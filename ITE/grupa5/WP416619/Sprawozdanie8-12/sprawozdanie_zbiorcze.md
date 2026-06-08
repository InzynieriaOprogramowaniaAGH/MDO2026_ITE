# Zbiorcze Sprawozdanie 8-12

**Student:** Wilhelm Pasterz

**Indeks:** 416619

**Kierunek:** ITE

**Grupa:** 5

---

## 1. Automatyzacja Systemu Operacyjnego: Nienadzorowana Instalacja (Kickstart)

### Cel i Architektura Rozwiązania

* **Cel:** Przeprowadzenie w pełni nienadzorowanej instalacji systemu Linux przy użyciu pliku odpowiedzi Kickstart (`ks.cfg`).
* **Model:** Klient-serwer (serwer HTTP hosta udostępnia plik konfiguracyjny, a maszyna docelowa VirtualBox w trybie Bridged Adapter pobiera go przy rozruchu).

### Definicja i Struktura Pliku Kickstart (`ks.cfg`)

* **Ustawienia instalatora:** Konfiguracja języka, układu klawiatury, strefy czasowej, automatycznego czyszczenia dysku (`clearpart --all --initlabel`) oraz automatycznego restartu po zakończeniu pracy.
* **Sekcja %packages:** Deklaracja instalacji pakietów podstawowych oraz narzędzi dodatkowych: `docker`, `wget`, `git`, `curl` i `systemd-container`.
* **Sekcja %post:** Skrypt poinstalacyjny aktywujący demona Docker, tworzący usługę systemd (`init-app.service`) i uruchamiający kontener Nginx przy pierwszym starcie.

### Przebieg Wdrożenia i Napotkane Problemy

* **Krok 1:** Uruchomienie lokalnego serwera HTTP Python w VS Code na porcie `8000`.
* **Krok 2:** Dopisywanie parametru lokalizacji pliku `inst.ks=http://<IP_HOSTA>:8000/ks.cfg` w menu GRUB instalatora.
* **Krok 3 (Problem):** Próba instalacji rozwojowej wersji *Fedora 44* wywołała błąd usługi `systemd-logind.service` i wejście w Emergency Mode.
* **Krok 4 (Rozwiązanie):** Downgrade obrazu ISO do stabilnej wersji *Fedora 40 Server* skutkujący pomyślnym, bezobsługowym wdrożeniem kontenera.

---

## 2. Automatyzacja i Zdalne Zarządzanie Konfiguracją: System Ansible

### Konfiguracja i Wymiana Kluczy

* **Przygotowanie maszyn:** Konfiguracja węzła sterującego (Orchestrator) oraz docelowego (`ansible-target`).
* **Uwierzytelnianie:** Wymiana kluczy publicznych SSH w celu bezhasłowego logowania na konto użytkownika `ansible`.

### Inwentaryzacja (`inventory.ini`)

* **Struktura:** Podział logiczny w pliku inwentaryzacji na sekcje `[Orchestrators]` oraz `[Endpoints]`.
* **Weryfikacja:** Mapowanie nazw w `/etc/hosts` i `systemd-resolved`, zweryfikowane modułem ad-hoc: `ansible Endpoints -i inventory.ini -m ping`.

### Tworzenie Ról i Wykonanie Playbooka

* **Szkieletowanie:** Inicjalizacja struktury ról poleceniem `ansible-galaxy role init deployment_role`.
* **Moduły:** Zastosowanie modułów YAML takich jak `ping`, `copy`, `package`, `service` oraz `reboot`.
* **Obsługa błędów:** Celowe wyłączenie usługi SSH na maszynie docelowej wykazało poprawną odporność Ansible na awarię połączenia (zgłoszenie statusu *Unreachable* i przerwanie wykonywania dalszych zadań).

---

## 3. Lokalna Orkiestracja Kontenerów: Kubernetes (K8s)

### Zarządzanie Środowiskiem Minikube

* **Zasoby:** Uruchomienie lokalnego klastra poleceniem `minikube start` z alokacją 3000 MB RAM i 3 rdzeni CPU.
* **Narzędzia:** Monitorowanie zasobów za pomocą panelu graficznego `minikube dashboard`.

### Problem Synchronizacji Rejestru (`ErrImageNeverPull`)

* **Problem:** Brak widoczności lokalnego obrazu aplikacji .NET 9.0 (gra Yahtzee) przez klaster Minikube skutkujący błędem pobierania obrazu.
* **Rozwiązanie:** Przełączenie kontekstu demona Docker za pomocą polecenia `eval $(minikube docker-env)` lub załadowanie obrazu przez `minikube image load`.

### Deklaratywne Zarządzanie i Strategie Wdrożeń (`deployment.yaml`)

* **Wersjonowanie:** Przetestowanie trzech wersji obrazu aplikacji (`v1` - bazowa, `v2` - zaktualizowana, `bad` - uszkodzona instrukcja CMD wywołująca błąd *CrashLoopBackOff*).
* **Skalowanie:** Dynamiczna zmiana liczby replik w zakresie od 0 do 8 oraz kontrola stanu poprzez `kubectl rollout status`.
* **Strategia Recreate:** Jednoczesne usuwanie starych podów przed utworzeniem nowych; skutkuje mierzalnym przestojem (downtime).
* **Strategia Rolling Update:** Stopniowa, falowa podmiana kontenerów na podstawie parametrów `maxUnavailable: 2` i `maxSurge: 25%`; zapewnia ciągłość działania aplikacji (*Zero-Downtime*).
* **Strategia Canary Deployment:** Równoległe uruchomienie wdrożenia produkcyjnego i testowego (canary) pod wspólną etykietą logiczną `app: yahtzee` w celu przekierowania części ruchu sieciowego przez Service.
* **Wycofywanie zmian:** Awaryjne przywrócenie stabilnej wersji po błędzie obrazu `bad` za pomocą instrukcji: `kubectl rollout undo deployment/yahtzee-production --to-revision=2`.

---

## 4. Wdrażanie w Chmurze Publicznej: Azure Container Instances (ACI)

### Budowa i Wypchnięcie Obrazu do Docker Hub

* **Przygotowanie:** Budowa dedykowanego obrazu Nginx zawierającego stronę z numerem indeksu (`WP416619`).
* **Publikacja:** Wypchnięcie gotowego artefaktu do publicznego rejestru komendą `docker push mekoishere/azure-app:v1`.

### Konfiguracja i Wdrożenie z Poziomu Azure Cloud Shell

* **Krok 1:** Utworzenie nowej grupy zasobów poleceniem `az group create --name rg-lab12-wilhelm --location polandcentral`.
* **Krok 2:** Rejestracja wymaganego dostawcy zasobów komendą `az provider register --namespace Microsoft.ContainerInstance`.
* **Krok 3:** Uruchomienie bezserwerowego kontenera za pomocą polecenia `az container create` z przypisaniem parametrów sprzętowych, publicznego adresu IP oraz unikalnej etykiety DNS.

### Analiza Ruchu Sieciowego i Logów (Cyberbezpieczeństwo)

* **Logi serwera:** Odczyt logów poprzez `az container logs` potwierdzający start aplikacji na porcie 80.
* **Aktywność botów:** Natychmiastowe zarejestrowanie masowych błędów `404 Not Found` dla ścieżek podatności (np. `/.env`, `/.git/HEAD`, `/wp-config.php`), wywołanych przez automatyczne boty skanujące przestrzeń IP chmury.
* **Błąd 400:** Wykrycie błędów zapytania spowodowanych przez próby wymuszenia szyfrowania HTTPS na porcie HTTP.
* **Czyszczenie środowiska:** Usunięcie całej grupy zasobów poleceniem `az group delete` w celu zatrzymania naliczania kosztów w subskrypcji studenckiej.

---

## Wnioski Ogólne

* **Redukcja błędu ludzkiego:** Automatyzacja za pomocą Kickstart i Ansible umożliwia powtarzalne i szybkie odtwarzanie środowisk serwerowych od zera.
* **Ciągłość działania systemów:** Deklaratywne pliki manifestów YAML w Kubernetes zapewniają automatyczne samonaprawianie (*self-healing*) oraz bezprzerwowe aktualizacje infrastruktury (*Rolling Update*).
* **Efektywność i bezpieczeństwo chmury:** Model Serverless w postaci Azure Container Instances przyspiesza publikację oprogramowania, jednak publiczne wystawienie usługi wymaga natychmiastowego zabezpieczenia brzegu sieci oraz restrykcyjnej kontroli kosztów alokacji zasobów.