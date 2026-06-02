# Przygotowanie woluminów do pracy

### Utworzenie woluminów

```bash
docker volume create volume-wejscie
docker volume create volume-wyjscie
```

Otrzymaliśmy dedykowane i odseparowane obszary pamięci, które mogą być używane przez kontenery do przechowywania danych. Woluminy te są trwałe i dane w nich przechowywane nie znikną po usunięciu kontenera.

### Sprawdzenie utworzonych woluminów

```bash
docker volume ls
```

![Stworzenie woluminów i sprawdzenie](</img/Screenshot 2026-05-01 at 19.30.00.png>)

### Sklonowanie ropozytorium z kodem do woluminu wejściowego

Użecie metody kontenera pomocniczego. Użycie tymczasowego kontenera z gitem do sklonowania repozytorium bezpośrednio do woluminu. Dzięki temu w kontenerze docelowym będzie już pobrane repozytorium, bez konieczności instalowania gita w kontenerze docelowym.

```bash
docker run --rm \
    -v volume-wejscie:/app \
    alpine/git \
    clone https://github.com/expressjs/express.git /app
```

- `-v volume-wejscie:/app` montuje wolumin `volume-wejscie` do katalogu `/app` w kontenerze,
- `alpine/git` to lekki obraz z gitem,
- `clone https://github.com/expressjs/express.git /app` klonuje repozytorium do katalogu `/app` w kontenerze.

![Klonoanie repozytorium do woluminu](</img/Screenshot 2026-05-01 at 20.28.28.png>)

### Sprawdzenie zawartości woluminu wejściowego

Teraz można podpiąć wolumin do tymczasowego kontenera i wyświetlić zawartość za pomocą `ls`.

```bash
docker run --rm -it -v volume-wejscie:/data alpine ls -l /data
```

![Sprawdzenie zawartości woluminu wejściowego](</img/Screenshot 2026-05-01 at 20.28.59.png>)

# Uruchomienie kontenera builder

W tym kontenerze zainstalujemy wszystkie zależności za pomocą `npm install` i otrzymane pliki przeniesiemy do woluminu wyjściowego.

```bash
docker run -it --rm \
    -v volume-wejscie:/wejscie \
    -v volume-wyjscie:/wyjscie \
    node:20-slim \
    bash
```

![Uruchomienie kontenera builder](</img/Screenshot 2026-05-01 at 20.43.58.png>)

Jak widać `git` nie jest zainstalowany.

### Instalacja zależności

```bash
cd /wejscie
npm install
```

![Instalacja zależności](</img/Screenshot 2026-05-01 at 20.45.59.png>)

### Skobiowanie plików do woluminu wyjściowego

```bash
cp -r ./* /wyjscie
```

![Skopiowanie plików do woluminu wyjściowego](</img/Screenshot 2026-05-01 at 20.47.48.png>)

![Sprawdzenie zawartości woluminu wyjściowego](</img/Screenshot 2026-05-01 at 20.50.32.png>)

# Uruchomienie kontenera docelowego i sprawdzenie działania aplikacji

```bash
docker run -it --rm -v volume-wyjscie:/app node:current bash
```

![Uruchomienie kontenera docelowego](</img/Screenshot 2026-05-01 at 20.54.16.png>)

# Eksponowanie portu i łączność miedzy kontenerami

## Uruchomienie serwera iperf3 w tle (odbiorca)

```bash
docker run -d --name iperf-server networkstatic/iperf3 -s
```

- `-d` uruchamia kontener w tle,
- `s` oznacza tryb serwera.

![Uruchomienie serwera iperf3](</img/Screenshot 2026-05-03 at 13.19.00.png>)

Domyślnie kontenery będą w sieci `bridge`, więc serwer iperf3 będzie dostępny pod adresem IP kontenera. Ale nie działa DNS.

### Sprawdzenie adresu IP serwera iperf3

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
```

lub

```bash
docker inspect iperf-server | grep IPAddress
```

![Sprawdzenie adresu IP serwera iperf3](</img/Screenshot 2026-05-03 at 13.24.47.png>)

## Uruchomienie klienta iperf3, połączenie z serwerem i pomiar przepustowości

### Uruchomienie klienta iperf3 i sprawdzenie przepustowości

```bash
docker run -it --rm networkstatic/iperf3 -c 172.17.0.2
```

![Uruchomienie klienta iperf3 i pomiar przepustowości](</img/Screenshot 2026-05-03 at 13.40.36.png>)

### Uruchomienie interaktywnego klienta iperf3 i sprawdzenie przepustowości (ubuntu)

```bash
docker run -it --rm --name klient ubuntu bash
apt update
apt install iperf3 -y
iperf3 -c 172.17.0.2
```

![Uruchomienie interaktywnego klienta iperf3 i pomiar przepustowości](</img/Screenshot 2026-05-03 at 13.50.33.png>)

## Stworzenie sieci typu bridge i podłączenie do niej kontenerów z wykorzystaniem DNS

### Stworzenie sieci typu bridge

```bash
docker network create siec-laby
docker network ls
```

![Stworzenie sieci typu bridge](</img/Screenshot 2026-05-03 at 13.55.50.png>)

### Podłączenie kontenerów do sieci

```bash
docker run -d --name iperf-server-dns --network siec-laby  networkstatic/iperf3 -s
docker run -it --rm --network siec-laby networkstatic/iperf3 -c iperf-server-dns
```

- `--network siec-laby` podłącza kontener do sieci `siec-laby`,

W sieci user-defined bridge DNS działa, więc można użyć nazwy kontenera `iperf-server-dns` zamiast adresu IP.

![Podłączenie kontenerów do sieci i pomiar przepustowości](</img/Screenshot 2026-05-03 at 14.01.22.png>)

Do wyświetlenia informacji o sieci: `docker network inspect siec-laby`

## Łączenie się z serverem spoza kontenera

### Wystartowanie serwera iperf3 z mapowaniem portu

```bash
docker run -d --rm --name server-exposed -p 5201:5201 networkstatic/iperf3 -s
```

### Test z hosta

```bash
iperf3 -c localhost
```

![Test z hosta](</img/S creenshot 2026-05-03 at 14.10.20.png>)

# Usługi w rozumieniu systemu, kontenera i klastra

## Uruchomienie kontenera z mapowaniem portu i instalacja serwera ssh

```bash
docker run -it -p 2222:22 --name ubuntu-ssh ubuntu:latest
apt update
apt-get install openssh-server -y
```

![Uruchomienie kontenera z mapowaniem portu i instalacja serwera ssh](</img/Screenshot 2026-05-06 at 20.22.13.png>)

## Umożliwienie logowania się do na konto root hasłem

```bash
mkdir /var/run/sshd
passwd root # Qwerty123!@#
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```

![Umożliwienie logowania się do na konto root hasłem](</img/Screenshot 2026-05-06 at 20.26.09.png>)

## Uruchomienie serwera ssh i zalogowanie się do niego z hosta

```bash
/usr/sbin/sshd -D &
```

```bash
ssh root@localhost -p 2222
```

![Uruchomienie serwera ssh i zalogowanie się do niego z hosta](</img/Screenshot 2026-05-06 at 20.28.23.png>)

# Przygotowanie do uruchomienia serwera Jenkins

## Stworzenie sieci

```bash
docker network create jenkins
```

## Uruchomienie pomocnika DIND

```bash
docker run --name jenkins-docker --rm --detach \
    --privileged --network jenkins \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume jenkins-docker-certs:/certs \
    --volume jenkins-data:/var/jenkins_home \
    docker:dind
```

- `--privileged` nadaje kontenerowi uprawnienia administratora na hoście (wymagane, by Docker mógł działać wewnątrz Dockera).

- `--env DOCKER_TLS_CERTDIR=/certs` włącza szyfrowanie TLS i wskazuje, gdzie mają być generowane certyfikaty bezpieczeństwa.

![Uruchomienie pomocnika DIND](</img/Screenshot 2026-05-07 at 11.16.22.png>)

## Uruchomienie właściwego serwera Jenkins

```bash
docker run --name jenkins-blueocean --rm --detach \
    --network jenkins --env DOCKER_HOST=tcp://jenkins-docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
    --publish 8080:8080 --publish 50000:50000 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    jenkins/jenkins:lts-jdk17
```

![Uruchomienie właściwego serwera Jenkins](</img/Screenshot 2026-05-07 at 11.23.02.png>)

## Sprawdzenie działania i logów serwera

W celu uzyskania hasła do pierwszego logowania:

```bash
docker logs jenkins-blueocean
```

![Sprawdzenie logów serwera Jenkins](</img/Screenshot 2026-05-07 at 11.26.01.png>)
