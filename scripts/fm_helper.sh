#!/usr/bin/env bash

#-------------------------------------------------------
# Helper pour l'intégration d'Apple Foundation Models (fm)
# dans les scripts .dotfiles
#
# Ce fichier doit être SOURCÉ, pas exécuté :
#   source "$(dirname "$0")/fm_helper.sh"
#
# Fournit :
#   - fm_available()      : teste si fm et jq sont disponibles
#   - jq_available()      : teste si jq est disponible
#   - smart_respond()     : wrapper autour de `fm respond` avec
#                           dégradation gracieuse et gestion d'erreurs
#
# Author : Jean-Christophe Champarnaud
# Update : 2026-10-24
#-------------------------------------------------------

#--- Détection des outils

# jq_available : retourne 0 si jq est installé
jq_available() {
    command -v jq &> /dev/null
}

# fm_available : retourne 0 si fm ET jq sont installés
# (jq est requis pour parser les sorties structurées)
fm_available() {
    command -v fm &> /dev/null && jq_available
}

# fm_require : affiche un message d'erreur clair si fm n'est pas dispo
# Usage : fm_require || return 1
fm_require() {
    if ! command -v fm &> /dev/null; then
        echo "⚠️  fm n'est pas disponible sur cette machine." >&2
        echo "   L'option --smart nécessite macOS 27+ (Apple Foundation Models)." >&2
        return 1
    fi
    if ! jq_available; then
        echo "⚠️  jq n'est pas installé (requis pour parser les sorties fm)." >&2
        echo "   Installez-le : brew install jq  (macOS) ou sudo apt install jq  (Linux)" >&2
        return 1
    fi
    return 0
}

#--- Wrapper principal

# smart_respond : wrapper autour de `fm respond`
#
# Usage :
#   smart_respond --instructions "..." --prompt "..." [--schema fichier] [--model pcc]
#
# Options :
#   --instructions <texte>  : instructions système (optionnel)
#   --prompt <texte>        : le prompt utilisateur (requis)
#   --schema <fichier>      : fichier JSON de schéma (optionnel)
#   --model <nom>           : modèle à utiliser (optionnel, défaut: embarqué)
#   --timeout <secondes>    : timeout (optionnel, défaut: 60)
#
# Retourne :
#   0 et affiche la réponse sur stdout en cas de succès
#   1 et affiche un message d'erreur sur stderr en cas d'échec
#
# En cas d'échec, la fonction ne fait PAS planter le script appelant :
# c'est à l'appelant de gérer le fallback.
smart_respond() {
    local instructions=""
    local prompt=""
    local schema=""
    local model=""
    local timeout=60

    # Parsing des arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --instructions) instructions="$2"; shift 2 ;;
            --prompt)       prompt="$2";       shift 2 ;;
            --schema)       schema="$2";       shift 2 ;;
            --model)        model="$2";        shift 2 ;;
            --timeout)      timeout="$2";      shift 2 ;;
            *)
                echo "smart_respond: option inconnue '$1'" >&2
                return 1
                ;;
        esac
    done

    # Vérifications
    if [[ -z "$prompt" ]]; then
        echo "smart_respond: --prompt est requis" >&2
        return 1
    fi

    if ! fm_require; then
        return 1
    fi

    if [[ -n "$schema" && ! -f "$schema" ]]; then
        echo "smart_respond: fichier de schéma introuvable : $schema" >&2
        return 1
    fi

    # Construction de la commande
    # On utilise un tableau pour éviter les problèmes de quoting
    local -a cmd=(fm respond)

    [[ -n "$instructions" ]] && cmd+=(--instructions "$instructions")
    [[ -n "$schema" ]]       && cmd+=(--schema "$schema")
    [[ -n "$model" ]]        && cmd+=(--model "$model")
    cmd+=("$prompt")

    # Exécution avec timeout si disponible
    local output
    local rc
    if command -v timeout &> /dev/null; then
        output=$(timeout "$timeout" "${cmd[@]}" 2>/dev/null)
        rc=$?
    else
        # macOS n'a pas timeout par défaut ; on exécute sans
        output=$("${cmd[@]}" 2>/dev/null)
        rc=$?
    fi

    if [[ $rc -ne 0 ]]; then
        echo "smart_respond: échec de l'appel fm (code $rc)" >&2
        return 1
    fi

    if [[ -z "$output" ]]; then
        echo "smart_respond: réponse vide de fm" >&2
        return 1
    fi

    # Si un schéma est fourni, valider que la sortie est du JSON valide
    if [[ -n "$schema" ]]; then
        if ! echo "$output" | jq empty 2>/dev/null; then
            echo "smart_respond: la réponse de fm n'est pas du JSON valide" >&2
            return 1
        fi
    fi

    echo "$output"
    return 0
}