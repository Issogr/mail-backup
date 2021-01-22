#!/bin/sh

set -e

generate_offlineimap () {
  cp deploy/defaults/offlineimaprc ./
  read -p "email address: " EMAIL
  sed -i -e "s/user@example.org/$EMAIL/g" offlineimaprc
  read -sp "email password: " PASS
  echo -e "\n"
  sed -i -e "s/mail-password/$PASS/g" offlineimaprc
  read -p "email IMAP: " IMAP
  sed -i -e "s/mail.example.org/$IMAP/g" offlineimaprc
  if [[ -f offlineimaprc-e ]]
  then
    rm offlineimaprc-e
  fi
}

case $1 in
"-d")
  generate_offlineimap
  mkdir -p vol/config vol/mail
  mv offlineimaprc vol/config/
  ;;
"-g")
  generate_offlineimap
  ;;
"-c")
  read -p "Clean all docker generated resources (Y/n)? " VALUE
  if [[ $VALUE != "n" ]]
  then
    rm -rf vol/config/metadata vol/mail/*
  fi
  ;;

*)
  echo -e "Tools:"
  echo -e "\t[  ] Display help"
  echo -e "\t[-d] Generate offlineimap local dir scructure and file"
  echo -e "\t[-g] Generate offlineimaprc with passed parameters"
  echo -e "\t[-c] Clean all docker generated resources"
  ;;
esac