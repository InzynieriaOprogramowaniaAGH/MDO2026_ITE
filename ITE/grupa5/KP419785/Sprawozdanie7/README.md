# SPRAWOZDANIE 7

## Środowisko uruchomieniowe
    Środowisko uruchomieniowe
    System operacyjny: Ubuntu 24.04 LTS (Maszyna wirtualna)
    Metoda dostępu: Zdalna sesja przez SSH (użytkownik: karro)
    Silnik kontenerów: Docker 27.x
    Projekt testowy: portfinder (język Go)
    Edytor kodu: Visual Studio Code połączony zdalnie (Remote - SSH)


## 1. Przepis dostarczany z SCM

Jenkinsfile nie jest wklejony ręcznie w interfejsie Jenkinsa, pobierany jest bezpośrednio z repozytorium przedmiotowego. W konfiguracji projektu ustawiono:

- **Definition:** Pipeline script from SCM
- **SCM:** Git
- **Repository URL:** `https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git`
- **Branch:** `KP419785`
- **Script Path:** `ITE/grupa5/KP419785/Sprawozdanie5/Jenkinsfile`

Dzięki temu infrastruktura budowania jest częścią kodu i wersjonowana razem z projektem.

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 022539.png>)
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 011032.png>)

    - [x] Przepis dostarczany z SCM, a nie wklejony w Jenkinsa lub sprawozdanie (co załatwia nam `clone` )

## 2. Clean 

Pierwszy etap pipeline'u (`Clean`) wykonuje:

```
    docker system prune -f
    rm -rf MDO2026_ITE
```

Usuwa wszystkie nieużywane obrazy Docker oraz poprzednio sklonowane repozytorium. Dzięki temu każde uruchomienie zaczyna od czystego stanu i nie ma ryzyka korzystania z cache'owanych warstw lub starego kodu.

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 094808.png>)

    - [x] Posprzątaliśmy i wiemy, że odbyło się to skutecznie - mamy pewność, że pracujemy na najnowszym (a nie *cache'owanym* kodzie)

## 3. Etap Build (repo, dockerfile)

Po etapie Clone Jenkins dysponuje pełnym repozytorium na gałęzi `KP419785`. Etap Build przechodzi do katalogu `ITE/grupa5/KP419785/Sprawozdanie6` gdzie znajdują się wszystkie potrzebne pliki (`Dockerfile.build`, `Dockerfile.test`, `Dockerfile.deploy`).

Budowany jest obraz buildowy:

```
    docker build --no-cache -t portfinder-build -f Dockerfile.build .
```

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 000053.png>)
![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004629.png>)

    - [x] Etap `Build` dysponuje repozytorium i plikami `Dockerfile`

## 4. Etap Build (image)

Obraz `portfinder-build` bazuje na `golang:1.24-alpine` (konkretny tag, nie `latest`), klonuje repozytorium portfinder i kompiluje binarkę przez `go build`. Użycie konkretnego tagu gwarantuje powtarzalność buildów.

    - [x] Etap `Build` tworzy obraz buildowy, np. `BLDR`

## 5. Przygotowanie artefaktu

Kontener docelowy jest celowo inny niż buildowy. `Dockerfile.deploy` stosuje multi-stage build:

- **Etap 1 (builder):** kompilacja na bazie `golang:1.24-alpine`
- **Etap 2 (runtime):** czysty `alpine:latest` + tylko plik `/bin/pf` + `ENTRYPOINT ["pf"]`

Finalny obraz nie zawiera toolchain Go ani kodu źródłowego, waży kilka MB zamiast kilkuset.

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004928.png>)

    - [x] Etap `Build` (krok w tym etapie) lub oddzielny etap (o innej nazwie), przygotowuje artefakt - **jeżeli docelowy kontener ma być odmienny**, tj. nie wywodzimy `Deploy` z obrazu `BLDR`

## 6. Etap Test

Obraz testowy bazuje na `portfinder-build:latest` i uruchamia `go test ./...`. Logi przechwytywane są do pliku i archiwizowane jako numerowany artefakt.

```
    docker build --no-cache --progress=plain -t portfinder-test -f Dockerfile.test . 2>&1 | tee test-output.log
```

Projekt portfinder nie zawiera plików `*_test.go`. Wynik `[no test files]` jest cechą projektu, nie błędem.

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 004732.png>)

    - [x] Etap `Test` przeprowadza testy

## 7. Etap Deploy 

Etap Deploy buduje `portfinder-deploy` z `ENTRYPOINT ["pf"]`. Obraz gotowy do uruchomienia bez dodatkowej konfiguracji. Następnie przeprowadzany jest smoke test:

```
    docker run --rm portfinder-deploy --help
```

Kontener uruchamia się, wyświetla pomoc i kończy z kodem 0.

![7](<../Sprawozdanie5/img/Zrzut ekranu 2026-03-31 005049.png>)

    - [x] Etap `Deploy` przygotowuje **obraz lub artefakt** pod wdrożenie. W przypadku aplikacji pracującej jako kontener, powinien to być obraz z odpowiednim entrypointem. W przypadku buildu tworzącego artefakt niekoniecznie pracujący jako kontener (np. interaktywna aplikacja desktopowa), należy przesłać i uruchomić artefakt w środowisku docelowym.
    - [x] Etap `Deploy` przeprowadza wdrożenie (start kontenera docelowego lub uruchomienie aplikacji na przeznaczonym do tego celu kontenerze sandboxowym)

## 8. Etap Publish

Gotowy obraz pakowany jest do archiwum i dodawany do historii builda:

```
    docker save portfinder-deploy | gzip > portfinder-image-${BUILD_NUMBER}.tar.gz
    archiveArtifacts artifacts: '*.tar.gz', fingerprint: true
```

Artefakt dostępny do pobrania z interfejsu WWW Jenkinsa. Numer buildu w nazwie pozwala jednoznacznie zidentyfikować jego pochodzenie.

![7](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094759.png>)

    - [x] Etap `Publish` wysyła obraz docelowy do Rejestru i/lub dodaje artefakt do historii builda

## 9. Pipeline 

Build #12 i #13 zakończone sukcesem z kompletnymi artefaktami. Etap Clean skutecznie usuwa poprzedni stan. Każde uruchomienie jest niezależne.

![7](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_094759.png>)
![7](<../Sprawozdanie5/img/Zrzut_ekranu_2026-03-31_100219.png>)

    - [x] Ponowne uruchomienie naszego *pipeline'u* powinno zapewniać, że pracujemy na najnowszym (a nie *cache'owanym*) kodzie. Innymi słowy, *pipeline* musi zadziałać więcej niż jeden raz 😎

## Definition of done

Artefakt `portfinder-12.tar.gz` pobrany z Jenkinsa załadowano i uruchomiono bezpośrednio na maszynie wirtualnej, całkowicie poza środowiskiem Jenkins:

```
    docker load < portfinder-12.tar.gz
    docker run --rm app-deploy --help
```

Aplikacja uruchomiła się poprawnie, zatem artefakt działa na maszynie docelowej bez żadnych modyfikacji.

![7](<img/Zrzut ekranu 2026-04-21 234420.png>)

**Czy artefakt może być pobrany i uruchomiony bez modyfikacji?**
Tak. Jedynym wymaganiem jest działający Docker. Obraz jest samowystarczalny. Zawiera statyczną binarkę Go i minimalny system Alpine.

**Czy artefakt zadziała od razu na maszynie o oczekiwanej konfiguracji?**
Tak. Binarka Go jest statyczna, nie ma zależności systemowych. Wystarczy `docker load` i `docker run`.

## Jenkinsfile

Plik dostępny w repozytorium pod ścieżką `ITE/grupa5/KP419785/Sprawozdanie5/Jenkinsfile` oraz w folderze `Sprawozdanie7`.

