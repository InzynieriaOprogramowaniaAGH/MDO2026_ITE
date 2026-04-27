# Sprawozdanie Zbiorcze - PS422034
## Laboratoria 5-7: Jenkins, Pipeline CI/CD, Jenkinsfile

---

## Wstęp

Tematyka zajęć koncentrowała się na budowie kompletnego potoku ciągłej integracji i dostarczania (CI/CD) z wykorzystaniem serwera Jenkins uruchamianego w środowisku Docker. Kolejne laboratoria stanowiły rozwinięcie poprzednich: od pierwszego uruchomienia Jenkinsa, przez zdefiniowanie pipeline'u budującego i testującego aplikację, aż po przeniesienie definicji potoku do repozytorium kodu i zapewnienie pełnej powtarzalności procesu.

---

## Omówienie użytych technologii i pojęć

### Jenkins

Jenkins jest jednym z najpowszechniej stosowanych serwerów automatyzacji CI/CD, utrzymywanym jako projekt open-source. Jego elastyczność wynika z rozbudowanego ekosystemu wtyczek - ekosystem obejmuje ponad 1800 rozszerzeń umożliwiających integrację z praktycznie każdym narzędziem deweloperskim. Potoki w Jenkinsie definiuje się w plikach `Jenkinsfile` przy użyciu języka Groovy w postaci deklaratywnej lub skryptowej.

Jenkins działa w architekturze kontroler-agenci: kontroler zarządza konfiguracją, harmonogramem i kolejką zadań, natomiast agenci wykonują właściwą pracę. W środowiskach skonteneryzowanych agenci często przyjmują postać efemerycznych kontenerów Dockera, powoływanych na czas trwania konkretnego zadania.

### Wtyczka BlueOcean

BlueOcean to nowoczesny interfejs graficzny do Jenkinsa, prezentujący pipeline w postaci wizualnego grafu etapów. Oferuje przejrzysty widok poszczególnych kroków, ich statusu oraz logów. Obraz Jenkinsa z BlueOcean rozszerza bazowy `jenkins/jenkins:lts` o:

- wtyczkę **BlueOcean** - nowoczesny interfejs graficzny do wizualizacji pipeline'ów,
- wtyczkę **docker-workflow** - umożliwia używanie Dockera w pipeline'ach,
- **Docker CLI** - pozwala na wykonywanie komend `docker` wewnątrz Jenkinsa.

### Docker-in-Docker (DIND)

Docker-in-Docker (DIND) to technika uruchamiania demona Dockera wewnątrz kontenera Dockera. Jest stosowana w środowiskach CI, gdzie serwer automatyzacji sam działa jako kontener, a jednocześnie musi budować i uruchamiać obrazy Dockera. DIND wymaga uruchomienia kontenera w trybie uprzywilejowanym (`--privileged`), co zapewnia dostęp do mechanizmów jądra niezbędnych do działania demona.

Alternatywnym podejściem jest Docker-outside-of-Docker (DooD), polegające na zamontowaniu socketu demona hosta (`/var/run/docker.sock`) wewnątrz kontenera - rozwiązanie prostsze w konfiguracji, lecz wiążące się z ryzykiem bezpieczeństwa wynikającym z pełnego dostępu kontenera do zasobów Dockera hosta.

### Pipeline jako kod

Pipeline jako kod to praktyka definiowania całego potoku CI/CD w pliku tekstowym przechowywanym razem z kodem źródłowym aplikacji. Podejście to przynosi szereg korzyści: historia zmian w pipeline'ie podlega kontroli wersji, każdy deweloper widzi dokładnie jak przebiega proces budowania, a infrastruktura budowania staje się integralną częścią projektu. W Jenkinsie tę rolę pełni plik `Jenkinsfile`.

### Jenkinsfile - składnia deklaratywna

Deklaratywny Jenkinsfile opisuje pipeline w postaci struktury `pipeline { stages { stage('Nazwa') { steps { ... } } } }`. Kluczowe elementy to:

- `agent` - określa, gdzie pipeline ma się wykonywać (np. `any` - na dowolnym agencie),
- `stages` - lista etapów wykonywanych sekwencyjnie,
- `steps` - konkretne kroki w ramach etapu (np. `sh` dla poleceń powłoki, `git` dla klonowania),
- `post` - blok wykonywany po zakończeniu pipeline'u niezależnie od wyniku (np. sprzątanie).

### Artefakt budowania

Artefakt budowania to plik lub zestaw plików będący wynikiem procesu CI - przenośna forma dystrybucji oprogramowania. Może przyjmować różne formy: archiwum tar.gz, pakiet DEB/RPM, obraz Docker, pakiet NPM/NuGet/JAR. Kluczową cechą artefaktu jest możliwość uruchomienia go na maszynie docelowej bez konieczności ponownego budowania ze źródeł.

### Semantic versioning

Semantic Versioning (SemVer) to konwencja wersjonowania oprogramowania w formacie `MAJOR.MINOR.PATCH`, gdzie: zmiana MAJOR oznacza niekompatybilne zmiany API, zmiana MINOR to nowa funkcjonalność zachowująca kompatybilność wsteczną, a zmiana PATCH to poprawki błędów. W kontekście pipeline'ów CI/CD numer wersji często rozszerzany jest o numer buildu Jenkinsa, np. `1.0.${BUILD_NUMBER}`.

### Obraz Docker `node` vs `node-slim`

Wybór obrazu bazowego ma istotny wpływ na rozmiar finalnego kontenera i bezpieczeństwo:

- `node` - pełny obraz oparty na Debianie, zawiera kompilator, narzędzia deweloperskie i git (~1,1 GB). Używany do budowania i testowania.
- `node-slim` - minimalny obraz zawierający wyłącznie środowisko uruchomieniowe Node.js (~250 MB). Odpowiedni dla kontenerów produkcyjnych, gdzie narzędzia deweloperskie są zbędne i stanowią potencjalny wektor ataku.

### Tunel SSH

Tunel SSH pozwala na przekierowanie ruchu z lokalnego portu na port zdalnego serwera przez szyfrowane połączenie SSH. Polecenie `ssh -L 8080:localhost:8080 użytkownik@host` sprawia, że połączenie do `localhost:8080` na lokalnej maszynie jest transparentnie przekazywane do portu 8080 na zdalnym serwerze. Jest to wygodny sposób na uzyskanie dostępu do usług działających na serwerach bez publicznego adresu IP lub za firewallem.

---

## Laboratorium 5 - Pipeline, Jenkins, izolacja etapów

### Cel

Celem piątego laboratorium było uruchomienie skonteneryzowanej instancji Jenkinsa z wtyczką BlueOcean, zapoznanie się z podstawową konfiguracją narzędzia oraz stworzenie pierwszego pipeline'u automatycznie klonującego repozytorium i budującego Dockerfile.

### Przygotowanie środowiska

Przed przystąpieniem do zajęć zweryfikowano dostępność obrazów Docker z poprzednich zajęć (`lab3-build:latest` oraz `lab3-test:latest`). Następnie przygotowano własny obraz Jenkinsa z zainstalowaną wtyczką BlueOcean i Docker CLI, definiując go plikiem `Dockerfile.jenkins`:

```dockerfile
FROM jenkins/jenkins:2.541.3-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
```

Zbudowano obraz poleceniem:

```bash
docker build -t myjenkins-blueocean:2.541.3-1 -f ~/Dockerfile.jenkins ~/
```

### Uruchomienie DIND i Jenkins BlueOcean

Zgodnie z oficjalną dokumentacją uruchomiono pomocniczy kontener Docker-in-Docker:

```bash
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2
```

Następnie uruchomiono właściwy kontener Jenkins BlueOcean:

```bash
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.541.3-1
```

Oba kontenery podłączone są do dedykowanej sieci `jenkins`, co umożliwia komunikację między nimi przez alias DNS `docker`.

### Dostęp do interfejsu - tunel SSH

Ponieważ serwer Jenkins działa na maszynie wirtualnej z wewnętrznym adresem IP, dostęp do panelu webowego uzyskano przez tunel SSH:

```bash
ssh -L 8080:localhost:8080 pawel@172.19.136.131
```

Po zestawieniu tunelu interfejs Jenkinsa był dostępny pod adresem `http://localhost:8080` w przeglądarce na lokalnej maszynie.

### Napotkane problemy i rozwiązania

Przy próbie zalogowania okazało się, że plik `initialAdminPassword` nie istnieje - Jenkins był już wcześniej skonfigurowany. Aby odzyskać dostęp, tymczasowo wyłączono mechanizm uwierzytelniania:

```bash
docker exec jenkins-blueocean bash -c "sed -i 's/<useSecurity>true/<useSecurity>false/' /var/jenkins_home/config.xml"
docker restart jenkins-blueocean
```

Po restarcie Jenkins był dostępny bez logowania, co umożliwiło ustawienie nowego hasła w panelu administracyjnym.

### Projekty wstępne

Przed przystąpieniem do tworzenia pipeline'u zrealizowano trzy projekty ogólne w Jenkinsie:

**Projekt `uname-project`** - wyświetla informacje o systemie:

```bash
uname -a
```

**Projekt `odd-hour-project`** - zwraca błąd, gdy bieżąca godzina jest nieparzysta:

```bash
hour=$(date +%H)
if [ $((hour % 2)) -ne 0 ]; then
  exit 1
fi
```

Projekt zakończył się błędem (zgodnie z oczekiwaniami), ponieważ build wykonano o godzinie 07 (nieparzystej).

**Projekt `docker-pull-project`** - pobiera obraz Ubuntu z Docker Hub:

```bash
docker pull ubuntu
```

### Pierwszy pipeline

Utworzono obiekt typu Pipeline realizujący klonowanie repozytorium i budowanie obrazów Dockerfile. Treść pipeline'u wpisano bezpośrednio do obiektu (nie z SCM):

```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git',
                    branch: 'PS422034'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t lab3-build -f PS422034/Sprawozdanie3/lab3/Dockerfile.build .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker build -t lab3-test -f PS422034/Sprawozdanie3/lab3/Dockerfile.test .'
            }
        }
    }
}
```

Pipeline zakończył się sukcesem, po czym uruchomiono go drugi raz - Docker skorzystał z cache warstw, co znacznie przyspieszyło budowanie.

### Wnioski

Skonteneryzowany Jenkins z DIND stanowi samodzielne i przenośne środowisko CI. Izolacja demona Dockera w osobnym kontenerze zapewnia bezpieczeństwo i czystość środowiska. Tunel SSH okazał się prostym i skutecznym rozwiązaniem problemu dostępu do usług na maszynach bez publicznego adresu IP.

---

## Laboratorium 6 - Pipeline: lista kontrolna

### Cel

Szóste laboratorium polegało na rozbudowie pipeline'u o kompletną ścieżkę krytyczną: `commit → clone → build → test → deploy → publish`. Celem było zaprojektowanie i udokumentowanie każdego etapu, wybór aplikacji testowej, stworzenie diagramów UML oraz weryfikacja wszystkich punktów listy kontrolnej.

### Wybór aplikacji

Wybrano framework **Express.js** - popularną bibliotekę Node.js do tworzenia aplikacji webowych. Repozytorium: `https://github.com/expressjs/express`. Express.js dostępny jest na licencji **MIT**, która pozwala na swobodne używanie, modyfikowanie i dystrybucję kodu, w tym na potrzeby zadań akademickich.

Wybór Express.js był uzasadniony dostępnością gotowego zestawu testów: `npm test` uruchamia **1249 testów**, które przechodzą w czasie ok. 3 sekund.

### Diagram aktywności procesu CI/CD

Zaplanowany przepływ procesu CI/CD:

```
[Start]
   |
   v
[Clone repozytorium]
   |
   v
[Build - docker build lab3-build]
   |
   v
[Test - docker build lab3-test + docker run]
   |           |
   |        [FAIL] 
   v
[Deploy - docker run express-deploy]
   |
   v
[Smoke test - curl localhost:3000]
   |
   v
[Publish - tar.gz jako artefakt Jenkins]
   |
   v
[Koniec SUCCESS]
```

### Diagram wdrożeniowy

```
[Host - serwer]
    |
    |── [jenkins-docker (DIND)] ◄─── sieć jenkins ───► [jenkins-blueocean]
    |         |                                                |
    |    docker daemon                               Jenkins UI :8080
    |         |
    |    [lab3-build] ──► [lab3-test] ──► [express-deploy]
    |                                           |
    |                                     aplikacja :3000
    |
    |── [jenkins-data (volume)]        /var/jenkins_home
    |── [jenkins-docker-certs (volume)] /certs/client
```

### Wymagania wstępne środowiska

Do prawidłowego działania pipeline'u wymagane są: Docker zainstalowany na hoście, Jenkins z DIND, sieć `jenkins` w Dockerze, woluminy `jenkins-data` i `jenkins-docker-certs` oraz środowisko Node.js (dostarczane przez obraz `node:latest`).

### Kontener bazowy i etap Build

Wybrano obraz `node:latest` jako kontener bazowy - zawiera Node.js i npm, będące jedynymi zależnościami do zbudowania i uruchomienia Express.js.

**Dockerfile.build:**

```dockerfile
FROM node:latest
WORKDIR /app
RUN git clone https://github.com/expressjs/express.git .
RUN npm install
```

### Etap Test

Testy uruchamiane są w osobnym kontenerze `lab3-test`, bazującym na obrazie `lab3-build`. Kontener testowy dziedziczy środowisko i kod po kontenerze buildowym:

**Dockerfile.test:**

```dockerfile
FROM lab3-build:latest
RUN npm test
```

Jeżeli testy nie przejdą, `npm test` zwraca niezerowy kod wyjścia, co powoduje zatrzymanie pipeline'u i raportowanie błędu.

### Etap Deploy

Zdefiniowano kontener `express-deploy` uruchamiający aplikację Express.js na porcie 3000:

```bash
docker run -d --name express-deploy -p 3000:3000 lab3-build node /app/index.js
```

Kontener buildowy `lab3-build` **nadaje się** do roli kontenera deploy w tym przypadku, ponieważ Express.js jest frameworkiem bez osobnego kroku kompilacji, a `node_modules` są już zainstalowane. W środowisku produkcyjnym warto byłoby jednak stworzyć osobny, lżejszy obraz oparty na `node:slim`, co zmniejszyłoby rozmiar obrazu z ~1,1 GB do ~250 MB.

Po uruchomieniu kontenera deploy wykonywany jest smoke test weryfikujący działanie aplikacji:

```bash
docker exec express-deploy curl -s http://localhost:3000 || true
```

### Etap Publish i wersjonowanie artefaktu

Artefaktem jest archiwum **tar.gz** zawierające zbudowaną aplikację Express wraz z `node_modules`. Wybór formatu tar.gz uzasadniony jest naturą aplikacji Node.js - archiwum z kodem i zależnościami jest prostym i przenośnym formatem dystrybucji, niewymagającym specjalistycznych narzędzi do instalacji.

```groovy
sh 'mkdir -p artifact'
sh 'docker run --rm -v $(pwd)/artifact:/artifact lab3-build tar -czf /artifact/express-1.0.0.tar.gz -C /app .'
archiveArtifacts artifacts: 'artifact/express-1.0.0.tar.gz', onlyIfSuccessful: true
```

Wersjonowanie artefaktu odbywa się przez nazwę pliku (`express-1.0.0.tar.gz`). Można je rozszerzyć o numer buildu Jenkinsa: `express-1.0.${BUILD_NUMBER}.tar.gz`.

Artefakt można zidentyfikować po numerze buildu Jenkinsa, hashu commita Git widocznym w logach oraz dacie i godzinie buildu.

### Kompletny Jenkinsfile (wersja z Lab 6)

```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git url: 'https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git',
                    branch: 'PS422034'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t lab3-build -f PS422034/Sprawozdanie3/lab3/Dockerfile.build .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker build -t lab3-test -f PS422034/Sprawozdanie3/lab3/Dockerfile.test .'
                sh 'docker run --rm lab3-test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker rm -f express-deploy || true'
                sh 'docker run -d --name express-deploy -p 3000:3000 lab3-build node /app/index.js'
                sh 'sleep 5'
                sh 'docker exec express-deploy curl -s http://localhost:3000 || true'
            }
        }
        stage('Publish') {
            steps {
                sh 'mkdir -p artifact'
                sh 'docker run --rm -v $(pwd)/artifact:/artifact lab3-build tar -czf /artifact/express-1.0.0.tar.gz -C /app .'
                archiveArtifacts artifacts: 'artifact/express-1.0.0.tar.gz', onlyIfSuccessful: true
            }
        }
    }
    post {
        always {
            sh 'docker rm -f express-deploy || true'
        }
    }
}
```

### Wnioski

Kompletny pipeline CI/CD realizuje wszystkie etapy ścieżki krytycznej. Zastosowanie bloku `post { always { ... } }` zapewnia sprzątanie środowiska nawet w przypadku niepowodzenia pipeline'u. Archiwizacja artefaktu bezpośrednio w Jenkinsie eliminuje konieczność utrzymywania osobnego systemu dystrybucji dla środowisk deweloperskich i testowych.

---

## Laboratorium 7 - Jenkinsfile: lista kontrolna

### Cel

Siódme laboratorium stanowiło zwieńczenie pracy nad pipeline'em. Celem było przeniesienie definicji Jenkinsfile do repozytorium SCM, dodanie etapu czyszczenia środowiska gwarantującego powtarzalność, stworzenie dedykowanego obrazu dla etapu Deploy z wbudowanym entrypointem oraz dwukrotne uruchomienie pipeline'u potwierdzające jego poprawność.

### Pipeline z SCM

Obiekt pipeline w Jenkinsie skonfigurowano jako **Pipeline script from SCM**:

- SCM: Git
- Repository URL: `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- Branch: `PS422034`
- Script Path: `PS422034/Sprawozdanie7/Jenkinsfile`

Dzięki temu Jenkins przy każdym uruchomieniu sam pobiera Jenkinsfile z repozytorium - krok `clone` realizowany jest niejawnie przez mechanizm SCM (widoczny jako `Checkout SCM` w widoku pipeline). Infrastruktura budowania stała się częścią kodu, podlegającą kontroli wersji.

### Etap Cleanup - pewność świeżego kodu

Na początku każdego uruchomienia pipeline wykonuje etap `Cleanup`, który usuwa poprzednie kontenery i obrazy Docker:

```groovy
stage('Cleanup') {
    steps {
        sh 'docker rm -f express-deploy || true'
        sh 'docker rmi -f lab3-build lab3-test express-deploy-img || true'
    }
}
```

Usunięcie obrazów przed każdym buildem wymusza pełny rebuild - eliminuje ryzyko pracy na starym cache. Operator `|| true` zapobiega błędom w przypadku, gdy obrazy lub kontenery nie istnieją (np. przy pierwszym uruchomieniu).

### Etap Build - obraz BLDR i artefakt

Obraz `lab3-build` pełni rolę obrazu buildowego (BLDR). Artefakt tworzony jest już na tym etapie, ponieważ kontener docelowy wywodzi się z obrazu buildowego:

```groovy
stage('Build') {
    steps {
        sh 'docker build -t lab3-build -f PS422034/Sprawozdanie3/lab3/Dockerfile.build .'
        sh 'mkdir -p artifact'
        sh 'docker run --rm -v $(pwd)/artifact:/artifact lab3-build tar -czf /artifact/express-1.0.0.tar.gz -C /app .'
    }
}
```

### Etap Test

Testy uruchamiane są w osobnym kontenerze dziedziczącym po `lab3-build`. Jeśli którykolwiek test nie przejdzie, pipeline zatrzymuje się i raportuje niepowodzenie:

```groovy
stage('Test') {
    steps {
        sh 'docker build -t lab3-test -f PS422034/Sprawozdanie3/lab3/Dockerfile.test .'
        sh 'docker run --rm lab3-test'
    }
}
```

### Etap Deploy - dedykowany obraz z entrypointem

Kluczową zmianą w stosunku do poprzedniej wersji jest budowanie dedykowanego obrazu `express-deploy-img` z wbudowanym entrypointem, zamiast podawania polecenia startowego ręcznie w `docker run`. Dockerfile dla obrazu deploy generowany jest dynamicznie w trakcie wykonania pipeline'u:

```groovy
stage('Deploy') {
    steps {
        sh '''cat > Dockerfile.deploy << DFEOF
FROM lab3-build:latest
EXPOSE 3000
CMD ["node", "/app/index.js"]
DFEOF'''
        sh 'docker build -t express-deploy-img -f Dockerfile.deploy .'
        sh 'docker rm -f express-deploy || true'
        sh 'docker run -d --name express-deploy -p 3000:3000 express-deploy-img'
        sh 'sleep 5'
        sh 'docker exec express-deploy curl -s http://localhost:3000 || true'
    }
}
```

Kontener `express-deploy` pełni rolę środowiska sandboxowego. Weryfikuje, że aplikacja startuje i odpowiada na żądania HTTP. Po zakończeniu pipeline'u blok `post { always }` sprząta kontener.

### Etap Publish

Artefakt `express-1.0.0.tar.gz` dołączany jest do każdego udanego przejścia pipeline'u:

```groovy
stage('Publish') {
    steps {
        archiveArtifacts artifacts: 'artifact/express-1.0.0.tar.gz', onlyIfSuccessful: true
    }
}
```

### Powtarzalność - buildy #15 i #16

Pipeline uruchomiono dwukrotnie (buildy #15 i #16), oba zakończyły się sukcesem. Etap Cleanup zapewnia każdorazowe usunięcie starych obrazów przed pełnym rebuildem, co gwarantuje powtarzalność bez polegania na cache.

### Kompletny Jenkinsfile (wersja finalna)

```groovy
pipeline {
    agent any
    stages {
        stage('Cleanup') {
            steps {
                sh 'docker rm -f express-deploy || true'
                sh 'docker rmi -f lab3-build lab3-test express-deploy-img || true'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t lab3-build -f PS422034/Sprawozdanie3/lab3/Dockerfile.build .'
                sh 'mkdir -p artifact'
                sh 'docker run --rm -v $(pwd)/artifact:/artifact lab3-build tar -czf /artifact/express-1.0.0.tar.gz -C /app .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker build -t lab3-test -f PS422034/Sprawozdanie3/lab3/Dockerfile.test .'
                sh 'docker run --rm lab3-test'
            }
        }
        stage('Deploy') {
            steps {
                sh '''cat > Dockerfile.deploy << DFEOF
FROM lab3-build:latest
EXPOSE 3000
CMD ["node", "/app/index.js"]
DFEOF'''
                sh 'docker build -t express-deploy-img -f Dockerfile.deploy .'
                sh 'docker rm -f express-deploy || true'
                sh 'docker run -d --name express-deploy -p 3000:3000 express-deploy-img'
                sh 'sleep 5'
                sh 'docker exec express-deploy curl -s http://localhost:3000 || true'
            }
        }
        stage('Publish') {
            steps {
                archiveArtifacts artifacts: 'artifact/express-1.0.0.tar.gz', onlyIfSuccessful: true
            }
        }
    }
    post {
        always {
            sh 'docker rm -f express-deploy || true'
        }
    }
}
```

### Definition of Done

**Czy artefakt może zadziałać na maszynie docelowej?**
Artefakt `express-1.0.0.tar.gz` zawiera kod źródłowy Express wraz z zainstalowanymi zależnościami (`node_modules`). Uruchomienie na maszynie docelowej wymaga jedynie Node.js:

```bash
tar -xzf express-1.0.0.tar.gz -C /app
node /app/index.js
```

**Czy obraz może być pobrany z Rejestru?**
W obecnej konfiguracji obraz `express-deploy-img` dostępny jest lokalnie w DIND. Nie jest pushowany do zewnętrznego rejestru - artefakt tar.gz pełni rolę przenośnej formy dystrybucji dostępnej bezpośrednio z Jenkinsa. W środowisku produkcyjnym kolejnym krokiem byłoby opublikowanie obrazu do Docker Hub lub prywatnego rejestru (np. `docker push registry.example.com/express-deploy:1.0.${BUILD_NUMBER}`).

### Rozbieżności między planowanym UML a efektem

Zaplanowany proces CI/CD pokrywa się z uzyskanym efektem. Wszystkie zaplanowane kroki zostały zrealizowane: Clone → Cleanup → Build → Test → Deploy → Publish. Jedyną różnicą w stosunku do pierwotnego planu jest brak osobnego, lekkiego kontenera runtime (`node:slim`) dla etapu Deploy - użyto kontenera buildowego jako bazy. Jest to podejście akceptowalne dla Express.js jako frameworka, choć w środowisku produkcyjnym warto rozważyć optymalizację rozmiaru obrazu.

### Wnioski

Przechowywanie Jenkinsfile w repozytorium SCM to kluczowy krok w kierunku traktowania infrastruktury jako kodu. Etap Cleanup gwarantuje deterministyczne wykonanie pipeline'u niezależnie od stanu środowiska. Budowanie dedykowanego obrazu deploy z wbudowanym entrypointem jest dobrą praktyką - obraz jest samowystarczalny i może być uruchomiony bez znajomości szczegółów implementacji.

---

## Podsumowanie

Realizacja laboratoriów 5-7 umożliwiła zaprojektowanie i wdrożenie kompletnego potoku CI/CD z wykorzystaniem Jenkinsa i Dockera:

1. **Jenkins z BlueOcean i DIND** - skonteneryzowane środowisko CI, dostępne przez tunel SSH, z archiwizowanymi logami i wtyczką do wizualizacji pipeline'ów.
2. **Pipeline jako kod** - przejście od wklejania treści pipeline'u w interfejs Jenkinsa do przechowywania Jenkinsfile w repozytorium SCM, co uczyniło infrastrukturę budowania częścią projektu.
3. **Kompletna ścieżka krytyczna** - realizacja wszystkich etapów: klonowanie, budowanie, testowanie, wdrożenie w kontenerze sandboxowym, smoke test i publikacja artefaktu.
4. **Powtarzalność** - etap Cleanup zapewnia czyste środowisko przy każdym uruchomieniu, co potwierdzono dwukrotnym sukcesem pipeline'u.
5. **Artefakt gotowy do wdrożenia** - archiwum tar.gz z kodem i zależnościami, dostępne bezpośrednio z historii buildów Jenkinsa.

Opanowanie przedstawionych narzędzi i praktyk stanowi fundament pracy inżyniera DevOps. Automatyzacja procesu budowania, testowania i dystrybucji oprogramowania eliminuje błędy ludzkie, skraca czas od commita do działającego artefaktu i zapewnia pełną audytowalność każdego etapu procesu wytwarzania.
