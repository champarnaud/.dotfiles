#!/usr/bin/env bash

# Vérifier si on est en mode auto (appelé depuis tmux.conf)
AUTO_MODE=false
if [[ "$1" == "--auto" ]]; then
    AUTO_MODE=true
fi

my_session=$(echo $HOSTNAME)

# Si en mode auto, vérifier qu'on n'est pas déjà dans une session configurée
if $AUTO_MODE; then
    # Ne rien faire si la session existe déjà et a plusieurs fenêtres/panes
    if tmux has-session -t "$my_session" 2>/dev/null; then
        current_windows=$(tmux list-windows -t "$my_session" | wc -l)
        if [[ $current_windows -gt 1 ]]; then
            exit 0
        fi
        current_panes=$(tmux list-panes -t "$my_session" | wc -l)
        if [[ $current_panes -gt 1 ]]; then
            exit 0
        fi
        # Supprimer la session existante si elle est vide
        tmux kill-session -t "$my_session" 2>/dev/null
    fi
fi

# Créer une nouvelle session tmux en arrière-plan
tmux new-session -d -s "$my_session"

# Diviser la fenêtre en deux panes horizontaux
tmux split-window -h

# Sélectionner le premier pane et lancer une commande
tmux select-pane -t 0
tmux send-keys 'cd' C-m

# Sélectionner le deuxième pane et lancer une autre commande
tmux select-pane -t 1
tmux send-keys 'htop' C-m
tmux split-window -v

# Sélectionner le troisième pane et lancer la surveillance des logs
tmux select-pane -t 2
tmux send-keys 'man tmux' C-m

# Attacher la session seulement si pas en mode auto
if ! $AUTO_MODE; then
    tmux attach-session -t "$my_session"
fi