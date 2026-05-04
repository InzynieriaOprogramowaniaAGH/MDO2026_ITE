## Sprawozdanie zbiorcze lab 5 - 7

### Jenkins

Jenkins to open-source serwer automatyzacji pozwalający na budowanie i wdrażanie aplikacji w rach procesów CI/CD.

Do uruchamiania Jenkinsa potrzebny jest docker, dzięki któremu możemy uruchomić potrzebne do funkcjonowania Jenkinsa:
-sieć
-Kontener Docker-in-Docker
-Kontenera Jenkins
Dodatkowo dla projektów pipeline mogą być potrzebne
-klient Dockera s kontenerze Jenkins
-konfiguracja insecure-registry

### Projekty Jenkins

Jenkins pozwala na uruchomienie różnego rodzaju projektów, w ramach zajęć zostały zaimplementowane projekty typu:  
-Freestyle - proste projekty konfigurowane w GUI, łatwe w implementacji ale przeznaczone dla podstawowej funkcjonalności. Przykładowe projekty wykonywane w ramach laboratorium wykonywały prosty kod shell.  
-Pipeline - Projekty z kontrolą przepływu podzielone na etapy, wersjonowane, wykonywane zgodnie z plikiem Jenkinsfile preferowalnie pobieranym z zewnętrznego SCP, na przykład git.

### laboratorium 5

Celem tego laboratorium było pierwsze uruchomienie Jenkinsa Poprzez stworzenie wyrzej wymienionych kontenerów.
Następnie należało utworzyć dwa projekty freestyle wykonujące kod shell:  
-Wypisujący uname.  
-Zwracający błąd jeśli godzina była parzysta.  
Oraz projekt pipeline, który pobierał repozytorium z kodem aplikacji, przechodził na wskazaną gałąź i budował obraz Dockera z projektem testowym.
Laboratorium pozwoliło na wstępne zapoznanie się ze środowiskiem Jenkins.

### laboratorium 6

W ramach szóstego laboratorium zaprojektowano i zaimplementowano kompletny pipeline CI/CD. Aplikacja testowa (program w C wypisujący „Hello”) została wybrana, zweryfikowana pod kątem licencji i poprawności budowy. Pipeline obejmował następujące etapy:  
-Checkout – pobranie kodu z repozytorium wraz z identyfikacją SHA commita.  
-Build and Test – budowa obrazu budującego (gcc:latest), uruchomienie make, make test wewnątrz kontenera oraz zarchiwizowanie artefaktu binarnego.  
-Deploy & Smoke Test – utworzenie lekkiego obrazu wdrożeniowego na bazie alpine:latest, skopiowanie skompilowanego pliku binarnego, uruchomienie kontenera i weryfikacja obecności słowa „Hello” w logu (smoke test).  
-Publish – otagowanie obrazu wersją 1.0.${BUILD_NUMBER} oraz latest, a następnie publikacja do lokalnego rejestru Docker (docker:5000).

### laboratorium 7

Laboratorium polegało na upewnieniu się że zaimplementowany pipeline nie istniał wyłącznie w ustawieniach w Jenkins ale był wdrożony z zewnątrz, w tym celu sprawdzono czy spełnie wszystkie wymagania z listy:
- [X] Przepis dostarczany z SCM, a nie wklejony w Jenkinsa lub sprawozdanie (co załatwia nam `clone` )
- [X] Posprzątaliśmy i wiemy, że odbyło się to skutecznie - mamy pewność, że pracujemy na najnowszym (a nie *cache'owanym* kodzie)
- [X] Etap `Build` dysponuje repozytorium i plikami `Dockerfile`
- [X] Etap `Build` tworzy obraz buildowy, np. `BLDR`
- [X] Etap `Build` (krok w tym etapie) lub oddzielny etap (o innej nazwie), przygotowuje artefakt - **jeżeli docelowy kontener ma być odmienny**, tj. nie wywodzimy `Deploy` z obrazu `BLDR`
- [X] Etap `Test` przeprowadza testy
- [X] Etap `Deploy` przygotowuje **obraz lub artefakt** pod wdrożenie. W przypadku aplikacji pracującej jako kontener, powinien to być obraz z odpowiednim entrypointem. W przypadku buildu tworzącego artefakt niekoniecznie pracujący jako kontener (np. interaktywna aplikacja desktopowa), należy przesłać i uruchomić artefakt w środowisku docelowym.
- [X] Etap `Deploy` przeprowadza wdrożenie (start kontenera docelowego lub uruchomienie aplikacji na przeznaczonym do tego celu kontenerze sandboxowym)
- [X] Etap `Publish` wysyła obraz docelowy do Rejestru i/lub dodaje artefakt do historii builda
- [X] Ponowne uruchomienie naszego *pipeline'u* powinno zapewniać, że pracujemy na najnowszym (a nie *cache'owanym*) kodzie. Innymi słowy, *pipeline* musi zadziałać więcej niż jeden raz 😎

Jedyne poprawki zostały wdrożone dopiero w celu zapewnienia działania pobieranego obrazu z rejestru.

Finalny kod Jenkinsfile po wszystkich laboratoriach przedstawiał się następująco:

pipeline {
    agent any
    
    environment {
        APP_VERSION = "1.0.${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = "docker:5000"
        IMAGE_NAME = "${DOCKER_REGISTRY}/hello-c-app"
        GIT_COMMIT_SHORT = ""
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script { env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim() }
                echo "Commit: ${env.GIT_COMMIT_SHORT}"
            }
        }

                        stage('Build and Test') {
            steps {
                dir('grupa2/MF419850/test_project') {
                    sh 'docker build -t hello-build .'
                    sh 'docker run --rm hello-build sh -c "make clean && make && make test"'
                    sh 'docker cp $(docker create hello-build):/app/hello .'
                    stash includes: 'hello', name: 'hello-binary'
                }
            }
        }

        stage('Deploy & Smoke Test') {
            steps {
                unstash 'hello-binary'
                sh """
                    docker build -f - -t ${IMAGE_NAME}:${APP_VERSION} . <<'DOCKERFILE'
FROM alpine:latest
COPY hello /app/hello
RUN chmod +x /app/hello
CMD ["/app/hello"]
DOCKERFILE
                """
                sh "docker run --rm ${IMAGE_NAME}:${APP_VERSION} > output.log"
                script {
                    def log = readFile 'output.log'
                    if (!log.contains('Hello')) { error("Smoke test failed: ${log}") }
                    echo "Smoke test OK: ${log}"
                }
            }
        }

        stage('Publish') {
            steps {
                sh "docker tag ${IMAGE_NAME}:${APP_VERSION} ${IMAGE_NAME}:latest"
                sh "docker push ${IMAGE_NAME}:${APP_VERSION} || true"
                sh "docker push ${IMAGE_NAME}:latest || true"
                archiveArtifacts artifacts: 'hello', fingerprint: true
            }
        }
    }

    post {
        always { cleanWs() }
        success { echo "SUKCES: ${APP_VERSION}" }
        failure { echo "BŁĄD" }
    }
}