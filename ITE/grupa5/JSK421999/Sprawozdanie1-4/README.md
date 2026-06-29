# Zbiorcze sprawozdanie z laboratoriów 1-4

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## Spis treści

1. [System kontroli wersji (Git, SSH, Hooki)](#1-system-kontroli-wersji-git-ssh-hooki)
2. [Podstawy konteneryzacji (Docker)](#2-podstawy-konteneryzacji-docker)
3. [Powtarzalne środowiska budowania (Dockerfile, build, test)](#3-powtarzalne-środowiska-budowania-dockerfile-build-test)
4. [Zarządzanie stanem, sieci i wdrożenie Jenkinsa](#4-zarządzanie-stanem-sieci-i-wdrożenie-jenkinsa)

---

# 1. System kontroli wersji (Git, SSH, Hooki)

System Git to fundament nowoczesnego procesu wytwarzania oprogramowania — umożliwia śledzenie zmian, bezpieczne przechowywanie kodu i współpracę w zespole.

## Uwierzytelnianie i bezpieczny dostęp do repozytorium

Dostęp do zdalnego repozytorium GitHub zrealizowano dwiema metodami:

- **PAT (Personal Access Token):** Wygenerowano token z precyzyjnie ograniczonymi uprawnieniami, umożliwiający klonowanie przez HTTPS.
- **Klucze SSH:** Utworzono dwa klucze w nowoczesnym standardzie (innym niż RSA), z czego co najmniej jeden został dodatkowo zabezpieczony hasłem. Klucz publiczny dodano do ustawień konta GitHub, co umożliwiło klonowanie repozytorium przez protokół SSH.

![Personal Access Token](img1/personalToken.jpg)
![Klonowanie repo HTTPS](img1/Klonowanie_repo_https.jpg)
![Generowanie kluczy SSH](img1/gen_ssh_2x.jpg)
![Dodanie klucza SSH do GitHuba](img1/DodanieKluczaSsh.jpg)

Dla dodatkowej warstwy bezpieczeństwa skonfigurowano uwierzytelnianie dwuskładnikowe (2FA) na koncie GitHub.

![2FA GitHub](img1/2FA.jpg)

## Organizacja środowiska deweloperskiego

Środowisko pracy podzielono na maszynę hosta (z interfejsem graficznym) oraz maszynę wirtualną z systemem Linux, w której wykonywane są procesy deweloperskie. Do komunikacji i wymiany plików między systemami wykorzystano:
- **Visual Studio Code z rozszerzeniem Remote-SSH** – edycja kodu na hoście z natychmiastowym wykonaniem w środowisku zdalnym.
- **FileZilla (SFTP)** – alternatywna metoda wymiany plików.

![VS Code SSH](img1/vscodeSSH.jpg)
![FileZilla](img1/filezilla.jpg)
![Test połączenia SSH z devops](img1/setup_ssh.jpg)

## Praca na gałęziach (Branching)

Zgodnie z workflow projektu:
1. Przełączono się na gałąź `main`, a następnie na gałąź grupy (`grupa5`).
2. Utworzono własną gałąź o nazwie `JSK421999`.
3. W katalogu grupy utworzono katalog `JSK421999`.
4. Zmiany wypychano poleceniem `git push`, a następnie utworzono Pull Request w celu wciągnięcia gałęzi do gałęzi grupowej.

![Checkout main i grupa](img1/checkoutmainGrupa.jpg)
![Pull Request na GitHubie](img1/GitHub%20PR.jpg)

## Git Hook — `commit-msg`

W celu wymuszenia spójności logów historii zaimplementowano lokalny mechanizm Git Hooka. Skrypt `commit-msg` weryfikuje, że każdy komunikat commita zaczyna się od prefiksu `JSK421999`.

Treść hooka (`commit-msg`):

```bash
#!/bin/bash

COMMIT_MSG=$1

FIRST_LINE=$(head -n 1 "$COMMIT_MSG")

MOJ_PREFIKS="JSK421999"

if [[ "$FIRST_LINE" != "$MOJ_PREFIKS"* ]]; then
    echo "==========================================================="
    echo "BŁĄD: Brak inicjału"
    echo "Oczekiwano na początku: '$MOJ_PREFIKS'"
    echo "Twoja wiadomość:        '$FIRST_LINE'"
    echo "==========================================================="
    
    exit 1
fi

exit 0
```

Skrypt skopiowano do `.git/hooks/commit-msg` i nadano mu uprawnienia wykonywania. Po przetestowaniu i poprawkach hook działa poprawnie — odrzuca commity bez wymaganego prefiksu, a akceptuje te zgodne z konwencją.

![Hook fix](img1/hook_fix.jpg)
![Działający hook](img1/working_hook.jpg)

---

# 2. Podstawy konteneryzacji (Docker)

Konteneryzacja zapewnia powtarzalność i izolację procesów deweloperskich. Docker, jako rynkowy standard, stanowi fundament nowoczesnych potoków CI/CD.

## Instalacja i konfiguracja

Docker zainstalowano z repozytorium dystrybucji Linux, unikając formatów Snap/FlatPak, które mogą wprowadzać problemy z uprawnieniami i izolacją sieciową. Użytkownika dodano do grupy `docker`, aby umożliwić pracę bez `sudo`.

![Instalacja Docker](img2/intalacja_docker.jpg)
![Dodanie do grupy docker](img2/instalacja_docker_dodanie_do_grupy.jpg)

Zalogowano się do Docker Hub za pomocą `docker login`:

![Docker login](img2/docker_login.jpg)

## Bazowe obrazy — przegląd

Zapoznano się z podstawowymi obrazami dostępnymi na Docker Hub. Pobrano i uruchomiono obrazy: `hello-world`, `busybox`, `ubuntu`, `mariadb`, `aspnet`, `sdk`. Sprawdzono ich rozmiary — obrazy różnią się znacząco: od kilku KB (`hello-world`, `busybox`) po setki MB (pełne systemy i SDK).

![Hello World](img2/testy_hello_world.jpg)
![Uruchomienie reszty obrazów](img2/testy_uruchomienie_reszty_obrazow.jpg)
![Rozmiar obrazów](img2/rozmiar_obrazow.jpg)

## Praca interaktywna z kontenerem

Uruchomiono kontener `busybox` w trybie interaktywnym (`-it`) i zweryfikowano numer jego wersji:

![Busybox version](img2/busybox_version.jpg)

## System w kontenerze — PID1

Uruchomiono kontener `ubuntu` w trybie interaktywnym. Zaprezentowano proces PID1 wewnątrz kontenera oraz odpowiadające mu procesy Dockera na hoście — pokazuje to, że kontener to po prostu izolowana grupa procesów w systemie gospodarza.

![PID1 i procesy Docker](img2/ubuntu_pid.jpg)

## Tworzenie własnego Dockerfile

Zgodnie z dobrymi praktykami, utworzono plik `Dockerfile` bazujący na `ubuntu:24.04`, instalujący Gita i klonujący repozytorium przedmiotowe:

![Zawartość Dockerfile](img2/dockerfile_content.jpg)

```dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE .

CMD ["/bin/bash"]
```

Obraz zbudowano i uruchomiono w trybie interaktywnym — potwierdzono obecność sklonowanego repozytorium wewnątrz kontenera.

![Budowanie Dockerfile](img2/budowanie_dockerfile.jpg)
![Działający git w kontenerze](img2/dzialajacy_git_w_kontenerze.png)

## Zarządzanie kontenerami

Wyświetlono wszystkie kontenery (zarówno aktywne, jak i zakończone). Następnie usunięto zakończone kontenery za pomocą `docker container prune`.

![Wyświetlenie kontenerów](img2/wyswietlenie_kontenerow.jpg)
![Container prune](img2/container_prune.jpg)

---

# 3. Powtarzalne środowiska budowania (Dockerfile, build, test)

Celem było zbudowanie oprogramowania w powtarzalnym, odizolowanym środowisku — tak, aby proces był w pełni przenośny między maszynami.

## Wybór oprogramowania

Wybrano repozytorium aplikacji Node.js — oficjalny projekt startowy frameworka **NestJS** (TypeScript). Projekt jest udostępniany na otwartej licencji MIT, zawiera testy jednostkowe (Jest) i umożliwia budowanie przez `npm run build` oraz testowanie przez `npm test`.

## Uruchomienie lokalne

Sklonowano repozytorium, zainstalowano zależności i zweryfikowano poprawność budowania oraz testów poza kontenerem.

![Pobranie repozytorium](img3/pobranie_repo.jpg)
![Instalacja npm](img3/install_npm.jpg)
![npm install](img3/cmd_npm_install.jpg)
![Build i testy lokalnie](img3/npm_build_i_npm_test.jpg)

## Build i testy w kontenerze (interaktywnie)

Ten sam proces odtworzono wewnątrz kontenera bazowego `node`:
1. Sklonowano repozytorium.
2. Zainstalowano zależności.
3. Wykonano budowanie aplikacji (`npm run build`).
4. Uruchomiono testy jednostkowe (`npm test`).

![Interaktywny build i testy w kontenerze](img3/git_clone_npm_install_npm_build_npmtest_it.jpg)

## Automatyzacja przez Dockerfile (2 etapy)

Zgodnie z dobrymi praktykami izolacji etapów, przygotowano dwa pliki `Dockerfile`:

### Dockerfile etapu Build

Pierwszy obraz realizuje wszystkie kroki do momentu zbudowania aplikacji (`npm run build`), bez uruchamiania testów:

![Dockerfile build](img3/Dockerfile_build.jpg)

### Dockerfile etapu Test

Drugi obraz bazuje na obrazie build (`FROM` poprzedniego etapu) i uruchamia wyłącznie testy — bez ponownego budowania:

![Dockerfile test](img3/Dockerfile_test.jpg)

### Weryfikacja

Uruchomiono kontener z obrazu testowego — testy przeszły pomyślnie. Należy podkreślić różnicę: obraz jest jedynie szablonem (definicją), natomiast **kontener** to uruchomiona instancja obrazu, która wykonuje proces (`npm test`) jako PID1.

![Uruchomienie kontenera testowego](img3/docker_tun_nest-app-test.jpg)

---

# 4. Zarządzanie stanem, sieci i wdrożenie Jenkinsa

## Woluminy — zachowywanie stanu między kontenerami

Kontenery z założenia są ulotne — dane znikają po ich usunięciu. Woluminy Docker rozwiązują ten problem, umożliwiając trwałe przechowywanie danych niezależnie od cyklu życia kontenera.

### Build z użyciem woluminów i kontenera pomocniczego

Utworzono wolumin wejściowy (`input`) i wyjściowy (`output`). Kod źródłowy sklonowano na wolumin wejściowy za pomocą tymczasowego kontenera pomocniczego z Gitem — dzięki temu **kontener docelowy nie potrzebuje Gita**, co jest zgodne z filozofią minimalnych obrazów.

![Tworzenie volume i clone repo](img4/tworzenie%20volume%20i%20clone%20repo.jpg)

Następnie uruchomiono kontener docelowy `node:20` (bez Gita), podpięto do niego oba woluminy i wykonano budowanie. Pliki wynikowe zapisano na woluminie wyjściowym, skąd są dostępne nawet po usunięciu kontenera.

![Budowanie operacyjne w docelowym kontenerze](img4/budowanie%20w%20temp%20kontenerze.jpg)

### Build w jednym kontenerze (z Gitem)

Alternatywnie, proces powtórzono używając jednego kontenera z zainstalowanym Gitem — sklonowano kod i zbudowano aplikację wewnątrz niego.

![Skrócona alternatywa clone i build w jednym kontenerze](img4/alternatywa%20clone%20i%20build%20w%20jednym%20kontenerze.jpg)

### Dyskusja: `RUN --mount`

Opcja `RUN --mount=type=bind` w `Dockerfile` pozwala zamontować kod z hosta tylko na czas budowania warstwy. Dzięki temu unikamy trwałego przechowywania historii repozytorium i narzędzi typu Git w finalnym obrazie — co przekłada się na mniejszy rozmiar i lepsze bezpieczeństwo.

---

## Sieci Docker — eksponowanie portów i komunikacja

### Domyślna sieć bridge

Uruchomiono serwer `iperf3` w domyślnej sieci bridge, sprawdzono jego adres IP i przeprowadzono test przepustowości z drugiego kontenera, używając adresu IP.

![Serwer iperf w kontenerze](img4/uruchomienie%20iperf3.jpg)
![Adresacja domyślna dla bridge](img4/znalezienie%20ip%20kontenera%20iperf3.jpg)
![Benchmark iperf3 za pomocą IP](img4/benchmark%20iperf3%20za%20pomoca%20ip.jpg)

### Własna sieć nazwana i rozwiązywanie nazw

Utworzono dedykowaną sieć (`docker network create`). Dzięki wbudowanemu w Dockera serwerowi DNS, kontenery mogą komunikować się między sobą za pomocą **nazw**, a nie adresów IP — co znacząco upraszcza konfigurację.

![Uruchomienie iperf3 na nazwanej sieci](img4/uruchomienie%20iperf3%20serwer%20na%20nazwanej%20sieci%20docker.jpg)
![Benchmark iperf3 dla nazwanej sieci](img4/benchmark%20iperf3%20dla%20nazwanej%20sieci.jpg)

### Łączność spoza hosta

Wystawiono port (`-p 5201:5201`) i przeprowadzono test `iperf3` z zewnętrznego komputera spoza klastra Dockera — potwierdzając możliwość komunikacji ze światem zewnętrznym.

![Transmisja z zewnątrz](img4/iperf3%20z%20innego%20komputera%20do%20otwartego%20portu%20dockera.jpg)

---

## SSH jako usługa w kontenerze

Uruchomiono kontener Ubuntu z serwerem SSH (`sshd`) i połączono się z nim z zewnętrznego komputera.

![Instalowanie ssh](img4/ssh%20w%20dockerze.jpg)
![Udane wejście SSH do Dockera z zewnątrz](img4/polaczenie%20sie%20do%20ssh%20w%20dockerze%20z%20zewnetrzego%20komputera.jpg)

**Zalety i wady SSH w Dockerze:**
- **Zalety:** Pozwala używać tradycyjnych narzędzi do skryptowania i transferu plików (np. SCP), które opierają się na protokole SSH.
- **Wady:** Jest sprzeczne z filozofią Dockera (jeden proces na kontener), zwiększa rozmiar obrazu o pakiety serwera SSH i poszerza potencjalną powierzchnię ataku.

---

## Instalacja Jenkins (DIND)

Zgodnie z dokumentacją, skonfigurowano środowisko **DinD** (Docker in Docker) i uruchomiono instancję serwera CI Jenkins. Wykazano działające kontenery oraz panel logowania po pomyślnej inicjalizacji.

![Deploy Jenkins node](img4/jenkins%20docker%20containers%20setup.jpg)
![Panel Jenkins po zalogowaniu](img4/working%20jenkins%20dashboard%20(after%20login).jpg)

Jenkins w kontenerze, mający dostęp do demona Dockera (poprzez DinD), stanowi fundament pod dalszą automatyzację procesów CI/CD.
