#! /bin/bash

export LC_ALL=C

#--- FONCTIONS 
creation_de_liens_symboliques()
{
	motif='File exists'
	msg=$(ln -s ~/.dotfiles/."$1" ~/."$1"  2>&1) || if [[ $msg =~ $motif ]]
then
	# Le fichier est déja présent
	echo "Renommez ou supprimez l'ancien fichier : $1" >&2
else
	echo "Essai de création de $1, mais : " $msg 
	fi
}

#--- LISTE DES FICHIERS ET REPERTOIRES DE CONFIGURATION
liste_des_config=("vim" "vimrc" "tux.conf")

#--- EXECUTION DE LA CREATION DES LIENS SYMBOLIQUES
for prog in ${liste_des_config[@]}
do
	echo "Création de : ."$prog
	creation_de_liens_symboliques $prog
done


