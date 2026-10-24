#!/usr/bin/env bash

#-------------------------------------------------------
# Script de vérification de présence du répertoire 'jcc'
# dans le répertoire temporaire '/tmp'
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-07
#-------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly w_bash="$(command -v bash)"

if [[ -z "$w_bash" ]]; then
    echo "Erreur: bash introuvable."
    exit 1
fi

# Récupérer la crontab actuelle
current_cron=$(crontab -l 2>/dev/null || echo "")

# Ajouter en mémoire le cron de vérification toutes les 5 minutes
cron_line="*/5 * * * * cd \"$SCRIPT_DIR\" && \"$w_bash\" \"$SCRIPT_DIR/tmp_directory.sh\" > /tmp/stdout.log 2> /tmp/stderr.log"
legacy_cron_line="*/5 * * * * cd ~/.dotfiles/scripts && $w_bash tmp_directory.sh > /tmp/stdout.log 2> /tmp/stderr.log"
daily_cron_line="0 10 * * * cd \"$SCRIPT_DIR\" && \"$w_bash\" \"$SCRIPT_DIR/daily_brew_update.sh\" > /tmp/daily_stdout.log 2> /tmp/daily_stderr.log"
legacy_daily_cron_line="0 10 * * * cd ~/.dotfiles/scripts && $w_bash daily_brew_update.sh > /tmp/daily_stdout.log 2> /tmp/daily_stderr.log"
updated_cron=$(printf '%s\n' "$current_cron" | grep -Fvx -- "$legacy_cron_line" | grep -Fvx -- "$legacy_daily_cron_line" || true)
tmp_added=false
brew_added=false

# Vérifier si la ligne cron existe déjà
if ! grep -Fqx -- "$cron_line" <<< "$updated_cron"; then
    [[ -n "$updated_cron" ]] && updated_cron+=$'\n'
    updated_cron+="$cron_line"
    tmp_added=true
else
    echo "Tâche cron déjà présente pour tmp_directory"
fi

# Ajouter la tâche cron pour daily_brew_update tous les jours à 10:00
if ! grep -Fqx -- "$daily_cron_line" <<< "$updated_cron"; then
    [[ -n "$updated_cron" ]] && updated_cron+=$'\n'
    updated_cron+="$daily_cron_line"
    brew_added=true
else
    echo "Tâche cron déjà présente pour daily_brew_update"
fi

if [[ "$tmp_added" == true || "$brew_added" == true ]]; then
    if printf '%s\n' "$updated_cron" | crontab -; then
        [[ "$tmp_added" == true ]] && echo "Tâche cron ajoutée pour tmp_directory"
        [[ "$brew_added" == true ]] && echo "Tâche cron ajoutée pour daily_brew_update"
    else
        echo "Erreur: impossible de mettre à jour la crontab." >&2
        exit 1
    fi
fi
