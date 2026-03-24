# Sprawozdanie 2
**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE  
**Grupa:** G6  

## 1. Instalacja środowiska Docker
Zgodnie z instrukcją, dokonałem instalacji silnika Docker w systemie Linux. Wykorzystałem pakiety dystrybucyjne (`docker.io`).

![Instalacja Dockera w systemie](obrazy/01_instalacja_docker.png)

## 2. Testowanie i analiza obrazów
Pobrałem i uruchomiłem szereg obrazów w celu weryfikacji ich działania oraz analizy kodów wyjścia (Exit Code).

* **Exit Code 0:** Oznacza sukces – proces wewnątrz kontenera zakończył się pomyślnie (np. program wykonał swoje zadanie i zamknął się zgodnie z planem).
* **Exit Code 1:** Sygnalizuje błąd ogólny, np. błąd w kodzie aplikacji lub brak wymaganego pliku.

Podczas testów wszystkie analizowane obrazy zakończyły się kodem **0**.

### Przegląd uruchomionych obrazów:
**Hello-World:** Pierwszy test poprawności komunikacji z demonem Dockera.
![Uruchomienie hello-world](obrazy/02_1_obraz.png)

**Ubuntu:** Uruchomienie bazowego systemu Linux.
![Uruchomienie ubuntu](obrazy/02_2_obraz.png)

**MariaDB:** Weryfikacja pobierania i startu bazy danych.
![Uruchomienie mariadb](obrazy/02_3_obraz.png)

**Obrazy .NET (Microsoft):** Analiza środowisk o różnym przeznaczeniu.
![Obraz aspnet](obrazy/02_4_obraz.png)
![Obraz runtime](obrazy/02_5_obraz.png)
![Obraz sdk](obrazy/02_6_obraz.png)

### Analiza rozmiarów
Użyłem komendy `docker images`, aby zestawić rozmiary obrazów. Widoczna jest znacząca różnica: obraz `sdk` (ponad 800MB) jest znacznie cięższy od `runtime`, ponieważ zawiera komplet narzędzi kompilacyjnych.

![Zestawienie rozmiarów obrazów](obrazy/02_7_obraz.png)

## 3. Praca z obrazem Busybox
Busybox, jako minimalistyczny zestaw narzędzi Unixowych, posłużył do testów interaktywnych.
* **Uruchomienie standardowe:**
![Działanie busybox](obrazy/03_1_busybox.png)
* **Wywołanie wersji w trybie interaktywnym (`-it`):**
![Interaktywna wersja busybox](obrazy/03_2_busybox.png)

## 4. Izolacja procesów (Ubuntu)
Kluczowym elementem zadania było sprawdzenie mechanizmu izolacji PID. Po uruchomieniu bash w kontenerze:
* **Wewnątrz kontenera:** Bash zgłasza się jako **PID 1**.
* **Na hoście:** Ten sam proces posiada wysoki, systemowy numer PID.
Dowodzi to, że kontener posiada własną przestrzeń nazw procesów, niezależną od gospodarza.

![Analiza procesów Ubuntu](obrazy/05_ubuntu.png)

## 5. Budowa własnego obrazu (Dockerfile)
Przygotowałem plik `Dockerfile`, który automatyzuje przygotowanie środowiska pracy. Plik bazuje na Ubuntu 22.04, instaluje `git` (z czyszczeniem cache'u apt w celu optymalizacji rozmiaru) oraz klonuje nasze repozytorium.

**Kod pliku Dockerfile:**
![Kod pliku Dockerfile](obrazy/06_1_Dockerfile.png)

**Budowanie i weryfikacja:**
Po zbudowaniu obrazu uruchomiłem kontener, sprawdzając obecność plików repozytorium komendą `ls`.
![Działanie własnego obrazu](obrazy/06_2_Dockerfile.png)

## 6. Zarządzanie zasobami i czyszczenie
Podczas realizacji zadań kontenery były usuwane na bieżąco po zakończeniu testów, co dokumentuje poniższa lista (pokazująca minimalną ilość aktywnych zasobów).

![Lista kontenerów w trakcie pracy](obrazy/07_dzialajace_kontenery.png)

Na zakończenie wykonałem pełne czyszczenie lokalnego magazynu obrazów i kontenerów (`docker system prune -a`), aby zwolnić zasoby systemowe.

![Stan po czyszczeniu](obrazy/08_czyszczenie.png)
