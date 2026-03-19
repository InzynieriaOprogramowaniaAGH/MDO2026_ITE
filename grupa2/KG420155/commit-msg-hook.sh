#!/bin/bash
PREFIX="KG420155"
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

if [[ ! "$COMMIT_MSG" == "$PREFIX"* ]]; then
  echo "Błąd: Wiadomość commita musi zaczynać się od '$PREFIX'."
  exit 1
fi
