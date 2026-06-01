#!/usr/bin/env bash
set -euo pipefail

DEPLOY="${1:-mdo-redis}"
NS="${2:-default}"
TIMEOUT="${3:-60s}"

echo "Sprawdzam rollout deployment/${DEPLOY} w ns/${NS} (timeout=${TIMEOUT})..."

kubectl rollout status "deployment/${DEPLOY}" \
  -n "${NS}" \
  --timeout="${TIMEOUT}"

echo "OK: wdrożenie zakończone w czasie ${TIMEOUT}."