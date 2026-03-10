# Sprawozdanie z laboratorium 2

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Instalacja Docker

### Instalacja Docker w systemie Linux

Zainstalowanie Dockera z repozytorium dystrybucji:

![Instalacja Docker](img/intalacja_docker.jpg)

Dodanie użytkownika do grupy `docker`:

![Dodanie do grupy docker](img/instalacja_docker_dodanie_do_grupy.jpg)

---

## 2. Docker Hub

### Logowanie do Docker Hub

Zalogowanie się do Docker Hub za pomocą polecenia `docker login`:

![Docker login](img/docker_login.jpg)

---

## 3. Obrazy Docker

### Zapoznanie z podstawowymi obrazami

Pobranie i uruchomienie obrazu `hello-world`:

![Hello World](img/testy_hello_world.jpg)

Uruchomienie pozostałych obrazów (`busybox`, `ubuntu`, `mariadb`, `aspnet`, `sdk`):

![Uruchomienie reszty obrazów](img/testy_uruchomienie_reszty_obrazow.jpg)

### Sprawdzenie rozmiarów obrazów

Sprawdzenie rozmiaru pobranych obrazów:

![Rozmiar obrazów](img/rozmiar_obrazow.jpg)

### Podłączenie interaktywne do busybox

Uruchomienie kontenera `busybox` w trybie interaktywnym i wywołanie numeru wersji:

![Busybox version](img/busybox_version.jpg)

---

## 4. System w kontenerze

### PID1 w kontenerze i procesy Docker na hoście

Uruchomienie kontenera `ubuntu` w trybie interaktywnym. Prezentacja procesu PID1 w kontenerze oraz procesów dockera na hoście:

![PID1 i procesy Docker](img/ubuntu_pid.jpg)

---

## 5. Dockerfile

### Utworzenie własnego Dockerfile

Utworzenie pliku `Dockerfile` bazującego na Ubuntu z zainstalowanym Git i sklonowanym repozytorium:

![Zawartość Dockerfile](img/dockerfile_content.jpg)

```dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git

WORKDIR /app

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE .

CMD ["/bin/bash"]
```

### Budowanie obrazu

Zbudowanie obrazu z własnego Dockerfile:

![Budowanie Dockerfile](img/budowanie_dockerfile.jpg)

### Uruchomienie i weryfikacja

Uruchomienie kontenera w trybie interaktywnym i weryfikacja że sklonowane repozytorium jest dostępne:

![Działający git w kontenerze](img/dzialajacy_git_w_kontenerze.png)

---

## 6. Zarządzanie kontenerami

### Wyświetlenie uruchomionych kontenerów

Pokazanie wszystkich kontenerów (uruchomionych i zakończonych):

![Wyświetlenie kontenerów](img/wyswietlenie_kontenerow.jpg)

### Czyszczenie zakończonych kontenerów

Usunięcie zakończonych kontenerów:

![Container prune](img/container_prune.jpg)

---
