#!/bin/bash

REQUIRED_PREFIX="DW419755"
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(head -n1 "$COMMIT_MSG_FILE")

if [[ "$COMMIT_MSG" != "$REQUIRED_PREFIX"* ]]; then
  echo "Błąd: commit message musi zaczynać się od: '$REQUIRED_PREFIX'"
  exit 1
fi

exit 0