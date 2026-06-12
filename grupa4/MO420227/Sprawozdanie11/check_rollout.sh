#!/bin/bash
DEPLOYMENT_NAME="my-app-deploy"
TIMEOUT_SECONDS=60

echo "Oczekiwanie max $TIMEOUT_SECONDS sekund na wdrożenie: $DEPLOYMENT_NAME"

if timeout $TIMEOUT_SECONDS kubectl rollout status deployment/$DEPLOYMENT_NAME; then
    echo "Wdrożenie zakończone sukcesem przed upływem limitu czasu."
    exit 0
else
    echo "BŁĄD: Wdrożenie nie powiodło się w ciągu $TIMEOUT_SECONDS sekund!"
    exit 1
fi