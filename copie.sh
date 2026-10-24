#!/usr/bin/env bash

#------------------------------------------------------
# Script de copie récursive d'un répertoire vers un autre
# Demande les répertoires source et destination si non fournis
# Author : Jean-Christophe Champarnaud
#------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MAX_SMART_FILES=40
SMART_TMP_DIR=""

usage() {
	echo "Usage: $SCRIPT_NAME [--smart] [source [destination]]"
}

cleanup() {
	if [[ -n "$SMART_TMP_DIR" && -d "$SMART_TMP_DIR" ]]; then
		rm -rf "$SMART_TMP_DIR"
	fi
}

trap cleanup EXIT

copy_smart_files() {
	local source_dir="$1"
	local destination_dir="$2"
	local manifest_file schema_file files_json output source_file relative_path
	local file_description preview
	local selected_file encoded_file found file_count=0 selected_count=0
	local -a candidates=()
	local -a selected=()

	# shellcheck source=scripts/fm_helper.sh
	source "$SCRIPT_DIR/scripts/fm_helper.sh" || return 1
	if ! fm_available; then
		echo "Erreur: --smart nécessite fm et jq." >&2
		return 1
	fi

	SMART_TMP_DIR=$(mktemp -d) || {
		echo "Erreur: impossible de créer le répertoire temporaire." >&2
		return 1
	}
	manifest_file="$SMART_TMP_DIR/files.jsonl"
	schema_file="$SMART_TMP_DIR/schema.json"

	while IFS= read -r -d '' source_file; do
		relative_path="${source_file#"$source_dir"/}"
		candidates[file_count]="$relative_path"
		file_count=$((file_count + 1))
		if (( file_count > MAX_SMART_FILES )); then
			echo "Erreur: --smart accepte au maximum $MAX_SMART_FILES fichiers. Réduisez le dossier source." >&2
			return 1
		fi
		preview=""
		file_description=$(file -b "$source_file" 2>/dev/null || true)
		case "$file_description" in
			*text*|*JSON*|*XML*|*HTML*|*CSV*|*script*)
				preview=$(head -c 1024 "$source_file" | tr '\r\n' '  ')
				;;
		esac
		jq -cn --arg path "$relative_path" --arg preview "$preview" \
			'{path: $path, preview: $preview}' >> "$manifest_file"
	done < <(find "$source_dir" -type f -print0)

	if (( file_count == 0 )); then
		echo "Aucun fichier à analyser dans '$source_dir'."
		return 0
	fi

	files_json=$(jq -s '.' "$manifest_file")
	if ! fm schema object --name "CopyPlan" \
		--string 'finals' --array \
		--string 'reasoning' > "$schema_file"; then
		echo "Erreur: impossible de générer le schéma de classification." >&2
		return 1
	fi

	if ! output=$(smart_respond \
		--instructions "Tu classes des fichiers pour une sauvegarde. Sélectionne uniquement les fichiers clairement finalisés et prêts à être conservés. Exclue les brouillons, fichiers temporaires, sauvegardes automatiques et versions intermédiaires. N'invente aucun chemin; en cas de doute, exclus le fichier. Réponds avec les chemins relatifs exacts présents dans la liste." \
		--prompt "Fichiers à classer (JSON):\n${files_json}" \
		--schema "$schema_file" \
		--timeout 60); then
		echo "Erreur: la classification fm a échoué." >&2
		return 1
	fi

	if ! jq -e '
		type == "object" and
		(.finals | type == "array") and
		all(.finals[]; type == "string") and
		(.reasoning | type == "string")
	' <<< "$output" >/dev/null; then
		echo "Erreur: réponse de classification invalide." >&2
		return 1
	fi

	while IFS= read -r encoded_file; do
		selected_file=$(jq -r '.' <<< "$encoded_file")
		found=false
		for relative_path in "${candidates[@]}"; do
			if [[ "$selected_file" == "$relative_path" ]]; then
				found=true
				break
			fi
		done
		if [[ "$found" != true ]]; then
			echo "Erreur: fm a retourné un chemin inconnu : $selected_file" >&2
			return 1
		fi
		if (( selected_count > 0 )); then
			for relative_path in "${selected[@]}"; do
				if [[ "$selected_file" == "$relative_path" ]]; then
					echo "Erreur: fm a retourné un fichier en double : $selected_file" >&2
					return 1
				fi
			done
		fi
		selected[selected_count]="$selected_file"
		selected_count=$((selected_count + 1))
	done < <(jq -c '.finals[]' <<< "$output")

	echo "Analyse : $(jq -r '.reasoning' <<< "$output")"
	if (( selected_count == 0 )); then
		echo "Aucun fichier final retenu; rien à copier."
		return 0
	fi

	local target_root="$destination_dir/$(basename "$source_dir")"
	for selected_file in "${selected[@]}"; do
		local target_file="$target_root/$selected_file"
		mkdir -p "$(dirname "$target_file")"
		cp -uv "$source_dir/$selected_file" "$target_file"
	done
}

smart=false
case "${1:-}" in
	--smart)
		smart=true
		shift
		;;
	-h|--help)
		usage
		exit 0
		;;
esac

if [[ $# -gt 2 ]]; then
	usage >&2
	exit 2
fi

if [[ $# -eq 0 ]]; then
	read -rp "Quel est le répertoire d'origine ? (défaut .) : " orig
	orig="${orig:-.}"

	read -rp "Quel est le répertoire de destination ? (defaut ~) : " dest
	dest="${dest:-$HOME}"
else
	orig="${1:-.}"
	dest="${2:-$HOME}"
fi

echo "Origine: $orig"
echo "Destination: $dest"

# Vérifier que le répertoire d'origine existe
source_input="$orig"
if ! orig=$(cd "$orig" 2>/dev/null && pwd -P); then
	echo "Erreur: Le répertoire d'origine '$source_input' n'existe pas."
	exit 1
fi

# Créer le répertoire de destination si nécessaire
if ! mkdir -p "$dest"; then
	echo "Erreur: impossible de créer le répertoire de destination '$dest'." >&2
	exit 1
fi
dest=$(cd "$dest" && pwd -P)

source_prefix="${orig%/}/"
case "$dest/" in
	"$source_prefix"*)
		echo "Erreur: la destination ne peut pas se trouver dans le répertoire source." >&2
		exit 1
		;;
esac

if [[ "$smart" == true ]]; then
	copy_smart_files "$orig" "$dest"
else
	# Copier récursivement avec mise à jour
	cp -uvr "$orig" "$dest"
fi
