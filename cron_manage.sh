#!/bin/bash

#-------------------------------------------------------
# Script de vérification de présence du répertoire 'jcc'
# dans le répertoire temporaire '/tmp'
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-07
#-------------------------------------------------------

w_bash=$(which bash)

# ajout du cron pour le paramètre passé à l'appel du script 
cron_line="*/5 * * * * cd ~/.dotfiles/scripts && $w_bash $1.sh > /tmp/stdout.log 2> /tmp/stderr.log"

# Récupérer la crontab actuelle
current_cron=$(crontab -l 2>/dev/null || echo "")

# Vérifier si la ligne cron existe déjà
if ! echo "$current_cron" | grep -qF "$cron_line"; then
    # Ajouter la nouvelle ligne et recharger la crontab
    (echo "$current_cron"; echo "$cron_line") | crontab -
    echo "Tâche cron ajoutée pour $1"
else
    echo "Tâche cron déjà présente pour $1"
fi
