# Sprawozdanie Lab1-4, Tomasz Kamiński

## Lab1 

* Konfiguracja środowiska (Maszyna wirtualna, VS, Filezilla)
* Utworzenie kluczy ssh i dodanie publicznego na githuba
* Utworzonie dedykowanej gałąęzi roboczej i sklonowanie repo przez http i ssh
* Zapoznanie się z git hookami, implementacja skryptu która sprawdza poprawność prefixu w commicie 
* Pull Request 

commit-msg.sh:
~~~
#!/bin/bash

prefix="TK422047"
message=$(cat "$1")
if [[ $message =~ ^$prefix ]]; then
    echo "OK"
    exit 0
else
    echo "nie ma prefixa";
    exit 1
fi
~~~


## Lab2 
 
Zapoznanie z Dockerem i cyklem życia kontenerów.

Porównanie obrzu z kontenerem: 
Obraz kontenera to szablon tylko do odczytu, który służy do przydzielania zasobów dla kontenera.

Wybrane komendy:
* docker images - Wyświetla liste pobranych obrazów
* docker ps -a - Wyswietla liste kontenerów 
* docker run -it busybox - Interaktywne wejscie kontenera
* docker container prune -f - Usuniecie nie urchomionych kontenerów
* docker rm/stop busybox - zatrzymanie/usuniecie kontenera 

Dockerfile:
~~~
FROM ubuntu:latest

RUN apt-get update && apt-get install -y git 

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .
~~~

## Lab3

Trzecie zajęcia skupiły się na praktycznym zastosowaniu Dockera, przeprowadzono pełny cykl budowania wybranej biblioteki,

* Instalacja wszystkich potrzebnych zaleznosci kompilatora GCC, klienta git oraz serwera redis-server
* Wykonanie buildu i testów na hoscie i w kontenerze
* Utworzenie docker build i docker test w celu automatyzacji procesu


Dockerfile.build:
~~~
FROM ubuntu:latest

RUN apt-get update && apt-get install -y  build-essential  git 
    
WORKDIR /app

RUN git clone https://github.com/redis/hiredis.git .
RUN make
~~~

Dockerfile.test:
~~~
FROM hiredis-build

RUN apt-get update && apt-get install -y redis-server

CMD make check
~~~

## lab4

Komunikację między kontenerami zrealizowano w dedykowanej sieci typu bridge, sprawdzono przepustowość z poziomu hosta jak i z poza. W osatnich dwóch etapach uruchomino usłuhe sshd i połąćżono się z nią i postawiono serwer Jenkins