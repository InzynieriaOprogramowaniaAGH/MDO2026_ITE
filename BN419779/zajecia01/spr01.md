# Sprawozdanie 1
Bartłomiej Nosek 
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
- nadanie uprawnień: `chmod +x commit-msg`
- skopowianie od odpooweidniego folderu: `cp commit-msg ../.git/hooks/commit-msg`

  ## Zrzuty ekranu:
<img width="630" height="118" alt="Screenshot 2026-03-06 145548" src="https://github.com/user-attachments/assets/6da85533-fcf8-40b1-9d5e-65c852af42c5" />

 <img width="621" height="384" alt="obraz" src="https://github.com/user-attachments/assets/782fb045-3879-478a-bdce-cc6303389bf1" />


