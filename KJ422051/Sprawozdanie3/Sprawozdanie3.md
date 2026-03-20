1. Pobranie repozytroium express
a. Sklonowanie
b. Instalacja zależności i testy

2. Uruchomienie czystego kontenera
a. Uruchomienie kontenera
-it - połączenie dwóch flas - i- sprawia, że wejście kontenera zostaje otwarte, -t przydziela wirtualny terminal, Node:18 - obraz bazowy

b. Aktualizacja i instalacja gita (jeśli nie ma)

c. Klonowanie
d. Budowanie
e. Testy i wyjście

3. Automatyzacja - pliki Dockerfile

a. Dockerfile przygotowujący środowisko i budujący aplikacje:

Dockerfile.build

b. Dockerfile bazujący na wczesniejszym, uruchamia testy

c. Budowanie obrazu bazowego
d. Budowanie obrazu testowego
e. Uruchomienie kontenera testowego
f. Weryfikacja stanu kontenera po zakończeniu procesu

Exited(0) - oznacza, że proces wewnątrz kontenera zakończył się sukcesem
