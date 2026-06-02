# Cel ćwiczenia

Celem jest skonfigurowanie Jenkins Pipeline, który będzie klonował repozytorium express, instalował zależności i uruchamiał testy.

# Środowisko

System: Ubuntu Server
Kontener Jenkins: jenkins/jenkins:lts
Kontener DIND: docker:24-dind
Docker w koneterze: node:20-slim

# Tworzenie sieci i wolumenów

```bash
docker network create jenkins-network
docker volume create jenkins-data
docker volume create jenkins-docker-certs
```

![Tworzenie sieci i wolumenów](<img/Screenshot 2026-05-07 at 15.03.31.png>)

# Uruchomienie silnika DIND

Kontener, który będzie fizycznie uruchmiał obrazy.

```bash
docker run --name jenkins-docker -d \
    --privileged \
    --network jenkins-network --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume jenkins-docker-certs:/certs/client \
    --volume jenkins-data:/var/jenkins_home \
    docker:24-dind
```

- `--privileged` daje kontenerowi pełne uprawnienia na hoście, co jest wymagane do uruchamiania innych kontenerów.
- `--network-alias docker` pozwala innym kontenerom w tej samej sieci na dostęp do tego kontenera pod nazwą "docker" (alias w sieci).

![Uruchomienie silnika DIND](<img/Screenshot 2026-05-07 at 15.09.03.png>)

# Uruchomienie kontenera Jenkins

```bash
docker run --name jenkins -d \
    --network jenkins-network \
    --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client \
    --env DOCKER_TLS_VERIFY=1 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    -p 8080:8080 -p 50000:50000 \
    jenkins/jenkins:lts
```

- `--env DOCKER_HOST=tcp://docker:2376` wskazuje Jenkinsowi, gdzie znajduje się silnik Docker (kontener DIND).
- `--env DOCKER_TLS_VERIFY=1` włącza wymóg weryfikacji TLS, co jest ważne dla bezpieczeństwa komunikacji między Jenkins a DIND.

## Instalacja docker.io w kontenerze Jenkins

```bash
docker exec -u 0 -it jenkins bash
apt-get update && apt-get install -y docker.io
```

![Uruchomienie kontenera Jenkins](<img/Screenshot 2026-05-07 at 15.13.14.png>)

# Konfiguracja wstępna przez przeglądarkę

- Sprawdzamy hasło administratora, które jest potrzebne do pierwszego logowania do Jenkins za pomocą `docker logs jenkins` i wprowadzamy je na stronie logowania `http://localhost:8080`.

- Instalujemy zalecane wtyczki i tworzymy pierwszego użytkownika.

![Konfiguracja wstępna](<img/Screenshot 2026-05-07 at 15.18.39.png>)

- `NodeJS` - do uruchamiania testów w kontenerze z Node.js.

* Instalujemy dodatkowe wtyczki `Docker`, `Docker Pipeline` i `Blue Ocean`.

![Instalacja wtyczek](<img/Screenshot 2026-05-07 at 15.20.08.png>)

# Weryfikacja poprawności przez proste zadania

### Test uname

```groovy
pipeline {
    agent any
    stages {
        stage('System Info') {
            steps { sh 'uname -a' }
        }
    }
}
```

![Sprawdzenie uname](<img/Screenshot 2026-05-07 at 15.26.38.png>)

#### Wynik

![Wynik uname](<img/Screenshot 2026-05-07 at 15.29.16.png>)

### Test godziny

```groovy
pipeline {
    agent any
    stages {
        stage('Verify Hour') {
            steps {
                script {
                    def hour = new Date().format("HH").toInteger()
                    if (hour % 2 != 0) {
                        error "BŁĄD: Godzina ${hour} jest nieparzysta. Przerywam!"
                    }
                    echo "Godzina ${hour} jest parzysta. Kontynuuję."
                }
            }
        }
    }
}
```

#### Wynik

![Wynik godziny](<img/Screenshot 2026-05-07 at 15.31.48.png>)

# Express.js pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                sh 'rm -rf express'
                sh 'git clone https://github.com/expressjs/express.git'
            }
        }
        stage('Install & Test') {
            steps {
                echo 'Build & Test'
                sh 'docker run --rm -v $PWD/express:/app -w /app node:20 bash -c "npm install && npm test"'
            }
        }
    }
}
```

![Express.js pipeline](<img/Screenshot 2026-05-07 at 22.30.24.png>)
