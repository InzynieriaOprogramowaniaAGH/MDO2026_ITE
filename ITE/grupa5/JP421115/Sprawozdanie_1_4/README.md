# Sprawozdanie podsumowujące laboratoria 1-4

Autor: Jan Pawelec

---

## Spis treści
1. [System kontroli wersji](#1-system-kontroli-wersji)
2. [Podstawy konteneryzacji](#2-podstawy-konteneryzacji)
3. [Powtarzalne środowiska budowania](#3-powtarzalne-środowiska-budowania)
4. [Zarządzanie stanem i komunikacja sieciowa w Dockerze](#4-zarządzanie-stanem-i-komunikacja-sieciowa-w-dockerze)
5. [Wdrożenie Jenkins](#5-wdrożenie-jenkins)
6. [Wnioski](#6-wnioski)

---

# 1. System kontroli wersji
System Git jest niezbędnikiem każdego współczesnego dewelopera. Stanowi podstawe do bezpiecznego przechowywania plików i współpracy z zespołem.

## Zabezpieczenie komunikacji 
W celu zapewnienia bezpiecznej komunikacji z repozytorium zdalnym, odchodzi się obecnie od tradycyjnego uwierzytelniania opartego na haśle. Zamiast tego stosuje się nowocześniejsze i bezpieczniejsze mechanizmy:

- Klucze SSH: Generuje się parę kluczy asymetrycznych w nowoczesnym standardzie. Klucz prywatny dodatkowo zabezpiecza się silnym hasłem, natomiast klucz publiczny dodaje się do ustawień konta GitHub.
- Tokeny PAT (Personal Access Token): Jako alternatywną metodę uwierzytelniania dla protokołu HTTPS można wykorzystać token dostępu z precyzyjnie ograniczonymi uprawnieniami.
- 2FA (Two-Factor Authentication): Konto dewelopera zabezpiecza się uwierzytelnianiem dwuskładnikowym, co stanowi obecnie rynkowy standard ochrony tożsamości i dostępu do kodu źródłowego.

## Organizacja środowiska deweloperskiego
Środowisko pracy najczęściej dzieli się na maszynę hosta (z interfejsem graficznym) oraz wyizolowane środowisko uniksowe (maszynę wirtualną lub kontener), w którym uruchamia się procesy deweloperskie. Do natychmiastowej synchronizacji i wymiany plików między systemami można skorzystać z protokołu SFTP/SSH (przy użyciu narzędzi takich jak FileZilla lub wbudowanych rozszerzeń IDE, np. Remote-SSH). Pozwala to na pisanie kodu na hoście i jego natychmiastową egzekucję w docelowym środowisku uniksowym.

## Branching
Każda zmianna w kodzie wymaga utworzenia nowego odgałęzienia. Workflow zaczyna się od utworzenia nowej gałęzi.

```bash
$ git checkout -b JP421115
```

Następnie zmiany są wprowadzane, wpychane za pomocą `git push`. Na końcu stostuje się Pull Request, który po weryfikacji dodaje kod do głównej kodbazy.

## Githooks
Aby zautomatyzować kontrolę jakości na wczesnym etapie i wymusić spójność logów historii, implementuje się lokalny mechanizm Git Hooks. W katalogu .git/hooks/ można utworzyć skrypt o nazwie commit-msg, który uruchamia się automatycznie przed zatwierdzeniem commita.

---

# 2. Podstawy konteneryzacji
Konteneryzacja zapewnia powtarzalność i izolację procesów deweloperskich. Narzędziem rynkowego standardu do budowy i uruchamiania wyizolowanych środowisk jest Docker, stanowiący fundament nowoczesnych potoków CI/CD.

## Przygotowanie silnika Docker w środowisku Linux
Instalację środowiska Docker przeprowadza się natywnie w systemie Linux. Zaleca się korzystanie z oficjalnych repozytoriów używanej dystrybucji, co gwarantuje lepszą kompatybilność i optymalizację pakietów niż uniwersalne wersje Community Edition. Należy również unikać dystrybucji poprzez formaty takie jak Snap, aby zapobiec problemom z uprawnieniami, izolacją sieciową oraz woluminami.

## Bazowe obrazy
Platforma Docker Hub stanowi główne repozytorium gotowych obrazów. W zależności od potrzeb projektowych, dobiera się odpowiednie środowisko bazowe. Obrazy różnią się znacznie rozmiarem oraz przeznaczeniem – od minimalistycznego hello-world czy busybox, po pełne systemy jak ubuntu / fedora, lub specjalistyczne środowiska uruchomieniowe (np. bazy danych mariadb czy pakiety SDK dla .NET).

Uruchomienie kontenera w trybie interaktywnym pozwala na swobodną weryfikację jego zawartości. Dla przykładu, uruchomienie powłoki w lekkim obrazie busybox:

```bash
$ docker run -it --rm busybox sh
```

## Tworzenie Dockerfile

Definicję środowiska utrzymuje się w pliku Dockerfile, realizując w ten sposób podejście Infrastructure as Code. Stosując dobre praktyki, należy minimalizować liczbę warstw (layers) i optymalizować rozmiar obrazu poprzez czyszczenie pamięci podręcznej menedżerów pakietów.

Poniższy skrypt obrazuje utworzenie dedykowanego środowiska bazującego na systemie Ubuntu, w którym instaluje się narzędzie Git, a następnie klonuje wskazane repozytorium:

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/organizacja/repozytorium-przedmiotowe.git .
```

Po zbudowaniu obrazu poleceniem `docker build` uruchamia się go interaktywnie, co pozwala na weryfikację obecności pobranych plików źródłowych bezpośrednio w kontenerze.

## Zarządzanie cyklem życia kontenerów

Zarówno budowanie obrazów, jak i testowanie aplikacji generuje dużą liczbę zatrzymanych kontenerów i nieużywanych obrazów. Prowadzi to do szybkiego wyczerpania zasobów dyskowych hosta (zwykle w katalogu `/var/lib/docker`).

Inspekcję wszystkich uruchomionych i zatrzymanych kontenerów realizuje się poleceniem:
```bash
$ docker ps -a
```

Utrzymanie higieny lokalnego magazynu przeprowadza się za pomocą wbudowanych mechanizmów sprzątających, czyszcząc nieużywane już zasoby:
```bash
$ docker container prune
$ docker image prune -a
```

Po zakończeniu prac konfiguracyjnych plik `Dockerfile` wersjonuje się, dodając go do odpowiedniego katalogu na swojej gałęzi w głównym repozytorium projektu i zatwierdzając standardowym commitem.

---

# 3. Powtarzalne środowiska budowania
Konteneryzacja zapewnia pełną powtarzalność procesu kompilacji i testowania oprogramowania, uniezależniając te etapy od konfiguracji lokalnej maszyny hosta. Stanowi to fundament przenośnych potoków CI/CD.

## Budowanie interaktywne w wyizolowanym kontenerze bazowym

Przed zautomatyzowaniem potoku, proces budowania i weryfikacji aplikacji przeprowadza się interaktywnie. W tym celu uruchamia się kontener bazowy dostosowany do wymogów projektu (np. `node` dla aplikacji w JavaScript).

Podłączenie terminala  pozwala na ręczną konfigurację obszaru roboczego, sklonowanie repozytorium oraz wywołanie narzędzi budujących. Po pomyślnej kompilacji, w tym samym wyizolowanym środowisku uruchamia się testy jednostkowe, weryfikując ostateczny raport końcowy.

```bash
$ docker run -it --rm node:18-alpine sh
/ apk add git make
/ git clone https://github.com/organizacja/repozytorium.git .
/ npm install
/ make build
/ make test
```

##  Implementacja wieloetapowego procesu za pomocą plików Dockerfile
Zweryfikowane interaktywnie kroki automatyzuje się, przenosząc je do plików Dockerfile. Zgodnie z wymogami separacji odpowiedzialności, proces ten dzieli się na dwa niezależne etapy:

1) Build: Odpowiada wyłącznie za pobranie zależności i skompilowanie kodu źródłowego do postaci końcowego artefaktu.
2) Test: Bazuje bezpośrednio na wygenerowanym wcześniej obrazie pierwszego kontenera. Służy wyłącznie do egzekucji testów jednostkowych – nie przeprowadza ponownie procesu budowania.

Takie podejście gwarantuje, że środowisko testowe operuje na dokładnie tym samym skompilowanym kodzie, który powstał w poprzednim kroku.

## Orkiestracja środowiska za pomocą Docker Compose
Zarządzanie wieloma plikami Dockerfile i ręczne wdrażanie kontenerów we właściwej kolejności jest procesem podatnym na błędy. Zamiast ręcznej inicjalizacji, całe środowisko ujmuje się w spójną kompozycję za pomocą narzędzia Docker Compose.

Plik konfiguracyjny docker-compose.yml pozwala na deklaratywne zdefiniowanie usług, ich ścieżek budowania oraz określenie zależności między nimi (np. wymuszenie uruchomienia kontenera testującego po kontenerze budującym). Przykładowy `yml`:

```yml
version: '3.8'
services: 
    builder: 
        build:
            context: .
            dockerfile: Dockerfile.build image: cjson-builder
    
    tester:
        build:
            context:
            dockerfile: Dockerfile.test
        image: cjson-tester 
        depends_on: builder
```

Dzięki takiemu ujęciu architektury, automatyzacja całego wieloetapowego procesu sprowadza się do wykonania pojedynczego polecenia w głównym katalogu repozytorium:

```bash
$ docker compose up --build
```

---

# 4. Zarządzanie stanem i komunikacja sieciowa w Dockerze
Kontenery po usunięciu tracą wszystkie zapisane w nich dane. Dlatego do zachowania plików i poprawnej komunikacji stosuje się odpowiednie mechanizmy oferowane przez Dockera.

## Współdzielenie plików i zapisywanie stanu
W celu zachowania danych po wyłączeniu kontenera stosuje się woluminy oraz mapowania folderów z dysku.

Aby zbudować projekt w kontenerze bazowym bez instalowania w nim programu Git, najprościej jest sklonować kod bezpośrednio na komputerze hosta. Następnie taki lokalny folder podpina się do działającego kontenera. Gotowe, skompilowane pliki zapisuje się na oddzielnym woluminie wyjściowym. Dzięki temu wygenerowane pliki nie znikną, gdy kontener zakończy pracę.

```bash
$ docker run -v /lokalny/kod:/app/src -v wolumin-wynikowy:/app/build ubuntu-builder
```

Nowocześniejszym podejściem przy pisaniu pliku Dockerfile jest użycie instrukcji `RUN --mount`. Pozwala ona na tymczasowe udostępnienie plików do kontenera wyłącznie na czas jego budowania, co zmniejsza ostateczny rozmiar obrazu.

## Sieci mostkowe, wewnętrzny DNS i narzędzie iPerf3
Do testowania połączeń i mierzenia prędkości sieci między kontenerami używa się programu `iperf3`. W domyślnej sieci Dockera kontenery muszą łączyć się ze sobą za pomocą adresów IP, co jest uciążliwe. Dlatego tworzy się własne sieci mostkowe. We własnej sieci działa wewnętrzny DNS, co pozwala kontenerom łączyć się ze sobą za pomocą ich nazw, zamiast używać adresów IP.

```bash
$ docker network create moja-siec
$ docker run -d --name serwer-testowy --network moja-siec networkstatic/iperf3 -s
$ docker run -it --rm --network moja-siec networkstatic/iperf3 -c serwer-testowy
```

Aby umożliwić dostęp do serwera iPerf z zewnątrz (spoza Dockera), należy dodatkowo wystawić porty na zewnątrz używając flagi `-p` (np. `-p 5201:5201`).

## Zestawienie usługi SSHD w kontenerze 
Instalowanie i uruchamianie serwera SSH (sshd) wewnątrz kontenera uznaje się za złą praktykę. Zgodnie z dobrymi wzorcami, jeden kontener powinien obsługiwać tylko jeden główny proces. Do wprowadzania poleceń w działającym kontenerze stosuje się po prostu polecenie docker exec.

Pomimo tego, istnieją nieliczne sytuacje, w których instalacja SSH ma uzasadnienie:
- Kiedy używa się narzędzi konfiguracyjnych wymagających protokołu SSH (np. Ansible).
- Kiedy kontener ma pełnić rolę punktu dostępowego w zamkniętej sieci wirtualnej.

Należy jednak pamiętać o potencjalnych wadach tego rozwiązania:
- Zwiększa to niepotrzebnie rozmiar obrazu.
- Tworzy dodatkowe luki w bezpieczeństwie (trzeba zarządzać kluczami SSH w każdym kontenerze).
- Znacznie utrudnia zarządzanie kontenerem, ponieważ wymaga uruchomienia dodatkowych programów kontrolujących działanie więcej niż jednego procesu naraz.

---

# 5. Wdrożenie Jenkins
Jenkins to otwartoźródłowy serwer automatyzacji, który służy do wdrażania procesów ciągłej integracji i ciągłego dostarczania (CI/CD), umożliwiając programistom automatyczne budowanie, testowanie oraz wdrażanie oprogramowania.

## Architektura serwera Jenkins w środowisku skonteneryzowanym

Tradycyjna instalacja Jenkinsa bezpośrednio na systemie operacyjnym utrudnia przenoszalność i zarządzanie zależnościami. W środowisku skonteneryzowanym główny serwer Jenkins (`Controller`) uruchamiany jest jako wyizolowany kontener.

Aby umożliwić serwerowi CI/CD budowanie obrazów i uruchamianie własnych kontenerów w ramach potoków, architekturę rozszerza się o dodatkowy kontener pomocniczy pełniący rolę demona Dockera. Oba kontenery komunikują się ze sobą wewnątrz współdzielonej sieci, wymieniając certyfikaty TLS w celu zapewnienia bezpieczeństwa.

## Konfiguracja mechanizmu Docker-in-Docker jako środowiska budującego

Uruchamianie Dockera wewnątrz Dockera wymaga kontenera działającego w trybie uprzywilejowanym (privileged: true). Kontener główny Jenkinsa nie posiada własnego demona Dockera; zamiast tego łączy się z kontenerem DinD poprzez zmienne środowiskowe wskazujące na odpowiedni host i certyfikaty.

Zamiast ręcznego uruchamiania obu usług, środowisko definiuje się za pomocą pliku `docker-compose.yml`, który współdzieli wolumin z danymi Jenkinsa (`jenkins-data`) oraz wolumin z wygenerowanymi certyfikatami.

## Inicjalizacja i weryfikacja działania instancji Jenkins

Uruchomienie całego środowiska sprowadza się do wykonania polecenia w katalogu z plikiem konfiguracyjnym. Flaga `-d` uruchamia kontenery w tle:
```bash
$ docker compose up -d
```

Można zweryfikować, sprawdzając procesy lub siegając do klienta przegladarkowego. Należy zalogować się za pomocą hasła, ktore Jenkins generuje za pierwszym uruchomieniem.

# 6. Wnioski
Współczesne potoki CI/CD opierają się na ścisłej integracji systemu Git z Dockerem, co gwarantuje bezpieczeństwo kodu i pełną powtarzalność procesów deweloperskich. Wykorzystanie narzędzia Docker Compose pozwala na deklaratywną orkiestrację środowiska, eliminując błędy ręcznej konfiguracji i znacząco przyspieszając wdrażanie złożonych usług. Dzięki technikom Multi-stage build oraz odpowiedniemu zarządzaniu woluminami, obrazy są zoptymalizowane pod kątem rozmiaru, a kluczowe dane projektowe pozostają trwałe. Sieci mostkowe z wewnętrznym DNS-em zapewniają płynną komunikację między kontenerami, usuwając konieczność kłopotliwego operowania na sztywnych adresach IP. Całość procesu automatyzacji domyka skonteneryzowany Jenkins z mechanizmem Docker-in-Docker, który tworzy w pełni autonomiczne i skalowalne środowisko do budowania aplikacji.