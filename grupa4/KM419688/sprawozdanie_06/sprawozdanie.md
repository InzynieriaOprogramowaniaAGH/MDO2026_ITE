## Celem jest zaprojektowanie i uruchomienie pipeline CI/CD dla projektu Express.js, który posiada licencję MIT.

Projekt buduje się lokalnie oraz przechodzą dołączone do niego testy. Zdecydowałem się na wykonanie forka repozytorium, aby mieć możliwość wprowadzania zmian i testowania ich w ramach pipeline CI/CD.

Link do oryginalnego repozytorium: [Express.js](https://github.com/expressjs/express)

[Fork repozytorium Express.js](https://github.com/kamilmarchewka/express)

## Ścieżka krytyczna będzie obejomować następujące kroki:

- checkout: pobranie kodu źródłowego z repozytorium, w tym kroku pliki z repozytorium są klonowane do agenta Jenkins.

- build image: budowanie obrazu Dockerowego na podstawie Dockerfile, który zawiera wszystkie zależności potrzebne do uruchomienia testów.

- run tests: uruchomienie kontenera na podstawie zbudowanego obrazu i wykonanie testów, które są zdefiniowane w projekcie Express.js.

- build app artifact .tar.gz: po pomyślnym przejściu testów, gotowy do użytku framework (index.js lib/ package.json node_modules/) jest pakowany do archiwum .tar.gz, które może zostać dalej użyte.

- deploy: uruchomienie kontenera na podstawie zbudowanego obrazu, oraz uruchomienine przykładowej aplikacji, która korzysta z frameworka Express.js i wyświetla "Hello World" na porcie 3000.

- smoke test: wykonanie prostego testu, przy pomocy curl, który sprawdza, czy aplikacja działa i czy zwraca oczekiwany wynik "Hello World" na porcie 3000.

- publish: jeżeli wszystkie poprzednie kroki zakończyły się sukcesem to gotowy do użytku framework jest zapisywany jako gotowy do pobrania artefakt w Jenkins.

## Uruchomienie kontenera Docker z obrazem Node.js i sprawdzenie, czy testy na forku przechodzą pomyślnie

```bash
docker run -it --rm node:20-bookworm bash
apt-get update && apt-get install -y git
git clone https://github.com/kamilmarchewka/express.git
cd express
npm install
npm run test
```

![Uruchomienie kontenera](<img/Screenshot 2026-05-08 at 08.35.57.png>)

Wyniki testów

![Wyniki testów](<img/Screenshot 2026-05-08 at 08.37.13.png>)

## Stworzenie Dockerfile

```Dockerfile
# Dockerfile.git
FROM alpine/git
WORKDIR /express-repo
ENTRYPOINT ["git", "clone", "https://github.com/expressjs/express.git", "."]
```

```Dockerfile
# Dockerfile.node
FROM node:20-slim
WORKDIR /express-repo
RUN ["sh","-c","npm install && npm run test"]
```

![Zbudowanie obrazów](<img/Screenshot 2026-05-08 at 08.55.24.png>)

## Uruchomienie kontenerów i sprawdzenie, czy testy przechodzą pomyślnie

```bash
docker build -t image-git -f Dockerfile.git .
docker build -t image-node -f Dockerfile.node .

docker run --rm -v express-repo-data:/express-repo express-git
docker run --rm -v express-repo-data:/express-repo express-node
```

![Uruchomienie kontenerów](<img/Screenshot 2026-05-08 at 09.00.58.png>)

## Uruhcomienie serwera Jenkins w kontenerze Docker

## Przygotowanie katalogu na dane Jenkins

```bash
mkdir -p ~/jenkins-home
sudo chown -R 1000:1000 ~/jenkins-home
```

![Stworzenie folderu na dane Jenkins](<img/Screenshot 2026-05-08 at 09.07.18.png>)

## Uruchomienie kontenera z Jenkins

```bash
docker run -d -u root \
    --name jenkins-server \
    -p 8080:8080 \
    -p 50000:50000 \
    -v ~/jenkins-home:/var/jenkins-home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker
    jenkins/jenkins:lts
```

![Uruchomienie kontenera Jenkins](<img/Screenshot 2026-05-08 at 09.55.09.png>)

Szukamy hasła za pomocą `docker logs jenkins-server` i wprowadzamy je na stronie Jenkins `http://localhost:8080`.

# Przygotowanie Dockerfile i Jenkinsfile dla pipeline CI/CD

Łączymy oba Dockerfile w jeden, który będzie używany w pipeline CI/CD.

```Dockerfile
# Etap 1 - budowanie zalezności
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Etap 2 - uruchomienie testów
FROM builder AS tester
RUN npm run test

RUN tar -czf /express-app.tar.gz index.js lib/ package.json node_modules/
```

```Groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Pobieranie kodu...'
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                echo 'Budowanie obrazu dockerowego...'
                sh 'docker build -t express-test-image .'
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Uruchamianie testów w kontenerze...'
                sh 'docker run --rm express-test-image'
            }
        }

        stage('Build App Artefact .tar.gz') {
            steps {
                sh '''
                    mkdir -p artefact/ artefact/logs

                    VERSION="1.0.${BUILD_NUMBER}"
                    ARTEFACT_NAME="express-app-v${VERSION}.tar.gz"

                    docker create --name extractor express-test-image
                    docker cp extractor:/express-app.tar.gz ./artefact/${ARTEFACT_NAME}
                    docker rm extractor
                '''
            }
        }

        stage('Deploy - run hello_world.js') {
            steps {
                echo 'Uruchomienie hello_world.js na localhost:3000'
                sh'''
                    docker stop hello-world-app || true
                    docker rm hello-world-app || true

                    docker run -d \
                        -p 3000:3000 \
                        --name hello-world-app \
                        express-test-image \
                        node examples/hello-world/index.js
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    sleep 5

                    CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' hello-world-app)
                    echo "Łączę się z IP: $CONTAINER_IP"

                    if curl -s http://$CONTAINER_IP:3000 | grep -q "Hello World"; then
                        echo "Sukces: Hello World się wyświetla"
                        TEST_RESULT=0
                    else
                        echo "Błąd: Nie znaleziono frazy"
                        TEST_RESULT=1
                    fi

                    docker logs hello-world-app > artefact/logs/container.log 2>&1 || echo "Kontener nie istniał"

                    exit $TEST_RESULT
                '''
            }
        }

        stage('Publish') {
            steps {
                sh 'ls'
                sh 'ls artefact/'
                archiveArtifacts artifacts: 'artefact/**', fingerprint: true
            }
        }
    }

    post {
        always {
            echo 'Czyszczenie środowiska...'
            sh 'docker stop hello-world-app'
            sh 'docker rm hello-world-app'
            sh 'docker rmi express-test-image || true'
        }
        success {
            echo 'Pipeline zakończony sukcesem!'
        }
        failure {
            echo 'Coś poszło nie tak. Sprawdź logi.'
        }
    }
}
```

# Tworzenie pipeline w Jenkins

Pliki: Dockerfile i Jenkinsfile umieszczamy w katalogu głównym forka repozytorium Express.js, a następnie tworzymy nowy pipeline w Jenkins, który będzie korzystał z tego repozytorium i wykonywał kroki zdefiniowane w Jenkinsfile.

![Tworzenie pipeline w Jenkins](<img/Screenshot 2026-05-08 at 09.57.30.png>)

![Konfiguracja pipeline](<img/Screenshot 2026-05-08 at 09.58.21.png>)

## Uruchomienie pipeline i obserwacja wyników

![Uruchomienie pipeline](<img/Screenshot 2026-05-13 at 00.12.11.png>)

## Artefakty

### Publikacja artefaktów

W Dockerfile została zdefiniowana instrukcja, `RUN tar -czf /express-app.tar.gz index.js lib/ package.json node_modules/`, która po pomyślnym przejściu testów, pakuje gotowy do użytku framework Express.js do archiwum .tar.gz. które jest zapisywane w dockerowym katalogu /artefact/.

Następnie artefakt jest wyciągany z kontenera i zapisywany w katalogu artefact/ w Jenkins.

```groovy
stage('Build App Artefact .tar.gz') {
    steps {
        sh '''
            mkdir -p artefact/ artefact/logs

            VERSION="1.0.${BUILD_NUMBER}"
            ARTEFACT_NAME="express-app-v${VERSION}.tar.gz"

            docker create --name extractor express-test-image
            docker cp extractor:/express-app.tar.gz ./artefact/${ARTEFACT_NAME}
            docker rm extractor
        '''
    }
}
```

Jako artefakt zapisywane są również logi z kontenera, który uruchamia przykładową aplikację hello_world.js `docker logs hello-world-app > artefact/logs/container.log 2>&1 || echo "Kontener nie istniał"` dzieje się to w stage `Smoke Test`.

Następnie wszystko jest archiwizowane jako artefakt w Jenkins, dzięki czemu można go łatwo pobrać i użyć w przyszłości.

```groovy
stage('Publish') {
    steps {
        sh 'ls'
        sh 'ls artefact/'
        archiveArtifacts artifacts: 'artefact/**', fingerprint: true
    }
}
```

![Publikacja artefaktów](<img/Screenshot 2026-05-13 at 00.12.41.png>)

### Wersjonowanie artefaktów

Użyłem prostego schematu wersjonowania, który opiera się na numerze builda w Jenkins. Każdy artefakt jest nazywany w formacie `express-app-v1.0.${BUILD_NUMBER}.tar.gz`, gdzie `${BUILD_NUMBER}` jest automatycznie zwiększanym numerem przy każdym uruchomieniu pipeline. Dzięki temu każdy artefakt ma unikalną nazwę, która pozwala łatwo zidentyfikować, z którego builda pochodzi.

### Identyfikacja artefaktów

Pochodzenie artefaktów można łatwo ustalić na podstawie numeru builda, który jest częścią nazwy pliku.

Dodatkowo istnieje funkcja `fingerprint` w Jenkins, która pozwala na śledzenie artefaktów i ich powiązań z konkretnymi buildami poprzez generowanie sumy kontrolnej MD5.

![Identyfikacja artefaktów](<img/Screenshot 2026-05-13 at 00.13.01.png>)

Jest to dużo lepszy sposób, ponieważ nawet jak ktoś zmieni nazwę pliku, to nadal będzie można zidentyfikować jego pochodzenie dzięki sumie kontrolnej.
