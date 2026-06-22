# Sprawozdanie zbiorcze z zajęć laboratoryjnych nr 8-12

<br/>
<br/>

## Laboratorium 8

### Przygotowanie środowiska do pracy z Ansible

Najpierw należy utworzyć dwie maszyny wirtualne z systemem Linux. Sieć została ustawiona na mostkową, maszyny pingują się nawzajem.

#### Instalacja `tar` i serwera OpenSSH `sshd` na obydwu maszynach.

```bash
sudo apt update && sudo apt install -y tar openssh-server
```

![Instalacja tar i sshd](<img/Screenshot 2026-05-21 at 20.30.06.png>)

#### Nadanie maszynie hostname `ansible-target`

```bash
sudo hostnamectl set-hostname ansible-target
```

aktualizacja plik `/etc/hosts`

![Aktualizacja pliku hosts](<img/Screenshot 2026-05-21 at 20.32.02.png>)

#### Utworzenie użytkownika `ansible` z haslem `kamil`

```bash
sudo adduser ansible
sudo usermod -aG sudo ansible
sudo reboot
```

po restarcie zalogowanie się na konto `ansible`

![Logowanie na konto ansible](<img/Screenshot 2026-05-21 at 20.34.55.png>)

#### Zainstalowanie Ansible na głównej maszynie

```bash
sudo apt update && sudo apt install -y tar openssh-server
sudo apt install -y ansible
```

#### Wymiana kluczy SSH między maszynami i sprawdzenie połączenia bez hasła

```bash
ssh-keygen -t ed25519
ssh-copy-id ansible@192.168.1.126
```

![Wymiana kluczy SSH](<img/Screenshot 2026-05-21 at 20.44.10.png>)

połączenie przy pomocy SSH bez hasła `ssh ansible@192.168.1.126`

![Połączenie SSH bez hasła](<img/Screenshot 2026-05-21 at 20.45.36.png>)

#### Sprawdzenie działania Ansible pingując maszynę docelową

Tworzymy plik `hosts` z następującą zawartością:

```bash
[targets]
192.168.1.126 ansible_user=ansible
```

a następnie wykonujemy polecenie: `ansible targets -i hosts -m ping`

- `targets` to nazwa grupy hostów, którą zdefiniowaliśmy w pliku `hosts`
- `-i` wskazuje gdzie znajduje się plik z listą hostów
- `-m` wskazuje jaki moduł Ansible ma zostać użyty, w tym przypadku `ping`

![Pingowanie maszyny docelowej](<img/Screenshot 2026-05-21 at 20.50.35.png>)

#### Zrobienie migawki maszyn

Na koniec należy zrobić migawkę obu maszyn, aby w razie potrzeby można było szybko przywrócić stan sprzed zmian.

![Migawka maszyn](<img/Screenshot 2026-05-21 at 20.59.51.png>)

### Inwentaryzacja

#### Dokonanie inwentaryzacji systemów

Nazyw komputerów zostały zmienione na `primary` i `ansible-target`. Wprowadzono nazwy DNS za pomocą pliku `/etc/hosts`, w którym na samym dole dodano wpisy:

```
192.168.1.125 primary
192.168.1.126 ansible-target
```

Zweryfikowano łączność między maszynami za pomocą polecenia `ping`:

```bash
ping -c 3 ansible-target
```

![Pingowanie ansible-target](<img/Screenshot 2026-05-22 at 09.17.11.png>)

##### Tworzenie pliku inwentaryzacji

Utworzenie pliku inventory.ini z następującą zawartością:

```ini
[Orchestrators]
primary ansible_connection=local

[Endpoints]
ansible-target ansible_user=ansible
```

- `ansible_connection=local` oznacza, że Ansible będzie działać lokalnie na maszynie `primary` i nie będzie próbować łączyć się z nią przez SSH

Następnie wykonanie polecenia `ansible all -i inventory.ini -m ping` w celu wysłania polecenia ping do wszystkich hostów zdefiniowanych w pliku inventory.ini.

Aby wszystko działało, najpier łączę się z maszyną target przez SSH `ssh ansible@ansible-target` i akceptuję klucz hosta, a następnie ponownie wykonuję polecenie ping.

![Pingowanie wszystkich hostów](<img/Screenshot 2026-05-22 at 09.33.16.png>)

### Zdalne wywoływanie procedur

#### Wysłanie żądania ping do wszystkich maszyn

Tworzymy plik `playbook.yml` z następującą zawartością:

```yaml
---
- name: Ping targets
  hosts: all
  tasks:
    - name: Ping
      ping:
```

#### Skopiowanie pliku inwentaryzacji na maszyny [Endpoints]

Dodanie nowego zadanai do `playbook.yml` i uruchomienie go ponownie

```yaml
- name: Copy inventory file to target
  ansible.builtin.copy:
    src: inventory.ini
    dest: /tmp/inventory.ini
```

![Zawartość katalogu /tmp](<img/Screenshot 2026-05-26 at 16.35.09.png>)

#### Ponowienie operacji, porównanie różnic w wyjściu

![Skopiowanie pliku inwentaryzacji](<img/Screenshot 2026-05-26 at 16.32.08.png>)

W ansible mamy 3 podstawowe statusy: `ok`, `changed` i `failed`.

- `ok` zadanie zostało wykonane poprawnie i nie było potrzeby wprowadzenia żadnych zmian,
- `changed` zadanie zostało wykonane poprawnie, ale wprowadziło jakieś zmiany w systemie,
- `failed` oznacza, że zadanie nie zostało wykonane poprawnie i wystąpił błąd.

Jeżeli uruchomimy jeszcze raz ten sam playbook, to zobaczymy, że status `changed` zmieni się na `ok`, ponieważ plik inwentaryzacji już istnieje na maszynie docelowej i nie ma potrzeby go ponownie kopiować.

#### Aktualizacja pakietów

Dodajemy kolejne zadanie do `playbook.yml`

```yaml
- name: Update package list
  ansible.builtin.package:
    update_cache: yes
  become: yes
```

#### Restartowanie usług: `sshd` i `rngd`

```yaml
- name: Restart sshd & rngd services
  ansible.builtin.service:
    name: ["sshd", "rngd"]
    state: restarted
```

### Zarządzanie stworzonym artefaktem

#### Opakowujemy artefakt w Dockerfile

```Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY . .
EXPOSE 3000

CMD ["node", "examples/hello-world/index.js"]
```

Następnie budujemy obraz Dockerowy i uruchamiamy kontener oraz sprawdzamy czy kontener działa poprawnie.

```bash
docker build -t m4rch3w44a/express-hello:v1 .
docker run -d -p 3000:3000 --name test-hello m4rch3w44a/express-hello:v1
```

![Uruchomienie kontenera](<img/Screenshot 2026-06-22 at 15.01.25.png>)

![Sprawdzenie działania kontenera](<img/Screenshot 2026-06-22 at 15.01.46.png>)

#### Wysyłamy obraz do Docker Hub

Po zalogowaniu się do Docker Hub za pomocą `docker login` możemy wysłać nasz obraz do repozytorium.

```bash
docker push m4rch3w44a/express-hello:v1
```

![Wysyłanie obrazu do Docker Hub](<img/Screenshot 2026-06-22 at 15.07.27.png>)

Sprawdzenie czy obraz jest dostępny w Docker Hub za pomocą `docker pull m4rch3w44a/express-hello:v1`.

![Sprawdzenie dostępności obrazu](<img/Screenshot 2026-06-22 at 15.08.00.png>)

#### Instalacja Dockera na maszynie docelowej za pomocą ansible

Tworzymy nowy playbook `docker.yml` z następującą zawartością.

```yaml
---
- name: Test połączenia
  hosts: Endpoints
  become: yes
  tasks:
    - name: install docker
      apt:
        name: docker.io
        state: present
        update_cache: yes

    - name: enable docker
      service:
        name: docker
        enabled: yes
        state: started

    - name: add ansible user to docker group
      user:
        name: ansible
        groups: docker
        append: yes
```

Teraz uruchamiamy tego playbooka i sprawdzamy czy Docker został poprawnie zainstalowany i uruchomiony.

![Instalacja Dockera za pomocą Ansible](<img/Screenshot 2026-06-22 at 15.42.21.png>)

#### Deploy aplikacji z Docker Hub na maszynie docelowej

Docker jest już zainstalowany, więc możemy teraz stworzyć nowego playbooka `deploy-express.yml`, który będzie odpowiedzialny za pobranie obrazu z Docker Hub i uruchomienie kontenera.

```yaml
---
- name: Deploy Express.js
  hosts: Endpoints
  tasks:
    - name: "Sanity: ping maszyny"
      ansible.builtin.ping:

    - name: "Sanity: czy Docker działa?"
      ansible.builtin.command: docker info
      changed_when: false

    - name: Usuń stary kontener (jeśli istnieje)
      ansible.builtin.command: docker rm -f express-hello
      ignore_errors: true

    - name: Pobierz obraz
      ansible.builtin.command: docker pull m4rch3w44a/express-hello:v1

    - name: Uruchom kontener
      ansible.builtin.command: docker run -d --name express-hello -p 3000:3000 m4rch3w44a/express-hello:v1

    - name: Poczekaj 3 sekundy na start
      ansible.builtin.pause:
        seconds: 3

    - name: "Weryfikacja: czy kontener działa?"
      ansible.builtin.command: docker ps --filter "name=express-hello"
      changed_when: false
```

Playbook ten zawiera również proste testy sanity, które sprawdzają czy maszyna jest osiągalna i czy Docker działa poprawnie. Następnie usuwa stary kontener (jeśli istnieje), pobiera nowy obraz z Docker Hub, uruchamia kontener i weryfikuje czy kontener działa poprawnie.

![Deploy aplikacji z Docker Hub](<img/Screenshot 2026-06-22 at 15.49.46.png>)

![Sprawdzenie działania aplikacji](<img/Screenshot 2026-06-22 at 15.48.28.png>)

Kontener uruchomił się poprawnie.

#### Cleanup

Ostatnim zadaniem będzie wykonanie cleanupu, czyli zatrzymania i usunięcia kontenera oraz usunięcie obrazu z maszyny. Do tego celu stworzymy kolejny playbook `cleanup.yml` z następującą zawartością:

```yaml
---
- name: Cleanup Express.js
  hosts: Endpoints
  tasks:
    - name: "Sanity: ping maszyny"
      ansible.builtin.ping:

    - name: "Sanity: czy Docker działa?"
      ansible.builtin.command: docker info
      changed_when: false

    - name: Zatrzymaj kontener
      ansible.builtin.command: docker stop express-hello
      ignore_errors: true

    - name: Usuń kontener
      ansible.builtin.command: docker rm express-hello
      ignore_errors: true

    - name: Usuń obraz
      ansible.builtin.command: docker rmi m4rch3w44a/express-hello:v1
      ignore_errors: true

    - name: "Weryfikacja: brak kontenerów"
      ansible.builtin.command: docker ps -a --filter "name=express-hello"
      changed_when: false

    - name: "Weryfikacja: brak obrazu"
      ansible.builtin.command: docker images m4rch3w44a/express-hello:v1
      changed_when: false
```

![Cleanup](<img/Screenshot 2026-06-22 at 15.59.29.png>)

### Stworzenie roli z powyższych playbooków

Inicjalizacja roli `express_deploy` za pomocą polecenia `ansible-galaxy init express_deploy`.

![Inicjalizacja roli](<img/Screenshot 2026-06-22 at 16.07.19.png>)

Teraz musimy uzupełnić zawartość plików, które zostały wygenerowane.

- `express_deploy/defaults/main.yml`

```yaml
#SPDX-License-Identifier: MIT-0
---
express_docker_image: "m4rch3w44a/express-hello:v1"
express_container_name: "express-hello"
express_port: 3000
express_state: "present"
```

- `express_deploy/meta/main.yml`

```yaml
#SPDX-License-Identifier: MIT-0
galaxy_info:
  author: Kamil Marchewka
  description: Rolla do wdrożenia aplikacji Express.js w kontenerze Docker.
  company: AGH

  license: license (GPL-2.0-or-later, MIT, etc)

  min_ansible_version: 2.2

  galaxy_tags: []

dependencies: []
```

- `express_deploy/tasks/main.yml`

```yaml
#SPDX-License-Identifier: MIT-0
---
- name: "Sanity: ping"
  ansible.builtin.ping:

- name: "Sanity: czy Docker działa?"
  ansible.builtin.command: docker info
  changed_when: false

- name: Usuń stary kontener (jeśli istnieje)
  ansible.builtin.command: "docker rm -f {{ express_container_name }}"
  ignore_errors: true
  when: express_state == "present"

- name: Pobierz obraz
  ansible.builtin.command: "docker pull {{ express_docker_image }}"
  when: express_state == "present"

- name: Uruchom kontener
  ansible.builtin.command: >
    docker run -d
    --name {{ express_container_name }}
    -p {{ express_port }}:{{ express_port }}
    {{ express_docker_image }}
  when: express_state == "present"

- name: Poczekaj na start
  ansible.builtin.pause:
    seconds: 3
  when: express_state == "present"

- name: "Weryfikacja: czy kontener działa?"
  ansible.builtin.command: "docker ps --filter name={{ express_container_name }}"
  changed_when: false
  when: express_state == "present"

- name: Zatrzymaj kontener
  ansible.builtin.command: "docker stop {{ express_container_name }}"
  ignore_errors: true
  when: express_state == "absent"

- name: Usuń kontener
  ansible.builtin.command: "docker rm {{ express_container_name }}"
  ignore_errors: true
  when: express_state == "absent"

- name: Usuń obraz
  ansible.builtin.command: "docker rmi {{ express_docker_image }}"
  ignore_errors: true
  when: express_state == "absent"
```

gdy wszystko jest już gotowe, możemy teraz użyć tej roli w playbooku `role.yml`

```yaml
---
- name: Express.js via rola
  hosts: Endpoints
  roles:
    - role: express_deploy
```

Następnie uruchamiamy i sprawdzamy czy działa poprawnie.

![Uruchomienie roli](<img/Screenshot 2026-06-22 at 16.09.12.png>)

![Sprawdzenie działania roli](<img/Screenshot 2026-06-22 at 16.09.48.png>)

dzięki wykorzystaniu roli możemy teraz łatwo zarządzać stanem naszej aplikacji, wystarczy zmienić wartość `express_state` na `absent` i ponownie uruchomić playbook, a rola zajmie się zatrzymaniem i usunięciem kontenera oraz obrazu.

<br/>
<br/>

## Laboratorium 9

Celem zajęć jest przygotowanie źródła instalacyjnego dla maszyny wirtualnej oraz przeprowadzenie instalacji systemu operacyjnego.

### Przygotowanie servera HTTP

Poniższe polecenia wykonujemy na maszynie wirtualnej z systemem Linux server, która będzie maszyną pomocniczą do przygotowania źródła instalacyjnego.

```bash
sudo apt update
sudo apt install apache2 -y
systemctl status apache2
```

![apache2](<./img/Screenshot 2026-05-28 at 15.57.49.png>)

### Przygotowanie źródła instalacyjnego

#### Utworzenie katalogu i pliku dla kickstartera

```bash
sudo mkdir -p /var/www/html/kickstart
sudo nano ks.cfg
```

Zawartość pliku `ks.cfg`, który będzie wystawiony przez serwer HTTP i użyty podczas instalacji systemu operacyjnego na maszynie wirtualnej.

```bash
##version=DEVEL
text
reboot

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=aarch64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=aarch64

keyboard us
lang en_US.UTF-8
timezone Europe/Warsaw --utc

network --bootproto=dhcp --hostname=fedora-auto

rootpw root
firewall --disabled
selinux --disabled

zerombr
clearpart --all --initlabel
autopart

bootloader

%packages
@core
docker
curl
wget
git
%end

%post --log=/root/ks-post.log

systemctl enable --now docker

cat > /etc/systemd/system/nginx-container.service << 'EOF'
[Unit]
Description=Nginx container
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --rm -p 80:80 --name nginx nginx
ExecStop=/usr/bin/docker stop nginx

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nginx-container.service

echo "POST SCRIPT FINISHED" > /root/post-done.txt

%end
```

Sprawdzenie poprawności za pomocą polecenia `curl http://localhost/kickstart/ks.cfg`

![ks](<./img/Screenshot 2026-05-28 at 16.08.32.png>)

### Instalacja systemu operacyjnego na maszynie wirtualnej z wykorzystaniem przygotowanego źródła instalacyjnego

#### Tworzenie maszyny wirtualnej

Tworzymy nową maszynę wirtualną z systemem Fedora 44, przeklikujemy wszystko. Aby było możliwe pobranie pliku `ks.cfg` z serwera HTTP, musimy zmienić kartę sieciową na `Bridged Adapter`.

#### Uruchomienie instalacji z wykorzystaniem kickstartera

Po zobaczeniu menu startowego GRUB, naciskamy klawisz `e` w elu edycji. Odszukujemy linię, która zaczyna się od linux i na jej końcu po spacji dodajemy: `inst.ks=http://192.168.1.129/kickstart/ks.cfg`

![grub](<./img/Screenshot 2026-05-28 at 16.37.18.png>)

#### Sprawdzenie poprawności instalacji

- hostname

```bash
hostname
```

![hostname](<./img/Screenshot 2026-05-28 at 17.17.31.png>)

---

- docker

```bash
docker ps
```

![docker](<./img/Screenshot 2026-05-28 at 17.17.59.png>)

---

- systemctl

```bash
systemctl status nginx-container
```

![nginx](<./img/Screenshot 2026-05-28 at 17.18.31.png>)

### Wnioski

Dzięki automatyzacji możemy zaoszczędzić mnóstwo czasu, zwłaszcze jeżeli musimy wdrożyć dużą liczbę maszyn. Kickstarter eliminuje potrzebę ręcznego przeklikiwania instalatora, a także pozwala na natychmiastową konfigurację systemu po instalacji

Kluczowe jest dobre skonfigurowanie sieci, ustawienie karty sieciowej na tryb Bridge Adapter jest niezbędne, aby maszyna mogła pobrać plik konfiguracyjny z serwera HTTP.

Skrypty %post dają ogromne możliwości, dzięki narzędzią takim jak Kickstart pozwala nie tylko na samą instalację OS-a, ale też na jego natychmiastową konfigurację. Dzięki temu maszyna od razu po pierwszym uruchomieniu jest gotowa do pracy i ma podniesione wymagane usługi (Docker + Nginx), bez konieczności ręcznego logowania się i instalowania czegokolwiek przez administratora.

<br/>
<br/>

## Laboratorium 10

### Instalacja Klastra Kubernetes

Najpierw pobieramy minikube, który jest narzędziem do uruchamiania lokalnego klastra Kubernetes.

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
```

![Instalacja minikube](<./img/Screenshot 2026-05-29 at 09.39.31.png>)

Dodajemy alias, uruchamiamy klaster i weryfikujemy, że wszystko działa poprawnie

```bash
echo "alias minikubctl='minikube kubectl --'" >> ~/.bashrc
source ~/.bashrc

minikube start
```

Możemy sprawdzić działania wywołując komendy `minikube status`, `minikubctl get nodes`

![Uruchomienie klastra](<./img/Screenshot 2026-05-29 at 09.41.57.png>)

![Klaster uruchomiony](<./img/Screenshot 2026-05-29 at 09.42.20.png>)

#### Uruchomienie dashboardu

```bash
minikube dashboard --url
```

![Dashboard](<./img/Screenshot 2026-05-29 at 08.50.47.png>)

Zwracamy uwagę na port, tutaj jest `36111`, ja poniżej użyłem innego, ze względu na to, że uruchamiałem dshboard kilka razy. Za każdym razem dostajemy inny port.

Następnie otwieramy nowy terminal i wykonujemy tunelowanie:

```bash
ssh -L 8080:localhost:<powyższy-port> kamil@192.168.1.133
```

![Tunelowanie](<./img/Screenshot 2026-05-29 at 09.00.01.png>)

Sprawdzamy czy dashboard jest dostępny pod adresem `http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`

![Dashboard dostępny](<./img/Screenshot 2026-05-29 at 13.53.44.png>)

### Analiza posiadanego kontenera

W kubernetesie kontener ma działać cały czas, więc musimy się upewnić, że nasz kontener jest w stanie działać bez końca. W innym przypadku, zostanie uznany za wadliwy i będzie nieustannie restartowany, co nie jest pożądane.

Posłużę się przygotowanym obrazem, bazującym na nginx, który będzie serwował statyczną stronę HTML.

#### Wygenerowanie strony HTML

Generujemy prostą stronę HTML, która będzie serwowana przez nasz kontener i zapisujemy ja jako `index.html`. Plik ten musi się znaleźć w folderze `/usr/share/nginx/html/`, z którego nginx domyślnie serwuje stronę.

#### Przygotowanie obrazu dockera

```Dockerfile
FROM nginx:alpine

RUN rm /usr/share/nginx/html/*

COPY ./index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
```

Teraz budujemy obraz

```bash
docker build -t aplikacja-html:v1 .
```

![Budowanie obrazu](<./img/Screenshot 2026-05-29 at 14.11.19.png>)

![Obraz zbudowany](<./img/Screenshot 2026-05-29 at 14.12.12.png>)

#### Uruchomienie kontenera i wykazanie że działa

```bash
docker run -d --name test-html -p 8081:80 aplikacja-html:v1
docker ps
```

![Uruchomienie kontenera](<./img/Screenshot 2026-05-29 at 14.14.57.png>)

Poprawność możemy sprawdzić uruchamiając logi kontenera `docker logs test-html`, wykonując zapytanie do serwera `curl http://localhost:8081` lub otwierając adres `http://192.168.1.133:8081` w przeglądarce.

![Sprawdzenie działania](<./img/Screenshot 2026-05-29 at 14.16.51.png>)

### Uruchamianie oprogramowania

#### Przesłanie lokalnego obrazu do minikuba

```bash
minikube image load aplikacja-html:v1
```

![Przesyłanie obrazu](<./img/Screenshot 2026-05-30 at 10.34.36.png>)
![Obraz przesłany](<./img/Screenshot 2026-05-30 at 10.34.46.png>)

#### Uruchomienie aplikacji na stosie k6s

Uruchamiamy nasz spersonizowany kontener z wykorzystaniem przesłanego obrazu:

```bash
minikubctl run kb-chmura --image=aplikacja-html:v1 --port=80 --labels app=kb-chmura
```

![Uruchomienie aplikacji](<./img/Screenshot 2026-05-30 at 10.36.24.png>)

Sprawdzamy, czy nasz pod został uruchomiony:

```bash
minikubctl get pods
```

![Lista podów](<./img/Screenshot 2026-05-30 at 10.36.45.png>)

Można też sprawdzić działanie poprzez dashboard. Należy go najpierw uruchomić w tle, zestawić tunel a następnie otworzyć w przeglądarce:

![Dashboard](<./img/Screenshot 2026-05-30 at 10.37.30.png>)

#### Wyprowadzenie portu

Aby uzyskać dostęp do naszej aplikacji, musimy przekierować port z naszego lokalnego komputera do portu, na którym nasz pod nasłuchuje (port-forwarding):

```bash
minikubctl port-forward pod/kb-chmura --address 0.0.0.0 7777:80
```

Ważne jest wskazanie adresu `0.0.0.0`, aby nasza aplikacja była dostępna z innych urządzeń w sieci, a nie tylko z naszego lokalnego komputera.

![Port forwarding](<./img/Screenshot 2026-05-30 at 10.39.22.png>)

#### Przedstawienie komunikacji z eksponowaną funkcjonalnością

![Komunikacja z aplikacją](<./img/Screenshot 2026-05-30 at 10.40.02.png>)

### Przekucie wdrożenia manualnego w plik wdrożenia (wprowadzenie)

#### Zapisanie wdrożenia jako plik `YAML`

Najpierw towrzymy plik wdrożenia `wdrozenie.yaml`, który będzie zawierał definicję naszego wdrożenia. W tym pliku określamy, ile replik naszej aplikacji chcemy uruchomić, jakie obrazy kontenerów mają być używane, oraz jakie porty mają być otwarte.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strona-www-deployment
  labels:
    app: strona-www-chmura
spec:
  replicas: 4
  selector:
    matchLabels:
      app: strona-www-chmura
  template:
    metadata:
      labels:
        app: strona-www-chmura
    spec:
      containers:
        - name: strona-www-container
          image: aplikacja-html:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
```

#### Przeprowadzenie próbnego wdrożenia

Teraz uruchamiamy nasze wdrożenie, jednak zanim to zrobimy to czyścimy nasz klaster z poprzednich podów, za pomocą polecenia `minikubctl delete pod <nazwa-poda>`.

![Usuwanie poda](<./img/Screenshot 2026-05-30 at 10.51.11.png>)

Najpierw nakazujemy Kubernetesowi, aby przeczytał nasz plik i zastosował zapisaną w nim konfigurację:

```bash
minikubctl apply -f wdrozenie.yaml
```

![Zastosowanie konfiguracji](<./img/Screenshot 2026-05-30 at 10.51.52.png>)

Aby upewnić się, że proces wdrażania przebiegł pomyślnie, stosujemy polecenie:

```bash
minikubctl rollout status deployment/strona-www-deployment
```

Teraz możemy sprawdzić listę podów, wówczas okaże się, że Kubernetes faktycznie uruchomił 4 repliki naszej aplikacji, zgodnie z tym co zapisaliśmy w pliku wdrożenia.

![Lista podów](<./img/Screenshot 2026-05-30 at 10.55.09.png>)

#### Wyeksponowanie wdrożenia jako serwis

Pody mogą się restartować i zmeiniać swoje IP, żeby mieć do nich jeden stały punkt dostępu, musimy utworzyć serwis, który będzie rozdzielał ruch sieciowy pomiędzy pody.

Tworzymy i sprawdzamy czy serwis został utworzony:

```bash
minikubctl expose deployment strona-www-deployment --type=NodePort --port=80 --target-port=80 --name=strona-www-serwis

minikubctl get service strona-www-serwis
```

- `--type=NodePort` - oznacza, że serwis będzie dostępny na porcie na węźle klastra.
- `--port=80` - to port, na którym serwis będzie nasłuchiwał.
- `--target-port=80` - to port, na który serwis będzie przekierowywał ruch do podów.
- `--name=strona-www-serwis` - nazwa serwisu.

![Serwis](<./img/Screenshot 2026-05-30 at 10.58.26.png>)

#### Przekierowanie portu do serwisu

Musimy zrobić tunelowanie ruchu z naszego lokalnego komputera do całego serwisu.

```bash
minikubctl port-forward service/strona-www-serwis --address 0.0.0.0 7891:80
```

- `--address 0.0.0.0` - serwis będzie dostępny na wszystkich interfejsach sieciowych naszego komputera.
- `7891:80` - ruch z portu 7891 na naszym komputerze będzie przekierowywany do portu 80 serwisu w klastrze.

![Tunelowanie ruchu](<./img/Screenshot 2026-05-30 at 11.01.51.png>)

#### Sprawdzenie działania aplikacji

Wchodzimy na adres `http://localhost:7891` i sprawdzamy, czy nasza aplikacja jest dostępna.

![Działanie aplikacji](<./img/Screenshot 2026-05-30 at 11.02.14.png>)

<br/>
<br/>

## Laboratorium 11

### Przygotowanie nowego obrazu

Zaczynamy od przygotowanie dwóch działających wersji obrazu i jeden wadliwej:
`my-app:v1` - działająca wersja
`my-app:v2` - działająca wersja z nowymi funkcjonalnościami
`my-app:v3` - wadliwa wersja z błęd

Obrzy te będą zapisane w lokalnym rejestrze obrazów Minikube.

<br/>

#### Startujemy lokalny klaster Kubernetes

```bash
minikube start --driver=docker
```

Sprawdzamy czy klaster działa poprawnie

![minikube status](<./img/Screenshot 2026-06-17 at 10.52.49.png>)

<br/>

#### Budujemy 3 wersje obrazu

Najpierw mówimy dockerowi, żeby działał wewnątrz klastra Minikube

```bash
eval $(minikube docker-env)
```

![eval minikube docker-env](<./img/Screenshot 2026-06-17 at 10.55.53.png>)

Następnie budujemy trzy wersje obrazu na bazie pliku index.html z poprzednich zajęć.

Wykorzystamy do tego prosty Dockerfile

```Dockerfile
FROM nginx:alpine
COPY ./index.html /usr/share/nginx/html/index.html
```

```bash
docker build -t my-app:v1 .
docker build -t my-app:v2 .
docker build -t my-app:v3 . -f Dockerfile.broken
```

w wersji drugiej dodajemy style CSS, a wersję trzecią budujemy tak, żeby od razu się crashowała i wykorzystujemy do tego poniższy Dockerfile

```Dockerfile
FROM alpine
CMD ["false"]
```

<br/>

#### Wyświetlamy listę obrazów

![images](<./img/Screenshot 2026-06-17 at 11.16.50.png>)

<br/>

#### Sprawdzamy czy obraz 3. jest wadliwy

Uruchamiamy obraz v3 i sprawdzamy jego status wyjścia

```bash
docker run my-app:v3
echo $?
```

![run broken image](<./img/Screenshot 2026-06-17 at 11.18.44.png>)

<br/>

<br/>

### Zmiany w deploymencie

Następnie tworzymy plik deployment.yaml, który będzie zawierał definicję naszego wdrożenia, oraz którym będziemy mogli potem manipulować.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 8
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-app:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

Kluczowe jest ustawienie `imagePullPolicy: Never`, które mówi Kubernetesowi, żeby nie próbował pobierać obrazu z rejestru, tylko używał lokalnego.

Wysyłamy konfigurację do klastra

```bash
kubectl apply -f deployment.yaml

# Sprawdzamy status wdrożenia
kubectl get pods
kubectl get deployment my-app
```

![deployment](<./img/Screenshot 2026-06-17 at 11.40.47.png>)

wersja z 8 replikami

<br/>

#### Zmniejszenie liczby replik do 4

![scale down](<./img/Screenshot 2026-06-17 at 11.43.14.png>)

<br/>

#### Zmniejszenie liczby replik do 0

![scale down to 0](<./img/Screenshot 2026-06-17 at 11.43.55.png>)

<br/>

#### Zwiększenie replik do 5

![scale up](<./img/Screenshot 2026-06-17 at 11.44.28.png>)

<br/>

#### Zastosowanie nowej wersji obrazu (v2)

Zmieniamy na `image: my-app:v2` i wysyłamy konfigurację do klastra

```bash
kubectl apply -f deployment my-app
# Sprawdzamy status wdrożenia
kubectl rollout status deployment my-app
kubectl describe deployment my-app | grep Image
```

![rollout](<./img/Screenshot 2026-06-17 at 11.48.28.png>)

Możemy sprawdzić historię wdrożeń, gdzie rewizja rośnie wraz ze zmianą obrazu

```bash
kubectl rollout history deployment my-app
```

![rollout history](<./img/Screenshot 2026-06-17 at 11.50.17.png>)

<br/>

#### Zastosowanie starczej wersji obrazu (v1)

Wrócić do poprzedniej wersji możemy za pomocą polecenia

```bash
kubectl rollout undo deployment my-app
```

i sprawdzamy wersję obrazu za pomocą `kubectl describe deployment my-app | grep Image`

![rollout undo](<./img/Screenshot 2026-06-17 at 11.53.03.png>)

<br/>

#### Zastosowanie wadliwej wersji obrazu (v3)

Teraz wdrażamy wadliwą wersję obrazu i obserwujemy zachowanie.

Po wpisaniu `kubectl get pods` widzimy, że wszystkie repliki w kółko się restartują.

![rollout broken](<./img/Screenshot 2026-06-17 at 11.55.48.png>)

Sprawdzamy też za pomocą `kubectl describe pods | grep -A 5 "State:"` i widzimy, że wszystkie repliki mają status `Error` i `Exit Code: 1`.

![rollout broken describe](<./img/Screenshot 2026-06-17 at 11.57.30.png>)

Teraz możemy wycofać wadliwe wdrożenie za pomocą `kubectl rollout undo deployment my-app` i sprawdzić, że repliki wróciły do poprzedniej wersji.

![rollout undo broken](<./img/Screenshot 2026-06-17 at 12.00.32.png>)

<br/>

<br/>

### Kontrola wdrożenia

Tworzymy skrypt `check_deploy.sh`, który będzie sprawdzał status wdrożenia po 60 sekundach

```bash
#!/bin/bash
minikube kubectl -- rollout status deployment/my-app --timeout=60s

if [ $? -eq 0 ]; then
    echo "Deployment successful"
else
    echo "Deployment failed"
fi
```

nadajemy uprawnienia

```bash
chmod +x check_deploy.sh
```

i uruchamiamy

```bash
./check_deploy.sh
```

![check deploy](<./img/Screenshot 2026-06-17 at 12.09.43.png>)

zmieniamy obraz na wadliwy i uruchamiamy ponownie skrypt

![check deploy broken](<./img/Screenshot 2026-06-17 at 12.12.36.png>)

<br/>

<br/>

### Strategie wdrożenia

#### Recreate

Tworzymy plik `deployment-recreate.yaml` z poniższą konfiguracją

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-recreate
spec:
  replicas: 8
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: my-app-recreate
  template:
    metadata:
      labels:
        app: my-app-recreate
    spec:
      containers:
        - name: my-app
          image: my-app:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

Metoda ta polega na tym, że wszystkie stare repliki są usuwane, a następnie tworzone są nowe. Istnieje więc moment, w którym nie ma żadnych działających replik.

Wdrażamy nową konfigurację, następnie zmieniamy obraz na v2 i wdrażamy ponownie. Widzimy, że wszystkie repliki są usuwane, a następnie tworzone są nowe.

```bash
kubectl apply -f deployment-recreate.yaml
kubectl get pods -w
```

![recreate](<./img/Screenshot 2026-06-17 at 18.20.37.png>)

<br/>

#### Rolling Update

Ta strategia jest włączona domyślnie i polega na tym, że stare repliki są stopniowo zastępowane nowymi. W tym czasie działają zarówno stare, jak i nowe.

<br/>

#### Canary

Tworzymy kolejny plik `deployment-canary.yaml` z poniższą konfiguracją

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-app:v2
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

Ta strategia polega na tym, że nowa wersja jest wdrażana tylko na jednej lub kilku replikach, a reszta nadal działa na starej wersji. Po pewnym czasie, jeśli wszystko działa poprawnie, można zwiększyć liczbę replik z nową wersją.

![canary](<./img/Screenshot 2026-06-17 at 18.32.49.png>)

<br/>

#### Wyeksponowanie aplikacji przez Service

Tworzymy service

```bash
kubectl expose deployment my-app \
  --type=ClusterIP \
  --port=80

# Sprawdzamy status service
kubectl get svc
```

Pody mają losowe adresy IP, które się zmieniają przy każdym restarcie. Service daje nam stabilny wewnętrzny adres (CluserIP), przez ktory możemy zawsze dotrzeć do aplikacji. Ruch jest balansowany między wszystkimi podami.

![service](<./img/Screenshot 2026-06-17 at 18.37.34.png>)

Teraz wykonujemy port-forward i sprawdzamy, czy aplikacja jest dostępna pod localhost:8080

```bash
kubectl port-forward svc/my-app 8080:80
```

![port forward](<./img/Screenshot 2026-06-17 at 18.40.38.png>)

<br/>

<br/>

### Podsumowanie

Podczas laboratorium przygotowano trzy wersje obrazu aplikacji nginx (v1, v2, v3) i wdrożono je w klastrze Minikube. Przeprowadzono skalowanie replik, aktualizację wersji obrazu z v1 na v2 (RollingUpdate) oraz rollback. Wdrożono wadliwy obraz, zaobserwowano stan CrashLoopBackOff i przywrócono działającą wersję. Przetestowano strategie Recreate, RollingUpdate i Canary oraz wyeksponowano aplikację przez serwis ClusterIP.

<br/>
<br/>

## Laboratorium 12

Tworzymy konto na platformie Docker Hub, aby móc przechowywać nasze obrazy kontenerów. Następnie tworzymy zasoby w Azure, takie jak grupy zasobów, rejestry kontenerów i usługi zarządzane, które umożliwią nam wdrażanie naszych aplikacji w kontenerach.

<br/>
<br/>

### Przygotowanie kontenera

Sprawdzamy czy obraz z naszą stroną www został prawidłowo zbudowany i czy działa lokalnie.

```bash
docker build -t my-portfolio:v1 .
docker images
```

![Obraz kontenera](<./img/Screenshot 2026-06-18 at 12.39.51.png>)

```bash
docker run --rm -d -p 8080:80 --name test my-portfolio:v1
curl http://localhost:8080
```

![Wynik działania kontenera](<./img/Screenshot 2026-06-18 at 12.43.03.png>)

Wszystko jest w porządku, więc możemy dodać ten obraz do Docker Hub, aby był dostępny w Azure.

Logujemy się do Docker Hub i przesyłamy nasz obraz

```bash
docker login
docker info
```

![Logowanie do Docker Hub](<./img/Screenshot 2026-06-18 at 12.50.09.png>)

Tagujemy obraz i przesyłamy go do Docker Hub

```bash
docker tag my-portfolio:v1 m4rch3w44a/my-portfolio:v1

docker push m4rch3w44a/my-portfolio:v1
```

![Tagowanie obrazu](<./img/Screenshot 2026-06-18 at 12.54.25.png>)

Są dwie różne nazwy ale to samo id, obraz został poprawnie przesłany do Docker Hub.

![Wynik przesyłania obrazu](<./img/Screenshot 2026-06-18 at 12.55.27.png>)

<br/>
<br/>

### Praca w Azure

#### Uruchomienie Azure Cloud Shell

Sprawdzamy czy mamy dostęp do Azure Cloud Shell i patrzymy czy mamy aktywny plan subskrypcji.

![Uruchomienie Azure Cloud Shell](<./img/Screenshot 2026-06-18 at 13.18.31.png>)

#### Utworzenie Resource Group

```bash
az group create --name rg-my-app --location westeurope
```

![Utworzenie Resource Group](<./img/Screenshot 2026-06-18 at 13.20.41.png>)

#### Rejestracja dostawcy Container Instances

Nas†epnie musimy zarejestrować dostawcę Container Instances, aby móc korzystać z tej usługi w naszej subskrypcji. Rejestracja chwilę trwa, więc musimy poczekać na jej zakończenie.

```bash
az provider register --namespace Microsoft.ContainerInstance
```

![Rejestracja dostawcy Container Instances](<./img/Screenshot 2026-06-18 at 13.29.03.png>)

#### Wdrożenie kontenera w Azure

Teraz możemy wdrożyć nasz kontener w Azure. Używamy polecenia `az container create`, aby utworzyć instancję kontenera z naszym obrazem z Docker Hub.

```bash
az container create \
    --resource-group rg-my-app \
    --name my-app-container \
    --image m4rch3w44a/my-portfolio:v1 \
    --dns-name-label my-app-m4rch3w44a \
    --ports 80 \
    --ip-address Public \
    --cpu 1 \
    --memory 1 \
    --os-type Linux \
    --location austriaeast
```

![Wdrożenie kontenera w Azure](<./img/Screenshot 2026-06-18 at 13.33.58.png>)

![Wdrożenie kontenera w Azure](<./img/Screenshot 2026-06-18 at 13.35.04.png>)

Jak widać wszystko działa poprawnie, nasz kontener został wdrożony w Azure i jest dostępny pod adresem `http://my-app-m4rch3w44a.austriaeast.azurecontainer.io`.

#### Weryfikacja działania kontenera

Napotkałem pewnien problem, który wynikał z tego, że zbudowałem obraz kontenera na systemie MacOS, a następnie próbowałem uruchomić go w Azure, który używa systemu Linux. W związku z tym musiałem przebudować obraz, żeby korzystał z archtektury amd64, a nie arm64. Po przebudowaniu obrazu i ponownym wdrożeniu kontenera w Azure wszystko działa poprawnie.

Wyświetlamy adres ip i dns name naszego kontenera, aby móc się do niego dostać.

```bash
az container show \
    --resource-group rg-my-app \
    --name my-app-container \
    --query "{name:name, state:instanceView.state, ip:ipAddress.ip, fqdn:ipAddress.fqdn}" \
    --output table
```

![Weryfikacja działania kontenera](<./img/Screenshot 2026-06-18 at 14.18.19.png>)

Teraz sprawdzamy czy nasza strona jest dostępna pod adresem ip i dns.

![Weryfikacja działania kontenera](<./img/Screenshot 2026-06-18 at 14.18.37.png>)

![Weryfikacja działania kontenera](<./img/Screenshot 2026-06-18 at 14.17.39.png>)

#### Analiza logów kontenera

![Analiza logów kontenera](<./img/Screenshot 2026-06-18 at 14.22.20.png>)

Logi pokazują co kontener robi w środku, czy się uruchomił poprawnie, czy są błędy, czy ktoś się połączył.

Patrząc na rekord zaczynający się od `GET / HTTP/1.1" 200` widać, że ktoś (my) połączyliśmy się z naszą stroną i pobraliśmy ją poprawnie, co było widać w przeglądarce.

#### Usunięcie zasobów

Najpierw usuwamy kontenery.

```bash
az container delete \
    --resource-group rg-my-app \
    --name my-app-container \
    --yes
```

![Usunięcie zasobów](<./img/Screenshot 2026-06-18 at 14.24.57.png>)

Następnie usuwamy grupę zasobów, która zawiera wszystkie zasoby, które utworzyliśmy w tym laboratorium.

```bash
az group delete \
    --name rg-my-app \
    --yes
```

![Usunięcie zasobów](<./img/Screenshot 2026-06-18 at 14.27.41.png>)
