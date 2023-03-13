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
répertoire `Home` de l'utilisateur vers le répertoire `.dotfiles`

## Scripts (`*.sh`)
Ce sont des scripts de personalisations de l'environnement pour la plus part.
Vous pouvez les appliquer depuis la ligne de commandes ou les piloter depuis 
le script principale `install.sh` 

* `foldertmp.sh` créé un répertoire pour l'utilisateur courant dans le 
répertoire '/tmp' et un lien symbolique dans le '/home' de l'utlisateur 
courant vers ce répertoire

## Applications
### raccourci Vim
* Mode normale
```
- CTRL-x + CTRL-v 	# split vertical avec saisie du fichier à ouvrir
- CTRL-x + CTRL-h 	# split horizontal avec saisie du fichier à ouvrir
- ;i  			# reformatage de l'indentation
```

### Bash
- Ajout du mode 'VI' à la saisie sur la ligne de commande

### Zsh
- Ajout du mode 'VI' à la saisie sur la ligne de commande
