# Zbiorcze Sprawozdanie z Laboratoriów: Automatyzacja Wdrożeń (Ansible & Kickstart)
**Zajęcia:** Laboratorium 08 oraz 09
**Autor:** Krzysztof Mamcarz (KM414315)

---

## Wstęp
Celem zrealizowanych laboratoriów było zapoznanie się z nowoczesnymi technikami automatyzacji wdrożeń systemów operacyjnych oraz oprogramowania. Prace podzielono na dwa etapy: zarządzanie istniejącą infrastrukturą przy użyciu narzędzia **Ansible** (Lab 08) oraz zautomatyzowane przygotowanie od zera środowiska operacyjnego za pomocą plików odpowiedzi **Kickstart** dla systemu Fedora (Lab 09).

---

## CZĘŚĆ I: Laboratorium 08 – Zdalne zarządzanie i konfiguracja (Ansible)

### 1. Inwentaryzacja środowiska (Inventory)
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

### 2. Wykonywanie procedur za pomocą Playbooka
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

Wykonanie playbooka (`ansible-playbook -i hosts.ini playbook.yml`) potwierdziło kluczową właściwość Ansible – idempotentność. Po ponownym uruchomieniu skryptu, zadania instalacyjne otrzymały status `ok` (brak niepotrzebnych zmian), a jedynie moduły wymuszające restart oznaczono jako `changed`.

Logikę instalacji oprogramowania (silnika Docker) oraz uruchomienia środowiska testowego Nginx zaszyto w głównym pliku zadań stworzonej roli. Skrypt uwzględnia mechanizm wyłapywania błędów (sanity check), instalując Dockera jedynie w przypadku jego braku na maszynie docelowej.


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
Rolę zaimportowano i uruchomiono prostym Playbookiem wdrażającym (deploy.yml). Proces przebiegł bezbłędnie, poprawnie obsługując wyjątek braku Dockera, instalując wymagane pakiety, nawiązując poprawne połączenie HTTP na porcie 8080, a następnie czyszcząc utworzone środowisko (usunięcie kontenera testowego).

## CZĘŚĆ II: Laboratorium 09 – Instalacje nienadzorowane (Kickstart)

### 1. Automatyzacja instalacji systemu Fedora
Drugim etapem była automatyzacja od podstaw. Przygotowano plik odpowiedzi dla instalatora Anaconda, który całkowicie znosi konieczność ręcznej interakcji operatora podczas instalacji systemu Fedora.

Plik określa ustawienia regionalne, politykę formatowania dysku (`clearpart`), ustawienia sieci oraz zautomatyzowaną konfigurację repozytoriów. Kluczowym elementem było zaimplementowanie dyrektywy `%post`, która odpowiadała za post-konfigurację systemu (włączenie usługi Docker i przygotowanie skryptów uruchomieniowych aplikacji).

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

### 2. Proces wdrożenia i weryfikacja

Plik odpowiedzi został udostępniony w wewnętrznej sieci wirtualnej z poziomu stacji roboczej za pomocą wbudowanego serwera HTTP:

```bash
python3 -m http.server 8000
```
Podczas rozruchu docelowej maszyny wirtualnej (bootowanie z obrazu ISO Fedory) zmodyfikowano parametry programu rozruchowego GRUB, dodając ścieżkę wskazującą na plik Kickstart:

```bash
inst.ks=http://<IP_SERWERA>:8000/ks.cfg
```

Instalator pomyślnie zaciągnął konfigurację, co zostało potwierdzone kodem `HTTP 200 GET` w logach serwera Python. Proces podzielenia dysku, pobrania pakietów (w tym środowiska wirtualizacji moby-engine) oraz wdrożenia skryptów z sekcji `%post` odbył się całkowicie nienadzorowanie.

Po automatycznym restarcie maszyny zweryfikowano poprawne logowanie na użytkownika `root`. Aby udowodnić poprawność całego łańcucha automatyzacji, wydano poniższe polecenia:

```bash 
[root@fedora-auto ~]# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS
54e148fddb00   nginx:latest   "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8080->80/tcp
```

```bash
[root@fedora-auto ~]# curl -s http://localhost:8080 | grep title
<title>Welcome to nginx!</title>
```

Zwrócony kod powitalny serwera Nginx ostatecznie potwierdza skuteczność wdrożenia nienadzorowanego, w którym maszyna nie tylko sama zainstalowała system operacyjny, ale od razu udostępniła wymagane przez projekt środowisko.

Podsumowanie: Powyższe prace udowodniły znaczną skuteczność podejścia Infrastructure as Code (IaC), w którym ręczne konfiguracje zostały całkowicie zastąpione przewidywalnymi i odtwarzalnymi skryptami deweloperskimi.


