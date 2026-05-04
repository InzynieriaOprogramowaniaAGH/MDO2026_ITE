# Ansible

Laboratoria poświęcone były pracy z oprogramowaniem ansible, do wykonywania poleceń zdalnie na wielu urządzeniach.

## Przygotowania

Praca przebiega na dwóch maszynach wirtualnych: Ubuntu desktop i Ubuntu server. Serwer będzie odbierać polecenia systemu z gui, który zawiera oprogramowanie ansible. Wpierw ustalone zostały nowe nazwy maszyn.

Nadawca otrzymał nazwę `ansi_sendr`:

![Zmiana nazwy nadawcy](images/1.%20Zmiana%20nazwy%20nadawcy.png)

Odbiorca, `ansi_recvr`:

![Zmiana nazwy odbiorcy](images/2.%20Zmiana%20nazwy%20odbiorcy.png)

Każde z urządzeń otrzymało też nazwę DNS na drugie urządzenie w pliku `/etc/hosts`. Jest to łatwy sposób na ustalenie pary nazwa-adres.

Nadawca posiada alias do odbiorcy o nazwie `recvr`:

![Hosty nadawcy](images/3.%20Hosty%20nadawcy.png)

Odbiorca posiada alias nadawcy pod nazwą `sendr`:

![Hosty odbiorcy](images/4.%20Hosty%20odbiorcy.png)

Przeprowadzone zostaje polecenie ping w celu zweryfikowania łączności i funkcjonalności aliasów:

Ping od nadawcy:

![Ping nadawcy](images/5.%20Ping%20nadawcy.png)

Ping od odbiorcy:

![Ping odbiorcy](images/6.%20Ping%20odbiorcy.png)

Po wstępnej konfiguracji można przejść do pracy z Ansible.

## Inventory file

Plik inventory jest zbiorem zdalnych urządzeń, podzielonych na węzły w celu łatwego zarządzania pulą odbiorców poleceń. Zgodnie z instrukcją zostały dodane grupy `Orchestrators` i `Endpoints`:

``` ini
[Orchestrators]
controller ansible_connection=local

[Endpoints]
controlled ansible_host=recvr ansible_port=2020 ansible_user=ansible ansible_ssh_private_key_file=~/.ssh/ansible_key

```

Objaśnienia:
* `controller` i `controlled`: aliasy maszyn;
* `ansible_connection=local`: sposób na określenie, że urządzenie `controller` jest urządzeniem, na którym znajduje się plik. Użycie tej wbudowanej opcji zapobiega zbędnie zawiłej konfiguracji przez powstrzymanie ansible przed łączeniem się z hostującą go maszyną przez SSH. Dzięki temu nie potrzeba generować zbędnych kluczy do łączenia urządzenia z samym sobą;
* `ansible_host=recvr`: adres maszyny kontrolowanej, znajdujący się pod utworzonym wcześniej aliasem;
* `ansible_port=2020`: port udostępniany przez maszynę kontrolowaną. Podanie go umożliwia połączenie się z urządzeniem, korzystającym z NAT przy pomocy port-forwarding'u;
* `ansible_user=ansible`: nazwa użytkownika maszyny kontrolowanej;
* `ansible_ssh_private_key_file=~/.ssh/ansible_key`: ścieżka do klucza SSH dla maszyny kontrolowanej.

Żeby połączyć się z urządzeniem, ansible wywoła polecenie: `ssh -i ansible_ssh_private_key_file ansible_user@ansible_host -p ansible_port`.

W celu przetestowania łączności wywoływany jest ping za pomocą oprogramowania. Służy do tego polecenie `ansible <grupy> -i <inventory> -m ping`. Wykona ono ping do wszystkich urządzeń określonych w podanych grupach pliku.

Rezultat polecenia:

![Ansible ping z ostrzeżeniem](images/7.%20Ansible%20ping%20z%20ostrzeżeniem.png)

Polecenie jest zakończone sukcesem, ale z ostrzeżeniem o nieścisłości interpretera Python'a. Żeby pozbyć się ostrzeżenia, należy wyraźnie zaznaczyć w pliku inventory, który z nich powinien być wykorzystywany:

``` ini
[Orchestrators:vars]
ansible_python_interpreter=/usr/bin/python3

[Endpoints:vars]
ansible_python_interpreter=/usr/bin/python3
```

Ponowne wykonanie ping przebiega pomyślnie bez ostrzeżeń:

![Ansible ping bez ostrzeżenia](images/8.%20Ansible%20ping%20bez%20ostrzeżenia.png)

Żeby wykonać ping na wszystkich maszynach, zamiast wypisywać wszystkie grupy, wymienia się je na `all`:

![Ansible ping all](images/9.%20Ansible%20ping%20all.png)

## Playbook YAML

Playbook jest plikiem, określającym jakie polecenia mają zostać wykonane na poszczególnych maszynach, zdefiniowanych w pliku inventory. Każdy playbook zawiera w sobie co najmniej jeden *Play*, czyli listę instrukcji *Task* wykonywanych przez określone moduły *Modules*.

Przykład składni:

``` yaml
- name: First play
  hosts: all

  tasks:
  - name: first task
    <module1>:
      opt1:
      opt2:

  - name: second task
    <module2>:
      opt1:
      opt2:

- name: Second play
  hosts: group1

  tasks:
  - name: first task
    <module3>:
      opt:

  - name: second task
    <module_with_no_options>:
```

### Ping

Playbook, który wywołuje ping na wszystkich urządzeniach wygląda następująco:

``` yaml
- name: Connectivity check
  hosts: all

  tasks:
  - name: Run ping
    ansible.builtin.ping:
```

Wykonanie playbook'a odbywa się po wywołaniu polecenia: `ansible-playbook -i <inventory> <playbook>`.

![Playbook ping](images/10.%20Playbook%20ping.png)

### Kopiowanie pliku

Playbook jest w stanie wykonywać operacje na plikach maszyny kontrolowanej za pomocą wbudowanego modułu `copy`.
Playbook kopiujący plik:

``` yaml
- name: Copy file to controlled device
  hosts: Endpoints

  tasks:
  - name: Copy inventory
    ansible.builtin.copy:
      src: inventory.ini
      dest: ~/ansible_stuff/inventory.ini
      owner: ansible
      group: ansible
      mode: '0644'
```

Podany plik kopiuje plik inventory ze swojego folderu, umieszcza go na ścieżce `~/ansible_stuff/` i nadaje mu odpowiednie uprawnienia: Właściciel: **ansible**, grupa: **ansible**, uprawnienia: **rw- r-- r--**.

![Playbook copy](images/11.%20Playbook%20copy.png)

Status zadania `Copy inventory` urządzenia `controlled` to *changed* z powodu modyfikacji stanu urządzenia.

Na serwerze znajduje się skopiowany plik:

![Playbook copy controlled](images/12.%20Playbook%20copy%20controlled.png)

Ponowne wykonanie tego samego playbook'a skutkuje innym statusem:

![Playbook another copy](images/13.%20Playbook%20another%20copy.png)

Plik już istnieje na urządzeniu, zatem jej stan nie uległ zmianie. Status maszyny `controlled` to *ok*.

### Aktualizacja pakietów systemowych

Playbook może wykonywać polecenia systemowe dzięki modułowi `apt`.
Playbook wykonujący aktualizację pakietów (odpowiednik *sudo apt update* i *sudo apt dist-upgrade*):

``` yaml
- name: Update system
  hosts: Endpoints
  become: yes

  tasks:
  - name: sudo apt update
    ansible.builtin.apt:
      update_cache: yes

  - name: sudo apt dist-upgrade
    ansible.builtin.apt:
      upgrade: dist
```

Dodanie wiersza `become: yes` jest istotne przy wykonywaniu poleceń systemowych. Zapewnia ono, że polecenia zostaną wykonane przez sudo. Pojawia się z nim jednak jeden problem:

![Playbook update error](images/15.%20Playbook%20update%20error.png)

Wykonanie polecenia jako sudo wymaga podania hasła, czego powyższy playbook nie robi. Żeby pozbyć się tego problemu, można wyłączyć konieczność podawania hasła do sudo użytkownikowi ansible, który wykonuje polecenia playbook'a na zdalnym urządzeniu. Robi się to przez wywołanie `sudo visudo` na maszynie kontrolowanej i dopisaniu `ansible ALL=(ALL) PASSWD:ALL` do otwartego pliku. Teraz użytkownik ansible nie musi podawać hasła dla sudo, dzięki czemu wykonanie playbook'a kończy się sukcesem:

![Playbook update](images/14.%20Playbook%20update.png)

### Restart usług SSHD i RNGD

Oprócz modułu `apt` istnieje jeszcze moduł `systemd` do zarządzania urządzeniem.
Plik wykonujący restart usług SSH i RNG:

``` yaml
- name: Restart utilities
  hosts: Endpoints
  become: yes

  tasks:
  - name: Restart SSH
    ansible.builtin.systemd:
      name: ssh
      state: restarted
  - name: Restart RNG
    ansible.builtin.systemd:
      name: rng-tools
      state: restarted
```

![Playbook restart SSH i RNG](images/16.%20Playbook%20restart%20SSH%20i%20RNG.png)

### Playbook przy braku połączenia SSH

Wszystkie powyższe pliki zostały złączone w jeden i przeprowadzono test zachowania playbook'a przy niedostępnym serwisie SSH na maszynie kontrolowanej:

![Playbook disabled SSH](images/17.%20Playbook%20disabled%20SSH.png)

Błąd pojawił się w trakcie zadania `Gathering Facts`. Jest to zadanie każdego playbook'a odbywające się przed zadaniami, zdefiniowanymi przez użytkownika. Błąd dotyczy tylko urządzenia kontrolowanego, więc urządzenie kontrolujące dalej wykonuje swój zestaw poleceń, co widać w kroku `Run ping`. Należy zwracać na to uwagę i być przygotowanym na ewentualne awarie pojedynczych węzłów.

### Playbook przy braku karty sieciowej po stronie kontrolowanej

Od urządzenia kontrolowanego odpięto kartę sieciową i ponownie uruchomiono playbook'a:

![Playbook disabled network](images/18.%20Playbook%20disabled%20network.png)

Rezultat jest taki sam jak w przypadku braku SSH. Urządzenia, które działają poprawnie, wykonują swoje zestawy poleceń, a wadliwe maszyny przerywają działanie. Warto w takim przypadku zabezpieczyć się przed kontynuacją działania pozostałych węzłów za pomocą np. poleceń assert lub innych testów, by uniknąć nieprzewidywalnego zachowania.

## Deployment artefaktu

Artefaktem stworzonym przez Jenkins pipeline jest archiwum z obrazem dockera, zawierającym skompilowany i przetestowany program.

Playbook zawiera następujące zadania:
* Ping target: wykonuje ping na urządzeniu kontrolowanym;
* Ensure work directory exists: weryfikuje czy folder przestrzeni roboczej istnieje;
* Copy archive to target: kopiuje plik archiwum na urządzenie;
* Install Docker: instaluje dockera;
* Verify docker binary exists: weryfikuje czy docker został pomyślnie zainstalowany;
* Fail if docker missing: przerywa wykonanie jeżeli nie ma dockera na urządzeniu;
* Check docker version: wypisuje wersję dockera;
* Load Docker image: tworzy obraz z pliku archiwum;
* Show loaded image result: wypisuje rezultat stworzenia obrazu;
* Run container: uruchamia kontener i rejestruje wynik;
* Assert container output echo: sprawdza czy wypisany został prawidłowy ciąg znaków po uruchomieniu kontenera (polecenie `CMD ["echo", "(Dockerfile: CMD [\"echo\"]) Application ready for deployment."]` w Dockerfile);
* List container contents: rejestruje zawartość kontenera;
* Show container contents: wypisuje zawartość kontenera;
* Verify container file list: testuje zawartość kontenera;
* Assert container file list: przerywa wykonanie jeżeli brakować będzie któregoś z plików;
* Remove image: usuwa obraz;
* Remove work dir: oczyszcza przestrzeń roboczą;
* Final ping: wykonuje ping na koniec wykonywania;

Żeby zweryfikować czy playbook jest napisany prawidłowo, wykonać można polecenie `ansible-playbook <playbook> --syntax-check`:

![Deploy playbook syntax check warning](images/19.%20Deploy%20playbook%20syntax%20check%20warning.png)

Wypisane ostrzeżenie mówi, że lista hostów jest pusta, mimo że są podani w pliku inventory. Jest to spowodowane niepodaniem ścieżki do pliku inventory w poleceniu weryfikującym składnię. Żeby nie musieć podawać ścieżki inventory przy każdym poleceniu, skonfigurować można ansible za pomocą pliku `ansible.cfg`:

``` ini
[defaults]
inventory = inventory.ini
```

Teraz plik inventory będzie znany ansible przy wykonywaniu każdego polecenia:

![Deploy playbook syntax check proper](images/20.%20Deploy%20playbook%20syntax%20check%20proper.png)

Playbook jest wykonany poleceniem `ansible-playbook deploy.yaml`

*(wynik polecenia w pliku deploy_log.txt)*

## Role

Role umożliwiają rozbicie pliku playbook na kilka osobnych plików, każdy o swoim unikalnym przeznaczeniu. Do stworzenia szkieletu roli służy polecenie `ansible-galaxy role init <nazwa>`. Jeżeli nie są konieczne wszystkie narzędzia roli, strukturę można utworzyć ręcznie.

Struktura roli wykonującej deploy projektu wygląda następująco:

```
roles/docker_deploy
|-defaults/main.yaml
|-files/ART_my-app-build_latest.tar.gz
|-meta/main.yaml
|-tasks/main.yaml
```

* defaults: zawiera zmienne środowiskowe;
* files: przechowuje pliki;
* meta: zawiera metadane o projekcie
* tasks: zawiera logikę playbook'a

Wywołanie roli odbywa się przez playbook'a z następującą treścią:
``` yaml
- name: Deploy Docker artifact
  hosts: Endpoints
  become: true

  roles:
    - docker_deploy
```