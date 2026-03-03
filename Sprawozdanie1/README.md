# Sprawozdanie 1

### Treść hooka

"#!/bin/sh
REQ="SS419695"
MSGFILE="$1"
FIRSTLINE="$(head -n 1 "$MSGFILE")"

case "$FIRSTLINE" in
  "$REQ"*)
    exit 0
    ;;
  *)
    echo "ERROR: Commit message must start with '$REQ'." >&2
    exit 1
    ;;
esac"

### Test działania hooka 

![Test](image.png)