#!/bin/bash
echo "Sprawdzanie statusu wdrożenia (limit 60s)..."
if minikube kubectl -- rollout status deployment/spring-deploy --timeout=60s; then
    echo "SUKCES: Wdrożenie zakończone pomyślnie!"
else
    echo "BŁĄD: Wdrożenie nie powiodło się w wyznaczonym czasie."
    exit 1
fi