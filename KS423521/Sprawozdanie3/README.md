# Sprawozdanie z zajęć nr 3

- **Imię i nazwisko:** Kacper Strzesak
- **Indeks:** 423521
- **Kierunek:** Informatyka techniczna
- **Grupa**: 5

---

## 1. Środowisko pracy

Zadania wykonano na systemie Ubuntu Server 24.04.4 LTS uruchomionym na platformie VirtualBox. Połączenie z maszyną zrealizowano za pomocą protokołu SSH (użytkownik: kacper).

## 2. Wybór repozytorium

Wybrano repozytorium: [jest-nodejs-example-showcase](https://github.com/BaseMax/jest-nodejs-example-showcase)

Repozytorium spełnia wymagania:

- posiada otwartą licencję (**GPL-3**),

- wykorzystuje środowisko **Node.js**,

- zawiera testy jednostkowe (**Jest**),

- umożliwia wykonanie poleceń `npm install` oraz `npm test`.

## 3. Uruchomienie aplikacji lokalnie

### 3.1. Sklonowanie repozytorium

![Sklonowanie Tepozytorium](screenshots/git-clone.png)

### 3.2. Instalacja zależności

![Instalacja Zależności](screenshots/npm-install.png)

### 3.3. Uruchomienie testów

![Uruchomienie Testów](screenshots/npm-test.png)

Testy w `sum.js` przeszły pomyślnie (**12 passed**). Pozostałe dwa zestawy zgłosiły błąd, ponieważ ich kod jest zakomentowany.


## 4. Budowanie i testowanie w kontenerze (tryb interaktywny)

## 4.1. Uruchomienie kontenera

Wykorzystano obraz Node.js.

`docker run -it node:20-slim bash`

Następnie zainstalowano `git`, by móc sklonować repozytorium.

![Uruchomienie Kontenera](screenshots/docker-run.png)

## 4.2. Klonowanie repozytorium

![Klonowanie w Kontenerze](screenshots/git-clone-kontener.png)

## 4.3. Build i test

Uruchomiono `npm install`, a następnie `npm test`.

![Klonowanie w Kontenerze](screenshots/npm-test-kontener.png)

Proces zakończył się sukcesem, co potwierdza poprawność działania aplikacji w odizolowanym środowisku.

# 5. Automatyzacja przy użyciu Dockerfile

## 5.1. Dockerfile (budowanie)

![Dockerfile Build](screenshots/dockerfile-build.png)

**Budowanie obrazu:**

![Dockerfile Budowanie](screenshots/dockerfile-budowanie.png)

## 5.2. Dockerfile (testowanie)

![Dockerfile Test](screenshots/dockerfile-test.png)

**Budowanie obrazu testowego:**

![Dockerfile Test Budowanie](screenshots/dockerfile-test-budowanie.png)

**Uruchomienie testów:**

![Dockerfile Test Testowanie](screenshots/docker-run-jest-test.png)

Kontener uruchamia skrypt testowy Jest oraz wyświetla raport z testów.
