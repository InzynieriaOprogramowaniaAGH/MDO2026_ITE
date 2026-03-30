# Sprawozdanie Zbiorcze - PS422034
## Laboratoria 1–4: Git, Docker, Konteneryzacja, CI/CD

---

## Wstęp

Niniejsze sprawozdanie stanowi zbiorcze podsumowanie czterech laboratoriów zrealizowanych w ramach kursu z Inżynierii Oprogramowania. Tematyka zajęć obejmowała nowoczesne narzędzia stosowane w profesjonalnym procesie wytwarzania oprogramowania - od zarządzania kodem źródłowym z wykorzystaniem systemu Git i protokołu SSH, przez konteneryzację aplikacji przy użyciu platformy Docker, aż po wdrożenie skonteneryzowanego serwera ciągłej integracji Jenkins. Kolejne laboratoria stanowiły rozwinięcie wiedzy zdobytej na poprzednich zajęciach, tworząc spójny obraz pracy w środowisku DevOps.

---

## Omówienie użytych technologii i pojęć

### System kontroli wersji

System kontroli wersji (ang. *Version Control System*, VCS) to oprogramowanie umożliwiające śledzenie i zarządzanie historią zmian w plikach - w szczególności w kodzie źródłowym. Każda zarejestrowana zmiana przechowywana jest jako odrębna migawka (commit) wraz z informacją o autorze, dacie oraz opisem wprowadzonych modyfikacji. Systemy VCS dzielą się na scentralizowane, w których pełna historia zmian przechowywana jest na jednym serwerze (np. SVN), oraz rozproszone, gdzie każdy uczestnik projektu posiada lokalną, kompletną kopię całego repozytorium (np. Git). Podejście rozproszone stało się standardem branżowym ze względu na możliwość pracy w trybie offline, prostsze zarządzanie gałęziami oraz niezależność od dostępności serwera centralnego.

### Git

Git jest rozproszonym systemem kontroli wersji stworzonym w 2005 roku przez Linusa Torvaldsa na potrzeby zarządzania kodem źródłowym jądra Linuksa. Wewnętrznie Git reprezentuje historię projektu w postaci grafu skierowanego acyklicznego (ang. *Directed Acyclic Graph*, DAG), w którym każdy commit wskazuje na swojego poprzednika lub poprzedników. Wszystkie dane repozytorium przechowywane są w ukrytym katalogu `.git`. Serwer zdalny pełni wyłącznie rolę punktu synchronizacji - nie jest wymagany do lokalnej pracy. Podstawowe operacje obejmują: `git init` oraz `git clone` (inicjalizacja i klonowanie), `git add` i `git commit` (rejestrowanie zmian), `git push` i `git pull` (synchronizacja ze zdalnym repozytorium), a także `git merge` i `git rebase` (scalanie gałęzi).

### Gałęzie w systemie Git

Gałąź w systemie Git jest lekkim, przesuwalnym wskaźnikiem na konkretny commit. Jej utworzenie jest operacją natychmiastową, ponieważ nie wiąże się z kopiowaniem plików - tworzony jest jedynie nowy wskaźnik. Mechanizm gałęzi umożliwia równoległe prowadzenie prac nad różnymi funkcjonalnościami bez wzajemnych zakłóceń. Przyjęty w branży model pracy (np. Git Flow) zakłada istnienie gałęzi głównej (`main`), gałęzi deweloperskiej (`develop`) oraz krótkotrwałych gałęzi funkcjonalnych (`feature/*`). Scalanie gałęzi realizowane jest przez `git merge` - zachowujące pełną historię obu gałęzi - lub `git rebase`, które przepisuje historię w sposób liniowy. Mechanizm Pull Request (PR), dostępny na platformach takich jak GitHub i GitLab, pozwala na przeprowadzenie przeglądu kodu (ang. *code review*) przed scaleniem zmian z gałęzią docelową.

### Personal Access Token

Personal Access Token (PAT) jest generowanym przez platformę ciągiem znaków zastępującym hasło użytkownika przy uwierzytelnieniu przez HTTPS lub API. W odróżnieniu od hasła, token może posiadać ściśle określony zakres uprawnień oraz datę wygaśnięcia, a jego unieważnienie jest możliwe w dowolnym momencie bez konieczności zmiany hasła głównego. Rozwiązanie to jest stosowane wszędzie tam, gdzie wymagane jest uwierzytelnienie automatyczne - w skryptach CI/CD, narzędziach deweloperskich oraz aplikacjach integrujących się z platformą przez API.

### Protokół SSH

SSH (ang. *Secure Shell*) jest kryptograficznym protokołem sieciowym umożliwiającym bezpieczną komunikację między dwoma urządzeniami poprzez niezaufaną sieć. Protokół zapewnia poufność transmisji poprzez szyfrowanie, integralność danych oraz wzajemne uwierzytelnienie obu stron połączenia. SSH działa w architekturze klient–serwer: po stronie serwera działa demon `sshd` nasłuchujący domyślnie na porcie 22, po stronie klienta używa się polecenia `ssh`. Dostępne są dwie metody uwierzytelnienia użytkownika: z użyciem hasła oraz z użyciem klucza kryptograficznego. Poza interaktywnym dostępem do zdalnego terminala SSH obsługuje również bezpieczny transfer plików (protokoły SCP i SFTP) oraz tunelowanie ruchu TCP.

### Kryptografia asymetryczna i klucze SSH

Klucze SSH opierają się na kryptografii asymetrycznej, w której każdy podmiot dysponuje parą matematycznie powiązanych kluczy: publicznego i prywatnego. Klucz publiczny umieszczany jest na serwerach docelowych w pliku `~/.ssh/authorized_keys` i może być swobodnie udostępniany. Klucz prywatny pozostaje wyłącznie w posiadaniu właściciela i nigdy nie powinien opuszczać jego urządzenia. Uwierzytelnienie przebiega następująco: serwer wystawia losowe wyzwanie kryptograficzne; klient podpisuje je kluczem prywatnym i odsyła podpis; serwer weryfikuje podpis przy użyciu klucza publicznego. Algorytm Ed25519, oparty na krzywych eliptycznych, oferuje wysokie bezpieczeństwo przy krótkich kluczach i jest obecnie zalecanym wyborem. Klucz prywatny może być dodatkowo zabezpieczony hasłem (ang. *passphrase*), co chroni przed nieautoryzowanym użyciem nawet w przypadku jego przechwycenia.

### Git Hooks

Git Hooks to mechanizm umożliwiający automatyczne wykonywanie skryptów w odpowiedzi na określone zdarzenia systemu Git. Skrypty umieszczane są w katalogu `.git/hooks/` i muszą posiadać nazwy odpowiadające konkretnym punktom zaczepienia. Najważniejsze z nich to: `pre-commit` (wykonywany przed zapisaniem commita, stosowany do uruchamiania linterów i testów), `commit-msg` (weryfikacja treści wiadomości commita), `pre-push` (uruchamiany przed wysłaniem zmian do repozytorium zdalnego) oraz `post-merge` (wykonywany po scaleniu gałęzi). Zwrócenie kodu wyjścia równego zero oznacza akceptację operacji; każda inna wartość powoduje jej przerwanie. Hooki mają charakter lokalny - nie są przenoszone podczas klonowania repozytorium.

### Wirtualizacja a konteneryzacja

Wirtualizacja polega na emulowaniu kompletnego środowiska sprzętowego, co umożliwia uruchamianie wielu niezależnych systemów operacyjnych na jednym hoście fizycznym. Każda maszyna wirtualna posiada własne jądro, sterowniki i wirtualne zasoby sprzętowe, co zapewnia wysoki stopień izolacji, lecz wiąże się ze znacznym narzutem zasobów obliczeniowych i pamięci. Konteneryzacja stanowi lżejszą alternatywę: kontenery współdzielą jądro systemu operacyjnego hosta, a ich izolacja realizowana jest przez mechanizmy jądra Linux - `namespaces` (izolacja przestrzeni nazw procesów, sieci i systemu plików) oraz `cgroups` (ograniczenie i monitorowanie zasobów). Kontener uruchamia się w ułamku sekundy i zużywa wielokrotnie mniej zasobów niż maszyna wirtualna, przy nieznacznie słabszej izolacji.

### Docker

Docker to platforma do budowania, dystrybucji i uruchamiania kontenerów, która znacząco przyczyniła się do upowszechnienia konteneryzacji w branży. Architektura Dockera obejmuje: demon `dockerd` zarządzający cyklem życia kontenerów i obrazów, klienta wiersza poleceń `docker` komunikującego się z demonem przez API REST, oraz rejestr obrazów (publiczny Docker Hub lub prywatny). Docker wykorzystuje warstwowy system plików - każda instrukcja w Dockerfile tworzy nową, niemutowalną warstwę, która może być współdzielona między obrazami, co ogranicza zużycie miejsca na dysku. Obraz jest niezmiennym szablonem zawierającym aplikację i jej zależności; kontener jest działającą instancją obrazu.

### Dockerfile

Dockerfile jest deklaratywnym plikiem tekstowym opisującym sekwencję kroków prowadzących do zbudowania obrazu Dockera. Każda instrukcja tworzy nową warstwę. Do najistotniejszych instrukcji należą: `FROM` (obraz bazowy), `RUN` (polecenie wykonywane podczas budowania), `COPY`/`ADD` (kopiowanie plików do obrazu), `WORKDIR` (katalog roboczy), `ENV` (zmienne środowiskowe), `EXPOSE` (dokumentacja portu nasłuchiwanego przez aplikację), `CMD` i `ENTRYPOINT` (polecenie uruchamiane przy starcie kontenera). Do zalecanych praktyk budowania obrazów należą: minimalizacja liczby warstw przez łączenie powiązanych instrukcji `RUN`, usuwanie cache menedżera pakietów w tej samej warstwie co instalacja, stosowanie konkretnych tagów obrazów bazowych zamiast `latest`, a także zasada minimalnych uprawnień.

### Multi-stage build

Multi-stage build (budowanie wieloetapowe) to technika definiowania wielu etapów w jednym Dockerfile, z których każdy może bazować na innym obrazie bazowym. Typowy schemat zakłada etap budowania (*builder*), zawierający kompilator, SDK i narzędzia deweloperskie, który produkuje artefakt końcowy, oraz etap produkcyjny, bazujący na lekkim obrazie bazowym i zawierający wyłącznie pliki niezbędne do działania aplikacji. Finalny obraz nie zawiera narzędzi budowania ani zależności deweloperskich, co redukuje jego rozmiar i ogranicza potencjalną powierzchnię ataku.

### Docker Compose

Docker Compose jest narzędziem do definiowania i zarządzania aplikacjami wielokontenerowymi. Konfiguracja zapisywana jest w pliku `docker-compose.yml` w formacie YAML, w którym opisuje się wszystkie usługi tworzące aplikację, ich wzajemne zależności, woluminy, sieci i zmienne środowiskowe. Całość uruchamiana jest poleceniem `docker compose up`, a zatrzymywana poleceniem `docker compose down`. Klauzula `depends_on` określa kolejność uruchamiania usług. Docker Compose jest narzędziem przeznaczonym głównie dla środowisk deweloperskich i potoków CI/CD; w środowiskach produkcyjnych o dużej skali stosuje się orkiestratory takie jak Kubernetes.

### Woluminy Docker

Woluminy stanowią rekomendowany przez Docker mechanizm trwałego przechowywania danych poza cyklem życia kontenera. Dane zapisane w woluminie zachowywane są po zatrzymaniu, restarcie i usunięciu kontenera. Docker zarządza woluminami we własnym katalogu (domyślnie `/var/lib/docker/volumes/`), co odróżnia je od bind mountów, w których użytkownik wskazuje konkretną ścieżkę na hoście. Wolumin może być jednocześnie podłączony do wielu kontenerów, co jest szczególnie przydatne przy przekazywaniu artefaktów między etapami potoku CI/CD. Alternatywną formą montowania jest `tmpfs mount`, w którym dane przechowywane są wyłącznie w pamięci operacyjnej i usuwane po zatrzymaniu kontenera.

### Sieci Docker

Docker udostępnia kilka typów sieci wirtualnych. Sieć `bridge` jest typem domyślnym - kontenery podłączone do tej samej sieci mostkowej mogą się ze sobą komunikować, a ruch wychodzący do sieci zewnętrznej przechodzi przez mechanizm NAT. Sieć `host` eliminuje izolację sieciową kontenera, który korzysta bezpośrednio z interfejsów sieciowych hosta. Sieć `none` całkowicie odcina kontener od sieci. Użytkownik może tworzyć własne sieci mostkowe poleceniem `docker network create`; sieci te posiadają wbudowany serwer DNS, umożliwiający adresowanie kontenerów po ich nazwie zamiast dynamicznie przydzielanego adresu IP - co jest kluczową funkcją w środowiskach wielokontenerowych.

### Continuous Integration i Continuous Delivery

Continuous Integration (CI) to praktyka inżynierii oprogramowania polegająca na automatycznym budowaniu i testowaniu kodu przy każdej wprowadzonej zmianie. Celem jest wczesne wykrywanie błędów integracyjnych i utrzymanie kodu w stanie gotowym do wdrożenia. Continuous Delivery (CD) rozszerza CI o automatyczne przygotowanie artefaktu gotowego do wdrożenia na środowisko produkcyjne. Continuous Deployment stanowi kolejny krok, w którym każda zmiana przechodząca przez potok jest automatycznie wdrażana na produkcję. Potoki CI/CD realizowane są przez narzędzia takie jak Jenkins, GitHub Actions, GitLab CI czy CircleCI i składają się z etapów: pobranie kodu, budowanie, testy jednostkowe, testy integracyjne, analiza statyczna, budowanie artefaktu i wdrożenie.

### Jenkins

Jenkins jest jednym z najpowszechniej stosowanych serwerów automatyzacji CI/CD, utrzymywanym jako projekt open-source. Jego elastyczność wynika z rozbudowanego ekosystemu wtyczek, obejmującego ponad 1800 rozszerzeń umożliwiających integrację z praktycznie każdym narzędziem deweloperskim. Potoki w Jenkinsie definiuje się w plikach `Jenkinsfile` przy użyciu języka Groovy w postaci deklaratywnej lub skryptowej. Jenkins działa w architekturze kontroler–agenci: kontroler zarządza konfiguracją, harmonogramem i kolejką zadań, natomiast agenci wykonują właściwą pracę. W środowiskach skonteneryzowanych agenci często przyjmują postać efemerycznych kontenerów Dockera, powoływanych na czas trwania konkretnego zadania.

### Docker-in-Docker

Docker-in-Docker (DIND) to technika uruchamiania demona Dockera wewnątrz kontenera Dockera. Jest stosowana w środowiskach CI, gdzie serwer automatyzacji sam działa jako kontener, a jednocześnie musi budować i uruchamiać obrazy Dockera. DIND wymaga uruchomienia kontenera w trybie uprzywilejowanym (`--privileged`), co zapewnia dostęp do mechanizmów jądra niezbędnych do działania demona. Alternatywnym podejściem jest Docker-outside-of-Docker (DooD), polegające na zamontowaniu socketu demona hosta (`/var/run/docker.sock`) wewnątrz kontenera - rozwiązanie prostsze w konfiguracji, lecz wiążące się z ryzykiem bezpieczeństwa wynikającym z pełnego dostępu kontenera do zasobów Dockera hosta.

---

## Laboratorium 1 - Git, Gałęzie, SSH

### Cel

Celem pierwszego laboratorium było przygotowanie stanowiska pracy: skonfigurowanie środowiska uniksowego na maszynie wirtualnej, opanowanie podstaw pracy z systemem Git oraz nawiązanie bezpiecznego połączenia SSH zarówno z maszyną wirtualną, jak i z serwisem GitHub.

### Użyte technologie i narzędzia

**Git** umożliwił śledzenie zmian w kodzie, pracę na gałęziach oraz synchronizację z repozytorium zdalnym. Repozytorium przedmiotowe sklonowano najpierw przez HTTPS z użyciem Personal Access Token, a następnie przy użyciu protokołu SSH - metody bezpieczniejszej i wygodniejszej w codziennej pracy.

**SSH** posłużył do nawiązania szyfrowanego połączenia z maszyną wirtualną oraz z serwisem GitHub. Wygenerowano dwa klucze kryptograficzne typu `ed25519`, z których jeden zabezpieczono hasłem. Klucz publiczny dodano do konta GitHub, co umożliwiło klonowanie repozytoriów bez konieczności podawania hasła przy każdej operacji.

**Git Hook** typu `commit-msg` zaimplementowano jako skrypt weryfikujący, że każda wiadomość commita rozpoczyna się od identyfikatora `PS422034`. Skrypt umieszczono w katalogu `.git/hooks/` i nadano mu uprawnienia do wykonania poleceniem `chmod +x`.

**Narzędzia pomocnicze:** Visual Studio Code z wtyczką Remote SSH umożliwił edycję plików na zdalnej maszynie bezpośrednio z lokalnego środowiska. FileZilla posłużył do transferu plików przez SFTP, natomiast polecenie `scp` - do kopiowania plików z poziomu wiersza poleceń.

### Kluczowe kroki

Zalogowano się do maszyny wirtualnej przez SSH z poziomu Windows PowerShell, zainstalowano Gita i niezbędne narzędzia sieciowe, wygenerowano klucze SSH i skonfigurowano je w serwisie GitHub. Następnie sklonowano repozytorium przedmiotowe, przełączono się na gałąź grupową (`GR5`) i utworzono własną gałąź `PS422034`. W katalogu roboczym `GR5/PS422034` umieszczono hook, sprawozdanie oraz zrzuty ekranu, po czym wysłano zmiany do repozytorium zdalnego i otwarto Pull Request do gałęzi grupowej.

### Wnioski

Git w połączeniu z SSH stanowi fundament nowoczesnej pracy z kodem źródłowym. Mechanizm gałęzi umożliwia równoległą pracę wielu osób bez ryzyka konfliktów, natomiast Git Hooks pozwalają na automatyczną weryfikację przyjętych konwencji - blokując niezgodne zmiany już na etapie lokalnego commitu.

---

## Laboratorium 2 - Docker: podstawy konteneryzacji

### Cel

Celem drugiego laboratorium było zapoznanie się z platformą Docker - uruchamianie gotowych obrazów, praca interaktywna z kontenerami oraz tworzenie własnych obrazów na podstawie pliku `Dockerfile`.

### Użyte technologie i narzędzia

**Docker** posłużył do uruchamiania izolowanych środowisk uruchomieniowych. Zapoznano się z obrazami z rejestru Docker Hub: `hello-world`, `busybox`, `ubuntu`, obrazami środowisk Microsoft .NET (`runtime`, `aspnet`, `sdk`) oraz bazą danych `mariadb`.

Własnoręcznie przygotowany **Dockerfile** bazował na obrazie `ubuntu:24.04`, instalował Gita i klonował repozytorium przedmiotowe, zgodnie z dobrymi praktykami budowania obrazów:

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git /repo
WORKDIR /repo
```

### Kluczowe obserwacje

Zbadano rozmiary poszczególnych obrazów - od kilku MB (`busybox`, `hello-world`) do kilkuset MB (obrazy .NET SDK). Sprawdzono kody wyjścia zakończonych kontenerów poleceniem `docker ps -a`. W trybie interaktywnym (`docker run -it`) zaobserwowano, że PID 1 wewnątrz kontenera to powłoka Bash, w odróżnieniu od hosta, gdzie PID 1 należy do procesu `init`. Na zakończenie wyczyszczono zakończone kontenery (`docker container prune`) oraz nieużywane obrazy (`docker image prune -a`).

### Wnioski

Docker znacząco upraszcza dystrybucję oprogramowania poprzez dostarczanie gotowego, samowystarczalnego środowiska uruchomieniowego. Dockerfile umożliwia w pełni powtarzalne i wersjonowane budowanie obrazów, eliminując problem zależności środowiskowych.

---

## Laboratorium 3 - Dockerfiles jako definicja etapów CI

### Cel

Trzecie laboratorium rozwinęło kompetencje z zakresu Dockera o automatyzację procesu budowania i testowania oprogramowania w kontenerze. Celem było praktyczne zrozumienie idei potoku CI, w którym każdy etap realizowany jest w izolowanym i powtarzalnym środowisku.

### Użyte technologie i narzędzia

Jako projekt testowy wybrano repozytorium **expressjs/express** - framework webowy dla Node.js dostępny na licencji MIT, zawierający zestaw testów jednostkowych uruchamianych poleceniem `npm test`.

Kluczowym elementem laboratorium było stworzenie dwóch powiązanych plików Dockerfile realizujących zasadę separacji odpowiedzialności:

`Dockerfile.build` - odpowiada za przygotowanie środowiska i instalację zależności:
```dockerfile
FROM node:latest
WORKDIR /app
RUN git clone https://github.com/expressjs/express.git .
RUN npm install
```

`Dockerfile.test` - bazuje na obrazie pierwszego kontenera i wykonuje wyłącznie testy:
```dockerfile
FROM lab3-build:latest
WORKDIR /app
CMD ["npm", "test"]
```

Całą kompozycję opisano w pliku `docker-compose.yml` i uruchomiono poleceniem `docker compose up`. Klauzula `depends_on` zapewniła właściwą kolejność wykonania etapów. Testy zakończyły się wynikiem **1249 passing**.

#### Dyskusja: przygotowanie do wdrożenia

Framework Express nie nadaje się do samodzielnego wdrożenia jako kontener produkcyjny - wymaga konkretnej aplikacji. Obraz buildowy zawiera zależności deweloperskie (`devDependencies`), niepotrzebne w produkcji i zwiększające rozmiar obrazu. Rekomendowanym rozwiązaniem jest zastosowanie techniki **multi-stage build**, w której finalny obraz bazuje na lekkim `node:alpine` i zawiera wyłącznie pliki wymagane do działania aplikacji.

### Wnioski

Separacja etapów budowania i testowania w osobnych kontenerach stanowi podstawę nowoczesnego CI. Każdy etap jest izolowany, deterministyczny i przenośny - gwarantując identyczne wyniki zarówno na stacji roboczej dewelopera, jak i na serwerze CI.

---

## Laboratorium 4 - Woluminy, sieć, usługi i Jenkins

### Cel

Czwarte laboratorium obejmowało zaawansowane zagadnienia konteneryzacji: trwałe przechowywanie danych z użyciem woluminów, komunikację sieciową między kontenerami, uruchamianie usług systemowych w kontenerze oraz wdrożenie skonteneryzowanego serwera Jenkins z pomocnikiem Docker-in-Docker.

### Zachowywanie stanu - woluminy Docker

Przygotowano dwa woluminy: `input-volume` przeznaczony na kod źródłowy oraz `output-volume` na artefakty budowania. Repozytorium zostało sklonowane bezpośrednio do fizycznej lokalizacji woluminu na hoście (`/var/lib/docker/volumes/input-volume/_data`), co pozwoliło zachować zasadę braku narzędzia Git wewnątrz kontenera bazowego. Zbadano również podejście alternatywne - klonowanie wewnątrz kontenera z tymczasowo zainstalowanym Gitem. Omówiono możliwość zastosowania dyrektywy `RUN --mount` w Dockerfile do montowania zasobów podczas budowania obrazu bez utrwalania ich w warstwach.

### Komunikacja sieciowa - iperf3

Przeprowadzono pomiary przepustowości komunikacji sieciowej przy użyciu narzędzia `iperf3` w trzech konfiguracjach:

| Scenariusz | Przepustowość |
|---|---|
| Kontener → Kontener (sieć domyślna) | ~57–62 Gbits/sec |
| Host → Kontener | ~35 Gbits/sec |
| Spoza hosta → Kontener | ~4.61 Gbits/sec |

Wysoka przepustowość w komunikacji kontener–kontener wynika z realizacji ruchu przez wirtualny interfejs sieciowy w obrębie tego samego hosta, z pominięciem fizycznej infrastruktury sieciowej. Utworzono własną sieć mostkową poleceniem `docker network create`, która udostępniła wbudowane rozwiązywanie nazw DNS, umożliwiające adresowanie kontenerów po nazwie zamiast dynamicznie przydzielanego adresu IP.

### Usługi - SSHD w kontenerze

Uruchomiono demona SSH (`sshd`) wewnątrz kontenera Ubuntu i nawiązano połączenie z zewnątrz na porcie 2222. Przeprowadzono analizę zalet i wad tego podejścia. Do zalet zalicza się możliwość zdalnego dostępu i transferu plików przy użyciu znanych narzędzi (SCP, SFTP). Wady obejmują zwiększenie rozmiaru obrazu, rozszerzenie powierzchni ataku oraz niezgodność z filozofią kontenerów zakładającą ich bezstanowość i jednocelowość. W środowiskach produkcyjnych rekomendowaną alternatywą pozostaje polecenie `docker exec`.

### Jenkins z Docker-in-Docker

Instalacja Jenkinsa obejmowała trzy etapy: utworzenie dedykowanej sieci `jenkins`, uruchomienie kontenera DIND w trybie uprzywilejowanym (`--privileged`) oraz uruchomienie kontenera Jenkins skonfigurowanego do komunikacji z demonem Dockera przez szyfrowane połączenie TLS. Po pobraniu hasła inicjalizacyjnego (`initialAdminPassword`) i instalacji wymaganych wtyczek serwer Jenkins uruchomił się poprawnie na porcie 8080.

### Wnioski

Woluminy, sieci i usługi stanowią trzy fundamentalne elementy produkcyjnego zastosowania platformy Docker. Technika Docker-in-Docker, mimo konieczności zastosowania trybu uprzywilejowanego, jest powszechnie stosowanym rozwiązaniem w skonteneryzowanych środowiskach CI/CD.

---

## Podsumowanie

Realizacja czterech laboratoriów umożliwiła zapoznanie się z pełnym, nowoczesnym cyklem pracy z oprogramowaniem w środowisku DevOps:

1. **Git i SSH** - zarządzanie kodem źródłowym, bezpieczny dostęp zdalny, automatyzacja konwencji przez Git Hooks
2. **Docker - podstawy** - izolacja środowisk uruchomieniowych, przenośność aplikacji, tworzenie własnych obrazów
3. **Docker - CI** - powtarzalne budowanie i testowanie w kontenerach, separacja etapów, Docker Compose
4. **Docker - zaawansowany** - trwałość danych, komunikacja sieciowa, usługi systemowe, serwer Jenkins

Opanowanie przedstawionych narzędzi i praktyk stanowi fundament pracy inżyniera oprogramowania dbającego o jakość, powtarzalność i przenośność wytwarzanego produktu. Konteneryzacja i ciągła integracja są powszechnie stosowanymi standardami w profesjonalnych projektach inżynierskich.

