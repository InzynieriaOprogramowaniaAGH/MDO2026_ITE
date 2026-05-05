# Sprawodzanie zbiorcze lab 5-7
### Jakub Padło, 422018

# Dlaczego Jenkinsa lepiej zainstalować na dockerze?
* **Czysty system (Izolacja)** -  Nie trzeba instalować konkretnej wersji Javy. Obraz Jenkinsa ma wszystko out-of-the-box. Bez zaśmiecania głównego systemu.
* **Łatwe aktualizacje** -  Wystarczy zmienić jedną cyferkę przy obrazie.
* **Łatwa przenośność** - Cały Jenkins to de facto jeden folder z danymi. Przy potrzebie przeniesienia go na inny serwer, wystarczy skopiować folder i uruchomić dockera. Zadziała identycznie.

### Dlaczego przy zmianie obrazu nie tracimy danych?
1. **Warstwowe działanie Dockera** (upperdir i lowerdir). Warstwa obrazu jest READ-ONLY. To taki engine.
2. **Wolumeny** - wszystkie projekty, konfiguracja i historia trzymane są w osobnym miejscu zdala od obrazu.

# Jak dać Jenkinsowi dostęp do Dockera?
| Cecha | **DinD** (Docker-in-Docker) | **DooD** (Docker-out-of-Docker) |
| :--- | :--- | :--- |
| **Mechanizm** | Główny Docker uruchamia wewnątrz kontenera **"małego Dockera"**, z którym łączy się Jenkins.  Jenkins sam w sobie nie ma demona Dockera, więc wysyła komendy przez TCP do tego kontenera. | Jenkins dostaje **"pilota"** do silnika Dockera, który już działa na komputerze. |
| **Instalacja** | **Skomplikowana** | **Prosta**: jedna linijka + podpięcie gniazda `/var/run/docker.sock`. |
| **Wydajność** | **Ciężkie**: Dwa działające silniki | **Lekkie**: brak narzutu, Jenkins korzysta z zasobów hosta. |
| **Izolacja** | **Pełna**: Jenkins działa w całkowicie odizolowanym środowisku. | **Brak**: Jenkins widzi i może zarządzać wszystkimi kontenerami na hoście. |

# Po co Jenkinsowi właśna sieć?
* Wymóg podejścia DinD
* Izolacja
* DNS - Gadanie po nazwach zamiast IP


# Kolejne kroki pipeline'u

# 1. Klonowanie repo
Pobiera kod z repozytorium, które zostało skonfigurowane przez GUI Jenkinsa w ustawieniach zadania.

Repo powinno zawierać również `Dockerfile`.
```
stage('Clone') {
    steps {
        checkout scm
    }
}
```

# 2. Testowanie kodu
```groovy
stage('Test') {
    steps {
        script {
            sh "docker build --target builder -t ${IMAGE_NAME}-test ."
            sh "docker run --rm ${IMAGE_NAME}-test pnpm test"
        }
    }
}
```

```Dockerfile
# ETAP 1: Instalacja zależności
FROM node:20-alpine AS deps
RUN corepack enable && corepack prepare pnpm@10.29.2 --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# ETAP 2: Budowanie
FROM node:20-alpine AS builder
RUN corepack enable && corepack prepare pnpm@10.29.2 --activate
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build
```

* Budujemy swój pierwszy obraz, aby mieć kontener na którym uruchomimy testy.
* Korzystając z multi-stage-build skorzystamy z dwóch pierwszych etapów 
    1. deps (instalacja zależności)
    2. builder (skopiowanie kodu, skopiowanie gotowego node_modules z poprzedniego etapu oraz zbudowanie aplikacji)

Jenkins odpala kontener z właśnie zbudowanego obrazu i uruchamia testy. Flaga --rm sprawia, że kontener jest kasowany zaraz po zakończeniu. Jeśli testy failują, Jenkins przerywa pipeline tutaj i nie przechodzi do budowania produkcyjnego obrazu.

### Dlaczego instalacji zależności jest wydzielone do osobnego etapu?
Na pierwszy rzut oka wygląda to nadmiarowo, jednak dzięki cachowani'u dockera ma ogromny sens.
Jeśli package.json i pnpm-lock.yaml się nie zmienią to docker użyje cache'u i pominie etap deps.
Gdybym połączył te dwa etapy to każda zmiana w kodzie uruchamiałaby pnpm install instalując zależności od nowa co byłoby potwornie nieoptymalne

### dockerignore

`COPY . .` - Ta komenda kopiuje wszystko. Aby bezsensownie nie kopiować ogromnego lokalnego node_modules trzeba stworzyć plik `.dockerignore`


### corepack
Corepack to wbudowane w node narzędzie, którego jedynym celem jest zarządzanie manadżerami pakietów (pnpm, yarn, ...). Jest lepszy ponieważ wymusza użycie tej samej wersji menadżera oraz całkowicie omija rejestr npm.

### --frozen-lockfile

Gwarantuje stabilność instalując dokładnie te wersje bibliotek, które są zdefiniowane w pliku lock. Żadnych cichych update'ów.

# 3. Budowanie obrazu produkcyjnego

```groovy
stage('Build') {
    steps {
        sh """
            docker build \
            --build-arg GIT_COMMIT=\$(git rev-parse --short HEAD) \
            --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
            --build-arg BUILD_DATE=\$(date -u +%Y-%m-%dT%H:%M:%SZ) \
            -t ${IMAGE_NAME}:${VERSION} \
            -t ${IMAGE_NAME}:latest .
        """
    }
}
```
```dockerfile
# ETAP 3: Produkcja
FROM node:20-alpine AS runner
WORKDIR /app

ARG GIT_COMMIT=unknown
ARG BUILD_NUMBER=unknown
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      ci.build.number="${BUILD_NUMBER}"

RUN addgroup -S nodejs && adduser -S -u 1001 nextjs
USER nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

EXPOSE 3000

CMD ["node", "server.js"]
```

## CMD
Domyślna komenda, która zostanie wywołana przy uruchomieniu kontenera **jeśli użytkownik nie poda innej**
```Dockerfile
CMD ["node", "server.js"]
```
`docker run ... `  - CMD zostanie wywołane odpalając serwer

`docker run ... pnpm test`  - CMD z Dockerfile zostanie zignorowane


## Tryb Standalone w Next.js
* Wykrywa pliki z node_modules, które są potrzebne w runtime i tylko je kopiuje (normalnie wymagany jest cały folder node_modules)
* Generuj server.js - serwer HTTP, który do uruchomienia wystarczy node (normalnie wymagany jest next)
* Dzięki dwóm powyższym rozmiar aplikacji maleje kilkukrotnie

## USER
Aplikacja uruchamiana jest przez usera bez uprawnień administratora co znacznie poprawia bezpieczeństwo


## Docker Cache
Dzięki zbudowniu wcześniej obrazu do testowania, docelowy obraz zbudował się dużo szybciej wykorzystując już istniejące warstwy! 

## Przekazywanie zmiennej do metadanych obrazu
```sh
# Przekazanie zmiennej dla dockera
docker build --build-arg BUILD_NUMBER=${BUILD_NUMBER}
```

```Dockerfile
# Dockefile
# Odebranie zmiennej
ARG BUILD_NUMBER 

# 'wypalenie' zmiennej w metadanych obrazu
LABEL ci.build.number="${BUILD_NUMBER}"
```

Dzięki temu po `docker inspect <nazwa_obrazu>` mamy
```json
"Labels": {
    "ci.build.number": "20",
}
```
przydaje się to debugowania, aby wiedzieć która wersja wprowadziała błąd.

# 4. Publish - wypychanie gotowego artefaktu do rejestru
```groovy
stage('Publish') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
            sh "docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY_IMAGE}:${VERSION}"
            sh "docker tag ${IMAGE_NAME}:latest ${REGISTRY_IMAGE}:latest"
            sh "docker push ${REGISTRY_IMAGE}:${VERSION}"
            sh "docker push ${REGISTRY_IMAGE}:latest"
        }
    }
    post {
        always {
            sh "docker logout || true"
        }
    }
}
```
Jenkins musi się zalogować do Docker Hub. Dane logowania są pobierane z magazynu poświadczeń Jenkinsa (nie są nigdzie zapisane w kodzie)

# Przekazywanie haseł - dobre praktyki
* **ŹLE**:  `sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"` - zmienne rozwijane wcześniej, shell dostaje już gotowy tekst przez co hasło może pojawić się w logach
* **DOBRZE**: `sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'` - zmienne rozwijane dopiero przez shell w runtime, bezpieczniejsze
* Jak to działa?
    1. Bash podstawia zmienne
    2. `echo` wypisuje i przekazuje `|` jako stdin do następnej komendy logowania
    3. `--password-stdin` pobiera hasło przekazane przez strumień

# 5. Deploy
```groovy
stage('Deploy') {
    steps {
        sh "docker pull ${REGISTRY_IMAGE}:${VERSION}"
        sh "docker rm -f kanye-web-container || true"
        sh "docker run -d --name kanye-web-container -p 3000:3000 ${REGISTRY_IMAGE}:${VERSION}"
    }
}
```
Jenkins pobiera świeżo opublikowany obraz z Docker Hub (nie używa lokalnej wersji), zatrzymuje i kasuje stary kontener jeśli istniał, i uruchamia nowy.
Aplikacja Next.js jest teraz dostępna na porcie 3000 hosta. Kontener uruchamia node server.js — plik wygenerowany przez Next.js w trybie standalone.

# 6. Post - sprzątanie
```groovy
post {
    always {
        script {
            sh "docker inspect ${IMAGE_NAME}:${VERSION} > docker-inspect-${VERSION}.json || true"
            archiveArtifacts artifacts: "docker-inspect-${VERSION}.json", allowEmptyArchive: true
            
            sh "docker rmi ${IMAGE_NAME}:${VERSION} || true"
            sh "docker rmi ${IMAGE_NAME}:latest || true"
            sh "docker rmi ${REGISTRY_IMAGE}:${VERSION} || true"
            sh "docker rmi ${IMAGE_NAME}-test || true"
        }
    }
}
```
Niezależnie od tego, czy pipeline przeszedł czy nie, Jenkins:

* Uruchamia docker inspect na lokalnym obrazie i zapisuje JSON z metadanymi (wersja, commity, labele) do pliku.
* Archiwizuje ten plik jako artefakt builda - widoczny w UI Jenkinsa.
* Usuwa wszystkie lokalne obrazy zbudowane podczas pipeline'u

## Dlaczego Jenkinsfile i Dockerfile żyją w repozytorium?
* **Pipeline-as-Code**: Proces CI/CD jest traktowany jak kod źródłowy.
* **Wersjonowanie**: Każda zmiana w procesie budowania ma swoją historię w Git.
* **Spójność**: Jenkins pobiera skrypt z repozytorium przy każdym uruchomieniu, co gwarantuje spójność z daną wersją.