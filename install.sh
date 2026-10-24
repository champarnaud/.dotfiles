#!/usr/bin/env bash

#------------------------------------------------------
# installation script for console conf files
# Author Jean-Christophe Champarnaud
# mail jc@champarnaud.fr
# Update 2026-10-24
#------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

#--- ENVIRONNEMENT
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly repconf="$SCRIPT_DIR/conf"
readonly repscripts="$SCRIPT_DIR/scripts"

# Sourcing du helper fm (avec fallback)
# shellcheck source=scripts/fm_helper.sh
source "$SCRIPT_DIR/scripts/fm_helper.sh" 2>/dev/null || {
    fm_available() { return 1; }
    smart_respond() { return 1; }
}

# Nom de la machine
[[ -e "$repconf/machine" ]] || echo "" > "$repconf/machine"

#--- FONCTIONS
check_tool() {
	local tool=""
	case $1 in
		tmux.conf) tool="tmux" ;;
		vimrc) tool="vim" ;;
		muttrc) tool="mutt" ;;
		*) return 0 ;;
	esac

	if ! command -v "$tool" &> /dev/null; then
		echo "$tool n'est pas installé."
		read -rp "Voulez-vous l'installer automatiquement ? (o/n) " response
		if [[ $response =~ ^[oO]$ ]]; then
			if "$repscripts/install_tools.sh"; then
				echo "$tool installé avec succès."
			else
				echo "Échec de l'installation de $tool. Installation du dotfile annulée."
				return 1
			fi
		else
			echo "Installation annulée pour $1"
			return 1
		fi
	fi
	return 0
}

creation_de_liens_symboliques() {
	if ! check_tool "$1"; then
		return 1
	fi

	mkdir -p "$SCRIPT_DIR/logs"

	if [[ -f ~/.$1 ]]
	then
		mv "$HOME/.$1" "$HOME/.$1.bak" 1>>"$SCRIPT_DIR/logs/install.log" 2>>"$SCRIPT_DIR/logs/error.log"
		echo "Le précédent fichier a été sauvegarde : $1.bak"
	fi

	if [[ -L ~/.$1 ]]
	then
		rm "$HOME/.$1"
		echo "Le précédent lien symbolique vers $1 a été supprimé."
	fi

	ln -s "$repconf/$1" "$HOME/.$1" 1>>"$SCRIPT_DIR/logs/install.log" 2>>"$SCRIPT_DIR/logs/error.log"

	echo -e "Le lien symbolique vers $1 a été créé.\n"
}

nommer_la_machine(){
	read -rp "Donnez un nom à votre machine : " machine
	echo "$machine" > "$repconf/machine"
}

execution_de_script(){
	echo "execution de script : $1 "
	bash "$repscripts/$1"
}

#--- MODE SMART
install_smart_mode() {
	if ! fm_available; then
		echo "⚠️  --smart indisponible (fm ou jq manquant)."
		echo "   Nécessite macOS 27+ et jq (brew install jq)."
		return 1
	fi

	echo "🤖 Mode smart : décrivez ce que vous voulez installer."
	echo "   Exemple : \"je veux tmux et zsh, pas mutt\""
	echo "   Tapez 'quit' pour annuler."
	echo ""
	read -rp "> " request

	if [[ -z "$request" || "$request" == "quit" ]]; then
		echo "Annulé."
		return 1
	fi

	# Lister les éléments disponibles
	local available
	available=$(ls "$repconf" 2>/dev/null; ls "$repscripts" 2>/dev/null | sed 's/\.sh$//')
	available=$(echo "$available" | grep -v '^$' | sort -u)

	if [[ -z "$available" ]]; then
		echo "⚠️  Aucun élément disponible dans conf/ ou scripts/."
		return 1
	fi

	# Créer le schéma
	local schema_file
	schema_file=$(mktemp /tmp/fm_schema_install.XXXXXX.json)
	# shellcheck disable=SC2064
	trap "rm -f '$schema_file'" RETURN

	if ! fm schema object --name "InstallPlan" \
		--string 'actions' --array \
		--string 'reasoning' > "$schema_file" 2>/dev/null; then
		echo "⚠️  Impossible de générer le schéma."
		return 1
	fi

	local output
	if ! output=$(smart_respond \
		--instructions "Tu es un assistant d'installation de dotfiles. On te donne une requête utilisateur et la liste des éléments disponibles (fichiers de conf/ et noms de scripts de scripts/). Retourne les actions à exécuter (noms exacts des fichiers de conf ou noms de scripts sans .sh) et une justification courte en français." \
		--prompt "Requête : ${request}\n\nÉléments disponibles :\n${available}" \
		--schema "$schema_file" \
		--timeout 60); then
		echo "⚠️  Échec de l'analyse fm."
		return 1
	fi

	if [[ -z "$output" ]]; then
		echo "⚠️  Échec de l'analyse fm."
		return 1
	fi

	echo ""
	echo "📋 Plan proposé :"
	echo "$output" | jq -r '.reasoning // "(pas de justification)"' 2>/dev/null
	echo ""
	echo "Actions :"
	echo "$output" | jq -r '.actions[]' 2>/dev/null | sed 's/^/  - /'
	echo ""

	read -rp "Exécuter ce plan ? (o/n) " confirm
	if [[ ! "$confirm" =~ ^[oO]$ ]]; then
		echo "Annulé."
		return 1
	fi

	# Exécution
	local action
	while read -r action; do
		[[ -z "$action" ]] && continue
		if [[ -f "$repconf/$action" ]]; then
			creation_de_liens_symboliques "$action"
		elif [[ -f "$repscripts/$action.sh" ]]; then
			execution_de_script "$action.sh"
		else
			echo "⚠️  Action inconnue : $action"
		fi
	done < <(echo "$output" | jq -r '.actions[]' 2>/dev/null)

	return 0
}

#--- MAIN
# Parsing des arguments
if [[ "$1" == "--smart" ]]; then
	install_smart_mode
	exit $?
fi
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	echo "Usage: $0 [--smart]"
	echo ""
	echo "Options:"
	echo "  --smart   Mode conversationnel via Apple Foundation Models (macOS 27+)"
	echo "  --help    Affiche cette aide"
	exit 0
fi

# Menu classique
installable=("$repconf"/*)
installable=("${installable[@]##*/}")
script_files=("$repscripts"/*.sh)
script_files=("${script_files[@]##*/}")
tab=("${installable[@]}" "${script_files[@]}")
tab+=("Tout")
tab+=("Installer-les-outils")
tab+=("Installer-les-dépendances-Zsh")
tab+=("Quitter")
options=${tab[*]}

PS3="Faites votre choix : "
select option in $options
do
	if [[ " ${options[@]} " =~ " ${option} " ]]
	then
		echo "Vous avez choisi l'option : $option"

		case $option in
			"Quitter")
				echo "Merci et au revoir"
				exit 9
				;;
			"Tout")
				echo -e "Patientez ...\n"
				for conf in "${installable[@]}"; do
					creation_de_liens_symboliques "$conf"
				done
				echo "C'est fait. Autre chose ?"
				;;
			"Installer-les-outils")
				echo "Installation des outils tmux, vim et mutt..."
				if "$repscripts/install_tools.sh"; then
					echo "Outils installés avec succès."
				else
					echo "Échec de l'installation des outils."
				fi
				echo "Autre chose ?"
				;;
			"Installer-les-dépendances-Zsh")
				echo "Installation des dépendances Zsh (Oh My Zsh, plugins, thème Powerlevel10k)..."
				if "$repscripts/install_zsh_deps.sh"; then
					echo "Dépendances Zsh installées avec succès."
				else
					echo "Échec de l'installation des dépendances Zsh."
				fi
				echo "Autre chose ?"
				;;
			"machine")
				nommer_la_machine && creation_de_liens_symboliques machine
				;;
			*)
				if [[ $option =~ \.sh$ ]]; then
					execution_de_script "$option"
				else
					creation_de_liens_symboliques "$option"
				fi
				echo "C'est fait. Autre chose ?"
				;;
		esac
	else
		echo "Option invalide. Veuillez choisir une option valide."
	fi
done
exit 0