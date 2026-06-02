#!/bin/bash
MSG_FILE=$1
COMMIT_MSG=$(head -n 1 "$MSG_FILE")
PREFIX="TM424276"

if [[ ! $COMMIT_MSG =~ ^$PREFIX ]]; then
    echo "--------------------------------------------------------"
    echo "BLAD: Wiadomosc commita musi zaczynac sie od $PREFIX"
    echo "--------------------------------------------------------"
    exit 1
fi
