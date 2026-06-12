#!/bin/bash

echo "Sprawdzam status wdrozenia..."
if kubectl rollout status deployment/lab11-deployment --timeout=60s; then
    echo "Sukces: Wdrozenie zakonczone pomyslnie przed uplywem 60 sekund."
    exit 0
else
    echo "Blad: Wdrozenie nie zdazylo sie wykonac (timeout) lub napotkalo problem."
    exit 1
fi
