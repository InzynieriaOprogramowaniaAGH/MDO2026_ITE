# Sprawozdanie 3 - Dockerfiles, kontener jako definicja etapu

**Student:** Wilhelm Pasterz

**Indeks:** 416619

**Kierunek:** ITE

**Grupa: 5** 


## 1. Klonowanie repozytorium https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example?
![](./img/1.png)

## 2. Make oraz puszczenie testów po doinstalowaniu wymaganych zależności
![](./img/2.png)

## 3. Uruchomienie kontenera z TTY
![](./img/3.png)

## 4. Ponowienie procesu na poziomie kontenera

Sklonowanie repozytorium, Uruchomienie buildu i przeprowadzenie testów

![](./img/4.png)

## 5. Utworzenie Dockerfile’i

![](./img/5.png)

***Dockerfile.build***

![](./img/6.png)

***Dockerfile.test***

![](./img/7.png)

## 6. Uruchomienie Dockerfile’i

![](./img/8.png)

![](./img/9.png)

![](./img/10.png)

## 7. Sprawdzenie czy wszystko działa

![](./img/11.png)

## 8. ... co pracuje w takim kontenerze?

W kontenerze pracuje jeden, konkretny proces testowy odizolowany dockerem. Kontener używa hosta żeby zarządzać procesorem i RAMem.