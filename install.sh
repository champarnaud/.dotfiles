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

	app=${tab[$1]} # nom de l'application
	ix_app=$1      # index de l'application

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
	echo "execusion de script : ${tab[$1]} " 
	sh "$repscripts/${tab[$1]}"

}

#--- main
boucle=0
while [ $boucle = 0 ]; do # menu
	echo "Liste des fichiers de configuration à installer :"
	for i in ${!tab[*]}; do
		echo "$i - ${tab[$i]}"
	done
	echo "* - Tous"
	echo "q - Sortie"
	read -p "Faites votre choix : " rep

  # traitment de la réponse
  if [ $rep == "q" ]; then # Sortie
	  echo "Au revoir"
	  exit 0
  elif [ $rep == "*" ]; then # Tous
	  clear
	  echo "Patientez ..."
	  for conf in ${!tab[*]}; do
		  creation_de_liens_symboliques $conf
	  done
	  echo "C'est fait ..."
	  echo "Au revoir"
	  exit 0
  elif [[ $rep =~ ^[0-9]?$ ]]; then # Picking
	  clear
	  [[ ${tab[$rep]} =~ \.sh$ ]] && execution_de_script $rep \
	  || creation_de_liens_symboliques $rep
	  echo "Fait !"
  else # Erreur
	  clear
	  echo "Pardon, je n'ai pas compris ..."
  fi
done

#--- FIN
exit 0
