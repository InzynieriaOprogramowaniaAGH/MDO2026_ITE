#!/bin/bash

echo "Start weryfikacji wdrożenia aplikacji"
echo "Sprawdzam status deploymentu (Limit czasu: 60 sekund)"

# zastosowanie minikube kubectl, aby skrypt działał niezależnie od konfiguracji aliasów
minikube kubectl -- rollout status deployment/app-lab10-deployment --timeout=60s

# sprawdzenie kodu wyjścia poprzedniego polecenia
if [ $? -eq 0 ]; then
    echo "SUKCES: Wdrożenie zakończyło się pomyślnie w ciągu 60 sekund"
    exit 0
else
    echo "BŁĄD: Wdrożenie przekroczyło limit 60 sekund lub zakończyło się awarią podów"
    exit 1
fi