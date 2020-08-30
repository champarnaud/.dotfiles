#! /bin/bash

export LC_ALL=C

creation_de_liens_symboliques()
{
	motif='File exists'
	msg=$(ln -s ~/.dotfiles/"$1" ~/"$1"  2>&1) || if [[ $msg =~ $motif ]]
then
	# Le fichier est déja présent
	echo "Renommez ou supprimez l'ancien fichier : $1" >&2
else
	echo "Essai de création de $1, mais : " $msg 
	fi
}

# Installation des configs de VIM
creation_de_liens_symboliques .vimrc
creation_de_liens_symboliques .vim
# Installation de vim
creation_de_liens_symboliques .tmux.conf

