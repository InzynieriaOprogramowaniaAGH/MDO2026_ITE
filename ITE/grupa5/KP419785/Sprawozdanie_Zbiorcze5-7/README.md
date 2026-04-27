# SPRAWOZDANIE ZBIORCZE 5–7
### Kinga Pytel
 
## Środowisko uruchomieniowe
    Środowisko uruchomieniowe
    System operacyjny: Ubuntu 24.04 LTS (Maszyna wirtualna)
    Metoda dostępu: Zdalna sesja przez SSH (użytkownik: karro)
    Silnik kontenerów: Docker 27.x
    Projekt testowy: portfinder (język Go)
    Edytor kodu: Visual Studio Code połączony zdalnie (Remote - SSH)
 
# LABORATORIUM 5 
 
## 1. Uruchomienie instancji Jenkins (Docker-in-Docker)
 
Aby umożliwić Jenkinsowi bezpieczne budowanie kontenerów, zastosowano podejście Docker-in-Docker (DIND). Konfiguracja wymaga dwóch powiązanych kontenerów w izolowanej sieci mostkowej. Zaletą względem montowania gniazda hosta jest pełna izolacja środowiska CI.
 
Uruchomiono kontener DIND, a następnie kontener `jenkins-blueocean`. Różnica między oficjalnym obrazem `jenkins/jenkins` a wariantem blueocean: blueocean ma doinstalowanego klienta Docker CLI oraz wtyczki Blue Ocean, niezbędne do komunikacji z DIND.
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 231703.png>)
 
Skonfigurowano przekierowanie portu 8080 w VS Code (Remote SSH) dla dostępu do panelu z maszyny fizycznej:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 234024.png>)
 
Ekran logowania i pobranie Initial Admin Password z wnętrza kontenera:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 234048.jpg>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 234223.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 234310.png>)
 
## 2. Zadania wstępne
 
Projekt 1: Wyświetlenie `uname -a`
 
Zdefiniowano krok budowania wykonujący skrypt powłoki `uname -a`. Zadanie zakończyło się sukcesem, zwracając informacje o architekturze wewnątrz kontenera:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 234908.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 235212.png>)
 
Projekt 2: Błąd przy nieparzystej godzinie
 
Skrypt sprawdza aktualną godzinę - jeśli reszta z dzielenia przez 2 nie wynosi 0, zwraca `exit 1`. Test wykonano o 8:00 czasu polskiego (6:00 UTC), Jenkins poprawnie zakończył się sukcesem:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 235454.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 082519.png>)
 
```
    hour=$(date +%-H)
    if [ $((hour % 2)) -ne 0 ]; then exit 1; fi
```
 
Projekt 3: Pobranie obrazu ubuntu
 
Zadanie weryfikowało komunikację Jenkins-DIND-Docker Hub przez `docker pull ubuntu`. Sukces potwierdza poprawną konfigurację sieci:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-30 235705.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 001718.png>)
 
## 3. Kompletny Pipeline CI/CD
 
Stworzono plik `Jenkinsfile` i umieszczono go w repozytorium. Pliki Dockerfile dla poszczególnych etapów wgrane do repozytorium przez git:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 003738.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004555.png>)
 
Zadanie typu Pipeline podłączono do repozytorium przedmiotowego na gałęzi `KP419785`:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 022539.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 011032.png>)
 
Uruchomienie procesu:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 091422.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 090742.png>)
 
### Etap: Build
 
Dockerfile.build bazuje na `golang:1.24-alpine`. Instaluje `make` i `git`, klonuje portfinder i kompiluje przez `go build`:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 000053.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004629.png>)
 
### Etap: Test
 
Dockerfile.test dziedziczy po `app-build:latest` i uruchamia `go test ./...`. Projekt portfinder nie zawiera plików `*_test.go` - wynik `[no test files]` jest cechą projektu, nie błędem:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 000459.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004657.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004732.png>)
 
### Etap: Deploy
 
Kontener buildowy nie nadaje się do wdrożenia produkcyjnego - zawiera pełny toolchain Go, `make`, `git` i kod źródłowy. Zastosowano multi-stage build w `Dockerfile.deploy`:
- Etap 1 (builder): `golang:1.24-alpine` kompiluje binarkę `/bin/pf`
- Etap 2 (runtime): czysty `alpine:latest` + wyłącznie `/bin/pf` + `ENTRYPOINT ["pf"]`
Finalny obraz waży kilka MB zamiast kilkuset. Różnica między `node` a `node-slim` jest analogiczna - pełny obraz zawiera narzędzia deweloperskie zbędne w produkcji.
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004928.png>)
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 005032.png>)
 
Smoke test:
 
![5](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 005049.png>)
 
```
    docker run --rm portfinder-deploy --help
```
 
### Etap: Publish
 
Gotowy obraz pakowany do archiwum i archiwizowany jako artefakt Jenkins:
 
```
    docker save app-deploy | gzip > portfinder-${BUILD_NUMBER}.tar.gz
    archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
```
 
# LABORATORIUM 6
 
## 1. Aplikacja i licencja
 
Wybrano projekt portfinder.
- Repozytorium: https://github.com/doganarif/portfinder
- Licencja: MIT - pozwala na swobodne użycie i modyfikację kodu na potrzeby zadania.
![6](<../Sprawozdanie6/img/Zrzut ekranu 2026-04-14 082207.png>)
 
- [x] Aplikacja została wybrana
- [x] Licencja potwierdza możliwość swobodnego obrotu kodem na potrzeby zadania

## 2. Build i testy wewnątrz kontenera
 
Program buduje się poprawnie wewnątrz kontenera `golang:1.24-alpine`. Wynik `[no test files]` jest cechą projektu:
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004732.png>)
 
- [x] Wybrany program buduje się
- [x] Przechodzą dołączone do niego testy
- [x] Wybrano kontener bazowy (`golang:1.24-alpine`)
- [x] Build wykonany wewnątrz kontenera
- [x] Testy wykonane wewnątrz kontenera (kolejnego)
- [x] Kontener testowy jest oparty o kontener build

## 3. Fork repozytorium
 
Fork nie jest konieczny. Pipeline klonuje oryginalne repozytorium bezpośrednio. Pliki `Dockerfile.*` i `Jenkinsfile` przechowywane są w repozytorium przedmiotowym na gałęzi `KP419785` - nie ma potrzeby modyfikowania kodu źródłowego portfindera.
 
- [x] Zdecydowano, czy jest potrzebny fork własnej kopii repozytorium

## 4. Diagram UML - plan procesu CI/CD
 
![UML6](<../Sprawozdanie6/img/Zrzut ekranu 2026-04-13 222806.png>)
 
- [x] Stworzono diagram UML zawierający planowany pomysł na proces CI/CD

## 5. Logi jako numerowany artefakt
 
Logi z etapu Test przechwytywane są przez `tee` i odkładane jako plik z numerem buildu:
 
```
    docker build --no-cache --progress=plain -t portfinder-test -f Dockerfile.test . 2>&1 | tee test-output.log
```
 
![6](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094759.png>)
![6](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094808.png>)
 
- [x] Logi z procesu są odkładane jako numerowany artefakt
- [x] Zdefiniowano, jaki element ma być publikowany jako artefakt
- [x] Opisano proces wersjonowania artefaktu (numer buildu Jenkins)
- [x] Dostępność artefaktu: artefakt załączony jako rezultat builda w Jenkinsie
- [x] Pliki Dockerfile i Jenkinsfile dostępne w sprawozdaniu oraz obok jako osobne pliki

## 6. Kontener Deploy - smoke test
 
Kontener buildowy nie nadaje się do wdrożenia - zawiera pełny toolchain Go. Zastosowano multi-stage build (`Dockerfile.deploy`):
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004928.png>)
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 005049.png>)
 
- [x] Zdefiniowano kontener 'deploy' pełniący rolę kontenera uruchomieniowego
- [x] Uzasadniono, czy kontener buildowy nadaje się do tej roli
- [x] Wersjonowany kontener 'deploy' wdrożony na instancję Dockera
- [x] Następuje weryfikacja poprawności działania aplikacji (smoke test)
- [x] Zweryfikowano potencjalną rozbieżność między zaplanowanym UML a otrzymanym efektem

## 7. Publish - wybór formy artefaktu
 
Artefakt: obraz Docker skompresowany jako `portfinder-image-{BUILD_NUMBER}.tar.gz`.
 
Portfinder to proste narzędzie konsolowe. Spakowanie go jako obrazu Docker pozwala uruchomić go na dowolnej maszynie bez instalowania Go - wystarczy:
 
```
    docker load < portfinder-image-12.tar.gz
```
 
Każdy plik ma w nazwie numer buildu z Jenkinsa. Jenkins zapisuje też fingerprint pliku, pozwalający zweryfikować, że plik nie został podmieniony.
 
![6](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 100219.png>)
 
- [x] Uzasadniono wybór artefaktu: obraz Docker jako archiwum tar.gz
- [x] Przedstawiono sposób na zidentyfikowanie pochodzenia artefaktu

## 8. Weryfikacja rozbieżności z diagramem UML
 
Wszystkie zaplanowane etapy zostały wykonane. Jedyna różnica: dodano etap `Clean` zapobiegający konfliktom nazw obrazów między buildami.
 
    - Manual trigger (wykonany)
    - Clone (wykonany)
    - Build (wykonany)
    - Test (wykonany)
    - Deploy (multi-stage) (wykonany)
    - Smoke test (wykonany)
    - Publish (tar.gz) (wykonany)
    - Etap Clean (wykonany)

 
# LABORATORIUM 7
 
## 1. Przepis dostarczany z SCM
 
Jenkinsfile nie jest wklejony ręcznie - pobierany jest bezpośrednio z repozytorium. Infrastruktura budowania jest częścią kodu i wersjonowana razem z projektem.
 
Konfiguracja projektu Jenkins:
- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- **Branch:** `KP419785`
- **Script Path:** `ITE/grupa5/KP419785/Sprawozdanie5/Jenkinsfile`

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 022539.png>)
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 011032.png>)
 
- [x] Przepis dostarczany z SCM, a nie wklejony w Jenkinsa lub sprawozdanie

## 2. Etap Clean
 
Pierwszy etap pipeline'u usuwa nieużywane obrazy Docker i poprzednio sklonowane repozytorium. Każde uruchomienie zaczyna od czystego stanu:
 
```
    docker system prune -f
    rm -rf MDO2026_ITE
```
 
![7](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094808.png>)
 
- [x] Posprzątaliśmy - pracujemy na najnowszym, nie cache'owanym kodzie

## 3. Etap Build
 
Po etapie Clone Jenkins dysponuje pełnym repozytorium na gałęzi `KP419785`. Etap Build przechodzi do katalogu `ITE/grupa5/KP419785/Sprawozdanie6` z plikami Dockerfile i buduje obraz z flagą `--no-cache`:
 
```
    docker build --no-cache -t portfinder-build -f Dockerfile.build .
```
 
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 000053.png>)
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004629.png>)
 
- [x] Etap Build dysponuje repozytorium i plikami Dockerfile
- [x] Etap Build tworzy obraz buildowy (BLDR)
## 4. Przygotowanie artefaktu
 
Kontener docelowy jest celowo inny niż buildowy. `Dockerfile.deploy` stosuje multi-stage build - finalny obraz nie zawiera toolchain Go ani kodu źródłowego:
 
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004928.png>)
 
- [x] Etap Build przygotowuje artefakt (docelowy kontener różni się od BLDR)

## 5. Etap Test
 
Obraz testowy bazuje na `portfinder-build:latest` i uruchamia `go test ./...`. Logi archiwizowane jako numerowany artefakt:
 
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004732.png>)
 
- [x] Etap Test przeprowadza testy

## 6. Etap Deploy
 
Etap buduje `portfinder-deploy` z `ENTRYPOINT ["pf"]` i przeprowadza smoke test:
 
```
    docker run --rm portfinder-deploy --help
```
 
Kontener uruchamia się, wyświetla pomoc i kończy z kodem 0:
 
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 005049.png>)
 
- [x] Etap Deploy przygotowuje obraz z odpowiednim entrypointem
- [x] Etap Deploy przeprowadza wdrożenie (smoke test kontenera docelowego)

## 7. Etap Publish
 
Gotowy obraz pakowany do archiwum i dodawany do historii builda:
 
```
    docker save portfinder-deploy | gzip > portfinder-image-${BUILD_NUMBER}.tar.gz
    archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
```
 
![7](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094759.png>)
 
- [x] Etap Publish dodaje artefakt do historii builda

## 8. Wielokrotne uruchomienie i Definition of Done
 
Build #12 i #13 zakończone sukcesem. Etap Clean gwarantuje niezależność każdego uruchomienia:
 
![7](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094759.png>)
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 100219.png>)
 
Artefakt `portfinder-12.tar.gz` załadowano i uruchomiono bezpośrednio na maszynie wirtualnej, poza środowiskiem Jenkins:
 
```
    docker load < portfinder-12.tar.gz
    docker run --rm app-deploy --help
```
 
![7](<../Sprawozdanie7/img/Zrzut ekranu 2026-04-21 234420.png>)
 
**Czy obraz może być pobrany i uruchomiony bez modyfikacji?**
Tak. Jedynym wymaganiem jest działający Docker. Obraz jest samowystarczalny - zawiera statyczną binarkę Go i minimalny system Alpine.
 
**Czy artefakt zadziała od razu na maszynie docelowej?**
Tak. Binarka Go jest statyczna, bez zależności systemowych. Wystarczy `docker load` i `docker run`.
 
- [x] Ponowne uruchomienie pipeline'u zapewnia pracę na najnowszym kodzie - pipeline działa więcej niż jeden raz
 
# Podsumowanie
 
### Jenkins + DIND
Jenkins w konfiguracji Docker-in-Docker pozwala agentom CI/CD budować własne kontenery w izolowanym środowisku. DIND jest bezpieczniejszy od montowania gniazda hosta (`/var/run/docker.sock`), gdyż agenci nie mają bezpośredniego dostępu do demona hosta.
 
### Pipeline CI/CD
Pipeline realizuje pełny cykl: Clean-Clone-Build-Test-Deploy-Publish. Kluczowe decyzje: użycie konkretnego tagu obrazu (`golang:1.24-alpine` zamiast `latest`) dla powtarzalności buildów, multi-stage build dla minimalnego obrazu produkcyjnego, oraz artefakt w formie tar.gz z numerem buildu dla identyfikowalności.
 
### Jenkinsfile jako kod
Umieszczenie Jenkinsfile w repozytorium sprawia, że infrastruktura budowania jest wersjonowana razem z kodem. Etap `Clean` z `--no-cache` gwarantuje, że każde uruchomienie jest deterministyczne i nie korzysta z przestarzałych warstw.
 
Główne zapytania do LLM:
- "jak połączyć kontenery Jenkins i DIND ze sobą?"
- "podstawowa składnia Jenkinsfile (Build, Test, Deploy) dla Go"
- "jak zmniejszyć wagę kontenera?"
Weryfikacja: testy w panelu Jenkinsa, sprawdzanie logów z budowania, dokumentacja Dockera i Jenkinsa.
 
*Listing historii poleceń zawarty w pliku `history.txt` w folderach Sprawozdanie5, Sprawozdanie6, Sprawozdanie7*
*Podział na stage pipeline'u zawarty w pliku `pipeline.txt` w folderze Sprawozdanie6*