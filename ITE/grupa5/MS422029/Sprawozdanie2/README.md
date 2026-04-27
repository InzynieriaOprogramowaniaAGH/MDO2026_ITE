# Zbiorcze Sprawozdanie z Laboratoriów CI/CD (Lab 5-7): Od instancji Jenkinsa do pełnego Pipeline SCM

**Autor:** Mateusz Stępień (MS422029)  
**Temat:** Postawienie środowiska CI/CD oraz automatyzacja budowania, testowania i wdrażania biblioteki cJSON przy użyciu potoku deklaratywnego (Jenkinsfile) zintegrowanego z GitHubem i Dockerem.

---

## 1. Wstęp i przygotowanie środowiska (Lab 5)
Zaczęliśmy od postawienia całego środowiska roboczego od zera. Utworzyłem nową instancję Jenkinsa (wraz z interfejsem Blueocean) i uruchomiłem kontener typu Docker-in-Docker (DinD), który pozwala Jenkinsowi uruchamiać inne kontenery w odizolowanym środowisku. 

Na rozgrzewkę stworzyłem trzy proste zadania testowe, żeby upewnić się, że Jenkins poprawnie reaguje:
* Projekt wywołujący komendę uname (zakończony sukcesem).
* Projekt weryfikujący godzinę – skrypt poprawnie zwrócił kod błędu (exit 1) dla godziny nieparzystej.
* Pobranie obrazu bazowego ubuntu za pomocą komendy docker pull.

## 2. Architektura i narzędzia (Lab 6)
Aby zautomatyzować proces, zbudowałem potok w oparciu o trzy główne narzędzia, z których każde miało swoje konkretne zadanie:
* **Jenkins:** Nasz orkiestrator. Sam nic nie kompiluje, ale wydaje polecenia i pilnuje kolejności. 
* **Docker (DinD):** Środowisko robocze. Dzięki niemu kompilujemy i testujemy kod wewnątrz odizolowanych kontenerów, co chroni główny system przed zanieczyszczeniem niepotrzebnymi pakietami i zależnościami.
* **GitHub (SCM):** Przechowujemy tam nie tylko kod biblioteki cJSON, ale również kod naszej infrastruktury, czyli plik Jenkinsfile. Podejście Infrastructure as Code znacząco ułatwia pracę, ponieważ wersjonujemy ustawienia serwera budującego tak samo jak zwykły projekt programistyczny.

## 3. Etapy Pipeline (Lab 7)
Zaimplementowałem pełną ścieżkę krytyczną. Każdy krok w potoku ma konkretne zadanie:

1. **Czyszczenie (cleanWs):** Zanim rozpocznie się proces, czyścimy obszar roboczy. Dzięki temu mamy gwarancję, że nowy build nie użyje uszkodzonych lub starych plików z poprzednich prób, co zapewnia pełną powtarzalność.
2. **Klonowanie repozytorium (Clone):** Pobieramy kod biblioteki cJSON z repozytorium. Zastosowałem tutaj mechanizm Shallow Clone z głębokością ustawioną na 1. Bez tego ustawienia Jenkins zatrzymywał się na kilkadziesiąt minut, pobierając pełną historię wszystkich zmian w repozytorium grupy. Potrzebny był nam wyłącznie aktualny stan plików.
3. **Kompilacja (Build):** Jenkins generuje plik Dockerfile i uruchamia rozbudowany kontener bazujący na systemie Ubuntu, w którym instalujemy pakiety build-essential i cmake. Kompilacja odbywa się wyłącznie wewnątrz tego odizolowanego kontenera. 
4. **Testy (Test):** W tym samym kontenerze, aby zachować pełną zgodność bibliotek, wykonujemy polecenie make test. W konsoli można było zaobserwować, że program prawidłowo przetworzył przykładowe pliki JSON, co potwierdziło zaliczenie testów.
5. **Publikacja artefaktu (Publish):** Zamiast udostępniać użytkownikom cały kontener z systemem operacyjnym, wyodrębniamy tylko użyteczne pliki: cJSON.h, cJSON.c oraz Makefile. Następnie pakujemy je w lekkie archiwum cjson-artefakt.tar.gz. Po tym kroku plik jest widoczny i gotowy do pobrania w Jenkinsie.
6. **Wdrożenie (Deploy):** Symulujemy środowisko produkcyjne, uruchamiając aplikację w minimalistycznym kontenerze alpine. Na środowisko produkcyjne nie wdraża się systemów zawierających narzędzia deweloperskie ze względów bezpieczeństwa. Wykonaliśmy również Smoke Test sprawdzając w terminalu poleceniem docker ps, czy kontener prawidłowo wystartował.

## 4. Rozwiązywanie problemów (Troubleshooting)
Zanim proces zaczął działać automatycznie, rozwiązałem następujące problemy techniczne:
* **Problemy z TLS i Dockerem:** Jenkins stracił połączenie z kontenerem Dockera (DinD). Wynikało to z faktu, że po restartach wygenerowały się nowe certyfikaty bezpieczeństwa, a główny węzeł próbował używać starych. Rozwiązaniem było ręczne usunięcie wolumenu jenkins-docker-certs i ponowne uruchomienie kontenerów w celu wynegocjowania prawidłowego połączenia.
* **Zatrzymanie na pobieraniu kodu:** Polecenie git fetch nie potrafiło zakończyć działania. Wprowadzenie opcji Shallow Clone całkowicie wyeliminowało ten problem. Kolejne uruchomienia zadania udowodniły również przewagę Dockera – proces przebiegał błyskawicznie dzięki sprawnemu wykorzystaniu pamięci podręcznej z poprzednich kompilacji.

## 5. Skrypt potoku (Jenkinsfile)
Oto finalny kod potoku automatyzujący powyższe kroki:

```groovy
pipeline {
    agent any
    stages {
        stage('Czyszczenie i SCM') {
            steps {
                cleanWs()
            }
        }
        stage('Pobranie zrodel') {
            steps {
                sh 'git clone [https://github.com/DaveGamble/cJSON.git](https://github.com/DaveGamble/cJSON.git)'
            }
        }
        stage('Build') {
            steps {
                dir('cJSON') {
                    sh '''
                    echo "FROM ubuntu:24.04" > Dockerfile.bldr
                    echo "RUN apt-get update && apt-get install -y build-essential cmake" >> Dockerfile.bldr
                    echo "COPY . /app" >> Dockerfile.bldr
                    echo "WORKDIR /app" >> Dockerfile.bldr
                    echo "RUN make" >> Dockerfile.bldr
                    '''
                    sh 'docker build -t cjson-bldr -f Dockerfile.bldr .'
                }
            }
        }
        stage('Test') {
            steps {
                dir('cJSON') {
                    sh 'docker run --rm cjson-bldr make test'
                }
            }
        }
        stage('Deploy i Publish') {
            steps {
                dir('cJSON') {
                    sh 'tar -czvf cjson-artefakt.tar.gz cJSON.h cJSON.c Makefile'
                    archiveArtifacts artifacts: 'cjson-artefakt.tar.gz', onlyIfSuccessful: true
                }
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker run -d --name cjson-produkcja alpine sleep 3600'
            }
        }
    }
}
```
## 6. Podsumowanie i Definition of Done

Proces CI/CD działa w pełni automatycznie, spełniając założenia Definition of Done. Na wyjściu otrzymujemy wysoce przenośny artefakt w formacie .tar.gz, który jest gotowy do pobrania. Zastosowanie środowiska Docker zwalnia docelowego użytkownika z konieczności instalacji narzędzi kompilacyjnych na swoim komputerze, ponieważ Jenkins wykonał to zadanie w izolowanym systemie.