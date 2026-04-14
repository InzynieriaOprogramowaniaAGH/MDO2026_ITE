# SPRAWOZDANIE 6

## Środowisko uruchomieniowe
    Środowisko uruchomieniowe
    System operacyjny: Ubuntu 24.04 LTS (Maszyna wirtualna)
    Metoda dostępu: Zdalna sesja przez SSH (użytkownik: karro)
    Silnik kontenerów: Docker 27.x
    Projekt testowy: portfinder (język Go)
    Edytor kodu: Visual Studio Code połączony zdalnie (Remote - SSH)

# 1.  Aplikacja i licencja
 
Wybrano projekt portfinder - narzędzie CLI w Go do skanowania otwartych portów.
- Repozytorium: https://github.com/doganarif/portfinder
- Licencja: MIT - pozwala na swobodne użycie i modyfikację kodu na potrzeby zadania.

![6](<img/Zrzut ekranu 2026-04-14 082207.png>)

    - [x] Aplikacja została wybrana
    - [x] Licencja potwierdza możliwość swobodnego obrotu kodem na potrzeby zadania
 
## 2. Program build i testy
 
Program buduje się poprawnie wewnątrz kontenera `golang:1.24-alpine`. Projekt portfinder nie zawiera plików testowych (`*_test.go`) - wywołanie `go test ./...` zwraca `[no test files]`, co jest cechą projektu, nie błędem konfiguracji.
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004732.png>)

    - [x] Przechodzą dołączone do niego testy
 
## 3. Fork repozytorium
 
Fork nie jest konieczny. Pipeline klonuje oryginalne repozytorium portfinder bezpośrednio. Pliki `Dockerfile.*` i `Jenkinsfile` przechowywane są w repozytorium przedmiotowym na gałęzi `KP419785` I nie ma potrzeby modyfikowania kodu źródłowego portfindera.

    - [x] Zdecydowano, czy jest potrzebny fork własnej kopii repozytorium
 
## 4. Diagram UML (plan procesu CI/CD)

![UML6](<img/Zrzut ekranu 2026-04-13 222806.png>)

    - [x] Stworzono diagram UML zawierający planowany pomysł na proces CI/CD

## 5. Kontener bazowy (build, test wewnątrz kontenera)
 
Kompilacja odbywa się w całości wewnątrz kontenera, bo na maszynie nie jest zainstalowane Go.
 
Pliki `Dockerfile.build`, `Dockerfile.test`, `Dockerfile.deploy` i `Jenkinsfile` dostępne są w tym samym katalogu w repozytorium.
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 000053.png>)
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004629.png>)
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 000459.png>)
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004657.png>)

    - [x] Wybrany program buduje się
    - [x] Wybrano kontener bazowy lub stworzono odpowiedni kontener wstepny (runtime dependencies)
    - [x] *Build* został wykonany wewnątrz kontenera
    - [x] Testy zostały wykonane wewnątrz kontenera (kolejnego)
    - [x] Kontener testowy jest oparty o kontener build
 
## 6. Logi jako numerowany artefakt
 
Logi z etapu Test przechwytywane są pobrane z interfejsu WWW Jenkinsa i zostały przesłane do repozytorium w folderze Sprawozdanie5.
 
![6](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094759.png>)
![6](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094808.png>)

    - [x] Logi z procesu są odkładane jako numerowany artefakt, niekoniecznie jawnie
    - [x] Zdefiniowano, jaki element ma być publikowany jako artefakt
    - [x] Opisano proces wersjonowania artefaktu (można użyć *semantic versioning*)
    - [x] Dostępność artefaktu: publikacja do Rejestru online, artefakt załączony jako rezultat builda w Jenkinsie
    - [x] Pliki Dockerfile i Jenkinsfile dostępne w sprawozdaniu w kopiowalnej postaci oraz obok sprawozdania, jako osobne pliki
 
## 7. Kontener Deploy (smoke test)
 
Kontener buildowy nie nadaje się do wdrożenia produkcyjnego, gdyż zawiera pełny toolchain Go, `make`, `git` i kod źródłowy.
 
Zastosowano multi-stage build w `Dockerfile.deploy`:
- Etap 1 (builder): klonuje repozytorium i kompiluje binarkę
- Etap 2 (runtime): czysty `alpine:latest` + tylko plik `/bin/pf`
 
Smoke test weryfikuje poprawność działania aplikacji:
```
    docker run --rm portfinder-deploy --help
```
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 005049.png>)
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004928.png>)

    - [x] Zdefiniowano kontener typu 'deploy' pełniący rolę kontenera, w którym zostanie uruchomiona aplikacja (niekoniecznie docelowo - może być tylko integracyjnie)
    - [x] Uzasadniono czy kontener buildowy nadaje się do tej roli/opisano proces stworzenia nowego, specjalnie do tego przeznaczenia
    - [x] Wersjonowany kontener 'deploy' ze zbudowaną aplikacją jest wdrażany na instancję Dockera
    - [x] Następuje weryfikacja, że aplikacja pracuje poprawnie (*smoke test*) poprzez uruchomienie kontenera 'deploy'
    - [x] Zweryfikowano potencjalną rozbieżność między zaplanowanym UML a otrzymanym efektem
 
## 8. Publish 
 
Artefakt skompresowany jako obraz Docker (portfinder-image-BUILD_NUMBER.tar.gz).

Portfinder to proste narzędzie konsolowe. Spakowanie go jako obrazu Docker pozwala uruchomić go na dowolnej maszynie bez instalowania Go, więc wystarczy jedna komenda:

```
    docker load < portfinder-image-12.tar.gz
```

Każdy plik ma w nazwie numer buildu z Jenkinsa, np. portfinder-image-12.tar.gz. Jenkins automatycznie zwiększa ten numer przy każdym uruchomieniu.

Jenkins zapisuje też sumę kontrolną (fingerprint) każdego pliku, więc można zweryfikować że plik nie został podmieniony
 
## 9. Widok pipeline i ponowne uruchomienie
 
Pipeline uruchomiony wielokrotnie.
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 100219.png>)
 
## 10. Weryfikacja rozbieżności z diagramem UML

    - Manual trigger (wykonany)
    - Clone (wykonany)
    - Build (wykonany)
    - Test (wykonany)
    - Deploy (multi-stage) (wykonany)
    - Smoke test (wykonany)
    - Publish (tar.gz) (wykonany)
    - Etap Clean (wykonany)
 
Dodano jedynie etap Clean, zapobiega on konfliktom nazw obrazów między buildami.

    - [x] Uzasadniono wybór: kontener z programem, plik binarny, flatpak, archiwum tar.gz, pakiet RPM/DEB
    - [x] Przedstawiono sposób na zidentyfikowanie pochodzenia artefaktu
 
*Podział na stage pipline'u zawarte w pliku `pipeline.txt` w folderze Sprawozdanie6*
