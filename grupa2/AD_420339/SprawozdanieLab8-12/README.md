# Sprawozdanie zbiorcze z części 3: laboratorium 8-12
**Autor:** Aleksandra Duda, grupa 2

## Cel i tematyka
Głównym celem zrealizowanej części laboratoriów było zapoznanie się z nowoczesnymi metodami automatyzacji procesów DevOps oraz z zarządzaniem pełnym cyklem życia aplikacji. Tematyka zajęć obejmowała szeroki zakres zagadnień - od nienadzorowanej instalacji systemów operacyjnych i zdalnej konfiguracji środowisk za pomocą Ansible, po automatyczne budowanie projektów w potokach CI/CD. Kluczowym elementem było również zdobycie umiejętności wdrażania, skalowania i monitorowania aplikacji kontenerowych w chmurze Microsoft Azure oraz w środowisku Kubernetes.

--------------------------------------------------------------------------------------

## Laboratorium 8 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible
### Cel
Celem laboratorium było zapoznanie się z narzędziem Ansible, konfiguracja środowiska wielomaszynowego, automatyzacja zadań administracyjnych przy użyciu playbooków oraz stworzenie niezależnej roli wdrażającej artefakt (kontener Docker) w środowisku odizolowanym.

### Realizacja zadań
1. Przygotowanie środowiska i wymiana kluczy

W celu realizacji zadań postawiłam drugą maszynę wirtualną (ansible-target) z minimalnym zestawem oprogramowania (obecny serwer OpenSSH oraz pakiet tar). Na maszynie zarządzającej (ansible-control) zainstalowałam Ansible.

![alt text](../Sprawozdanie8/image-4.png)
![alt text](../Sprawozdanie8/image.png)
![alt text](../Sprawozdanie8/image-1.png)

2. Inwentaryzacja i konfiguracja DNS

Mapowanie nazw hostów na adresy IP zrealizowałam lokalnie poprzez edycję pliku /etc/hosts oraz weryfikację za pomocą modułu systemd-resolved. Poprawność komunikacji DNS potwierdziłam testem ping. Następnie utworzyłam plik inwentaryzacji dzielący infrastrukturę na sekcje Orchestrators oraz Endpoints, sprawdzając łączność modułem ad-hoc ansible -m ping.

Plik /etc/hosts, struktura pliku inventory.ini oraz wynik udanego polecenia ping:
![alt text](../Sprawozdanie8/image-6.png)
![alt text](../Sprawozdanie8/image-7.png)
![alt text](../Sprawozdanie8/image-9.png)
![alt text](../Sprawozdanie8/image-10.png)

3. Zdalne wywoływanie procedur za pomocą Playbooków

Utworzyłam i uruchomiłam skrypt tasks.yml realizujący kopiowanie plików, aktualizację pakietów systemowych oraz restart usług systemowych (sshd, rngd).

Drugie uruchomienie playbooka wykazało status changed=0. Wynika to z cechy idempotentności Ansible - narzędzie weryfikuje stan docelowy i nie wykonuje operacji powtórnie, jeśli pliki lub konfiguracje na maszynie docelowej są tożsame ze źródłem.

Obsługa awarii sieciowych: Przeprowadziłam testy odporności systemu poprzez zasymulowanie awarii (wyłączenie usługi SSH oraz odpięcie karty sieciowej na maszynie docelowej). Zgodnie z oczekiwaniami, Ansible natychmiast przerwał wykonywanie zadań, raportując status hosta jako unreachable.

![alt text](../Sprawozdanie8/image-15.png)
![alt text](../Sprawozdanie8/image-16.png)
![alt text](../Sprawozdanie8/image-22.png)
![alt text](../Sprawozdanie8/image-23.png)

4. Zarządzanie artefaktem i strukturyzacja kodu

W architekturze odizolowanej od zewnętrznych rejestrów (Docker Hub), proces wdrażania (Publish & Deploy) zrealizowałam za pomocą eksportu kontenera NestJS do lokalnego archiwum .tar (docker save), przesłania go na endpoint i załadowania do docelowego silnika (docker load).

W celu podniesienia czytelności i ponownego wykorzystania kodu, skrypt deploy_flat.yml zrefaktoryzowałam do postaci dedykowanej roli Ansible zainicjalizowanej narzędziem ansible-galaxy. Rola ta zawiera etap walidacyjny (Sanity Check wolnego miejsca), automatyczną instalację Docker Engine, uruchomienie kontenera, weryfikację wystawionego portu 3000 oraz sprzątanie plików tymczasowych.

![alt text](../Sprawozdanie8/image-28.png)
![alt text](../Sprawozdanie8/image-29.png)
![alt text](../Sprawozdanie8/image-31.png)

### Wnioski cząstkowe
Wykorzystanie Ansible udowodniło, że automatyzacja oparta na architekturze bezagentowej i protokole SSH pozwala na błyskawiczne włączenie nowych maszyn do centralnego systemu zarządzania bez konieczności instalowania dodatkowego oprogramowania. Kluczowa cecha idempotentności, potwierdzona statusem changed=0 przy powtórnym uruchomieniu skryptu, gwarantuje bezpieczeństwo konfiguracji poprzez dążenie do stanu docelowego zamiast bezwarunkowego wykonywania instrukcji. Przeprowadzone testy z wyłączeniem sieci wykazały skuteczność mechanizmu chroniącego infrastrukturę przed stanami nieustalonymi poprzez natychmiastowe przerwanie pracy po wykryciu statusu unreachable. Ostatecznie, refaktoryzacja procesu do postaci dedykowanej roli zautomatyzowała pełen cykl wdrożeniowy aplikacji NestJS w środowisku izolowanym, udowadniając, że podejście IaC zapewnia pełną powtarzalność i wygodne zarządzanie artefaktami kontenerowymi.

deploy_flat.yml:
```yml
- name: zarządzanie artefaktem i wdrożenie
  hosts: Endpoints
  become: true
  tasks:

    # 1. sanity check
    - name: "Sanity check: sprawdzenie wolnego miejsca"
      ansible.builtin.shell: "df -h / | awk 'NR==2 {print $4}'"
      register: disk_space
      ignore_errors: yes

    - name: "Wynik Sanity Check"
      ansible.builtin.debug:
        msg: "Dostępne miejsce na Target: {{ disk_space.stdout }}. Kontynuuję..."

    # 2. instalacja dockera
    - name: "Instalacja pakietów bazowych i python3-docker"
      ansible.builtin.apt:
        name: [ca-certificates, curl, gnupg, python3-docker]
        state: present
        update_cache: yes

    - name: "Konfiguracja repozytorium Dockera"
      block:
        - name: Katalog na klucze
          ansible.builtin.file: { path: /etc/apt/keyrings, state: directory, mode: '0755' }
        - name: Pobierz klucz GPG
          ansible.builtin.get_url: { url: "https://download.docker.com/linux/ubuntu/gpg", dest: "/etc/apt/keyrings/docker.asc" }
        - name: Dodaj repo
          ansible.builtin.apt_repository:
            repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
            state: present

    - name: "Instalacja Docker Engine"
      ansible.builtin.apt:
        name: [docker-ce, docker-ce-cli, containerd.io]
        state: present

    # 3. wdrożenie artefaktu (Deploy)
    - name: "Przesłanie artefaktu (.tar) z /tmp/ sterującej na /tmp/ docelowej"
      ansible.builtin.copy:
        src: /tmp/moja-app.tar
        dest: /tmp/moja-app.tar
        mode: '0644'

    - name: "Załadowanie obrazu do Dockera na Target"
      ansible.builtin.shell: "docker load < /tmp/moja-app.tar"

    - name: "Uruchomienie kontenera aplikacji"
      community.docker.docker_container:
        name: moja-aplikacja-final
        image: moja-app-test:latest
        state: started
        restart_policy: always
        published_ports:
          - "3000:3000"

    # 4. weryfikacja łączności
    - name: "Weryfikacja: Czy aplikacja odpowiada na porcie 3000?"
      ansible.builtin.uri:
        url: "http://localhost:3000"
        status_code: 200
      register: result
      until: result.status == 200
      retries: 5
      delay: 5

    # 5. oczyszczanie
    - name: "Oczyszczanie: Usunięcie pliku .tar z maszyny docelowej"
      ansible.builtin.file:
        path: /tmp/moja-app.tar
        state: absent
```

inventory.ini:
```bash
[Orchestrators]
    ansible-control ansible_connection=local

[Endpoints]
    ansible-target ansible_user=ansible

```

deploy_app/tasks/main.yml:
```bash
- name: "Sanity check: Sprawdzenie wolnego miejsca"
  ansible.builtin.shell: "df -h / | awk 'NR==2 {print $4}'"
  register: disk_space
  ignore_errors: yes

- name: "Wynik Sanity Check"
  ansible.builtin.debug:
    msg: "Dostępne miejsce na Target: {{ disk_space.stdout }}. Kontynuuję..."

- name: "Instalacja pakietów bazowych i python3-docker"
  ansible.builtin.apt:
    name: [ca-certificates, curl, gnupg, python3-docker]
    state: present
    update_cache: yes

- name: "Katalog na klucze"
  ansible.builtin.file: { path: /etc/apt/keyrings, state: directory, mode: '0755' }

- name: "Pobierz klucz GPG"
  ansible.builtin.get_url: { url: "https://download.docker.com/linux/ubuntu/gpg", dest: "/etc/apt/keyrings/docker.asc" }

- name: "Dodaj repo"
  ansible.builtin.apt_repository:
    repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
    state: present

- name: "Instalacja Docker Engine"
  ansible.builtin.apt:
    name: [docker-ce, docker-ce-cli, containerd.io]
    state: present

- name: "Przesłanie artefaktu (.tar) z /tmp/ sterującej na /tmp/ docelowej"
  ansible.builtin.copy:
    src: /tmp/moja-app.tar
    dest: /tmp/moja-app.tar
    mode: '0644'

- name: "Załadowanie obrazu do Dockera na Target"
  ansible.builtin.shell: "docker load < /tmp/moja-app.tar"

- name: "Uruchomienie kontenera aplikacji"
  community.docker.docker_container:
    name: moja-aplikacja-final
    image: moja-app-test:latest
    state: started
    restart_policy: always
    published_ports:
      - "3000:3000"

- name: "Weryfikacja: Czy aplikacja odpowiada na porcie 3000?"
  ansible.builtin.uri:
    url: "http://localhost:3000"
    status_code: 200
  register: result
  until: result.status == 200
  retries: 5
  delay: 5

- name: "Oczyszczanie: Usunięcie pliku .tar z maszyny docelowej"
  ansible.builtin.file:
    path: /tmp/moja-app.tar
    state: absent
```

deploy_app/meta/main.yml:
```bash
galaxy_info:
  author: Ola Duda
  description: automatyzacja wdrożenia NestJS
  company: AGH
  license: MIT
  min_ansible_version: 2.1
  platforms:
   - name: Ubuntu
     versions:
     - all

  galaxy_tags: []

dependencies: []

```

site.yml:
```bash
- name: wdrożenie przez rolę
  hosts: Endpoints
  become: true
  roles:
    - deploy_app
```

--------------------------------------------------------------------------------------

## Laboratorium 9 - Pliki odpowiedzi dla wdrożeń nienadzorowanych
### Cel
Celem laboratorium było utworzenie źródła instalacji nienadzorowanej dla systemu operacyjnego hostującego oprogramowanie, konfiguracja pliku odpowiedzi Kickstart (.cfg) oraz automatyczne wdrożenie aplikacji kontenerowej bezpośrednio podczas inicjalizacji systemu.

### Realizacja zadań
1. Przygotowanie środowiska sieciowego i pliku odpowiedzi

Do realizacji zadania wykorzystałam Fedora Server 44. Początkowy plik odpowiedzi (anaconda-ks.cfg) pobrałam z systemu, przeniosłam go do katalogu użytkownika i zmodyfikowałam pod kątem automatyzacji: dodałam definicje repozytoriów zwierciadeł (mirrors) dla wersji 44, wymusiłam formatowanie dysku (clearpart --all --initlabel) oraz zmieniłam hostname na fedora-devops.

![alt text](../Sprawozdanie9/image.png)
![alt text](../Sprawozdanie9/image-1.png)
![alt text](../Sprawozdanie9/image-2.png)

2. Uruchomienie instalacji nienadzorowanej

Dostarczanie pliku ks.cfg maszynie klienckiej zrealizowałam lokalnie przy użyciu wbudowanego w język Python serwera HTTP (python3 -m http.server). Wskazałam plik konfiguracyjny w parametrach bootowania instalatora, a poprawność komunikacji i pobrania pliku przez nową instancję potwierdziłam kodem statusu HTTP 200.

![alt text](../Sprawozdanie9/image-3.png)
![alt text](../Sprawozdanie9/image-4.png)
![alt text](../Sprawozdanie9/image-5.png)

3. Automatyzacja wdrożenia aplikacji

Proces publikacji uprościłam poprzez wdrożenie kontenera hello-world zamiast aplikacji samodzielnej. W sekcji %post pliku Kickstart zaimplementowałam uruchamianie Dockera (systemctl enable docker), skrypt startowy /usr/local/bin/start-fedora-app.sh z opóźnieniem sleep 10 na inicjalizację sieci oraz automatyczne wywołanie skryptu przy starcie poprzez harmonogram cron (@reboot). Całość procesu kończy dyrektywa reboot wywoływana automatycznie po zakończeniu pracy instalatora.

![alt text](../Sprawozdanie9/image-11.png)
![alt text](../Sprawozdanie9/image-12.png)
![alt text](../Sprawozdanie9/image-13.png)

4. Rozwiązywanie problemów sieciowych

Podczas testów instalator zgłaszał błędy braku łączności i braku możliwości sparsowania pliku konfiguracyjnego. Problemem okazało się restrykcyjne zachowanie instalatora sieciowego wobec szyfrowanych połączeń HTTPS w środowisku testowym. Po zmianie adresów URL repozytoriów i pliku odpowiedzi na protokół HTTP, serwer poprawnie odebrał zapytanie GET, a proces instalacji zakończył się sukcesem.

![alt text](../Sprawozdanie9/image-14.png)
![alt text](../Sprawozdanie9/image-15.png)
![alt text](../Sprawozdanie9/image-16.png)
![alt text](../Sprawozdanie9/image-17.png)

### Wnioski cząstkowe
Laboratorium pokazało, że odpowiednio skonfigurowany plik Kickstart pozwala postawić system całkowicie od zera bez klikania czegokolwiek w instalatorze. Największą trudnością okazały się wymagania instalatora sieciowego Fedory, który odrzucał bezpieczne linki HTTPS i ruszył dopiero po zmianie protokołów na zwykłe HTTP. Ciekawym rozwiązaniem z którym zapoznałam się na zajęciach było wykorzystanie sekcji %post do automatycznego włączenia Dockera oraz wdrożenie skryptu z opóźnieniem do crona (@reboot), dzięki czemu kontener z aplikacją odpala się sam zaraz po starcie maszyny.

Finalny plik ks.cfg:
```bash
# Generated by Anaconda 44.30
# Keyboard layouts
keyboard --vckeymap=pl --xlayouts='pl'
# System language
lang pl_PL.UTF-8

# Adres bazowy dla instalatora Fedory 44
url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64

# Repozytorium z aktualizacjami pakietów
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

%packages
@^server-product-environment
moby-engine
docker-compose
%end

# System authorization information
authselect enable-feature with-fingerprint

# Run the Setup Agent on first boot
firstboot --enable

# Generated using Blivet version 3.13.2
ignoredisk --only-use=sda
autopart
# Partition clearing information
clearpart --all --initlabel

network --hostname=fedora-devops

# System timezone
timezone Europe/Warsaw --utc

# Root password
rootpw --iscrypted xxx
user --groups=wheel --name=ansible --password=xxx --iscrypted --gecos="ansible"

%post --log=/var/log/anaconda-post-install.log

# Włączenie Dockera
systemctl enable docker

# Tworzenie skryptu uruchamiającego aplikację
cat <<EOF > /usr/local/bin/start-fedora-app.sh
#!/bin/bash
# Czekanie na sieć
sleep 10
docker run -d --name fedora-app hello-world
EOF

chmod +x /usr/local/bin/start-fedora-app.sh

# Uruchomienie skryptu przy każdym starcie systemu
cat <<EOF > /etc/cron.d/fedora-app-cron
@reboot root /usr/local/bin/start-fedora-app.sh

EOF

%end

# Automatyczny restart po instalacji
reboot
```

--------------------------------------------------------------------------------------

## Laboratorium 10 - Wdrażanie na zarządzalne kontenery: Kubernetes(1)
### Cel
Celem laboratorium było postawienie i konfiguracja lokalnego klastra Kubernetes za pomocą narzędzia Minikube, umieszczenie tam mojej aplikacji webowej oraz sprawdzenie w praktyce, jak działa automatyczne wdrażanie, skalowanie i rozdzielanie ruchu za pomocą obiektów typu Deployment i Service.

### Realizacja zadań
1. Instalacja i konfiguracja lokalnego klastra Kubernetes

Prace rozpoczęłam od instalacji narzędzia Minikube, służącego do uruchamiania lokalnego klastra Kubernetes. Po zakończeniu instalacji usunęłam pobrane pliki tymczasowe, aby zachować porządek w systemie.

![alt text](../Sprawozdanie10/image.png)

Bezpieczeństwo instalacji zapewniłam poprzez wykorzystanie izolacji środowiskowej. Wybór dockera sprawia, że cały klaster Kubernetes funkcjonuje wewnątrz odrębnego, odizolowanego kontenera oraz dedykowanej sieci w maszynie wirtualnej.

![alt text](../Sprawozdanie10/image-4.png)

W celu optymalizacji pracy i zachowania kompatybilności z wbudowanym mechanizmem Minikube, w pliku konfiguracyjnym terminala (.bashrc) utworzyłam alias dla narzędzia kubectl. Sesję odświeżyłam poleceniem source ~/.bashrc.

![alt text](../Sprawozdanie10/image-2.png)

Następnie zainicjalizowałam Kubernetes Dashboard, czyli graficzny panel sterowania.

![alt text](../Sprawozdanie10/image-6.png)

2. Przygotowanie i analiza obrazu kontenerowego

Do wdrożenia wybrałam serwer Nginx, spełniający wymaganie Kubenertesa dotyczące uruchamiania procesów działających w sposób ciągły (wcześniej używałam prostego hello-world,  który działał w sposób nieciągły). Przygotowałam plik źródłowy index.html oraz Dockerfile, który zamienia domyślną konfigurację startową serwera.

index.html oraz Dockerfile:

![alt text](../Sprawozdanie10/image-7.png)
![alt text](../Sprawozdanie10/image-8.png)

Aby uniknąć konieczności wypychania obrazu do Docker Huba, przekierowałam zmienne środowiskowe lokalnego terminala na wewnętrzny silnik Dockera działający wewnątrz Minikube. W tym środowisku zbudowałam obraz app-lab10:v1.

![alt text](../Sprawozdanie10/image-9.png)
![alt text](../Sprawozdanie10/image-10.png)

3. Wdrożenie manualne i ekspozycja usług

Na początku uruchomiłam aplikację w sposób imperatywny. Weryfikacja pokazała status Running dla nowo utworzonego poda.

![alt text](../Sprawozdanie10/image-11.png)
![alt text](../Sprawozdanie10/image-14.png)

Aby przetestować działanie aplikacji poza siecią klastra, wykonałam przekierowanie portów (port forwarding) na port lokalny. Komunikacja HTTP potwierdziła poprawne przesyłanie zmodyfikowanej strony internetowej.

![alt text](../Sprawozdanie10/image-13.png)
![alt text](../Sprawozdanie10/image-12.png)

4. Deklaratywne zarządzanie infrastrukturą (IaC) i skalowanie

W celu przejścia na paradygmat deklaratywny, stworzyłam plik konfiguracyjny deployment.yaml, w którym zdefiniowałam stan infrastruktury składający się z 4 replik aplikacji. Wdrożenie uruchomiłam komendą kubectl apply.

![alt text](../Sprawozdanie10/image-15.png)
![alt text](../Sprawozdanie10/image-16.png)

Stan wdrożenia zweryfikowałam za pomocą mechanizmu rollout status, który potwierdził poprawne uruchomienie wszystkich 4 podów. Następnie wyeksponowałam deployment jako obiekt typu Service, zapewniając automatyczny load balancing pomiędzy replikami.

![alt text](../Sprawozdanie10/image-17.png)
![alt text](../Sprawozdanie10/image-18.png)
![alt text](../Sprawozdanie10/image-19.png)
![alt text](../Sprawozdanie10/image-20.png)

Na zakończenie zweryfikowałam stan klastra w Kubernetes Dashboard. Panel wskazał łącznie 5 działających podów - dalej poprawnie działały 4 pody kontrolowane deklaratywnie przez Deployment oraz jeden pod uruchomiony wcześniej manualnie.

![alt text](../Sprawozdanie10/image-21.png)

### Wnioski cząstkowe
Laboratorium udowodniło wysoką efektywność Minikube jako izolowanego środowiska testowego, pozwalającego na symulację zachowania klastra produkcyjnego przy minimalnch zasobach. Kluczowym wnioskiem z laboratorium jest przewaga podejścia deklaratywnego (pliki YAML) nad poleceniami imperatywnymi. Zdefiniowanie IAC zapewnia powtarzalność środowiska oraz umożliwia automatyczne zarządzanie cyklem życia aplikacji przez Kubernetes. Wykorzystanie obiektów typu Deployment oraz Service pokazało mechanizmy wysokiej dostępności.

Treść Dockerfile:
 ```Dockerfile
 FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
 ```

Treść deployment.yaml:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-lab10-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: app-lab10-multipod
  template:
    metadata:
      labels:
        app: app-lab10-multipod
    spec:
      containers:
      - name: nginx-container
        image: app-lab10:v1
        ports:
        - containerPort: 80
```

--------------------------------------------------------------------------------------

## Laboratorium 11 - Wdrażanie na zarządzalne kontenery: Kubernetes (2)
### Cel
Celem laboratorium było dalsze zapoznanie się z wdrażaniem aplikacji na zarządzalne kontenery i nauka zaawansowanych funkcji Kubenertesa, takich jak skalowanie podów, testowanie strategii (Recreate, Rolling Update, Canary) oraz wycofywanie zmian w przypadku wdrożenia wadliwego obrazu.

### Realizacja zadań
1. Przygotowanie nowych wersji obrazu

Żeby przetestować, jak Kubernetes radzi sobie z aktualizacjami i błędami, przygotowałam trzy różne wersje lokalnego obrazu aplikacji:

- Wersja 1: Obraz bazowy z poprzedniego laboratorium (serwer Nginx ze stroną)
- Wersja 2: Zaktualizowana aplikacja z nową treścią w pliku index.html
- Wersja bad: Celowo uszkodzony obraz (Dockerfile.bad), w którym znajduje się błędna komenda startowa CMD. Uruchomienie tego kontenera miało wywołać błąd systemu, żeby sprawdzić mechanizmy obronne Kubernetesa

![alt text](../Sprawozdanie11/image.png)
![alt text](../Sprawozdanie11/image-1.png)

Żeby Kubernetes widział moje obrazy bez wrzucania ich do internetu, połączyłam terminal z silnikiem Dockera wewnątrz Minikube poleceniem eval $(minikube docker-env). Dzięki temu obrazy od razu budowały się wewnątrz klastra i nie musiałam ich ręcznie przesyłać.

2. Zmiany w deploymencie (skalowanie)

Prace zaczęłam od sprawdzenia konfiguracji w pliku deployment.yaml.

Pierwsza wersja pliku deployment.yaml:

![alt text](../Sprawozdanie11/image-2.png)

Następnie zaczęłam testować klaster i jak reaguje na dynamiczne zmiany liczby replik:

- Zwiększenie liczby replik do 8:

![alt text](../Sprawozdanie11/image-3.png)
![alt text](../Sprawozdanie11/image-4.png)

- Zmniejszenie liczby replik do 1: Zgodnie z oczekiwaniami, jeden pod został w stanie Running, a reszta znajdowała się w stanie Terminating.

![alt text](../Sprawozdanie11/image-5.png)

- Zmniejszenie liczby replik do 0: Wszystkie pody zostały całkowicie skasowane.

![alt text](../Sprawozdanie11/image-6.png)

Ponowne zwiększenie liczby replik, tym razem do 4:

![alt text](../Sprawozdanie11/image-7.png)

3. Testowanie aktualizacji i obsługa awarii

Następnie sprawdziłam, co się stanie, gdy w pliku wdrożenia zmienie wersje obrazów aplikacji:

- Wgranie nowej wersji (Wersja 2):

![alt text](../Sprawozdanie11/image-8.png)
![alt text](../Sprawozdanie11/image-9.png)

- Powrót do starszej wersji - Rollback: Zamiast edytować plik ręcznie, użyłam polecenia minikubctl rollout undo deployment/app-lab10-deployment, co cofnęło zmiany.

![alt text](../Sprawozdanie11/image-10.png)

Wdrożenie wadliwego obrazu (bad) w celu sprawdzenia reakcji klastra:

![alt text](../Sprawozdanie11/image-11.png)

Obserwacja stanów podów podczas awarii:

![alt text](../Sprawozdanie11/image-12.png)
![alt text](../Sprawozdanie11/image-13.png)

Status ErrImagePull oznacza, że klaster szuka obrazu w zewnętrznym rejestrze, zamiast brać go z lokalnego środowiska Minikube. Błąd ImagePullBackOff oznacza, że obraz pobrał się poprawnie, ale przestał działać przez błędną komendę startową CMD.
Po przetestowaniu tych wariantów szybko przywróciłam działającą wersję aplikację komendą rollout undo. Pody wróciły do stanu Running.

![alt text](../Sprawozdanie11/image-14.png)
![alt text](../Sprawozdanie11/image-15.png)

4. Skrypt weryfikacyjny

Skrypt sprawdzający, czy wdrożenie nastąpiło w ciągu 60 sekund:

![alt text](../Sprawozdanie11/image-16.png)

Test działania skryptu - udany dla dobrej wersji oraz celowo błędny dla wersji bad:

![alt text](../Sprawozdanie11/image-17.png)
![alt text](../Sprawozdanie11/image-18.png)

5. Wdrażanie za pomocą różnych strategii

Zanim włączyłam testy strategii, przygotowałam plik service.yaml, żeby mieć jeden stabilny punkt dostępu (serwis) rozdzielający ruch na pody.

![alt text](../Sprawozdanie11/image-19.png)
![alt text](../Sprawozdanie11/image-20.png)

- Strategia Recreate: Ta strategia działa bezwzględnie - najpierw zabija wszystkie stare pody naraz (Terminating), przez co strona na moment przestaje działać, a dopiero potem stawia nowe pody od zera.

![alt text](../Sprawozdanie11/image-21.png)
![alt text](../Sprawozdanie11/image-22.png)
![alt text](../Sprawozdanie11/image-23.png)

- Strategia Rolling Update: Wymienia pody partiami. Parametr 'maxUnavailable' decyduje, ile podów może maksymalnie nie działać podczas aktualizacji, a 'maxSurge' określa, ile nadprogramowych podów klaster może chwilowo stworzyć.

![alt text](../Sprawozdanie11/image-24.png)
![alt text](../Sprawozdanie11/image-25.png)

Podczas zmiany obrazu dla 5 replik widoczny był mieszany stan: klaster włączył jeden nadprogramowy kontener (ContainerCreating) i jednocześnie wyłączał dwa stare pody (Terminating). Przez cały ten czas reszta podów normalnie obsługiwała ruch, więc użytkownicy nie odczuli żadnego przestoju.

- Strategia Canary Deployment: Polega na wypuszczeniu jednego nowego poda obok stabilnie działającej starej wersji, żeby sprawdzić, czy wszystko z nim w porządku. Zrobiłam to poprzez uruchomienie dwóch osobnych wdrożeń (plików YAML), które mają tę samą główną etykietę.

Najpierw przywróciłam pierwszy deployment.yaml:

![alt text](../Sprawozdanie11/image-26.png)

Następnie stworzyłam canary-deployment.yaml z jedną repliką testową:

![alt text](../Sprawozdanie11/image-27.png)

Dzięki wspólnej etykiecie jeden serwis automatycznie kierował część ruchu na nowego poda testowego, nie ruszając głównych podów. Wszystkie pody działały w stanie Running.

6. Powiązanie środowiska z Docker Hubem

Na koniec przygotowałam środowisko na kolejne laboratoria i powiązałam maszynę z zewnętrznym docker hubem. Upewniłam się, że system widzi moje konto.

![alt text](../Sprawozdanie11/image-28.png)

Wpisałam komendę eval $(minikube docker-env --unset), żeby terminal przestał patrzeć wyłącznie na wnętrze Minikube, a zaczął widzieć moje oficjalne konto. Zbudowałam obraz ze swoim loginem i wysłałam go poleceniem docker push do publicznego repozytorium w docker hubie.

![alt text](../Sprawozdanie11/image-29.png)
![alt text](../Sprawozdanie11/image-30.png)

### Wnioski cząstkowe
Laboratorium pokazało, jak działają zaawansowane mechanizmy orkiestracji w Kubernetesie. Testy ze skalowaniem udowodniły, że wystarczy zmienić jedno ustawienie w konfiguracji, a klaster sam wykona resztę pracy. Na zajęciach miałam także okazję zobaczyć porównanie strategii aktualizacji: Recreate powoduje przestój, co nie jest najlepszym rozwiązaniem w pracy, natomiast Rolling Update i Canary pozwalają zmienić kod aplikacji bezprzestojowo. Największym plusem Kubenertesa okazała się jego odporność na błędy - przy wdrożeniu celowo błędnego obrazu, mechanizm aktualizacji sam się zablokował i nie zabił starej, działającej aplikacji, a polecenie rollout undo pozwoliło szybko cofnąć całą operację i przywrócić porządek w klastrze bez żadnych strat.

Plik Dockerfile:
```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```
Plik Dockerfile.bad:
```Dockerfile
FROM app-lab10:v1
CMD ["to-wywola-blad-systemu"]
```
deployment.yaml (edytowany w trakcie laboratorium):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-lab10-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-lab10-multipod
  template:
    metadata:
      labels:
        app: app-lab10-multipod
    spec:
      containers:
      - name: nginx-container
        image: app-lab10:v1
        ports:
        - containerPort: 80
```
canary-deployment.yaml:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-lab10
  template:
    metadata:
      labels:
        app: app-lab10
        version: canary
    spec:
      containers:
        - name: nginx
          image: app-lab10:v2
          ports:
            - containerPort: 80
```

index.html:
```html
<h1>Lab 11 - nowa wersja mojej aplikacji</h1>
```

service.yaml:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: NodePort
  selector:
    app: app-lab10
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

weryfikuj.sh:
```sh
#!/bin/bash

echo "Start weryfikacji wdrożenia aplikacji"
echo "Sprawdzam status deploymentu (Limit czasu: 60 sekund)"

# zastosowanie minikube kubectl, aby skrypt działał niezależnie od konfiguracji aliasów
minikube kubectl -- rollout status deployment/app-lab10-deployment --timeout=60s

# sprawdzenie kodu wyjścia poprzedniego polecenia
if [ $? -eq 0 ]; then
    echo "SUKCES: Wdrożenie zakończyło się pomyślnie w ciągu 60 sekund"
    exit 0
else
    echo "BŁĄD: Wdrożenie przekroczyło limit 60 sekund lub zakończyło się awarią podów"
    exit 1
fi
```

--------------------------------------------------------------------------------------

## Laboratorium 12 - Wdrażanie na zarządzalne kontenery w chmurze (Azure)
### Cel
Zapoznanie się z procesem wdrażania kontenerów w Azure (platformie chmurowej).

### Realizacja zadań
1. Przygotowanie kontenera i środowiska

- Zweryfikowałam obecność obrazu aplikacji w publicznym repozytorium Docker Hub

![alt text](../Sprawozdanie12/image.png)

- Zalogowałam się do portalu Azure, zainstalowałam Azure CLI na maszynie wirtualnej i przeprowadziłam uwierzytelnienie do platformy (az login --use-device-code)

![alt text](../Sprawozdanie12/image-1.png)
![alt text](../Sprawozdanie12/image-4.png)

2. Konfiguracja i rozwiązanie problemów z subskrypcją

- Zdefiniowałam zmienne środowiskowe polepszające pracę oraz utworzyłam grupę zasobów

![alt text](../Sprawozdanie12/image-5.png)
![alt text](../Sprawozdanie12/image-6.png)

- Podczas próby wdrożenia kontenera wystąpił błąd związany z nieodpowiednim regionem dla kontenera:

![alt text](../Sprawozdanie12/image-7.png)

Szukałam problemu: zmieniłam środowisko na bezpośredni terminal w Azure, przetestowałam lokacje Europy, USA, Polski, zmieniłam obraz na hhtpd jednak żadne zmiany nie zadziałały.

![alt text](../Sprawozdanie12/image-8.png)

- Po weryfikacji dostępnych dla konta lokalizacji:

![alt text](../Sprawozdanie12/image-9.png)

Ostatecznie utworzyłam nową grupę zasobów oraz pomyślnie wdrożyłam kontener w regionie Sweden Central, uzyskując status Succeeded

![alt text](../Sprawozdanie12/image-10.png)
![alt text](../Sprawozdanie12/image-11.png)

3. Weryfikacja działania i czyszczenie środowiska

- Poprawne uruchomienie aplikacji potwierdziłam przez pobranie logów kontenera i ogólne pokazanie działania projektu:

![alt text](../Sprawozdanie12/image-12.png)
![alt text](../Sprawozdanie12/image-13.png)
![alt text](../Sprawozdanie12/image-14.png)

- Po zakończeniu ćwiczenia, w celu uniknięcia naliczania opłat i zużywania tokenów Azure, usunęłam cały kontener oraz powiązaną grupę zasobów

![alt text](../Sprawozdanie12/image-15.png)
![alt text](../Sprawozdanie12/image-16.png)

### Wnioski cząstkowe
Laboratorium wykazało, że chmura Azure pozwala na błyskawiczne uruchomienie aplikacji kontenerowej bez konieczności zarządzania infrastrukturą serwerową. Proces ten wymaga jednak monitorowania ograniczeń posiadanej subskrypcji oraz usuwania zasobów po zakończeniu pracy, aby zapobiec niekontrolowanemu zużyciu środków finansowych.

--------------------------------------------------------------------------------------

## Wnioski
Zrealizowana trzecia część laboratoriów pozwoliła na dokładne zapoznanie się z nowoczesnymi praktykami DevOps w zakresie automatyzacji, orkiestracji oraz wdrażania systemów i aplikacji. Dzięki wykorzystaniu narzędzia Ansible zautomatyzowałam zarządzanie konfiguracją oraz proces dystrybucji kodu na maszyny zdalne, co wyeliminowało potrzebę manualnego wykonywania powtarzalnych procedur. Implementacja nienadzorowanej instalacji systemu operacyjnego za pomocą plików odpowiedzi (laboratorium z Fedorą) pokazała, jak skutecznie i powtarzalnie przygotować środowisko pod utrzymywanie odpowiedniego oprogramowania od momentu pierwszego uruchomienia. Praca z platformami chmurowymi Microsoft Azure oraz Kubernetesem przybliżyła mi mechanizmy skalowania, monitorowania logów oraz zarządzania cyklem życia kontenerów. Przetestowanie strategii aktualizacji aplikacji, takich jak Rolling Update czy Canary Deployment, udowodniło, jak kluczowa w pracy jest możliwość ciągłego (bez przerw) wdrażania nowych wersji oprogramowania przy jednoczesnym zachowaniu pełnej kontroli nad stabilnością systemu.