#!/usr/bin/env bash

#------------------------------------------------------
# installation script for console conf files
# Author Jean-Christophe Champarnaud
# mail jc@champarnaud.fr
# Update 2023-03-12
#------------------------------------------------------

#--- ENVIRONNEMENT
# répertoires
repconf="conf"
repscripts="scripts"

# Nom de la machine
[ -e "$repconf/machine" ] || echo "" > "$repconf/machine"

#--- FONCTIONS
check_tool() {
	local tool=""
	case $1 in
		tmux.conf) tool="tmux" ;;
		vimrc) tool="vim" ;;
		muttrc) tool="mutt" ;;
		*) return 0 ;;  # pas de vérification nécessaire
	esac
	
	if ! command -v "$tool" &> /dev/null; then
		echo "$tool n'est pas installé."
		read -p "Voulez-vous l'installer automatiquement ? (o/n) " response
		if [[ $response =~ ^[oO]$ ]]; then
			if ./install_tools.sh; then
				echo "$tool installé avec succès."
			else
				echo "Échec de l'installation de $tool. Installation du dotfile annulée."
				return 1
			fi
		else
			echo "Installation annulée pour $1"
			return 1
		fi
	fi
	return 0
}

creation_de_liens_symboliques() {
	# Vérification de l'outil requis
	if ! check_tool "$1"; then
		return 1
	fi

	# Créer le répertoire logs s'il n'existe pas
	mkdir -p logs

	# test if file exist then save
	if [ -f ~/.$1 ] && [ ! -L ~/.$1 ]
	then
		mv ~/.$1 ~/.$1.bak 1>>logs/install.log 2>>logs/error.log
		echo "Le précédent fichier a été sauvegarde : $1.bak"
	fi

	# test if symlink to remove
	if [ -L ~/.$1 ]
	then
		rm ~/.$1
		echo "Le précédent lien symbolique vers $1 a été supprimé."
	fi

	# création du lien symbolique vers le fichier dans le rep 'conf/'
	ln -s ~/.dotfiles/$repconf/$1 ~/.$1 1>>logs/install.log 2>>logs/error.log

	echo -e "Le lien symbolique vers $1 a été créé.\n"
}

nommer_la_machine(){
	read -p "Donnez un nom à votre machine : " machine
	echo "$machine" > "$repconf/machine"
}

execution_de_script(){
	echo "execusion de script : $1 " 
	bash "$repscripts/$1"
}

#--- MAIN
# liste les fichiers et repertoires de configuration pour le menu
installable=($(ls conf/ && ls scripts/))
tab=("${installable[@]}")
tab+=("Tout")
tab+=("Installer-les-outils")
tab+=("Installer-les-dépendances-Zsh")
tab+=("Quitter")
options=${tab[*]}
nb_options=${#tab[@]}

PS3="Faites votre choix : "
select option in $options
do
	if [[ " ${options[@]} " =~ " ${option} " ]]
	then
		echo "Vous avez choisi l'option : $option"

		case $option in
			"Quitter")
				echo "Merci et au revoir"
				exit 99
				;;
			"Tout")
				echo -e "Patientez ...\n" # Tous
				for conf in "${installable[@]}"; do
					creation_de_liens_symboliques $conf
				done
				echo "C'est fait. Autre chose ?"
				;;
			"Installer-les-outils")
				echo "Installation des outils tmux, vim et mutt..."
				if ./scripts/install_tools.sh; then
					echo "Outils installés avec succès."
				else
					echo "Échec de l'installation des outils."
				fi
				echo "Autre chose ?"
				;;
			"Installer-les-dépendances-Zsh")
				echo "Installation des dépendances Zsh (Oh My Zsh, plugins, thème Powerlevel10k)..."
				if ./scripts/install_zsh_deps.sh; then
					echo "Dépendances Zsh installées avec succès."
				else
					echo "Échec de l'installation des dépendances Zsh."
				fi
				echo "Autre chose ?"
				;;
			"machine")
				nommer_la_machine && creation_de_liens_symboliques machine
				nommer_la_machine
				;;
			*)
				[[ $option =~ \.sh$ ]] && execution_de_script $option \
					|| creation_de_liens_symboliques $option
				echo "C'est fait. Autre chose ?"
				;;
		esac
	else
		echo "Option invalide. Veuillez choisir une option valide."
	fi
done
exit 0

