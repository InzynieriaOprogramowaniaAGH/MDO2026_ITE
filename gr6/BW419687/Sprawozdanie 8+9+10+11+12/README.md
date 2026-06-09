# Sprawozdanie zbiorcze z laboratoriów nr 8-12
## Laboratorium nr.8 - Automatyzacja konfiguracji z Ansible

Celem laboratorium było poznanie narzędzia Ansible do zarządzania konfiguracją oraz automatyzacji wdrażania aplikacji w środowisku rozproszonym.
Wprowadzono nowe pojęcia:
- Ansible - narzędzie do automatyzacji IT (konfiguracja, orkiestracja, wdrażanie) działające bez agenta, wykorzystujące SSH.

- Orchestrator - maszyna (tu Ubuntu Server) zarządzająca zdalnymi hostami poprzez Ansible.

- Inventory - plik określający hosty zarządzane (np. adresy IP, grupy).

- Playbook - plik YAML z sekwencją zadań (tasks) do wykonania na zdalnych hostach.

- Rola (role) - strukturalny sposób organizacji playbooków (zmienne, zadania, szablony, pliki).

- Gathering Facts - zbieranie informacji o zdalnym hoście (system, sieć, pakiety) przed wykonaniem zadań.

- Moduły Ansible - ping, package, copy, docker_image, docker_container, docker_container_exec, assert, fail, debug.

Poruszone polecenia:
```bash
    ansible-playbook playbook1.yaml
```
- uruchomienie playbooka.
```bash
    ansible-galaxy init flac-deploy
```
- utworzenie szkieletu roli.

- W playbooku: użycie modułów do sprawdzenia dostępności, instalacji Dockera, kopii plików binarnego FLAC, uruchomienia kontenera, wykonania polecenia wewnątrz kontenera, weryfikacji wyniku i sprzątania.

## Laboratorium nr.9 - Automatyzacja instalacji systemu z Kickstartem

Celem laboratorium było wykonanie w pełni automatycznej instalacji systemu Fedora Server z dodatkowym oprogramowaniem (FLAC) przy użyciu pliku Kickstart.

Wprowadzono nowe pojęcia:

- Kickstart - metoda bezinterakcyjnej instalacji systemów Red Hat/Fedora, oparta na pliku konfiguracyjnym (anaconda-ks.cfg).

- mkksiso - narzędzie do wbudowania pliku kickstart w obraz ISO, tworząc obraz z automatyczną instalacją.

- %post - sekcja w pliku kickstart wykonująca polecenia po zakończeniu instalacji (tu: instalacja FLAC i test).

Poruszone polecenia:

```bash
    sudo mkksiso --ks new-ks.cfg /ścieżka/do/Fedora.iso auto.iso
```
- utworzenie ISO z automatycznym kickstartem.

- Modyfikacja pliku kickstart: dodanie repozytoriów, zmiana nazwy hosta, czyszczenie partycji, instalacja FLAC (w sekcji %post: dnf install -y flac i flac --version).

# Laboratorium nr.10 - Wprowadzenie do Kubernetes (Minikube)

Celem laboratorium było zainstalowanie lokalnego klastra Kubernetes (Minikube), zbudowanie własnego obrazu kontenera i uruchomienie pierwszego deploymentu.
Wprowadzono nowe pojęcia:

- Minikube - narzędzie do uruchamiania jedno-węzłowego klastra Kubernetes na maszynie lokalnej (do nauki i testów).

- kubectl - wiersz poleceń do zarządzania klastrem Kubernetes.

- Pod - najmniejsza jednostka w Kubernetes, grupująca jeden lub więcej kontenerów.

- Deployment - zasób deklarujący pożądaną liczbę replik podów i strategię aktualizacji.

- Service - udostępnia aplikację wewnątrz klastra lub na zewnątrz.

- Dashboard - interfejs webowy do monitorowania i zarządzania klastrem.

Poruszone polecenia:

```bash
    minikube start
```
- uruchomienie klastra.
```bash
    minikube dashboard
```
- otwarcie dashboardu.
```bash
    docker build -t my-nginx:custom . 
```
- budowa obrazu (wewnątrz środowiska Minikube).

```bash
    kubectl run ... - ręczne uruchomienie poda.
```
- kubectl port-forward pod/nazwa 8080:80 - przekierowanie portów do poda.
```bash
    kubectl apply -f deployment.yaml
```
- wdrożenie z pliku YAML (deployment).
```bash
    kubectl scale deployment my-nginx-deployment --replicas=4
```
- skalowanie liczby replik.

# Laboratorium nr.11 - Zarządzanie wdrożeniami w Kubernetes

Celem laboratorium było poznanie strategii aktualizacji wdrożeń (rolling, recreate, canary) oraz mechanizmów rollback i weryfikacji stanu rolloutów.

Wprowadzono nowe pojęcia:

- Strategia Rolling Update - stopniowa wymiana starych podów na nowe (domyślna w Kubernetes), brak przestoju.

- Strategia Recreate - usunięcie wszystkich starych podów przed utworzeniem nowych (występuje przestój).

- Strategia Canary - częściowe wdrożenie nowej wersji obok starej, z manualnym sterowaniem ruchem.

- Rollout history - historia zmian w deploymentach (rewizje).

- Rollback - przywrócenie poprzedniej rewizji.

Poruszone polecenia:

```bash
    kubectl rollout status deployment/nazwa --timeout=60s
```
- sprawdzenie postępu rollouta.

```bash
    kubectl rollout undo deployment/nazwa --to-revision=N
```
- powrót do danej rewizji.

```bash
    kubectl rollout history deployment/nazwa
```
- pokazuje historię.

```bash
    kubectl describe deployment/nazwa
```
- wyświetla szczegóły deploymentu.

```bash
    kubectl scale deployment/nazwa --replicas=0|1|4|8
```
- dynamiczne skalowanie.

# Laboratorium nr.12 - Wdrażanie w Azure Container Apps

Celem laboratorium było zapoznanie się z usługą Azure Container Apps - platformą serverless do uruchamiania kontenerów w chmurze Microsoft Azure.

Wprowadzono nowe pojęcia:

- Azure Container Apps - usługa PaaS do uruchamiania kontenerów bez zarządzania infrastrukturą (automatyczne skalowanie, ingress).

- Subskrypcja - pojedyncza umowa zapewniająca środki które pozwalają na korzystanie z zasobów Azure.

- Resource Group - zbiór na zasoby Azure (ułatwia zarządzanie i usuwanie).

- Ingress - reguły ruchu wejściowego do kontenera (tu: udostępnienie aplikacji publicznie).

- Log Stream - strumieniowe logi z działającego kontenera (bezpośrednio w portalu).

Poruszone akcje (głównie przez portal Azure):

- Utworzenie konta i aktywacja subskrypcji studenckiej.

- Użycie CloudShell (powłoka w chmurze).

- Stworzenie Resource Group.

- Wdrożenie kontenera nginx z włączonym publicznym ingress (automatyczny publiczny adres).

- Testowanie działającej aplikacji przez przeglądarkę.

- Podgląd logów w czasie rzeczywistym (Log Stream).

- Zatrzymanie kontenera.

- Usunięcie całej Resource Group (kasuje wszystkie powiązane zasoby).