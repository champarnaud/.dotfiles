#!/usr/bin/env bash

#--------------------------------------------
# Test des upgrade necessaire de brew
# et envois de l'information par mail
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-07
#--------------------------------------------

#- S'assurer que l'on est sous mac
os=$(uname -a | awk '{print $1}')

if [ "$os" !=  "Darwin" ]
then
	echo "Ce n'est pas une plateforme Mac"
	exit 1
fi

# Vérifier si brew est installé
if ! command -v brew &> /dev/null; then
	echo "Erreur: Homebrew n'est pas installé."
	exit 1
fi

# Appel de la mise à jour de Brew et extraction des paquest à mettre à jour
brew update 

# Récupérer les paquets à mettre à jour
brew outdated > /tmp/brew.outdated

# si pas de maj pas de mail
nb_lignes=$(wc -l /tmp/brew.outdated | awk '{print $1}')

if [ $nb_lignes -gt 0 ] 
then
	# Envoi du mail
	/usr/local/bin/mutt -s "Brew : $nb_lignes pack(s) to be updated" \
		jc@champarnaud.fr < /tmp/brew.outdated 2> /dev/null
fi

