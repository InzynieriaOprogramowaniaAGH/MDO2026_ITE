Zbiorcze sprawozdanie z ćwiczeń 8–12
===================================

Niniejszy dokument stanowi zbiorcze podsumowanie ćwiczeń 8, 9, 10, 11 i 12
realizowanych w ramach przedmiotu DevOps. Obejmuje on pełną ścieżkę od
automatyzacji infrastruktury, przez instalacje nienadzorowane systemów operacyjnych,
po orkiestrację kontenerów w Kubernetes i wdrażanie na platformach chmurowych.

W odróżnieniu od zbiorczych sprawozdań 1–4 (Git/Docker) i 5–7 (Jenkins CI/CD),
sprawozdanie 8–12 skupia się na zaawansowanych praktykach DevOps: automatyzacji
infrastruktury poprzez Ansible, zarządzaniu infrastrukturą as code, orkiestracji
kontenerów i wdrożeniu na platformach chmurowych.

## Cel i zakres serii ćwiczeń

Celem serii ćwiczeń było nabycie praktycznych umiejętności potrzebnych do:

1. **Automatyzacji infrastruktury** (Ansible) — konfiguracji wielu maszyn wirtualnych
   i orchestracji zadań administratorskich niezależnie od architektury CPU.

2. **Instalacji nienadzorowanych systemów operacyjnych** (Anaconda/Kickstart) — tworzenia
   reprodukowalnych, autonomicznych środowisk do wdrażania aplikacji bez interwencji
   operatora.

3. **Orkiestracji kontenerów** (Kubernetes) — zarządzania aplikacjami kontenerowymi
   w klastrach z automatycznym skalowaniem, aktualizacją i przywracaniem stanu.

4. **Wdrażania na platformach chmurowych** (Azure Container Instances) — publikacji
   aplikacji w środowisku public cloud.

### Zakres techniczny

Zakres obejmował:

- Konfiguracja środowiska Ansible (kontrola maszyn x64 i ARM64, playbooks, role, inwentarze).
- Tworzenie pełnego pipeline'u instalacji nienadzorowanych (kickstart, virtiofs, virt-install).
- Wdrażanie i orkiestracja Kubernetes (minikube, kubectl, deployment, service, dashboard).
- Zarządzanie cyklem życia aplikacji (skalowanie, strategie aktualizacji, rollout).
- Publikacja obrazów w Azure Container Instances.

## Przebieg ćwiczenia 8 (Ansible i multi-arch)

Ćwiczenie 8 wprowadził automatyzację infrastruktury i koncepcję multi-arch.

### Infrastruktura laboratoryjna

Zainstalowano trzy maszyny wirtualne:
- `ansible` (kontroler),
- `ansible-target-x64` (cel, architektura Intel x64),
- `ansible-target-arm64` (cel, architektura ARM64).

Maszyny x64 bootowane są bezpośrednio z jądra systemem plików `btrfs` poprzez subvoluminy,
co umożliwia szybkie snapshoting i eksport poprzez `btrfs send/receive`.
Maszyny ARM64 konfigurowane są w `virt-manager`/`libvirt`.

Dodatkowo skonfigurowano usługę `systemd-resolved` z mDNS, co umożliwia
rozwiązywanie nazw hostów w sieci lokalnej (`.local`).

### Ansible: Podstawowe operacje

1. **Inwentarz hostów** — zdefiniowanie grup (`control`, `managed`, `managed_x64`, `managed_arm64`).
2. **Walidacja łączności** — weryfikacja dostępu do wszystkich maszyn poleceniem `ansible all -m ping`.
3. **Pierwsza orchestracja** — playbook aktualizujący wszystkie maszyny (`pacman -Syu`).

Wykazano, że Ansible pracuje efektywnie na zasobach o różnych architekturach CPU,
co stanowi podstawę dla multi-arch CI/CD.

### Role i infrastruktura galaxy

Utworzono strukturę roli `deploy`:

```
roles/deploy/
├── meta/main.yml      (metadane i zależności)
└── tasks/main.yml     (definicja zadań)
```

Rola instaluje Docker, uruchamia usługę i pobiera obraz `hello-world`,
co pozwala na testowanie wieloarchitekturowego wdrażania.

### Problemy i rozwiązania

Podczas wdrażania napotkano problemy z systemami plików:

1. **Problem overlayfs na x64** — maszyna x64 bootowana z `virtiofs` miała ograniczenia
   capabilities. Rozwiązano poprzez libvirt hook'a ustawiający `--modcaps='+sys_admin'`
   dla procesu `virtiofsd`.

2. **Problem Docker na ARM64** — Docker nie uruchamiał się. Rozwiązano przez
   przeprowadzenie poprawnej aktualizacji systemu i przeładowanie modułów jądra.

Po naprawach playbook `deploy` przebiegł pomyślnie na wszystkich maszyn, co świadczy
o efektywności automatyzacji niezależnie od architektury.

## Przebieg ćwiczenia 9 (Instalacje nienadzorowane)

Ćwiczenie 9 skupiło się na automatyzacji instalacji systemów operacyjnych.

### Instalacja bazowa z sieci

Wykorzystano `virt-manager` i `libvirt` do instalacji sieciowej Fedory 44 z GUI.
Maszyna skonfigurowana z:
- EFI firmware,
- 4 vCPU, 4 GB RAM,
- virtiofs dla współdzielenia danych,
- konsolą serialową VirtIO.

Plik domeny XML zapewnia definicję infrastruktury maszyny i jej stanu —
stanowi część dokumentacji reprodukowalnej.

### Anaconda i Kickstart

Instalacja wykonana graficznie przez RDP, a następnie wyeksportowana do pliku
konfiguracyjnego `anaconda-ks.cfg` (format Kickstart).

Pliki Kickstart zawierają instrukcje partycjonowania, instalacji pakietów,
sieciowej konfiguracji i niestandardowych kroków post-instalacyjnych.

### Instalacja nienadzorowana (unattended)

Bazowy plik `anaconda-ks.cfg` zmieniono o:

1. **Tryb Command-line** — `cmdline` zamiast GUI,
2. **Konfiguracja hosta** — `network --hostname`,
3. **Clearing dysku** — `clearpart --all --initlabel`,
4. **Usunięcie predefiniowanych użytkowników** — pozwala na bezpieczną tworzę koniguracji per-maszyna,
5. **Ustawianie usług** — `services --enabled=docker`,
6. **Hooki post-instalacyjne** (`%post`) — montowanie virtiofs, kopiowanie obrazów Docker, włączanie serwisów.

### Automacja z virt-install

Zamiast GUI `virt-manager`, użyto polecenia `virt-install`, które generuje plik domeny
i uruchamia instalację w pełni autonomicznie.

Skrypt `setup-vm.sh`:

```sh
virt-install \
    --connect qemu:///system \
    --location="https://download.fedoraproject.org/pub/fedora/linux/releases/44/Everything/x86_64/os/" \
    --initrd-inject=anaconda-ks.cfg \
    --extra-args="inst.ks=file:/anaconda-ks.cfg console=hvc0" \
    --name="$NAME" --osinfo fedora44 --network=network=default \
    --vcpus=4 --memory=4096 --memorybacking="access.mode=shared,source.type=memfd" \
    --console="type=pty,target.type=virtio" \
    --filesystem="$LIBVIRT_VAR/filesystems/containers,containers,readonly=true,driver.type=virtiofs" \
    --disk "$LIBVIRT_VAR/images/$NAME.qcow2,size=20" \
    --video none --sound none --graphics none \
    --boot uefi
```

To pozwala na masowe tworzenie maszyn wirtualnych z tą samą konfiguracją.

### Wdrażanie aplikacji podczas instalacji

Post-instalacyjne hooki ładują i uruchamiają obrazy Docker w systemie:

```sh
%post --interpreter=/usr/bin/sh
mount -t virtiofs containers /mnt
install -dm755 /usr/local/share/docker-images-extra
install -Dm644 -t /usr/local/share/docker-images-extra/ /mnt/*.tar.gz
umount /mnt
systemctl enable my-pacman-launch.service
%end
```

Zapewnia to pełną autonomię: od pobrania OS, przez konfigurację, do wdrożenia aplikacji.

### Praktyka bezpieczeństwa

Konfiguracja umyślnie wymaga ręcznego ustawienia użytkownika i hasła po instalacji
(poprzez `initial-setup`). Zapobiega to wyciękowi danych z repozytoriów i zmniejsza
ryzyko przy skalowaniu — każda maszyna ma unikatowe poświadczenia.

## Przebieg ćwiczenia 10 (Kubernetes)

Ćwiczenie 10 wprowadził orkiestrację kontenerów poprzez Kubernetes.

### Instalacja klastra (minikube)

Wybrano `minikube` — lekki, lokalny klaster Kubernetes do celów laboratoryjnych.
Zainstalowano również `kubectl` (CLI dla Kubernetesa) i `kompose` (konwertacja Docker Compose → Kubernetes).

Klaster uruchomiono w trybie **Docker Rootless**, co ogranicza wpływ na system hosta
i zapewnia większe bezpieczeństwo.

### Aplikacja testowa

Zamiast oryginalnego projektu (pacman), użyto aplikacji sieciowej `speedtest`
(LibreSpeed) — narzędzia do testowania prędkości internetu dostępnego za HTTP.

Konfiguracja `docker-compose.yml`:

```yaml
services:
  speedtest:
    image: ghcr.io/librespeed/speedtest:latest
    environment:
      MODE: standalone
      TITLE: "Speedtest AGH"
    ports:
      - "8880:8080"
```

### Konwersja do Kubernetes

Narzędzie `kompose` skonwertowało konfigurację Docker Compose do zasobów Kubernetes:

```console
kompose -f compose.yml convert
```

Wygenerowano pliki `deployment.yaml` i `service.yaml`, które wdrażają aplikację w klastrze.

### Wdrażanie i ekspozycja

1. **Wdrożenie** — zasoby załadowano do klastra poprzez Dashboard graficznie lub `kubectl apply`.
2. **Weryfikacja** — potwierdzono uruchomienie podów: `kubectl get pods`.
3. **Ekspozycja portu** — port-forward z lokalnego portu na port kontenera, umożliwiając dostęp do aplikacji.
4. **Skalowanie** — powiększono replset do 5 replik poprzez Dashboard.

Wykazano, że Kubernetes automatycznie zarządza podami i utrzymuje życzony stan
(jeśli pod się zawali, Kubernetes tworzy nowy).

### Dashboard i monitorowanie

Uruchomiono Dashboard Kubernetes (`minikube dashboard`) — graficzny interfejs do:
- przeglądania podów, serwisów, deploymentów,
- edycji konfiguracji,
- monitorowania logów.

## Przebieg ćwiczenia 11 (*Zaawansowany Kubernetes*)

Ćwiczenie 11 pogłębiło umiejętności orkiestracji poprzez skalowanie, strategie
aktualizacji i kontrolę wdrażania.

### Zarządzanie replikami

Eksperymentowano z różnymi liczbami replik (0, 1, 2, 5) poprzez edycję deploymentu
w Dashboard. Wykazano, że Kubernetes utrzymuje życzany stan — usunięcie podu skutkuje
jego automatycznym odtworzeniem.

### Wersjonowanie obrazów

Testowano trzy warianty obrazu `speedtest`:
- `6.1.0` (nowszy),
- `6.0.2` (starszy),
- `broken` (uszkodzony, celowo dla testów).

### Walidacja deploymentu

Stworzono skrypt shell'owy `verify_deployment.sh` do weryfikacji statusu wdrażania:

```bash
kubectl rollout history deployment.apps/${DEPLOYMENT} -n ${NAMESPACE}
kubectl rollout status deployment.apps/${DEPLOYMENT} -n ${NAMESPACE} --timeout=60s
kubectl describe deployment.apps/${DEPLOYMENT} -n ${NAMESPACE}
kubectl get pods -n ${NAMESPACE} -o wide
```

Skrypt pozwala na diagnostykę błędów — np. gdy obraz nie istnieje, Kubernetes
zwraca error `ImagePullBackOff`, co jest widoczne w logach.

### Strategie aktualizacji

Przetestowano dwie strategia rollout'u:

#### 1. Recreate

Usuwa wszystkie stare pody i tworzy nowe. Aplikacja jest krótko niedostępna,
ale konfiguracja jest prosta.

#### 2. Rolling Update

Zastępuje pody stopniowo (domyślnie 25% niedostępnych i 25% ponad liczbą docelową).
Zapewnia ciągłość usługi, ale jest bardziej skomplikowana.

#### 3. Canary Deployment

Nie jest to wbudowana strategia, a raczej praktyka: użycie dwóch deploymentów
(`production` i `canary`) z wspólną usługą, różniące się etykietami.
Pozwala na testowanie nowych wersji na niewielkim podzbiorze ruchu.

### Historia i rollback

Kubernetes rejestruje historię deploymentów — `kubectl rollout history` pokazuje
poprzednie rewizje. Dzięki temu można szybko cofnąć się do stabilnej wersji.

## Przebieg ćwiczenia 12 (Wdrażanie na Azure)

Ćwiczenie 12 pokazał publikację aplikacji na platformie chmurowej.

### Publikacja obrazu

Obraz Docker (`my-pacman:7.1.0-b34` z ćwiczeń 5–7) opublikowano w **prywatnym**
repozytorium Docker Hub:

```bash
docker login
docker push <registry>/<image>:<tag>
```

### Wdrażanie na Azure

Wdrożenie wykonano poprzez Azure Container Instances (ACI):

1. **Portal Azure** — wybór *Container App* i konfiguracja zasobu.
2. **Konfiguracja obrazu** — wskazanie prywatnego repozytorium z poświadczeniami.
3. **Publikacja** — Azure automatycznie pobiera obraz i uruchamia kontener.

### Interpretacja statusu

Aplikacja `pacman` (tool administracyjny) jest typu *one-shot* — uruchamia się,
wyświetla help/usage i kończy pracę. Powoduje to, że Azure wyświetla status
*crashed*, co jest normalne dla tego typu aplikacji.

Potwierdzenie poprawnego wdrożenia vidać w logach: `pacman -V` wyświetla
wersję narzędzia, co świadczy o poprawnym uruchomieniu.

### Alternatywa CLI

Zadanie można również wykonać przez Azure CLI:

```bash
az containerapp create \
    --name <app-name> \
    --resource-group <group> \
    --image <image-url> \
    --environment <env>
```

## Kluczowe problemy i decyzje inżynierskie

### Problem 1: Multi-arch i ograniczenia hypervisora

Maszyny ARM64 w QEMU miały problemy z Docker ze względu na ograniczenia jądra
i emulatora. Rozwiązanie: aktualizacja systemu i przeładowanie modułów jądra.
W środowisku bare metal Docker działa prawidłowo.

### Problem 2: overlayfs na virtiofs

Dostęp do systemu plików overlay na virtiofs wymagał zwiększenia capabilities
dla procesu `virtiofsd` poprzez libvirt hook'a.

### Decyzja 1: Bezpieczeństwo konfiguracji w Kickstart

Umyślnie wyłączono predefiniowane konto (wymaga `initial-setup` post-boot).
Zapobiega to wyciękowi haseł między maszynami i ułatwia skalowanie.

### Decyzja 2: Przechowywanie obrazów Docker lokalnie (virtiofs)

Zamiast publikowania obrazów w rejestrze chmurowym, przechowywane są lokalnie
poprzez virtiofs. Wymaga mniej infrastruktury i zachowuje prywatność danych.

### Decyzja 3: Azure Container Instances zamiast AKS

ACI jest prostsze do wdrażania dla pojedynczych kontenerów, natomiast AKS
(Azure Kubernetes Service) byłby bardziej odpowiedni dla wielokontenerowych
aplikacji produkcyjnych.

## Wnioski końcowe

1. **Ansible jest potężnym narzędziem do automatyzacji infrastruktury** — nawet dla
   heterogenicznych środowisk (różne architektury, systemy operacyjne). Playbooks
   i role upraszczają zarządzanie wieloma maszynami.

2. **Instalacje nienadzorowane (Kickstart/virt-install) znacząco przyspieszają
   wdrażanie infrastruktury** — możliwość masowego tworzenia maszyn z identyczną
   konfiguracją. Post-instalacyjne hooki umożliwiają wdrażanie aplikacji bez
   interwencji operatora.

3. **Kubernetes odróżnia się od tradycyjnego zarządzania kontenerami** — automatyczne
   skalowanie, samoleczenie podów, strategie aktualizacji i historią rollout'u
   czyni go idealne dla aplikacji producyjnych.

4. **Multi-stage DevOps pipeline**: Ansible → Kickstart → Docker → Kubernetes → Azure
   stanowi kompletny przepływ od kodu do wdrażania w chmurze.

5. **Monitorowanie i kontrola wdrażania jest kluczowe** — skrypty walidujące status
   deploymentu (rollout history, describe, events) pozwalają na szybką diagnostykę
   i minimalizację przestoju.

6. **Bezpieczeństwo wymaga myślenia na wielopoziomowe**:
   - Na poziomie infrastruktury (libvirt, virtiofs capabilities),
   - Na poziomie systemu operacyjnego (rootless Docker, bezpieczne konfiguracje),
   - Na poziomie aplikacji (private registries, poświadczenia).

7. **Prywatne rejestry i lokalne przechowywanie obrazów są praktyczne dla
   laboratoriów i małych wdrażań**, ale w produkcji należy zastosować
   publiczne rejestry z replikacją geograficzną i SLA.

---

Podsumowując, seria ćwiczeń 8–12 rozszerzyła wiedzę z zakresu CI/CD o operacyjne
aspekty infrastruktury: od automatyzacji systemów operacyjnych, przez orkiestrację
kontenerów, po wdrażanie na platformach chmurowych. Zdobyte umiejętności tworzą
solidną podstawę do projektowania skalowlaych, niezawodnych i bezpiecznych
systemów w podejściu DevOps.
