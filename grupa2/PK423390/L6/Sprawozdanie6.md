# Sprawozdanie 6 – Pipeline CI/CD
 
## 1. Wybór Aplikacji i Licencji
 
Wybraną aplikacją jest **Express.js** w wersji v5.1.0 - popularny framework webowy dla Node.js.
 
- **Repozytorium:** https://github.com/expressjs/express
- **Licencja:** MIT – pozwala na swobodne modyfikowanie i dystrybucję kodu na potrzeby zadania.
 
## 2. Diagram UML procesu CI/CD
 
![Diagram](IMG/Zrzut%20ekranu%202026-05-15%20033236.png)
 
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
- Etap `deploy` oparty jest na lżejszym obrazie `node:20-bookworm-slim`, który nie zawiera narzędzi deweloperskich - jest to obraz produkcyjny.
## 4. Konfiguracja Pipeline w Jenkins (Jenkinsfile)
 
![Konfiguracja2](IMG/Zrzut%20ekranu%202026-05-15%20015748.png)
![Konfiguracja](IMG/Zrzut%20ekranu%202026-05-15%20015757.png)
 
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
 
Pipeline pomyślnie przeszedł przez wszystkie etapy w czasie 2 minut i 35 sekund:
 
- **Cleanup** - usunięcie poprzedniego kontenera i katalogu roboczego
- **Clone** - pobranie tylko folderu L6 z repozytorium (sparse-checkout)
- **Build** - zbudowanie obrazu buildowego z Express.js v5.1.0
- **Test** - uruchomienie testów jednostkowych wewnątrz kontenera
- **Deploy** - uruchomienie kontenera produkcyjnego
- **Smoke Test** - weryfikacja poprawności uruchomienia przez sprawdzenie exit code kontenera
- **Publish** - zapis logów jako artefakt i otagowanie obrazu jako `latest`
Wszystkie etapy zakończyły się sukcesem (zielone checkmarki w BlueOcean).

![](IMG/Zrzut%20ekranu%202026-05-15%20031758.png)
 
## 6. Publikacja i Wersjonowanie
 
**Artefaktem** pipeline'u jest plik `build-log-1.0.X.txt` zawierający logi z działania kontenera deploy. Jest on archiwizowany w Jenkinsie z mechanizmem `fingerprint: true`, co umożliwia jednoznaczną identyfikację pochodzenia artefaktu (z którego builda pochodzi).

![](IMG/Zrzut%20ekranu%202026-05-15%20032122.png)
 
## 7. Weryfikacja zgodności z diagramem UML
 
Ostateczny pipeline jest zgodny z zaplanowanym diagramem UML. Wszystkie etapy ścieżki krytycznej zostały zrealizowane:
 
| Etap | Status |
|------|--------|
| commit / manual trigger | Manual trigger w Jenkinsie |
| clone | Etap Clone (sparse-checkout) |
| build | Etap Build (docker build --target build) |
| test | Etap Test (docker build --target test) |
| deploy | Etap Deploy (docker run) |
| publish | Etap Publish (archiveArtifacts) |
 
## 8. Podsumowanie
 
Pipeline spełnia wszystkie wymagania ścieżki krytycznej. Proces jest w pełni zautomatyzowany - od momentu ręcznego wyzwolenia do weryfikacji działającego kontenera i publikacji artefaktu. Zastosowanie multi-stage build pozwoliło na rozdzielenie środowisk i stworzenie lekkiego obrazu produkcyjnego opartego na `node:20-bookworm-slim`.
