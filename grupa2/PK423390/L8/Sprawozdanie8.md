# Sprawozdanie 8 – Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

---

## 1. Instalacja Ansible i konfiguracja SSH

Ansible pracuje w modelu bezagentowym - do zarządzania systemem docelowym wykorzystuje wyłącznie protokół SSH. Wymaga to poprawnej konfiguracji zaufania między maszynami.

Wykonane kroki:

- Na głównej maszynie wirtualnej zainstalowano Ansible z repozytorium dystrybucji Ubuntu.
- Klucz publiczny przesłano na maszynę docelową (`ansible-target`, IP: 192.168.0.101) za pomocą `ssh-copy-id`, co umożliwia logowanie bez podawania hasła.

```bash
ssh-copy-id ansible@192.168.0.101
```

![ssh-copy-id](IMG/Zrzut%20ekranu%202026-05-15%20061311.png)
![ansible-version](IMG/Zrzut%20ekranu%202026-05-15%20062003.png)

---

## 2. Inwentaryzacja systemów

Inwentarz w Ansible to baza danych o hostach, którymi zarządzamy. Stworzono plik `inventory.ini` z dwiema grupami hostów:

```ini
[Orchestrators]
localhost ansible_connection=local

[Endpoints]
192.168.0.101 ansible_user=ansible
```

- Grupa `Orchestrators` zawiera maszynę sterującą. Parametr `ansible_connection=local` omija stos SSH przy wykonywaniu zadań lokalnie.
- Grupa `Endpoints` zawiera maszynę docelową z użytkownikiem `ansible`.

Weryfikacja łączności za pomocą modułu `ping`:

```bash
ansible all -i inventory.ini -m ping
```

Moduł `ping` sprawdza zdolność Ansible do zalogowania się przez SSH, uruchomienia skryptu Pythona i odebrania odpowiedzi JSON. Obie maszyny zwróciły status `SUCCESS`.

![ansible-ping](IMG/Zrzut%20ekranu%202026-05-15%20062304.png)

---

## 3. Zdalne wywoływanie procedur

### 3.1. Kopiowanie pliku inwentaryzacji

Plik inwentaryzacji skopiowano na maszynę docelową za pomocą modułu `copy`:

```bash
ansible Endpoints -i inventory.ini -m copy -a "src=inventory.ini dest=/tmp/inventory.ini"
```

Pierwsze uruchomienie zwróciło status `CHANGED` - plik został przesłany. Ponowne uruchomienie zwróciło `ok` - Ansible wykrył że plik już istnieje i jest identyczny.

![kopiowanie-inventory](IMG/Zrzut%20ekranu%202026-05-15%20062539.png)

### 3.2. Aktualizacja pakietów

```bash
ansible Endpoints -i inventory.ini -m apt -a "update_cache=yes" -b -K
```

![apt-update](IMG/Zrzut%20ekranu%202026-05-15%20063343.png)

### 3.3. Restart usług

Zrestartowano usługę `sshd` na maszynie docelowej. Usługa `rngd` nie była zainstalowana na maszynie docelowej, więc Ansible zgłosił błąd `FAILED` z komunikatem `Could not find the requested service rngd: host`, ale dzięki parametrowi `ignore_errors: true` w playbooku pipeline nie został przerwany.

```bash
ansible Endpoints -i inventory.ini -m service -a "name=ssh state=restarted" -b -K
```

![restart-sshd](IMG/Zrzut%20ekranu%202026-05-15%20063545.png)

---

## 4. Playbook - zdalne wywoływanie procedur systemowych

Wszystkie powyższe operacje zebrano w playbooku `playbook_system.yml`:

```yaml
---
- name: Zdalne wywolywanie procedur systemowych
  hosts: Endpoints
  become: true
  tasks:
    - name: 1. Wyslij zadanie ping do wszystkich maszyn
      ping:

    - name: 2. Skopiuj plik inwentaryzacji na maszyne Endpoints
      copy:
        src: inventory.ini
        dest: /tmp/inventory.ini

    - name: 3. Ponow operacje kopiowania (porownaj roznice)
      copy:
        src: inventory.ini
        dest: /tmp/inventory.ini

    - name: 4. Zaktualizuj pakiety w systemie
      apt:
        update_cache: yes

    - name: 5. Zrestartuj uslugi sshd
      service:
        name: ssh
        state: restarted

    - name: 6. Zrestartuj uslugi rngd
      service:
        name: rngd
        state: restarted
      ignore_errors: yes
```

Wynik uruchomienia playbooka - zadanie 3 zwróciło `ok` zamiast `changed`, co potwierdza idempotentność. Zadanie 6 (`rngd`) zgłosiło błąd ale zostało zignorowane.

![playbook-run-2](IMG/Zrzut%20ekranu%202026-05-15%20065213.png)

---

## 5. Zarządzanie artefaktem

### 5.1. Struktura roli

Rolę zainicjalizowano komendą:

```bash
ansible-galaxy role init deploy_app
```

### 5.2. Zadania roli (`roles/deploy_app/tasks/main.yml`)

```yaml
---
- name: 1. Sanity check - czy maszyna zyje
  ping:

- name: 2. Instalacja Dockera na maszynie docelowej
  apt:
    name: docker.io
    state: present
    update_cache: yes

- name: 3. Uruchomienie uslugi Docker
  service:
    name: docker
    state: started
    enabled: yes

- name: 4. Przygotowanie folderu na Dockerfile
  file:
    path: /tmp/app_build
    state: directory

- name: 5. Stworzenie Dockerfile - Artefakt
  copy:
    dest: /tmp/app_build/Dockerfile
    content: |
      FROM nginx:alpine
      RUN echo "<h1>Laboratorium 8 - Ansible i Docker</h1>" > /usr/share/nginx/html/index.html

- name: 6. Zbudowanie obrazu - Requirement Build
  command: docker build -t moja-apka:v1 /tmp/app_build/

- name: 7. Uruchomienie kontenera - Requirement Run
  command: docker run -d -p 8080:80 --name final-app moja-apka:v1

- name: 8. Weryfikacja lacznosci - Requirement Verify
  uri:
    url: "http://localhost:8080"
    status_code: 200
  register: result

- name: 9. Oczyszczenie - zatrzymanie kontenera - Requirement Cleanup
  command: docker rm -f final-app
  ignore_errors: yes
```

### 5.3. Wynik uruchomienia

Wszystkie zadania zakończyły się sukcesem. Play recap: `ok=10 changed=7 unreachable=0 failed=0`.

![deploy-playbook](IMG/Zrzut%20ekranu%202026-05-15%20071001.png)

---