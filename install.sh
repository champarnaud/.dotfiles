#! /bin/bash

# TODO
# Se servir de $? pour savoir si une acrion a réussi ou non 0=OK
# Se servir de la sortie standart 1 pour envoyer vers un fichier de log 
# Se sercir de la sortie error standart 2 pour envoyer vers un error-file


export LC_ALL=C

#--- ENVIRONNEMENT
# répertoires
repconf="conf"
repscripts="scripts"

# Nom de la machine
[ -e "$repconf/machine" ] || echo "" > "$repconf/machine"

#--- LISTE DES FICHIERS ET REPERTOIRES DE CONFIGURATION
tab=($(ls conf/ && ls scripts/))

#--- FONCTIONS
function creation_de_liens_symboliques() {

	# création du lien symbolique vers le fichier dans le rep 'conf/'
	msg=$(ln -s ~/.dotfiles/$repconf/"$1" ~/."$1" 2>&1)

	# Si l'ancien fichier ou lien symbolique existe on le supprime
	# pour le remplacer
	if [ ! -z "$msg" ]; then
		read -p "Voulez-vous supprimer le lien '$1' précédent ? [O/n] " suppr
		if [[ $suppr =~ [oOyY] ]]; then
			echo "Essai de suppression de : ."$1
			msg=$(rm ~/."$1" 2>&1)
			if [ -z $msg ]; then
				echo "Suppression de ====> ."$1
				creation_de_liens_symboliques $1
			else
				echo "Impossible de supprimer : ."$1
				echo "Vérifiez que vous avez les droits"
			fi
		else
			echo "Vous devez supprimer le fichier ."$1
		fi
	else
		echo "Installation de ===> ."$1
		# si installation de la machine
		if [[ ! -s "$repconf/machine" || "$1" == "machine" ]]; then
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
# echo="data ?"
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
				[[ $resp =~ \.sh$ ]] && execution_de_script $resp \
					|| creation_de_liens_symboliques $resp
				echo "C'est fait. Autre chose ?"
			else
				echo "Demande incorrecte."
			fi
			;;
	esac
done
exit 0

