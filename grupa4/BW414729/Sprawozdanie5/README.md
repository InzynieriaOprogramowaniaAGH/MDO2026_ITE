```
uname -a
```


```
#!/bin/bash
# Wymuszamy czas warszawski tylko dla tej jednej komendy
HOUR=$(TZ="Europe/Warsaw" date +%-H)

echo "Aktualna godzina na serwerze to: $HOUR"

if [ $((HOUR % 2)) -ne 0 ]; then
    echo "BŁĄD: Godzina jest nieparzysta!"
    exit 1
else
    echo "SUKCES: Godzina jest parzysta!"
    exit 0
fi
```

```
docker pull ubuntu:latest
```

```
docker exec -u 0 -it jenkins-blueocean bash -c "apt-get update && apt-get install -y docker.io"
```


```
pipeline {
    agent any

    stages {
        stage('1. SCM Checkout') {
            steps {
                echo 'Klonowanie repozytorium przedmiotowego...'
                // Poprawiony URL i wskazanie Twojej gałęzi (BW414729)
                git branch: 'BW414729', url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git'
            }
        }

        stage('2. Docker Build') {
            steps {
                echo 'Budowanie obrazu z folderu Sprawozdanie5...'
                script {
                    // Wchodzimy do katalogu sprawozdania i tam odpalamy build
                    dir('grupa4/BW414729/Sprawozdanie4') {
                        sh 'docker build -t moj-program-builder .'
                    }
                }
            }
        }

        stage('3. Weryfikacja') {
            steps {
                sh 'uname -a'
                sh 'docker images | grep moj-program-builder'
            }
        }
    }

    post {
        success {
            echo 'Pipeline zakończony sukcesem! Uruchom go teraz drugi raz dla testu cache.'
        }
    }
}
```