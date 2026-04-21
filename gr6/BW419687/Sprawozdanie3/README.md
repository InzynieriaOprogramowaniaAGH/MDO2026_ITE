Wszystkie poniższe czynności zostały wykonane na maszynie wirtualnej Ubuntu Server za pomocą SSH.

# Dobór i wstępna kompilacja programu otwartoźródłowego

1. Wybrano repozytorium FLAC (https://gitlab.xiph.org/steils/flac/) jako program z otwartą licencją i systemem buildowania z testami: ![](./1.png)

2. Po zainstalowaniu zależności wywołano skrypt autoconf: ![](./2.png)

3. Następnie wywołano skrypt configure ![](./3.png)

4. Po uruchomieniu obu narzędzi program może być zbuildowany za pomocą make: ![](./4.png)

5. I przetestowany za pomocą make check: ![](./5.png)

# Build w kontenerze

1. Uruchomiono nowy kontener Ubuntu: ![](./6.png)

2. Pobrano zależności: ![](./7.png) ![](./8.png) ![](./9.png)

3. Sklonowano repozytorium: ![](./10.png)

4. Zbudowano program: ![](./11.png)

5. Utworzono użytkownika do wykonywania testów (root nie powinien ich wykonywać): ![](./12.png)

# Automatyzacja z dockerfile

1. Utworzono plik Dockerfile-build do buildowania (ale nie testowania) FLAC:
```docker
FROM ubuntu:22.04

# Pobieranie zależności
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool-bin \
    pkg-config \
    git \
    libogg-dev \
    gettext

# Przygotowanie użytkownika
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

# Klonowanie
RUN git clone https://gitlab.xiph.org/xiph/flac.git flac

# Build
WORKDIR /home/builder/flac
RUN ./autogen.sh && \
    ./configure && \
    make -j$(nproc)
```

2. Zbudowano następnie obraz z zbuildowanym FLAC: ![](./13.png)

3. Stworzono dockerfile testowy na podstawie poprzedniego:
```docker
# Obraz bazowany na poprzednim obrazie
FROM flac:built

USER builder
WORKDIR /home/builder/flac

# Testy (bez ponownej kompilacji)
RUN make check
```

4. Zbudowano obraz testowy: ![](./14.png)

# Historia bash

```bash
  125  sudo apt install make
  126  ./autogen.sh
  127  sudo apt install autoconf automake libtool pkg-config
  128  ./autogen.sh
  129  apt install libtool
  130  sudo apt install libtool
  131  ./autogen.sh
  132  man libtool
  133  sudo apt install libtool-bin
  134  ./autogen.sh
  135  ./configure
  136  ls
  137  make
  138  ls
  139  sudo apt install g++
  140  make
  141  make check
  142  docker run -it --name flac-builder ubuntu:22.04 bash
  143  ls
  144  cd ..
  145  cd Sprawozdanie3/
  146  docker build -t flac:built -f Dockerfile-build .
  147  docker build -t flac:tested -f Dockerfile-test .
  148  history
```