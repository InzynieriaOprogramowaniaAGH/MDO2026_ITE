# Sprawozdanie z laboratorium 8 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Instalacja zarządcy Ansible i przygotowanie maszyn

W ramach pierwszego etapu skonfigurowano środowisko do automatyzacji:
* Utworzono nową, lekką maszynę wirtualną bazującą na systemie operacyjnym zgodnym z maszyną główną.
* Upewniono się, że zainstalowane są niezbędne narzędzia: `tar` oraz serwer OpenSSH (`sshd`).
* Maszynie nadano nazwę hosta (hostname): `ansible-target` i utworzono natywnego użytkownika `ansible`.
* Na głównej maszynie (pełniącej rolę *Orchestratora*) zainstalowano pakiety Ansible z oficjalnego repozytorium dystrybucji.
* Skonfigurowano bezhasłowe uwierzytelnianie SSH pomiędzy główną maszyną a użytkownikiem `ansible` na węźle docelowym poprzez wygenerowanie i skopiowanie klucza (`ssh-copy-id`).

## 2. Inwentaryzacja i mapowanie DNS

Zamiast standardowego adresowania IP, skonfigurowano system tak, by używał przypisanych nazw.
* Dodano wpis do pliku `/etc/hosts` na głównej maszynie, by nazwa `ansible-target` mapowała bezpośrednio na IP nowej maszyny wirtualnej.
* Skonstruowano plik inwentaryzacji `inventory.ini` zawierający ustrukturyzowane grupy: sekcję `[Orchestrators]` dla maszyny lokalnej (`localhost`) oraz sekcję `[Endpoints]` dla maszyny docelowej.
* Wykonano polecenie typu ad-hoc za pomocą modułu `ping` wbudowanego w Ansible, co potwierdziło sukces wzajemnej komunikacji.

![Ping test z Ansible](img/ansible-target-ping.jpg)

## 3. Zdalne wywoływanie procedur (Playbook systemowy)

Stworzono bazowy skrypt YAML (`system.yml`) obrazujący możliwość grupowego konfigurowania stanu maszyn. Playbook uwzględnił m.in.:
* Transfer pliku statycznego (kopiowanie `inventory.ini` do `/tmp`).
* Moduł aktualizacji systemu (`apt upgrade` i `update_cache`) z zabezpieczeniem wyłączającym interakcje z użytkownikiem (`DEBIAN_FRONTEND=noninteractive`).
* Instalację wymaganego pakietu `rng-tools-debian`.
* Zrestartowanie kluczowych usług (w tym `sshd` i generowania entropii `rngd`).

**Napotkane problemy (sudo-rs):**
Podczas próby podniesienia uprawnień (`become: yes`) w playbooku, natrafiono na problem z pakietem `sudo-rs` na maszynie docelowej. Skutkowało to błędami uwierzytelniania sudo przy wykonywaniu poleceń administracyjnych. Załączono zrzut ekranu ilustrujący ten problem:

![Problemy z sudo-rs](img/playbook_problemy_sudo_rs.jpg)

W celu ominięcia problemu, edytowano na nowej maszynie konfigurację za pomocą polecenia `visudo`, wprowadzając bezpośrednio dla użytkownika `ansible` regułę powalającą na pracę bez poświadczeń: `ansible ALL=(ALL:ALL) NOPASSWD: ALL`. Dzięki temu wszystkie zadania typu `become` wywoływane w playbookach mogły zadziałać poprawnie.

Brak powielania wywołanych już akcji udowodniono uruchamiając playbook drugi raz – zadania, które osiągnęły wcześniej swój stan docelowy, zostały po prostu oznaczone w konsoli na zielono (`ok`), nie powodując ponownej, niepotrzebnej instalacji czy konfiguracji (pominięto status `changed`). 

![Brak ponownych modyfikacji - drugie przejście playbooka](img/playboot_dwa_uruchomienia.jpg)

Przeprowadzono również weryfikację zachowania na wypadek awarii (odłączenie docelowej maszyny w Proxmox). Skrypt poprawnie poinformował o zgłoszeniu błędu `UNREACHABLE` dla odciętego węzła.

![Test awarii - UNREACHABLE](img/playbook_wylaczona_vm.jpg)

## 4. Zarządzanie stworzonym artefaktem aplikacji

Skorzystano z gotowego środowiska aplikacji (NestJS) utworzonego przy okazji laboratoriów z CI/CD pod Jenkinsa. Nowy playbook wdrożeniowy (`deploy.yml`) przygotował całkowicie czystą maszynę pod start środowiska wdrożeniowego.
Automatyzacja objęła:
1. Pobranie i instalację środowiska Docker (`docker.io`) poprzez polecenia Ansible oraz włączenie demona usługi Docker w tle.
2. Skopiowanie spreparowanego wcześniej na serwerze artefaktu (obraz Dockera aplikacji zachowany w uniwersalnym pliku `.tar`) na maszynę końcową.
3. Załadowanie obrazu i start aplikacji kontenerowej na otwartym porcie `3000`.
4. *Sanity Check / Smoke Test* - Ansible, wykorzystując swój moduł `uri`, wysłał z wnętrza procesu żądanie pod docelowy adres `localhost:3000`, weryfikując czy usługa zwróciła oczekiwany kod API `200 OK`.
5. Uporządkowanie środowiska (zatrzymanie, usunięcie testowego kontenera, a także skasowanie wgranego archiwum) po pomyślnym wykonaniu.

Proces powiódł się.

![Sukces wdrożenia artefaktu z weryfikacją API](img/run_deploy_yml.jpg)

## 5. Szkieletowanie ról (Ansible Galaxy)

W celu zachowania przejrzystości, zrezygnowano z jednego pliku implementacji. Całość zmieniono na ustrukturyzowaną wersję za pomocą *Ansible Roles*.
* Narzędziem `ansible-galaxy role init deploy_nestjs` zadeklarowano architekturę katalogową.
* Moduły operacyjne wydzielono ze zbiorczego tekstu do pliku dedykowanych zadań: `tasks/main.yml`.
* Uzupełniono dane wymagane do poprawności metadanych – zaktualizowano licencję na wolną *MIT* i dodano poprawną sygnaturę autora projektu (`meta/main.yml`).
* Zadeklarowano główny plik wykonawczy dla zespołu zarządzającego `site.yml`, wywołujący jedynie informację na temat wdrażanej na stacji roboczej roli.

![Sukces wykonania struktury z użyciem ról - site.yml](img/run_site_yml.jpg)