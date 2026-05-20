# Sprawozdanie Zbiorcze: Laboratoria 5, 6, 7
**Tematyka:** Potoki CI/CD, Jenkins, Infrastructure as Code, środowisko Ansible

## Cel Laboratoriów
Głównym celem cyklu zajęć było stworzenie kompletnego, zautomatyzowanego potoku wdrażania oprogramowania (CI/CD) przy użyciu narzędzia Jenkins. Proces ewoluował od konfiguracji środowiska, poprzez manualne definicje potoku, aż po podejście deklaratywne (Infrastructure as Code) i przygotowanie maszyn wirtualnych do automatyzacji konfiguracji za pomocą Ansible.

---

## Laboratorium 5: Architektura Jenkins i środowisko DIND
W ramach pierwszego etapu utworzono instancję Jenkinsa działającą w oparciu o środowisko zagnieżdżone (Docker in Docker). Pozwala to Jenkinsowi na swobodne budowanie innych kontenerów z poziomu własnego środowiska. Przygotowano dedykowany obraz rozszerzony o interfejs Blueocean.

**Kluczowe polecenia konfiguracyjne:**
```bash
# Uruchomienie środowiska DIND
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 docker:dind
```

Wykonano zadania wstępne udowadniające operacyjność środowiska, w tym pobranie obrazu Ubuntu za pomocą polecenia docker pull ubuntu oraz uruchomienie skryptów Bash weryfikujących parametry systemu:

```bash
# Skrypt weryfikujący parzystość godziny
HOUR=$(date +%-H)
if [ $((HOUR % 2)) -ne 0 ]; then
  exit 1
else
  exit 0
fi
```

## Laboratorium 6: Kompletny Potok CI/CD (Ścieżka Krytyczna)
Centralnym punktem cyklu było zdefiniowanie potoku realizującego pełną ścieżkę krytyczną: Clone, Build, Test, Deploy, Publish. Zdecydowano się na lekką aplikację w środowisku Node.js opartą na obrazie node:18-slim. Proces generuje logi z testów jako artefakt oraz archiwum TAR gotowe do redystrybucji. Wdrożenie testowe (smoke test) realizowane jest na kontenerze integracyjnym, który następnie jest usuwany.

**Kod zaimplementowanego potoku (język Groovy):**

```groovy
pipeline {
    agent any
    environment { DOCKER_BUILDKIT = '0' }
    stages {
        stage('Pobranie i Kod (Clone)') {
            steps {
                writeFile file: 'index.js', text: 'console.log("Dziala!");'
                writeFile file: 'test.js', text: 'console.log("Test OK");'
                writeFile file: 'Dockerfile', text: '''FROM node:18-slim\nWORKDIR /app\nCOPY . .\nCMD ["node", "index.js"]'''
            }
        }
        stage('Budowanie (Build)') {
            steps { sh 'docker build -t apka-ci-cd:latest .' }
        }
        stage('Testowanie (Test)') {
            steps {
                sh 'docker run --rm apka-ci-cd:latest node test.js > test-results.log'
                archiveArtifacts artifacts: 'test-results.log', fingerprint: true
            }
        }
        stage('Wdrożenie (Deploy)') {
            steps {
                sh 'docker run -d --name apka-test apka-ci-cd:latest'
                sleep 2
                sh 'docker rm -f apka-test'
            }
        }
        stage('Publikacja (Publish)') {
            steps {
                sh 'docker save apka-ci-cd:latest > apka-release.tar'
                archiveArtifacts artifacts: 'apka-release.tar', fingerprint: true
            }
        }
    }
}
```

## Laboratorium 7: Jenkinsfile z SCM oraz Ansible
Ostatni etap polegał na przeniesieniu definicji potoku do pliku Jenkinsfile umieszczonego w systemie kontroli wersji, zgodnie z metodyką Infrastructure as Code. Utworzono lokalne repozytorium Git na serwerze i skonfigurowano Jenkinsa do odczytu kodu (opcja Pipeline script from SCM).

**Inicjalizacja lokalnego SCM:**

```bash
git init
git add Jenkinsfile
git commit -m "Inicjalizacja potoku CI/CD"
```

Dodatkowo przygotowano środowisko pod narzędzie Ansible. Utworzono nową maszynę wirtualną, nadano jej nazwę ansible-target i zainstalowano serwer sshd oraz narzędzie tar. Zestawiono autoryzację kluczami SSH bez hasła między maszyną główną a maszyną docelową.

**Konfiguracja dostępu Ansible:**

```bash
# Wygenerowanie kluczy na głównej maszynie
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

# Przesłanie klucza na docelową maszynę
ssh-copy-id ansible@ansible-target

# Weryfikacja logowania bezhasłowego
ssh ansible@ansible-target
```

Środowisko zostało w pełni skonfigurowane, logowanie następuje bez autoryzacji hasłem, a infrastruktura gotowa jest do pisania playbooków.