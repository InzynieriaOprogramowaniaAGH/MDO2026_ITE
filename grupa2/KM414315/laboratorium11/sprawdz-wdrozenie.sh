#!/bin/bash
if kubectl rollout status deployment/apka-deployment --timeout=60s; then
  echo "SUKCES: Wdrozenie stabilne i gotowe!"
else
  echo "BLAD: Wdrozenie nie powiodlo sie w wyznaczonym czasie (60s)."
  exit 1
fi
