#!/bin/bash
DEPLOYMENT="portfinder-deployment"
TIMEOUT=60

echo "Weryfikacja wdrozenia: $DEPLOYMENT (timeout: ${TIMEOUT}s)"
if minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "SUCCESS: Wdrozenie zakonczone pomyslnie w ciagu ${TIMEOUT} sekund!"
    exit 0
else
    echo "FAILED: Wdrozenie nie zakonczylo sie w ciagu ${TIMEOUT} sekund!"
    minikube kubectl -- get pods -l app=portfinder-app
    minikube kubectl -- describe deployment $DEPLOYMENT | tail -20
    exit 1
fi
