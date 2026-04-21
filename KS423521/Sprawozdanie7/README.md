# Sprawozdanie z zajęć nr 6

- **Imię i nazwisko:** Kacper Strzesak
- **Indeks:** 423521
- **Kierunek:** Informatyka techniczna
- **Grupa**: 5

---

## 1. Środowisko pracy

Zadania wykonano na systemie Ubuntu Server 24.04.4 LTS uruchomionym na platformie VirtualBox. Połączenie z maszyną zrealizowano za pomocą protokołu SSH (użytkownik: kacper).

---

## 2. Rozwinięcie pipeline'u CI/CD – Jenkinsfile

Plik Jenkinsfile znajduje się w repozytorium projektu i został umieszczony tam już podczas Laboratorium 6, natomiast w ramach bieżących zajęć został on zaktualizowany.

Plik **[Jenkinsfile](./Jenkinsfile)**:

```groovy
pipeline {
    agent any

    environment {
        VERSION = "1.0.${BUILD_NUMBER}"
        IMAGE = "markdown-it"
        CONTAINER = "md-${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh "docker build --target test -t ${IMAGE}:${VERSION}-test ."
            }
        }

        stage('Build Image (Deploy)') {
            steps {
                sh "docker build --target deploy -t ${IMAGE}:${VERSION} ."
            }
        }

        stage('Run Deploy Container') {
            steps {
                sh "docker run -d --name ${CONTAINER} ${IMAGE}:${VERSION}"
            }
        }

        stage('Archive') {
            steps {
                sh "docker save ${IMAGE}:${VERSION} -o ${IMAGE}-${VERSION}.tar"
                archiveArtifacts artifacts: '*.tar', fingerprint: true
            }
        }
    }

    post {
        always {
            sh "docker rm -f ${CONTAINER} || true"
            sh "docker rmi ${IMAGE}:${VERSION} || true"
        }
    }
}
```

- [x] Przepis dostarczany z SCM, a nie wklejony w Jenkinsa lub sprawozdanie (co załatwia nam `clone` )

---

## 3. Opis pipeline’u

#### Clean (usunięcie cache)

```groovy
stage('Clean') {
    steps {
        deleteDir()
    }
}
```

Zapewnia pracę na świeżym kodzie i eliminuje problem cache.

- [x] Posprzątaliśmy i wiemy, że odbyło się to skutecznie - mamy pewność, że pracujemy na najnowszym (a nie *cache'owanym* kodzie)

#### Checkout (clone repozytorium)

```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

Pipeline pobiera aktualny kod z repozytorium.

- [x] Etap `Build` dysponuje repozytorium i plikami `Dockerfile`

#### Build i Test

```groovy
stage('Build & Test') {
    steps {
        sh "docker build --target test -t ${IMAGE}:${VERSION}-test ."
    }
}
```

Tworzony jest obraz buildowy (testowy), wykorzystywany w kolejnych etapach. Wykonywane są testy.

- [x] Etap `Build` tworzy obraz buildowy, np. `BLDR`
- [x] Etap `Test` przeprowadza testy

---

#### Build (Deploy Image)

```groovy
stage('Build Image (Deploy)') {
    steps {
        sh "docker build --target deploy -t ${IMAGE}:${VERSION} ."
    }
}
```

Tworzony jest finalny obraz aplikacji przeznaczony do wdrożenia.

#### Deploy

```groovy
stage('Run Deploy Container') {
    steps {
        sh "docker run -d --name ${CONTAINER} ${IMAGE}:${VERSION}"
    }
}
```

Kontener aplikacji zostaje uruchomiony (wdrożenie w środowisku testowym).

- [x] Etap `Deploy` przeprowadza wdrożenie (start kontenera docelowego lub uruchomienie aplikacji na przeznaczonym do tego celu kontenerze sandboxowym)

## 4. Definition of Done

1. > Czy opublikowany obraz może być pobrany z Rejestru i uruchomiony w Dockerze **bez modyfikacji** (acz potencjalnie z szeregiem wymaganych parametrów, jak obraz DIND)? Nie chcemy posyłać w świat czegoś, co działa tylko u nas!

2. > Czy dołączony do jenkinsowego przejścia artefakt, gdy pobrany, ma szansę zadziałać **od razu** na maszynie o oczekiwanej konfiguracji docelowej?