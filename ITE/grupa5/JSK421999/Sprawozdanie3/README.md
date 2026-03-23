# Sprawozdanie z laboratorium 3

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Wybór oprogramowania i uruchomienie lokalne

Na potrzeby laboratorium wybrałem repozytorium aplikacji Node.js (NestJS), które zawiera testy i umożliwia budowanie przez `npm run build` oraz testowanie przez `npm test`.

### Pobranie repozytorium

Sklonowanie projektu do środowiska roboczego:

![Pobranie repozytorium](img/pobranie_repo.jpg)

### Instalacja zależności

Instalacja `npm` i narzędzi wymaganych do budowania aplikacji:

![Instalacja npm](img/install_npm.jpg)

Instalacja zależności projektu:

![npm install](img/cmd_npm_install.jpg)

### Build i testy lokalnie

Uruchomienie `npm run build` oraz `npm test` poza kontenerem:

![Build i testy lokalnie](img/npm_build_i_npm_test.jpg)

---

## 2. Izolacja i powtarzalność: build oraz testy w kontenerze (interaktywnie)

W drugim kroku ten sam proces został odtworzony wewnątrz kontenera bazowego z Node.js.

W kontenerze wykonano kolejno:
- klonowanie repozytorium,
- instalację zależności,
- budowanie aplikacji,
- uruchomienie testów.

![Interaktywny build i testy w kontenerze](img/git_clone_npm_install_npm_build_npmtest_it.jpg)

---

## 3. Automatyzacja kroków przez Dockerfile (2 etapy)

Zgodnie z poleceniem przygotowano dwa Dockerfile:

### 3.1. Dockerfile etapu build

Pierwszy obraz realizuje wszystkie kroki do momentu zbudowania aplikacji (`npm run build`), bez uruchamiania testów:

![Dockerfile build](img/Dockerfile_build.jpg)

### 3.2. Dockerfile etapu test

Drugi obraz bazuje na obrazie build i uruchamia tylko testy (`npm test`) — bez ponownego budowania:

![Dockerfile test](img/Dockerfile_test.jpg)

### 3.3. Weryfikacja działania obrazu testowego

Uruchomienie kontenera z obrazu testowego i potwierdzenie poprawnego wykonania testów:

![Uruchomienie kontenera testowego](img/docker_tun_nest-app-test.jpg)

Wniosek: obraz jest tylko szablonem, a pracuje **kontener** uruchomiony z tego obrazu. To kontener wykonuje proces (`npm test`) jako PID1.

---