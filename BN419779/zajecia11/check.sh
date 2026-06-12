#!/bin/bash
if kubectl rollout status deployment/web-deploy --timeout=60s; then
    echo "Wdrożenie zakończone sukcesem!"
else
    echo "BŁĄD: Wdrożenie zablokowane (Timeout)."
    kubectl rollout undo deployment/web-deploy
    exit 1
fi
