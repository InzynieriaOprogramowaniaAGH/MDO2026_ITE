#!/bin/bash

set -euo pipefail

# Konfiguracja parametrów
DEPLOYMENT_NAME="nginx-deployment"
TIMEOUT_LIMIT="60s"

echo "=== Rozpoczęcie weryfikacji wdrożenia: ${DEPLOYMENT_NAME} ==="
echo "Oczekiwanie na zakończenie rolloutu (Max: ${TIMEOUT_LIMIT})..."

if ./minikube kubectl -- rollout status deployment/${DEPLOYMENT_NAME} --timeout=${TIMEOUT_LIMIT}; then
    echo " [SUKCES] Wdrożenie zakończyło się powodzeniem w wyznaczonym czasie!"
    exit 0
else
    echo " [AWARIA] Przekroczono limit 60 sekund lub wdrożenie zakończyło się błędem."
    echo " Aktualny stan podów:"
    ./minikube kubectl -- get pods
    exit 1
fi