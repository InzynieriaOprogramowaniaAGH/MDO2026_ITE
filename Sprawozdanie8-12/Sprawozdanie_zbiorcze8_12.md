# Raport Techniczny: Automatyzacja Infrastruktury, Orkiestracja i Wdrażanie w Chmurze
**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE | **Grupa:** G6

## Charakterystyka Architektury
Dokument przedstawia analizę i implementację rozproszonego środowiska aplikacyjnego typu Cloud-Native, zrealizowanego z wykorzystaniem paradygmatów **Infrastructure as Code (IaC)**, **Niezmienności Infrastruktury (Immutable Infrastructure)** oraz **Declarative Configuration**. Zastosowany stos technologiczny obejmuje zautomatyzowane środowiska wirtualne (Hyper-V, Kickstart), bezagentowe narzędzia do zarządzania konfiguracją (Ansible), platformę orkiestracji (Kubernetes) oraz usługi chmurowe w modelu Serverless (Azure Container Instances). Celem wdrożenia było wyeliminowanie manualnych interwencji operatora na każdym etapie cyklu życia oprogramowania.

## 1. Zarządzanie Infrastrukturą jako Kodem (IaC) i Konfiguracja (Ansible)
Architektura zakłada pełną automatyzację powoływania węzłów obliczeniowych (Control Node oraz Endpoints) oraz ich bezobsługową konfigurację poinstalacyjną, redukując do zera zjawisko dryfu konfiguracji (Configuration Drift).

### 1.1 Nienadzorowany Bootstrapping Systemów
Powoływanie węzłów zrealizowano poprzez skrypty automatyzujące komunikację z hipernadzorcą oraz mechanizmy instalacji nienadzorowanej (Unattended Installation).
* **Infrastruktura sprzętowa (Hyper-V):** Konfiguracja maszyn wirtualnych 2. generacji została zdefiniowana jako kod za pomocą skryptów PowerShell (`Automatyzacja_VM.ps1`). Skrypt w sposób deklaratywny alokuje zasoby (RAM, vCPU), mapuje wirtualne przełączniki sieciowe (Default Switch) oraz montuje nośniki instalacyjne ISO, standaryzując środowisko uruchomieniowe.
* **Automatyzacja instalacji OS (Kickstart):** Zamiast manualnego przechodzenia przez kreator Anaconda, wykorzystano pliki odpowiedzi Kickstart (`fedora_ks.cfg`). Plik ten, udostępniany w sieci wewnętrznej przez dedykowany serwer HTTP, wstrzykiwał konfigurację partycjonowania, sieci i kont użytkowników bezpośrednio do parametrów jądra (GRUB). Skonfigurowana sekcja `%post` zrealizowała koncepcję *Zero-Touch Provisioning*, automatycznie instalując środowisko Docker i uruchamiając skonteneryzowaną aplikację bezpośrednio po restarcie gotowego systemu.

### 1.2 Silnik Zarządzania Konfiguracją
Scentralizowane zarządzanie stanem węzłów (Configuration Management) oparto na architekturze bezagentowej narzędzia Ansible, wykorzystującej autoryzację asymetryczną (PKI / klucze RSA SSH) oraz protokół WinRM/SSH do komunikacji.
* **Idempotentność potoków:** Zaimplementowane Playbooki gwarantują zachowanie pożądanego stanu docelowego. Mechanizmy wbudowane w moduły Ansible przed wykonaniem akcji weryfikują obecny stan systemu (np. sumy kontrolne plików, statusy usług `systemd`). Jeśli stan faktyczny zgadza się z deklarowanym, zadanie zwraca status `ok` (brak zmian), co chroni przed destrukcyjnym nadpisywaniem konfiguracji.
* **Obsługa wyjątków i niezawodność:** Zastosowano mechanizmy łagodzenia błędów (`ignore_errors`) dla specyficznych usług, które nie występują w minimalistycznych obrazach systemów (np. demon `rngd`). Przeprowadzono również testy *Chaos Engineering* polegające na symulacji nagłej utraty łączności (wyłączenie gniazd i usług systemd dla demona SSH na maszynie docelowej), co potwierdziło prawidłową detekcję stanu `UNREACHABLE` przez węzeł sterujący.
* **Modularyzacja wdrożeń (Ansible Galaxy):** Złożona logika wdrożeniowa została odseparowana i ustrukturyzowana za pomocą ról. Zamiast monolitycznego Playbooka, utworzono strukturę katalogową obejmującą pliki `tasks/main.yml`, `meta/main.yml` i `vars`. Zadania roli obejmowały: podniesienie uprawnień (`become: yes`), instalację silnika Docker, transfer binariów JAR do katalogu `/tmp`, konfigurację mapowania portów oraz wykonanie automatycznych testów walidacyjnych API za pomocą modułu `uri`.

## 2. Orkiestracja Środowisk Kontenerowych (Kubernetes)
Wyizolowane, pojedyncze kontenery zastąpiono zarządzalnym klastrem Kubernetes (lokalna implementacja `minikube`), który przejął całkowitą odpowiedzialność za wysoką dostępność, autoleczenie (Self-healing) i balansowanie ruchu sieciowego aplikacji.

### 2.1 Architektura Wdrożeń Deklaratywnych
Zarządzanie cyklem życia aplikacji przeniesiono na poziom obiektów klastra, definiowanych za pomocą manifestów YAML, zrywając z imperatywnym zarządzaniem (np. `docker run`).
* **Obiekty Deployment i ReplicaSet:** Stan pożądany aplikacji został określony deklaratywnie w obiekcie `Deployment`. Definiuje on nie tylko obraz kontenera, ale także rygorystycznie utrzymywaną liczbę replik (skalowanie horyzontalne). Kontroler klastra w tle zarządza obiektem `ReplicaSet`, który nieustannie monitoruje pody – w przypadku awarii jednego z nich, natychmiast powołuje nowy, aby utrzymać zadeklarowany stan.
* **Load Balancing Wewnętrzny (Service):** Efemeryczne pody (posiadające zmienne adresy IP) wyeksponowano na poziomie klastra poprzez obiekt typu `Service` z typem `ClusterIP`. Zapewnia on stały adres wirtualny (Virtual IP) oraz wykorzystuje `kube-proxy` do rozdzielania przychodzącego ruchu sieciowego (Round-Robin) pomiędzy aktywne repliki. Do lokalnego diagnozowania trasowania wykorzystano mechanizm tunelowania `port-forward`.

### 2.2 Strategie Aktualizacji i Zarządzanie Awariami
* **Rolling Updates & Rollbacks:** Kubernetes domyślnie wykorzystuje strategię łagodnego wdrażania (*Rolling Update*). Zbadano mechanizmy ochrony klastra przed błędną konfiguracją – po zaaplikowaniu manifestu z nieistniejącym tagiem obrazu, proces pobierania zakończył się błędem `ErrImagePull` (oraz statusem `ImagePullBackOff`). Klaster inteligentnie wstrzymał terminację starych, stabilnych replik, chroniąc system przed całkowitą awarią (Downtime). Wdrożenie naprawiono komendą wycofania rewizji (`kubectl rollout undo`), co udowadnia pełną audytowalność i niezawodność procesu wydawniczego.
* **Architektura Canary Deployment:** Zaimplementowano zaawansowaną strategię dystrybucji ruchu. Wdrożono odizolowany, pojedynczy pod testowy z nową rewizją aplikacji (`v2`), który na poziomie etykiet (Label Selectors) został przypięty do tego samego obiektu `Service`, co 4 pody stabilne. Architektura ta umożliwia bezpieczne, asynchroniczne testy produkcyjne A/B, kierując dokładnie 20% ruchu na nową, eksperymentalną wersję.

## 3. Wdrażanie Zwinne w Chmurze Publicznej (Microsoft Azure)
Ekspozycja produkcyjna zoptymalizowanego obrazu aplikacji została zrealizowana w chmurze Microsoft Azure, całkowicie eliminując warstwę zarządzania sprzętem i hypervisorem na rzecz natywnego modelu Serverless.

### 3.1 Azure Container Instances (ACI) i Optymalizacja FinOps
Wdrożenie zrealizowano z wykorzystaniem środowiska powłoki Azure Cloud Shell. Jako mechanizm uruchomieniowy wybrano usługę ACI, cechującą się minimalnym narzutem konfiguracyjnym, brakiem konieczności utrzymywania wirtualnych maszyn węzłów (jak w przypadku AKS) i natychmiastową alokacją publicznych adresów IP (FQDN).
* **Izolacja zasobów i mitygacja limitów subskrypcji:** Architektura poleceń wdrożeniowych (`az container create`) została rygorystycznie dostosowana do polityk zarządzania kosztami dla subskrypcji edukacyjnych. Zaimplementowano mikrozbywalne limity przydziału zasobów obliczeniowych (1 vCPU, 1.5 GB RAM) oraz jawnie wymuszono docelowy region operacyjny (`swedencentral`) oznaczony jako zwolniony z blokad polis (mitygacja błędów `RequestDisallowedByAzure`).
* **Telemetria i cykl życia w chmurze:** Walidacja uruchomieniowa objęła weryfikację logów systemowych standardowego wyjścia (stdout) bezpośrednio z warstwy abstrakcji chmury (`az container logs`). 
* **Zarządzanie Kosztami (Cost Management):** W ramach wymuszania czystości środowiska zaprojektowano asynchroniczne niszczenie całej zdefiniowanej topologii chmurowej poprzez operację usunięcia nadrzędnej grupy zasobów (`az group delete`). Takie podejście chroni budżet przed powstawaniem tzw. zasobów osieroconych (Orphaned Resources).

## 4. Wykaz Konfiguracji Zabezpieczeń i Komend Krytycznych

### Automatyzacja (IaC) i Bootstrapping
```powershell
# Wykonanie skryptu IaC w środowisku z podwyższonymi restrykcjami wykonywania skryptów
Set-ExecutionPolicy Bypass -Scope Process; .\Automatyzacja_VM.ps1

# Inicjalizacja serwera HTTP dystrybuującego plik Kickstart (ks.cfg) dla instalatora Anaconda
python3 -m http.server 8082

### Konfiguracja i Ansible
# Weryfikacja łączności (Sanity check) na węzłach z inwentarza bez modyfikacji ich stanu
ansible all -m ping -i inventory.ini

# Wykonanie wdrożenia z wymuszeniem podniesienia uprawnień (sudo) na węźle docelowym
ansible-playbook deploy.yml --become

### Orkiestracja w Klastrze Kubernetes
# Deklaratywne zaaplikowanie stanu do klastra (Deployment, Service, Ingress)
kubectl apply -f deployment.yml

# Weryfikacja zakończenia sukcesem wdrożenia deklaratywnego (Timeout 60s)
kubectl rollout status deployment/spring-api --timeout=60s

# Wycofanie uszkodzonego stanu (Rollback) do ostatniej zdrowej rewizji w historii
kubectl rollout undo deployment/spring-api

# Zestawienie bezpiecznego tunelu pomiędzy portem localhost a usługą wewnątrz klastra
kubectl port-forward service/spring-service 8082:80

### Administracja Chmurą (Azure CLI)
# Tworzenie logicznego kontenera na zasoby (Grupa Zasobów)
az group create --name DevOps-Zadanie12 --location swedencentral

# Serverless deployment: alokacja RAM, vCPU i mapowanie publicznych endpointów
az container create \
  --resource-group DevOps-Zadanie12 \
  --name spring-api-chmura \
  --image 64pseaqeze/spring-api-prod:v2 \
  --ip-address public --ports 8080 \
  --location swedencentral \
  --os-type Linux --cpu 1 --memory 1.5

# Kaskadowe i całkowite czyszczenie zasobów cloudowych z pominięciem promptów
az group delete --name DevOps-Zadanie12 --yes --no-wait