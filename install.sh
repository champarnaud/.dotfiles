#! /bin/bash

export LC_ALL=C

#--- ENVIRONNEMENT
repconf="conf"
repscripts="scripts"
[ ! -s "$repconf/machine" ] || echo "" > "$repconf/machine"

#--- LISTE DES FICHIERS ET REPERTOIRES DE CONFIGURATION
tab=($(ls conf/ && ls scripts/))

#--- FONCTIONS
function creation_de_liens_symboliques() {

	app=$1 # nom de l'application

	# création du lien symbolique vers le fichier dans le rep 'conf/'
	msg=$(ln -s ~/.dotfiles/$repconf/"$app" ~/."$app" 2>&1)

	# Si l'ancien fichier ou lien symbolique existe on le supprime
	# pour le remplacer
	if [ ! -z "$msg" ]; then
		read -p "Voulez-vous supprimer le lien '$app' précédent ? [O/n] " suppr
		if [[ $suppr =~ [oOyY] ]]; then
			echo "Essai de suppression de : ."$app
			msg=$(rm ~/."$app" 2>&1)
			if [ -z $msg ]; then
				echo "Suppression de ===> ."$app
				creation_de_liens_symboliques $1
			else
				echo "Impossible de supprimer : ."$app
				echo "Vérifiez que vous avez les droits"
			fi
		else
			echo "Vous devez supprimer le fichier ."$app
		fi
	else
		echo "Installation de ===> ."$app
		# si installation de la machine
		if [[ ! -s "$repconf/machine" || "$app" == "machine" ]]; then
			read -p "Donnez un nom à votre machine : " machine
			echo "$machine" > "$repconf/machine"
		fi
	fi
}

function execution_de_script(){
	echo "execusion de script : $1 " 
	sh "$repscripts/$1}"
}

#--- main
PS3="Faites votre choix : "
echo="data ?"
select resp in ${tab[*]} tout quit
do
	case $resp in
		"quit")
			echo "Merci et au revoir"
			exit 0
			;;
		"tout")
			echo "Patientez ..." # Tous
			for conf in ${!tab[*]}; do
				creation_de_liens_symboliques $conf
			done
			echo "C'est fait. Autre chose ?"
			;;
		*)
			if [ $REPLY -le $((${#tab[@]} - 2)) ]
			then
				[[ $resp =~ \.sh$ ]] && execution_de_script $resp || creation_de_liens_symboliques $resp
				echo "C'est fait. Autre chose ?"
			else
				echo "Demande incorrecte."
			fi
			;;
	esac
done
exit 0

