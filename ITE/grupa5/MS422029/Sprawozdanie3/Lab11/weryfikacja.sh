#!/bin/bash
echo "Sprawdzam status wdrozenia (limit: 60 sekund)..."

if kubectl rollout status deployment/lab11-deploy --timeout=60s; then
    echo "SUKCES: Wdrozenie zdazylo sie uruchomic!"
    exit 0
else
    echo "BLAD: Wdrozenie nie powiodlo sie w zadanym czasie."
    exit 1
fi
