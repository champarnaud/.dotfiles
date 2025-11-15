#!/usr/bin/env bash

# Créer une nouvelle session tmux en arrière-plan
tmux new-session -d -s my_session

# Diviser la fenêtre en deux panes horizontaux
tmux split-window -h

# Sélectionner le premier pane et lancer une commande
tmux select-pane -t 0
tmux send-keys 'tail -f /var/log/system.log' C-m

# Sélectionner le deuxième pane et lancer une autre commande
tmux select-pane -t 1
tmux send-keys 'htop' C-m

# Attacher la session pour l'afficher
tmux attach-session -t my_session