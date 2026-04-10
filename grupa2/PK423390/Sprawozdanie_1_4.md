# Sprawozdanie zbiorcze - Laboratoria 1-4
---

## Laboratorium 1 - Git i konfiguracja środowiska

### 1. Instalacja Git i klonowanie repozytorium

Zainstalowano Git, a repozytorium zostało sklonowane przy użyciu protokołu HTTPS z Personal Access Token.

### 2. Klucze SSH

Utworzono dwa klucze SSH (z hasłem i bez), a klucz publiczny dodano do konta GitHub w sekcji SSH Keys:

```bash
cat ~/.ssh/id_ed25519.pub
```

Repozytorium sklonowano ponownie przy użyciu protokołu SSH.

### 3. Konfiguracja środowiska pracy

Repozytorium otwarto w Visual Studio Code przez połączenie Remote SSH. Przejście na gałąź grupy i utworzenie własnej gałęzi roboczej.

### 4. Git Hook - weryfikacja commit message

Utworzono skrypt `commit-msg` wymuszający prefiks `PK423390` w każdym commicie:

```bash
#!/bin/bash

message=$(cat $1)
prefix="PK423390"

if [[ $message != $prefix* ]]; then
    echo "Commit message musi zaczynać się od $prefix"
    exit 1
fi
```

Hook skopiowano do `.git/hooks/`. Próba commita bez prefiksu zakończyła się błędem, co potwierdziło poprawne działanie mechanizmu.

---

## Laboratorium 2 - Wprowadzenie do Docker

### 1. Instalacja Docker

Zainstalowano Docker w wersji dystrybucyjnej (`docker.io`).

### 2. Praca z obrazami z Docker Hub

Pobrano i uruchomiono obrazy: `hello-world`, `busybox`, `mariadb`. Zweryfikowano kody wyjścia procesów w kontenerach (`Exit Codes`).

### 3. Tryb interaktywny i izolacja procesów

Uruchomiono kontener `busybox` w trybie `-it` i sprawdzono wersję systemu. Zademonstrowano izolację procesów - `bash` działał jako PID 1 wewnątrz kontenera, podczas gdy na hoście miał wysoki numer PID.

### 4. Własny Dockerfile

Stworzono `Dockerfile` bazujący na Ubuntu z instalacją Gita i klonowaniem repozytorium. Zbudowany obraz uruchomiono jako kontener i zweryfikowano zawartość sklonowanego repozytorium.

### 5. Czyszczenie środowiska

Wyświetlono wszystkie kontenery (`docker ps -a`) i usunięto zbędne zasoby.

---

## Laboratorium 3 - Budowanie i testowanie w kontenerze

### 1. Wybór projektu

Wybrano projekt **Express.js** - popularny framework webowy dla Node.js.

- Repozytorium: `https://github.com/expressjs/express`
- Licencja: MIT
- Narzędzia budowania: `npm` (`package.json` pełni rolę analogiczną do `Makefile`)
- Projekt zawiera setki testów jednostkowych z czytelnym raportem końcowym

### 2. Budowa i testy - sesja interaktywna

Uruchomiono czysty kontener `node:18`, sklonowano repozytorium, zainstalowano zależności i uruchomiono testy:

```bash
docker run -it node:18 bash
git clone https://github.com/expressjs/express
cd express
npm install
npm test
```

### 3. Automatyzacja - Dockerfile.build i Dockerfile.test

Zaimplementowano dwa pliki Dockerfile rozdzielające etapy budowania i testowania:

**Dockerfile.build** - tworzy obraz bazowy ze sklonowanym i zbudowanym projektem.

**Dockerfile.test** - bazuje na obrazie z poprzedniego kroku i uruchamia testy jako domyślną komendę.

### 4. Obraz vs kontener

Obraz jest statycznym, niezmiennym wzorcem zawierającym system plików, kod aplikacji i biblioteki. Kontener to uruchomiona instancja obrazu - żywy, izolowany proces w systemie.

---

## Laboratorium 4 - Woluminy, sieć i Jenkins

### 1. Zachowywanie stanu między kontenerami

Utworzono dwa woluminy Docker:

```bash
docker volume create vol_input
docker volume create vol_output
```

**Metoda 1 - bind mount z hosta (bez Gita w kontenerze):**
Repozytorium sklonowano na hoście, a następnie podmontowano do kontenera jako bind mount.

```bash
git clone https://github.com/expressjs/express ./express-src

docker run -it \
  -v ./express-src:/input \
  -v vol_output:/output \
  node:18 bash

cd /input && npm install && npm test
cp -r /input/node_modules /output/
cp /input/package.json /output/
```

Wszystkie 1246 testów przeszło pomyślnie. Po wyjściu z kontenera zweryfikowano trwałość danych:

```bash
docker run --rm -v vol_output:/output node:18 ls /output
# node_modules  package.json
```

**Metoda 2 - klonowanie wewnątrz kontenera (Git w kontenerze):**

```bash
docker run -it -v vol_input:/input -v vol_output:/output node:18 bash

apt-get update && apt-get install -y git
git clone https://github.com/expressjs/express /input/express
cd /input/express && npm install && npm test
cp -r /input/express/node_modules /output/
cp /input/express/package.json /output/
```

Ponownie 1246 testów zakończonych sukcesem.

**Dyskusja:**
Instrukcja `RUN --mount=type=bind` pozwala tymczasowo podmontować zasoby podczas budowania obrazu bez zapisywania ich w warstwach. Jednak wyniki nie mogą być zapisane poza obraz.

---

### 2. Sieć i przepustowość - iperf3

Zbadano przepustowość komunikacji w różnych konfiguracjach sieciowych.

**Domyślna sieć bridge (połączenie po IP):**

```bash
docker run -d --name iperf-server networkstatic/iperf3 -s
docker run -it --name iperf-client --network bridge networkstatic/iperf3 -c 172.17.0.2
```

**Własna sieć mostkowa z rozwiązywaniem nazw:**

```bash
docker network create my-net
docker run -d --name iperf-server --network my-net networkstatic/iperf3 -s
docker run -it --name iperf-client --network my-net networkstatic/iperf3 -c iperf-server
```

W dedykowanej sieci możliwe jest użycie nazwy kontenera zamiast adresu IP - Docker zapewnia wbudowany DNS. W domyślnej sieci `bridge` ta funkcjonalność nie jest dostępna.

**Połączenie z hosta i spoza hosta:**

```bash
# Eksponowanie portu:
docker run -d --name iperf-server --network my-net -p 5201:5201 networkstatic/iperf3 -s

# Test z hosta Ubuntu:
iperf3 -c localhost -p 5201

# Test z Windowsa (przez VirtualBox NAT + port forwarding):
iperf3.exe -c 127.0.0.1 -p 5201
```

**Podsumowanie przepustowości:**

| Scenariusz | Przepustowość |
|---|---|
| Kontener → Kontener (domyślna sieć bridge) | ~43.6 Gbits/sec |
| Kontener → Kontener (sieć my-net, po nazwie) | ~33.0 Gbits/sec |
| Host Ubuntu → Kontener (port forwarding) | ~13.7 Gbits/sec |
| Windows → Kontener (VirtualBox NAT) | ~521 Mbits/sec |

Spadek przepustowości w kolejnych scenariuszach wynika z dodawania kolejnych warstw abstrakcji sieciowej (translacja portów NAT, stos sieciowy VirtualBox).

---

### 3. SSHD w kontenerze

Uruchomiono kontener Ubuntu z wyeksponowanym portem 22 i skonfigurowano serwer SSH:

```bash
docker run -it --name ssh-container -p 2222:22 ubuntu bash

apt-get update && apt-get install -y openssh-server
mkdir /run/sshd
echo 'root:haslo123' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
/usr/sbin/sshd -D &
```

Połączono się z kontenera z hosta:

```bash
ssh root@localhost -p 2222
```

**Zalety i wady SSH w kontenerach:**

Zalety: znajoma metoda dostępu, przydatna przy migracji aplikacji legacy.

Wady: sprzeczna z filozofią konteneryzacji (jeden proces = jeden kontener), zwiększa powierzchnię ataku. Docker dostarcza dedykowane narzędzia: `docker exec`, `docker logs`, `docker cp`.

---

### 4. Jenkins + Docker-in-Docker

Przeprowadzono instalację skonteneryzowanej instancji Jenkinsa zgodnie z oficjalną dokumentacją.

**Przygotowanie środowiska:**

```bash
docker network create jenkins
docker volume create jenkins-docker-certs
docker volume create jenkins-data
```

**Kontener DIND:**

```bash
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2
```

**Własny obraz Jenkinsa** (`Dockerfile`):

```dockerfile
FROM jenkins/jenkins:2.541.3-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
```

```bash
docker build -t myjenkins-blueocean:2.541.3-1 .
```

**Uruchomienie Jenkinsa:**

```bash
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.541.3-1
```

Działające kontenery (`docker ps`):
- `jenkins-blueocean` - porty `8080`, `50000`
- `jenkins-docker` (DIND) - port `2376`

Jenkins był dostępny pod adresem `http://localhost:8080` po skonfigurowaniu przekierowania portów w VirtualBox. Wyświetlono ekran inicjalizacji z prośbą o podanie hasła administratorskiego.

---

## Wnioski

W trakcie czterech laboratoriów zapoznano się z kluczowymi narzędziami stosowanymi w praktyce DevOps. Skonfigurowano środowisko Git z automatyczną weryfikacją commitów przez hooki. Opanowano podstawy konteneryzacji Docker - budowanie obrazów, zarządzanie cyklem życia kontenerów i czyszczenie środowiska. Zautomatyzowano budowanie i testowanie projektu Node.js/Express przy użyciu Dockerfile. W ostatnim laboratorium zademonstrowano persystencję danych przez woluminy, zbadano przepustowość różnych konfiguracji sieciowych oraz uruchomiono produkcyjną instancję serwera CI Jenkins z pomocnikiem Docker-in-Docker.