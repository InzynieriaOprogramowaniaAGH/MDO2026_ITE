#!/bin/bash
kubectl rollout status deployment/web-deployment --timeout=60s
if [ $? -eq 0 ]; then
  echo "Wdrozenie zakonczone sukcesem."
  exit 0
else
  echo "Blad: Wdrozenie nie powiodlo sie w ciagu 60 sekund."
  exit 1
fi
