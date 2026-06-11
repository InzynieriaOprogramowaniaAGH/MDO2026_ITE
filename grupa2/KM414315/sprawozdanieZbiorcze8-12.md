# Zbiorcze Sprawozdanie z Laboratoriów 08-12: Od Automatyzacji Infrastruktury po Chmurę Obliczeniową
**Autor:** Krzysztof Mamcarz (KM414315)

---

## Wstęp Ogólny
Celem zrealizowanego bloku laboratoriów było praktyczne opanowanie nowoczesnych metod wdrażania systemów operacyjnych, zarządzania konfiguracją, orkiestracji kontenerów oraz wykorzystania chmury publicznej. 
Prace podzielono na trzy główne etapy:
1. **Automatyzacja (Lab 08-09):** Zarządzanie infrastrukturą z użyciem Ansible oraz instalacje nienadzorowane (Kickstart).
2. **Orkiestracja (Lab 10-11):** Lokalne wdrażanie i skalowanie aplikacji opartych na kontenerach przy użyciu klastra Kubernetes.
3. **Chmura Obliczeniowa (Lab 12):** Wdrażanie zarządzalnych kontenerów w środowisku Microsoft Azure.

---

## CZĘŚĆ I: Automatyzacja Wdrożeń (Ansible & Kickstart)

### 1. Laboratorium 08 – Zdalne zarządzanie i konfiguracja (Ansible)

**Inwentaryzacja środowiska (Inventory)**
Pierwszym krokiem konfiguracji Ansible było zdefiniowanie węzłów zarządzanych. Utworzono plik `hosts.ini`, w którym podzielono środowisko na maszynę orkiestrującą (`Orchestrators`) oraz docelową (`Endpoints`).

```ini
# Plik: hosts.ini
[Orchestrators]
localhost ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

Aby zweryfikować poprawność konfiguracji kluczy SSH oraz łączność bezhasłową, wykonano testowy ping do wszystkich węzłów:

```bash
ansible -i hosts.ini all -m ping
```

Zarówno `localhost`, jak i `ansible-target` zwróciły status `SUCCESS` wraz z odpowiedzią `"ping": "pong"`, co potwierdziło gotowość środowiska do przyjmowania poleceń.

Wykonywanie procedur za pomocą Playbooka
W celu ujednolicenia konfiguracji maszyny docelowej przygotowano deklaratywny skrypt w formacie YAML (Playbook). Jego zadaniem było zaktualizowanie repozytoriów, wgranie odpowiednich pakietów narzędziowych oraz restart kluczowych usług (demona SSH oraz generatora liczb losowych `rngd`).

```yml
# Plik: playbook.yml
---
- name: Konfiguracja maszyny docelowej
  hosts: Endpoints
  become: yes
  tasks:
    - name: Skopiowanie pliku inwentaryzacji
      ansible.builtin.copy:
        src: hosts.ini
        dest: /home/ansible/hosts.ini
        owner: ansible
        mode: '0644'

    - name: Aktualizacja pakietów w systemie (apt update & upgrade)
      ansible.builtin.apt:
        update_cache: yes
        upgrade: dist

    - name: Upewnienie sie, ze rng-tools jest zainstalowane
      ansible.builtin.apt:
        name: rng-tools-debian
        state: present

    - name: Restart uslugi sshd
      ansible.builtin.service:
        name: ssh
        state: restarted

    - name: Restart uslugi rngd
      ansible.builtin.service:
        name: rng-tools-debian
        state: restarted
```

Wykonanie playbooka potwierdziło kluczową właściwość Ansible – idempotentność. Po ponownym uruchomieniu skryptu, zadania instalacyjne otrzymały status `ok` (brak niepotrzebnych zmian), a jedynie moduły wymuszające restart oznaczono jako `changed`.
Logikę instalacji oprogramowania (silnika Docker) oraz uruchomienia środowiska testowego Nginx zaszyto w głównym pliku zadań stworzonej roli, uwzględniając mechanizm wyłapywania błędów (sanity check).

```yml
# Plik: deploy_app/tasks/main.yml
---
- name: Przeprowadz sanity check docelowej maszyny
  ansible.builtin.command: docker --version
  ignore_errors: yes
  register: sanity_check

- name: Na maszynie docelowej, Dockera zainstaluj Ansiblem!
  ansible.builtin.apt:
    name: docker.io
    state: present
    update_cache: yes
  when: sanity_check.failed

- name: Upewnienie sie, ze usluga Docker dziala i startuje z systemem
  ansible.builtin.service:
    name: docker
    state: started
    enabled: yes

- name: Pobierz z Docker Hub aplikacje i uruchom kontener
  ansible.builtin.command: docker run -d --name apka-testowa -p 8080:80 nginx:latest

- name: Czekaj kilka sekund na pelne uruchomienie aplikacji
  ansible.builtin.pause:
    seconds: 3

- name: Zweryfikuj lacznosc z kontenerem
  ansible.builtin.command: curl -s http://localhost:8080
  register: curl_result

- name: Pokaz wynik weryfikacji (sukces!)
  ansible.builtin.debug:
    msg: "Pomyslnie polaczono z aplikacja w kontenerze!"
  when: curl_result.rc == 0

- name: Zatrzymaj i usun kontener (Oczyszczanie srodowiska)
  ansible.builtin.command: docker rm -f apka-testowa
```

### 2. Laboratorium 09 – Instalacje nienadzorowane (Kickstart)

Automatyzacja instalacji systemu Fedora
Przygotowano plik odpowiedzi dla instalatora Anaconda, który całkowicie znosi konieczność ręcznej interakcji operatora podczas instalacji systemu. Plik określa ustawienia regionalne, politykę formatowania dysku (`clearpart`), ustawienia sieci oraz zautomatyzowaną konfigurację repozytoriów. Zaimplementowano dyrektywę `%post` odpowiadającą za post-konfigurację systemu (włączenie usługi Docker i skryptów uruchomieniowych).

```bash
# Plik: ks.cfg
text
lang en_US.UTF-8
keyboard pl
timezone Europe/Warsaw
reboot

network --bootproto=dhcp --hostname=fedora-auto --activate
rootpw --plaintext haslo123

url --mirrorlist=[http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch](http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch)
repo --name=update --mirrorlist=[http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch](http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch)

clearpart --all --initlabel
autopart

%packages
@core
moby-engine
nano
curl
%end

%post --log=/root/ks-post.log
systemctl enable docker

cat << 'SERVICE' > /etc/systemd/system/uruchom-apke.service
[Unit]
Description=Uruchomienie testowej aplikacji w Dockerze
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker run -d --name apka-kickstart -p 8080:80 nginx:latest

[Install]
WantedBy=multi-user.target
SERVICE

systemctl enable uruchom-apke.service
%end
```

Plik udostępniono w sieci wirtualnej za pomocą wbudowanego serwera HTTP Pythona na porcie 8000. Parametry GRUB zmodyfikowano podczas rozruchu: `inst.ks=http://<IP_SERWERA>:8000/ks.cfg`. Po automatycznym restarcie zweryfikowano poprawne wdrożenie poleceniami `docker ps` oraz `curl -s http://localhost:8080 | grep title`, co zwróciło nagłówek Nginx i ostatecznie potwierdziło skuteczność podejścia Infrastructure as Code.

## CZĘŚĆ II: Orkiestracja Kontenerów (Kubernetes)

### 3. Laboratorium 10 – Architektura klastra i wdrożenia deklaratywne

Wdrożenie klastra zrealizowano lokalnie za pomocą narzędzia `minikube` (silnik Docker).

```bash
minikube start --driver=docker
```

Poprawność wdrożenia zweryfikowano komendą `kubectl get nodes` oraz uruchomieniem graficznego panelu `minikube dashboard`.
Początkowo aplikację uruchomiono imperatywnie:

```bash
kubectl run apka-lab10 --image=nginx:latest --port=80 --labels app=apka-lab10
```

Proces ten przekuto następnie w plik konfiguracyjny YAML `(Deployment)`, zapewniający wysoką dostępność dzięki utrzymywaniu 4 replik.

```yml
# Plik: deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apka-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: apka-lab10
  template:
    metadata:
      labels:
        app: apka-lab10
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Obiekt wyeksponowano na zewnątrz za pomocą Serwisu (`NodePort`), zlecając Kubernetesowi równoważenie obciążenia (Load Balancing).

### 4. Laboratorium 11 – Zarządzanie cyklem życia i strategie aktualizacji

Skalowanie i Dystrybucja
Zbadano elastyczność środowiska poprzez dynamiczne skalowanie wdrożenia w locie (od 0 do 8 replik):

```bash
kubectl scale deployment apka-deployment --replicas=8
```

Zbudowano lokalnie nowe obrazy na bazie Alpine (`v1, v2, faulty`) i załadowano je bezpośrednio do wewnętrznego silnika klastra poleceniem `minikube image load`, optymalizując transfer z Docker Huba.

Aktualizacje, obsługa awarii i skrypty weryfikujące
Celowo naruszono stabilność systemu wdrażając obraz `faulty`. Klaster zablokował uszkodzoną aktualizację (`status CrashLoopBackOff`), chroniąc działające pody. Produkcję uratowano mechanizmem wycofania zmiany:

```bash
kubectl rollout undo deployment/apka-deployment
```

Napisano również skrypt zautomatyzowanej kontroli, wspierający potoki CI/CD w weryfikacji stabilności rolloutów:

```bash 
#!/bin/bash
# Plik: sprawdz-wdrozenie.sh
if kubectl rollout status deployment/apka-deployment --timeout=60s; then
  echo "SUKCES: Wdrozenie stabilne i gotowe!"
else
  echo "BLAD: Wdrozenie nie powiodlo sie w wyznaczonym czasie (60s)."
  exit 1
fi
```

Strategie Wdrożeniowe (Podsumowanie)
Przetestowano odmienne strategie architektoniczne:

    Recreate: Bezwzględne wyłączenie wszystkich starych podów przed budową nowych (downtime).

    Rolling Update: Zmodyfikowana wersja domyślna z dopasowanymi parametrami maxUnavailable: 2 i maxSurge: 25%.

    Canary Deployment: Utworzenie osobnego manifestu (1 replika) dzielącego etykietę główną (app: apka-lab10), co pozwoliło skierować ułamek ruchu sieciowego na nową wersję bez ryzykowania stabilności całej usługi.

## CZĘŚĆ III: Zarządzalne Kontenery w Chmurze (Azure)

### 5. Laboratorium 12 – Azure Container Instances (ACI)

W ostatnim etapie opuszczono środowisko lokalne na rzecz chmury publicznej. Zadaniem było wdrożenie publicznego obrazu Nginx z Docker Hub do usługi ACI poprzez Azure Cloud Shell (Bash).

Przed przystąpieniem do pracy zarejestrowano dostawcę usługi w subskrypcji studenckiej, a następnie utworzono dedykowaną grupę zasobów w regionie Polska:

Następnie przeprowadzono właściwe wdrożenie. Parametry komendy precyzyjnie definiowały żądane zasoby (CPU, pamięć RAM) oraz typ systemu operacyjnego, co pozwoliło uniknąć konfliktów przyznawania kwot w chmurze.

```bash 
krzysztof [ ~ ]$ az container create \
  --resource-group Lab12-RG-PL \
  --name apka-lab12 \
  --image nginx:latest \
  --dns-name-label apkalab12-km414315-pl \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 80
```

(Wynik JSON potwierdził utworzenie instancji ze stanem "Running" i powiązanym publicznym IP).

Weryfikację dostępności przeprowadzono wydobywając publiczny adres FQDN kontenera i wykonując żądanie HTTP w przeglądarce, co potwierdziło sukces wdrożenia.

Stan usług oraz ruch sieciowy sprawdzono dodatkowo z perspektywy logów chmurowych poleceniem `az container logs`.

Aby zapobiec niepotrzebnemu zużyciu limitów studenckich (Cost Management), cały cykl wdrożenia zamknięto bezwzględnym usunięciem wygenerowanej wcześniej grupy zasobów:

## Wnioski Końcowe

Zestaw laboratoriów pozwolił na kompletne przejście ścieżki nowoczesnego cyklu wytwarzania i wdrażania oprogramowania. Zaczynając od zautomatyzowanego przygotowywania sprzętu (IaC/Ansible/Kickstart), poprzez deklaratywne utrzymywanie niezawodności lokalnego oprogramowania (Kubernetes), na pełnym przeniesieniu odpowiedzialności za architekturę do chmury publicznej (CaaS/Azure) kończąc. Narzędzia te eliminują błędy manualne i są fundamentem współczesnych praktyk DevOps.

