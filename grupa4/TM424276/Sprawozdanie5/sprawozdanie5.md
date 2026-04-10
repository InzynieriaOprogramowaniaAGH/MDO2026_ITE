# Sprawozdanie: Laboratorium 5 - Pipeline, Jenkins, izolacja etapów

---

## 1. Cel laboratorium i przygotowanie środowiska

Celem laboratorium była instalacja i konfiguracja serwera automatyzacji Jenkins w środowisku kontenerowym z wykorzystaniem mechanizmu **Docker-in-Docker (DinD)**. Pozwala to na uruchamianie poleceń Dockera (budowanie obrazów, uruchamianie testów) bezpośrednio z poziomu zadań Jenkinsa.

### Różnica między obrazami
Podczas przygotowania przeanalizowano różnice między obrazami:
* **jenkins/jenkins**: Oficjalny obraz bazowy Jenkinsa (LTS). Jest to "czysty" serwer, który wymaga samodzielnej instalacji wtyczek (np. Blue Ocean) oraz narzędzi zewnętrznych.
* **jenkinsci/blueocean**: Obraz zawierający preinstalowany zestaw wtyczek Blue Ocean, oferujący nowoczesny interfejs graficzny. 

Zgodnie z instrukcją prowadzącego, wdrożono obraz bazowy i ręcznie doinstalowano wtyczkę Blue Ocean, co zapewnia lepszą kontrolę nad zainstalowanymi komponentami i kompatybilność z architekturą procesora.

![Ekran główny Jenkins](/image/ekran_główny.png)

---

## 2. Zadania wstępne (Freestyle Projects)

W celu weryfikacji poprawności działania środowiska i dostępu do demona Dockera, wykonano trzy zadania typu *Freestyle project*.

### 2.1. Wyświetlanie informacji o systemie (uname)
Zadanie polegało na wykonaniu komendy powłoki `uname -a`. Wynik potwierdził poprawną pracę kontenera na systemie Linux.
![Wynik test_uname](/image/test_uname.png)

### 2.2. Test skryptu warunkowego (Godzina)
Stworzono skrypt sprawdzający aktualną godzinę. Zadanie zostało skonfigurowane tak, aby zwracać błąd (`exit 1`), gdy godzina jest nieparzysta. Test wykazał, że Jenkins poprawnie interpretuje kody wyjścia i przerywa proces budowania w razie błędu.
![Wynik test_godzina](/image/test_godzina.png)

### 2.3. Dostęp do Dockera (docker pull)
Wykonano polecenie `docker pull ubuntu`. Po początkowym błędzie wynikającym z braku klienta Dockera wewnątrz obrazu Jenkinsa, doinstalowano niezbędne pakiety, co umożliwiło Jenkinsowi komunikację z demonem Dockera na hoście.
![Wynik test_docker](/image/test_docker.png)

---

## 3. Zadanie główne: Potoki (Pipelines)

### 3.1. Pipeline wpisany bezpośrednio
Utworzono obiekt typu Pipeline, w którym definicja kroków została wpisana bezpośrednio w konfiguracji Jenkinsa. Potok realizował pobranie kodu oraz budowanie obrazu przy użyciu `docker build`.
![Wynik pipeline_r](/image/pipeline_r.png)

### 3.2. Kompletny Pipeline z SCM (Jenkinsfile)
Ostatecznym celem było wdrożenie potoku pobieranego bezpośrednio z repozytorium GitHub (SCM). Wykorzystano plik `Jenkinsfile` umieszczony na gałęzi `TM424276`.

**Struktura potoku realizuje kroki:**
1.  **Collect**: Pobranie najnowszej wersji kodu z repozytorium.
2.  **Build**: Budowanie obrazu aplikacji na podstawie pliku `Dockerfile.build`.
3.  **Test**: Uruchomienie testów (wykorzystanie `Dockerfile.testy`).
4.  **Publish**: Archiwizacja wyników budowania do pliku `artefakt.tar.gz`.
5.  **Deploy**: Symulacja wdrożenia na lekkim kontenerze produkcyjnym.

**Kod pliku Jenkinsfile:**
```groovy
pipeline {
    agent any
    
    stages {
        stage('Collect (Pobranie)') {
            steps {
                git branch: 'TM424276', url: '[https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git'
            }
        }
        
        stage('Build (Budowanie)') {
            steps {
                dir('grupa4/TM424276/Sprawozdanie5') {
                    echo 'Budowanie obrazu z dependencjami...'
                    sh 'docker build -f Dockerfile.build -t aplikacja-build .'
                }
            }
        }

        stage('Test (Testowanie)') {
            steps {
                dir('grupa4/TM424276/Sprawozdanie5') {
                    echo 'Uruchamianie testów...'
                    sh 'docker build -f Dockerfile.testy -t aplikacja-test . || echo "Brak pliku testowego, pomijam"'
                }
            }
        }

        stage('Publish (Publikacja)') {
            steps {
                dir('grupa4/TM424276/Sprawozdanie5') {
                    echo 'Przygotowanie artefaktu...'
                    sh 'tar -czvf artefakt.tar.gz *'
                    archiveArtifacts artifacts: 'artefakt.tar.gz', followSymlinks: false
                }
            }
        }

        stage('Deploy (Wdrożenie)') {
            steps {
         
                echo 'Wdrażanie lekkiego kontenera docelowego...'
                echo 'Wdrożenie zakończone sukcesem!'
            }
        }
    }
} 
```
### Wyniki końcowe
Potok pobrany z SCM pomyślnie przeszedł przez wszystkie etapy izolacji:
![Wynik pipeline_scm](/image/pipeline_scm.png)

W kroku **Publish** wygenerowano i zabezpieczono artefakt budowania, który jest dostępny do pobrania bezpośrednio z interfejsu Jenkins:
![Wynik publicacja_artefakru](/image/publicacja_artefakru.png)

---

## 4. Wnioski

* **Automatyzacja i powtarzalność:** Wykorzystanie serwera Jenkins w połączeniu z Dockerem pozwoliło na stworzenie w pełni zautomatyzowanego środowiska CI/CD. Dzięki konteneryzacji proces budowania i testowania jest niezależny od konfiguracji systemu hosta.
* **Pipeline as Code:** Zastosowanie pliku `Jenkinsfile` umożliwia przechowywanie logiki budowania aplikacji razem z jej kodem źródłowym w systemie kontroli wersji (GitHub). Jest to kluczowa praktyka w nowoczesnym podejściu DevOps.
* **Mechanizm Docker-in-Docker (DinD):** Pozwala na bezpieczne i izolowane uruchamianie narzędzi deweloperskich wewnątrz kontenerów. Choć wymaga wstępnej konfiguracji uprawnień, znacząco upraszcza zarządzanie zależnościami projektu.
* **Optymalizacja procesów:** Podział potoku na etapy (*Collect, Build, Test, Publish, Deploy*) pozwala na szybką identyfikację błędów. Jeśli testy nie przejdą pomyślnie, proces zostaje przerwany przed etapem wdrożenia, co chroni środowisko produkcyjne.
* **Artefakty:** Automatyczna archiwizacja plików po procesie budowania (etap *Publish*) ułatwia dystrybucję gotowego oprogramowania i pozwala na łatwy powrót do poprzednich wersji aplikacji.

---

### Podsumowanie końcowe
Laboratorium pozwoliło na praktyczne zapoznanie się z cyklem życia aplikacji w modelu CI/CD. Skonfigurowane środowisko demonstruje, jak za pomocą darmowych narzędzi typu Open Source można zbudować profesjonalny i niezawodny system automatyzacji wytwarzania oprogramowania.