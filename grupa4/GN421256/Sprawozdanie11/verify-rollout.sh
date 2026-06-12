#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT="${1:-gn-nginx}"
TIMEOUT="${2:-60}"
# KUBECTL jako tablica, zeby "minikube kubectl --" rozbilo sie na osobne slowa
read -r -a KUBECTL <<< "${KUBECTL:-minikube kubectl --}"

echo "Sprawdzam rollout deployment/$DEPLOYMENT (timeout: ${TIMEOUT}s)..."
if "${KUBECTL[@]}" rollout status "deployment/$DEPLOYMENT" --timeout="${TIMEOUT}s"; then
  echo "OK: wdrozenie zakonczone w czasie <= ${TIMEOUT}s"
  "${KUBECTL[@]}" get deployment "$DEPLOYMENT"
  exit 0
else
  echo "BLAD: wdrozenie NIE zakonczylo sie w ${TIMEOUT}s"
  "${KUBECTL[@]}" describe deployment "$DEPLOYMENT" | tail -n 30
  exit 1
fi
