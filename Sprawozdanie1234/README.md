# Sprawozdanie z laboratoriów


------------------------------------------------------------------------

# Zajęcia 01 -- Git, gałęzie, SSH

## Cel

Celem zajęć było przygotowanie środowiska pracy oraz zapoznanie się z
podstawowymi mechanizmami systemu kontroli wersji Git, konfiguracją SSH
oraz pracą na gałęziach repozytorium.

## Wykonane zadania

### Instalacja Git

``` bash
sudo apt install git
git --version
```

Sklonowano repozytorium przedmiotowe:

``` bash
git clone 
```

### Konfiguracja SSH

``` bash
ssh-keygen -t ed25519 -C "student@example.com"
ssh-keygen -t ecdsa -C "student@example.com"
```

Sklonowanie repozytorium przez SSH:

``` bash
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
```

### Gałęzie

``` bash
git checkout main
git checkout grupa
git checkout -b KD232144
```

### Git hook

``` bash
#!/bin/sh
prefix="KD232144"
if ! grep -q "^$prefix" "$1"; then
 echo "Commit message musi zaczynać się od $prefix"
 exit 1
fi
```

------------------------------------------------------------------------

# Zajęcia 02 -- Docker

## Instalacja

``` bash
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version
```

## Test obrazów

``` bash
docker run hello-world
docker run busybox
docker run ubuntu
docker run mariadb
```

``` bash
docker images
```

## Busybox

``` bash
docker run -it busybox sh
uname -a
```

## Ubuntu

``` bash
docker run -it ubuntu bash
ps -ef
```

Na hoście:

``` bash
ps aux | grep docker
```

## Dockerfile

``` dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y git

WORKDIR /app


```

Budowanie:

``` bash
docker build -t myimage .
docker run -it myimage bash
```

Czyszczenie:

``` bash
docker ps -a
docker container prune
docker image prune
```

------------------------------------------------------------------------

# Zajęcia 03 -- Dockerfile jako etap CI

## Repozytorium

``` bash
git clone https://github.com/Humanizr/Humanizer.git
```

## Build lokalny

``` bash
sudo apt install dotnet-sdk-10.0
dotnet restore
dotnet build
dotnet test
```

## Build w kontenerze

``` bash
docker run -it mcr.microsoft.com/dotnet/sdk:10.0 bash
```

W kontenerze:

``` bash
git clone https://github.com/Humanizr/Humanizer.git
cd Humanizer
dotnet restore
dotnet build
dotnet test
```

## Dockerfile build

``` dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0

WORKDIR /src
COPY . .

RUN dotnet restore
RUN dotnet build
```

## Dockerfile test

``` dockerfile
FROM humanizer-build

WORKDIR /src
RUN dotnet test
```

------------------------------------------------------------------------

# Zajęcia 04 -- Woluminy, sieci, Jenkins

## Woluminy

``` bash
docker volume create humanizer-in
docker volume create humanizer-out
```

``` bash
docker run --rm -v humanizer-in:/data alpine/git clone https://github.com/Humanizr/Humanizer.git /data
```

``` bash
docker run -it -v humanizer-in:/src -v humanizer-out:/out mcr.microsoft.com/dotnet/sdk:10.0 bash
```

Build:

``` bash
cd /src
dotnet build
```

## Sieci

``` bash
docker network create lab-net
```

iperf:

``` bash
apt install -y iperf3
iperf3 -s
iperf3 -c IP_SERWERA
```

## SSH w kontenerze

``` bash
apt install openssh-server
service ssh start
ssh student@localhost -p 2222
```

## Jenkins

``` bash
docker network create jenkins
```

``` bash
docker run -d --name jenkins-docker --privileged docker:dind
```

``` bash
docker run -d -p 8080:8080 --name jenkins jenkins/jenkins:lts
```

Hasło administratora:

``` bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Panel:

http://IP_SERWERA:8080

------------------------------------------------------------------------

# Podsumowanie

Podczas laboratoriów skonfigurowano środowisko pracy z Git i SSH,
poznano podstawy konteneryzacji w Dockerze oraz zastosowano Dockerfile
do budowania oprogramowania w powtarzalnym środowisku CI. W ostatnim
etapie uruchomiono Jenkins w kontenerze oraz wykorzystano woluminy i
sieci Docker.
