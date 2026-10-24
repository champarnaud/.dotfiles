# .dotfiles

Projet de rassemblement des fichiers de configurations

Librement inspiré du projet https://github.com/Chewie/dotfiles

## Installation
Clonez le projet dans le répertoire de votre choix, puis lancez l'installateur :

```bash
cd /chemin/vers/le/dépôt
./install.sh
```

`~/.dotfiles` reste un emplacement conventionnel, mais n'est pas obligatoire.
Les chemins des configurations et des scripts sont calculés depuis le dépôt ;
`install.sh` peut donc aussi être lancé depuis un autre répertoire.

L'installateur crée les liens symboliques dans le répertoire personnel (`~`).
L'option **Tout** lie uniquement les fichiers de configuration ; les scripts
restent disponibles séparément dans le menu.

## Fonctionnalités avancées

### Installation automatique des outils
Le script `install.sh` détecte automatiquement si les outils requis (tmux, vim, mutt) sont installés. Si absent, il propose l'installation automatique via `install_tools.sh`.

**Support multi-OS :**
- **macOS** : Installation via Homebrew (`brew install tmux vim mutt bat lsd`)
- **Linux Debian/Ubuntu** : Installation via apt (`sudo apt install tmux vim mutt bat lsd`)

Les scripts signalent les échecs de mise à jour ou d'installation des paquets,
ainsi que les échecs de clonage des dépendances Zsh, au lieu d'annoncer un succès.

### Installation automatique des dépendances Zsh
Le script `install.sh` propose une option dédiée pour installer automatiquement toutes les dépendances Zsh nécessaires (Oh My Zsh, plugins et thème Powerlevel10k).

**Ce qui est installé :**
- **Oh My Zsh** : Framework de configuration Zsh
- **Thème Powerlevel10k** : Thème moderne et performant
- **Plugins** : zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting
- **Outils** : fzf (fuzzy finder)

### Scripts automatisés (`scripts/`)
Ces scripts peuvent être exécutés individuellement ou intégrés au processus d'installation :

* **`tmp_directory.sh`** : Crée un répertoire temporaire personnel (`/tmp/<user>`) et un lien symbolique (`~/tmp`), puis configure les tâches cron du projet.
* **`brew_upgrade.sh`** : Vérifie les mises à jour Homebrew disponibles et envoie un rapport par email (macOS uniquement)
* **`cron_manage.sh`** : Ajoute les tâches cron de maintenance (toutes les 5 minutes) et de mise à jour Homebrew (tous les jours à 10 h), en préservant les tâches existantes. Les commandes utilisent le chemin réel du dépôt.

### Script utilitaire
* **`copie.sh`** : Script de copie récursive avec vérifications (origine, destination, permissions)

### Intégration Apple Foundation Models (macOS 27+)

Sur macOS 27 et versions ultérieures, certains scripts offrent une option
`--smart` qui utilise **Apple Foundation Models** via l'outil `fm` pour
améliorer les actions de manière contextuelle.

**Prérequis :**
- macOS 27+ (l'outil `fm` est préinstallé)
- `jq` installé (`brew install jq`)

**Scripts concernés :**

| Script | Option | Effet |
|---|---|---|
| `copie.sh` | `--smart` | Classe les fichiers en "finaux" / "brouillons" via `fm` et ne copie que les finaux |
| `scripts/brew_upgrade.sh` | `--smart` | Génère un résumé intelligent des mises à jour Homebrew dans le mail |
| `install.sh` | `--smart` | Mode conversationnel : décrivez ce que vous voulez installer en langage naturel |

**Exemples :**

```bash
# Copie intelligente : ne garde que les fichiers finaux
./copie.sh --smart ~/projet ~/backup

# Rapport brew avec résumé
./scripts/brew_upgrade.sh --smart

# Installation guidée en langage naturel
./install.sh --smart
# > je veux tmux et zsh, pas mutt
```

## Configurations incluses

### Zsh
Configuration complète avec installation automatique des dépendances :
- **Oh My Zsh** et thème **Powerlevel10k** (installés automatiquement)
- Plugins : `zsh-autosuggestions`, `zsh-completions`, `zsh-syntax-highlighting` (installés automatiquement)
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

