# Sprawozdanie zbiorcze 8–12 (Ansible + Kubernetes + Azure)

Wspólny wątek ćwiczeń 8–12: od zdalnej automatyzacji wdrożeń (Ansible), przez instalację niezmiennej infrastruktury (Kickstart), po orkiestrację kontenerów w klastrze (Kubernetes/minikube) i wdrożenie w chmurze (Azure Container Instances).

---

## Cel

Celem ćwiczeń 8–12 było:
- zautomatyzowanie zdalnego wdrażania i konfiguracji maszyn za pomocą **Ansible**,
- przygotowanie **niezmiennej instalacji** systemu Linux z kontenerem uruchamianym po pierwszym starcie (Kickstart),
- uruchomienie i konfiguracja klastra **Kubernetes** (minikube) oraz wdrażanie aplikacji kontenerowych,
- zarządzanie wdrożeniami (skalowanie, rollback, strategie) i weryfikacja rolloutu,
- publikacja obrazu na **Docker Hub** i wdrożenie kontenera w **Azure** bez tworzenia własnego rejestru w chmurze.

---

## Środowisko i narzędzia

- **Ansible**: inventory YAML, playbooki, role, ad-hoc `ping`, idempotencja.
- **VirtualBox**: dwie VM Ubuntu (dyrygent + endpoint), port forwarding SSH.
- **Fedora + Kickstart**: automatyczna instalacja systemu, `%post` z Dockerem i systemd unit.
- **minikube + kubectl**: klaster lokalny, driver Docker, alias `minikubectl`.
- **Docker**: własny obraz `gn-nginx` (nginx + `index.html`), wersje `1.0`, `2.0`, `broken`.
- **Kubernetes**: Pod, Deployment, Service, YAML, `rollout history/undo`, strategie wdrożeń.
- **Docker Hub**: `whatapity171/gn-nginx`.
- **Azure**: Cloud Shell, `az container create`, Azure Container Instances (ACI).

---

## Sprawozdanie 8 (20.05.2026) – Ansible: automatyzacja i zdalne wdrożenie

### Środowisko
- **`Ubuntu-Server`** – dyrygent (`Orchestrators`, `ansible_connection: local`),
- **`ansible-target`** – endpoint (`Endpoints`, user `ansible`, minimalna instalacja),
- łączność przez port forwarding VirtualBox: `2222` / `2223` na `10.0.2.2`,
- bezhasłowe SSH (`ssh-copy-id`), alias w `~/.ssh/config`.

### Inventory
Plik `Sprawozdanie8/inventory.yml` z grupami `Orchestrators` i `Endpoints`.

### Playbooki (`playbooks/`)
| Plik | Cel |
|------|-----|
| `01-ping.yml` | ping wszystkich hostów |
| `02-copy-inventory.yml` | kopiowanie inventory na endpoint (idempotencja) |
| `03-update-restart.yml` | `apt upgrade` + restart `sshd` / `rngd` |
| `04-unreachable.yml` | zachowanie przy niedostępnym hoście (`UNREACHABLE`) |
| `05-deploy-container.yml` | wdrożenie artefaktu `.tar` z zajęć 07 |
| `06-role-deploy.yml` | to samo przez rolę `axios_deploy` |

### Wdrożenie artefaktu kontenerowego
Artefakt z pipeline’u (zajęcia 07): `axios-deploy-image.tar` (`docker save`).

Playbook `05-deploy-container.yml`:
1. sanity check (ping + obecność `.tar` na dyrygencie),
2. instalacja `docker.io` Ansiblem,
3. `docker load` + uruchomienie kontenera,
4. smoke test (`test -d dist` → `SMOKE OK`),
5. sprzątanie pliku `.tar` na maszynie docelowej.

### Rola Ansible
Logika przeniesiona do roli `roles/axios_deploy/` (utworzonej przez `ansible-galaxy role init`), z `defaults/`, `tasks/`, `meta/main.yml`. Playbook `06-role-deploy.yml` wywołuje wyłącznie rolę.

### Efekt
Zrealizowano pełną ścieżkę: inventory → playbooki → deploy artefaktu → enkapsulacja w roli. Pokazano idempotencję Ansible oraz obsługę hostów niedostępnych bez wywracania całego playbooka.

Dowody: zrzuty w `Sprawozdanie8/` (m.in. `0-ansible-ready.png`, `14.png`–`18.png`).

---

## Sprawozdanie 9 – Kickstart: niezmienna instalacja z kontenerem

### Zakres prac
- Dwie maszyny wirtualne **Fedora**.
- Pierwsza maszyna: wygenerowanie i edycja pliku odpowiedzi Kickstart (`ks.cfg`).
- Tymczasowy serwer HTTP udostępniający `ks.cfg` drugiej maszynie.
- Druga maszyna: instalacja z parametrem boot `inst.ks=http://IP:8000/ks.cfg`.

### Zawartość `%post` w Kickstart
- włączenie `sshd`,
- instalacja **Docker CE** (repo docker.com),
- utworzenie unitu systemd `myapp.service` uruchamiającego kontener `nginx:latest` na porcie `8080:80`,
- `systemctl enable` dla `docker` i `myapp`.

### Efekt
Po automatycznej instalacji system startuje z włączonym Dockerem i kontenerem nginx — bez ręcznej konfiguracji po pierwszym bootcie. Weryfikacja: logi instalacji + działający obraz Dockera.

Dowody: zrzuty w `Sprawozdanie9/` (`1.png`–`3.png`).

---

## Sprawozdanie 10 (29.05.2026) – Kubernetes (1): minikube, pod, deployment, serwis

### Instalacja klastra
- `minikube start --driver=docker` (wymagane 2 CPU w ustawieniach VM),
- `minikube status`, `kubectl get nodes`, `kubectl get pods -A`,
- alias `minikubectl="minikube kubectl --"`,
- uruchomienie **Dashboard**.

### Własny obraz aplikacji
Obraz `gn-nginx:1.0` — `nginx:1.27-alpine` z własnym `index.html` (`GN421256 - Devops`).

```dockerfile
FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

Obraz załadowany do minikube (`minikube image load`).

### Uruchomienie w klastrze
- `minikube kubectl run` → pod `gn-nginx`,
- `port-forward pod/gn-nginx 8080:80` → dostęp HTTP lokalnie,
- ręczne napisanie `gn-nginx-deployment.yaml` (bo `kubectl run` tworzy tylko Pod, nie Deployment),
- przykładowy deployment nginx (`kubectl apply`),
- skalowanie do **4 replik**,
- utworzenie **Service** + `port-forward svc/...`.

### Efekt
Poznano podstawowe zasoby Kubernetes (Pod, Deployment, Service), deklaratywne wdrożenie przez YAML oraz dostęp do aplikacji przez port-forward.

Dowody: zrzuty w `Sprawozdanie10/` (`1.png`–`14.png`).

---

## Sprawozdanie 11 – Kubernetes (2): wersje obrazu, skalowanie, rollback, strategie

### Nowe wersje obrazu
| Tag | Opis |
|-----|------|
| `gn-nginx:1.0` | wersja bazowa |
| `gn-nginx:2.0` | zmieniona treść HTML (WERSJA 2.0) |
| `gn-nginx:broken` | celowy błąd (`exit 1`) → `CrashLoopBackOff` |

Obrazy załadowane do minikube (`minikube image load`).

### Skalowanie replik (edycja YAML + `apply`)
Sekwencja: **8 → 1 → 0 → 4** replik. Przy skalowaniu do 0 wykryto osierocony Pod z zajęć 10 (`kubectl run`) — usunięty `kubectl delete pod gn-nginx`.

### Zmiana wersji obrazu i rollback
- aktualizacja do `2.0`, powrót do `1.0`, wdrożenie `broken`,
- `kubectl rollout history`, `kubectl describe deployment`,
- `kubectl rollout undo` → przywrócenie działającej wersji.

### Skrypt weryfikujący (`verify-rollout.sh`)
Sprawdza `kubectl rollout status` z timeoutem 60 s. Poprawka: `KUBECTL` jako tablica bash (alias `minikubectl` nie działa w skryptach).

### Strategie wdrożeń
| Strategia | Plik | Zachowanie |
|-----------|------|------------|
| **Recreate** | `deployment-recreate.yaml` | wszystkie stare pody znikają naraz, potem nowe |
| **Rolling Update** | `deployment-rolling.yaml` | stopniowa wymiana (`maxUnavailable: 2`, `maxSurge: 50%`) |
| **Canary** | `deployment-canary-stable.yaml` + `deployment-canary-new.yaml` + `service-canary.yaml` | 3× stable (v1) + 1× canary (v2), wspólny serwis |

Obserwacja: `port-forward svc/...` przypina się do jednego poda — podział ruchu canary widoczny dopiero przy curl do ClusterIP z wnętrza klastra.

Dowody: zrzuty w `Sprawozdanie11/` (`1'.png`–`25-curltest.png`).

---

## Sprawozdanie 12 – Azure Container Instances + Docker Hub

### Przygotowanie obrazu
- lokalny test `gn-nginx:2.0` (kontener działa, serwuje HTTP),
- publikacja na Docker Hub: `whatapity171/gn-nginx` (tagi `1.0`, `2.0`),
- push z pełną ścieżką `docker.io/<user>/gn-nginx:<tag>`.

### Wdrożenie w Azure
- **Cloud Shell** (Bash) w regionie **Germany West Central** (*West Europe* zablokowane polityką subskrypcji studenckiej — `RequestDisallowedByAzure`),
- `az group create --name rg-mdo12-gn421256 --location germanywestcentral`,
- `az container create` z obrazu Docker Hub:
  - `--os-type Linux`,
  - `--cpu 1 --memory 1`,
  - `--dns-name-label gn421256-nginx`,
  - `--ports 80 --ip-address public`.

### Weryfikacja
- `az container show` → stan **Running**, publiczny FQDN,
- `az container logs` → logi nginx,
- `curl http://<fqdn>` → HTML v2.0.

### Sprzątanie
```bash
az container delete --resource-group rg-mdo12-gn421256 --name gn-nginx-aci --yes
az group delete --name rg-mdo12-gn421256 --yes --no-wait
```

Dowody: zrzuty w `Sprawozdanie12/` (`1-docker-local.png`–`6-curl-azure.png`).

---

## Podsumowanie zmian 8 → 9 → 10 → 11 → 12

| Ćwiczenie | Temat | Kluczowy efekt |
|-----------|-------|----------------|
| **8** | Ansible | Zdalna automatyzacja, deploy artefaktu `.tar`, enkapsulacja w roli |
| **9** | Kickstart | Niezmienna instalacja Fedory z Dockerem i kontenerem po pierwszym bootcie |
| **10** | Kubernetes (1) | minikube, Pod/Deployment/Service, własny obraz `gn-nginx` |
| **11** | Kubernetes (2) | Skalowanie, rollback, strategie (Recreate/Rolling/Canary), skrypt weryfikacji |
| **12** | Azure ACI | Docker Hub → publiczny kontener w chmurze, sprzątanie resource group |

---

## Wnioski końcowe

- **Ansible** upraszcza powtarzalne wdrożenia na wielu maszynach; inventory, playbooki i role pozwalają oddzielić logikę od konfiguracji hostów. Idempotencja i obsługa `UNREACHABLE` są kluczowe w środowisku produkcyjnym.
- **Kickstart** umożliwia w pełni zautomatyzowaną instalację systemu z prekonfigurowanymi usługami (Docker, systemd unit) — przydatne przy skalowaniu floty maszyn.
- **Kubernetes** przenosi zarządzanie kontenerami na poziom deklaratywny (YAML); Deployment zapewnia samonaprawę i skalowanie, Service — stabilny dostęp do podów.
- **Strategie wdrożeń** różnią się dostępnością podczas aktualizacji: Recreate (przerwa), Rolling Update (stopniowo), Canary (kontrolowane ryzyko na części ruchu).
- **Chmura (Azure ACI)** pozwala uruchomić kontener z publicznego rejestru (Docker Hub) bez budowy własnej infrastruktury klastrowej — wymaga jednak świadomego zarządzania kosztami (usuwanie resource group po ćwiczeniach) i uwzględnienia ograniczeń subskrypcji studenckiej (regiony, wymagane parametry CPU/RAM).
