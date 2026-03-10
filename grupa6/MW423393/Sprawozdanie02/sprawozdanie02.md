# Sprawozdanie 02 - Git, Docker

**Data zajęć:** 03.03.2026 r.

**Imię i nazwisko:** Mateusz Wiech

**Nr indeksu:** 423393

**Grupa:** 6

**Branch:** MW423393

---

## 0. Środowisko

Ćwiczenie wykonano w środowisku linuksowym (Ubuntu Server 24.04.4 LTS) działającym na maszynie wirtualnej z wykorzystaniem klienta `git` (2.43.0) i `OpenSSH` (9.6p1). Połączenie z maszyną realizowano przez SSH. Repozytorium było obsługiwane z poziomu terminala oraz edytora Visual Studio Code.

---

## 1. Instalacja Docker

W tym celu wykorzystano polecenie `apt install docker.io`

![Instalacja Docker](./SS/apt_install_docker.png)

Dodano użytkownika do grupy `docker` i sprawdzono wersję Dockera.

![Docker sprawdzenie wersji](./SS/docker_check.png)

Sprawdzenie działania dokonano poprzez polecenie `docker run hello-world`

![Docker run hell-world](./SS/docker_run_hello_world.png)

Dodatkowo zalogowano się przy użyciu Personal Access Token.

![Docker login](./SS/docker_login.png)

---

## 2. Obrazy

Obrazy pobrano polceniem:

```
docker pull hello-world
docker pull busybox
docker pull ubuntu
docker pull mariadb
docker pull mcr.microsoft.com/dotnet/runtime
docker pull mcr.microsoft.com/dotnet/aspnet
docker pull mcr.microsoft.com/dotnet/sdk
```

![Docker pull](./SS/docker_pull.png)

Sprawdzenia wielkości pobranych obrazów można dokonać dzięki poleceniu `docker images`.

![Docker images](./SS/docker_images.png)

Uruchamianie kontenerów i sprawdzenie ich kodów wyjścia.

![Docker run](./SS/docker_run_echo.png)

`busybox` jest kontenerem interaktywnym - aby do niego wejść należy skorzystać z polecenia `docker run -it busybox sh`.

![busybox shell](./SS/busybox_shell.png)

Uruchomienie systemu `ubuntu` w kontenerze - sprawdzenie procesu PID1 oraz aktualizacja pakietów.

![Ubuntu shell](./SS/docker_run_ubuntu.png)

Procesy dockera na hoście:

![Docker ps](./SS/docker_ps.png)

---

# 3. Dockerfile

Treść utworzonego Dockerfile:

```
FROM ubuntu:latest

RUN apt update && apt install -y git ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
```

Budowanie obrazu:

![Docker build](./SS/docker_build.png)

Uruchomienie interaktywne obrazu:

![Docker run repo](./SS/docker_run_repo.png)

Repozytorium zostało poprawnie sklonowane.

---

# 4. Czyszczenie kontenerów i obrazów

Wyświetlenie zakończonych i uruchomionych kontenerów:

![Docker ps a](./SS/docker_ps_a.png)

Wyczyszczenie zakończonych kontenerów:

![Docker container prune](./SS/docker_container_prune.png)

Po tej operacji `docker ps -a` zwraca pustą listę.

Usuwanie lokalnych obrazów:

![Docker image prune](./SS/docker_image_prune.png)
![Docker image after](./SS/docker_images_after_prune.png)

Po usunięciu `docker images` zwraca pustą listę.