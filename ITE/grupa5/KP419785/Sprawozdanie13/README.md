# SPRAWOZDANIE 13
 
## Środowisko uruchomieniowe
 
- System operacyjny (maszyna lokalna): Ubuntu 24.04 LTS - maszyna wirtualna `devops`
- Metoda dostępu: Zdalna sesja przez SSH (użytkownik: `karro`)
- Projekt: `portfinder` (fork repozytorium `doganarif/portfinder`)
- Platforma CI: GitHub Actions (konto: `Karro707`)
- Repozytorium forka: `https://github.com/Karro707/portfinder`

## 1. Fork repozytorium
 
Sforkowano repozytorium `doganarif/portfinder` na konto `Karro707`. Nazwa repozytorium pozostaje niezmieniona (`portfinder`). Fork tworzy niezależną kopię projektu, do której można dodawać własne workflow bez ingerencji w upstream.
 
![13](<img/Zrzut ekranu 2026-06-08 231249.png>)
 
- [x] Repozytorium zostało sforkowane na konto Karro707

## 2. Klonowanie forka i utworzenie gałezi `ino_dev`
 
Sforkowane repozytorium sklonowano lokalnie na maszynę wirtualną do katalogu sprawozdania:
 
```bash
git clone https://github.com/Karro707/portfinder.git
```
 
![13](<img/Zrzut ekranu 2026-06-08 232201.png>)
 
Następnie w sklonowanym repozytorium sprawdzono zawartość katalogu i utworzono dedykowaną gałąź `ino_dev`, na której będzie definiowany workflow:
 
```bash
ls
git checkout -b ino_dev
git push origin ino_dev
```
 
![13](<img/Zrzut ekranu 2026-06-09 080700.png>)
 
![13](<img/Zrzut ekranu 2026-06-08 232400___kopia.png>)
 
- [x] Gałąź `ino_dev` utworzona i wypchnięta do zdalnego repozytorium

## 3. Weryfikacja braku istniejących workflow
 
Przed stworzeniem własnej akcji sprawdzono, czy w repozytorium nie istnieją już żadne workflow. Katalog `.github/workflows/` nie istniał - projekt portfinder nie zawiera domyślnych pipeline'ów CI:
 
```bash
ls .github/workflows/ 2>/dev/null && rm -rf .github/workflows/ || echo "Brak workflows"
git add -A
git commit -m "Remove existing workflows"
git push origin ino_dev
```
 
Wynik `Brak workflows` potwierdza brak istniejących plików do usunięcia. Commit zakończył się komunikatem `nothing to commit, working tree clean`:
 
![13](<img/Zrzut ekranu 2026-06-08 232541.png>)
 
- [x] Zweryfikowano brak istniejących workflow w projekcie

## 4. Definicja akcji GitHub Actions
 
Utworzono plik workflow `.github/workflows/build.yml`. Akcja reaguje na zdarzenie `push` do gałęzi `ino_dev`. Trigger został skonfigurowany zgodnie z wymaganiem indywidualnym omówionym na zajęciach.
 
Plik definiuje job `build` uruchamiany na `ubuntu-latest`, składający się z kroków:
 
1. `Checkout repository` - pobranie kodu z repozytorium
2. `Set up Go` - konfiguracja środowiska Go w wersji `1.24` (spójnej z poprzednimi laboratoriami)
3. `Install dependencies` - pobranie zależności przez `go mod download`
4. `Build` - kompilacja projektu: `go build -v -o portfinder-bin ./...`
5. `Run tests` - uruchomienie testów: `go test ./... || echo "No test files found"`
6. `Upload artifact` - wgranie zbudowanej binarki jako artefaktu buildu
![13](<img/Zrzut ekranu 2026-06-09 081254.png>)
 
Plik dodano do repozytorium i wypchnięto:
 
```bash
git add .github/workflows/build.yml
git commit -m "Add GitHub Actions CI workflow for ino_dev"
git push origin ino_dev
```
 
![13](<img/Zrzut ekranu 2026-06-09 081531.png>)
 
![13](<img/Zrzut ekranu 2026-06-09 081550.png>)
 
- [x] Akcja reaguje na push do gałęzi `ino_dev`
- [x] Workflow zdefiniowany w pliku `.github/workflows/build.yml`
- [x] Trigger skonfigurowany zgodnie z wymaganiem z zajęć

## 5. Uruchomienie akcji po pierwszym commicie
 
Po wypchnięciu pliku workflow GitHub Actions automatycznie uruchomił pierwszą akcję. W zakładce Actions widoczny jest run `Add GitHub Actions CI workflow for ino_dev` na gałęzi `ino_dev` ze statusem `In progress`:
 
![13](<img/Zrzut ekranu 2026-06-09 081943.png>)
 
- [x] Akcja uruchomiona automatycznie po commicie do `ino_dev`

## 6. Iteracyjna naprawa workflow i finalne uruchomienie
 
Pierwsze uruchomienia zakończyły się niepowodzeniem z powodu błędu w komendzie budowania. Po poprawieniu komendy `go build` wypchnięto kolejny commit.
 
Run #6 pod nazwą `Add GitHub Actions CI workflow for ino_dev` uruchomił się automatycznie po commicie do `ino_dev`:
 
![13](<img/Zrzut ekranu 2026-06-09 081958.png>)
 
Run #6 zakończył się statusem **Success** w 26 sekund. Widoczny 1 artefakt:
 
![13](<img/Zrzut ekranu 2026-06-09 082133.png>)
![13](<img/Zrzut ekranu 2026-06-09 082054.png>)
 
- [x] Program buduje się poprawnie wewnątrz akcji po zacommitowaniu zmiany do gałęzi

## 7. Logi z etapu Build i Run tests
 
Logi etapu `Build` pokazują kompilację wraz z pobieraniem wszystkich zależności Go. Etap `Run tests` wyświetla wynik `[no test files]` dla wszystkich pakietów projektu - jest to cecha samego projektu portfinder, nie błąd konfiguracji workflow:
 
![13](<img/Zrzut ekranu 2026-06-08 234316.png>)
 
- [x] Etap Build zakończony sukcesem
- [x] Etap Run tests zakończony sukcesem (`[no test files]` - cecha projektu)

## 8. Artefakt zbudowanej binarki
 
Akcja uploaduje zbudowaną binarkę jako artefakt `portfinder-binary-6` o rozmiarze 4.2 MB z wygenerowanym skrótem SHA-256 umożliwiającym weryfikację integralności pliku:
 
![13](<img/Zrzut ekranu 2026-06-08 234544.png>)
 
- [x] Zbudowany artefakt załączony za pomocą dedykowanej akcji `actions/upload-artifact`
- [x] Artefakt dostępny do pobrania z poziomu historii buildu

## 9. Weryfikacja triggera
 
Zweryfikowano, że akcja nie uruchamia się przy commicie do gałęzi `main`. Wypchnięto zmianę do `main` - w zakładce Actions widoczne pozostają wyłącznie runy z gałęzi `ino_dev`, brak nowego uruchomienia:
 
```bash
git checkout main
echo "Done" >> README_CI.md
git add README_CI.md
git commit -m "Test: should not trigger workflow"
git push origin main
```
 
![13](<img/Zrzut ekranu 2026-06-09 082133.png>)
 
Historia pokazuje workflow runy - wszystkie na gałęzi `ino_dev`. Push do `main` nie wywołał żadnej akcji, co potwierdza poprawność konfiguracji triggera.
 
- [x] Trigger działa selektywnie - reaguje tylko na zmiany w `ino_dev`

## Podsumowanie
 
### GitHub Actions jako narzędzie Shift-left
 
GitHub Actions przenosi weryfikację kodu na jak najwcześniejszy etap procesu - bezpośrednio do repozytorium. Akcja uruchamia się automatycznie przy każdym pushu do `ino_dev`, bez potrzeby utrzymywania osobnej infrastruktury CI (jak Jenkins z DIND z poprzednich laboratoriów). Konfiguracja sprowadza się do pojedynczego pliku YAML w repozytorium.
 
### Selektywny trigger
 
Konfiguracja `on: push: branches: [ino_dev]` zapewnia, że pipeline nie blokuje pracy na gałęzi `main`. Workflow uruchamia się tylko przy zmianach w dedykowanej gałęzi deweloperskiej, co jest dobrą praktyką w pracy zespołowej.
 
### Artefakt jako wynik buildu
 
Binarka `portfinder-bin` uploadowana przez `actions/upload-artifact` jest dostępna bezpośrednio z poziomu GitHub bez konieczności konfigurowania zewnętrznego rejestru. Każdy run generuje oddzielny, numerowany artefakt z odciskiem SHA-256.
 
Główne zapytania do LLM:
- "podstawowa składnia GitHub Actions workflow dla projektu Go"
Weryfikacja: obserwacja logów w zakładce Actions na GitHubie, sprawdzenie statusu poszczególnych kroków joba, weryfikacja braku uruchomienia przy pushu do `main`.
