# Sprawozdanie 3
## Cel ćwiczenia
### Krzysztof Mazur ITE
Celem ćwiczenia było zbudowanie oprogramowania w powtarzalnym środowisku CI z wykorzystaniem kontenerów Docker, tak aby proces build oraz test był przenośny pomiędzy różnymi systemami operacyjnymi.

Do realizacji zadania wykorzystano repozytorium frameworka backendowego: https://github.com/expressjs/express.git.

---

## Budowanie aplikacji lokalnie

### Klonowanie repozytorium

```bash
git clone https://github.com/expressjs/express.git
cd express
```
![Opis obrazka](img/L3_1.png)
### Instalacja środowiska npm
```bash
sudo apt update
sudo apt install -y nodejs npm
```

### Weryfikacja wersji
```bash
node -v
npm -v
```
![Opis obrazka](img/L3_2.png)
### Instalacja zależności projektu oraz uruchomienie testów
```bash
npm install
npm test
```
Instalacja:
![Opis obrazka](img/L3_3.png)
Testy:
![Opis obrazka](img/L3_4.png)
## Build i test w kontenerze
### Uruchomienie kontenera Node
```bash
docker run -it node:20 bash
```
![Opis obrazka](img/L3_5.png)
### Instalacja git w kontenerze
```bash
apt update
apt install -y git
```
Wewnątrz kontenera:
![Opis obrazka](img/L3_6.png)
### Klonowanie repozytorium w kontenerze
```bash
git clone https://github.com/expressjs/express.git
cd express
```


### Instalacja zależności oraz testy
```bash
npm install
npm test
exit
```
Testy w kontenerze:
![Opis obrazka](img/L3_7.png)
Testy zakończyły się powodzeniem, co potwierdza powtarzalność procesu build w izolowanym środowisku

## Automatyzacja build
### Utworzenie pliku
```bash
nano Dockerfile.build
```
![Opis obrazka](img/L3_8.png)
### Budowa obrazu
```bash
docker build -f Dockerfile.build -t express-build .
```
![Opis obrazka](img/L3_9.png)
Wyniki testów (sukces):
![Opis obrazka](img/L3_9_success.png)
### Automatyzacja testów
```bash
nano Dockerfile.test
```
![Opis obrazka](img/L3_10.png)
### Budowa obrazu oraz uruchamianie kontenera

```bash
docker build -f Dockerfile.test -t express-test .
docker run --rm express-test
```
![Opis obrazka](img/L3_11.png)
Wyniki testów:
![Opis obrazka](img/L3_12.png)
## Docker Compose

### Utworzenie pliku
```bash
nano docker-compose.yml
```
![Opis obrazka](img/L3_13.png)
### Uruchomienie
```bash
docker compose build
docker compose run test
```
![Opis obrazka](img/L3_14.png)
Wyniki testów przy pełnej automatyzacji procesu:
![Opis obrazka](img/L3_15.png)
## Dyskusja

Czy Express nadaje się do wdrażania jako kontener?

Tak. Express jest frameworkiem backendowym Node.js, dlatego może zostać uruchomiony jako aplikacja serwerowa w kontenerze Docker.

Finalny obraz mógłby uruchamiać aplikację poleceniem:
```bash
node app.js
```
Czy należy usuwać artefakty builda?
Tak. W praktyce stosuje się podejście:
```bash
builder image -> runtime image
```
czyli multi-stage Docker build, w którym finalny obraz zawiera jedynie niezbędne pliki runtime.

Czy Express można dystrybuować jako pakiet?

Tak. Express jest dystrybuowany jako pakiet npm:
```bash
npm install express
```
Czy można stworzyć trzeci kontener (deploy)?

Tak. Możliwe jest utworzenie np.:
```bash
Dockerfile.release
```
który realizowałby: build projektu, testy, publikację pakietu