Wszystkie poniższe czynności zostały wykonane na maszynie wirtualnej Ubuntu Server za pomocą SSH.

# Zachowywanie stanu między kontenerami

1. Stworzono 2 nowe woluminy: ![](./1.png)

2. Zmodyfikowano Dockerfile z poprzednich zajęć aby stworzyć obraz builder bez gita:
```docker
FROM ubuntu:22.04

# Pobieranie zależności
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool-bin \
    pkg-config \
    libogg-dev \
    gettext
```
![](./build.png)
![](./2.png) \
3. 
Utworzono kontener z załączonymi woluminami:![](./3.png) \
4. Sklonowano repozytorium za pomocą kontenera pomocniczego:
![](./4.png) \
5. Uruchomiono build w kontenerze: ![](./5.png) i zapisano wynik: ![](./6.png) \
6. Można również wszystko wykonać za pomocą dockerfile'a i parametru --mount dla RUN:
```docker
FROM flac:builder AS builder

# Montujemy wolumin wejściowy (bind mount) – źródło może być np. lokalny katalog
RUN --mount=type=bind,target=/input \
    cd /input && ./autogen.sh && ./configure && make -j$(nproc)

# Kopiujemy wynik do woluminu wyjściowego (lub do obrazu)
RUN --mount=type=bind,target=/output \
    cp -r /input/microbench /output/
```