#!/bin/bash
echo "Oczekiwanie na wdrożenie"
kubectl rollout status deployment/nestjs-app-deployment --timeout=60s
if [ $? -eq 0 ]; then
  echo "Wdrożenie zakończone pomyślnie."
  exit 0
else
  echo "Wdrożenie przekroczyło limit czasu albo zawiodło."
  exit 1
fi
