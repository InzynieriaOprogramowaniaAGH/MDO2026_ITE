#!/bin/bash
DEPLOYMENT_NAME="moja-aplikacja-deployment"
TIMEOUT="60s"

echo "Weryfikacja wdrożenia $DEPLOYMENT_NAME..."
if minikube kubectl -- rollout status deployment/$DEPLOYMENT_NAME --timeout=$TIMEOUT; then
    echo "Sukces: Wdrożenie zakończone poprawnie w wymaganym czasie."
    exit 0
else
    echo "Błąd: Wdrożenie nie powiodło się w ciągu 60 sekund!"
    exit 1
fi