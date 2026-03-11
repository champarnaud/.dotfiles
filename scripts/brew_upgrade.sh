#!/usr/bin/env bash

#--------------------------------------------
# Test des upgrade necessaire de brew
# et envois de l'information par mail
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-07
#--------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
OUTDATED_FILE=""

cleanup() {
    if [[ -n "${OUTDATED_FILE:-}" && -f "$OUTDATED_FILE" ]]; then
        rm -f "$OUTDATED_FILE"
    fi
}

trap cleanup EXIT

#- S'assurer que l'on est sous mac
os=$(uname -s)

if [[ "$os" != "Darwin" ]]; then
	echo "Ce n'est pas une plateforme Mac"
	exit 1
fi

# Vérifier si brew est installé
if ! command -v brew &> /dev/null; then
	echo "Erreur: Homebrew n'est pas installé."
	exit 1
fi

# Appel de la mise à jour de Brew et extraction des paquets à mettre à jour
brew update

# Récupérer les paquets à mettre à jour dans un fichier temporaire sécurisé
OUTDATED_FILE="$(mktemp)"
brew outdated > "$OUTDATED_FILE"

# si pas de maj pas de mail
nb_lignes=$(wc -l < "$OUTDATED_FILE")

if [[ "$nb_lignes" -gt 0 ]]; then
	# Envoi du mail
	/usr/local/bin/mutt -s "Brew : $nb_lignes pack(s) to be updated" \
		jc@champarnaud.fr < "$OUTDATED_FILE" 2> /dev/null
fi

