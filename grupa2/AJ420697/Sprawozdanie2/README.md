# Sprawozdanie - DevOps - Lab 2 - Andrzej Janaszek

## 1. Instalacja Dockera


Update pakietów \
`sudo apt update`

Instalacja \
`sudo apt install docker.io`

Uruchomienie testowego obrazu \
`sudo docker run hello-world`

Sprawdzenie wersji Dockera
```
andrzej@ubuntuserver24:~/DEVOPS$ docker --version
Docker version 28.2.2, build 28.2.2-0ubuntu1~24.04.1
```

![Uruchomienie obrazu hello-world](./img/img01_test_installation_hello_docker.png)

## 3. Zapoznanie z obrazami
### Pobrane obrazy i ich rozmiar `sudo docker images`
![](./img/img02_docker_images.png)

### Kontenery po uruchomieniu i ich statusy (kody wyjścia). Jeden kontener ma status 1 ponieważ nie została podana zmienna środowiskowa odpowiadająca za hasło roota (mariadb)

![](./img/img03_containers.png)

## 4.Uruchomienie busybox

### Efekt uruchomienia
![](./img/img04_docker_run_busybox.png)

### Podłączenie interaktywne i sprawdzenie wersji
![](./img/img05_busybox_interactive_version.png)

## 5. System (ubuntu) w kontenerze
### Uruchomienie interaktywne
![](./img/img06_ubuntu_pid.png)

### Procesy dockera na Hoscie
![](./img/img07_host_docker_processes.png)

### Update pakietów
![](./img/img08_apt_update.png)

## 6. Własny obraz
### Zbudowanie obrazu
![](./img/img09_custom_image.png)

### Sprawdzenie repo i gita
![](./img/img10_interactive_git_check.png)

## 7. Uruchomione kontenery
![](./img/img11_containers_and_prune.png)

## 8. Wyczyszczenie obrazów
![](./img/img12_docker_image_prune.png)