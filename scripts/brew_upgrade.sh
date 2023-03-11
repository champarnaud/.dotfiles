#! /bin/bash

#--------------------------------------------
# Test des upgrade necessaire de brew
# et envois de l'information par mail
# Author : Jean-Christophe Champarnaud
# Last update : 2023-03-11
#--------------------------------------------

# Appel de la mise à jour de Brew et extraction des paquest à mettre à jour
/usr/local/bin/brew update && \
/usr/local/bin/brew outdated > /tmp/brew.outdate && cat /tmp/brew.outdate

# Envoi du mail
mutt -s "Update brew à faire" jc@champarnaud.fr < /tmp/brew.outdate
