# Sprawozdanie 7 – Jenkinsfile

## 1. Przepis dostarczany z SCM

Plik Jenkinsfile nie jest wklejony bezpośrednio w ustawieniach obiektu Jenkins, lecz znajduje się w repozytorium przedmiotowym MDO2026_ITE na gałęzi `PK423390`, pod ścieżką `grupa2/PK423390/L6/Jenkinsfile`.

Jenkins pobiera go automatycznie przy każdym uruchomieniu pipeline'u dzięki konfiguracji:

- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- **Branch:** `*/PK423390`
- **Script Path:** `grupa2/PK423390/L6/Jenkinsfile`

Dzięki temu infrastruktura budowania staje się "częścią kodu" - każda zmiana w Jenkinsfile jest wersjonowana razem z kodem aplikacji.

## 2. Sprzątanie (Cleanup)

Pierwszym etapem pipeline'u jest `Cleanup`, który:
- usuwa ewentualny poprzedni kontener (`docker rm -f`)
- usuwa katalog roboczy `workspace-l6` z poprzedniego uruchomienia

```groovy
stage('Cleanup') {
    steps {
        sh "docker rm -f ${env.CONTAINER_NAME} || true"
        sh "rm -rf workspace-l6 || true"
    }
}
```

Dzięki temu mamy pewność, że pipeline zawsze pracuje na świeżym kodzie, a nie na danych z poprzedniego uruchomienia. Użycie `|| true` zapobiega błędom gdy kontener lub katalog nie istnieje.

## 3. Etap Clone


```groovy
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
```

Po wykonaniu tego etapu w katalogu `workspace-l6/grupa2/PK423390/L6/` dostępne są pliki `Dockerfile` i `Jenkinsfile`.

## 4. Etap Build

Etap `Build` dysponuje repozytorium i plikiem `Dockerfile`. Budowany jest obraz buildowy zawierający aplikację Express.js v5.1.0 wraz z wszystkimi zależnościami deweloperskimi.

```groovy
        stage('Build') {
            steps {
                sh "docker build --target build -t ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
    }
```

Flaga `--target build` wskazuje na pierwszy etap multi-stage build w Dockerfile.

## 5. Etap Test

Etap `Test` buduje obraz testowy bazujący na obrazie `build`i uruchamia testy jednostkowe Express.js.

```groovy
        stage('Test') {
            steps {
                sh "docker build --target test -t ${env.IMAGE_NAME}-test:${env.BUILD_NUMBER} ."
            }
        }
```

Kontener testowy jest oparty bezpośrednio na obrazie buildowym, dzięki czemu nie ma potrzeby ponownej instalacji zależności.

## 6. Etap Deploy

Etap `Deploy` buduje finalny obraz produkcyjny oparty na lżejszym `node:20-bookworm-slim` i uruchamia kontener.

```groovy
        stage('Deploy') {
            steps {
                sh "docker build --target deploy -t ${env.IMAGE_NAME}-deploy:${env.BUILD_NUMBER} ."
                sh "docker run -d --name ${env.CONTAINER_NAME} --network host ${env.IMAGE_NAME}-deploy:${env.BUILD_NUMBER}"
            }
        }
```

Kontener deploy jest odmienny od kontenera buildowego - nie zawiera narzędzi deweloperskich, jest mniejszy i przeznaczony wyłącznie do uruchomienia aplikacji.

## 7. Smoke Test

```groovy
        stage('Smoke Test') {
            steps {
                sleep 10
                sh "docker run --rm --network host alpine sh -c 'apk add --no-cache curl && curl -f http://localhost:3000'"
            }
        }
```

## 8. Etap Publish

```groovy
        stage('Publish') {
            steps {
                sh "docker logs ${env.CONTAINER_NAME} > build-log-${env.BUILD_NUMBER}.txt"
                archiveArtifacts artifacts: "*.txt", fingerprint: true
            }
        }
```

Mechanizm `fingerprint: true` pozwala na jednoznaczną identyfikację artefaktu i powiązanie go z konkretnym buildem.

## 9. Kompletny Jenkinsfile

```groovy
pipeline {
    agent any
    environment {
        IMAGE_NAME = "express-app-pk423390"
        CONTAINER_NAME = "express-instance"
    }
    stages {
        stage('Cleanup') {
            steps {
                sh "docker stop ${env.CONTAINER_NAME} || true"
                sh "docker rm ${env.CONTAINER_NAME} || true"
            }
        }
        stage('Build') {
            steps {
                sh "docker build --target build -t ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }
        stage('Test') {
            steps {
                sh "docker build --target test -t ${env.IMAGE_NAME}-test:${env.BUILD_NUMBER} ."
            }
        }
        stage('Deploy') {
            steps {
                sh "docker build --target deploy -t ${env.IMAGE_NAME}-deploy:${env.BUILD_NUMBER} ."
                sh "docker run -d --name ${env.CONTAINER_NAME} --network host ${env.IMAGE_NAME}-deploy:${env.BUILD_NUMBER}"
            }
        }
        stage('Smoke Test') {
            steps {
                sleep 10
                sh "docker run --rm --network host alpine sh -c 'apk add --no-cache curl && curl -f http://localhost:3000'"
            }
        }
        stage('Publish') {
            steps {
                sh "docker logs ${env.CONTAINER_NAME} > build-log-${env.BUILD_NUMBER}.txt"
                archiveArtifacts artifacts: "*.txt", fingerprint: true
            }
        }
    }
    post {
        always {
            sh "docker stop ${env.CONTAINER_NAME} || true"
            sh "docker rm ${env.CONTAINER_NAME} || true"
        }
    }
}
```
![](IMG/Zrzut%20ekranu%202026-05-15%20031758.png)
![](IMG/Zrzut%20ekranu%202026-05-15%20032122.png)

## 10. Weryfikacja listy kontrolnej

| Wymaganie | Status |
|-----------|--------|
| Przepis dostarczany z SCM |  Jenkinsfile w repo, pobierany przez Pipeline script from SCM |
| Sprzątanie przed buildem | Etap Cleanup usuwa stary kontener i katalog roboczy |
| Etap Build dysponuje repo i Dockerfile | Pobiera L6/ z Dockerfile |
| Etap Build tworzy obraz buildowy |  `docker build --target build` |
| Przygotowanie artefaktu (kontener deploy odmienny od build) |  `--target deploy` na bazie `node:20-bookworm-slim` |
| Etap Test przeprowadza testy |  `docker build --target test` + `docker run` |
| Etap Deploy przygotowuje obraz z entrypointem |  CMD ["node", "examples/hello-world/index.js"] |
| Etap Deploy przeprowadza wdrożenie |  `docker run -d` |
| Etap Publish dodaje artefakt do historii builda | `archiveArtifacts` z `fingerprint: true` |
| Pipeline działa więcej niż raz | Cleanup usuwa poprzedni stan przed każdym uruchomieniem |


## 11. Podsumowanie

Pipeline jest w pełni zautomatyzowany i idempotentny – każde uruchomienie zaczyna od czystego stanu. Jenkinsfile przechowywany w repozytorium razem z kodem sprawia, że infrastruktura CI/CD jest wersjonowana i łatwa do odtworzenia.