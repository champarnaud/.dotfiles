#!/usr/bin/env bash

#--------------------------------------------
# Test des upgrade necessaire de brew
# et envois de l'information par mail
# Author : Jean-Christophe Champarnaud
# Last update : 2026-10-24
#--------------------------------------------

# Sourcing du helper fm (avec fallback si absent)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=fm_helper.sh
source "$SCRIPT_DIR/fm_helper.sh" 2>/dev/null || {
    fm_available() { return 1; }
    smart_respond() { return 1; }
}

#--- Parsing des arguments
SMART=false
for arg in "$@"; do
    case "$arg" in
        --smart) SMART=true ;;
        --help|-h)
            echo "Usage: $0 [--smart]"
            echo ""
            echo "Options:"
            echo "  --smart   Utilise Apple Foundation Models pour générer"
            echo "            un résumé intelligent du rapport (macOS 27+)"
            exit 0
            ;;
        *)
            echo "Option inconnue : $arg" >&2
            exit 1
            ;;
    esac
done

#- S'assurer que l'on est sous mac
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

# Appel de la mise à jour de Brew et extraction des paquets à mettre à jour
brew update

# Récupérer les paquets à mettre à jour
brew outdated > /tmp/brew.outdated

# si pas de maj pas de mail
nb_lignes=$(wc -l < /tmp/brew.outdated | awk '{print $1}')

if [ "$nb_lignes" -gt 0 ]
then
    # Préparer le corps du mail
    if $SMART && fm_available; then
        echo "🔍 Génération d'un résumé intelligent..."
        summary=$(smart_respond \
            --instructions "Tu résumes une liste de paquets Homebrew à mettre à jour. Produis un résumé court en français, en 3-5 lignes, en signalant les mises à jour de sécurité ou majeures si tu peux les identifier." \
            --prompt "Paquets à mettre à jour :\n\n$(cat /tmp/brew.outdated)" \
            --timeout 60)

        if [[ $? -eq 0 && -n "$summary" ]]; then
            {
                echo "=== Résumé (fm) ==="
                echo "$summary"
                echo ""
                echo "=== Détail ==="
                cat /tmp/brew.outdated
            } > /tmp/brew.mailbody
        else
            echo "⚠️  Résumé fm indisponible, envoi du rapport brut."
            cp /tmp/brew.outdated /tmp/brew.mailbody
        fi
    else
        cp /tmp/brew.outdated /tmp/brew.mailbody
    fi

    # Envoi du mail (détection du chemin de mutt)
    mutt_path=$(command -v mutt || echo "/usr/local/bin/mutt")
    "$mutt_path" -s "Brew : $nb_lignes pack(s) to be updated" \
        jc@champarnaud.fr < /tmp/brew.mailbody #2> /dev/null
fi