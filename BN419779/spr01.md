# Sprawozdanie 1
---
### Cel ćwiczenia
Ustawianie środowiska, stworzenie brancha i stworzenie skryptu hooka  

### Przebieg laboratoriów
- klonowanie repozytorium (mozna bez klucza ponieważ jest publiczne) `git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- stworzenie katalogu `mkdir BN419779`
- wejscie do katalogu `cd BN419779`
- stworzenie spr `touch spr01.md`
- utworzenie skrytpu bashowego  
```console
#!/bin/bash

ID="BN419779"
MSG_FILE="$1"

MESSAGE=$(cat "$MSG_FILE")

if [[ ! "$MESSAGE" =~ ^$ID ]]; then
    echo "Zle, comitta start to:  $ID"
    exit 1
fi
```
-- nadanie uprawnień: `chmod +x commit-msg`
-- skopowianie od odpooweidniego folderu: `cp commit-msg ../.git/hooks/commit-msg`

