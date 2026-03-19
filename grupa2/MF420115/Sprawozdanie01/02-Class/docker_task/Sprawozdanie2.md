# Sprawozdanie: Docker i Konteneryzacja
Autor: Maciej Fraś 

Data: 13 marca 2026 r.

Środowisko: Ubuntu 24.04.4 LTS (Virtual Machine / Hyper-V), Visual Studio Code (VSC)
1. Cel zajęć
Celem zajęć jest zestawienie środowiska skonteneryzowanego do pracy nad CI i potwierdzenie łączności/możliwośi utrzymywania kodu w repozytorium GitHub

2. Instalacja i konfiguracja środowiska
Zgodnie z zaleceniami, zainstalowano pakiet docker.io

![Instalacja DOcker](Screenshots/docker_instalacja.png)
![[Dodanie użytkownika do grupy docker]](Screenshots/helloworld_docker.png)

3. Eksploracja obrazów Docker Hub

![Pobranie obrazów](Screenshots/docker_images_controllers.png)
![Zestawienie obrazów](Screenshots/docker_images.png)

4. Interaktywny busybox

![](Screenshots/busybox_uruchomiony.png)

5. Izolacja procesów (PID 1)

![Izolowany proces](Screenshots/docker_bash_pid.png)

6. Własny obraz (Dockerfile)

![Dockerfile](Screenshots/nanoDockerfile.png)

![docker build](Screenshots/docker_buildd.png)

![docker run](Screenshots/docker_run_it.png)

7. Czyszczenie

![Czyszczenie](Screenshots/docker_czysczenie_kontenerow.png)