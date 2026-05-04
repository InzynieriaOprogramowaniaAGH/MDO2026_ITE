# Sprawozdanie Zbiorcze 1
**Autor:** Mateusz Stępień (MS422029)

**Kierunek:** Informatyka Techniczna
## 1. System kontroli wersji Git i bezpieczna komunikacja
Podstawą pracy z kodem jest zapewnienie bezpiecznego połączenia z repozytorium. W tym celu wygenerowano klucz SSH przy użyciu algorytmu Ed25519 poleceniem `ssh-keygen -t ed25519 -C "MDO"`. Część publiczna klucza została dodana do konta w serwisie GitHub, co umożliwiło bezproblemowe klonowanie repozytorium. 

Praca z systemem Git obejmowała:
* **Zarządzanie gałęziami (branchami):** Przełączono się na gałąź główną, następnie na gałąź `grupa5`, z której ostatecznie utworzono indywidualną gałąź o nazwie `MS422029`.
* **Automatyzację za pomocą Git Hooks:** Utworzono skrypt `commit-msg` i umieszczono go w ukrytym katalogu `.git/hooks/`, nadając mu uprawnienia do wykonywania (`chmod +x`). Zadaniem skryptu jest automatyczne dodawanie numeru indeksu na początek każdej wiadomości commita.

## 2. Docker
Po zainstalowaniu pakietu `docker.io`, zbadano podstawowe mechanizmy działania kontenerów:
* **Kody wyjścia:** Uruchomiono testowe obrazy (m.in. `hello-world`, `busybox`, `ubuntu`) i zweryfikowano ich kody wyjścia. Status `0` oznacza poprawne zakończenie zadania przez kontener. Listę zakończonych kontenerów można sprawdzić poleceniem `docker ps -a`.
* **Procesy i PID 1:** Zbadano procesy wewnątrz kontenera `ubuntu`. Proces startowy, np. `/bin/bash`, otrzymuje wewnątrz kontenera identyfikator PID 1. Z poziomu systemu hosta procesy te są widoczne jako odrębne zadania zarządzane przez silnik Docker.
* **Optymalizacja obrazu:** Utworzono własny plik `Dockerfile` bazujący na Ubuntu 24.04, w którym po instalacji narzędzia `git` wyczyszczono menedżer pakietów, co jest dobrą praktyką redukującą rozmiar końcowego obrazu.

## 3. Pliki .test i .build
Aby zautomatyzować proces kompilacji i testowania, wykorzystano bibliotekę cJSON w języku C. Zamiast wykonywać wszystkie operacje ręcznie w jednym kontenerze, podzielono proces na dwa niezależne etapy:
1. **Środowisko budujące (`Dockerfile.build`):** Obraz ten pobiera system Ubuntu, instaluje narzędzia takie jak `git`, `build-essential` i `cmake`, a następnie klonuje repozytorium do katalogu `/app` i wykonuje kompilację poleceniem `make`.
2. **Środowisko testowe (`Dockerfile.test`):** Obraz bazuje bezpośrednio na warstwach pierwszego obrazu (`FROM cjson-build:latest`), a jego jedynym zadaniem jest wywołanie testów za pomocą polecenia `make test`.

To podejście demonstruje zasadę jednego procesu – kontener testowy uruchamia binarkę z testami, a po ich zakończeniu proces zwraca kod 0 i kontener ulega wyłączeniu.

## 4. Woluminy
Kluczowym elementem pracy z Dockerem jest zachowanie wygenerowanych danych oraz komunikacja między kontenerami.
* **Woluminy i kontenery pomocnicze:** Aby zbudować aplikację Express.js bez instalowania programu Git w docelowym obrazie, utworzono wirtualne dyski (woluminy): `wejsciowy` i `wyjsciowy`. Tymczasowy kontener pomocniczy pobrał kod na wolumin `wejsciowy`. Następnie główny kontener budujący (`node:18-bullseye`) podpiął te woluminy, wykonał kompilację (`npm install`) i zapisał wynik na wolumenie `wyjsciowy`. 
* **Wewnętrzny DNS Dockera:** W domyślnej sieci `bridge` kontenery komunikują się po adresach IP, które trzeba odczytywać komendą `docker inspect`. Aby to uprościć, utworzono własną sieć poleceniem `docker network create my-network`. We własnych sieciach Docker zapewnia serwer DNS, co pozwala na łączenie się z usługami poprzez ich nazwy (np. `serwer-iperf-dns`).
* **Eksponowanie portów:** Aby umożliwić dostęp z zewnątrz, wystawiono port kontenera parametrem `-p 5201:5201`. Ruch odbywający się w ramach maszyny hosta charakteryzuje się bardzo wysoką przepustowością, gdyż jest obsługiwany wirtualnie w pamięci RAM przez jądro systemu Linux.

## 5. Jenkins 
W ramach badań przetestowano działanie serwera SSH w kontenerze (obraz `rastasheep/ubuntu-sshd`). Ustalono, że traktowanie kontenera jak wirtualnej maszyny i instalowanie w nim demona SSH to antywzorzec. Takie podejście niepotrzebnie powiększa obraz, komplikuje zarządzanie kluczami i wprowadza luki w zabezpieczeniach. Do interaktywnej pracy należy używać polecenia `docker exec`.

Na koniec wdrożono platformę CI/CD Jenkins w architekturze Docker-in-Docker (DinD). Utworzono dedykowaną sieć `jenkins` i uruchomiono dwie połączone usługi: pomocniczy kontener `docker:dind` (silnik Dockera) oraz właściwą instancję z interfejsem graficznym `jenkins-blueocean`. Środowisko zainicjalizowano, odczytując z logów kontenera startowe hasło administratora i podając je na stronie dostępnej przez przemapowany port 8080.