# Zbiorowe Sprawozdanie z procesu CI/CD (Laboratoria 5-7)
 
---

## 1. Laboratorium 5: Konfiguracja i uruchomienie środowiska Jenkins

### 1.1. Architektura środowiska (Jenkins + DIND)
Środowisko ciągłej integracji zostało oparte na architekturze kontenerowej, wykorzystując wzorzec Docker-in-Docker (DIND). Wymagało to uruchomienia dwóch współpracujących ze sobą kontenerów:
1. **DIND (`docker:dind`):** Kontener działający w trybie uprzywilejowanym, udostępniający wewnątrz siebie demona Docker. Służy on jako środowisko wykonawcze dla procesów budowania obrazów w potoku.
2. **Jenkins Blueocean:** Kontener zawierający serwer Jenkins. 

**Różnica między obrazem Jenkins a Blueocean:** Standardowy obraz `jenkins/jenkins` zawiera podstawową wersję serwera z klasycznym interfejsem graficznym. Obraz `jenkinsci/blueocean` jest rozszerzony o zestaw wtyczek Blue Ocean, które całkowicie zmieniają i unowocześniają interfejs użytkownika, oferując wizualną, intuicyjną reprezentację wieloetapowych potoków (pipeline'ów) oraz ułatwiając diagnostykę błędów.

Serwer Jenkins został połączony z kontenerem DIND za pomocą sieci wewnętrznej Dockera oraz certyfikatów TLS, co zapewnia bezpieczną komunikację i pozwala Jenkinsowi na zlecanie zadań budowania demonowi Docker.

### 1.2. Zadania wstępne i testy infrastruktury
Przed przystąpieniem do docelowego potoku, zweryfikowano poprawność działania środowiska poprzez proste zadania:
* Uruchomiono potok wyświetlający wynik polecenia `uname`, potwierdzając bazowy system kontenera.
* Skonfigurowano potok z warunkiem sprawdzającym parzystość godziny, weryfikując mechanizmy obsługi błędów i zatrzymywania builda.
* Pomyślnie pobrano obraz `ubuntu` komendą `docker pull`, potwierdzając poprawne połączenie Jenkinsa z siecią zewnętrzną i demonem DIND.

---

## 2. Laboratorium 6: Architektura procesu CI/CD i ścieżka krytyczna

### 2.1. Wybór aplikacji i założenia
Do implementacji potoku wybrano skonteneryzowaną aplikację opartą na środowisku Node.js. Aplikacja udostępnia API, posiada zdefiniowany zbiór testów jednostkowych (np. za pomocą frameworka Vitest/Mocha) i jest objęta licencją otwartoźródłową, co pozwala na swobodny obrót kodem. Zdecydowano się na wykorzystanie osobnego repozytorium (fork) w celu pełnej kontroli nad kodem i konfiguracją potoku.

### 2.2. Izolacja etapów – Multi-stage build
Zgodnie z dobrymi praktykami, zaimplementowano wieloetapowy proces budowania obrazu (Multi-stage Dockerfile), wprowadzając wyraźny podział na obraz budujący i obraz wdrożeniowy.

* **Kontener Build/Test (`target test`):** Oparty na pełnym obrazie środowiska (np. `node:20`). Zawiera kod źródłowy oraz wszystkie zależności deweloperskie (`devDependencies`). Jego zadaniem jest skompilowanie aplikacji oraz wykonanie zautomatyzowanych testów jednostkowych wewnątrz izolowanego środowiska.
* **Kontener Deploy (`target deploy`):** Jest to odchudzony obraz docelowy. 

**Dlaczego oddzielamy kontener build od deploy?**
Kontener buildowy nie nadaje się do wdrożenia na produkcję, ponieważ jest zbyt "ciężki" i zawiera niepotrzebne narzędzia deweloperskie, co zwiększa powierzchnię ataku. Różnica między obrazem `node` a `node-slim` (lub `node-alpine`) jest kluczowa: pełny obraz zawiera wiele pakietów systemowych, natomiast `slim/alpine` zawiera tylko absolutne minimum niezbędne do uruchomienia silnika V8 i aplikacji. 

Do obrazu Deploy kopiowane są jedynie zbudowane artefakty z etapu pierwszego, a pakiety instalowane są z flagą `--omit=dev` (tylko zależności produkcyjne). Obraz ten nie zawiera historii builda ani plików źródłowych testów.

### 2.3. Wdrożenie docelowe i redystrybucja
Zdecydowano, że docelową formą redystrybucyjną (Publish) będzie gotowy do uruchomienia obraz kontenera Docker, spakowany do formatu `.tar.gz` (tzw. Docker archive). Zapewnia to absolutną przenaszalność – plik ten jest pełnoprawnym i kompletnym artefaktem.

---

## 3. Laboratorium 7: Pipeline as Code (Jenkinsfile)

Realizacja pełnej ścieżki krytycznej (*commit -> clone -> build -> test -> deploy -> publish*) została ujęta w sposób deklaratywny w pliku `Jenkinsfile`, przechowywanym bezpośrednio w repozytorium kodu.

### 3.1. Zrealizowane etapy potoku (Pipeline Steps)
1. **Checkout SCM (Clone):** Definicja potoku pochodzi z systemu kontroli wersji (SCM). Jenkins automatycznie klonuje wskazane repozytorium, zapewniając zawsze pracę na objętym audytem kodzie.
2. **Budowanie i Testowanie (Build & Test):** Uruchomienie komendy `docker build` celującej w etap testowy z pliku Dockerfile. Wymuszenie braku cache'u (`--no-cache`) gwarantuje, że kod budowany jest od zera, co niweluje problem fałszywie pozytywnych buildów (tzw. "działa u mnie").
3. **Budowanie obrazu Deploy:** Zbudowanie zoptymalizowanego obrazu produkcyjnego ze zdefiniowanym konkretnym tagiem wersji (Semantic Versioning), łączącym numer wersji z unikalnym `BUILD_ID` potoku.
4. **Weryfikacja Sandboxowa (Smoke Test - Deploy):** Przed publikacją artefaktu, obraz docelowy uruchamiany jest w środowisku izolowanym (`docker run -d`). Potok weryfikuje poprawne podniesienie aplikacji, odpytując jej endpoint (np. port 3000) za pomocą komendy `wget`. Otrzymanie poprawnej odpowiedzi HTTP warunkuje dalsze kroki.
5. **Publikacja Artefaktu (Publish):** Gotowy kontener jest kompresowany (`docker save ... | gzip`) i dołączany do zadania w Jenkinsie za pomocą kroku `archiveArtifacts`.
6. **Sprzątanie (Post Actions):** Użycie dyrektywy `cleanWs()` na końcu potoku gwarantuje usunięcie pozostałości i zapobiega wyciekom danych pomiędzy kolejnymi uruchomieniami zadań. Wymusza to stuprocentową niezależność kolejnych wywołań potoku.

### 3.2. Weryfikacja "Definition of Done"
Zaprojektowany proces uznaje się za skuteczny i zakończony wdrożeniem, ponieważ spełnia poniższe rygorystyczne warunki:

* **Brak konieczności modyfikacji na produkcji:** Utworzony artefakt (archiwum tar.gz z obrazem kontenera) zawiera już środowisko uruchomieniowe Node.js oraz skompilowany kod z zainstalowanymi modułami. Można go pobrać z Jenkinsa, wczytać (`docker load`) i uruchomić na dowolnym serwerze na świecie.
* **Gotowość do uruchomienia od razu:** Docelowy obraz posiada zdefiniowany `ENTRYPOINT` / `CMD` odpowiadający za poprawne wystartowanie aplikacji, wyeksponowane porty (`EXPOSE`) oraz minimalne wymagane zmienne środowiskowe. Instalacja ogranicza się do posiadania silnika Docker na maszynie produkcyjnej. Środowisko nie wymaga instalowania żadnych dodatkowych bibliotek. Pomyślne zrealizowanie etapu "Smoke Test" stanowi niezaprzeczalny dowód, że artefakt "położony" na czystym środowisku działa poprawnie i automatycznie serwuje aplikację.

---

**Podsumowanie:** Konfiguracja infrastruktury oparta na DIND z użyciem deklaratywnego pliku `Jenkinsfile` pozwoliła na skuteczne wdrożenie procesu ciągłej integracji i dostarczania, zapewniając automatyzację testów, najwyższe standardy bezpieczeństwa (Multi-stage builds, clean workspace) oraz w pełni przenaszalny i izolowany artefakt końcowy.
