#!/bin/bash

#----------------------------------------------------------
# Script de vérification de présence du répertoire <user>
# dans le répertoire temporaire '/tmp'
# Support macOS et Linux (Debian/Ubuntu)
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-07
#----------------------------------------------------------

# Vérification de l'OS supporté
os=$(uname -s)
if [ "$os" = "Darwin" ]; then
    echo "Configuration pour macOS"
elif [ "$os" = "Linux" ]; then
    if command -v apt &> /dev/null; then
        echo "Configuration pour Linux Debian/Ubuntu"
    else
        echo "Erreur: OS Linux non supporté (apt non trouvé). Ce script est conçu pour Debian/Ubuntu."
        exit 1
    fi
else
    echo "Erreur: OS non supporté ($os). Ce script supporte macOS et Linux Debian/Ubuntu uniquement."
    exit 1
fi

quisuisje=$(whoami)

# vérification si /tmp/jcc existe sinon création	
[ -d /tmp/jcc ] || mkdir /tmp/"$quisuisje"

# vérification si le raccourci est présent dans /home/<user>
[ -h ~/tmp ] || ln -s /tmp/"$quisuisje" ~/tmp

# installation du cron
source ./cron_manage.sh tmp_directory
