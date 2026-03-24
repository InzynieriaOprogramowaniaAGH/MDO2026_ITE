## 1. Pobranie repozytorium - express 
![](1a.png)

### Zainstalowanie wszystkich paczek
![](1.png)

### Sprawdzenie czy posiada testy
![](1b.png)

## 2. Uruchamianie czystego kontenera

```-it``` - interaktywny terminal

```node:20-bookworm``` - bazowy obraz

![](2.png)

### Klonowanie i budowanie
![](2a.png)

### Testy
![](2b.png)

```node:20``` ma wszystko czego potrzeba - git, npm czy node

## 3. Tworzenie kontenera z pliku

### Dockerfile.build
![](3a.png)

```-t express-app:build``` - nadanie nazwy obrazowi

```-f Dockerfile.build``` - wskazanie na konkretny plik


![](3b.png)

### Dockerfile.test
![](3c.png)
![](3d.png)

## 4. Weryfikacja
Po odpaleniu komendy
```docker run --name test-run express-app:test```
pojawiają sie logi i przechodzą pomyślnie wszystki testy

![](4a.png)

## Status
kontener posiada status ```exit 0``` - wszystko przeszło pomyślnie

![](4b.png)