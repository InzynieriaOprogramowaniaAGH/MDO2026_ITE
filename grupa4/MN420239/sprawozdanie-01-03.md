# Sprawozdanie zbiorcze - zajęcia 01-03

**Autor:** MN420239 · **Grupa:** 4

---

## Zajęcia 01 - Git, SSH, gałęzie

Przygotowano środowisko pracy na maszynie wirtualnej z **Linux Ubuntu**: zainstalowano **Git** oraz narzędzia do **SSH**. Do edycji kodu użyto **Cursor** (fork VS Code), a do sesji SSH na VM - **Termius**.

Sklonowano repozytorium przedmiotowe z GitHub, następnie wygenerowano **dwa klucze SSH inne niż RSA**:

- `ssh-keygen -t ed25519 -C "github-key1"` - pierwszy klucz z hasłem,
- `ssh-keygen -t ecdsa -b 521 -C "github-key2"`.

Klucze dodano do **ssh-agent** (`ssh-add`, weryfikacja `ssh-add -l`), publiczne klucze wpisano w ustawieniach GitHub (**SSH keys**). Połączenie zweryfikowano poleceniem `ssh -T git@github.com`. Repozytorium sklonowano przez SSH, np. `git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026s_ITE`.

Utworzono gałąź roboczą poleceniem `git checkout -b MN420239`. W pliku **`.git/hooks/commit-msg`** umieszczono skrypt powłoki sprawdzający, czy pierwsza linia komunikatu commita zaczyna się od **`MN420239`** (w przeciwnym razie `exit 1` i komunikat błędu). Dzięki temu wymuszona jest spójna konwencja commitów w ramach identyfikatora studenta.

---

## Zajęcia 02 - Docker - podstawy

**Docker** zainstalowano z oficjalnego repozytorium dystrybucji (Ubuntu). Uruchomiono przykładowe obrazy: **hello-world**, **busybox** oraz **ubuntu** - obserwowano m.in. rozmiary obrazów w lokalnym magazynie, kody wyjścia oraz zachowanie kontenerów.

Dla **busybox** pokazano tryb interaktywny i sprawdzenie wersji. Dla **ubuntu** zweryfikowano proces **PID 1** wewnątrz kontenera oraz procesy Dockera na hoście; w kontenerze wykonano aktualizację pakietów, po czym zakończono sesję.

Przygotowano własny plik **`docker-test/Dockerfile`** (baza **`ubuntu:22.04`**): instalacja **git** oraz klonowanie repozytorium **MDO2026_ITE**. Obraz zbudowano, kontener uruchomiono interaktywnie i potwierdzono obecność sklonowanego kodu. Plik Dockerfile umieszczono w katalogu sprawozdania zgodnie z wymaganiami zajęć.

Na zakończenie wyświetlono listę uruchomionych i zakończonych kontenerów, usunięto zakończone kontenery oraz posprzątano nieużywane obrazy z lokalnego magazynu Dockera.

---

## Zajęcia 03 - Node.js w Dockerze, wieloetapowy build, Compose

Jako projekt testowy wybrano publiczne repozytorium **vscode-setup** (GitHub): aplikacja CLI w **Node.js** do interaktywnego doboru rozszerzeń VS Code, licencja **MIT**, testy jednostkowe przez **`npm test`**.

**Lokalnie:** `git clone https://github.com/chahe-dridi/vscode-setup.git`, następnie `npm install` i `npm test`.

**W kontenerze:** uruchomiono bazowy obraz Node.js, wewnątrz sklonowano repo i ponownie uruchomiono testy - wszystkie zakończyły się powodzeniem; wykonano także build w środowisku kontenerowym.

Przygotowano osobne pliki: **`Dockerfile.build`** (instalacja zależności, przygotowanie środowiska) oraz **`Dockerfile.test`** (bazuje na obrazie z etapu build). Kolejność pracy: budowa obrazu build (`docker build -t vscode-build -f Dockerfile.build .`), budowa obrazu testowego (`docker build -t vscode-test -f Dockerfile.test .`), uruchomienie `docker run vscode-test` - testy uruchamiane automatycznie przy starcie kontenera.

**Docker Compose** zdefiniowano tak, aby cały przepływ (budowa i testy) dało się odpalić jednym poleceniem, co upraszcza powtarzalność i zbliża konfigurację do typowego **CI/CD** (osobny etap przygotowania artefaktu i osobny etap weryfikacji). W rozwiązaniu widać też rozróżnienie: **obraz** to niezmienny szablon z aplikacją i zależnościami; **kontener** to uruchomiona instancja tego obrazu - obraz **vscode-build** dostarcza środowisko, obraz **vscode-test** służy do wykonania `npm test`.
