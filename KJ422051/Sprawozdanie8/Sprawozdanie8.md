
Stworzono pełnego klona – maszyna będzie działać samodzielnie,
Wygeneruj nowe adresy MAC dla wszystkich kart sieciowych – dzięki temu obie maszyny będą mogły mieć różne adresy IP w sieci.

Aby maszyny mogły się połączyć ustawiono sieć na:

 <img width="659" height="150" alt="image" src="https://github.com/user-attachments/assets/bd02bfba-8656-43ec-9fae-71d3ecc043a9" />


Zmiana nazwy hosta:

 <img width="877" height="55" alt="image" src="https://github.com/user-attachments/assets/1a3dfc0b-34b4-4e8a-8b03-f49a69084ab1" />


Dodanie użytkownika ansible:
 
<img width="666" height="150" alt="image" src="https://github.com/user-attachments/assets/73df9d3d-680e-43eb-b213-bfb29dd215c7" />


Za pomocą ip a sprawdzono adres IP:

 <img width="181" height="38" alt="image" src="https://github.com/user-attachments/assets/96810e46-d3c9-4241-a8c5-d34c60a607b1" />


Migawka:

<img width="431" height="248" alt="image" src="https://github.com/user-attachments/assets/317d5819-baa4-4c29-a66c-92a28c5d02fb" />

 
Wykonano migawkę, aby zabezpieczyć stan systemu przed konfiguracją Ansible.

Instalacja ansible na głównej maszynie:

 <img width="945" height="239" alt="image" src="https://github.com/user-attachments/assets/3b422df8-a971-480a-babb-4e41cbc09ae4" />


Wymiana kluczy:
Generowanie kluczy na głównej maszynie:

<img width="836" height="580" alt="image" src="https://github.com/user-attachments/assets/01e63229-c1d9-48cd-bf34-2c05a1360e9a" />

 
Wysłanie kopii identyfikatora z maszyny głównej do klona:
 
<img width="945" height="351" alt="image" src="https://github.com/user-attachments/assets/196209ea-5a79-444c-90a4-e2bfed008ee8" />


Sprawdzenie:

 <img width="794" height="102" alt="image" src="https://github.com/user-attachments/assets/4bc07108-5e5a-4683-9c31-44337478932e" />

<img width="355" height="50" alt="image" src="https://github.com/user-attachments/assets/1047a126-b27b-4327-9081-eaf2e53f7322" />

 

Konfiguracja nazw:

<img width="878" height="370" alt="image" src="https://github.com/user-attachments/assets/673c07c7-fcd8-4301-b70c-de314a92c65d" />

 
Sprawdzenie czy działa:  

<img width="945" height="158" alt="image" src="https://github.com/user-attachments/assets/a2866d12-8fa1-4006-a83d-19a5362ffb10" />


Plik inwentaryzacji:

<img width="945" height="296" alt="image" src="https://github.com/user-attachments/assets/ecd9011e-edf4-4f3b-809b-a47bb367bf6a" />

 
Konfiguracja pliku pozwoliła na posługiwanie się nazwą ansible-target zamiast adresu IP. Podział na sekcje Orchestrators i Endpoints pozwala na precyzyjne kierowanie zadań do konkretnych grup maszyn.

Test:  

<img width="945" height="349" alt="image" src="https://github.com/user-attachments/assets/d5a059f6-6619-4a3b-b240-7eba17baa660" />


Zdalne procedury:

Plik tasks.yml:

 <img width="934" height="849" alt="image" src="https://github.com/user-attachments/assets/b879dfef-12a5-43c9-b730-fa76e32c1c56" />


Należało dodać uprawnienia sudo na ansible:

<img width="666" height="72" alt="image" src="https://github.com/user-attachments/assets/f6db0393-e2e3-47e6-bcd3-041377b55ee1" />

 
Uruchomienie:

<img width="945" height="259" alt="image" src="https://github.com/user-attachments/assets/af151959-56e0-41bd-895f-f070c061d484" />

 

Zarządzanie artefaktem Docker:

<img width="591" height="430" alt="image" src="https://github.com/user-attachments/assets/9e465327-dd10-4c70-b687-31d52b96387e" />

 
Z powodu braku własnego obrazu na Docker hubie użyto hello-world

Inicjalizacja:

<img width="945" height="60" alt="image" src="https://github.com/user-attachments/assets/33b66b09-4e33-41e3-b9d9-bd4feba297a3" />

 
Przeniesienie zadań:

<img width="945" height="825" alt="image" src="https://github.com/user-attachments/assets/50822a38-bbc0-496f-8653-50e854848ed9" />

 
Wypełnienie metadanych:

 <img width="945" height="447" alt="image" src="https://github.com/user-attachments/assets/2b796ba7-b3c2-4b03-b90f-36610d6d3c8f" />


Stworzenie i odpalenie głównego pliku:
 
<img width="902" height="261" alt="image" src="https://github.com/user-attachments/assets/1887f51f-1c2e-49ff-8ed7-e219903d15e0" />



Maszyna podczas pracy wyłączyła się z powodu braku dostępnego miejsca na komputerze:

<img width="945" height="222" alt="image" src="https://github.com/user-attachments/assets/5b8cfb91-57b6-4240-861d-878dbedca33c" />

 
Wystąpił błąd krytyczny VERR_DISK_FULL, który doprowadził do zawieszenia maszyny wirtualnej i błędu UNREACHABLE.  Przy okazji awarii został przeprowadzony test odporności Ansible.

Po ponownym uruchomieniu:

<img width="945" height="643" alt="image" src="https://github.com/user-attachments/assets/37280351-b989-4b2a-a883-d361e3af3290" />

 
Weryfikacja automatyczna za pomocą komendy docker ps.
Sprawdzenie poprawności na ansible:

<img width="695" height="109" alt="image" src="https://github.com/user-attachments/assets/14f78ef5-2a18-40ae-91c9-2ed7504f3814" />

 
Weryfikacja ręczna poprzez zalogowanie na maszynę docelowa i sprawdzenie obecności pliku inwentarza.

Udało się w pełni zautomatyzować proces przygotowania środowiska, instalacji silnika kontenerowego Docker oraz wdrożenia przykładowego artefaktu przy użyciu struktury ról Ansible, co zapewnia łatwe ponowne użycie kodu w przyszłości.
