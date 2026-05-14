Sklonowanie maszyny wirtualnej:
 
Pełny klon – maszyna będzie działać samodzielnie,
Wygeneruj nowe adresy MAC dla wszystkich kart sieciowych – dzięki temu obie maszyny będą mogły mieć różne adresy IP w sieci.

Aby maszyny mogły się połączyć ustawiono sieć na:
 

Zmiana nazwy hosta:
 

Dodanie użytkownika ansible:
 

Za pomocą ip a sprawdzono adres IP:
 

Migawka:
 
Wykonano migawkę, aby zabezpieczyć stan systemu przed konfiguracją Ansible.

Instalacja ansible na głównej maszynie:
 

Wymiana kluczy:
Generowanie kluczy na głównej maszynie:
 
Wysłanie kopii identyfikatora z maszyny głównej do klona:
 

Sprawdzenie:
 
 

Konfiguracja nazw:
 
Sprawdzenie czy działa:  

Plik inwentaryzacji:
 
Konfiguracja pliku pozwoliła na posługiwanie się nazwą ansible-target zamiast adresu IP. Podział na sekcje Orchestrators i Endpoints pozwala na precyzyjne kierowanie zadań do konkretnych grup maszyn.

Test:  

Zdalne procedury:
Plik tasks.yml:
 

Należało dodać uprawnienia sudo na ansible:
 
Uruchomienie:
 

Zarządzanie artefaktem Docker:
 
Z powodu braku własnego obrazu na Docker hubie użyto hello-world

Inicjalizacja:
 
Przeniesienie zadań:
 
Wypełnienie metadanych:
 

Stworzenie i odpalenie głównego pliku:
 



Maszyna podczas pracy wyłączyła się z powodu braku dostępnego miejsca na komputerze:
 
Wystąpił błąd krytyczny VERR_DISK_FULL, który doprowadził do zawieszenia maszyny wirtualnej i błędu UNREACHABLE.  Przy okazji awarii został przeprowadzony test odporności Ansible.

Po ponownym uruchomieniu:

 
Weryfikacja automatyczna za pomocą komendy docker ps.
Sprawdzenie poprawności na ansible:
 
Weryfikacja ręczna poprzez zalogowanie na maszynę docelowa i sprawdzenie obecności pliku inwentarza.

Udało się w pełni zautomatyzować proces przygotowania środowiska, instalacji silnika kontenerowego Docker oraz wdrożenia przykładowego artefaktu przy użyciu struktury ról Ansible, co zapewnia łatwe ponowne użycie kodu w przyszłości.
