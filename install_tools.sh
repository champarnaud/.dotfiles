#!/bin/bash

#------------------------------------------------------
# Script d'installation des outils tmux, vim, mutt, bat et lsd
# Support macOS (brew) et Linux/Debian (apt)
# Author: Jean-Christophe Champarnaud
# Update: 2025-11-07
#------------------------------------------------------

# Détection de l'OS
os=$(uname -s)

echo "Détection de l'OS: $os"

if [ "$os" = "Darwin" ]; then
    echo "Installation sur macOS avec Homebrew..."
    # Vérifier si brew est installé
    if ! command -v brew &> /dev/null; then
        echo "Erreur: Homebrew n'est pas installé. Veuillez l'installer d'abord."
        echo "Visitez: https://brew.sh/"
        exit 1
    fi
    # Installation des paquets
    brew update
    brew install tmux vim mutt bat lsd
    echo "Installation terminée sur macOS."

elif [ "$os" = "Linux" ]; then
    echo "Installation sur Linux avec apt..."
    # Vérifier si apt est disponible
    if ! command -v apt &> /dev/null; then
        echo "Erreur: apt n'est pas disponible. Ce script est conçu pour Debian/Ubuntu."
        exit 1
    fi
    # Installation des paquets
    sudo apt update
    sudo apt install -y tmux vim mutt bat lsd
    echo "Installation terminée sur Linux."

else
    echo "Erreur: OS non supporté ($os). Ce script supporte macOS et Linux/Debian uniquement."
    exit 1
fi

echo "Les outils tmux, vim, mutt, bat et lsd ont été installés avec succès."