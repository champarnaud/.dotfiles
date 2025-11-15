#!/usr/bin/env bash

#-------------------------------------------------------
# Script de vérification de présence du répertoire 'jcc'
# dans le répertoire temporaire '/tmp'
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-07
#-------------------------------------------------------

w_bash=$(which bash)

# Récupérer la crontab actuelle
current_cron=$(crontab -l 2>/dev/null || echo "")

# ajout du cron pour vérification du répertoire 'jcc' toutes les 5 minutes
cron_line="*/5 * * * * cd ~/.dotfiles/scripts && $w_bash tmp_directory.sh > /tmp/stdout.log 2> /tmp/stderr.log"

# Vérifier si la ligne cron existe déjà
if ! echo "$current_cron" | grep -qF "$cron_line"; then
    # Ajouter la nouvelle ligne et recharger la crontab
    (echo "$current_cron"; echo "$cron_line") | crontab -
    echo "Tâche cron ajoutée pour tmp_directory"
else
    echo "Tâche cron déjà présente pour tmp_directory"
fi

# Ajouter la tâche cron pour daily_brew_update tous les jours à 10:00
daily_cron_line="0 10 * * * cd ~/.dotfiles/scripts && $w_bash daily_brew_update.sh > /tmp/daily_stdout.log 2> /tmp/daily_stderr.log"

if ! echo "$current_cron" | grep -qF "$daily_cron_line"; then
    # Ajouter la nouvelle ligne et recharger la crontab
    (echo "$current_cron"; echo "$daily_cron_line") | crontab -
    echo "Tâche cron ajoutée pour daily_brew_update"
else
    echo "Tâche cron déjà présente pour daily_brew_update"
fi
