#!/usr/bin/env bash

echo $# $0 $1 $2 $3

if [ $# -eq 0 ]
then
	read -p "Quel est le répertoire d'origine ? (défaut .) : " orig
	if [ -z "$orig" ]; then
		orig='.'
	fi

	read -p "Quel est le répertoire de destination ? (defaut ~) : " dest
	if [ -z "$dest" ]; then
		dest='~'
	fi
else
	orig=${1:-'.'}
	dest=${2:-'~'}
fi

echo "Origine: $orig"
echo "Destination: $dest"

# Vérifier que le répertoire d'origine existe
if [ ! -d "$orig" ]; then
	echo "Erreur: Le répertoire d'origine '$orig' n'existe pas."
	exit 1
fi

# Créer le répertoire de destination si nécessaire
if [ ! -d "$dest" ]; then
	mkdir -p "$dest"
fi

# Copier récursivement avec mise à jour
cp -uvr "$orig" "$dest"
