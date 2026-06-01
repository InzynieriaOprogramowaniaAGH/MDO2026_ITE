#!/bin/bash

echo "=== Rozpoczynam weryfikację wdrożenia (Max 60 sekund) ==="

minikube kubectl -- rollout status deployment/moja-aplikacja-deployment --timeout=60s

if [ $? -eq 0 ]; then
    echo "✅ Poprawne wdrożenie"
    exit 0
else
    echo "❌ Przekroczenie limitu 60 sekund lub awaria!"
    exit 1
fi
