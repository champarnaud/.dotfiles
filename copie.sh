#!/bin/bash

echo $1

read -p "Quel est le répertoire d'origine ? (défaut .) : " orig

if [ -z $orig ]; then
	orig='.'
fi

read -p "Quel est le répertoire de destination ? : " dest
while [ -z $dest ]; do
	read -p "Quel est le répertoire de destination ? : " dest
done

echo $orig $dest

#cp -uvr $org $dest`
