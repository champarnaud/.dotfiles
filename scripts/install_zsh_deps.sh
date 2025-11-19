#!/usr/bin/env bash

#------------------------------------------------------
# Script d'installation des dépendances Zsh
# Installe Oh My Zsh, Powerlevel10k et les plugins requis
# Support macOS (brew) et Linux/Debian (apt)
# Author: GitHub Copilot
# Update: 2025-11-19
#------------------------------------------------------

# Détection de l'OS
os=$(uname -s)

echo "🔧 Installation des dépendances Zsh..."
echo "Détection de l'OS: $os"
echo ""

# Fonction d'installation pour macOS
install_macos() {
    echo "📍 Installation sur macOS avec Homebrew..."

    # Vérifier si brew est installé
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew n'est pas installé. Veuillez l'installer d'abord : https://brew.sh/"
        exit 1
    fi

    # Installer Oh My Zsh si pas présent
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "📦 Installation d'Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "✅ Oh My Zsh déjà installé"
    fi

    # Installer Powerlevel10k
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo "🎨 Installation du thème Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    else
        echo "✅ Powerlevel10k déjà installé"
    fi

    # Installer les plugins
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "🔧 Installation du plugin zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    else
        echo "✅ zsh-autosuggestions déjà installé"
    fi

    # zsh-completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        echo "🔧 Installation du plugin zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
    else
        echo "✅ zsh-completions déjà installé"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo "🔧 Installation du plugin zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    else
        echo "✅ zsh-syntax-highlighting déjà installé"
    fi

    # Installer fzf si pas présent
    if ! command -v fzf &> /dev/null; then
        echo "🔍 Installation de fzf..."
        brew install fzf
        # Installer les completions fzf
        $(brew --prefix)/opt/fzf/install --no-bash --no-fish --key-bindings --completion --no-update-rc
    else
        echo "✅ fzf déjà installé"
    fi

    echo "✅ Installation terminée sur macOS !"
}

# Fonction d'installation pour Linux
install_linux() {
    echo "📍 Installation sur Linux..."

    # Vérifier si apt est disponible
    if ! command -v apt &> /dev/null; then
        echo "❌ apt n'est pas disponible. Ce script est conçu pour Debian/Ubuntu."
        exit 1
    fi

    # Installer Oh My Zsh si pas présent
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "📦 Installation d'Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "✅ Oh My Zsh déjà installé"
    fi

    # Installer Powerlevel10k
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        echo "🎨 Installation du thème Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    else
        echo "✅ Powerlevel10k déjà installé"
    fi

    # Installer les plugins
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "🔧 Installation du plugin zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    else
        echo "✅ zsh-autosuggestions déjà installé"
    fi

    # zsh-completions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
        echo "🔧 Installation du plugin zsh-completions..."
        git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
    else
        echo "✅ zsh-completions déjà installé"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo "🔧 Installation du plugin zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    else
        echo "✅ zsh-syntax-highlighting déjà installé"
    fi

    # Installer fzf si pas présent
    if ! command -v fzf &> /dev/null; then
        echo "🔍 Installation de fzf..."
        sudo apt update
        sudo apt install -y fzf
    else
        echo "✅ fzf déjà installé"
    fi

    echo "✅ Installation terminée sur Linux !"
}

# Installation selon l'OS
case "$os" in
    "Darwin")
        install_macos
        ;;
    "Linux")
        install_linux
        ;;
    *)
        echo "❌ OS non supporté ($os). Ce script supporte macOS et Linux Debian/Ubuntu uniquement."
        exit 1
        ;;
esac

echo ""
echo "🎉 Toutes les dépendances Zsh ont été installées !"
echo ""
echo "💡 Pour appliquer la configuration :"
echo "   source ~/.zshrc"
echo ""
echo "🔧 Si vous voulez configurer Powerlevel10k :"
echo "   p10k configure"