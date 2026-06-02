#!/bin/bash
DEPLOYMENT=${1:-nginx-demo}
TIMEOUT=${2:-60}
INTERVAL=2
elapsed=0

while [ $elapsed -lt $TIMEOUT ]; do
  kubectl rollout status deployment/$DEPLOYMENT --timeout=2s && exit 0
  sleep $INTERVAL
  elapsed=$((elapsed + INTERVAL))
done

echo "Rollout did not complete within ${TIMEOUT}s"
exit 1
