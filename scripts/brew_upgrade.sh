#!/usr/bin/env bash

#--------------------------------------------
# Test des upgrade necessaire de brew
# et envois de l'information par mail
# Author : Jean-Christophe Champarnaud
# Last update : 2026-10-24
#--------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDATED_FILE=""
MAIL_BODY_FILE=""

cleanup() {
    [[ -n "$OUTDATED_FILE" && -f "$OUTDATED_FILE" ]] && rm -f "$OUTDATED_FILE"
    [[ -n "$MAIL_BODY_FILE" && -f "$MAIL_BODY_FILE" ]] && rm -f "$MAIL_BODY_FILE"
}

trap cleanup EXIT

# Sourcing du helper fm (avec fallback si absent)
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
os=$(uname -s)

if [[ "$os" != "Darwin" ]]; then
    echo "Ce n'est pas une plateforme Mac"
    exit 1
fi

# Vérifier si brew est installé
if ! command -v brew &> /dev/null; then
    echo "Erreur: Homebrew n'est pas installé."
    exit 1
fi

# Appel de la mise à jour de Brew et extraction des paquets à mettre à jour
if ! brew update; then
    echo "Erreur: échec de la mise à jour Homebrew." >&2
    exit 1
fi

# Récupérer les paquets à mettre à jour dans un fichier temporaire sécurisé
OUTDATED_FILE="$(mktemp)"
if ! brew outdated > "$OUTDATED_FILE"; then
    echo "Erreur: impossible de récupérer les paquets obsolètes Homebrew." >&2
    exit 1
fi

# si pas de maj pas de mail
nb_lignes=$(wc -l < "$OUTDATED_FILE")

if [[ "$nb_lignes" -gt 0 ]]; then
    MAIL_BODY_FILE="$(mktemp)"
    if [[ "$SMART" == true ]] && fm_available; then
        echo "🔍 Génération d'un résumé intelligent..."
        if summary=$(smart_respond \
            --instructions "Tu résumes une liste de paquets Homebrew à mettre à jour. Produis un résumé court en français, en 3-5 lignes, en signalant les mises à jour de sécurité ou majeures si tu peux les identifier." \
            --prompt "Paquets à mettre à jour :\\n\\n$(cat "$OUTDATED_FILE")" \
            --timeout 60); then
            {
                echo "=== Résumé (fm) ==="
                echo "$summary"
                echo ""
                echo "=== Détail ==="
                cat "$OUTDATED_FILE"
            } > "$MAIL_BODY_FILE"
        else
            echo "⚠️  Résumé fm indisponible, envoi du rapport brut."
            cp "$OUTDATED_FILE" "$MAIL_BODY_FILE"
        fi
    else
        cp "$OUTDATED_FILE" "$MAIL_BODY_FILE"
    fi

    # Envoi du mail (détection du chemin de mutt)
    mutt_path=$(command -v mutt || echo "/usr/local/bin/mutt")
    if ! "$mutt_path" -s "Brew : $nb_lignes pack(s) to be updated" \
        jc@champarnaud.fr < "$MAIL_BODY_FILE"; then
        echo "Erreur: échec de l'envoi du rapport Homebrew." >&2
        exit 1
    fi
fi