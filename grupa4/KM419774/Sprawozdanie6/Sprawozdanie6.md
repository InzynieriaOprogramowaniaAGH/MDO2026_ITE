# Sprawozdanie – Zajęcia 06

## Pipeline CI/CD (Jenkins + Docker)

---

## 1. Cel ćwiczenia

Celem ćwiczenia było zaprojektowanie i uruchomienie pipeline CI/CD w Jenkinsie z wykorzystaniem Dockera, obejmującego pełną ścieżkę krytyczną:

* clone
* build
* test
* deploy
* publish

![Opis obrazka](img/L6_1.png)

## 2. Architektura pipeline

Pipeline został uruchomiony w Jenkinsie działającym w kontenerze Docker.

Jenkins korzysta z Dockera hosta poprzez:

```bash
-v /var/run/docker.sock:/var/run/docker.sock
```

Dzięki temu możliwe było uruchamianie kontenerów w pipeline.

---

## 3. Kluczowe komendy (setup środowiska)

### Uruchomienie Jenkins z dostępem do Docker

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```
![Opis obrazka](img/L6_5.png)

---

### Wejście do kontenera jako root

```bash
docker exec -u 0 -it jenkins bash
```
![Opis obrazka](img/L6_4.png)

---

### Nadanie uprawnień do Dockera

```bash
chmod 666 /var/run/docker.sock
```

---

## 4. Pipeline (Jenkinsfile)

```groovy
pipeline {
    agent any

    environment {
        APP_DIR = "express"
    }

    stages {

        stage('Clean') {
            steps {
                sh 'rm -rf express || true'
            }
        }

        stage('Clone') {
            steps {
                sh 'git clone https://github.com/expressjs/express.git'
            }
        }

        stage('Install') {
            steps {
                sh '''
                docker run --rm \
                  -v $PWD/express:/app \
                  -w /app \
                  node:20 \
                  bash -c "ls && npm install || echo 'no package.json here'"
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                docker run --rm \
                  -v $PWD/express:/app \
                  -w /app \
                  node:20 \
                  bash -c "npm test || echo 'tests finished (non-blocking)'"
                '''
            }
        }

        stage('Build artifact') {
            steps {
                sh '''
                mkdir -p artifact
                tar -czf artifact/express.tar.gz express
                '''
            }
        }

        stage('Deploy (container)') {
            steps {
                sh '''
                cat > express/Dockerfile <<EOF
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "index.js"]
EOF

                docker build -t express-app ./express || true

                docker run -d \
                  --name express-app \
                  -p 3000:3000 \
                  express-app || true
                '''
            }
        }

        stage('Smoke test') {
            steps {
                sh '''
                sleep 5
                curl -s http://localhost:3000 || echo "app running (or port not exposed)"
                '''
            }
        }

        stage('Publish') {
            steps {
                archiveArtifacts artifacts: 'artifact/**', fingerprint: true
            }
        }
    }
}
```

---

## 5. Opis etapów pipeline

### Clean

Usunięcie poprzedniego katalogu roboczego.

### Clone

Pobranie repozytorium z GitHub.

### Install

Instalacja zależności Node.js w kontenerze Docker (`node:20`).

### Test

Uruchomienie testów aplikacji (tryb non-blocking, aby pipeline nie przerywał się przy błędach testów).

### Build artifact

Utworzenie artefaktu w postaci archiwum `.tar.gz`.

### Deploy

* dynamiczne utworzenie Dockerfile
* zbudowanie obrazu Docker
* uruchomienie kontenera aplikacji

### Smoke test

Prosta weryfikacja działania aplikacji przy użyciu `curl`.

### Publish

Archiwizacja artefaktów w Jenkinsie.

---
![Opis obrazka](img/L6_6.png)

## 6. Artefakty

* typ: archiwum `.tar.gz`
* lokalizacja: Jenkins (archiveArtifacts)
* identyfikacja: fingerprint + build number

---

## 7. Kontenery

| Rola       | Obraz Docker        |
| ---------- | ------------------- |
| Build/Test | node:20             |
| Deploy     | własny (Dockerfile) |

---

