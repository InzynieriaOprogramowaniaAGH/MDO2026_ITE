# Sprawozdanie z laboratorium 9 - Pliki odpowiedzi dla wdrożeń nienadzorowanych

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Przygotowanie serwera instalacyjnego
- Utworzono katalog udostępniający pliki na głównej maszynie, do którego skopiowano archiwum z aplikacją `app.tar`.
- Utworzono plik odpowiedzi Kickstart `ks.cfg` na podstawie wymagań: instalacja nienadzorowana, formatowanie całego dysku, statyczna konfiguracja sieci dla nowej maszyny, ustawienie nazwy hosta `nestjs-host-auto` i instalacja pakietu `docker`.
- W sekcji `%post` dodano listę poleceń pobierającą zbudowany artefakt `app.tar` z serwera pobierania. Następnie utworzono plik usługi `start-myapp.service` dla `systemd`, który ładuje obraz `docker load` i uruchamia zbudowany wcześniej kontener w tle od razu po restarcie i starcie usługi demona Dockera.
- Rozwiązano problem uruchamiania polecenia `docker run` podczas procesu instalacji (instalator działa jako chroot) poprzez konfigurację włączenia usługi przy starcie z poleceniem `systemctl enable start-myapp.service`.
- Uruchomiono serwer plików realizujący to zadanie przy pomocy polecenia `python3 -m http.server 8000`.

![Serwer Pythona na hoście](img/python_http_server.jpg)

## 2. Instalacja nienadzorowana systemu Fedora
- Utworzono maszynę wirtualną i podłączono obraz instalacyjny w postaci płyty ISO (Fedora Server).
- Ominięto wyzwanie związane z niedostępnością serwera przypisywania adresów sieciowych (DHCP) i zainicjowano statyczną konfigurację stosu sieciowego w procesie bootowania loadera i Anacondy.
- W menu GRUB wywołano opcje uruchamiania (klawiszem `e`), a na zakończenie ciągu znaków definiującego uruchomienie instalatora dopisano konfigurację interfejsu `ens18`: `ip=<IP_VM>::<IP_BRAMY>:<MASKA>:fedora:ens18:none nameserver=1.1.1.1 inst.ks=http://<IP_SERWERA>:8000/ks.cfg`.
- Instrukcja przypisała adres karcie sieciowej a parametr `inst.ks` wskazał docelowe miejsce do pobrania autorskiego pliku odpowiedzi.

![Ekran GRUB](img/grub_inst_ks.jpg)

### 2.1 Napotkane problemy i zastosowane rozwiązania
- Pierwsze próby rozruchu wykazały problem zawieszania procesu podczas konfiguracji (`nm-wait-online-initrd.service`). Zaradzono mu narzucając konkretny interfejs dla przypisanego IP w GRUB (`ens18`).
- Procedurę Kickstart zablokował błąd nieznanego wywołania `autostep`. Wynikało to z faktu użytkowania najnowszej wersji operacyjnego systemu bazowego, w którym parametry te wycofano (`deprecated`). Skasowano linijkę kodu na serwerze i ponowiono instalację. Zmodyfikowany dokument Kickstart poprowadził do końca całą operację nienadzorowaną.

## 3. Weryfikacja działającego środowiska
- Po operacji partycjonowania, implementacji bazowych narzędzi na sformatowanym dysku oraz skonfigurowaniu struktury systemowej, proces montażu zakończono automatycznym restartem.
- Zaprezentowano system, który poprawnie skonfigurował host na `nestjs-host-auto` z wprowadzonym adresem sieciowym.
- Pomyślne sprawdzenie poprawności działania aplikacji, za sprawą użycia komendy `curl localhost:3000` i statusu w wierszu `docker ps`, udowodniło wykonaną operację importowania i zbudowania kontenerowego pakietu po starcie samego serwera w poprawny i zamierzony sposób.

![Pomyślna weryfikacja automatycznej instalacji i wdrożenia aplikacji](img/testy_dzialajacy_system.jpg)