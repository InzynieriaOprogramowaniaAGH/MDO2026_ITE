# Sprawozdanie z lab2 - Git, Docker
**Autor:** Aleksandra Duda, grupa 2

## Cel
Na zajęciach laboratoryjnych zapoznałam się z konteneryzacją w Dockerze, w szczególności z prawidłową instalacją i konfiguracją środowiska Docker w systemie Linux, zarządzaniu obrazami z DockerHub, zrozumieniu cyklu życia kontenera i wykorzystaniu pliku Dockerfile.

## Zestawienie środowiska skonteneryzowanego
1. Zainstalowałam Docker w systemie linuksowym, użwając repozytorium dystrybucji (docker.io w ubuntu) i niestosując Snapa i Flat Pak
![alt text](image-1.png)
![alt text](image-2.png)
![alt text](image-3.png)

2. Zarejestrowałam się w DockerHub i zapoznałam z sugerowanymi obrazami
![alt text](image.png)

Następnie zalogowałam się w terminalu:
![alt text](image-4.png)

Sprawdziłam czy docker działa:
![alt text](image-5.png)
![alt text](image-6.png)

3. Zapoznałam się z obrazami hello-world, busybox, ubuntu lub fedora, mariadb, runtime, aspnet i sdk dla Microsoft .NET uruchamiając je, sprawdzając ich rozmiary i sprawdzając kod wyjścia. Wykorzystałam komende docker run - jak nie ma obrazu na dysku to Docker sam go pobierze i uruchomi.
Zrzuty ekranów uruchomienia trzech obrazów:
![alt text](image-7.png)
![alt text](image-8.png)

Sprawdziłam rozmiary obrazów:
![alt text](image-9.png)
Jak widać hello-world zajmuje najmniej miejsca, podczas gdy sdk zajmuje go zdecydowanie najwięcej.

Na koniec sprawdziłam kod wyjścia (poleceniem docker ps -a):
![alt text](image-10.png)
Większość uruchomionych kontenerów zakończyła pracę z kodem 0, co oznacza poprawne wykonanie. Kontener mariadb jako jedyny posiada status up, ponieważ jest to serwer bazy danych uruchomiony w tle (-d) i jego proces nie kończy się automatycznie tylko pozostaje aktywny.

4. Uruchomiłam kontener z obrazu busybox.
Efekt uruchomienia:
![alt text](image-11.png)

Następnie podłączyłam się do kontenera interaktywnie (flagi -i, -t) i wywołałam numer wersji:
![alt text](image-12.png)
Na zrzucie ekranu widać, że wersja to BusyBox v1.37.0.

5. Uruchomiłam "system w kontenerze" - kontener z obrazu ubuntu.
Ponownie zastosowałam flagi -i, -t żebym mogła wydawać polecenia wewnątrz. PID1 w kontenerze:
![alt text](image-13.png)

Procesy dockera na hoście. W tym celu wykonałam polecenie 'ps -ef | grep bash' w drugim terminalu. Tutaj proces bash ma zupełnie inny, dużo wyższy numer PID niż 1 (wynika to z izolacji przestrzeni nazw i że kontener nie jest osobnym systemem operacyjnym, tylko odizolowanym procesem współdzielącym jądro z systemem nadrzędnym):
![alt text](image-14.png)

Zaktualizowałam pakiety i wyszłam:
![alt text](image-15.png)

6. Stworzyłam, zbudowałam i uruchomiłam prosty plik Dockerfile bazujący na wybranym systemie i sklonowałam w nim repozytorium:

![alt text](image-18.png)
![alt text](image-16.png)
![alt text](image-17.png)
Znajduje się na liście:
![alt text](image-19.png)

Następnie upewniłam się, że obraz będzie miał gita, uruchomiłam w trybie interaktywnym i zweryfikowałam, że jest tam ściągnięte nasze repozytorium:
![alt text](image-20.png)
Znajdują się tam pliki repozytorium i ukryty folder .git tak jak powinny.

7. Uruchomione kontenery, wyczyściłam zakończone:
![alt text](image-21.png)
![alt text](image-22.png)

8. Wyczyściłam obrazy przechowywane w lokalnym magazynie:

![alt text](image-23.png)

Zweryfikowałam czy magazyn jest czysty:
![alt text](image-24.png)

Treść Dockerfile:
```dockerfile
#lekki obraz bazowy
FROM alpine:latest

#instalacja gita i czyszczenie cache
RUN apk update && apk add --no-cache git

#ustalenie folderu roboczego
WORKDIR /app

#sklonowanie repozytorium do bieżącego folderu
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

#domyślne polecenie po startcie kontenera - odpalanie shella, bez tego kontener by się wyłączył
CMD ["/bin/sh"]
```

Polecenie history:
```bash
  117  mkdir grupa2/AD_420339/Sprawozdanie2
  118  sudo apt update
  119  sudo apt install docker.io -y
  120  sudo systemctl start docker
  121  sudo systemctl enable docker
  122  docker login
  123  docker login -u ola0duda
  124  sudo systemctl status docker
  125  docker --version
  126  docker run hello-world
  127  sudo docker run hello-world
  128  sudo docker run busybox echo "test"
  129  sudo docker run ubuntu cat /etc/issue
  130  sudo docker run mariadb
  131  echo $?
  132  sudo docker run --name testbazy -e MARIADB_ROOT_PASSWORD=admin -d mariadb
  133  sudo docker ps
  134  sudo docker run mcr.microsoft.com/dotnet/runtime
  135  sudo docker run mcr.microsoft.com/dotnet/aspnet
  136  sudo docker run mcr.microsoft.com/dotnet/sdk dotnet --version
  137  sudo docker images
  138  sudo docker ps -a
  139  sudo docker run busybox
  140  sudo docker run busybox echo "hello busybox"
  141  sudo docker run -it busybox sh
  142  sudo docker run -it ubuntu bash
  143  sudo docker ps -a
  144  ls
  145  cd grupa2
  146  ls
  147  cd AD_420339/
  148  ls
  149  cd Sprawozdanie2
  150  sudo docker build -t obrazAD .
  151  sudo docker build -t obraz-ad .
  152  sudo docker images
  153  sudo docker run -it obraz-ad
  154  sudo docker ps -a
  155  sudo docker container prune
  156  sudo docker ps -a
  157  sudo docker stop mariadb
  158  sudo docker stop dc191037d38e
  159  sudo docker rm dc191037d38e
  160  sudo docker ps -a
  161  sudo docker image prune -a
  162  sudo docker images
  163  history
```
