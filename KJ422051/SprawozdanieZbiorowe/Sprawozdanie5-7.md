# Sprawozdanie zbiorowe 5-7

Jenkins to narzędzie open-source do automatyzacji procesów tworzenia oprogramowania.  Pomaga w realizacji koncepcji CI/CD (Continuous Integration oraz Continous Delivery).  Oznacza to, że kod jest automatycznie sprawdzany, budowany, testowany i wysyłany na serwer po każdej wprowadzonej zmianie.
Jenkins opiera się na Pipeline’ach – plik tekstowy (Jenkinsfile), który zawiera listę kroków do wykonania.

W ramach laboratoriów omawiane było zagadnienie pracy z serwerem Jenkins w środowisku kontenerowym (Docker). 

## Architektura Docker w Dockerze (DinD):
Jenkins aby mógł budować obrazy Dockerowe potrzebuje dostępu do silnika Dockera. Aby nie instalować Docker bezpośrednio na systemie operacyjnym, uruchomiony został osobny kontener, który pełni rolę serwera Dockera – obraz docker:dind.
Kolejny kontener ma zainstalowanego Jenkinsa, wraz z Blue Ocean (tworzy bardziej przejrzysty interfejs). 
Kontenery zostały połączone ze sobą za pomocą sieci, a Jenkins łączy się za pomocą ustawionych zmiennych środowiskowych (DOCKER_HOST oraz DOCKER_CERT_PATH).

Na początku stworzono proste zadania w powłoce Shell.  Dzięki temu ukazany został mechanizm Exit Codes Jenkinsa.  Kod 0 oznacza sukces a 1 jest sygnałem błędy i przerwania zadania.

Następnie wykonano bardziej zaawansowane formy – przejście do pipeline, zapisanego w Jenkinsfile.
## Struktura:
	- agent any -  określa, gdzie ma się wykonać zadanie,
	- environment – definiuje zmienne (np. konfiguracje połączenia z Dockerem),
	- stages – podział procesu na etapy (np. Pull, Build, Test, Deploy).

Po uruchomieniu wyświetla się Stage view (wizualizacja etapów), pozwala to na monitoring wydajności procesu. Pozwala zobaczyć które etapy (stages) trwały za długo.

Wykorzystanie architektury DinD spowodowało, że całe środowisko budowania jest całkowicie odizolowane od systemu operacyjnego hosta, co zapewnia czystość i bezpieczeństwo – wszystkie operacje budowania obrazów odbywają się wewnątrz kontenerów.


Na kolejnych zajęciach rozpoczęto tworzenie pełnego cyklu życia aplikacji.
Przyjęta strategia to SCM – Source Control Management. Wybrano repozytorium Express.js do forkowania. Jest to stworzenie własnej kopii cudzego projektu.
Architektura Mutli-stage Build:
## Podział na dwa kontenery:
- Dockerfile.build – mimo wybrania obrazu node:18 -alpine, który jest bardzo mały to jest on cięższy od kolejnego kontenera, ponieważ zawiera narzędzia budujące.
- Dockerfile.runtime – wybrano node:18-slim, jest on lżejszy i zoptymalizowany pod kątem stabilności.

## Analiza Jenkinsfile:
Definiowanie zmiennych (nazwa obrazu, wersja budowania) pozwala na łatwe zarządzanie projektem bez edytowania każdego kroku skryptu.
Użycie bloku post do archiwizacji wyników testów (archiveArtifacts) i czyszczenia kontenerów zapewniło czystość środowiska. Bez automatycznego usuwania kontenerów po testach, serwerowi  Jenkins szybko zabrakłoby miejsca na dysku.

## Weryfikacja jakości:
Unit Tests – sprawdzają, czy logika kodu jest poprawna na poziomie funkcji.
Smoke Test – Jenkins uruchamia kontener z aplikacją na porcie 3000, a następnie za pomocą komendy curl sprawdza, czy serwer rzeczywiście odpowiada.
Samo pomyślne zbudowanie obrazu nie gwarantuje, że aplikacja działa. Smoke Test weryfikuje, czy kontener jest w stanie wystartować.

Artefakt to gotowy produkt procesu. Paczka .tar.gz jest uniwersalnym nośnikiem. Pozwala na łatwe przenoszenie kodu, archiwizację lub wysyłkę do zewnętrznych repozytoriów.

## Wnioski:
Realizacja projektu pokazała, że środowisko Jenkins pracujące w modelu Docker-in-Docker zapewnia wysoką izolację i elastyczność budowania procesów. 
Zastosowanie oddzielnych pików Dockerfile pozwoliło drastycznie zmniejszyć rozmiar obrazy końcowego przy zachowaniu funkcjonalności. 
Definicja potoku w formie Jenkinsfile umożliwiła pełną automatyzację cyklu życia aplikacji oraz łatwe zarządzanie wersjami bezpośrednio z repozytorium Github.
Wprowadzenie etapu Smoke Test okazało się kluczowe dla zapewnienia jakości, skutecznie blokując publikację niedziałających wersji oprogramowania.
Automatyzacja czyszczenia środowiska po każdym buildzie zagwarantowała stabilność serwera i uniknięcie konfliktów zasobów w kolejnych iteracjach.
Całość prac udowodniła, że nowoczesne podejście CI/CD znacząco przyspiesza dostarczanie zmian, jednocześnie minimalizując ryzyko wystąpienia błędów wdrożeniowych.

