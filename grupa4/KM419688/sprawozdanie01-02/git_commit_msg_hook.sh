#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(head -n 1 "$COMMIT_MSG_FILE")
MY_ID="KM419688"

if [[ ! $COMMIT_MSG =~ ^$MY_ID ]]; then
    echo "========================================================"
    echo "BŁĄD: Commit zablokowany przez Git Hooka!"
    echo "Wiadomość musi zaczynać się od: $MY_ID"
    echo "========================================================"
    exit 1
fi

exit 0