# Raport Zbiorczy: Metodologia i Architektura Środowisk DevOps
**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE | **Grupa:** G6

## Wstęp
Cykl laboratoriów 1-4 stanowił kompleksowe wprowadzenie do nowoczesnych metod wytwarzania oprogramowania, gdzie punkt ciężkości przesunięto z implementacji kodu na architekturę środowiska wytwórczego. W dobie mikroserwisów i chmury obliczeniowej, umiejętność zarządzania infrastrukturą staje się równie istotna, co sama biegłość w programowaniu. Celem prac było przejście od manualnej konfiguracji stacji roboczej, przez izolację procesów w kontenerach, aż po pełną orkiestrację potoków CI/CD (Continuous Integration / Continuous Deployment). Kluczowym założeniem była realizacja paradygmatu **Infrastructure as Code (IaC)**, gwarantującego powtarzalność, skalowalność i bezpieczeństwo na każdym etapie cyklu życia aplikacji.

## 1. Fundamenty komunikacji i bezpieczeństwa (SSH & Git)
Pierwszy etap prac skupił się na ustanowieniu ustandaryzowanego i bezpiecznego kanału komunikacji między lokalnym środowiskiem deweloperskim a zdalnymi systemami kontroli wersji (GitHub) oraz serwerami operacyjnymi (Ubuntu 24.04 LTS).

### 1.1 Kryptografia asymetryczna w praktyce
Zrezygnowano ze starszych, podatnych na ataki standardów (jak RSA z krótkim kluczem) na rzecz algorytmu **ED25519**. Opiera się on na krzywych eliptycznych, co zapewnia wyższy poziom bezpieczeństwa przy znacznie krótszym kluczu i mniejszym narzucie obliczeniowym. Jest to obecnie standard w branży DevOps.
*   **Kluczowe operacje:** Generowanie par kluczy, implementacja agenta uwierzytelniającego (`ssh-agent`) oraz bezpieczna dystrybucja klucza publicznego. Dzięki temu wyeliminowano konieczność przesyłania haseł w formie jawnej przez sieć.

### 1.2 Automatyzacja standardów poprzez Git Hooks
W celu wymuszenia spójności historii zmian w repozytorium, zaimplementowano lokalne skrypty automatyzacji (**commit-msg hook**). Mechanizm ten działa po stronie klienta i blokuje operację zatwierdzania zmian (`commit`), jeśli wiadomość nie spełnia narzuconego formatu.
*   **Cel:** Identyfikacja autora przez numer indeksu (MS422035). Symuluje to rzeczywiste reguły obowiązujące w profesjonalnych zespołach, gdzie wiadomości commitów muszą zawierać np. numer zadania z systemu Jira.

## 2. Teoria i mechanika kontenerów (Docker)
Kolejnym filarem było wdrożenie technologii kontenerowej jako wydajnej alternatywy dla ciężkiej wirtualizacji sprzętowej.

### 2.1 Architektura izolacji: Namespaces i Control Groups
Docker wykorzystuje mechanizmy jądra Linux do separacji zasobów. Podczas testów na obrazach Ubuntu i BusyBox wykazano działanie **Namespaces** (przestrzeni nazw).
*   **Obserwacja:** Proces wewnątrz kontenera operuje na **PID 1** (Process ID), zachowując pełną izolację od stosu systemowego hosta. Oznacza to, że aplikacja "myśli", że jest jedynym procesem w systemie, co drastycznie ułatwia zarządzanie zależnościami.
*   **Cgroups:** Mechanizm ten zapewnia, że kontener nie zużyje wszystkich zasobów maszyny fizycznej (pamięć RAM, CPU), co gwarantuje stabilność całego węzła.

### 2.2 Optymalizacja poprzez UnionFS
Analiza warstwowości obrazów pozwoliła zrozumieć działanie systemu plików **UnionFS**. Każda instrukcja w `Dockerfile` tworzy nową warstwę "tylko do odczytu". W przypadku błędu w budowaniu, Docker wykorzystuje mechanizm cache'owania, co pozwala na błyskawiczne wznowienie procesu od ostatniego poprawnego kroku.

## 3. Konteneryzacja jako definicja etapu budowania (CI)
W trzecim etapie kontenery przestały być traktowane jedynie jako środowiska uruchomieniowe, a stały się definicjami konkretnych kroków w procesie **Continuous Integration**.

### 3.1 Problem Headless i wirtualizacja grafiki (Xvfb)
Podczas testowania aplikacji **Java/Maven (Calculator)** napotkano błąd `HeadlessException`. Wynika on z natury kontenerów serwerowych – nie posiadają one fizycznej karty graficznej ani monitora, a biblioteki Java AWT/Swing wymagają serwera wyświetlania X11.
*   **Rozwiązanie:** Implementacja **Xvfb (X virtual framebuffer)**. Jest to serwer wyświetlania realizujący wszystkie operacje graficzne w pamięci RAM. Dzięki temu możliwe było poprawne przeprowadzenie testów jednostkowych GUI w środowisku całkowicie pozbawionym interfejsu graficznego.

### 3.2 Budowanie wieloetapowe (Multi-stage Builds)
Zastosowano technikę rozdzielenia środowiska kompilacji od produkcyjnego w jednym pliku `Dockerfile`.
1.  **Stage 1 (Build):** Zawiera pełne SDK, Maven i kody źródłowe. Tu następuje kompilacja.
2.  **Stage 2 (Runtime):** Zawiera tylko niezbędne środowisko JRE i skompilowany plik `.jar`.
*   **Zaleta:** Drastyczne zmniejszenie rozmiaru końcowego obrazu (nawet o 80%) oraz poprawa bezpieczeństwa poprzez usunięcie narzędzi kompilacyjnych z obrazu, który trafia na serwer.

## 4. Persystencja, Sieciowość i Zaawansowana Orkiestracja
Ostatni etap prac poświęcono zagadnieniom operacyjnym i automatyzacji serwerowej przy użyciu systemu Jenkins.

### 4.1 Zarządzanie stanem: Woluminy vs Bind Mounts
Zrozumienie ulotności (ephemeral nature) kontenerów doprowadziło do wdrożenia mechanizmów persystencji:
*   **Named Volumes:** Wykorzystane do przechowywania danych konfiguracyjnych Jenkinsa. Dane te "przeżywają" usunięcie kontenera, co jest kluczowe w systemach produkcyjnych.
*   **Bind Mounts:** Wykorzystane do mapowania gniazda Dockera (`/var/run/docker.sock`), co pozwala na architekturę DooD (Docker-outside-of-Docker).

### 4.2 Diagnostyka sieciowa (iperf3)
Przeprowadzono testy wydajnościowe, porównując domyślne mostki sieciowe (`bridge`) z trybem `host`.
*   **Wniosek:** Tryb `bridge` wprowadza minimalny narzut wynikający z translacji adresów (NAT), ale zapewnia kluczową dla DevOps izolację i możliwość komunikacji po nazwach usług (DNS Dockera).

### 4.3 Architektura CI: Jenkins Master-Agent
Zaimplementowano instancję Jenkinsa, która zleca zadania budowania osobnym kontenerom. Pozwala to na pełną separację: serwer Jenkins zarządza jedynie logiką kolejek, podczas gdy faktyczne budowanie kodu odbywa się w dynamicznie powoływanych, czystych kontenerach-agentach.

## 5. Kompendium Techniczne i Wykaz Poleceń

### 1. Zarządzanie Git i SSH
```bash
# Generowanie klucza
ssh-keygen -t ed25519 -C "MS422035"

# Ładowanie klucza do pamięci
ssh-add ~/.ssh/id_ed25519

# Zarządzanie przepływem pracy na gałęziach
git checkout -b MS422035
```
### 2. Operacje Docker i Diagnostyka
```bash
# Uruchomienie interaktywne z czyszczeniem
docker run -it --rm --name dev-container ubuntu:24.04

# Dogłębna analiza techniczna zasobów
docker inspect [container_id]

# Usuwanie nieużywanych warstw i obrazów
docker system prune -a

# Weryfikacja przepustowości łączy między kontenerami
iperf3 -s
iperf3 -c [server_ip]
```

### 3. Orkiestracja i CI
```bash
# Deklaratywne uruchamianie całego stosu usług
docker-compose up -d

# Kluczowe polecenie dla testów interfejsu graficznego w kontenerze
xvfb-run mvn test

# Dostęp do poświadczeń administratora Jenkins
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
## Wnioski i Podsumowanie
Realizacja cyklu laboratoriów pozwoliła na zrozumienie, że powtarzalność środowiska jest fundamentem stabilnego procesu dostarczania oprogramowania. Kluczem do sukcesu jest dążenie do pełnej automatyzacji, gdzie każdy element infrastruktury jest opisany kodem i może zostać odtworzony w dowolnym momencie. Synergia narzędzi Git, Docker i Jenkins tworzy kompletny ekosystem, który minimalizuje ryzyko wystąpienia błędów konfiguracyjnych i przyspiesza cykl wydawniczy.