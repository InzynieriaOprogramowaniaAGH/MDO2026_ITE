# Ćwiczenia 5

## Cel ćwiczenia

Celem jest skonfigurowanie Jenkins Pipeline, który będzie klonował repozytorium express, instalował zależności i uruchamiał testy.

## Środowisko

System: Ubuntu Server
Kontener Jenkins: jenkins/jenkins:lts
Kontener DIND: docker:24-dind
Docker w koneterze: node:20-slim

## Tworzenie sieci i wolumenów

```bash
docker network create jenkins-network
docker volume create jenkins-data
docker volume create jenkins-docker-certs
```

![Tworzenie sieci i wolumenów](<img/Screenshot 2026-05-07 at 15.03.31.png>)

## Uruchomienie silnika DIND

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

## Uruchomienie kontenera Jenkins

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

### Instalacja docker.io w kontenerze Jenkins

```bash
docker exec -u 0 -it jenkins bash
apt-get update && apt-get install -y docker.io
```

![Uruchomienie kontenera Jenkins](<img/Screenshot 2026-05-07 at 15.13.14.png>)

## Konfiguracja wstępna przez przeglądarkę

- Sprawdzamy hasło administratora, które jest potrzebne do pierwszego logowania do Jenkins za pomocą `docker logs jenkins` i wprowadzamy je na stronie logowania `http://localhost:8080`.

- Instalujemy zalecane wtyczki i tworzymy pierwszego użytkownika.

![Konfiguracja wstępna](<img/Screenshot 2026-05-07 at 15.18.39.png>)

- `NodeJS` - do uruchamiania testów w kontenerze z Node.js.

* Instalujemy dodatkowe wtyczki `Docker`, `Docker Pipeline` i `Blue Ocean`.

![Instalacja wtyczek](<img/Screenshot 2026-05-07 at 15.20.08.png>)

## Weryfikacja poprawności przez proste zadania

#### Test uname

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

#### Test godziny

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

# Ćwiczenia 6

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

# Ćwiczenia 7

## Celem tego ćwiczenia jest przeanalizowanie i zweryfikowanie działania zbudowanego wcześniej pipeline'u Jenkins, budującego aplikacji express, przy pomocy dostarczonej listy kontrolnej.

### Posprzątanie środowiska

Dodanie polecenia `cleanWs()` na początku pipeline'u pozwoli na usunięcie wszystkich plików z poprzednich buildów, co zapewni czyste środowisko do kolejnych testów.

![Weryfikacja działania cleanWs()](<img/Screenshot 2026-05-14 at 14.57.44.png>)

Dodatkowo podczas budowaniu obrazu dockera użyłem flagi `--no-cache`.

### Etap build dysponuje potrzebnymi plikami

Dodanie polecenia `ls -la` na początku etapu build.

![Weryfikacja obecności plików](<img/Screenshot 2026-05-14 at 15.13.18.png>)

Wszystkie potrzebne pliki zostały poprawnie skopiowane do katalogu roboczego.

### Podzielenie etapów pipeline'u na osobne kroki, nie budowanie wszystkiego w jednym kroku (build)

W efekcie chcemy mieć osobne obrazy dla każdego etapu: builder, tester, packager i finalny obraz dla deploy. Dzięki temu możemy łatwo zidentyfikować, na którym etapie występuje ewentualny problem i uniknąć sytuacji, w której błąd w jednym etapie wpływa na cały proces. Jak i również zoptymalizować finalny obraz, który będzie lekki i nie będzie zawierał zbędnych plików.

### Aktualizacja Dockerfile

```Dockerfile
# Builder
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Tester
FROM builder AS tester
RUN npm run test

# Runner
FROM node:20-alpine AS runner
WORKDIR /app

# Kopiowanie niezbędnych rzeczy
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/index.js ./
COPY --from=builder /app/lib/ ./lib/

COPY --from=builder /app/examples/ ./examples/

RUN npm install --only=production && npm cache clean --force

# Packager
FROM runner AS packager
RUN apk add --no-cache tar
RUN tar -czf /express-app.tar.gz -C /app .

FROM runner
EXPOSE 3000
CMD ["node", "examples/hello-world/index.js"]

```

### Aktualizacja Jenkinsfile

W każdym etapie dodałem odpowiednie polecenie aby zbudować obraz dla konkretnego targetu.

Zaktualizowany Jenkinsfile:

```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "express-prod-app"
        VERSION = "1.0.${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                sh 'docker rm -f hello-world-app extractor || true'
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh 'docker build --target tester -t express-app-test .'
            }
        }

        stage('Build Artefact') {
            steps {
                sh '''
                    mkdir -p artefact artefact/logs
                    ARTEFACT_NAME="express-app-v${VERSION}.tar.gz"

                    echo "Budowanie paczki (Target: packager)..."
                    docker build --target packager -t express-app-pkg .

                    docker rm -f extractor || true
                    docker create --name extractor express-app-pkg
                    docker cp extractor:/express-app.tar.gz ./artefact/${ARTEFACT_NAME}
                    docker rm -f extractor
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Uruchamianie lekkiego obrazu'
                sh '''
                    docker build -t ${IMAGE_NAME}:latest .

                    docker stop hello-world-app || true
                    docker rm hello-world-app || true

                    docker run -d \
                        -p 3000:3000 \
                        --name hello-world-app \
                        ${IMAGE_NAME}:latest
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
                        echo "Sukces: Aplikacja odpowiada poprawnie"
                        TEST_RESULT=0
                    else
                        echo "Błąd: Brak odpowiedzi Hello World"
                        TEST_RESULT=1
                    fi

                    docker logs hello-world-app > artefact/logs/container_${BUILD_NUMBER}.log 2>&1
                    exit $TEST_RESULT
                '''
            }
        }

        stage('Publish') {
            steps {
                archiveArtifacts artifacts: 'artefact/**', fingerprint: true
            }
        }
    }

    post {
        always {
            echo 'Sprzątanie'
            sh '''
                docker stop hello-world-app || true
                docker rm -f hello-world-app extractor || true
                docker rmi express-app-test express-app-pkg || true
            '''
        }
        success {
            echo "Pipeline zakończony sukcesem! Artefakt v${VERSION} gotowy."
        }
        failure {
            echo 'Pipeline zakończony niepowodzeniem. Sprawdź logi etapów.'
        }
    }
}
```

### Porównanie wielkości obrazów

![Wielkość obrazów](<img/Screenshot 2026-05-14 at 16.58.17.png>)

### Otrzymane artefakty

![Otrzymane artefakty](<img/Screenshot 2026-05-14 at 17.28.38.png>)

![Zawartość artefaktu](<img/Screenshot 2026-05-14 at 17.29.32.png>)

## Wysłanie finalnego obrazu do rejestru lokalnego

```bash
docker run -d -p 5000:5000 --restart=always --name lokalny-rejestr registry:2
docker tag express-prod-app localhost:5000/express-prod-app:v1
docker push localhost:5000/express-prod-app:v1
```

![Weryfikacja wysłania obrazu do rejestru](<img/Screenshot 2026-05-14 at 17.41.53.png>)

## Podsumowanie

Finalny obraz wysłany do rejestru jest lekki i gotowy do uruchomienia. Pobrany artefakt jest gotową do uruchomienia paczką, nie jest wymagana instalacja żadnych dodatkowych zależności, wystarczy rozpakować i uruchomić.

![Podsumowanie](<img/Screenshot 2026-05-14 at 17.45.15.png>)

![Weryfikacja działania aplikacji](<img/Screenshot 2026-05-14 at 17.45.33.png>)

Pipeline działa poprawnie.

![Weryfikacja działania pipeline'u](<img/Screenshot 2026-05-14 at 18.00.01.png>)

## Przygotowanie do kolejnych zajęć: Ansible

### Tworzenie maszyny wirtualnej

```bash
limactl create --name=ansible-target --memory=1 --cpus=1 --disk=10 template://ubuntu
limactl start ansible-target
limactl shell ansible-target
```

![Tworzenie maszyny wirtualnej](<img/Screenshot 2026-05-14 at 18.03.54.png>)

### Instalacja programów i uruchomienie ssh

```bash
sudo apt update && sudo apt install -y tar openssh-server net-tools
sudo systemctl enable --now ssh
```

### Zmiana nazwy hosta

```bash
sudo hostnamectl set-hostname ansible-target
```

Oraz edycja pliku `/etc/hosts`:

![Zmiana nazwy hosta](<img/Screenshot 2026-05-14 at 18.07.46.png>)

### Dodanie użytkownika ansible bez hasła

```bash
sudo adduser ansible # haslo: ansible
sudo usermod -aG sudo ansible
```

![Dodanie użytkownika ansible](<img/Screenshot 2026-05-14 at 18.14.23.png>)

![Weryfikacja dodania użytkownika ansible](<img/Screenshot 2026-05-14 at 18.15.27.png>)

### Skopiowanie klucza ssh do targetu

```bash
ssh-copy-id ansible@192.168.5.15
```

![Skopiowanie klucza ssh do targetu](<img/Screenshot 2026-05-14 at 18.28.20.png>)

### Instalacja Ansible na głównej maszynie

```bash
sudo apt update && sudo apt install -y ansible
```

![Instalacja Ansible na głównej maszynie](<img/Screenshot 2026-05-14 at 20.05.12.png>)

Niestety nie udało mi się połączyć z targetem, mimo poprawnej konfiguracji i skopiowania klucza ssh. Próbowałem wielu sposobów, różnych konfiguracji i rozwiązań, ale niestety bez skutku. Na ten moment nie jestem w stanie zdiagnozować problemu, ale będę dalej próbował i szukał rozwiązania.

## Definition of Done

Powstał pipeline, który buduje aplikację express, testuje ją, pakuje do artefaktu i uruchamia w kontenerze. Pipeline jest podzielony na osobne etapy, a obrazy są zoptymalizowane. Artefaktem jest gotowa do uruchomienia paczka, która nie wymaga instalacji żadnych dodatkowych zależności, musi być jedynie uruchomiona w środowisku z node.js. Tak więc pipeline spełnia wszystkie wymagania procesu CI/CD.
