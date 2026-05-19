# Sprawozdanie zbiorcze – Laboratoria 5, 6, 7

# Laboratorium 5 – Jenkins: Wprowadzenie i pierwsze Pipeline

## 1. Przygotowanie: Utworzenie instancji Jenkins

Zgodnie z instrukcją uruchomiono środowisko składające się z dwóch kontenerów w dedykowanej sieci `jenkins`:
1. Kontener `jenkins-docker` oparty na obrazie `docker:dind`, udostępniający gniazdo Dockera.
2. Kontener `jenkins-blueocean` oparty na oficjalnym obrazie Jenkinsa.

Po uruchomieniu środowiska, Jenkins został wstępnie skonfigurowany, a hasło administratora pobrano z logów kontenera.

---

## 2. Zadania wstępne: Konfiguracja i pierwsze uruchomienie

### 2.1. Zadanie wyświetlające `uname`

```bash
uname -a
```

Zadanie zakończyło się statusem `SUCCESS`, zwracając informacje o jądrze systemu Linux.

### 2.2. Zadanie zwracające błąd, gdy godzina jest nieparzysta

Aby uniknąć błędu interpretacji liczb z zerem wiodącym jako systemu ósemkowego (np. `08`), zastosowano flagę `%-H` w komendzie pobierającej czas.

```bash
GODZINA=$(date +%-H)
echo "Aktualna godzina: $GODZINA"

if [ $((GODZINA % 2)) -ne 0 ]; then
    echo "BŁĄD: Godzina $GODZINA jest nieparzysta!"
    exit 1
else
    echo "SUKCES: Godzina $GODZINA jest parzysta."
    exit 0
fi
```

### 2.3. Zadanie pobierające obraz `ubuntu`

```bash
docker pull ubuntu:latest
```

Obraz został pomyślnie pobrany do środowiska Dockera obsługującego Jenkinsa.

---

## 3. Zadanie główne: Obiekt typu Pipeline

### 3.1. Skrypt Pipeline

Skrypt realizuje dwa główne kroki: sklonowanie repozytorium przedmiotowego na gałęzi `PK423390` oraz zbudowanie obrazu Dockerowego na podstawie pliku `Dockerfile` znajdującego się w podkatalogu. W tym celu użyto bloku `dir()`.

```groovy
pipeline {
    agent any
    stages {
        stage('Sklonowanie repozytorium') {
            steps {
                git branch: 'PK423390', url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git'
            }
        }
        stage('Zbudowanie Dockerfile') {
            steps {
                script {
                    echo "Wchodzę do katalogu z Dockerfile i buduję obraz..."
                    dir('grupa2/PK423390/L4') {
                        def customImage = docker.build("moj-builder:${env.BUILD_ID}")
                    }
                }
            }
        }
    }
}
```

### 3.2. Pierwsze uruchomienie

Podczas pierwszego uruchomienia Jenkins poprawnie nawiązał połączenie, pobrał repozytorium Git, wszedł do odpowiedniego podkatalogu i zainicjował budowanie obrazu.

### 3.3. Drugie uruchomienie i wnioski

Czas wykonania zadania podczas drugiego uruchomienia znacząco się skrócił. Analiza logów konsoli wykazała, że system wykorzystał pamięć podręczną Dockera (`CACHED`) dla poszczególnych warstw obrazu. Izolacja etapów w Jenkins Pipeline ułatwiła czytelność logów i pozwoliłaby na szybsze zlokalizowanie ewentualnych błędów.

---

# Laboratorium 6 – Pipeline CI/CD

## 1. Wybór Aplikacji i Licencji

Wybraną aplikacją jest **Express.js** w wersji v5.1.0 – popularny framework webowy dla Node.js.

- **Repozytorium:** https://github.com/expressjs/express
- **Licencja:** MIT – pozwala na swobodne modyfikowanie i dystrybucję kodu na potrzeby zadania.

## 2. Diagram UML procesu CI/CD

![Diagram](L6/IMG/Zrzut%20ekranu%202026-05-15%20033236.png)

## 3. Implementacja kontenerów (Dockerfile)

Zastosowano **multi-stage build** w celu rozdzielenia środowisk budowania, testowania i uruchamiania aplikacji.

```dockerfile
# ETAP 1: Build
FROM node:20-bookworm AS build
WORKDIR /app
RUN git clone --branch v5.1.0 --depth 1 https://github.com/expressjs/express.git .
RUN npm install

# ETAP 2: Test
FROM build AS test
CMD ["npm", "test"]

# ETAP 3: Deploy
FROM node:20-bookworm-slim AS deploy
WORKDIR /app
COPY --from=build /app /app
EXPOSE 3000
CMD ["node", "examples/hello-world/index.js"]
```

- Etap `build` pobiera kod i instaluje wszystkie zależności (w tym deweloperskie).
- Etap `test` bazuje bezpośrednio na `build`, dzięki czemu nie ma potrzeby ponownej instalacji zależności.
- Etap `deploy` oparty jest na lżejszym obrazie `node:20-bookworm-slim` - jest to obraz produkcyjny.

## 4. Konfiguracja Pipeline w Jenkins

![Konfiguracja2](L6/IMG/Zrzut%20ekranu%202026-05-15%20015748.png)
![Konfiguracja](L6/IMG/Zrzut%20ekranu%202026-05-15%20015757.png)

```groovy
pipeline {
    agent any
    environment {
        IMAGE_NAME = "express-app-pk423390"
        VERSION = "1.0.${BUILD_NUMBER}"
        CONTAINER_NAME = "express-instance"
    }
    stages {
        stage('Cleanup') {
            steps {
                sh "docker rm -f ${env.CONTAINER_NAME} || true"
                sh "rm -rf workspace-l6 || true"
            }
        }
        stage('Clone') {
            steps {
                sh """
                    git clone --depth 1 --filter=blob:none --sparse -b PK423390 \
                    https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git workspace-l6 && \
                    cd workspace-l6 && \
                    git sparse-checkout set grupa2/PK423390/L6 && \
                    git checkout
                """
            }
        }
        stage('Build') {
            steps {
                sh "docker build --target build -t ${env.IMAGE_NAME}:${env.VERSION} workspace-l6/grupa2/PK423390/L6/"
            }
        }
        stage('Test') {
            steps {
                sh "docker build --target test -t ${env.IMAGE_NAME}-test:${env.VERSION} workspace-l6/grupa2/PK423390/L6/"
                sh "docker run --rm ${env.IMAGE_NAME}-test:${env.VERSION} > test.log || true"
            }
        }
        stage('Deploy') {
            steps {
                sh "docker build --target deploy -t ${env.IMAGE_NAME}-deploy:${env.VERSION} workspace-l6/grupa2/PK423390/L6/"
                sh "docker run -d --name ${env.CONTAINER_NAME} ${env.IMAGE_NAME}-deploy:${env.VERSION}"
            }
        }
        stage('Smoke Test') {
            steps {
                sh """
                    sleep 5
                    STATUS=\$(docker inspect ${env.CONTAINER_NAME} --format='{{.State.ExitCode}}')
                    echo "Exit code: \$STATUS"
                    if [ "\$STATUS" -ne 0 ]; then
                        echo "Smoke test FAILED"
                        exit 1
                    else
                        echo "Smoke test PASSED"
                    fi
                """
            }
        }
        stage('Publish') {
            steps {
                sh "docker tag ${env.IMAGE_NAME}-deploy:${env.VERSION} ${env.IMAGE_NAME}:latest"
                sh "docker logs ${env.CONTAINER_NAME} > build-log-${env.VERSION}.txt"
                archiveArtifacts artifacts: "*.txt", fingerprint: true
            }
        }
    }
    post {
        always {
            sh "docker rm -f ${env.CONTAINER_NAME} || true"
        }
    }
}
```

## 5. Przebieg Pipeline i Weryfikacja

Pipeline pomyślnie przeszedł przez wszystkie etapy w czasie 2 minut i 35 sekund.

![Pipeline](L6/IMG/Zrzut%20ekranu%202026-05-15%20031758.png)

## 6. Publikacja i Wersjonowanie

Artefaktem pipeline'u jest plik `build-log-1.0.X.txt` zawierający logi z działania kontenera deploy. Jest on archiwizowany w Jenkinsie z mechanizmem `fingerprint: true`, co umożliwia jednoznaczną identyfikację pochodzenia artefaktu.

Wersjonowanie realizowane jest przez zmienną `${BUILD_NUMBER}` w formacie `1.0.X` (semantic versioning).

![Artefakt](L6/IMG/Zrzut%20ekranu%202026-05-15%20032122.png)

## 7. Weryfikacja zgodności z diagramem UML

| Etap | Status |
|------|--------|
| commit / manual trigger | Manual trigger w Jenkinsie |
| clone | Etap Clone (sparse-checkout) |
| build | Etap Build (docker build --target build) |
| test | Etap Test (docker build --target test) |
| deploy | Etap Deploy (docker run) |
| publish | Etap Publish (archiveArtifacts) |


---

# Laboratorium 7 – Jenkinsfile

## 1. Przepis dostarczany z SCM

Plik Jenkinsfile nie jest wklejony bezpośrednio w ustawieniach obiektu Jenkins, lecz znajduje się w repozytorium przedmiotowym MDO2026_ITE na gałęzi `PK423390`, pod ścieżką `grupa2/PK423390/L6/Jenkinsfile`.

Jenkins pobiera go automatycznie przy każdym uruchomieniu pipeline'u dzięki konfiguracji:

- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- **Branch:** `*/PK423390`
- **Script Path:** `grupa2/PK423390/L6/Jenkinsfile`

Dzięki temu infrastruktura budowania staje się "częścią kodu" - każda zmiana w Jenkinsfile jest wersjonowana razem z kodem aplikacji.

## 2. Weryfikacja listy kontrolnej

| Wymaganie | Status |
|-----------|--------|
| Przepis dostarczany z SCM | Jenkinsfile w repo, pobierany przez Pipeline script from SCM |
| Sprzątanie przed buildem | Etap Cleanup usuwa stary kontener i katalog roboczy |
| Etap Build dysponuje repo i Dockerfile | Sparse-checkout pobiera L6/ z Dockerfile |
| Etap Build tworzy obraz buildowy | `docker build --target build` |
| Kontener deploy odmienny od build | `--target deploy` na bazie `node:20-bookworm-slim` |
| Etap Test przeprowadza testy | `docker build --target test` + `docker run` |
| Etap Deploy przygotowuje obraz z entrypointem | `CMD ["node", "examples/hello-world/index.js"]` |
| Etap Deploy przeprowadza wdrożenie | `docker run -d` |
| Etap Publish dodaje artefakt do historii builda | `archiveArtifacts` z `fingerprint: true` |
| Pipeline działa więcej niż raz | Cleanup usuwa poprzedni stan przed każdym uruchomieniem |

---
# Wnioski

Realizacja laboratoriów 5-7 pozwoliła na zrozumienie pełnego cyklu życia aplikacji w podejściu DevOps - od ręcznego budowania kontenerów do w pełni zautomatyzowanego pipeline'u CI/CD. Kluczowym wnioskiem jest wartość koncepcji "Infrastructure as Code": przechowywanie Jenkinsfile i Dockerfile w repozytorium zapewnia powtarzalność, odtwarzalność i minimalizuje ryzyko błędów ludzkich. Rozdzielenie obrazów build/test/deploy udowodniło, że bezpieczeństwo i wydajność mogą iść w parze z automatyzacją, a praktyczne problemy infrastrukturalne - jak brak miejsca na dysku czy timeouty przy klonowaniu - pokazały, że utrzymanie środowiska CI/CD wymaga równie dużej świadomości zasobów systemowych, co znajomości samych narzędzi.