# Lab 5: Pipeline, Jenkins, izolacja etapów

### Przygotowania
Tworzenie obrazów zostało dokonane na poprzednich zajęciach - jednak błędne zostały połączone ze sobą certyfikaty, co spowodowało problemy z połączeniem się z *jenkins-docker*, dlatego jeszcze raz stworzony został obraz *jenkins-blueocean* na podstawie dockerfile:

![](1dockerfile.png)
![](my-jenkins.png)


#### Oba kontenery działają
![](kontenery.png)

### Logowanie w przeglądarce
Dzięki komendzie `docker logs jenkins-blueocean` przy pierwszym uruchomieniu, możemy podejrzeć hasło do Jenkins

**Tworzenie konta:**   
![](tworzenie-admin.png)

**Konfiguracja instancji:**   
![](1c.png)

**Pomyślne zalogowanie:**   
![](1d.png)

### Tworzenie zadań
**zadanie-uname:**   

```
pipeline {
    agent any
    stages {
        stage('Wyświetl info o systemie') {
            steps {
                sh 'uname -a'
            }
        }
    }
}
```

![](zadanie-uname.png)

**zadanie-godzina:**

```
pipeline {
    agent any
    stages {
        stage('Sprawdzanie godziny') {
            steps {
                sh '''
                HOUR=$(date +%H)
                echo "Aktualna godzina: $HOUR"
                if [ $((HOUR % 2)) -ne 0 ]; then
                    echo "BŁĄD: Godzina $HOUR jest nieparzysta!"
                    exit 1
                else
                    echo "Godzina $HOUR jest parzysta. Wszystko OK."
                fi
                '''
            }
        }
    }
}
```

![](zadanie-godzina.png)

**zadanie-docker:**

```
pipeline {
    agent any
    stages {
        stage('Docker Pull') {
            steps {
                sh 'docker pull ubuntu:latest'
                sh 'docker images | grep ubuntu'
            }
        }
    }
}
```

W tym miejscu można zobaczyć że docker nie mógł odnaleźć folderu z certyfikatami.

![](zadanie-docker-b.png)


dlatego należało uruchomić go z poprawioną ścieżką i skrypt przeszedł pomyślnie:

![](zadanie-docker.png)


### Uruchomienie buildera w Jenkins - oba pliki wrzucone na Github'a
**Docker.build**

![](dockerbuild.png)

**Docker.test**

![](dockertest.png)


**skrypt pipeline**

```
pipeline {
    agent any
    stages {
        stage('Clone Branch') {
            steps {
                git branch: 'WW420972', url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git'
            }
        }
        stage('Build Image') {
            steps {
                sh 'docker build -t moj-budowniczy -f WW420972/lab5/docker-setup/Dockerfile.build WW420972/lab5/'
            }
        }
    }
}
```

![](1-uruchomienie.png)
![](2-uruchomienie.png)

**Różnica w czasie -** jest spowodowana cachowaniem, zapamiętany został poprzedni stan, dlatego nie trzeba było ponownie instalować
