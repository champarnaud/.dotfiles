# .dotfiles

Projet de rassemblement des fichiers de configurations

Librement inspiré du projet https://github.com/Chewie/dotfiles

## Installation
- cloner le projet dans le répertoire de l'utilisateur 
- Puis : 
``` 
cd ~/.dotfiles        # Se déplacer dans le dossier
./install.sh          # Exécuter l'installation
```

- Le fichier `install.sh` va créer les liens symboliques dans le
répertoire `/home/<user>` de l'utilisateur vers le répertoire `.dotfiles/`

## Fonctionnalités avancées

### Installation automatique des outils
Le script `install.sh` détecte automatiquement si les outils requis (tmux, vim, mutt) sont installés. Si absent, il propose l'installation automatique via `install_tools.sh`.

**Support multi-OS :**
- **macOS** : Installation via Homebrew (`brew install tmux vim mutt bat lsd`)
- **Linux Debian/Ubuntu** : Installation via apt (`sudo apt install tmux vim mutt bat lsd`)

### Scripts automatisés (`scripts/`)
Ces scripts peuvent être exécutés individuellement ou intégrés au processus d'installation :

* **`tmp_directory.sh`** : Crée un répertoire temporaire personnel (`/tmp/<user>`) et un lien symbolique (`~/tmp`). Installe automatiquement une tâche cron pour maintenance (toutes les 5 minutes)
* **`brew_upgrade.sh`** : Vérifie les mises à jour Homebrew disponibles et envoie un rapport par email (macOS uniquement)
* **`cron_manage.sh`** : Gestionnaire optimisé des tâches cron pour les scripts du projet

### Script utilitaire
* **`copie.sh`** : Script de copie récursive avec vérifications (origine, destination, permissions)

## Configurations incluses

### Zsh
Configuration complète avec :
- **Oh My Zsh** et thème **Powerlevel10k**
- Plugins : `zsh-autosuggestions`, `zsh-completions`, `zsh-syntax-highlighting`
- **Alias personnalisés** :
  - `ll="lsd -Alh"` et `ls="lsd -lh"` (remplacement moderne de ls)
  - `distupdate="sudo apt update && sudo apt upgrade"`
  - `gco="git commit -am"`
  - `pbc="php bin/console"`
- **FZF** pour la recherche floue
- Mode VI activé (`bindkey -v`)

### Vim
Configuration complète avec :
- Numérotation relative des lignes
- Coloration syntaxique et indentation intelligente
- **Raccourcis personnalisés** :
  - `CTRL-x + CTRL-v` : split vertical
  - `CTRL-x + CTRL-h` : split horizontal  
  - `;i` : reformatage de l'indentation
- Support souris, completion améliorée

### Tmux
- **Préfixe personnalisé** : `Ctrl+q` (au lieu de `Ctrl+b`)
- Navigation avec `Alt+flèches`
- Split shortcuts : `v` (vertical), `h` (horizontal)
- Souris activée, coloration 256 couleurs

### Mutt
Configuration email avec signature personnalisée.

### Bash
- Mode VI activé pour la ligne de commande

## Logs et maintenance
- **Logs automatiques** : `logs/install.log` et `logs/error.log`
- **Tâches cron** : Maintenance automatique des répertoires temporaires
- **Sauvegarde** : Fichiers existants sauvegardés avec suffixe `.bak`

## Compatibilité
- **macOS** (avec Homebrew)
- **Linux Debian/Ubuntu** (avec apt)
- **Architecture** : Intel et Apple Silicon supportés

## Qualité du code

### Git Hooks
Le projet inclut des **hooks Git locaux** pour maintenir la qualité :

- **`pre-commit`** : Vérifie automatiquement les fins de ligne CRLF dans les fichiers Markdown avant chaque commit
- **`pre-push`** : Vérification supplémentaire avant push

#### Installation des hooks :
```bash
./init-hooks.sh  # Initialise les hooks Git locaux
```

### Utilitaire de correction
- **`fix-line-endings.sh`** : Script utilitaire pour corriger les problèmes de fins de ligne
  ```bash
  ./fix-line-endings.sh check    # Vérifier les fins de ligne
  ./fix-line-endings.sh fix-md   # Corriger les fichiers .md
  ./fix-line-endings.sh fix-all  # Corriger tous les fichiers
  ```

### CI/CD (GitHub Actions)
- **Vérification automatique** des fins de ligne sur les PR et pushes
- **Blocage des commits** avec CRLF dans les fichiers Markdown

## Personnalisation
Les configurations peuvent être adaptées selon vos besoins :
- Modifier les alias dans `conf/zshrc`
- Ajuster les raccourcis Vim dans `conf/vimrc`
- Personnaliser Tmux dans `conf/tmux.conf`

