#! /bin/bash

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
creation_de_liens_symboliques() {

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
tab=($(ls conf/ && ls scripts/))
tab+=("Tout")
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
				for conf in $options; do
					creation_de_liens_symboliques $conf
				done
				echo "C'est fait. Autre chose ?"
				;;
			"machine")
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

