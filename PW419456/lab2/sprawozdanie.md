# Sprawozdanie - lab 2

**Piotr Walczak**
**419456**

## 1. Instalacja Dockera

- Zainstalowano Dockera zgodnie z zaleceniami z [instrukcji](https://docs.docker.com/engine/install/ubuntu/)

![](sprawozdanie-ss/devops_lab2_1.png)
## 2. Rejestracja w Docker Hub

- Utworzono konto na platformie [Docker Hub](https://hub.docker.com/)

![](sprawozdanie-ss/devops_lab2_2.png)

## 3. Pierwsze obrazy

- Sklonowano obrazy `hello-world`, `busybox`, `ubuntu`

![](sprawozdanie-ss/devops_lab2_3.png)

- Sprawdzono romiary sklonowanych obrazów

![](sprawozdanie-ss/devops_lab2_4.png)

- Uruchomiono obrazy

![](sprawozdanie-ss/devops_lab2_5.png)

## 4. Kontener `busybox`

- Uruchomiono kontener w trybie interaktywnym i sprawdzono numer wersji

![](sprawozdanie-ss/devops_lab2_6.png)

## 5. System w kontenerze (`ubuntu`)

- Sprawdzono proces o `PID` równym 1
- Zaktualizowano pakiety 

![](sprawozdanie-ss/devops_lab2_7.png)

## 6. Pierwszy `Dockerfile`

- Utworzono [`Dockerfile`](./Dockerfile)

```Dockerfile
FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git 

CMD ["/bin/bash"]
```

- Zbudowano i uruchomiono obraz
- Sprawdzono czy instalacja gita i sklonowanie repozytorium przebiegło pomyślnie

![](sprawozdanie-ss/devops_lab2_8.png)

## 7. Czyszczenie obrazów

- Wypisano wszystkie obrazy i je usunięto

![](sprawozdanie-ss/devops_lab2_9.png)
