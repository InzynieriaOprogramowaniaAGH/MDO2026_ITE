# Stawianie dockera
1. Utwórz katalog na klucze GPG
2. Pobierz i zapisz klucz GPG Dockera
3. Daj wszystkim prawo odczytu klucza
4. Dodaj repozytorium Dockera do źródeł apt
5. Odśwież listę pakietów

<img src="ss/ss1.png" width="500">

### Zainstaloawnie sładników Dockera: silnik, narzędzie poleceń i narzędzia do obsługi obrazów
<img src="ss/ss2.png" width="800">

# Zapoznanie się z obrazami sprawdzając kod wyjścia
### 1. Hello World
<img src="ss/ss5.png" width="400">

### 2. Busybox
<img src="ss/busybox-ss.png" width="400">

### 3. aspnet
<img src="ss/aspnet-ss.png" width="600">

### Sprawdzenie rozmiarów powyższych obrazów
<img src="ss/screen.png" width="500">

# Uruchomienie kontenera z obrazu busybox, podłączenie interaktywne i sprawdzenie wersji
<img src="ss/ss6.png" width="500">

# System w kontenerze
### 1. Uruchomienie ubuntu w kontenerze i sprawdzenie PIDU wewnatrz kontenera 
<img src="ss/ss7.png" width="500">

### 2. Sprawdzenie PID'u tego samego kontenera na hoście
<img src="ss/ss8.png" width="700">

### Wniosek
* Kontener to tylko izolowany proces na hoście. Myśli, że jego PID to 1, ale w rzeczywistości na hoście ma zwykły wysoki PID
* oba środowiska współdzielą ten sam kernel

# Stworzenie własnego obrazu
### 1. Własnoręcznie napisany Dockerfile i zbudowanie obrazu
<img src="ss/ss9.png" width="500">

Dobre praktyki w Dockerfile:
* ubuntu:24.04 zamiast ubuntu:latest - przewidywalność buildów
* Jeden RUN dla update + install - mniej warstw w obrazie
* rm -rf /var/lib/apt/lists/* - czyszczenie cache apt, mniejszy rozmiar obrazu
* WORKDIR zamiast cd w RUN - czytelność i bezpieczeństwo
* LABEL z metadanymi - dobra praktyka dokumentacyjna
* CMD zamiast ENTRYPOINT dla interaktywnego użycia

### 2. Interaktywne uruchomienie i przetestowanie kontenera
<img src="ss/ss10.png" width="600">

# Sprzątanie
### 1. Sprawdzenie uruchomionych kontenerów, a potem ich usunięcie
<img src="ss/ss11.png" width="600">

### 2. Usunięcie wszystkich obrazów
<img src="ss/ss12.png" width="500">