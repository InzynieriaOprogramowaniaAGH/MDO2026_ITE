# Sprawozdanie z zajęć 13.03.2026
# Przygotowanie Dockera
1. Instalacja Dockera na VM
![install docker](Screeny/inst-docker.png)
2. Uruchomienie dockera po restarcie VM
![enable odcker](Screeny/enable-docker.png)
3. Sprawdzenie czy działa
![info](Screeny/docker-info.png)
# Zapoznanie się z przykładowymi obrazami dockera 

1. hello world (rm żeby się pozbyć od razu)
![hw](Screeny/hw.png)
2. to samo dla bb (gdzieś mi uciekł screenshot)
3. ubuntu to samo
![ub](Screeny/ubuntu-run.png)
4. mariadb używamy -d bo bo nie kończy się od razu + inny sposób sprawdzenia exitcode
![mdb](Screeny/mariadb.png)
![mdb-exit](Screeny/mariadb-exit.png)
5. Obrazy MS Dotnet są praktycznie identyczne
![.net](Screeny/.net.png)

6. Używamy docker images aby sprawdzić rozmiar obrazów
![images](Screeny/images-size.png)


# BusyBox

1. Uruchamiamy busybox używajac -d dla detached i sleep 3600 zeby działał przez godzinę
![bb](Screeny/bb-run-sleep.png)
![bb](Screeny/bb-docker-ps.png)
2. wejście w interaktywne
![bb](Screeny/docker-exec-bb.png)
# System w dockerze (Ubuntu)

1. Pobranie i uruchomienie Ubuntu przez dockera
2. Sprawdzenie PID
![ub-sys](Screeny/run-ubuntu-sys.png)
3. Pokazanie wszystkich procesów dockera
![grep](Screeny/procesy-dockera.png)
4. Apt upgrade i exit
![aptupgr](Screeny/wyjscie-z-ubuntu.png)


# Własny Dockerfile

Stworzenie Dockerfile
```
FROM ubuntu:22.04 
#konkretny tag a nie latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates git && \
    rm -rf /var/lib/apt/lists/*
#apt-get i install w jednym RUN

WORKDIR /opt/app

CMD ["bash"]
```
1. Zbudowanie własnego obrazu
![mojdocker](Screeny/build-gnimage.png)
2. Uruchomienie obrazu
![dockerrun](Screeny/uruchomienie-dockera-mojego.png)
3. Wewnątrz uruchomionego systemu: git --version git clone cd i ls
![gitclone](Screeny/klonowanie-na-obrazie.png)

# Pruning
1. Sprawdzenie uruchomionych i czyszczenie zakończonych
![dockerps-a](Screeny/dockerps-a.png)
![pruning1](Screeny/pruning.png)
2. Czyszczenie obrazów z pamięci
![pruning2](Screeny/pruning2.png)

# Wszystkie polecenia
```{bash}
sudo apt install docker.io
sudo systemctl enable --now docker
docker info
docker run --name hw --rm hello-world
echo "exit code hello-world: $?"
docker run --name bb --rm busybox echo "Hello from busybox"
echo "exit code busybox: $?"
docker run --name ub --rm ubuntu bash -c "echo Hello from ubuntu"
echo "exit code ubuntu: $?"
docker run -d --name mariadb-test -e MARIADB_ROOT_PASSWORD=example mariadb:latest
docker inspect -f '{{.State.ExitCode}}' mariadb-test
docker stop mariadb-test
docker rm mariadb-test
docker run --name dotnet-runtime --rm mcr.microsoft.com/dotnet/runtime:8.0 dotnet --info
echo "exit code runtime: $?"
docker run --name dotnet-aspnet --rm mcr.microsoft.com/dotnet/aspnet:8.0 dotnet --info
echo "exit code aspnet: $?"
docker run --name dotnet-sdk --rm mcr.microsoft.com/dotnet/sdk:8.0 dotnet --info
echo "exit code sdk: $?"

docker images

docker run -d --name bb-test busybox sleep 3600
docker ps --filter name=bb-test
docker exec -it bb-test sh
busybox --help | head -n 1
docker stop bb-test
docker rm bb-test

docker run -it --name ub-sys ubuntu bash
ps -p 1 -o pid,ppid,comm,args
apt upgrade -y
exit

ps aux | grep docker
docker ps

docker build -t gnimage .
docker run --rm -it --name gncontainer gnimage

git --version         
git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
cd MDO2026
ls

docker ps
docker ps -a
docker ps -aq -f status=exited | xargs -r docker rm

docker image prune -a

```