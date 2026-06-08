# Sprawozdanie zbiorcze — Laboratoria 8–12
## DevOps: Automatyzacja, Kubernetes, Chmura

---

## Spis laboratoriów

| Nr | Temat |
|----|-------|
| Lab 8 | Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible |
| Lab 10 | Wdrażanie na zarządzalne kontenery: Kubernetes (1) | 
| Lab 11 | Wdrażanie na zarządzalne kontenery: Kubernetes (2) | 
| Lab 12 | Wdrażanie na zarządzalne kontenery w chmurze (Azure) |

---

## Lab 8 — Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

### Cel laboratorium

Zapoznanie się z narzędziem Ansible do automatyzacji zarządzania konfiguracją i zdalnego wykonywania zadań na wielu maszynach jednocześnie, bez konieczności instalowania agentów.

### Środowisko

| Rola | Hostname | Użytkownik | Adres IP |
|------|----------|------------|----------|
| Orchestrator | `ansible-main` | `szymon` | `192.168.56.100` |
| Endpoint | `ansible-target` | `tar` | `192.168.56.101` |

Obie maszyny działały w środowisku VirtualBox na systemie Ubuntu.

### Wykonane zadania

**Konfiguracja SSH:**
Wygenerowano parę kluczy ed25519 na maszynie głównej i skopiowano klucz publiczny na maszynę docelową poleceniem `ssh-copy-id`. Połączenie SSH bez hasła zostało zweryfikowane pomyślnie.

**Inwentaryzacja:**
Utworzono plik `inventory.ini` definiujący dwie grupy — `Orchestrators` (połączenie lokalne) oraz `Endpoints` (maszyna docelowa). Weryfikacja łączności przez `ansible all -m ping` zwróciła `SUCCESS` dla obu maszyn.

**Playbook — zrealizowane zadania:**
- Ping wszystkich maszyn (`ansible.builtin.ping`)
- Kopiowanie pliku inwentaryzacji na Endpoints (`ansible.builtin.copy`) — zademonstrowano idempotentność
- Aktualizacja pakietów systemowych (`ansible.builtin.apt` z `become: true`)

### Napotkane problemy i rozwiązania

| Problem | Rozwiązanie |
|---------|------------|
| `Permission denied` przy `ssh-copy-id` | Poprawienie nazwy użytkownika (`tar` zamiast `szymon`) |
| SSH pyta o hasło mimo wymiany kluczy | Ustawienie `chmod 700 ~/.ssh` i `chmod 600 ~/.ssh/authorized_keys` |
| `Missing sudo password` przy `become: true` | Dodanie flagi `-K` do `ansible-playbook` |
| `Failed to lock apt` | Dodanie parametru `lock_timeout: 60` do modułu apt |
| Maszyna docelowa niedostępna po nazwie | Dodanie wpisu `192.168.56.101 ansible-target` do `/etc/hosts` |

### Wnioski

Ansible umożliwia zdalne zarządzanie wieloma maszynami bez agentów, korzystając wyłącznie z SSH. Kluczową cechą jest idempotentność — wielokrotne wykonanie tego samego playbooka jest bezpieczne. Prawidłowa konfiguracja SSH jest warunkiem koniecznym działania całego systemu.

---

## Lab 10 — Wdrażanie na zarządzalne kontenery: Kubernetes (1)

### Cel laboratorium

Instalacja i konfiguracja lokalnego klastra Kubernetes przy użyciu Minikube, uruchomienie aplikacji jako Pod i Deployment, ekspozycja serwisu HTTP.

### Środowisko

- Serwer Ubuntu z 1.9 GB RAM i 2 CPU
- Minikube v1.38.1 ze sterownikiem Docker
- kubectl v1.36.1
- Obraz aplikacji: `nginx`

### Wykonane zadania

**Instalacja klastra:**
Kubectl i minikube pobrano z oficjalnych źródeł (dl.k8s.io, storage.googleapis.com). Ze względu na ograniczenia sprzętowe klaster uruchomiono z flagami `--memory=1800 --force`. Klaster osiągnął stan `Ready`.

**Mitigacja ograniczeń sprzętowych:**

| Problem | Rozwiązanie |
|---------|------------|
| Za mało RAM (1.9 GB) | Flagi `--force --memory=1800` |
| Za mało miejsca na dysku | Rozszerzenie VDI z 36 GB do 80 GB, rozszerzenie LVM (`growpart`, `lvextend`, `resize2fs`) |
| Niestabilność przy Jenkins | Użycie lekkiego obrazu nginx (~50 MB vs 746 MB) |

**Uruchomienie poda:**
```bash
minikube kubectl -- run nginx --image=nginx --port=80 --labels app=nginx
```
Pod osiągnął stan `Running`. Dostęp przez `kubectl port-forward` na porcie 8090.

**Deployment YAML (4 repliki):**
Wszystkie 4 repliki nginx uruchomiły się poprawnie. Serwis ClusterIP wyeksponowano przez `port-forward` — aplikacja dostępna pod `http://127.0.0.1:8090`.

### Porównanie: Pod vs Deployment

| Cecha | Pod | Deployment |
|-------|-----|-----------|
| Liczba replik | 1 | Konfigurowalna |
| Odporność na awarie | Brak | ReplicaSet pilnuje replik |
| Aktualizacje | Brak | Rolling update wbudowany |
| Użycie | Dev/test | Produkcja |

### Wnioski

Kubernetes automatyzuje zarządzanie cyklem życia kontenerów. Podejście deklaratywne (YAML) jest bardziej powtarzalne niż manualne komendy. Ograniczenia sprzętowe są realną przeszkodą wymagającą świadomej mitigacji.

---

## Lab 11 — Wdrażanie na zarządzalne kontenery: Kubernetes (2)

### Cel laboratorium

Zaawansowane zarządzanie deploymentami: skalowanie, rollbacki, strategie wdrożeń (Recreate, Rolling Update, Canary).

### Przygotowane obrazy Docker

| Obraz | Tag | Opis |
|-------|-----|------|
| `szyszon26/myapp` | `v1` | httpd 2.4-alpine, niebieski UI |
| `szyszon26/myapp` | `v2` | httpd 2.4-alpine, zielony UI |
| `szyszon26/myapp` | `broken` | Kontener kończy się błędem `exit 1` — symuluje CrashLoopBackOff |

### Skalowanie Deploymentu

Operacje skalowania wykonywano dwoma sposobami: edycją pola `replicas` w YAML lub poleceniem `kubectl scale`:

| Operacja | Repliki |
|----------|---------|
| Zwiększenie | 8 |
| Zmniejszenie | 1 |
| Zatrzymanie | 0 |
| Ponowne uruchomienie | 4 |

Przy `replicas: 0` żaden pod nie działał — Deployment istniał, ale aplikacja była niedostępna.

### Aktualizacje obrazów i rollback

```bash
kubectl set image deployment/myapp myapp=szyszon26/myapp:v2    # aktualizacja
kubectl set image deployment/myapp myapp=szyszon26/myapp:broken # wadliwy
kubectl rollout undo deployment/myapp                           # cofnięcie
kubectl rollout history deployment/myapp                        # historia
```

Wadliwy obraz powodował `CrashLoopBackOff` — Kubernetes wykrywał błąd i próbował restartować pody z wykładniczo rosnącym opóźnieniem.

### Strategie wdrożeń

**Recreate** — wszystkie stare pody usuwane jednocześnie przed uruchomieniem nowych. Krótka przerwa w działaniu. Użycie: migracje baz danych, niekompatybilne zmiany API.

**Rolling Update** (`maxUnavailable: 2`, `maxSurge: 2`) — stare pody zastępowane stopniowo, bez przestoju. Użycie: standardowe aktualizacje aplikacji bezstanowych.

**Canary** — dwa osobne Deploymenty z tym samym selektorem, obsługiwane przez jeden Service:
- `myapp-stable`: 4 repliki (v1) — ~80% ruchu
- `myapp-canary`: 1 replika (v2) — ~20% ruchu

### Skrypt weryfikujący wdrożenie (60 sekund)

```bash
#!/bin/bash
if kubectl rollout status deployment/$1 --timeout=60s; then
    echo "OK: Wdrożenie zakończone pomyślnie."; exit 0
else
    echo "BŁĄD: Przekroczono timeout."; exit 1
fi
```

Skrypt zintegrowano z pipeline Jenkins jako krok `Verify Rollout`.

### Wnioski

Strategie wdrożeń pozwalają kontrolować ryzyko aktualizacji. Canary umożliwia testowanie nowej wersji na małym procencie ruchu. Rollback przez `kubectl rollout undo` jest szybki i niezawodny.

---

## Lab 12 — Wdrażanie na zarządzalne kontenery w chmurze (Azure)

### Cel laboratorium

Wdrożenie własnego kontenera Docker z Docker Hub na platformę Azure Container Instances (ACI), weryfikacja działania serwisu HTTP, pobranie logów i usunięcie zasobów.

### Środowisko

- Platforma: Microsoft Azure for Students (konto AGH)
- Usługa: Azure Container Instances
- Rejestr: Docker Hub (`szyszon26/myapp`)
- Region: `francecentral`
- Narzędzie: Azure Cloud Shell (Bash)

### Wykonane kroki

**1. Przygotowanie obrazu:**
```bash
docker login
docker tag myapp:v1 szyszon26/myapp:v1
docker push szyszon26/myapp:v1
```

**2. Rejestracja providera ACI:**
```bash
az provider register --namespace Microsoft.ContainerInstance
```
Konieczna przed pierwszym użyciem — domyślnie `NotRegistered` na koncie studenckim.

**3. Utworzenie Resource Group:**
```bash
az group create --name myResourceGroup --location francecentral
```

**4. Wdrożenie kontenera:**
```bash
az container create \
  --resource-group myResourceGroup \
  --name mycontainer \
  --image szyszon26/myapp:v1 \
  --dns-name-label szyszon26-agh \
  --ports 80 \
  --ip-address public \
  --os-type Linux \
  --cpu 1 --memory 1.5 \
  --location francecentral
```

**5. Weryfikacja:**

| Status | FQDN | IP |
|--------|------|----|
| Running | szyszon26-agh.francecentral.azurecontainer.io | 4.176.23.16 |

Logi Apache potwierdziły działanie serwera. Odpowiedź HTTP zwróciła stronę "Wersja 1.0".

**6. Sprzątanie:**
```bash
az container delete --resource-group myResourceGroup --name mycontainer --yes
az group delete --name myResourceGroup --yes
```

### Napotkane problemy

| Problem | Rozwiązanie |
|---------|------------|
| `RequestDisallowedByAzure` dla wielu regionów | Region `francecentral` okazał się działający dla konta AGH |
| `Microsoft.ContainerInstance` NotRegistered | `az provider register --namespace Microsoft.ContainerInstance` |
| `RegistryErrorResponse` (Docker Hub) | Powtórzenie komendy — chwilowy błąd po stronie Docker Hub |
| Brak publicznego FQDN | Dodanie flagi `--ip-address public` |

### Wnioski

Azure Container Instances umożliwia szybkie wdrożenie kontenera z Docker Hub bez zarządzania infrastrukturą. Konta studenckie AGH mają ograniczenia regionalne — konieczne jest przetestowanie kilku regionów. Usunięcie resource group po zakończeniu pracy jest kluczowe dla uniknięcia naliczania kosztów.

---

## Podsumowanie całości

Laboratoria 8–12 tworzyły spójną ścieżkę nauki DevOps — od automatyzacji konfiguracji, przez lokalne zarządzanie kontenerami, po wdrożenie w chmurze.

| Lab | Technologia | Kluczowe pojęcie |
|-----|-------------|-----------------|
| 8 | Ansible | Automatyzacja bez agentów, idempotentność |
| 10 | Kubernetes (minikube) | Pod, Deployment, Service |
| 11 | Kubernetes (minikube) | Skalowanie, rollback, strategie wdrożeń |
| 12 | Azure ACI | Kontener w chmurze, zarządzanie zasobami |

Każde laboratorium budowało na poprzednim — obrazy Docker przygotowane w lab 11 zostały bezpośrednio użyte w lab 12. Narzędzia różnią się poziomem abstrakcji: Ansible zarządza maszynami, Kubernetes zarządza kontenerami, Azure ACI zarządza infrastrukturą chmurową.
