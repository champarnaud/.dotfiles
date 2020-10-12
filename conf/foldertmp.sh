#!/bin/sh

# Script de vérification de présence du répertoire 'jcc'
# dans le répertoire temporaire '/tmp'

# vérification si /tmp existe sinon création

# vérification si /tmp/jcc existe sinon création	
[ -d /tmp/jcc ] || mkdir /tmp/jcc

