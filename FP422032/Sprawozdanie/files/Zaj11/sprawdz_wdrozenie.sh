#!/bin/bash

DEPLOYMENT="kalkulator-deployment"
TIMEOUT="60s"

echo "Rozpoczynam weryfikację wdrożenia $DEPLOYMENT..."

if minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=$TIMEOUT; then
    echo "SUKCES: Wdrożenie zakończone pomyślnie!"
    exit 0
else
    echo "BŁĄD: Wdrożenie nie powiodło się w ciągu $TIMEOUT (lub utknęło)."
    exit 1
fi