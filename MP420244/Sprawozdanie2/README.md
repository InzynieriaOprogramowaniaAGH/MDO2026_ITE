![Lista obrazów](images/1.%20Lista%20obrazów.png)

* znalezienie dystrybucji: `docker search (nazwa_obrazu)`
* pobranie obrazu: `docker pull (nazwa_obrazu)`

![Hello World](images/2.%20Hello%20world.png)

* uruchomienie obrazu: `docker run (id_obrazu)`

Niektóre z obrazów (np. mariadb) potrzebują zdefiniowanie dodatkowych zmiennych środowiskowych za pomocą flagi -e.

![Uruchomione kontenery](images/3.%20Uruchomione%20obrazy.png)

* lista wszystkich kontenerów: `docker container ls -a`

Niektóre kontenery pozostają uruchomione. Większość z nich kończy się z kodem 0. Pojawiło się więcej kontenerów mariadb, co mogło być spowodowane omyłkowym wielokrotnym odtworzeniem obrazu.

![Uruchomione kontenery](images/4.%20Uruchomione%20kontenery.png)

* lista uruchomionych kontenerów: `docker ps`

![Uruchomienie busybox](images/5.%20Uruchomienie%20busybox.png)

* uruchomienie kontenera w trybie interaktywnym: `docker run -i (nazwa_obrazu)`

![Wersja busybox](images/6.%20Wersja%20busybox.png)

* wywołanie polecenia w kontenerze: `docker exec -it (id_kontenera) (terminal) -c (komenda)`

![Operacje na ubuntu](images/7.%20Operacje%20na%20ubuntu.png)

Uruchomienie kontenera z ubuntu automatycznie przerzuca kontekst do terminala wewnętrznego. Wywołane zostały polecenia: `echo`, `ps` i `apt update`.

![Budowanie obrazu](images/8.%20Budowanie%20obrazu.png)

* tworzenie obrazu z pliku Dockerfile: `docker build -t (nazwa_obrazu):(tag) (lokalizacja pliku Dockerfile)`

![Uruchomiony obraz](images/9.%20Uruchomiony%20obraz.png)

Plik Dockerfile automatycznie instaluje git-a i klonuje repozytorium, co widać po rezultacie poleceń `ls -la` i `cat README.md`.

![Uruchomione kontenery](images/10.%20Uruchomione%20kontenery.png)

Wyżej rezultat uruchomienia wszystkich kontenerów.

![Usunięcie obrazów](images/11.%20Usunięcie%20obrazów.png)

Żeby usunąć wszystkie obrazy, należy pozbyć się wszystkich bazujących na nich kontenerów:

* usuwanie wszystkich kontenerów: `docker rm $(docker ps -aq)`
* usuwanie wszystkich obrazów: `docker rmi $(sudo docker images -q)`