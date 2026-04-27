# Sprawozdanie zbiorcze - zajęcia 05-07

**Imię i nazwisko:** Mateusz Wiech

**Nr indeksu:** 423393

**Grupa:** 6

**Branch:** MW423393

---

## 0. Środowisko

Ćwiczenie wykonano w środowisku linuksowym (Ubuntu Server 24.04.4 LTS) działającym na maszynie wirtualnej z wykorzystaniem klienta `git` (2.43.0) i `OpenSSH` (9.6p1). Połączenie z maszyną realizowano przez SSH. Repozytorium było obsługiwane z poziomu terminala oraz edytora Visual Studio Code. Wykostano oprogramowanie `Docker` w wersji 28.2.2 oraz `Jenkins` w wersji 2.541.3, uruchomiony w kontenerze Docker.

Wybrano projekt [`merge-anything`](https://github.com/mesqueeb/merge-anything.git), będący biblioteką JavaScript/TypeScript. Projekt udostępnia testy, buduje się przy użyciu `Node.js`, a jego kod może być uruchamiany w izolacji kontenerowej. Udostępniany jest na licencji `MIT`, co pozwala na swobodny obrót kodem na potrzeby zadania.

---

## 1. Cel ćwiczeń

Celem laboratoriów 05–07 było przygotowanie kompletnego procesu CI/CD dla wybranego projektu z wykorzystaniem `Jenkins` oraz `Docker`. Należało uruchomić środowisko budowania oparte na Jenkinsie i DIND, przygotować pipeline realizujący kroki `build -> test -> deploy -> publish`, a następnie przenieść jego definicję z ustawień obiektu Jenkins do repozytorium w postaci pliku `Jenkinsfile`. Finalnym produktem miał być powtarzalny proces budowania i testowania, przygotowujący artefakt redystrybucyjny i możliwy do uruchamiania wielokrotnie bez ręcznego odtwarzania środowiska.

---

## 2. Uruchomienie środowiska Jenkins i pierwszy pipeline

W pierwszym etapie przygotowano środowisko `Jenkins` wraz z kontenerem `DIND` (`Docker-in-Docker`) oraz niestandardowym obrazem `Blue Ocean`, zawierającym klienta Dockera i wymagane pakiety. Jako zadania wstępne utworzono proste projekty testowe (`uname`, sprawdzanie godziny, `docker pull ubuntu`) oraz stworzono pierwszy obiekt typu `pipeline`. Definicja pipeline była wpisywana ręcznie bezpośrednio do konfiguracji obiektu w Jenkinsie. Pipeline pobierał repozytorium przedmiotowe, odnajdywał `Dockerfile` buildera i uruchamiał budowę obrazu.

Uruchomienie obrazu DIND:

```bash
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
```

Stworzenie obrazu blueocean na podstawie obrazu Jenkinsa z `Dockerfile`:

```Dockerfile
FROM jenkins/jenkins:2.541.3-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
```

Uruchomienie blueocean:

```bash
docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:custom
```

![Jenkins dashboard](../Sprawozdanie05/SS/jenkins_dashboard.png)

Utworzony i uruchomiony pipeline:

![Jenkins pipeline script](../Sprawozdanie05/SS/builder-pipeline_script.png)
![Jenkins history](../Sprawozdanie05/SS/builder-pipeline_console.png)
![Jenkins status](../Sprawozdanie05/SS/builder-pipeline_2nd_run_status.png)

`Jenkins` przechowuje historię uruchomień pipeline'u wraz z ich statusem, czasem wykonania, logami konsoli oraz archiwizowanymi artefaktami. Pozwala analizować przebieg kolejnych buildów, identyfikować błędy i pobierać pliki wynikowe przypisane do konkretnego numeru buildu.

---

## 3. Pełna ścieżka krytyczna procesu CI/CD

Opracowano pełny plan pipeline według ścieżki krytycznej `manual trigger -> clone -> build -> test -> deploy -> publish`. Jako projekt wybrano bibliotekę `merge-anything`. Utworzono obrazy `merge-anything-build` i `merge-anything-test`, uruchomiono testy w kontenerze testowym, zdefiniowano etap `Package` przygotowujący artefakt `tar.gz`, etap `Deploy` uruchamiający kontener integracyjny oraz etap `Publish`, archiwizujący artefakty i logi w Jenkinsie.

![builder-pipeline - git clone](../Sprawozdanie06/SS/jenkins_builder-pipeline_clone.png)

---

## 4. Pipeline jako kod (`Jenkinsfile`)

Definicja procesu została przeniesiona z konfiguracji obiektu Jenkins do repozytorium w postaci pliku `Jenkinsfile`. Proces budowania nie żyje wyłącznie w ustawieniach obiektu Jenkins, ale staje się częścią kodu projektu. Zadanie `builder-pipeline` przełączono na tryb `Pipeline script from SCM`, wskazując repozytorium `MDO2026_ITE`, gałąź `MW423393` oraz ścieżkę `grupa6/MW423393/Sprawozdanie06/Jenkinsfile`. Struktura budowania została potraktowana jako część kodu. Pipeline można uruchamiać wielokrotnie, czyści on poprzednie artefakty i logi, korzysta z aktualnych plików `Dockerfile`, przygotowuje artefakt redystrybucyjny i zapisuje go jako rezultat konkretnego buildu w Jenkinsie.

![pipeline from scm](../Sprawozdanie07/SS/pipeline_scm.png)

---

## 5. Architektura procesu CI/CD

Ostateczny proces CI/CD przyjął postać:

`Manual trigger -> SCM checkout -> Build Builder Image -> Build Tester Image -> Test -> Package -> Deploy -> Smoke test -> Publish`

W etapie `Build` tworzony jest obraz `merge-anything-build`, zawierający środowisko uruchomieniowe oparte o `node:18` i `git`, który pobiera repozytorium `merge-anything`, instaluje zależności i wykonuje `npm run build`. Następnie budowany jest obraz `merge-anything-test`, bazujący na obrazie buildowym i służący do uruchamiania testów. Etap `Test` uruchamia kontener `merge-anything-test` i wykonuje automatyczne testy poleceniem `npm test`. Ich wynik jest zapisywany do pliku z numerem builda. Po przejściu testów wykonywany jest etap `Package`, który czyści poprzednie artefakty i logi z katalogu roboczego, po czym przygotowuje nowy artefakt redystrybucyjny. Z obrazu buildowego kopiowane są pliki `dist`, `package.json`, `README.md` i `LICENSE`, a następnie pakowane do archiwum `merge-anything-dist-<BUILD_NUMBER>.tar.gz`. W etapie `Deploy` uruchamiany jest kontener `merge-anything-deploy-<BUILD_NUMBER>`, a poprawność wdrożenia weryfikowana jest przez `Smoke test`, sprawdzający obecność plików w katalogu `/app/dist`. Na końcu etapu `Publish` artefakt i logi są archiwizowane w Jenkinsie.

Końcowa treść pliku `Jenkinsfile`:
```Groovy
pipeline {
    agent any

    stages {
        stage('Build Builder Image') {
            steps {
                dir('grupa6/MW423393/Sprawozdanie06/docker') {
                    sh 'docker build -t merge-anything-build -f Dockerfile.build .'
                }
            }
        }

        stage('Build Tester Image') {
            steps {
                dir('grupa6/MW423393/Sprawozdanie06/docker') {
                    sh 'docker build -t merge-anything-test -f Dockerfile.test .'
                }
            }
        }

        stage('Test') {
            steps {
                sh 'mkdir -p grupa6/MW423393/Sprawozdanie06'
                sh 'docker run --rm merge-anything-test | tee grupa6/MW423393/Sprawozdanie06/test-output-${BUILD_NUMBER}.log'
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                    set -e
                    mkdir -p grupa6/MW423393/Sprawozdanie06/artifact
                    rm -rf grupa6/MW423393/Sprawozdanie06/artifact/*
                    rm -f grupa6/MW423393/Sprawozdanie06/*.tar.gz
                    rm -f grupa6/MW423393/Sprawozdanie06/*.log
        
                    CID=$(docker create merge-anything-build)
                    docker cp ${CID}:/app/dist grupa6/MW423393/Sprawozdanie06/artifact/dist
                    docker cp ${CID}:/app/package.json grupa6/MW423393/Sprawozdanie06/artifact/package.json
                    docker cp ${CID}:/app/README.md grupa6/MW423393/Sprawozdanie06/artifact/README.md
                    docker cp ${CID}:/app/LICENSE grupa6/MW423393/Sprawozdanie06/artifact/LICENSE
                    docker rm ${CID}
        
                    tar -czf grupa6/MW423393/Sprawozdanie06/merge-anything-dist-${BUILD_NUMBER}.tar.gz -C grupa6/MW423393/Sprawozdanie06/artifact .
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f merge-anything-deploy-${BUILD_NUMBER} || true
                    docker run -d --name merge-anything-deploy-${BUILD_NUMBER} merge-anything-build tail -f /dev/null
                '''
            }
        }

        stage('Smoke test') {
            steps {
                sh '''
                    docker exec merge-anything-deploy-${BUILD_NUMBER} ls -la /app/dist | tee grupa6/MW423393/Sprawozdanie06/smoke-test-${BUILD_NUMBER}.log
                    docker exec merge-anything-deploy-${BUILD_NUMBER} test -f /app/dist/index.js
                    cat grupa6/MW423393/Sprawozdanie06/smoke-test-${BUILD_NUMBER}.log
                '''
            }
        }

        stage('Publish') {
            steps {
                archiveArtifacts artifacts: "grupa6/MW423393/Sprawozdanie06/*-${BUILD_NUMBER}.tar.gz,grupa6/MW423393/Sprawozdanie06/*-${BUILD_NUMBER}.log", fingerprint: true
            }
        }
    }

    post {
        always {
            sh 'docker rm -f merge-anything-deploy-${BUILD_NUMBER} || true'
        }
    }
}
```

---

## 6. Wnioski

W trakcie laboratoriów 05–07 udało się przejść od ręcznie definiowanego pipeline w Jenkinsie do pełnego procesu CI/CD zapisanego w pliku `Jenkinsfile` i przechowywanego w repozytorium. Najważniejsze było zbudowanie kompletnej i działającej ścieżki, uruchamianej wielokrotnie i generującej wersjonowane artefakty. Proces wykorzystuje izolację kontenerową, rozdzielenie obrazu buildowego i testowego, archiwizację logów oraz integracyjne wdrożenie kontenera docelowego. Na końcu procesu powstaje artefakt możliwy do wdrożenia w sensie integracyjnym: archiwum `merge-anything-dist-<BUILD_NUMBER>.tar.gz` oraz uruchomiony kontener deploy. Sam artefakt ma charakter redystrybucyjny i może zostać wykorzystany na maszynie o oczekiwanej konfiguracji docelowej, wyposażonej w odpowiednie środowisko uruchomieniowe. Ostateczne rozwiązanie nie jest jeszcze produkcyjnym systemem publikacji obrazu runtime, ale stanowi poprawnie działający proces CI/CD na potrzeby laboratoriów.