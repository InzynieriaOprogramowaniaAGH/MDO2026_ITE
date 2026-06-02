# Stawianie dockera
```bash
sudo apt install docker.io
```
### Pobieranie dockera z repo dystrybucji(apt) zamiast Community Edition
Wersja dystrybucyjna:
* odrazu gotowa do użytku
* stablina
* lepiej dostosowana
* nie wymaga konfiguracji. 
### W 90% lepiej korzystać z wersji danej dystrybucji, chyba że potrzebujemy najnowszej wersji Docker to wtedy trzeba pobrać community edition (długi i skomplikowany proces konfiguracji)



# Zapoznanie się z obrazami
#### Kod wyjścia - liczba zwracana przez program po zakończeniu działania.
```
0 : sukces
1-255 : coś poszło nie tak 
Przydatne w automazacji i CI/CD do sprawdzania czy kolejne kroki zakończyły się sukcesem.
```
### 1. Hello World
Minimalny obraz testowy. Służy sprawdzeniu czy Docker działa poprawnie.

<img src="ss/ss5.png" width="400">

### 2. Busybox
Ultra lekki linux, z najważniejszymi narzędziami uniksowymi

<img src="ss/busybox-ss.png" width="400">

### 3. aspnet
**runtime** - podstawowe środowisko konieczne do uruchomienia aplikacji .NET

**aspnet** - runtime + asp.net do aplikacji webowych

**sdk** - pełny zestaw narzędzi .NET razem z kompilatorem. Tylko do wersji dev

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
* Kontener to izolowany proces, nie wirtualna maszyna To samo co na hoście ma PID 4787, w kontenerze widzi siebie jako PID 1. To zwykły proces Linuksa z inną "perspektywą".
* Oba środowiska używają tego samego jądra systemu. Stąd docker jest lżejszy niż VM, ale też mniej odizolowany.

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