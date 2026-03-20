# Interaktywne budowanie i testowanie w kontenerze
<img src="ss/ss1.png" width="400">

<img src="ss/ss2.png" width="400">

### Instalacja zależności
<img src="ss/ss3.png" width="300">

### `npm run build` bierze źródłowy kod axios z lib/ i kompiluje go do kilku formatów dystrybucyjnych w katalogu dist/.
<img src="ss/ss4.png" width="350">

### Uruchomienie testów
<img src="ss/ss5.png" width="300">

<img src="ss/ss6.png" width="450">

# Automatyzacja przez Dockerfile
### Dzięki temu zamiast ręcznie wpisywać komendy w interaktywnym TTY, mamy powtarzalny, zautomatyzowany proces. Każdy docker build odtwarza dokładnie te same kroki na każdej maszynie, bez potrzeby ręcznej interwencji.
<img src="ss/ss7.png" width="450">

## !UWAGA!
```bash
# CMD
docker build -f Dockerfile.build -t **XYZ**     # Nadanie nazwy obrazowi podczas budowania
```
```yml
# Dockerfile.test
FROM **XYZ**    # Aby inny kontener bazował na poprzednim to w Dockerfile korzystamy z tej nazwy
```
### Docker szuka obrazu o tej nazwie lokalnie. Dlatego kolejność ma znaczenie. Najpierw trzeba zbudować axios-build, a dopiero potem axios-test. `depends_on` w Docker Compose właśnie to wymusza.
<img src="ss/ss8.png" width="1000">

<img src="ss/ss9.png" width="1000">

<img src="ss/ss10.png" width="500">

# Sprawdzenie działajacych kontenerów i istniejących obrazów
<img src="ss/ss11.png" width="800">

# Docker-compose
<img src="ss/ss12.png" width="600">

### Kolejny poziom automatyzacji - Zamiast ręcznie wydawać dwie osobne komendy docker build w odpowiedniej kolejności, jedna komenda `docker compose up --build` buduje oba obrazy we właściwej kolejności i zarządza zależnością między nimi.

<img src="ss/ss13.png" width="600">

<img src="ss/ss14.png" width="300">

<img src="ss/ss15.png" width="500">

# Dyskusja
## Czy axios nadaje się do wdrożenia jako kontener?

Nie. Axios to biblioteka JavaScript, nie samodzielna aplikacja - nie ma procesu i nie nasłuchuje na portach.
Kontener służy tu wyłącznie jako środowisko do buildu i testów, nie jako finalny artefakt.

## Finalny artefakt

Dla biblioteki npm artefaktem jest paczka `.tgz` z katalogu `dist/`,
publikowana do rejestru `npmjs.com` przez `npm publish`.
Użytkownicy instalują ją standardowo przez `npm install axios`.

## Podział odpowiedzialności między Dockerfile'ami
* `Dockerfile.build`- instalacja zależności + kompilacja
* `Dockerfile.test` - uruchomienie testów (bazuje na build)
* `Dockerfile.publish` - publikacja do npm (bazuje na build, wymaga `NPM_TOKEN`)

Test i publish to niezależne ścieżki - obie bazują na tym samym obrazie buildowym.

## Multi-stage build (dla aplikacji, nie bibliotek)

Przy wdrażaniu aplikacji jako kontener stosuje się multi-stage build: pierwszy etap
kompiluje kod z pełnym zestawem narzędzi deweloperskich, drugi etap kopiuje tylko
gotowe artefakty do czystego obrazu. Efekt: mniejszy obraz, mniejsza powierzchnia ataku.

**Dla axios nie ma to zastosowania - nie wdrażamy kontenera, wdrażamy paczkę npm**