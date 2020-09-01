#! /bin/bash

export LC_ALL=C

#--- FONCTIONS
creation_de_liens_symboliques() {
  motif='File exists'
  msg=$(ln -s ~/.dotfiles/."$1" ~/."$1" 2>&1) || if [[ $msg =~ $motif ]]; then
    # Le fichier est déja présent
    echo "Renommez ou supprimez l'ancien fichier : $1" >&2
  else
    echo "Essai de création de $1, mais : " $msg
  fi
}

#--- LISTE DES FICHIERS ET REPERTOIRES DE CONFIGURATION
tab=("vim" "vimrc" "tmux.conf" "bashrc" "machine")

#--- main
boucle=0
while [ $boucle=0 ]; do # menu
  echo "Liste des fichiers de configuration à installer :"
  for i in ${!tab[*]}; do
    echo "$i - ${tab[$i]}"
  done
  echo "* - Tous"
  echo "q - Sortie"
  read -p "Faites votre choix : " rep

  # traitment de la réponse
  if [[ $rep == "q" ]]; then # Sortie
    echo "Au revoir"
    exit 0
  elif [[ $rep == "*" ]]; then # Tous
    clear
    echo "Patientez ..."
    for conf in ${tab[@]}; do
      echo "Installation de ===> "$conf
      creation_de_liens_symboliques $conf
    done
    echo "C'est fait ..."
    echo "Au revoir"
    exit 0
  elif [[ $rep =~ ^[0-9]?$ ]]; then # Picking
    clear
    prog=${tab[$rep]}
    echo "Installation de ===> "$prog
    creation_de_liens_symboliques $conf
    echo "Fait !"
  else # Erreur
    clear
    echo "Pardon je n'ai pas compris ..."
  fi

done

#--- FIN
exit 0
