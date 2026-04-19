# Sprawozdanie 3 - Konteneryzacja i automatyzacja procesów wytwórczych

## 1. Wybór oprogramowania
Do realizacji zadania wybrano projekt **Redis**, napisany w języku C. Wybór uzasadniony jest przejrzystym procesem kompilacji (`make`) i rozbudowanym systemem testów, co pozwala na demonstrację powtarzalności środowiska w kontenerach.

## 2. Prace na maszynie lokalnej 
W pierwszym etapie sklonowano repozytorium i przeprowadzono kompilację bezpośrednio na maszynie wirtualnej.
![Klonowanie i struktura](screenshots/lab3_1.png)
![Kompilacja lokalna](screenshots/lab3_2.png)

Podczas uruchomienia testów na hoście wystąpiły błędy, co potwierdza wpływ konfiguracji systemu gospodarza na stabilność testów.
![Błędy testów lokalnych](screenshots/lab3_3.png)

## 3. Budowanie interaktywne w kontenerze
Uruchomiono czysty kontener `ubuntu:latest`, w którym ręcznie zainstalowano zależności (`build-essential`, `tcl`, `git`). W izolowanym środowisku wszystkie testy zakończyły się sukcesem.
![Instalacja w kontenerze](screenshots/lab3_4.png)
![Sukces testów w kontenerze](screenshots/lab3_5.png)

## 4. Automatyzacja przy użyciu Dockerfile
Przygotowano dwa pliki Dockerfile w celu separacji procesów:
- `Dockerfile.build`, który dpowiada za instalację narzędzi i kompilację kodu.
- `Dockerfile.test`, który wykorzystuje obraz builda do uruchomienia automatycznych testów.

![Budowanie obrazu Build](screenshots/lab3_6.png)
![Budowanie obrazu Test](screenshots/lab3_7.png)
![Wynik testów z Dockerfile](screenshots/lab3_8.png)

## 5. Docker Compose
Zaimplementowano plik `docker-compose.yml`, który automatyzuje budowanie i uruchamianie kontenera testowego jedną komendą.
![Konfiguracja Compose](screenshots/lab3_9.png)
![Uruchomienie i wynik Compose](screenshots/lab3_10.png)
![Status zakończenia testera](screenshots/lab3_11.png)

## 6. Analiza artefaktów i dyskusja
- Redis jest standardowo dystrybuowany jako obraz, alczkolwiek obecny obraz zawiera kod źródłowy i kompilatory, przez co jest zbyt duży do celów produkcyjnych.
- Aby umożliwić dystrybucję w systemach bez silnika kontenerowego, można wykorzystać kontener budujący do wygenerowania paczek instalacyjnych `.deb` lub `.rpm`, które byłyby finalnym artefaktem wyjściowym.

![Lista zbudowanych obrazów](screenshots/lab3_13.png)
