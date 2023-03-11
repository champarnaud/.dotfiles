#! /bin/bash

#--------------------------------------------
# Test des upgrade necessaire de brew
# et envois de l'information par mail
# Author : Jean-Christophe Champarnaud
# Last update : 2023-03-11
#--------------------------------------------

# Appel de la mise à jour de Brew et extraction des paquest à mettre à jour
/usr/local/bin/brew update 

# Récupérer les paquets à mettre à jour
/usr/local/bin/brew outdated > /tmp/brew.outdated

# si pas de maj pas de mail
nb_lignes=$(wc -l /tmp/brew.outdated | awk '{print $1}')

if [ $nb_lignes -gt 0 ] 
then
	# Envoi du mail
	/usr/local/bin/mutt -s "Brew : $nb_lignes pack(s) to be updated" \
		jc@champarnaud.fr < /tmp/brew.outdated 2> /dev/null
fi

