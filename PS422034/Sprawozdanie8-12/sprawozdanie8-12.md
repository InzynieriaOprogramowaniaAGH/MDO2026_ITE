# Sprawozdanie Zbiorcze - PS422034
## Laboratoria 8-12: Ansible, Kickstart, Kubernetes, Azure

---

## Wstęp

Tematyka zajęć 8-12 stanowiła kolejny etap budowania kompetencji DevOps, skupiając się na automatyzacji zarządzania konfiguracją, wdrożeniach nienadzorowanych oraz orkiestracji kontenerów. Laboratoria 8-9 dotyczyły automatyzacji zadań administracyjnych przy użyciu Ansible oraz przygotowania pliku odpowiedzi Kickstart umożliwiającego bezobsługową instalację systemu operacyjnego. Laboratoria 10-11 wprowadziły Kubernetes jako platformę orkiestracji kontenerów - od pierwszego uruchomienia klastra, przez skalowanie i rolling update, aż po zaawansowane strategie wdrożeń. Laboratorium 12 zamknęło cykl wdrożeniem aplikacji kontenerowej w chmurze Microsoft Azure.

Wszystkie laboratoria były ze sobą logicznie powiązane: artefakt zbudowany w Jenkinsie (Lab 5-7) trafił do playbooka Ansible (Lab 8), obrazy Docker opublikowane w laboratorium 11 zostały wdrożone w chmurze w laboratorium 12. Taka ciągłość odzwierciedla rzeczywistą architekturę potoków DevOps stosowanych w środowiskach produkcyjnych.

---

## Omówienie użytych technologii i pojęć

### Ansible

Ansible to bezagentowe narzędzie do automatyzacji zarządzania konfiguracją, wdrożeń i orkiestracji zadań IT. W odróżnieniu od narzędzi wymagających instalacji agenta na każdej zarządzanej maszynie (jak Puppet czy Chef), Ansible komunikuje się z hostami docelowymi wyłącznie przez SSH. Na maszynie zarządzanej nie trzeba instalować żadnego dodatkowego oprogramowania - wystarczy działający serwer SSH i interpreter Python.

Konfiguracja opisywana jest w plikach YAML zwanych **playbookami**, definiujących sekwencje zadań do wykonania na wybranych grupach hostów. Każde zadanie korzysta z gotowego **modułu** - jednostki logiki enkapsulującej konkretną operację (np. `ansible.builtin.copy`, `ansible.builtin.apt`, `ansible.builtin.service`).

Kluczowe pojęcia Ansible:

- **Inwentarz** (`inventory`) - plik opisujący hosty i ich grupy. Hosty można grupować logicznie (np. `Orchestrators` i `Endpoints`) i adresować grupy w playbookach.
- **Playbook** - plik YAML składający się z jednego lub więcej **plays**. Każdy play wskazuje hosty i listę tasków. Playbooki czyta się jak przepis: co, gdzie i w jakiej kolejności wykonać.
- **Rola** (`role`) - mechanizm grupowania tasków, zmiennych, szablonów i plików w wielokrotnie używalną jednostkę. Strukturę roli generuje `ansible-galaxy role init`.
- **Idempotentność** - kluczowa cecha Ansible: wielokrotne uruchomienie tego samego playbooka daje identyczny efekt końcowy. Jeśli system jest już w żądanym stanie, Ansible nie wykonuje zbędnych operacji i raportuje `ok` zamiast `changed`.

### Plik odpowiedzi Kickstart

Kickstart to mechanizm automatyzacji instalacji systemów z rodziny Red Hat (Fedora, RHEL, CentOS). Plik odpowiedzi zawiera deklaratywny opis wszystkich wyborów dokonywanych zwykle ręcznie podczas instalacji: układ klawiatury, strefę czasową, schemat partycjonowania, listę pakietów, hasła użytkowników, konfigurację sieci oraz polecenia do wykonania po instalacji w sekcji `%post`.

Instalator Anaconda po zakończeniu instalacji automatycznie generuje plik `/root/anaconda-ks.cfg` - gotowy zapis wszystkich dokonanych wyborów, stanowiący punkt wyjścia do przygotowania własnego pliku odpowiedzi. Plik udostępnia się instalatorowi przez serwer HTTP, podając jego adres w parametrze bootloadera GRUB: `inst.ks=http://...`.

### Kubernetes

Kubernetes (K8s) to platforma orkiestracji kontenerów open-source, automatyzująca wdrażanie, skalowanie i zarządzanie aplikacjami kontenerowymi. Kluczowe abstrakcje:

- **Pod** - najmniejsza jednostka wdrożeniowa. Zawiera jeden lub więcej kontenerów współdzielących sieć i storage. Pody są efemeryczne - Kubernetes tworzy je i usuwa według potrzeb.
- **Deployment** - obiekt zarządzający zestawem replik podów. Deklaruje pożądany stan (np. „4 kopie obrazu X"), a Kubernetes stale dąży do jego utrzymania. Obsługuje rolling update i rollback.
- **ReplicaSet** - kontroler tworzony automatycznie przez Deployment, odpowiedzialny za utrzymanie zadeklarowanej liczby działających podów.
- **Service** - abstrakcja sieciowa zapewniająca stabilny punkt dostępu do zestawu podów. Typy: `ClusterIP` (wewnętrzny), `NodePort` (port węzła), `LoadBalancer` (chmurowy load balancer).
- **Namespace** - wirtualna izolacja zasobów w klastrze. Komponenty systemowe działają w `kube-system`, zasoby użytkownika domyślnie w `default`.

### Minikube

Minikube uruchamia lokalny jednowęzłowy klaster Kubernetes, przeznaczony do nauki i testowania. Instalacja sprowadza się do pobrania jednej binarki. Narzędzie `kubectl` dostarczane jest wbudowane jako `minikube kubectl --`, eliminując potrzebę osobnej instalacji klienta.

### Strategie wdrożeń Kubernetes

| Strategia | Downtime | Dwie wersje jednocześnie | Kiedy stosować |
|---|---|---|---|
| Recreate | Tak | Nie | Zmiany niekompatybilne wstecznie |
| RollingUpdate | Nie | Przez chwilę | Standardowe aktualizacje |
| Canary | Nie | Celowo | Testowanie na małej części ruchu |

### Azure Container Instances (ACI)

Azure Container Instances umożliwia uruchomienie kontenera Docker bez konfigurowania klastra ani serwera. Kontener uruchamiany jest bezpośrednio z obrazu z Docker Hub, a Azure samo przydziela zasoby obliczeniowe. ACI odpowiednie jest dla prostych wdrożeń jednorazowych - bez narzutu operacyjnego klastra Kubernetes. Zasoby Azure grupowane są w **Resource Groups** przypisanych do konkretnego regionu.

---

## Laboratorium 8 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

### Cel

Celem laboratorium było praktyczne zapoznanie się z Ansible jako systemem automatyzacji zarządzania konfiguracją. Zadanie polegało na skonfigurowaniu komunikacji SSH między dwiema maszynami, napisaniu playbooków demonstrujących idempotentność oraz wdrożeniu artefaktu Express.js z poprzednich zajęć przy użyciu roli Ansible.

### Środowisko i inwentarz

Laboratorium wymagało dwóch maszyn: maszyny głównej (`devops-serwer`) z zainstalowanym Ansible oraz maszyny docelowej (`ansible-target`) z Ubuntu 25.10. Komunikację skonfigurowano przez wymianę kluczy SSH oraz dodanie wpisu do `/etc/hosts`, dzięki czemu maszyny adresowane są nazwami zamiast adresami IP.

Inwentarz opisywał obie maszyny w dwóch logicznych grupach:

```ini
[Orchestrators]
localhost ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

Łączność zweryfikowano modułem `ping`:

```bash
ansible all -i ~/ansible/inventory.ini -m ping
```

Obie maszyny odpowiedziały `pong`, potwierdzając poprawną konfigurację SSH i Ansible.

### Playbook - zadania i idempotentność

Playbook `playbook.yml` realizował cztery zadania: weryfikację łączności, skopiowanie pliku inwentarza na maszynę docelową, aktualizację pakietów systemowych i restart usług systemowych.

```yaml
---
- name: Ping wszystkich
  hosts: all
  tasks:
    - name: Ping
      ansible.builtin.ping:

- name: Kopiuj inventory na Endpoints
  hosts: Endpoints
  tasks:
    - name: Kopiuj plik inventory
      ansible.builtin.copy:
        src: /home/pawel/ansible/inventory.ini
        dest: /home/ansible/inventory.ini
        owner: ansible
        mode: '0644'

- name: Aktualizuj pakiety na Endpoints
  hosts: Endpoints
  become: true
  tasks:
    - name: apt update + upgrade
      ansible.builtin.apt:
        update_cache: yes
        upgrade: dist

- name: Restart usług
  hosts: Endpoints
  become: true
  tasks:
    - name: Restart sshd
      ansible.builtin.service:
        name: ssh
        state: restarted
    - name: Restart rngd (ignoruj błąd jeśli brak)
      ansible.builtin.service:
        name: rngd
        state: restarted
      ignore_errors: true
```

Pierwsze uruchomienie playbooka zwróciło status `changed` przy zadaniach modyfikujących stan systemu. Drugie uruchomienie - bez żadnych zmian - zwróciło `ok` przy kopiowaniu pliku (plik był już na miejscu i identyczny) oraz przy aktualizacji pakietów. To właśnie **idempotentność**: Ansible weryfikuje aktualny stan i wykonuje tylko to, co konieczne. Użycie `ignore_errors: true` przy usłudze `rngd` pozwala playbookowi kontynuować nawet jeśli usługa nie istnieje na danej maszynie.

Przetestowano też zachowanie przy wyłączonej usłudze SSH na maszynie docelowej - Ansible skorzystał z istniejącego połączenia i zrestartował SSH jako jedno z zadań, przywracając pełen dostęp.

### Wdrożenie artefaktu - playbook deploy

Artefakt `express-1.0.0.tar.gz` z poprzednich laboratoriów skopiowano z kontenera Jenkins i wdrożono na maszynę docelową playbookiem `deploy.yml`. Realizował on kompletny cykl: weryfikację obecności Dockera z warunkową instalacją jeśli brak (`when: docker_check.rc != 0`), wysłanie archiwum, zbudowanie obrazu Docker na podstawie dynamicznie generowanego Dockerfile, uruchomienie kontenera, smoke test oraz sprzątanie środowiska.

Fragment kluczowej części playbooka - tworzenie Dockerfile i budowanie obrazu:

```yaml
- name: Stwórz Dockerfile
  ansible.builtin.copy:
    dest: /opt/express-app/Dockerfile
    content: |
      FROM node:latest
      WORKDIR /app
      COPY express-1.0.0.tar.gz /app/
      RUN tar -xzf express-1.0.0.tar.gz -C /app
      RUN echo "const express = require('/app'); const app = express(); \
      app.get('/', (req,res) => res.send('OK')); app.listen(3000);" > /app/server.js
      EXPOSE 3000
      CMD ["node", "/app/server.js"]

- name: Zbuduj obraz Docker
  ansible.builtin.shell: docker build -t express-runtime /opt/express-app/

- name: Uruchom kontener
  ansible.builtin.shell: docker run -d --name express-app -p 3000:3000 express-runtime

- name: Smoke test
  ansible.builtin.shell: sleep 5 && docker exec express-app curl -s http://localhost:3000
  register: smoke

- name: Wynik smoke testu
  ansible.builtin.debug:
    var: smoke.stdout
```

Smoke test zwrócił `"smoke.stdout": "OK"` - potwierdzenie poprawnego uruchomienia aplikacji na maszynie docelowej.

### Rola Ansible

Całe wdrożenie przepakowano w rolę Ansible (`express_deploy`) wygenerowaną przez:

```bash
ansible-galaxy role init express_deploy
```

Polecenie automatycznie tworzy standaryzowaną strukturę katalogów:

```
roles/express_deploy/
├── defaults/
├── files/
├── handlers/
├── meta/
├── tasks/
├── templates/
└── vars/
```

Taski z `deploy.yml` przeniesiono do `tasks/main.yml`, a metadane roli uzupełniono w `meta/main.yml`. Rolę uruchamiano przez prosty plik `site.yml`:

```yaml
---
- name: Deploy Express App via rola
  hosts: Endpoints
  roles:
    - express_deploy
```

```bash
ansible-playbook -i ~/ansible/inventory.ini ~/ansible/site.yml
```

Struktura plików w repozytorium:

```
PS422034/Sprawozdanie8/
├── inventory.ini
├── playbook.yml
├── deploy.yml
├── site.yml
└── roles/
    └── express_deploy/
        ├── meta/main.yml
        └── tasks/main.yml
```

### Wnioski

Ansible okazał się intuicyjnym narzędziem, gdzie czytelność playbooków YAML sprawia, że dokumentują one same siebie. Bezagentowość upraszcza onboarding nowych maszyn - wystarczy SSH i Python. Idempotentność zmienia podejście do automatyzacji: zamiast pisać skrypty „co zrobić krok po kroku", definiuje się „jaki ma być stan docelowy", a narzędzie samo decyduje co jest potrzebne. Role są naturalnym krokiem w kierunku wielokrotnego użycia i dystrybucji logiki wdrożeniowej.

---

## Laboratorium 9 - Pliki odpowiedzi dla wdrożeń nienadzorowanych

### Cel

Celem laboratorium było przygotowanie pliku odpowiedzi Kickstart umożliwiającego w pełni automatyczną instalację Fedory 42, która po uruchomieniu samodzielnie hostuje aplikację Express.js w kontenerze Docker - bez jakiejkolwiek interakcji użytkownika.

### Punkt wyjścia - plik anaconda-ks.cfg

Po pierwszej, interaktywnej instalacji Fedory 42 w Hyper-V, instalator Anaconda wygenerował `/root/anaconda-ks.cfg` - zapis wszystkich dokonanych wyborów. Fragment oryginalnego pliku:

```
# Generated by Anaconda 42.27.12
keyboard --vckeymap=pl --xlayouts='pl'
lang pl_PL.UTF-8

%packages
@^server-product-environment
%end

clearpart --none --initlabel
autopart
timezone Europe/Warsaw --utc
```

Plik ten stanowił punkt wyjścia do modyfikacji pod instalację nienadzorowaną.

### Modyfikowany plik odpowiedzi

Na podstawie `anaconda-ks.cfg` przygotowano `ks-modified.cfg` z następującymi kluczowymi zmianami:

- `clearpart --none` zastąpiono `clearpart --all --initlabel` - gwarantuje formatowanie całego dysku niezależnie od jego poprzedniej zawartości,
- dodano repozytoria sieciowe Fedory 42 (`url --mirrorlist=...`), aby instalator pobierał pakiety z internetu,
- ustawiono hostname `fedora-ps422034` zamiast domyślnego `localhost`,
- dodano pakiety `docker`, `curl`, `wget`,
- dodano sekcję `%post` konfigurującą Docker i serwis aplikacji,
- dodano dyrektywę `reboot` kończącą instalację automatycznym restartem.

Kompletny zmodyfikowany plik:

```
text
reboot

url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-42&arch=x86_64
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f42&arch=x86_64

lang pl_PL.UTF-8
keyboard --vckeymap=pl --xlayouts=pl
timezone Europe/Warsaw --utc

network --bootproto=dhcp --device=eth0 --onboot=yes
network --hostname=fedora-ps422034

rootpw --plaintext rootpass123
user --name=student --password=student123 --plaintext --groups=wheel

clearpart --all --initlabel
autopart

%packages
@^minimal-environment
docker
curl
wget
%end

%post --log=/root/ks-post.log
exec > /dev/tty3 2>&1
echo "=== Wlaczanie Docker ==="
systemctl enable docker

cat > /usr/local/bin/start-express.sh << 'SCRIPT'
#!/bin/bash
docker rm -f express-app || true
docker run -d --name express-app --restart=always -p 3000:3000 node:latest \
  sh -c "mkdir -p /app && cd /app && npm init -y && npm install express && \
  node -e \"const express=require('express'); const app=express(); \
  app.get('/',(req,res)=>res.send('OK')); app.listen(3000);\""
SCRIPT

chmod +x /usr/local/bin/start-express.sh

cat > /etc/systemd/system/express-app.service << 'SERVICE'
[Unit]
Description=Express App
After=docker.service network-online.target
Requires=docker.service

[Service]
ExecStart=/usr/local/bin/start-express.sh
Restart=on-failure
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

systemctl enable express-app.service
echo "=== Post-instalacja zakonczona ==="
%end
```

Sekcja `%post` zawiera dyrektywę `exec > /dev/tty3 2>&1`, dzięki której wszystkie komunikaty z etapu post-instalacji są przekierowywane na terminal TTY3 i widoczne na ekranie podczas trwania instalacji (zakres rozszerzony).

Ważne ograniczenie sekcji `%post`: polecenie `docker run` nie zadziała na tym etapie, ponieważ daemon Dockera nie jest jeszcze uruchomiony. Dlatego zamiast uruchamiać kontener bezpośrednio, jedynie włączono serwis przez `systemctl enable` - Docker i kontener uruchomią się przy pierwszym starcie systemu. Dyrektywa `After=docker.service` w definicji serwisu gwarantuje właściwą kolejność startowania zależności.

### Udostępnienie pliku i instalacja nienadzorowana

Plik `ks-modified.cfg` udostępniono przez prosty serwer HTTP uruchomiony na pierwszej maszynie Fedora:

```bash
firewall-cmd --add-port=8888/tcp --permanent && firewall-cmd --reload
python3 -m http.server 8888 &
```

Nową maszynę wirtualną (`fedora-kickstart2`) uruchomiono z tego samego ISO. Podczas bootowania edytowano parametry GRUB, dopisując na końcu linii startowej:

```
inst.ks=http://172.28.26.22:8888/ks-modified.cfg
```

Po zatwierdzeniu (`Ctrl+X`) instalator automatycznie pobrał plik odpowiedzi i przeprowadził całą instalację bez żadnej interakcji użytkownika.

### Weryfikacja po instalacji

Po automatycznym restarcie systemu zweryfikowano trzy rzeczy:

```bash
hostname                   # fedora-ps422034
systemctl status docker    # active (running), enabled
curl http://localhost:3000 # OK
```

Hostname był `fedora-ps422034`, Docker działał jako usługa, a aplikacja odpowiedziała `OK`. Cały łańcuch automatyzacji zadziałał poprawnie.

Zakres rozszerzony obejmował również zarządzanie maszyną wirtualną przez cmdlety PowerShell Hyper-V:

```powershell
Get-VM -Name "fedora-kickstart2" | Select-Object Name, State, MemoryAssigned, ProcessorCount
```

### Wnioski

Kickstart eliminuje czynnik ludzki z procesu instalacji systemu. Podejście z hostowaniem pliku przez HTTP jest elastyczne - plik można aktualizować bez modyfikowania nośnika instalacyjnego, co ma znaczenie przy wdrożeniach wielu maszyn. Połączenie Kickstarta z sekcją `%post` i serwisami systemd pozwala dostarczyć w pełni skonfigurowany system gotowy do pracy zaraz po pierwszym uruchomieniu.

---

## Laboratorium 10 - Wdrażanie na zarządzalne kontenery: Kubernetes (1)

### Cel

Celem laboratorium było pierwsze uruchomienie lokalnego klastra Kubernetes przy użyciu Minikube oraz zapoznanie się z podstawowymi obiektami: Podem, Deploymentem i Service. Demonstrowano różnicę między uruchomieniem pojedynczego poda a zarządzanym deploymentem z replikami.

### Instalacja i uruchomienie klastra

Minikube zainstalowano przez pobranie binarki:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Klaster uruchomiono ze sterownikiem Docker:

```bash
minikube start --driver=docker
```

Przed uruchomieniem konieczne było rozszerzenie przestrzeni dyskowej maszyny wirtualnej (Minikube pobiera własne obrazy systemowe), a klaster uruchomił się mimo ostrzeżenia o niewystarczającej ilości RAM - akceptowalne w środowisku laboratoryjnym.

Po uruchomieniu zweryfikowano stan wszystkich podów systemowych w przestrzeni nazw `kube-system`:

```bash
minikube kubectl -- get pods -A
```

Działające komponenty: `coredns`, `etcd-minikube`, `kube-apiserver-minikube`, `kube-controller-manager-minikube`, `kube-proxy`, `kube-scheduler-minikube` i `storage-provisioner` - wszystkie ze statusem `Running`.

Dashboard Kubernetes udostępniono przez `minikube dashboard --url`. Ponieważ nasłuchuje na wewnętrznym adresie maszyny, dostęp z przeglądarki na Windowsie wymagał tunelu SSH - analogicznie jak w przypadku Jenkinsa w laboratoriach 5-7.

### Pod vs Deployment - różnica w praktyce

W pierwszym kroku uruchomiono pojedynczy pod poleceniem `kubectl run` z aplikacją Express.js:

```bash
minikube kubectl -- run express-app --image=node:latest --port=3000 \
  --labels app=express-app -- sh -c \
  "mkdir -p /app && cd /app && npm init -y && npm install express && \
  node -e \"const express=require('express'); const app=express(); \
  app.get('/',(req,res)=>res.send('OK')); app.listen(3000);\""
```

Dostęp do poda uzyskano przez port-forward:

```bash
minikube kubectl -- port-forward pod/express-app 9090:3000 &
curl http://localhost:9090  # OK
```

Uruchomienie pojedynczego poda jest szybkie, ale ma istotne ograniczenie: jeśli pod ulegnie awarii, Kubernetes go nie restartuje - brak mechanizmu pilnującego jego działania. Właściwym podejściem jest Deployment.

### Plik Deployment - 4 repliki

Wdrożenie zapisano deklaratywnie w pliku `express-deployment.yml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: express-deployment
  labels:
    app: express-app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: express-app
  template:
    metadata:
      labels:
        app: express-app
    spec:
      containers:
      - name: express-app
        image: node:latest
        ports:
        - containerPort: 3000
        command: ["sh", "-c"]
        args: ["mkdir -p /app && cd /app && npm init -y && npm install express && \
               node -e \"const express=require('express'); const app=express(); \
               app.get('/',(req,res)=>res.send('OK')); app.listen(3000);\""]
```

```bash
minikube kubectl -- apply -f ~/express-deployment.yml
minikube kubectl -- rollout status deployment/express-deployment
minikube kubectl -- get pods
```

Deployment uruchomił 4 repliki poda - wszystkie ze statusem `Running`. Aplikację wyeksponowano jako Service i zweryfikowano:

```bash
minikube kubectl -- expose deployment express-deployment --type=NodePort --port=3000
minikube kubectl -- port-forward service/express-deployment 9091:3000 &
curl http://localhost:9091  # OK
```

### Wnioski

Laboratorium pokazało fundamentalną różnicę między Dockerem a Kubernetes: Docker uruchamia kontenery, Kubernetes zarządza ich cyklem życia w skali. Deklaratywny model (opisujemy pożądany stan, nie sekwencję kroków) i automatyczne naprawianie awarii odróżniają Kubernetes od ręcznego zarządzania kontenerami. Plik YAML Deploymentu staje się dokumentacją infrastruktury i może być wersjonowany razem z kodem aplikacji.

---

## Laboratorium 11 - Wdrażanie na zarządzalne kontenery: Kubernetes (2)

### Cel

Celem laboratorium było pogłębienie wiedzy o Kubernetes przez pracę z własnymi obrazami Docker oraz demonstrację zaawansowanych operacji: skalowania, rolling update, obsługi wadliwych wdrożeń, rollbacku i różnych strategii wdrożeń.

### Przygotowanie obrazów i publikacja na Docker Hub

Zbudowano trzy wersje własnej aplikacji Express.js, bazujące na lekkim obrazie `node:20-alpine`:

**Wersja v1** - odpowiada `OK - wersja 1`:

```bash
docker build -t pawlistonks/express-app:v1 .
docker push pawlistonks/express-app:v1
```

**Wersja v2** - zmieniona treść odpowiedzi na `OK - wersja 2`:

```bash
docker build -t pawlistonks/express-app:v2 .
docker push pawlistonks/express-app:v2
```

**Wersja broken** - aplikacja natychmiast kończy pracę z błędem, symulując błąd konfiguracyjny:

```javascript
console.error("FATAL: config missing");
process.exit(1);
```

```bash
docker build -t pawlistonks/express-app:broken .
docker push pawlistonks/express-app:broken
```

Wybór obrazu `node:20-alpine` zamiast `node:latest` zmniejsza rozmiar obrazu z ponad 1 GB do kilkudziesięciu MB, co przyspiesza pobieranie i zmniejsza powierzchnię ataku.

### Plik Deployment i skalowanie

Wdrożenie zdefiniowano w pliku `express-deployment.yml` z obrazem v1 i 4 replikami. Skalowanie odbywało się przez modyfikację pola `replicas` i ponowne `kubectl apply`:

```bash
# Skalowanie do 8 replik
minikube kubectl -- scale deployment/express-deployment --replicas=8
minikube kubectl -- rollout status deployment/express-deployment

# Skalowanie do 0 - aplikacja zatrzymana, konfiguracja zachowana
minikube kubectl -- scale deployment/express-deployment --replicas=0
minikube kubectl -- get pods  # No resources found

# Przywrócenie 4 replik
minikube kubectl -- scale deployment/express-deployment --replicas=4
```

Skalowanie do zera jest charakterystycznym wzorcem Kubernetes - pozwala tymczasowo zatrzymać aplikację bez usuwania konfiguracji Deploymentu.

### Rolling Update i ochrona przed wadliwymi wdrożeniami

Aktualizację obrazu z `v1` do `v2` wykonano przez modyfikację pola `image` w pliku YAML i `kubectl apply`. Kubernetes przeprowadził rolling update - podmienił pody stopniowo, zachowując dostępność usługi. Zweryfikowano po aktualizacji:

```bash
minikube kubectl -- port-forward deployment/express-deployment 9092:3000 &
curl http://localhost:9092  # OK - wersja 2
```

Następnie celowo wdrożono wadliwy obraz `broken`. Kubernetes wykrył, że nowe pody natychmiast crashują (rosnąca liczba restartów, status `Error`) i automatycznie zatrzymał rollout. Stare pody z v2 pozostały działające - klaster nie zniszczył działającego wdrożenia na rzecz wadliwego:

```bash
minikube kubectl -- get pods
# NAME                                   READY   STATUS             RESTARTS
# express-deployment-7d9f8b-xxxx         1/1     Running            0         # stare v2
# express-deployment-broken-yyyy         0/1     Error              5          # nowe broken
```

Powrót do poprzedniej wersji wykonano jednym poleceniem:

```bash
minikube kubectl -- rollout undo deployment/express-deployment
minikube kubectl -- rollout status deployment/express-deployment
```

Historia rewizji z adnotacjami umożliwia audyt wszystkich zmian:

```bash
minikube kubectl -- rollout history deployment/express-deployment
minikube kubectl -- annotate deployment/express-deployment \
  kubernetes.io/change-cause="powrot do v2 po broken"
```

### Skrypt weryfikujący wdrożenie

Napisano skrypt `check-deployment.sh` weryfikujący czy wdrożenie zakończyło się pomyślnie w ciągu 60 sekund:

```bash
#!/bin/bash
DEPLOYMENT="express-deployment"
TIMEOUT=60

if minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "SUCCESS: Wdrożenie zakończone w czasie!"
    exit 0
else
    echo "FAILED: Wdrożenie nie zdążyło w ${TIMEOUT}s!"
    exit 1
fi
```

Skrypt zwraca kod wyjścia `0` przy sukcesie i `1` przy przekroczeniu limitu, co umożliwia integrację z systemami CI/CD - pipeline może automatycznie wykryć nieudane wdrożenie i podjąć akcję naprawczą.

### Strategie wdrożeń

#### Recreate

Strategia `Recreate` zatrzymuje wszystkie istniejące pody przed uruchomieniem nowych. Powoduje chwilowy downtime, ale gwarantuje brak jednoczesnego działania dwóch wersji - właściwe gdy nowa wersja jest niekompatybilna ze starą.

```yaml
spec:
  strategy:
    type: Recreate
```

Podczas aktualizacji widoczny był charakterystyczny wzorzec: wszystkie stare pody przechodziły jednocześnie w stan `Terminating`, po czym nowe pody startowały od zera.

#### RollingUpdate

Strategia `RollingUpdate` podmienia pody stopniowo. Parametry `maxUnavailable` i `maxSurge` kontrolują tempo i skalę podmianki:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2
      maxSurge: 25%
```

W odróżnieniu od `Recreate`, nowe pody uruchamiane są zanim stare zostaną zatrzymane - usługa pozostaje dostępna przez cały czas aktualizacji.

#### Canary Deployment

Canary to wzorzec realizowany przez dwa osobne deploymenty i dwa oddzielne serwisy. Mała część ruchu kierowana jest do nowej wersji w celu weryfikacji przed pełnym wdrożeniem:

```yaml
# deployment-canary.yml
spec:
  replicas: 1
  selector:
    matchLabels:
      app: express-canary
      track: canary
  template:
    metadata:
      labels:
        app: express-canary
        track: canary
```

```bash
minikube kubectl -- apply -f ~/deployment-canary.yml
minikube kubectl -- apply -f ~/service-canary.yml
minikube kubectl -- port-forward service/express-canary-svc 9093:3000 &
curl http://localhost:9093  # OK - wersja 2
```

Serwis canary obsługiwał ruch niezależnie od głównego deploymentu, umożliwiając testowanie nowej wersji na izolowanym przepływie żądań.

### Wnioski

Kubernetes dostarcza mechanizmy automatycznej ochrony przed wadliwymi wdrożeniami, których brak w ręcznym zarządzaniu kontenerami. Rolling update z automatycznym wykrywaniem crashujących podów i rollback jednym poleceniem czynią wdrożenia bezpieczniejszymi i szybszymi do naprawienia. Wybór strategii wdrożenia to świadoma decyzja architektoniczna wynikająca z wymagań aplikacji - nie kwestia preferencji.

---

## Laboratorium 12 - Wdrażanie na zarządzalne kontenery w chmurze (Azure)

### Cel

Celem laboratorium było wdrożenie własnego obrazu Docker z Docker Hub na platformę Microsoft Azure przy użyciu Azure Container Instances, weryfikacja działania usługi oraz posprzątanie wszystkich zasobów po zakończeniu pracy.

### Logowanie i wybór subskrypcji

Po uruchomieniu Azure Cloud Shell zalogowano się kontem studenckim Microsoft Azure for Students i zweryfikowano aktywną subskrypcję.

### Utworzenie grupy zasobów

Początkowo podjęto próbę użycia regionów `westeurope` i `northeurope`, jednak polityka subskrypcji studenckiej ograniczała dostępne regiony. Grupę zasobów utworzono w `francecentral`:

```bash
az group create \
  --name rg-ps-express \
  --location francecentral
```

Jest to ważna praktyczna lekcja: w środowiskach korporacyjnych i akademickich polityki IAM mogą znacząco ograniczać dostępne opcje konfiguracji - należy to weryfikować przed wdrożeniem.

### Wdrożenie kontenera z Docker Hub

Do wdrożenia wykorzystano obraz zbudowany i opublikowany w poprzednim laboratorium - bezpośrednia demonstracja wartości Docker Hub jako ogniwa łączącego pipeline CI/CD z docelowym środowiskiem:

```bash
az container create \
  --resource-group rg-ps-express \
  --name aci-ps-express \
  --image pawlistonks/express-app:v2 \
  --ports 3000 \
  --dns-name-label ps-express-aci-12345 \
  --location francecentral \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5
```

### Weryfikacja działania

Sprawdzono stan kontenera i pobrano logi:

```bash
az container show \
  --resource-group rg-ps-express \
  --name aci-ps-express \
  --query instanceView.state
# "Running"

az container logs \
  --resource-group rg-ps-express \
  --name aci-ps-express
# Listening on 3000
```

Azure automatycznie przydzieliło pełny adres FQDN:

```
ps-express-aci-12345.francecentral.azurecontainer.io
```

Pod tym adresem aplikacja była dostępna z przeglądarki natychmiast po wdrożeniu - bez konfigurowania DNS, load balancera ani certyfikatów.

### Usunięcie zasobów

Po zakończeniu testów usunięto kontener, a następnie grupę zasobów jednym poleceniem - usuwa ono wszystkie zawarte w niej zasoby:

```bash
az container delete --resource-group rg-ps-express --name aci-ps-express --yes
az group delete --name rg-ps-express --yes --no-wait
```

Sprzątanie zasobów jest obowiązkiem użytkownika - pozostawione zasoby generują koszty nawet gdy nikt z nich nie korzysta, co w środowiskach ze skończonym budżetem (subskrypcje studenckie) ma szczególne znaczenie.

### Wnioski

ACI idealnie ilustruje model chmury „płać za to czego używasz" - kontener istniał i generował koszty tylko przez czas trwania testu. Porównując z Kubernetes, ACI nie oferuje automatycznego skalowania ani zaawansowanego zarządzania cyklem życia, ale też nie wymaga żadnej z tych konfiguracji. Laboratorium domknęło pętlę: ten sam obraz Docker, który zbudowano lokalnie w Lab 11, trafił bezpośrednio do działającej usługi publicznej w chmurze.

---

## Podsumowanie

Realizacja laboratoriów 8-12 zbudowała spójny obraz pełnego procesu dostarczania oprogramowania w środowiskach DevOps:

1. **Ansible (Lab 8)** - automatyzacja zarządzania konfiguracją bez agentów. Deklaratywne playbooki, idempotentność i role tworzą infrastrukturę opisaną kodem - powtarzalną, audytowalną i łatwą w utrzymaniu. Artefakt z Jenkinsa trafił na maszynę docelową w pełni automatycznie.

2. **Kickstart (Lab 9)** - automatyzacja sięgająca warstwy instalacji systemu operacyjnego. Plik odpowiedzi eliminuje czynnik ludzki z procesu instalacji i dostarcza w pełni skonfigurowany system zaraz po pierwszym uruchomieniu.

3. **Kubernetes (Lab 10)** - wprowadzenie deklaratywnego modelu zarządzania kontenerami w skali. Zamiast ręcznie uruchamiać kontenery, opisuje się pożądany stan - klaster dąży do jego utrzymania włącznie z automatyczną naprawą awarii.

4. **Kubernetes zaawansowany (Lab 11)** - bezpieczne wdrożenia: rolling update, automatyczna ochrona przed wadliwymi obrazami, rollback w kilka sekund oraz strategie Recreate, RollingUpdate i Canary dobierane do konkretnych wymagań biznesowych.

5. **Azure ACI (Lab 12)** - wdrożenie w chmurze publicznej bez konfigurowania infrastruktury. Obraz z Docker Hub trafił bezpośrednio do działającej, publicznie dostępnej usługi, domykając pętlę od kodu źródłowego do produkcji.

Wspólnym mianownikiem wszystkich zajęć jest przesunięcie odpowiedzialności od ręcznych, podatnych na błędy operacji w stronę zautomatyzowanych, deklaratywnych systemów - fundamentalna zmiana podejścia, która odróżnia DevOps od tradycyjnej administracji systemami.
