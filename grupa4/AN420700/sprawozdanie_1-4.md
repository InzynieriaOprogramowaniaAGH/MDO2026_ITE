# Sprawozdanie laboratoria 1–4
**Autor:** Artur Niemiec  

---

## 1. Konfiguracja środowiska deweloperskiego (Lab 1)

Sklonowano repozytorium i skonfigurowano dostęp przez SSH przy użyciu kluczy Ed25519. Klucze publiczne dodano do GitHub, klucz prywatny załadowano do agenta SSH. Utworzono dedykowaną gałąź roboczą oraz zaimplementowano git hook wymuszający konwencję nazewnictwa commitów.

**Git hook `commit-msg`:**
```bash
#!/bin/bash
commit_msg=$(cat "$1")
if [[ ! $commit_msg =~ ^AN420700 ]]; then
    echo "BŁĄD: Commit musi zaczynać się od AN420700"
    exit 1
fi
```

**Instalacja hooka:**
```bash
cp commit-msg-hook.sh .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

---

## 2. Środowisko skonteneryzowane Docker (Lab 2)

Zainstalowano Docker i zapoznano się z podstawowym cyklem życia kontenerów: pull, run, exec, stop, rm. Zbudowano własny obraz na podstawie Dockerfile klonujący gałąź roboczą projektu.

Kontener jest izolowanym procesem współdzielącym jądro systemu operacyjnego hosta, który w przeciwieństwie do maszyn wirtualnych nie wirtualizuje sprzętu, co przekłada się na minimalny narzut wydajnościowy. Dockerfile pełni rolę wykonywalnej dokumentacji środowiska, gdzie każda instrukcja `RUN` tworzy nową warstwę obrazu, która jest cache'owana, co przyspiesza kolejne buildy.

**Dockerfile:**
```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y git
WORKDIR /app
RUN git clone -b AN420700 https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
```


---

## 3. Budowanie projektu w kontenerze (Lab 3)

Przeprowadzono pełny cykl budowania interpretera CPython: najpierw lokalnie na hoście, następnie wewnątrz interaktywnego kontenera Ubuntu, a na końcu w pełni zautomatyzowany z użyciem dwóch Dockerfileów i Docker Compose.

Rozdzielenie obrazu buildującego od testującego realizuje zasadę pojedynczej odpowiedzialności. Obraz produkcyjny powinien zawierać wyłącznie skompilowane pliki binarne, dzieki czemu osiąga się **multi-stage build**, w którym końcowy obraz kopiuje artefakty z etapu kompilacji do lekkiej bazy (np. `debian:slim`), eliminując kompilatory i kod źródłowy. Docker Compose automatyzuje zależności między etapami, zastępując ręczne sekwencjonowanie komend.

**Dockerfile.build:**
```dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git build-essential pkg-config libssl-dev zlib1g-dev \
    libffi-dev libbz2-dev libreadline-dev libsqlite3-dev tzdata
RUN git clone https://github.com/python/cpython.git /cpython
WORKDIR /cpython
RUN ./configure && make -j$(nproc)
```

**Dockerfile.test** (dziedziczy po builderze):
```dockerfile
FROM cpython-builder:latest
WORKDIR /cpython
CMD ["make", "test"]
```

**docker-compose.yml:**
```yml
version: '3.8'
services:
  builder:
    build:
      context: .
      dockerfile: Dockerfile.build
    image: cpython-builder:latest
  tester:
    build:
      context: .
      dockerfile: Dockerfile.test
    depends_on:
      - builder
```

---

## 4. Woluminy, sieć i usługi w Dockerze (Lab 4)

Zbadano mechanizmy trwałości danych (woluminy), komunikacji sieciowej między kontenerami (IPerf3) oraz uruchomiono serwer CI (Jenkins z Docker-in-Docker).

Woluminy Dockera trwają niezależnie od cyklu życia kontenerów i są zarządzane przez daemona Dockera, to znaczy są preferowane nad bind mount, który uzależnia kontener od konkretnej ścieżki na hoście. Własna sieć mostkowa aktywuje wbudowany resolver DNS, pozwalając kontenerom adresować się nazwami zamiast zmiennymi adresami IP. SSH w kontenerze jest antywzorcem (`docker exec` w pełni go zastępuje). Docker-in-Docker (DinD) umożliwia natomiast uruchamianie i budowanie kontenerów wewnątrz kontenera CI, co jest standardowym podejściem w pipeline'ach Jenkinsa.

**Klonowanie kodu na wolumin przez kontener pomocniczy:**
```bash
docker run --rm -v input_vol:/helper alpine/git clone \
    https://github.com/python/cpython.git /helper
```

**Sieć mostkowa z DNS:**
```bash
docker network create iperf_siec
docker run --name serwer_dns --network iperf_siec networkstatic/iperf3 -s
docker run --rm --network iperf_siec networkstatic/iperf3 -c serwer_dns
```

### Wnioski

---

## Podsumowanie

| Lab | Zakres | Kluczowe narzędzia |
|-----|--------|--------------------|
| 1 | Git, SSH, git hooks | Git, SSH, Bash |
| 2 | Podstawy Dockera, własny obraz | Docker, Dockerfile |
| 3 | Build pipeline, Docker Compose | Dockerfile, Docker Compose, CPython |
| 4 | Woluminy, sieć, usługi CI | Docker volumes, iperf3, Jenkins, DinD |

Laboratoria tworzą spójny pipeline DevOps. Centralną ideą jest izolacja: każdy etap działa w osobnym, deterministycznym środowisku.
