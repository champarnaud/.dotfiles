#!/bin/bash

#-------------------------------------------------------
# Script de vérification de présence du répertoire 'jcc'
# dans le répertoire temporaire '/tmp'
# Author : Jean-Christophe Champarnaud
# Last update : 2023-03-12
#-------------------------------------------------------

injection_cron(){
	crontab -l >> mycron
	crontab mycron
	rm mycron
	#mv mycron mycron.$(date +%Y%M%d_%H%I%S)
}

w_bash=$(which bash)

# ajout du cron pour le paramètre passé à l'appel du script 
testcron=$(crontab -l | grep "$1")
if [ -z "$testcron" ]
then
	echo "*/5 * * * * cd ~/.dotfiles/scripts && $w_bash $1.sh \
		> /tmp/stdout.log 2> /tmp/stderr.log" \
		>> mycron 
			injection_cron 
fi
