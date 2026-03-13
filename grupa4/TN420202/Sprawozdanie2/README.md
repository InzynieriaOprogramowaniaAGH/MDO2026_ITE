# Sprawozdanie 1 

## 1. Instalacja Dockera

W celu przyspieszenia procesu instalacji Dockera zostało wykorzystane AI.

Treść zapytania:

"Pomóż mi zainstalować dockera na Ubuntu zgodnie z dokumentacją"

```bash
sudo apt remove docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc -y

sudo apt update
sudo apt install ca-certificates curl gnupg -y

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Weryfikacja odpowiedzi:
```bash
sudo systemctl status docker
docker --version
```
![Sprawdzenie Dockera 1](Spr_dockera1.png)

![Sprawdzenie Dockera 2](Spr_dockera2.png)

## 2. Docker Hub

```bash
docker login
```
![Logowanie](logowanie.png)

## 3. Obrazy

Pobrano obraz hello-world i sprawdzono działanie.

```bash
docker pull hello-world
docker run hello-world
```

![Obraz hello-world](hello-world.png)

Następnie pobrano resztę obrazów.

```bash
docker pull busybox
docker pull ubuntu
docker pull mariadb
docker pull mcr.microsoft.com/dotnet/runtime:8.0
docker pull mcr.microsoft.com/dotnet/aspnet:8.0
docker pull mcr.microsoft.com/dotnet/sdk:8.0
```

Sprawdzono ich rozmiary.

```bash
docker images
```

![Sprawdzenie rozmiaru obrazów](Spr_obrazow.png)

## 4. Busybox

```bash
docker run busybox
```

![Uruchomienie kontenera](run_busybox.png)

```bash
docker run -it busybox sh
```

![Wejście interaktywne](busybox_interaktywnie.png)

## 5. System w kontenerze

```bash
docker run -it ubuntu bash
```

![PID1](ubuntu_pid1.png)

```bash
docker ps
docker top <container_id>
```

![Procesy](procesy.png)

```bash
apt update
apt upgrade -y
exit
```

![Pakiety](update_pakietow.png)

## 6. Własny Dockerfile

```dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
```

```bash
docker build -t tn420202-sprawozdanie2 .
```

![Build](docker_build.png)

```bash
docker run -it --name tn420202-repo tn420202-sprawozdanie2
```

![Run](docker_run.png)

## 7. Pokazanie kontenerów

```bash
docker ps -a
``` 

![Kontenery](Kontenery.png)

## 8. Czyszczenie obrazów

```bash
docker container prune -f
docker image prune -a -f
docker ps -a
docker images
```
![Po wyczyszczeniu](po_czyszczeniu.png)