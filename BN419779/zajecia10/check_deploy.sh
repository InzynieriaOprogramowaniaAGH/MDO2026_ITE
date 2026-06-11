#!/bin/bash
if kubectl rollout status deployment/web-deploy --timeout=60s; then
    echo "Wdrożenie zakończone sukcesem!"
else
    echo "BŁĄD: Wdrożenie nie powiodło się w ciągu 60 sekund. Cofaam zmiany!"
    kubectl rollout undo deployment/web-deploy
    exit 1
fi
