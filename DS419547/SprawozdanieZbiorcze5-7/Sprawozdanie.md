# Sprawozdanie Zbiorcze z Laboratoriów 5-7

### Wstęp
Drugi blok zajęć laboratoryjnych skupiał się na automatyzacji procesów wytwarzania oprogramowania przy użyciu Jenkinsa. Przeszliśmy od podstawowej konfiguracji serwera w środowisku kontenerowym, przez pipeline'y CI/CD, aż po optymalizację procesu budowania i wdrożenie podejścia IaC poprzez wykorzystanie plików Jenkinsfile w systemie kontroli wersji SCM.

### Jenkins, Pipeline, Izolacja etapów (Lab 05)
Pierwszym krokiem było uruchomienie instancji Jenkinsa w trybie Docker-in-Docker (DinD). Takie podejście pozwala Jenkinsowi na zarządzanie kontenerami Dockera (budowanie, uruchamianie, usuwanie) bez bezpośredniego dostępu do hosta, co zapewnia wysoką izolację procesów budowania.

W ramach zadań wstępnych przetestowaliśmy mechanizmy Jenkinsa na prostych projektach typu *Freestyle*, weryfikując komunikację z demonem Dockera (np. poprzez `docker pull`). Następnie przeszliśmy do obiektów typu *Pipeline*, które pozwalają na definiowanie całego procesu CI jako ciągu logicznych kroków (etapów).

**Kluczowe osiągnięcia:**
*   **Konfiguracja DinD**: Zapewnienie Jenkinsowi zdolności do operowania na kontenerach wewnątrz własnego środowiska.
*   **Wprowadzenie do Pipeline**: Pierwsze definicje procesów obejmujące klonowanie repozytorium i budowanie obrazów na podstawie Dockerfile z poprzednich zajęć.

![Główny pulpit Jenkinsa po konfiguracji](img/jenkins-dashboard.png)

### Projektowanie i implementacja CI/CD (Lab 06)
Kolejne zajęcia poświęcono zaprojektowaniu kompletnego rurociągu dla rzeczywistej aplikacji. Wybrano szablon `nestjs/typescript-starter` na licencji MIT. Proces został poprzedzony analizą UML, określającą etapy: *Checkout*, *Build*, *Test*, *Deploy* oraz *Smoke Test*.

W celu optymalizacji obrazów zastosowano technikę **Multi-stage build**. Pozwala ona na wykorzystanie cięższego obrazu z pełnym zestawem narzędzi (kompilator, npm) tylko do etapu budowania i testowania, podczas gdy końcowy obraz produkcyjny (runtime) zawiera jedynie niezbędne pliki wykonywalne i produkcyjne zależności, co znacząco redukuje jego rozmiar i zwiększa bezpieczeństwo.

**Elementy procesu:**
*   **Smoke Test**: Automatyczna weryfikacja poprawności wdrożenia poprzez sprawdzenie dostępności usługi za pomocą narzędzia `curl` wewnątrz tymczasowego kontenera.
*   **Publikacja artefaktów**: Archiwizacja logów aplikacji jako numerowanych plików, co pozwala na późniejszą diagnostykę błędów wdrożeniowych.

![Diagram UML procesu CI/CD](img/pipeline-uml.png)

### Jenkinsfile i optymalizacja CI/CD (Lab 07)
Ostatni etap polegał na przeniesieniu całej definicji rurociągu do repozytorium kodu w postaci pliku `Jenkinsfile`. Pozwala to na pełną wersjonowalność procesu budowania razem z kodem aplikacji (Pipeline as Code).

Skupiliśmy się na optymalizacji i idempotentności procesu. Każdy build rozpoczyna się od czyszczenia przestrzeni roboczej (`deleteDir()`), co gwarantuje brak artefaktów z poprzednich, potencjalnie nieudanych prób. Wprowadzono również jawny etap budowania obrazu budującego (`--target build`), który służy wyłącznie do przeprowadzenia testów jednostkowych przed stworzeniem finalnego obrazu runtime.

**Wnioski z optymalizacji:**
*   **Idempotentność**: Mechanizm usuwania poprzednich kontenerów (`docker stop && docker rm`) zapewnia, że każda próba wdrożenia odbywa się w czystym środowisku.
*   **Rozdzielenie ról**: Wyraźne odseparowanie obrazu budującego (BLDR) od obrazu wdrożeniowego (Deploy) pozwala na efektywniejsze zarządzanie zasobami i artefaktami.

![Widok etapów zoptymalizowanego Pipeline'u](img/pipeline-final.png)

### Kompendium Techniczne i Wykaz Komend

Poniższe zestawienie podsumowuje techniczne aspekty pracy z Jenkinsem i procesami CI/CD.

#### 1. Architektura Jenkins i Docker
Uruchomienie Jenkinsa z obsługą Dockera wymagało specyficznej konfiguracji sieciowej i uprawnień.

*   **Pobieranie hasła admina**: `docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword`
*   **Budowanie obrazu Jenkinsa z Dockerem**:
    ```dockerfile
    FROM jenkins/jenkins:2.440.2-jdk17
    USER root
    RUN apt-get update && apt-get install -y lsb-release
    RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg
    RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    RUN apt-get update && apt-get install -y docker-ce-cli
    USER jenkins
    RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
    ```

#### 2. Składnia Deklaratywna Pipeline (Jenkinsfile)
Pipeline definiowany jest w bloku `pipeline { ... }`, który zawiera kluczowe sekcje:

*   **agent**: Określa, gdzie ma się wykonać proces (np. `agent any`).
*   **environment**: Definicja zmiennych globalnych dostępnych we wszystkich etapach.
*   **stages**: Kontener dla poszczególnych kroków logicznych.
*   **post**: Akcje wykonywane po zakończeniu rurociągu (np. `always`, `success`, `failure`).
*   **Kluczowe polecenia**:
    *   `sh '...'` – wykonanie skryptu powłoki.
    *   `checkout scm` – pobranie kodu z repozytorium skonfigurowanego w zadaniu.
    *   `archiveArtifacts` – zachowanie plików (np. logów, binariów) w historii buildu.
    *   `deleteDir()` – rekurencyjne usunięcie bieżącego katalogu roboczego.

#### 3. Zaawansowane Techniki Docker w CI
*   **Multi-stage builds**:
    Użycie instrukcji `FROM ... AS ...` pozwala na nazwanie etapów. Możemy budować tylko do konkretnego etapu używając flagi `--target`.
    ```bash
    docker build --target build -t my-builder .
    ```
*   **Networking w testach**:
    Użycie `--network host` w kontenerach testowych i wdrożeniowych (sandbox) pozwala na łatwy dostęp do usług bez konieczności skomplikowanego mapowania portów wewnątrz środowiska DinD.
*   **Idempotentność wdrożenia**:
    Zastosowanie `|| true` przy zatrzymywaniu kontenerów pozwala uniknąć błędów pipeline'u, gdy kontener o danej nazwie jeszcze nie istnieje.
    ```bash
    sh "docker stop my-app || true"
    sh "docker rm my-app || true"
    ```

### Podsumowanie i wyciągnięte wnioski
Realizacja laboratoriów 5-7 pozwoliła na pełne zrozumienie cyklu życia aplikacji w nowoczesnym podejściu DevOps. Przejście od ręcznego budowania kontenerów do w pełni zautomatyzowanego rurociągu CI/CD pokazało, jak można zminimalizować ryzyko błędów ludzkich i zapewnić powtarzalność wdrożeń.

Najważniejszą lekcją było zrozumienie koncepcji **"Infrastructure as Code"**. Przechowywanie definicji rurociągu (Jenkinsfile) oraz środowiska uruchomieniowego (Dockerfile) w repozytorium pozwala na łatwe odtworzenie całego ekosystemu w dowolnym momencie, co jest kluczowe w pracy zespołowej i skalowaniu systemów. Rozdzielenie obrazów budujących od produkcyjnych udowodniło natomiast, że bezpieczeństwo i wydajność mogą iść w parze z automatyzacją.
