#!/bin/sh

#-------------------------------------------------------
# Script de vérification de présence du répertoire 'jcc'
# dans le répertoire temporaire '/tmp'
#-------------------------------------------------------

quisuisje=$(whoami)

# vérification si /tmp/jcc existe sinon création	
[ -d /tmp/jcc ] || mkdir /tmp/"$quisuisje"

# vérification si le raccourci est présent dans /home/<user>
[ -h ~/tmp ] || ln -s /tmp/"$quisuisje" ~/tmp

# ajout du cron
testcron=$(crontab -l | grep "foldertmp")
[ ! -z "$testcron" ] || \
	(crontab -l; \
	echo "10 * * * * cd ~/.dotfiles/scripts && sh foldertmp.sh") |\
	crontab -

exit 0
