# Raport Zbiorczy: Zaawansowane Potoki CI/CD i Infrastruktura jako Kod (IaC)
**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE | **Grupa:** G6

## Wstęp
Cykl laboratoriów 5-7 stanowił płynne przejście od lokalnego zarządzania kontenerami do pełnej automatyzacji procesów wytwórczych w architekturze rozproszonej. Głównym celem było wdrożenie profesjonalnych narzędzi klasy Continuous Integration / Continuous Deployment (CI/CD) przy użyciu serwera Jenkins, a następnie przygotowanie fundamentów pod zarządzanie konfiguracją maszyn z wykorzystaniem systemu Ansible. Kluczowym paradygmatem realizowanym podczas tych prac było podejście **Pipeline-as-a-Code** oraz **Infrastructure as Code (IaC)**, które gwarantują, że zarówno proces budowania aplikacji, jak i stan infrastruktury są wersjonowane, powtarzalne i niezależne od lokalnego środowiska dewelopera.

## 1. Architektura Izolowana CI (Docker-in-Docker)
Pierwszym krokiem ku automatyzacji było powołanie odpornego na awarie serwera ciągłej integracji. Zrezygnowano z klasycznej instalacji bezpośrednio na systemie operacyjnym na rzecz środowiska w pełni skonteneryzowanego.

### 1.1 Architektura Sidecar i Separacja Zadań
Wdrożono serwer Jenkins współpracujący z niezależnym demonem Dockera w modelu **Docker-in-Docker (DinD)**.
* **Izolacja:** Logika zarządzania zadaniami (Jenkins Blue Ocean) została oddzielona od silnika budującego (DinD). Komunikacja odbywała się w obrębie dedykowanej, wewnętrznej sieci wirtualnej `jenkins`, co znacząco podniosło bezpieczeństwo środowiska.
* **Persystencja:** Skonfigurowano woluminy stałe (`jenkins-data`), aby uodpornić konfigurację i historię potoków na ulotność kontenerów. 

### 1.2 Administracja i Optymalizacja Zasobów
Wprowadzono rygorystyczne zasady zarządzania systemem:
* **Bezpieczeństwo:** Zablokowano dostęp anonimowy, wdrażając pełną autoryzację dla użytkowników zalogowanych.
* **Rotacja logów:** Zaimplementowano mechanizm *Build Discarder*, ograniczając historię do 5 ostatnich kompilacji, co chroni woluminy przed wyczerpaniem przestrzeni dyskowej.

## 2. Konteneryzacja Aplikacji i Multi-stage Builds
Kluczowym aspektem integracji była konteneryzacja samej aplikacji (Spring Boot/Java) w sposób pozwalający na jej płynne przenoszenie między środowiskami.

### 2.1 Optymalizacja środowiska wykonawczego
Zastosowano architekturę wieloetapową (**Multi-stage build**), która rozwiązuje problem "ciężkich" obrazów:
* **Etap budowania:** Obszerny obraz z JDK i narzędziem Maven do kompilacji i testowania kodu.
* **Etap uruchomieniowy:** Minimalistyczny obraz `eclipse-temurin:21-jre-alpine`, do którego kopiowany jest wyłącznie gotowy plik wykonywalny (`.jar`).
Dzięki temu środowisko produkcyjne jest lżejsze i pozbawione zbędnych narzędzi deweloperskich, co zmniejsza wektor potencjalnych ataków.

### 2.2 Wykorzystanie Docker Cache
Zbadano i wdrożono mechanizmy buforowania warstw Dockera (Layer Caching). Analiza wykazała skrócenie czasu budowania potoku z 31 sekund do 10 sekund (zysk ok. 67%) przy kolejnych uruchomieniach, co ma krytyczne znaczenie dla optymalizacji czasu pracy w zespołach programistycznych.

## 3. Ewolucja Potoków (Pipeline-as-a-Code)
Proces CI/CD ewoluował od prostych, wyklikiwanych zadań (Freestyle Projects) do w pełni zautomatyzowanych, deklaratywnych skryptów.

### 3.1 Integracja SCM (Source Control Management)
Zrezygnowano z utrzymywania logiki budowania w interfejsie graficznym Jenkinsa. Definicja procesu została przeniesiona do pliku `Jenkinsfile` w repozytorium GitHub. Serwer CI pobierał definicję potoku z gałęzi docelowej (MS422035), co zapewnia pełną zgodność procesu z wersją kodu, dla której został napisany.

### 3.2 Ścieżka Krytyczna Potoku
Zaprojektowano i zaimplementowano pełen cykl życia wdrożenia:
1.  **Cleanup & Setup:** Czyszczenie przestrzeni roboczej (`deleteDir()`) i pobieranie bez użycia starych danych z cache (`--no-cache`).
2.  **Build & Test:** Kompilacja, wykonanie testów jednostkowych (JUnit) oraz weryfikacja zgodności wersji maszyny wirtualnej Java.
3.  **Deploy (Sandbox):** Uruchomienie aplikacji w odizolowanym kontenerze testowym i wykonanie mechanicznego *Smoke Testu* za pomocą polecenia `curl`. Udowadnia to gotowość do wdrożenia.
4.  **Publish:** Przechwycenie gotowego artefaktu (plik JAR) do historii Jenkinsa, realizując "Definition of Done" – opublikowany obraz i plik można pobrać i uruchomić na dowolnej maszynie.

## 4. Wstęp do Zarządzania Konfiguracją (Ansible)
Ostatni etap prac stanowił pomost między ciągłą integracją (CI) a automatycznym zarządzaniem infrastrukturą docelową.

### 4.1 Bezhasłowa komunikacja SSH
Przygotowano zminimalizowaną maszynę wirtualną (`ansible-target` z systemem Ubuntu Server) pełniącą rolę węzła docelowego. Wygenerowano dedykowane, bezhasłowe klucze RSA na węźle sterującym (Control Node) i za pomocą narzędzia `ssh-copy-id` wdrożono je w systemie docelowym. Pozwoliło to na w pełni zautomatyzowaną autoryzację, która jest warunkiem koniecznym do działania systemów IaC.

### 4.2 Inicjalizacja Ansible
Zainstalowano oprogramowanie Ansible, zdefiniowano plik inwentarza (`inventory.ini`) i pomyślnie zestawiono komunikację (moduł `ping`). Środowisko to otwiera drogę do deklaratywnego instalowania pakietów i wdrażania artefaktów (wygenerowanych wcześniej przez Jenkinsa) na wielu serwerach produkcyjnych jednocześnie.

## 5. Kompendium Techniczne i Wykaz Poleceń

### 1. Optymalizacja i Testowanie Kontenerów
```bash
# Budowanie obrazu bez korzystania z cache'owanych warstw
docker build --no-cache -t spring-api-prod:final .

# Nadpisywanie punktu wejścia w celu testów (np. weryfikacja wersji)
docker run --rm --entrypoint java spring-api-prod:final -version

# Pobieranie artefaktu ze zbudowanego, tymczasowego kontenera
docker create --name temp-container spring-api-prod:final
docker cp temp-container:/usr/src/app/api.jar ./api-v8.jar