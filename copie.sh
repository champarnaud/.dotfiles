#!/usr/bin/env bash

#------------------------------------------------------
# Script de copie récursive d'un répertoire vers un autre
# Demande les répertoires source et destination si non fournis
# Author : Jean-Christophe Champarnaud
#------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

if [[ $# -eq 0 ]]; then
	read -rp "Quel est le répertoire d'origine ? (défaut .) : " orig
	orig="${orig:-.}"

	read -rp "Quel est le répertoire de destination ? (defaut ~) : " dest
	dest="${dest:-$HOME}"
else
	orig="${1:-.}"
	dest="${2:-$HOME}"
echo "Origine: $orig"
echo "Destination: $dest"

# Vérifier que le répertoire d'origine existe
if [[ ! -d "$orig" ]]; then
	echo "Erreur: Le répertoire d'origine '$orig' n'existe pas."
	exit 1
fi

# Créer le répertoire de destination si nécessaire
if [[ ! -d "$dest" ]]; then
	mkdir -p "$dest"
fi

# Copier récursivement avec mise à jour
cp -uvr "$orig" "$dest"
