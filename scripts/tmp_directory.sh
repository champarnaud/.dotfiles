#!/bin/bash

#----------------------------------------------------------
# Script de vérification de présence du répertoire <user>
# dans le répertoire temporaire '/tmp'
# Author : Jean-Christophe Champarnaud
# Last update : 2023-03-12
#----------------------------------------------------------

quisuisje=$(whoami)

# vérification si /tmp/jcc existe sinon création	
[ -d /tmp/jcc ] || mkdir /tmp/"$quisuisje"

# vérification si le raccourci est présent dans /home/<user>
[ -h ~/tmp ] || ln -s /tmp/"$quisuisje" ~/tmp

# installation du cron
source cron_manage.sh tmp_directory
