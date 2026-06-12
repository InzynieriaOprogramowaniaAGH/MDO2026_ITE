#!/bin/bash

DEPLOYMENT_NAME="nextjs-app"
TIMEOUT="60s"

kubectl() {
  minikube kubectl -- "$@"
}

echo "Oczekiwanie na wdrożenie $DEPLOYMENT_NAME (limit $TIMEOUT)..."

if kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=$TIMEOUT; then
    echo "SUKCES: Wdrożenie zakończone pomyślnie w ciągu 60 sekund."
    exit 0
else
    echo "BŁĄD: Wdrożenie nie powiodło się lub przekroczyło czas 60 sekund."
    
    echo "Ostatnie zdarzenia:"
    kubectl get events --sort-by='.lastTimestamp' | tail -n 3
    exit 1
fi