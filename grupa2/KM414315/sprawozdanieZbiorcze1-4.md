# Sprawozdanie Zbiorcze: Laboratoria 1-4
**Tematyka:** Narzędzia DevOps, Git, Podstawy Dockera, Izolacja środowisk, Sieci i Woluminy

## Cel Laboratoriów
Celem pierwszego cyklu laboratoriów było przygotowanie profesjonalnego stanowiska pracy programisty/inżyniera DevOps, wdrożenie się w ekosystem kontenerów Docker, oraz izolacja procesu budowania i testowania kodu. Cykl zakończył się konfiguracją zaawansowanych mechanizmów Dockera (sieci, woluminy) i wstępnym przygotowaniem instancji Jenkins.

---

## Laboratorium 1: Środowisko pracy i Git
Pierwsze zajęcia skupiły się na poprawnej konfiguracji narzędzi. Zestawiono uwierzytelnianie do serwisu GitHub z wykorzystaniem protokołu SSH (wygenerowano bezpieczne klucze kryptograficzne). Sklonowano repozytorium przedmiotowe i utworzono dedykowaną, izolowaną gałąź roboczą `KM414315`. 

W celu zapewnienia standardów nazewnictwa w repozytorium, napisano i zaimplementowano skrypt typu Git Hook (`commit-msg`), który automatycznie weryfikuje, czy każda wiadomość commita rozpoczyna się od zdefiniowanego prefiksu (inicjałów i numeru indeksu).

**Kod zaimplementowanego skryptu Git Hook (`commit-msg`):**
```bash
#!/bin/bash
PREFIX="KM414315"
MESSAGE=$(cat "$1")

if [[ ! $MESSAGE == $PREFIX* ]]; then
  echo "BŁĄD: Wiadomość commita musi zaczynać się od $PREFIX!"
  exit 1
fi
exit 0
```

## Laboratorium 2: Wprowadzenie do Dockera
Zainstalowano środowisko Docker na systemie operacyjnym Ubuntu Server. Po pomyślnym zalogowaniu się do Docker Hub za pomocą tokenu, przeanalizowano działanie i rozmiary podstawowych obrazów, takich jak busybox, ubuntu, czy obrazy środowiska .NET.

Przetestowano tryb interaktywny kontenerów (docker run -it), weryfikując drzewo procesów (wyizolowany PID 1) i dokonano aktualizacji pakietów systemowych izolowanego systemu. Utworzono pierwszy prosty plik Dockerfile realizujący pobranie repozytorium za pomocą narzędzia git.

**Prosty Dockerfile narzędziowy:**

```bash
FROM ubuntu:22.04
WORKDIR /app
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*
RUN git clone [https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git) .
```

## Laboratorium 3: Konteneryzacja procesu Build & Test
Na cele zadania wybrano otwartoźródłowy projekt w technologii Node.js/TypeScript (nestjs/typescript-starter), dysponujący testami jednostkowymi zaimplementowanymi w środowisku Jest. Projekt pomyślnie zbudowano i przetestowano lokalnie.

Następnie przeniesiono ten proces do izolowanego środowiska Dockera, dzieląc go na mniejsze etapy. Utworzono definicje Dockerfile automatyzujące instalację zależności, krok kompilacji (build) oraz separujące wykonanie testów jednostkowych (test). Zastosowanie kontenerów zagwarantowało pełną powtarzalność środowiska.

**Dockerfile dla etapu budowania (moj-etap-build):**

```bash
FROM node:18
WORKDIR /app
RUN git clone [https://github.com/nestjs/typescript-starter.git](https://github.com/nestjs/typescript-starter.git) .
RUN npm install
RUN npm run build
```

***Dockerfile dla etapu testowania (moj-etap-test):***

```bash
FROM moj-etap-build:latest
CMD ["npm", "run", "test"]
```

## Laboratorium 4: Woluminy, Sieci i środowisko CI
Ostatnie laboratorium cyklu wprowadziło koncepcję zachowywania stanu (persystencji) pomiędzy nietrwałymi kontenerami za pomocą woluminów Dockera (vol_wejsciowy, vol_wyjsciowy).

Za pomocą narzędzia iperf3 przetestowano przepustowość połączeń sieciowych między kontenerami. Pomiary wykonano na domyślnej sieci mostkowej, a następnie na dedykowanej sieci użytkownika (moja_super_siec), sprawdzając poprawność rozpoznawania hostów po nazwach DNS, a nie tylko adresach IP. Uruchomiono i zweryfikowano również kontener dostarczający usługę SSHD.

W finalnym kroku zainicjalizowano serwer automatyzacji Jenkins, wykorzystując podejście Docker-in-Docker (DIND) do umożliwienia budowania kontenerów z poziomu agentów Jenkinsa.

**Uruchomienie serwera DIND (Docker in Docker) i sieci:**

```bash
docker network create jenkins
docker volume create jenkins-docker-certs
docker volume create jenkins-data

docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  docker:dind
```
