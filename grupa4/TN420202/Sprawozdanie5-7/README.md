# Sprawozdanie zbiorcze — Zajęcia 5 - 7


## 1. Wymagania wstępne

- Jenkins uruchomiony w kontenerze Docker  
- dostęp do Dockera (Docker-in-Docker)  
- repozytorium GitHub  
- aplikacja Node.js z testami  

---

## 2. Architektura rozwiązania

Pipeline został zrealizowany w oparciu o:

- Jenkins (orchestrator)
- Docker (środowisko uruchomieniowe)
- GitHub (repozytorium kodu)
- Jenkinsfile (definicja pipeline)

---

## 3. Opis procesu (CI/CD)

Proces CI można opisać jako:

1. Pobranie kodu (clone)
2. Budowa obrazu (build)
3. Uruchomienie testów (test)
4. Przygotowanie środowiska (deploy)
5. Publikacja artefaktu (publish)

---

## 4. Implementacja pipeline

Pipeline został zapisany w pliku `Jenkinsfile` w repozytorium.

```groovy
pipeline {
    agent any

    stages {
        stage('Clone app repo') {
            steps {
                git branch: 'main', url: 'https://github.com/aws-samples/node-js-tests-sample.git'
            }
        }

        stage('Build image') {
            steps {
                sh '''
                printf "%s" "FROM node:18
                WORKDIR /app
                COPY . .
                RUN npm install
                CMD [\\"npm\\", \\"test\\"]" > Dockerfile
                docker build -t my-app .
                '''
            }
        }

        stage('Test') {
            steps {
                sh 'docker run --rm my-app'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker rm -f my-app-deploy || true
                docker run -d --name my-app-deploy my-app tail -f /dev/null
                docker ps
                '''
            }
        }

        stage('Publish') {
            steps {
                sh '''
                docker save my-app > my-app.tar
                ls -lh my-app.tar
                '''
            }
        }
    }
}
```

## 5. Opis etapów pipeline

- **Clone** - pobranie kodu z repozytorium GitHub. Spełnia:

    - praca na aktualnym kodzie 
    - integracja z SCM
- **Build** - budowa obrazu Docker zawierającego aplikację i zależności. Decyzje:

    - użyto obrazu ***node:18***
    - instalacja zależności przez ***npm install***
- **Test** - uruchomienie testów jednostkowych wewnątrz kontenera. Wynik:

    - 7 testów zakończonych sukcesem

    Zalety:

    - izolowane środowisko
    - powtarzalność

- **Deploy** - uruchomienie aplikacji w kontenerze. Decyzja:

    - kontener działa jako środowisko docelowe (sandbox)

```bash
docker run -d --name my-app-deploy my-app
```

- **Publish** - zapis obrazu jako artefakt:

```bash
docker save my-app > my-app.tar
```

## 6. Ścieżka krytyczna

Zrealizowana ścieżka:

- commit
- clone
- build
- test
- deploy
- publish

## 7. Definition of Done

Pipeline uznaje się za zakończony poprawnie, gdy:

- powstasje artefakt (my-app.tar)
- testy przechodzą
- aplikacja działa w kontenerze
- proces jest powtarzalny

## 8. Wnioski

- Jenkinsfile umożliwia pełną automatyzację CI/CD
- Docker zapewnia izolację i powtarzalność środowiska
- Pipeline można łatwo rozszerzać o kolejne etapy