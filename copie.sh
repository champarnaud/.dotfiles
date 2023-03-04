#!/bin/bash

echo $# $0 $1 $2 $3

if [ $# = 0 ]
then
	read -p "Quel est le répertoire d'origine ? (défaut .) : " orig
	if [ -z $orig ]; then
		orig='.'
	fi

	read -p "Quel est le répertoire de destination ? (defaut ~) : " dest
	if [ -z $dest ]; then
		dest='~'
	fi
fi

echo $orig $dest

#cp -uvr $org $dest`
