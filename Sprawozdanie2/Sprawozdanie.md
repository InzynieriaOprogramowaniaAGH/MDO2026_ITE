# Sprawozdanie - Zajęcia 02

---

## Instalacja Docker

```bash
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker
docker --version
docker run hello-world
```

![Instalacja Docker](instalacja-docker.png)
![Dodanie użytkownika do grupy docker](dodanie-uzytkownika-do-dockera.png)

---

## Logowanie do Docker Hub

```bash
docker login
```

![Logowanie Docker Hub](docker-login.png)

---

## Obrazy i kontenery

```bash
docker pull hello-world
```
![hello-world](docker-hello-world.png)

```bash
docker pull busybox
```
![busybox](docker-busy-box.png)

```bash
docker pull ubuntu
```
![ubuntu](docker-ubuntu.png)

```bash
docker pull mariadb
```
![mariadb](docker-mariadb.png)

---

## Interaktywny busybox

```bash
docker run -it busybox /bin/sh
uname -a
exit
```
![busybox interaktywnie](busybox-interaktywny.png)

---

## System w kontenerze

```bash
docker run -it ubuntu /bin/bash
ps aux
apt update
exit
```
![ubuntu kontener](ubuntu-interaktywny.png)

---

## Dockerfile

```dockerfile
FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y git curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
CMD ["/bin/bash"]
```

```bash
docker build -t sprawozdanie2 .
docker run -it sprawozdanie2 /bin/bash
ls -la /workspace
```
![build dockerfile](docker-build.png)
![uruchomienie dockerfile](docker-run-wlasny.png)

---

## Czyszczenie

```bash
docker ps -a
docker container prune -f
docker images
docker image prune -f
```
![czyszczenie kontenerów i obrazów](docker-czyszczenie.png)