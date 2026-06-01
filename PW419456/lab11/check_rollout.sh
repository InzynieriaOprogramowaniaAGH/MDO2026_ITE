#!/usr/bin/env bash

DEPLOYMENT_NAME=$1
TIMEOUT="60s"

if [ -z "$DEPLOYMENT_NAME" ]; then
  echo "Uzycie: ./check_rollout.sh <nazwa_deploymentu>"
  exit 1
fi

echo "Sprawdzanie statusu wdrozenia: $DEPLOYMENT_NAME (Timeout: $TIMEOUT)..."

if kubectl rollout status deployment/"$DEPLOYMENT_NAME" --timeout=$TIMEOUT; then
  echo ">>> SUKCES: Wdrozenie zakonczylo sie pomyslnie przed uplywem czasu."
  exit 0
else
  echo ">>> BLAD: Wdrozenie nie powiodlo sie w ciagu $TIMEOUT (lub pody sa uszkodzone)."
  exit 1
fi