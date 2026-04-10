## 1. Zachowywanie stanu między kontenerami
 
### 1.1. Przygotowanie woluminów
 
Przed uruchomieniem kontenerów utworzono dwa woluminy Docker: wejściowy (`vol_input`) oraz wyjściowy (`vol_output`).
 
```bash
docker volume create vol_input
docker volume create vol_output
docker volume ls
```
 
Poprawność operacji potwierdzono poleceniem `docker volume ls`, które wykazało obecność obu woluminów na liście.
 
![Woluminy](IMG/Zrzut%20ekranu%202026-04-09%20183005.png)

---
 
### 1.2. Metoda 1 - Bind mount z lokalnym katalogiem (bez Gita w kontenerze)
 
Repozytorium Express.js zostało sklonowane **na hoście** (gdzie dostępny jest Git), a następnie podmontowane do kontenera jako bind mount:
 
```bash
git clone https://github.com/expressjs/express ./express-src
 
docker run -it \
  -v ./express-src:/input \
  -v vol_output:/output \
  node:18 bash
```
 
Wewnątrz kontenera uruchomiono instalację zależności i testy:
 
```bash
cd /input
npm install
npm test
```
 
![Uruchomienie kontenera z bind mount](IMG/Zrzut%20ekranu%202026-04-09%20183619.png)
 
![Pull obrazu node:18 i wejście do kontenera](IMG/Zrzut%20ekranu%202026-04-09%20184040.png)
 
Wszystkie 1246 testów przeszło pomyślnie:
 
![1246 testów passing - metoda 1](IMG/Zrzut%20ekranu%202026-04-09%20184254.png)
 
Wyniki buildu skopiowano na wolumin wyjściowy, a następnie zweryfikowano ich trwałość po wyłączeniu kontenera:
 
```bash
cp -r /input/node_modules /output/
cp /input/package.json /output/
exit
 
docker run --rm -v vol_output:/output node:18 ls /output
```
 
![Persystencja danych na woluminie wyjściowym](IMG/Zrzut%20ekranu%202026-04-09%20184415.png)
 
Dane (`node_modules`, `package.json`) przetrwały wyłączenie kontenera, co potwierdza poprawne działanie woluminu.
 
---
 
### 1.3. Metoda 2 - Klonowanie wewnątrz kontenera (Git w kontenerze)
 
W drugiej iteracji repozytorium sklonowano bezpośrednio wewnątrz kontenera, uprzednio instalując Gita:
 
```bash
docker run -it \
  -v vol_input:/input \
  -v vol_output:/output \
  node:18 bash
 
# Wewnątrz kontenera:
apt-get update && apt-get install -y git
git clone https://github.com/expressjs/express /input/express
cd /input/express
npm install
npm test
cp -r /input/express/node_modules /output/
cp /input/express/package.json /output/
```
 
![Uruchomienie kontenera z woluminami Docker](IMG/Zrzut%20ekranu%202026-04-09%20184640.png)
 
![Klonowanie repo wewnątrz kontenera](IMG/Zrzut%20ekranu%202026-04-09%20184741.png)
 
![1246 testów passing - metoda 2](IMG/Zrzut%20ekranu%202026-04-09%20184802.png)
 
![Kopiowanie wyników na wolumin wyjściowy](IMG/Zrzut%20ekranu%202026-04-09%20185057.png)
 
---
 
### 1.4. Dyskusja:
 
Instrukcja `RUN --mount` w Dockerfile pozwala na tymczasowe podmontowanie zasobów podczas budowania obrazu, bez trwałego zapisywania ich w warstwach obrazu. Przykład:
 
```dockerfile
# syntax=docker/dockerfile:1
FROM node:18
RUN --mount=type=bind,source=./express-src,target=/input \
    cd /input && npm install && cp -r node_modules /app/
```
 
**Ograniczenia:** `RUN --mount` montuje zasoby tylko na czas wykonania danej instrukcji i nie pozwala na zapis wyników poza obraz. Dane wyjściowe trafiają do warstw obrazu, a nie do zewnętrznych woluminów Docker.
 
---
 
## 2. Eksponowanie portów i łączność między kontenerami
 
### 2.1. Test na domyślnej sieci bridge
 
Uruchomiono kontener serwera iperf3 na domyślnej sieci Docker (`bridge`), sprawdzono jego adres IP, a następnie podłączono klienta:
 
```bash
docker run -d --name iperf-server networkstatic/iperf3 -s
docker inspect iperf-server | grep IPAddress
# IP serwera: 172.17.0.2
 
docker run -it --name iperf-client --network bridge networkstatic/iperf3 -c 172.17.0.2
```
 
Osiągnięta przepustowość: **~43.6 Gbits/sec**.
 
![Test iperf3 na domyślnej sieci - wynik](IMG/Zrzut%20ekranu%202026-04-09%20191417.png)
 
---
 
### 2.2. Własna sieć mostkowa z rozwiązywaniem nazw
 
Utworzono dedykowaną sieć `my-net`, która umożliwia rozwiązywanie nazw kontenerów przez wbudowany DNS Dockera:
 
```bash
docker network create my-net
docker run -d --name iperf-server --network my-net networkstatic/iperf3 -s
docker inspect iperf-server | grep IPAddress
# IP serwera: 172.18.0.2
 
docker run -it --name iperf-client --network my-net networkstatic/iperf3 -c iperf-server
```
 
Klient połączył się używając **nazwy kontenera** (`iperf-server`) zamiast adresu IP - możliwe wyłącznie w dedykowanych sieciach Docker (w domyślnej sieci `bridge` DNS nie działa między kontenerami).
 
Osiągnięta przepustowość: **~32.5 Gbits/sec**.
 
![Test iperf3 na sieci my-net z rozwiązywaniem nazw](IMG/Zrzut%20ekranu%202026-04-09%20192009.png)
 
---
 
### 2.3. Połączenie spoza kontenera - z hosta (Ubuntu)
 
Wyeksponowano port 5201 na hoście i przetestowano połączenie bezpośrednio z systemu hosta:
 
```bash
docker run -d --name iperf-server --network my-net -p 5201:5201 networkstatic/iperf3 -s
iperf3 -c localhost -p 5201
```
 
Osiągnięta przepustowość: **~13.7 Gbits/sec**. Spadek względem komunikacji kontener-kontener wynika z dodatkowej warstwy translacji portów (`iptables` NAT).
 
![Test iperf3 z hosta Ubuntu](IMG/Zrzut%20ekranu%202026-04-09%20193308.png)
 
---
 
### 2.4. Połączenie spoza hosta - z systemu Windows (host fizyczny)
 
VM działa w trybie NAT w VirtualBox. Skonfigurowano przekierowanie portów: `127.0.0.1:5201 → 10.0.2.15:5201`. Na Windowsie uruchomiono `iperf3.exe`:
 
```cmd
iperf3.exe -c 127.0.0.1 -p 5201
```
 
Osiągnięta przepustowość: **~521 Mbits/sec**. Znaczący spadek przepustowości względem poprzednich testów wynika z przejścia przez stos sieciowy VirtualBox NAT, który dodaje istotny narzut.
 
![Test iperf3 z Windowsa przez NAT](IMG/Zrzut%20ekranu%202026-04-09%20194827.png)
 
### Podsumowanie przepustowości
 
| Scenariusz | Przepustowość |
|---|---|
| Kontener → Kontener (domyślna sieć bridge) | ~43.6 Gbits/sec |
| Kontener → Kontener (sieć my-net) | ~32.5 Gbits/sec |
| Host Ubuntu → Kontener (port forwarding) | ~13.7 Gbits/sec |
| Windows → Kontener (VirtualBox NAT) | ~521 Mbits/sec |
 
---
 
## 3. Usługi w rozumieniu systemu, kontenera i klastra - SSHD
 
### 3.1. Konfiguracja SSHD w kontenerze Ubuntu
 
Uruchomiono kontener Ubuntu z wyeksponowanym portem SSH, a następnie zainstalowano i skonfigurowano serwer SSH:
 
```bash
docker run -it --name ssh-container -p 2222:22 ubuntu bash
 
# Wewnątrz kontenera:
apt-get update && apt-get install -y openssh-server
mkdir /run/sshd
echo 'root:haslo123' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
/usr/sbin/sshd -D &
```
 
![Instalacja openssh-server w kontenerze](IMG/Zrzut%20ekranu%202026-04-09%20195237.png)
 
### 3.2. Połączenie z kontenerem przez SSH
 
Z drugiego terminala na hoście nawiązano połączenie SSH z kontenerem:
 
```bash
ssh root@localhost -p 2222
```
 
![Połączenie SSH z kontenerem Ubuntu](IMG/Zrzut%20ekranu%202026-04-09%20202641.png)
 
Połączenie zakończyło się sukcesem - zalogowano się do powłoki kontenera jako `root@598a4ee58e0a`.
 
### 3.3. Zalety i wady SSH w kontenerach
 
**Zalety:** znajoma metoda dostępu, przydatna przy migracji aplikacji legacy do kontenerów.
 
**Wady:** sprzeczna z filozofią konteneryzacji (jeden proces = jeden kontener), zwiększa powierzchnię ataku i utrudnia monitoring. Docker dostarcza dedykowane narzędzia: `docker exec`, `docker logs`, `docker cp`.
 
---
 
## 4. Przygotowanie i uruchomienie serwera Jenkins
 
### 4.1. Przygotowanie środowiska
 
Utworzono dedykowaną sieć oraz woluminy dla Jenkinsa:
 
```bash
docker network create jenkins
docker volume create jenkins-docker-certs
docker volume create jenkins-data
```
 
### 4.2. Uruchomienie kontenera Docker-in-Docker (DIND)
 
![Uruchomienie kontenera DIND](IMG/Zrzut%20ekranu%202026-04-10%20012119.png)
 
### 4.3. Budowa własnego obrazu Jenkinsa
 
![Dockerfile w edytorze VS Code](IMG/Zrzut%20ekranu%202026-04-10%20012633.png)
 
Zbudowano obraz:
 
```bash
docker build -t myjenkins-blueocean:2.541.3-1 .
```
 
![Pomyślne zbudowanie obrazu myjenkins-blueocean](IMG/Zrzut%20ekranu%202026-04-10%20012924.png)
 
### 4.4. Uruchomienie kontenera Jenkins
 
```bash
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.541.3-1
```
 
### 4.5. Weryfikacja działających kontenerów
 
```bash
docker ps -a
```
 
![Działające kontenery Jenkins i DIND](IMG/Zrzut%20ekranu%202026-04-10%20013101.png)
 
Widoczne są dwa działające kontenery:
- `jenkins-blueocean` (obraz `myjenkins-blueocean:2.541.3-1`) - nasłuchuje na portach `8080` i `50000`
- `jenkins-docker` (obraz `docker:dind`) - nasłuchuje na porcie `2376`
 
### 4.6. Ekran logowania Jenkins
 
Po skonfigurowaniu przekierowania portów w VirtualBox (8080 → 8080), Jenkins był dostępny w przeglądarce pod adresem `http://localhost:8080`.
 
![Ekran logowania Jenkins - Odblokuj Jenkinsa](IMG/Zrzut%20ekranu%202026-04-10%20013242.png)
 
Wyświetlono ekran inicjalizacji Jenkinsa z prośbą o podanie hasła administratorskiego, znajdującego się w pliku `/var/jenkins_home/secrets/initialAdminPassword`.
 
---
 