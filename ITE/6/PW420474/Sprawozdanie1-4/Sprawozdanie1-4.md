# Sprawozdanie 1-4

Przemysław Wrona 420474 ITE

## L1
Używam multipass do zarządzania VM, backend virtualbox, czyli to tak naprawdę przykrywka pod shell. Próbowałem żeby działało z hypervisorem windowsowym ale nie działało.
![alt text](1/1.png)
![alt text](1/2.png)
![alt text](1/3.png)
![alt text](1/4.png)
![alt text](1/5.png)
![alt text](1/6.png)
![alt text](1/7.png)
![alt text](1/8.png)
Zrobione troche pozniej \/ (Nie mam zdjęc jak ustawialem to bo to bylo dawno temu)
![alt text](1/9.png)

```bash
#!/bin/bash


COMMIT_MSG=$(head -n 1 "$1")

if [[ ! "$COMMIT_MSG" =~ ^"PW420474"  ]]; then
        echo "=!!="
        echo"COMMIT_MSG musi zawierac PW420474!"
        exit 1

fi

exit 0
```
```
FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
CMD ["/bin/bash"]

```


## L2

![alt text](2/1.png)
Tutaj male zamieszanie (pliki sdk,aspnet i runtime trzeba pobrac z mirrora microsoftowego)
![alt text](2/2.png)
![alt text](2/3.png)
![alt text](2/4.png)
![alt text](2/5.png)
![alt text](2/6.png)
![alt text](2/7.png)
![alt text](2/8.png)
![alt text](2/9.png)
![alt text](2/10.png)
![alt text](2/11.png)
![alt text](2/12.png)
![alt text](2/13.png)

```bash
FROM ubuntu:latest

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y git
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE L2
CMD ls -l L2
```

## L3

![alt text](<3/Zrzut ekranu 2026-03-24 034626.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 034826.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 035215.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 035344.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 035401.png>)
![alt text](3/oops.png)
![alt text](<3/Zrzut ekranu 2026-03-24 035433.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 040229.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 040918.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 041114.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 041201.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 041253.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 041414.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 041520.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 041908.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 042238.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 042252.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 042314.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 042639.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043002.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043205.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043340.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043502.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043548.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043759.png>) 
![alt text](<3/Zrzut ekranu 2026-03-24 043839.png>)
![alt text](<3/Zrzut ekranu 2026-03-24 045207.png>)

### Dyskusja L3
 * "czy program nadaje się do wdrażania i publikowania jako kontener, czy taki sposób interakcji nadaje się tylko do builda?"
    * Abralang to kompilator więc może mieć zastosowanie w cyklu budowania innych skonteneryzowanych aplikacji, ale do lokalnej deweloperki lepiej zainstalować systemowo
 * "jeżeli program miałby być publikowany jako kontener - czy trzeba go oczyszczać z pozostałości po buildzie?"
    * Tak trzeba, jedyne co potrzebne w image'u jest binarka w tym przypadku.
 * "A może dedykowany *deploy-and-publish* byłby oddzielną ścieżką (inne Dockerfiles)?"
    * Tak to docelowo byłaby jedna z możliwości, przy każdym bumpie semver by CI/CD pipeline automatycznie uploadował artefakty na serwer włącznie z binarkami systemowymi (poza image'ami dockerowymi).
 * "Czy zbudowany program należałoby dystrybuować jako pakiet, np. JAR, DEB, RPM, EGG?"
    * Docelowo statyczny ELF i EXE, dystrybucje na linuxie - PKGBUILD, DEB, RPM i AppImage oraz wszech-dostępne buid-it-yourself. (dystrybucje poza "build it yourself" nie są na ten moment dostępne dla tego kompilatora jako że to projekt hobbystyczny :D )

 


## L4 

![alt text](<4/Zrzut ekranu 2026-03-31 083059.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 083431.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 084001.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 084046.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 084547.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 085008.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 085846.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 090104.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 090306.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 090505.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 090558.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 090805.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 090805.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 091137.png>)
Czy sshd w dockerze ma sens? Tak ma niszowe zastosowanie, umiem sobie wyobrazić sytuację gdzie na przykład z jakiegoś powodu nie mogę usunąc kontenera (np.: jakiś serwer z danymi w ramie), ale jest problem z configiem. W takiej sytuacji zostaje nam ssh, lub docker attach, ale to jest nie dostępne jeżeli klucze do hosta ma tylko 1 osoba, a do serwera ma więcej osób, wtedy zostaje tylko ssh
![alt text](<4/Zrzut ekranu 2026-03-31 091639.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 091714.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 091824.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 092102.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 092310.png>)
![alt text](<4/Zrzut ekranu 2026-03-31 092540.png>)