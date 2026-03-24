# Sprawozdanie 3 - Dockerfiles i konteneryzacja etapu CI
**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE  
**Grupa:** G6  

## 1. Praca w środowisku lokalnym (Host)
Celem zadania było zbudowanie oprogramowania w powtarzalnym środowisku CI. Wybranym projektem jest **Calculator** (Java/Maven). Pracę rozpocząłem od przygotowania repozytorium i kompilacji bezpośrednio na moim serwerze Ubuntu.

### Kompilacja
Po sklonowaniu kodu i inicjalizacji projektu, uruchomiłem proces kompilacji, który zakończył się pomyślnie.

![Pobranie i inicjalizacja repozytorium](obrazy/01_1_repozytorium.png)
![Sukces kompilacji na hoście](obrazy/01_2_repozytorium.png)

Problem pojawił się przy próbie uruchomienia testów jednostkowych. Mimo że Maven raportował sukces (BUILD SUCCESS), w raporcie końcowym widniała informacja o wykonaniu dokładnie zera testów.

![Wynik testów na hoście - 0 wykonanych testów](obrazy/02_1_testy.png)

Analiza logów pozwoliła mi odkryć przyczynę tego stanu rzeczy. Projekt korzystał z przestarzałej wersji wtyczki testującej, która nie potrafiła rozpoznać nowoczesnych testów JUnit 5 obecnych w kodzie źródłowym.

![Analiza logów i przestarzałej wtyczki Surefire](obrazy/02_2_testy.png)

## 2. Izolacja i powtarzalność: Praca w kontenerze
Przeniosłem proces do kontenera Docker, aby zapewnić czyste i w pełni odizolowane środowisko pracy.

### Praca interaktywna
Zacząłem od uruchomienia oficjalnego obrazu Maven w trybie interaktywnym z podłączonym terminalem (TTY).

![Uruchomienie kontenera Maven](obrazy/03_kontener.png)

Wewnątrz kontenera zainstalowałem niezbędne narzędzia, sklonowałem kod repozytorium i przeprowadziłem proces budowania.

![Klonowanie repozytorium wewnątrz kontenera](obrazy/04_1_kontener_repozytorium.png)
![Sukces budowania w kontenerze](obrazy/04_2_kontener_repozytorium.png)

### Walka z interfejsem graficznym i bibliotekami
W środowisku kontenera Maven automatycznie pobrał nowszą wersję wtyczki, dzięki czemu testy zostały poprawnie wykryte. Jednak ich uruchomienie zakończyło się błędem `HeadlessException`. Wynikało to z faktu, że kalkulator posiada interfejs graficzny, a kontener nie posiada fizycznego monitora. Dodatkowo w systemie brakowało bibliotek niezbędnych do obsługi grafiki w Javie.

![Błąd HeadlessException i wykrycie nowej wtyczki](obrazy/05_1_kontener_testy.png)
![Widok logów z pobieraniem nowej wtyczki](obrazy/05_2_kontener_testy.png)

Rozwiązaniem okazało się doinstalowanie bibliotek systemowych oraz konfiguracja serwera **Xvfb** (wirtualnego bufora ekranu). Po stworzeniu "oszukanego" monitora w pamięci RAM, testy interfejsu zakończyły się pełnym sukcesem.

![Pełny sukces testów po konfiguracji wirtualnego ekranu](obrazy/05_3_kontener_testy.png)

## 3. Automatyzacja: Dockerfiles
Aby uniknąć ręcznej konfiguracji przy każdym uruchomieniu, stworzyłem dwa pliki Dockerfile, które automatyzują proces i dzielą go na logiczne etapy.

### Etap 1: Budowanie (Dockerfile.build)
Ten plik odpowiada za przygotowanie całego środowiska, pobranie kodu i przeprowadzenie kompilacji.

![Wywołanie procesu budowania obrazu builder](obrazy/06_1_kontener_build.png)
![Wynik budowania warstwy builder](obrazy/06_2_kontener_build.png)
![Kod pliku Dockerfile.build](obrazy/06_3_kontener_build.png)

### Etap 2: Testowanie (Dockerfile.test)
Drugi kontener bazuje bezpośrednio na pierwszym. Jego jedynym zadaniem jest doinstalowanie pakietów graficznych i bezpieczne przeprowadzenie testów.

![Budowanie obrazu testowego](obrazy/07_1_kontener_test.png)
![Sukces budowania warstwy testowej](obrazy/07_2_kontener_test.png)
![Kod pliku Dockerfile.test](obrazy/07_3_kontener_test.png)

Poprawność całego automatu sprawdziłem komendą `docker run`. System samodzielnie postawił środowisko i przeprowadził testy, zwracając raport końcowy bez potrzeby interwencji użytkownika.

![Finalne uruchomienie automatu testowego](obrazy/08_kontener_run.png)

## 4. Docker Compose
Ostatnim krokiem było połączenie obu etapów w jedną kompozycję. Dzięki plikowi `docker-compose.yml`, cały proces można uruchomić jedną krótką komendą. To rozwiązanie gwarantuje, że proces będzie działał identycznie na każdym serwerze.

![Sukces wykonania pełnej kompozycji Docker Compose](obrazy/09_1_compose.png)
![Kod pliku docker-compose.yml](obrazy/09_2_compose.png)
