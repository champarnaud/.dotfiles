#!/usr/bin/env bash

#--------------------------------------------
# Script de mise à jour quotidienne de Homebrew et des paquets
# Author : Jean-Christophe Champarnaud
# Last update : 2025-11-15
#--------------------------------------------

# S'assurer que l'on est sous mac
os=$(uname -a | awk '{print $1}')

if [ "$os" != "Darwin" ]
then
    echo "Ce n'est pas une plateforme Mac"
    exit 1
fi

# Vérifier si brew est installé
if ! command -v brew &> /dev/null; then
    echo "Erreur: Homebrew n'est pas installé."
    exit 1
fi

# Mise à jour de Homebrew lui-même
echo "Mise à jour de Homebrew..."
brew update

# Mise à jour des paquets installés
echo "Mise à jour des paquets..."
brew upgrade

echo "Mise à jour terminée."