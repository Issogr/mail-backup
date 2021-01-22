#!/bin/sh

set -e

case $1 in
"-g")
  cp deploy/defaults/offlineimaprc ./
  read -p "email address:" EMAIL
  sed -i -e "s/user@example.org/$EMAIL/g" offlineimaprc
  read -sp "email password:" PASS
  echo -e "\n"
  sed -i -e "s/password/$PASS/g" offlineimaprc
  read -p "email IMAP:" IMAP
  sed -i -e "s/mail.example.org/$IMAP/g" offlineimaprc
  if [[ -f offlineimaprc-e ]]
  then
    rm offlineimaprc-e
  fi
  ;;
"-c")
  echo -e "Clean all generated resources"
  rm offlineimaprc*
  rm -rf vol/config/metadata vol/mail/*
  ;;

*)
  echo -e "Tools:"
  echo -e "\t[  ] Display help"
  echo -e "\t[-g] Generate offlineimaprc with passed parameters"
  echo -e "\t[-c] Clean all generated resources"
  ;;
esac