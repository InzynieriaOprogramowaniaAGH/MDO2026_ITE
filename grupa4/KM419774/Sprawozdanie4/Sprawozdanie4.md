# DevOps Lab 4  
## Woluminy, sieci kontenerowe oraz uruchomienie Jenkins

### Krzysztof Mazur ITE

### Cel ćwiczenia

Celem ćwiczenia było zapoznanie się z dodatkowymi mechanizmami konteneryzacji:

- woluminami Docker
- sieciami kontenerowymi
- komunikacją między kontenerami
- uruchomieniem usługi SSH w kontenerze
- instalacją instancji Jenkins z wykorzystaniem Docker-in-Docker

---

## Zachowywanie stanu między kontenerami

### Utworzenie woluminów



```bash
docker volume create express_input
docker volume create express_output
docker volume ls
```
- Użyto kontenera pomocniczego alpine
- Zamontowano wolumin express_input
- Repozytorium zostało sklonowane bezpośrednio do woluminu

Kod nie znajdował się w kontenerze - znajdował się w woluminie, dzięki czemu był dostępny dla innych kontenerów.

![Opis obrazka](img/L4_1.png)

Klonowanie repozytorium na wolumin wejściowy
```bash
docker run --rm \
  -v express_input:/data \
  alpine \
  sh -c "apk add git && git clone https://github.com/expressjs/express.git /data/express"
  ```

![Opis obrazka](img/L4_2.png)

Uruchomienie kontenera builder
```bash
docker run -it \
  -v express_input:/input \
  -v express_output:/output \
  node:20 bash
```

```bash
apt update
apt install -y git

cd /input
git clone https://github.com/expressjs/express.git

cd express
npm install

cp -r node_modules /output/
```

![Opis obrazka](img/L4_4.png)

![Opis obrazka](img/L4_7.png)

![Opis obrazka](img/L4_8.png)

Artefakty builda zostały zapisane na woluminie wyjściowym.

## Sieci kontenerowe i pomiar przepustowości
Utworzenie sieci
```bash
docker network create labnet
```

![Opis obrazka](img/L4_9.png)

Serwer iperf

![Opis obrazka](img/L4_10.png)

```bash
docker run -it --name iperf_server --network labnet ubuntu bash
```

W kontenerze:
```bash
apt update
apt install -y iperf3 iproute2
ip a
iperf3 -s
```

Klient iperf
```bash
docker run -it --name iperf_client --network labnet ubuntu bash
```

![Opis obrazka](img/L4_11.png)

W kontenerze:
```bash
apt update
apt install -y iperf3 iproute2
ip a
iperf3 -c 172.20.0.2
iperf3 -c iperf_server
```
![Opis obrazka](img/L4_12.png)

Zbadano przepustowość komunikacji między kontenerami.

Połączenie z hosta
```bash
docker rm iperf_server

docker run -it \
  --name iperf_server \
  --network labnet \
  -p 5201:5201 \
  ubuntu bash
```

![Opis obrazka](img/L4_14.png)

W kontenerze:
```bash
apt update
apt install -y iperf3
iperf3 -s
```
Na hoście:
```bash
iperf3 -c localhost
iperf3 -c 172.20.0.2
```

![Opis obrazka](img/L4_16.png)

## Usługa SSH w kontenerze
```bash
docker run -it --name ssh_lab -p 2222:22 ubuntu bash
```
W kontenerze:
```bash
apt update
apt install -y openssh-server
passwd
service ssh start
```

Na hoście:
```bash
ssh root@localhost -p 2222
```

![Opis obrazka](img/L4_18.png)

Zalety:

- możliwość debugowania kontenera
- dostęp administracyjny
- integracja z legacy systemami

Wady:

- zwiększona powierzchnia ataku
- odejście od idei immutable container
- konieczność zarządzania użytkownikami i hasłami

## Instalacja Jenkins

Wolumin i sieć
```bash
docker volume create jenkins_home
docker network create jenkins
```
Uruchomienie Docker-in-Docker
```bash
docker run -d --name jenkins-dind \
  --network jenkins \
  --privileged \
  docker:24-dind
```

![Opis obrazka](img/L4_19.png)

Sprawdzenie:
```bash
docker ps
```
![Opis obrazka](img/L4_20.png)

Uruchomienie Jenkins
```bash
docker run -d --name jenkins \
  --network jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -e DOCKER_HOST=tcp://jenkins-dind:2375 \
  jenkins/jenkins:lts
```
Sprawdzenie:
```bash
docker ps
docker logs -f jenkins
docker exec -it jenkins bash
```
![Opis obrazka](img/L4_21.png)
![Opis obrazka](img/L4_22.png)

Po uruchomieniu dostęp do panelu Jenkins uzyskano przez przeglądarkę:

http://192.168.1.104:8080

![Opis obrazka](img/L4_23.png)
