# Sprawozdanie z laboratorium 5

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Przygotowanie środowiska Jenkins (Docker + DIND)

Uruchomiono Jenkins w kontenerze Dockera zgodnie z dokumentacją producenta, z podejściem umożliwiającym wykonywanie poleceń Dockera z poziomu CI.

![Uruchomienie Jenkinsa w Dockerze](img/uruchomienie_jenkinsa_w_dockerze.jpg)

Różnica między obrazem standardowym a Blue Ocean:
- standardowy Jenkins to podstawowy serwer CI,
- Blue Ocean to Jenkins rozszerzony o nowy interfejs pipeline i dodatkowe wtyczki.

---

## 2. Zadanie wstępne: uruchomienie (Freestyle)

### 2.1. Projekt `uname`

Utworzono zadanie Freestyle i dodano krok `uname -a`.

![Konfiguracja zadania uname](img/new_item_zadanie_uname.jpg)
![Treść komendy uname w shell](img/uname_tresc_shell_komendy.jpg)
![Wynik zadania uname](img/console_output_zadanie_uname.jpg)

### 2.2. Projekt z błędem dla nieparzystej godziny

Utworzono zadanie zwracające kod błędu, gdy bieżąca godzina jest nieparzysta.

![Treść skryptu sprawdzenia godziny](img/sprawdzenie_godziny_tresc_shell.jpg)
![Błąd zadania godzina](img/zadanie_godzina_output_error.jpg)

### 2.3. Pobranie obrazu `ubuntu`

W osobnym zadaniu wykonano `docker pull ubuntu`.

![Treść komendy docker pull](img/docker_pull_tresc_shell.jpg)
![Udany docker pull ubuntu](img/udany_docker_pull.jpg)

---

## 3. Zadanie wstępne: obiekt typu pipeline

Utworzono obiekt typu `Pipeline` i wpisano skrypt bezpośrednio w konfiguracji zadania (bez SCM na tym etapie).
Pipeline realizuje:
- pobranie repozytorium,
- stworzenie Dockerfile,
- budowanie obrazu.

![Konfiguracja kroków pipeline](img/pipeline_steps.jpg)
![Console output pipeline](img/pipeline1_console_output.jpg)

Pipeline uruchomiono ponownie w celu potwierdzenia powtarzalności działania.

![Drugie uruchomienie pipeline](img/pipeline_2_uruchomienia.jpg)

---
