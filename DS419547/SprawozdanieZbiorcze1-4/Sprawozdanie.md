# Sprawozdanie Zbiorcze z Laboratoriów 1-4

### Wstęp
Pierwszy blok zajęć laboratoryjnych stanowił wprowadzenie w metody wytwarzania oprogramowania, gdzie nacisk kładziono nie na sam kod, ale przede na środowisko, w którym ten kod powstaje, jest testowany i uruchamiany. Rozpoczęliśmy od konfiguracji lokalnej maszyny, przez izolację procesów w kontenerach, aż po tworzenie całych środowisk i wstępną automatyzację typu CI/CD. Dążyliśmy do sytuacji, w której każdy etap pracy jest udokumentowany, powtarzalny i bezpieczny.

### Wprowadzenie, Git, Gałęzie, SSH (Lab 01)
Pierwszy etap skupił się na przygotowaniu bezpiecznego i ustandaryzowanego środowiska pracy. Pierwszym elementem była konfiguracja protokołu SSH do komunikacji z GitHubem.
Zainstalowaliśmy klienta Git, utworzyliśmy dwa klucze SSH oraz skonfigurowaliśmy je jako metodę dostępu do GitHuba używając GitHub CLI.

W celu wymuszenia spójności, przetestowaliśmy lokalny mechanizm automatyzacji w postaci Git hooka `pre-commit`. Skrypt ten weryfikuje, czy każda wiadomość commita zaczyna się od zdefiniowanego prefiksu (inicjały i numer indeksu), co znacząco, poza zaprezentowaniem działania Git hooków, ułatwia późniejszą analizę historii zmian w repozytorium.

**Zastosowane rozwiązania:**
*   **SSH**: Zapewnia bezpieczną i bezobsługową autoryzację w komunikacji z serwerem.
*   **Git Hooks**: Pozwalają na automatyczną walidację standardów przed wysłaniem kodu do zdalnego źródła.

![Mechanizm Git hook w praktyce](img/git_hook.png)

### Git, Docker (Lab 02)
Kolejne zajęcia dotyczyły konteneryzacji procesów przy użyciu Dockera. Głównym celem było zrozumienie różnicy między kontenerem a maszyną wirtualną. Kontener, jako wyizolowany proces współdzielący jądro systemu z hostem, pozwala na znacznie szybsze uruchamianie usług przy minimalnym narzucie zasobów.

Przeprowadziliśmy testy na różnych obrazach systemowych (BusyBox, Ubuntu, MariaDB) oraz przygotowaliśmy własny plik Dockerfile. Pozwoliło to na stworzenie powtarzalnego środowiska, w którym repozytorium jest automatycznie klonowane do wnętrza obrazu, co eliminuje problemy z brakiem zależności na różnych maszynach deweloperskich.

**Zalety konteneryzacji w procesie DevOps:**
*   **Izolacja**: Środowisko uruchomieniowe jest niezależne od konfiguracji systemu hosta.
*   **Powtarzalność**: Każdy członek zespołu pracuje na dokładnie takim samym obrazie bazowym.
*   **Czystość systemu**: Zależności aplikacji nie muszą być instalowane bezpośrednio w systemie operacyjnym.

![Budowa i uruchomienie pierwszego spersonalizowanego kontenera](img/docker-run-wlasny.png)

### Dockerfiles, kontener jako definicja etapu (Lab 03)
Na tym etapie wykorzystaliśmy kontenery jako definicje konkretnych kroków w budowaniu aplikacji (CI). Do testów posłużył projekt oparty na frameworku NestJS. Aby zapewnić stabilność procesu, użyliśmy komendy `npm ci`, która instaluje zależności ściśle według pliku `package-lock.json`, gwarantując zgodność wersji bibliotek.

Całość procesu została zautomatyzowana za pomocą Docker Compose. Pozwoliło to na zdefiniowanie wieloetapowego budowania (multi-stage build), gdzie jeden obraz odpowiada za kompilację kodu z TypeScriptu do JavaScriptu, a kolejny za uruchomienie testów jednostkowych w czystym środowisku.

**Kluczowe techniki budowania:**
*   **Multi-stage build**: Rozdzielenie etapu kompilacji od etapu testowania i uruchamiania w celu optymalizacji obrazów.
*   **Docker Compose**: Orkiestracja kontenerów za pomocą deklaratywnego pliku YAML, co upraszcza zarządzanie parametrami uruchomieniowymi.
*   **Integracja testów**: Automatyczne przerwanie procesu budowania w przypadku wykrycia błędów w testach jednostkowych.

![Zautomatyzowany raport z testów jednostkowych w izolowanym środowisku](img/8-dockerfile-test-results.png)

### Dodatkowa terminologia w konteneryzacji, instancja Jenkins (Lab 04)
Ostatnie laboratorium poświęcono już bardziej zaawansowanym zagadnieniom infrastrukturalnym i uruchomieniu serwera Jenkins. Jednym z celów było zapewnienie trwałości danych przy użyciu woluminów Dockera, co zapobiega utracie konfiguracji Jenkinsa po restarcie kontenera.

Przeprowadziliśmy również testy wydajnościowe sieci narzędziem `iperf`, porównując domyślny sterownik `bridge` z trybem `host`. Pozwoliło to zrozumieć koszty wydajnościowe izolacji sieciowej. Na koniec skonfigurowaliśmy architekturę Master-Agent, gdzie główna instancja Jenkinsa zleca wykonywanie zadań budowania osobnym kontenerom-agentom.

**Wnioski z konfiguracji infrastruktury:**
*   **Woluminy**: Niezbędne do zachowania stanu aplikacji wewnątrz kontenerów.
*   **Wydajność sieci**: Wybór między izolacją a wydajnością zależy od specyfiki konkretnego wdrożenia.
*   **Skalowalność**: Podział na Mastera i Agenty pozwala na równoległe przetwarzanie zadań bez przeciążania serwera głównego.

![Monitorowanie statusu kontenerów Jenkinsa i agentów roboczych](img/8-jenkins-containers.png)

### Kompendium Techniczne i Wykaz Komend

Poniższe zestawienie stanowi techniczny i teoretyczny fundament zrealizowanych prac, zawierający pogłębiony opis mechanizmów oraz wykaz kluczowych komend.

#### 1. System Kontroli Wersji (Git) i Bezpieczeństwo (SSH)
Git jest rozproszonym systemem kontroli wersji, który pozwala na śledzenie historii zmian w kodzie. Bezpieczeństwo komunikacji zapewnia protokół SSH, oparty na kryptografii asymetrycznej (para kluczy: publiczny na serwerze, prywatny na maszynie lokalnej).

*   **Podstawowe komendy Git**:
    *   `git init` – inicjalizacja nowego repozytorium w bieżącym katalogu.
    *   `git status` – sprawdzenie stanu plików (śledzone, nieśledzone, zmodyfikowane).
    *   `git add <plik>` lub `git add .` – dodanie zmian do obszaru *staging* (przygotowanie do commita).
    *   `git commit -m "wiadomość"` – zatwierdzenie zmian i utworzenie migawki (snapshot) stanu projektu.
    *   `git log` – wyświetlenie pełnej historii commitów.
    *   `git branch <nazwa>` – tworzenie nowej gałęzi.
    *   `git checkout <nazwa>` – przełączenie się na inną gałąź. `git checkout -b <nazwa>` – tworzy i przełącza jednocześnie.
    *   `git merge <nazwa>` – scalanie zmian z innej gałęzi do obecnej.
    *   `git pull` – pobranie zmian ze zdalnego repozytorium i ich automatyczne scalenie.
    *   `git push` – wysłanie lokalnych commitów do zdalnego źródła.
*   **SSH i Zarządzanie kluczami**:
    *   `ssh-keygen -t ed25519 -C "opis"` – generowanie nowoczesnego klucza (zalecany algorytm ED25519).
    *   `ssh-add ~/.ssh/id_ed25519` – dodanie klucza do agenta, co pozwala uniknąć ponownego wpisywania hasła (passphrase).
    *   `cat ~/.ssh/id_ed25519.pub` – pobranie klucza publicznego do konfiguracji na GitHubie.
*   **Git Hooks**: Skrypty w `.git/hooks/` (np. `pre-commit`, `commit-msg`) automatyzują weryfikację standardów przed wysłaniem kodu.

#### 2. Konteneryzacja (Docker) - Koncepcja i Narzędzia
Docker to platforma pozwalająca na "spakowanie" aplikacji wraz ze wszystkimi jej zależnościami (biblioteki, pliki konfiguracyjne, środowisko uruchomieniowe) do jednego, przenośnego obrazu.

*   **Obraz (Image)**: Tylko do odczytu szablon (blueprint), z którego tworzone są kontenery. Składa się z warstw. Jest niemodyfikowalny po zbudowaniu.
*   **Kontener (Container)**: Uruchomiona, izolowana instancja obrazu. To żyjący proces, który posiada własny system plików, sieć i przestrzeń procesów, ale współdzieli jądro (kernel) systemu hosta.
*   **Szczegółowa analiza `docker run`**:
    `docker run [OPCJE] OBRAZ [POLECENIE] [ARGUMENTY]`
    *   `-d` (Detached): Uruchomienie kontenera w tle.
    *   `-it` (Interactive + TTY): Umożliwia interakcję z kontenerem przez terminal (np. wejście do basha).
    *   `--name <nazwa>`: Nadanie kontenerowi przyjaznej nazwy zamiast losowego identyfikatora.
    *   `-p <port_hosta>:<port_kontenera>`: Mapowanie portów (np. `-p 8080:80` udostępnia usługę kontenera na porcie 8080 hosta).
    *   `-v <sciezka_hosta/nazwa_wolumenu>:<sciezka_kontenera>`: Montowanie wolumenu dla trwałości danych.
    *   `-e KLUCZ=WARTOSC`: Przekazanie zmiennych środowiskowych do aplikacji.
    *   `--rm`: Automatyczne usunięcie kontenera po jego zatrzymaniu (zachowanie czystości systemu).
    *   `--network <nazwa>`: Podłączenie kontenera do konkretnej sieci Dockera.
*   **Diagnostyka**:
    *   `docker ps -a` – lista kontenerów.
    *   `docker logs -f <id>` – śledzenie logów na żywo.
    *   `docker exec -it <id> bash` – wejście do działającego kontenera.
    *   `docker inspect <id>` – szczegółowe dane techniczne (JSON).

#### 3. Budowanie Własnych Obrazów (Dockerfile)
Dockerfile to plik tekstowy zawierający instrukcje krok po kroku, jak zbudować obraz.

*   **Podstawowe instrukcje**:
    *   `FROM`: Określa obraz bazowy (fundament, np. `ubuntu:22.04` lub `node:20`).
    *   `WORKDIR`: Ustawia katalog roboczy dla wszystkich kolejnych instrukcji (odpowiednik `cd`).
    *   `COPY` i `ADD`: Kopiowanie plików z lokalnego dysku do systemu plików obrazu.
    *   `RUN`: Wykonuje komendy powłoki podczas budowania (np. instalacja pakietów: `apt-get install`). Każdy `RUN` tworzy nową warstwę.
    *   `ENV`: Definiuje zmienne środowiskowe dostępne podczas budowania i w czasie działania kontenera.
    *   `EXPOSE`: Dokumentuje, na których portach aplikacja będzie nasłuchiwać (nie otwiera ich automatycznie na hoście).
    *   `CMD`: Domyślne polecenie uruchamiane przy starcie kontenera. Może zostać nadpisane przez użytkownika przy `docker run`.
    *   `ENTRYPOINT`: Główne polecenie kontenera, którego zazwyczaj się nie nadpisuje (często łączy się z `CMD`).

#### 4. Orkiestracja (Docker Compose)
Docker Compose służy do definiowania i uruchamiania wielokontenerowych aplikacji przy użyciu pliku YAML (`docker-compose.yml`).

*   **Struktura pliku YAML**:
    *   `services`: Definicje poszczególnych kontenerów (np. `db`, `app`, `web`).
    *   `build`: Ścieżka do katalogu z Dockerfile (jeśli obraz ma być zbudowany lokalnie).
    *   `image`: Nazwa obrazu do pobrania lub tag do nadania budowanemu obrazowi.
    *   `ports`, `volumes`, `networks`: Konfiguracja zasobów dla konkretnej usługi.
    *   `depends_on`: Określa kolejność uruchamiania (np. aplikacja czeka na start bazy danych).
*   **Komendy Docker Compose**:
    *   `docker compose up -d` – buduje (jeśli trzeba), tworzy i uruchamia wszystkie usługi w tle.
    *   `docker compose down` – zatrzymuje i usuwa kontenery, sieci i obrazy zdefiniowane w projekcie.
    *   `docker compose ps` – status usług w ramach projektu.
    *   `docker compose logs -f` – zbiorcze logi ze wszystkich kontenerów usługi.

#### 5. Mechanizmy Trwałości, Sieci i Diagnostyka
*   **Woluminy (Volumes) – Typy i przeznaczenie**:
    Warstwa zapisu wewnątrz kontenera jest domyślnie ulotna i wolniejsza (Copy-on-Write). Woluminy rozwiązują te problemy, przenosząc dane poza cykl życia kontenera.
    1.  **Named Volumes** (`-v nazwa:/sciezka`): Zarządzane całkowicie przez Dockera. Idealne do baz danych (np. `/var/lib/mysql`). Są niezależne od struktury katalogów hosta, co ułatwia migrację.
    2.  **Bind Mounts** (`-v /host/path:/container/path`): Mapują konkretny plik lub katalog z hosta. Pozwalają na edycję kodu źródłowego na maszynie dewelopera i natychmiastowe testowanie w kontenerze. Użycie flagi `:ro` (read-only) zwiększa bezpieczeństwo, blokując kontenerowi możliwość modyfikacji plików hosta.
    3.  **tmpfs mounts**: Przechowywanie danych wyłącznie w pamięci RAM hosta. Dane nigdy nie trafiają na dysk, co zapewnia ekstremalną szybkość i bezpieczeństwo (dane wrażliwe, np. klucze, giną natychmiast po zatrzymaniu kontenera).
*   **Sieci (Networking) – Architektura i typy**:
    *   **Bridge (Mostek)**: Domyślny tryb. Docker tworzy wirtualny interfejs (np. `docker0`), a kontenery komunikują się przez NAT. Każda sieć typu bridge ma własny serwer DNS, co pozwala kontenerom łączyć się po nazwach usług (np. `app` łączy się z `db`).
    *   **Host**: Kontener korzysta bezpośrednio ze stosu sieciowego hosta. Brak narzutu translacji adresów zapewnia najwyższą wydajność, ale powoduje konflikty portów (tylko jeden kontener na danym porcie na całym hostcie).
    *   **Overlay**: Umożliwia komunikację kontenerów działających na różnych hostach fizycznych (klaster Swarm). Tworzy rozproszoną sieć wirtualną nad fizyczną infrastrukturą.
    *   **Macvlan**: Przypisuje kontenerowi własny, fizyczny adres MAC. Kontener staje się widoczny w sieci lokalnej jako osobne, fizyczne urządzenie, co ułatwia integrację ze starszymi systemami monitorowania sieci.
    *   **None**: Całkowity brak interfejsów sieciowych (poza loopback). Stosowany dla zadań wymagających maksymalnej izolacji.
*   **Diagnostyka przepustowości (iperf3)**:
    Narzędzie do aktywnego pomiaru maksymalnej przepustowości łączy IP. W laboratoriach pozwoliło na porównanie wydajności sieci `bridge` i `host`.
    *   `iperf3 -s`: Uruchomienie serwera nasłuchującego na porcie 5201.
    *   `iperf3 -c <IP> -t 10`: Uruchomienie klienta wykonującego test przez 10 sekund.
    *   `iperf3 -u -b 100M`: Wykonanie testu protokołu UDP z ograniczeniem pasma do 100 Mbit/s (pozwala badać straty pakietów).

#### 6. Automatyzacja i Zaawansowana Architektura CI (Jenkins)
*   **Jenkins Master-Agent**: Centralny serwer (Master) zarządza logiką i interfejsem, natomiast Agenty wykonują faktyczne kroki budowania. Agenty mogą być uruchamiane jako kontenery Dockera "na żądanie" (on-demand), co gwarantuje czyste środowisko dla każdego zadania.
*   **Docker-in-Docker (DinD) oraz DooD**:
    W środowisku CI agenty często muszą same budować obrazy (`docker build`) lub uruchamiać kontenery testowe.
    *   **DinD (Docker-in-Docker)**: Kontener-agent posiada własny, odizolowany demon Dockera wewnątrz. Wymaga trybu `--privileged`.
    *   **DooD (Docker-outside-of-Docker)**: Najczęstsza praktyka polegająca na montowaniu gniazda Dockera hosta (`-v /var/run/docker.sock:/var/run/docker.sock`) do kontenera-agenta. Agent zleca operacje Dockerowe demonowi działającemu na maszynie-gospodarzu, co jest wydajniejsze i łatwiejsze w zarządzaniu cache'em obrazów.
*   **npm ci (Clean Install)**: Krytyczne narzędzie w procesach CI, różniące się od `npm install`:
    1.  Wymaga pliku `package-lock.json` i instaluje wersje w nim zablokowane (brak niespodzianek przy nowych wydaniach bibliotek).
    2.  Usuwa istniejący folder `node_modules` przed startem, zapewniając brak pozostałości z poprzednich prób.
    3.  Kończy się błędem, jeśli zależności w `package.json` nie zgadzają się z plikiem blokady.

### Podsumowanie i wyciągnięte wnioski
Realizacja czterech laboratoriów pozwoliła na zbudowanie kompletnego fundamentu pod nowoczesne podejście do inżynierii oprogramowania. Przejście od ręcznej konfiguracji do automatyzacji w Jenkinsie pokazało, jak duży wpływ na jakość i tempo prac ma odpowiedni dobór narzędzi.

Najważniejszą wyciągniętą wiedzą było zrozumienie, że powtarzalność środowiska jest głównym czynnikiem stabilnego procesu CI/CD. Dzięki zastosowaniu Dockera i Gita, proces wytwarzania oprogramowania staje się przewidywalny, a ewentualne błędy są wykrywane na wczesnym etapie, zanim trafią do środowiska produkcyjnego.
