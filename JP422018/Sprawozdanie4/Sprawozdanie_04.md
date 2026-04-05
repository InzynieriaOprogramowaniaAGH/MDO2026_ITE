# LAB 4
# Zachowywanie stanu między kontenerami
## 1. Przygotowanie wolumenów
<img src="ss/ss1.png" width="600">

## 2A. Klonowanie repo bez gita w kontenerze
<img src="ss/ss2.png" width="500">

#### Użyłem kontenera pomocniczego, który służy wyłącznie do pobrania kodu i zapisania go na wolumenie input_source.
#### **Dlaczego tak?**
* Izolacja: Kontener bazowy pozostaje czysty. Nie musimy instalować w nim Gita, co zmniejsza rozmiar obrazu i zwiększa bezpieczeństwo
* Automatyzacja: Nie musimy ręcznie kopiować plików z hosta ani polegać na tym, czy host ma zainstalowanego Gita. Cały proces jest powtarzalny na dowolnej maszynie z Dockerem.
* Persystencja: Dane trafiają bezpośrednio do wolumenu zarządzanego przez Dockera, co jest wydajniejsze niż Bind Mount na niektórych systemach.

### 3. Uruchomienie kontenera, podłączyenie obu wolumenów i wykonanie builda
<img src="ss/ss3.png" width="500">

### 4. Weryfikacja plików na wolumenie wyjściowym
<img src="ss/ss4.png" width="800">

## 2B. Klonowanie repo z gitem w kontenerze
<img src="ss/ss5.png" width="600">

# Eksponowanie portu i łączność między kontenerami

## 1. Przygotowanie obrazu i łączność w sieci domyślnej
<img src="ss/ss6.png" width="900">

## 2. Utworzenie kontenerów we własnej sieci
<img src="ss/ss7.png" width="900">

## 3A. Połączenie się spoza kontenera z hosta
<img src="ss/ss8.png" width="900">

## 3B. Połączenie się spoza kontenera spoza hosta
<img src="ss/ss9.png" width="900">

## 4. Wyciągniecie logów z kontenera
<img src="ss/ss10.png" width="500">

# Usługi w rozumieniu systemu, kontenera i klastra

## 1. Budowa kontenera
<img src="ss/ss11.png" width="600">

## 2. Uruchomienie kontenera i połączenie się z nim przez ssh
<img src="ss/ss12.png" width="900">

### Zalety
- Szyfrowana komunikacja
- Powszechnie znane narzędzie
- Pełny shell + SCP/SFTP + tunelowanie portów

### Wady
- Narusza zasadę "jeden proces na kontener"
- Zwiększa powierzchnię ataku
- `docker exec` / `kubectl exec` robią to samo prościej
- Trudne w środowiskach efemerycznych

### Kiedy używać
- Kontenery działające jak VM-y (np. środowiska dev)
- Brak dostępu do hosta Docker/K8s
- Legacy tooling wymagający SSH
- Gdy `exec` jest celowo zablokowany

# Jenkins

## 1. Utworzenie sieci mostkowej I uruchomienie pomocnika Docker 
<img src="ss/ss13.png" width="700">

## 2. Uruchomienie kontenera Jenkinsa
<img src="ss/ss14.png" width="700">

## 3. Sprawdzenie czy kontenery działają poprawnie
<img src="ss/ss15.png" width="800">

## 4. Logowanie do Jenkinsa przez `adres_maszyny:8080`
<img src="ss/ss16.png" width="500">

