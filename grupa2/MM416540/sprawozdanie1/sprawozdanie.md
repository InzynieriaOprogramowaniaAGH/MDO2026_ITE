# Sprawozdanie Zajęcia 01

Mateusz Malaga Gr.2

MM416540

## Git
Zainstalowano Git i sklonowano repozytorium.

![alt text](image-4.png)

## Konfiguracja VS code i Remote SSH (wtyczka)

Zainstalowałem wtyczkę i skonfigurowałem połączenie.

![alt text](image-2.png)

Z niedokońca zrozumiałego powodu nie było możliwości podłączenia się do ssh podczas gdy byłem podłączony po kablu, problem rozwiązało przejscie na wi-fi

## Konfiguracja połączenia SFTP w File Zilla

![alt text](image-1.png)

## SSH
Utworzono klucze:
- ed25519

![alt text](<Zrzut ekranu 2026-03-12 161552-1.png>)
![alt text](image-3.png)
- ecdsa

![alt text](image-5.png)

## Utworzenie Git Hook'a do werfikacji 

Treść:
```bash

#!/bin/sh

PREFIX="MM416540"

MESSAGE=$(cat "$1")

case "$MESSAGE" in
$PREFIX*)
    exit 0
    ;;
*)
    echo "Commit message musi zaczynać się od $PREFIX"
    exit 1
    ;;
esac
```

## Pull Request
![alt text](image-7.png)

## Podsumowanie
Podczas zajęć:

przygotowano środowisko pracy z Git i SSH,
wygenerowano dwa klucze SSH (ed25519 oraz ecdsa),
dodano klucze do ssh-agent oraz do konta GitHub,
przetestowano połączenie SSH z GitHub,
sklonowano repozytorium przy użyciu protokołu SSH,
utworzono gałąź MM416540,
przygotowano git hook sprawdzający poprawność komunikatu commita.