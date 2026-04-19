# Sprawozdanie z Zajęć 1 - Franciszek Tokarek (422048)

## 1. Cel zajęć
Przygotowanie stanowiska pracy, konfiguracja bezpiecznego dostępu przez SSH, automatyzacja weryfikacji commitów oraz obsługa przepływu pracy w systemie Git.

## 2. Konfiguracja SSH i GitHub
Wygenerowano dwa klucze typu ED25519 na systemie macOS (jeden zabezpieczony hasłem do GitHub, drugi do maszyny wirtualnej).

Skonfigurowano dostęp kluczem SSH do profilu GitHub, co umożliwiło bezpieczne klonowanie repozytorium.

Uwierzytelnianie dwuskładnikowe (2FA) na koncie GitHub było włączone już wcześniej.

## 3. Narzędzia i wymiana plików
Skonfigurowano zdalny dostęp do maszyny wirtualnej 10.211.55.4 za pomocą edytora z rozszerzeniem Remote - SSH.

Zapewniono natychmiastową wymianę plików (zrzuty ekranu) za pomocą protokołu SFTP w programie FileZilla.

4. Zarządzanie repozytorium i gałęziami
Repozytorium zostało sklonowane dwoma metodami: przez protokół SSH oraz testowo przez HTTPS do folderu test_https.

Przełączono się na gałąź główną, a potem na gałąź grupową grupa6, od której utworzono osobistą gałąź roboczą FT422048.

5. Automatyzacja: Git Hook
Napisany został skrypt commit-msg weryfikujący, czy każda wiadomość zatwierdzenia zaczyna się od FT422048.

Skrypt został aktywowany poprzez skopiowanie do katalogu .git/hooks/ i nadanie uprawnień wykonywania (chmod +x).

Treść githooka:

Bash

#!/bin/bash
commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")
pattern="^FT422048.*"

if [[ ! $commit_msg =~ $pattern ]]; then
  echo "ERROR: Commit message must start with 'FT422048'"
  exit 1
fi
Weryfikacja działania:

Próba commita z błędną wiadomością została zablokowana przez system.

Commit z poprawnym prefiksem został zaakceptowany.

6. Dokumentacja i historia pracy
Na zrzutach ekranu znajduje się potwierdzenie poprawnego wykonania zadania.

7. Pull Request
Ostatnim etapem było wysłanie zmian na serwer zdalny (git push) oraz otwarcie Pull Requesta z gałęzi FT422048 do gałęzi grupa6.
