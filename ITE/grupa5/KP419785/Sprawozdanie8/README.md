# SPRAWOZDANIE – LABORATORIUM 8

## Środowisko uruchomieniowe

- System operacyjny (główna maszyna): Ubuntu 24.04 LTS – maszyna wirtualna `devops`
- System operacyjny (maszyna docelowa): Ubuntu 26.04 LTS – maszyna wirtualna `ansible-target`
- Silnik wirtualizacji: Oracle VirtualBox
- Metoda dostępu: Zdalna sesja przez SSH (użytkownik: `karro`)
- Narzędzie automatyzacji: Ansible (zainstalowany na głównej maszynie)
- Edytor kodu: GNU nano / Visual Studio Code (Remote SSH)
- Projekt: portfinder (artefakt z poprzednich laboratoriów)

## 1. Utworzenie nowej maszyny wirtualnej

Utworzono drugą maszynę wirtualną z minimalnym zestawem oprogramowania opartą na Ubuntu 26.04 LTS. Podczas instalacji ustawiono:

- hostname: `ansible-target`
- użytkownik: `ansible`

Poprawne uruchomienie maszyny i zalogowanie się jako użytkownik `ansible` potwierdzono bezpośrednio w konsoli VirtualBox:

![1](<img/Zrzut ekranu 2026-04-28 015248.png>)
(wcześniej użytkownikiem był karro, ale zmieniłam to na nowej maszynie do wymagań)

## 2. Instalacja Ansible i wymiana kluczy SSH

Na głównej maszynie wirtualnej (`devops`) zainstalowano Ansible z repozytorium dystrybucji. Następnie wygenerowano parę kluczy SSH (ED25519) i wymieniono je z użytkownikiem `ansible` na maszynie docelowej.

Wygenerowanie klucza na maszynie `ansible-target` oraz pobranie adresu IP (192.168.1.38):

![2](<img/Zrzut ekranu 2026-04-28 014539.png>)

Skopiowanie klucza publicznego do maszyny `ansible-target` i weryfikacja logowania bez hasła:

![3](<img/Zrzut ekranu 2026-04-28 014504.png>)

![4](<img/Zrzut ekranu 2026-04-28 014718.png>)

Skopiowanie klucza publicznego do maszyny `ansible-target` dla użytkownika `ansible` i weryfikacja logowania bez hasła:

![5](<img/Zrzut ekranu 2026-04-28 015335.png>)

## 3. Inwentaryzacja

Na głównej maszynie dopisano adres IP maszyny docelowej do pliku `/etc/hosts`, przypisując jej nazwę `ansible-target`. Dzięki temu możliwe jest odwoływanie się do maszyny po nazwie zamiast po adresie IP.

![6](<img/Zrzut ekranu 2026-04-28 020151.png>)

Stworzono plik `inventory.ini` z sekcjami `[Orchestrators]` (główna maszyna `devops`) oraz `[Endpoints]` (maszyna docelowa `ansible-target`):

![7](<img/Zrzut ekranu 2026-04-28 020351.png>)

Przeprowadzono test łączności modułem `ping` do wszystkich hostów z pliku inwentaryzacji. Przy pierwszym uruchomieniu pojawił się komunikat weryfikacji klucza hosta SSH (fingerprint) dla maszyny `ansible-target`, potwierdzono połączenie wpisując `yes`:

![8](<img/Zrzut ekranu 2026-04-28 021539.png>)

Po zaakceptowaniu klucza hosta, kolejne uruchomienie pinguje obie maszyny bez dodatkowych pytań:

![9](<img/Zrzut ekranu 2026-04-28 021843.png>)

![10](<img/Zrzut ekranu 2026-04-28 021955.png>)

Obie maszyny (`devops` i `ansible-target`) zwróciły wynik `SUCCESS` z `"ping": "pong"`.

## 4. Konfiguracja sudo dla użytkownika ansible

Aby umożliwić Ansible wykonywanie zadań z podwyższonymi uprawnieniami (`become: yes`) bez podawania hasła, zalogowano się na maszynę `ansible-target` i dodano użytkownika `ansible` do sudoers z opcją `NOPASSWD`:

![11](<img/Zrzut ekranu 2026-04-28 023025.png>)

## 5. Playbook – zdalne procedury podstawowe

Stworzono plik `playbook podstawy.yml` realizujący kilka zadań na maszynach z grupy `Endpoints`:

![12](<img/Zrzut ekranu 2026-04-28 022708.png>)

Uruchomienie `ansible-playbook -i inventory.ini playbook_podstawy.yml` zakończyło się sukcesem. Wynik `changed=3` potwierdza, że skopiowanie pliku, aktualizacja cache pakietów i restart SSH to operacje, które faktycznie zmodyfikowały stan systemu:

![13](<img/Zrzut ekranu 2026-04-28 023115.png>)

Uruchomienie playbooka ponownie (z flagą `-K` do podania hasła sudo, choć użytkownik `ansible` ma już skonfigurowane `NOPASSWD`) pokazuje idempotentność, `changed=1` zamiast `changed=3`. Kopiowanie pliku inwentaryzacji i aktualizacja cache zwróciły `ok` (brak zmian), gdyż stan systemu był już zgodny z oczekiwanym. Jedynie restart SSH zawsze powoduje zmianę stanu:

![14](<img/Zrzut ekranu 2026-04-28 023124.png>)

## 6. Test z odpiętą kartą sieciową

Przeprowadzono próbę połączenia przy odpiętej karcie sieciowej maszyny `ansible-target`. Ansible zwrócił błąd `UNREACHABLE!` dla maszyny docelowej z komunikatem `No route to host`, natomiast połączenie z `devops` (localhost) zakończyło się sukcesem:

![15](<img/Zrzut ekranu 2026-04-28 023406.png>)

## 7. Rola Ansible 

Stworzono szkielet roli za pomocą narzędzia `ansible-galaxy`:

![16](<img/Zrzut ekranu 2026-04-28 023444.png>)

W pliku `deploy_portfinder/tasks/main.yml` zdefiniowano następujące zadania:

- instalacja wymaganych pakietów (ca-certificates, curl, gnupg) przez `ansible.builtin.apt`
- dodanie klucza GPG Dockera przez `ansible.builtin.apt key`
- dodanie repozytorium Dockera przez `ansible.builtin.apt repository`
- instalacja Docker CE, docker-ce-cli i containerd.io

![17](<img/Zrzut ekranu 2026-04-28 023627.png>)

Rola obejmuje również dalsze zadania: dodanie użytkownika `ansible` do grupy `docker`, skopiowanie artefaktu `portfinder-12.tar.gz` na maszynę docelową, załadowanie obrazu Docker i uruchomienie kontenera.

Stworzono plik `wdrozenie.yml` wywołujący rolę `deploy portfinder`:

![18](<img/Zrzut ekranu 2026-04-28 023703.png>)

## 8. Uruchomienie roli

Uruchomienie `ansible-playbook -i inventory.ini wdrozenie.yml` spowodowało wykonanie wszystkich tasków roli. Docker został zainstalowany Ansiblem na maszynie docelowej. Widoczne statusy `changed` dla kluczowych kroków:

![19](<img/Zrzut ekranu 2026-04-28 025745.png>)

Ponowne uruchomienie playbooka wykazało idempotentność roli. Wszystkie wcześniej zainstalowane komponenty (pakiety, klucz GPG, repozytorium Docker, Docker Engine) zwróciły `ok`. Jedynym krokiem z `changed` był transfer artefaktu i załadowanie obrazu.

Krok uruchomienia kontenera zwrócił błąd `FAILED` z kodem `rc: 125`. Docker próbował pobrać obraz `portfinder-deploy:latest` z Docker Hub (brak dostępu), zamiast użyć lokalnie załadowanego obrazu `app-deploy`. Krok miał ustawiony `ignore errors: yes`, więc playbook kontynuował i zakończył się wynikiem `ok=11 changed=4 failed=0 ignored=1`:

![20](<img/Zrzut ekranu 2026-04-28 033856.png>)

Błąd wynika z rozbieżności nazwy obrazu, artefakt załadowany przez `docker load` nosi nazwę `app-deploy`, natomiast w tasku uruchamiającym kontener użyto nazwy `portfinder-deploy`. Korekta polega na ujednoliceniu nazwy tagu w tasku:

## Podsumowanie

### Ansible i inwentaryzacja
Ansible umożliwia zarządzanie wieloma maszynami z jednego miejsca. Plik inwentaryzacji z sekcjami `Orchestrators` i `Endpoints` pozwala precyzyjnie kierować taski do odpowiednich maszyn. Wymiana kluczy SSH eliminuje potrzebę podawania haseł podczas automatyzacji.

### Idempotentność playbooków
Kluczową cechą Ansible jest idempotentność, ponowne uruchomienie tego samego playbooka nie zmienia już skonfigurowanego systemu. Widać to wyraźnie w porównaniu pierwszego (`changed=3`) i drugiego (`changed=1`) uruchomienia `playbook podstawy.yml`.

### Rola ansible-galaxy
Użycie ról pozwala na organizację i wielokrotne użycie kodu Ansible. Szkielet roli generowany przez `ansible-galaxy role init` zawiera gotową strukturę katalogów.

### Wdrożenie artefaktu Docker przez Ansible
Docker zainstalowany Ansiblem na maszynie docelowej umożliwia pełne wdrożenie aplikacji bez manualnej interwencji. Artefakt `portfinder-12.tar.gz` z poprzednich laboratoriów jest przesyłany i ładowany automatycznie. Zidentyfikowana rozbieżność nazwy obrazu jest trywialną korektą konfiguracji roli.

*Pliki `inventory.ini`, `playbook_podstawy.yml`, `wdrozenie.yml`, `deploy portfinder/tasks/main.yml` dostępne w katalogu `lab8 ansible`.*
*Listing historii poleceń zawarty w pliku `history.txt` w folderach Sprawozdanie8.*