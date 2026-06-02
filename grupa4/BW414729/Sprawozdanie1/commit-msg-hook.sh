#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(head -n 1 "$COMMIT_MSG_FILE")

PREFIX="BW414729"

if [[ ! "$COMMIT_MSG" =~ ^"$PREFIX" ]]; then
  echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  echo "BŁĄD: Wiadomość commita musi zaczynać się od: $PREFIX"
  echo "Twoja wiadomość to: $COMMIT_MSG"
  echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  exit 1
fi