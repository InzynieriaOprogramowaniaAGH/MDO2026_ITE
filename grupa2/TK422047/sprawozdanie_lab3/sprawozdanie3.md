# Sprawozdanie Lab3, Tomasz Kamiński


## Narzędzia i konfiguracja 
Ćwiczenie wykonano w środowisku **Ubuntu Server 24.04.4 LTS** uruchomionym na **VirtualBox**.

## Wybór oprogramowania
Do przeprowadzenia laboratorium wybrałem bibloteke C - **hiredis**, wykorzystuje ona Makefile oraz zawiera rozbudowany skrypt testowy test.sh wywoływany komendą make check.

https://github.com/redis/hiredis.git

![build](./img/image3.png)

## Build
 
![build](./img/build.png)

## Uruchomienie testow

![build](./img/testy.png)

![](./img/testy2.png)


## Uruchomienie interaktywnie kontenera

![](./img/image2.png)

Pobranie potrzebnych zaleznosci 

![](./img/image5.png)

Sklonowanie repo/Build wewnątrz kontenera

![](./img/image6.png)

Testy wewnątrz kontenera

![](./img/image7.png)

![](./img/image8.png)

## DockerFile

Zawartość Docker build

![](./img/poprawionydocker.png)

Zbudowanie Obrazu przy użyciu komendy 
sudo docker build -t hiredis-build -f Dockerfile.build .

![](./img/image9.png)

Zawartosc Docker test 

![](./img/image10.png)

Zbudowanie Obrazu

![](./img/image11.png)

Uruchomienie testu w kontenerze

![](./img/image13.png)

![](./img/image12.png)

Status kontenera 

![](./img/image14.png)

Kod wyjscia 0 potwierdza ze testy przeszły pomyślnie 