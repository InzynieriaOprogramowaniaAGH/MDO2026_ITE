# Sprawozdanie 09 - Instalacja Nienadzorowana (Kickstart) i Automatyzacja

---

## 1. Cel zadania
Celem laboratorium było przygotowanie zautomatyzowanego źródła instalacji nienadzorowanej (Kickstart) dla systemu operacyjnego hostującego aplikację w kontenerze. System miał zainstalować się automatycznie z podziałem dysku, pobraniem odpowiednich repozytoriów, instalacją środowiska Docker oraz samoczynnym uruchomieniem kontenera z aplikacją podczas pierwszego startu.

Ze względu na architekturę hosta (Apple Silicon M-series), proces został przeprowadzony na systemie **Fedora Server 44** w wersji dla architektury **aarch64** przy użyciu instalatora sieciowego (Netinstall).

---

## 2. Przygotowanie pliku odpowiedzi (Kickstart)
Na głównej maszynie (DevOps) utworzono plik odpowiedzi `ks.cfg`. W pliku zawarto dyrektywy odpowiedzialne za:
* Ustawienia regionalne i klawiaturę.
* Podpięcie dedykowanych repozytoriów Fedory 44 (aarch64).
* Całkowite formatowanie dysku (`clearpart --all --initlabel`).
* Zmianę nazwy hosta na `fedora-auto`.
* Instalację niezbędnych pakietów w sekcji `%packages` (m.in. `moby-engine`, `docker-compose`).

**Kluczowa sekcja `%post`:**
W ramach sekcji poinstalacyjnej przygotowano skrypt, który włącza usługę Docker oraz tworzy i aktywuje własną usługę w `systemd` (`uruchom-aplikacje.service`). Jej zadaniem jest pobranie i uruchomienie kontenera `nginx:alpine` natychmiast po pierwszym uruchomieniu systemu.

Plik został udostępniony w sieci lokalnej za pomocą serwera HTTP w Pythonie (`python3 -m http.server 8000`).

![Udostępnianie pliku ks.cfg](/screeny/01_python_server.png)
*Rys 1. Serwer HTTP udostępniający plik instalacyjny dla nowej maszyny.*

---

## 3. Instalacja Nienadzorowana
Utworzono nową maszynę wirtualną typu ARM64 w trybie karty sieciowej "Bridged". Podczas rozruchu z obrazu ISO zedytowano parametry programu ładującego GRUB. 

Do parametrów jądra (sekcja `linux`) dopisano ścieżkę do pliku odpowiedzi z serwera na maszynie DevOps:
`inst.ks=http://192.168.100.135:8000/ks.cfg`

Instalator pomyślnie pobrał konfigurację, przeprowadził partycjonowanie, zainstalował pakiety i zrestartował maszynę bez jakiejkolwiek interakcji ze strony użytkownika.

![Sukces instalacji i ekran logowania](/screeny/02_fedora_login.png)
*Rys 2. System pomyślnie zainstalowany z nadanym hostname'm 'fedora-auto'.*

---

## 4. Weryfikacja Działania (Wnioski)
Po zalogowaniu do nowego systemu zweryfikowano poprawność wykonania zadań z sekcji `%post`.

1. **Weryfikacja Dockera:** Zastosowano komendę `docker ps`, która potwierdziła, że kontener `nginx:alpine` działa od razu po uruchomieniu systemu.

![Weryfikacja kontenera Docker](/screeny/03_docker_i_curl_test.png)
*Rys 3. Kontener Nginx został uruchomiony automatycznie w tle.*

2. **Ostateczny test aplikacji (Smoke Test):** System wirtualny otrzymał adres IP w sieci lokalnej w trybie Bridged. Połączono się z nim bezpośrednio z przeglądarki na maszynie hosta (macOS), co dowodzi poprawnego działania całego zautomatyzowanego stosu technologicznego.

![Weryfikacja działania w przeglądarce](/screeny/04_nginx_browser.png)
*Rys 4. Strona powitalna Nginx odpowiadająca z nowo zainstalowanego systemu.*

---