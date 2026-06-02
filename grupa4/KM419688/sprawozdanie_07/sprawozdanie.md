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

# Przygotowanie do kolejnych zajęć: Ansible

## Tworzenie maszyny wirtualnej

```bash
limactl create --name=ansible-target --memory=1 --cpus=1 --disk=10 template://ubuntu
limactl start ansible-target
limactl shell ansible-target
```

![Tworzenie maszyny wirtualnej](<img/Screenshot 2026-05-14 at 18.03.54.png>)

## Instalacja programów i uruchomienie ssh

```bash
sudo apt update && sudo apt install -y tar openssh-server net-tools
sudo systemctl enable --now ssh
```

## Zmiana nazwy hosta

```bash
sudo hostnamectl set-hostname ansible-target
```

Oraz edycja pliku `/etc/hosts`:

![Zmiana nazwy hosta](<img/Screenshot 2026-05-14 at 18.07.46.png>)

## Dodanie użytkownika ansible bez hasła

```bash
sudo adduser ansible # haslo: ansible
sudo usermod -aG sudo ansible
```

![Dodanie użytkownika ansible](<img/Screenshot 2026-05-14 at 18.14.23.png>)

![Weryfikacja dodania użytkownika ansible](<img/Screenshot 2026-05-14 at 18.15.27.png>)

## Skopiowanie klucza ssh do targetu

```bash
ssh-copy-id ansible@192.168.5.15
```

![Skopiowanie klucza ssh do targetu](<img/Screenshot 2026-05-14 at 18.28.20.png>)

## Instalacja Ansible na głównej maszynie

```bash
sudo apt update && sudo apt install -y ansible
```

![Instalacja Ansible na głównej maszynie](<img/Screenshot 2026-05-14 at 20.05.12.png>)

Niestety nie udało mi się połączyć z targetem, mimo poprawnej konfiguracji i skopiowania klucza ssh. Próbowałem wielu sposobów, różnych konfiguracji i rozwiązań, ale niestety bez skutku. Na ten moment nie jestem w stanie zdiagnozować problemu, ale będę dalej próbował i szukał rozwiązania.

# Definition of Done

Powstał pipeline, który buduje aplikację express, testuje ją, pakuje do artefaktu i uruchamia w kontenerze. Pipeline jest podzielony na osobne etapy, a obrazy są zoptymalizowane. Artefaktem jest gotowa do uruchomienia paczka, która nie wymaga instalacji żadnych dodatkowych zależności, musi być jedynie uruchomiona w środowisku z node.js. Tak więc pipeline spełnia wszystkie wymagania procesu CI/CD.
