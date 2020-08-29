#! /bin/bash

export LC_ALL=C

creation_de_liens_symboliques()
{
	motif='File exists'
	msg=$(ln -s "$1" "$2"  2>&1) || if [[ $msg =~ $motif ]]
then
	# Le fichier est déja présent
	echo "Renommez ou supprimez l'ancien fichier de configuration" >&2
else
	echo $msg
	fi
}

# Installation des configs de VIM
creation_de_liens_symboliques ~/.dotfiles/.vimrc ~/.vimrc
creation_de_liens_symboliques ~/..dotfiles/.vimrc ~/.vimrc
