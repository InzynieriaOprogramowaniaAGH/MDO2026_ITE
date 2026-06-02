#!/bin/bash

# Skrypt weryfikujący, czy deployment zakończył rollout w ciągu 60 sekund
# Użycie: ./check-deployment.sh <nazwa-deploymentu> [namespace]

DEPLOYMENT=$1
NAMESPACE=${2:-default}

if [ -z "$DEPLOYMENT" ]; then
  echo "Użycie: $0 <nazwa-deploymentu> [namespace]"
  exit 1
fi

echo "Sprawdzanie rolloutu deploymentu '$DEPLOYMENT' w namespace '$NAMESPACE' (limit czasu: 60s)..."

# Uruchom kubectl rollout status z timeoutem 10 sekund
if kubectl rollout status deployment/"$DEPLOYMENT" -n "$NAMESPACE" --timeout=60s; then
  echo "Deployment '$DEPLOYMENT' zakończył rollout pomyślnie w czasie < 60s."
  exit 0
else
  echo "Deployment '$DEPLOYMENT' NIE zakończył rolloutu w ciągu 60 sekund (lub wystąpił błąd)."
  exit 1
fi
