# Sprawozdanie - zajęcia 3

1. Po znalezieniu repozytorium z kodem danego oprogramowania, które spełniało warunki scenariusza:
	a) dysponowało otwartą licencją
	b) miało narzędzia typu make build
	c) zawierało zdefiniowane i obecne testy
nastąpiło kolejno: sklonowanie niniejszego repozytorium, przeprowadzenie build-a programu wraz z instalacją wymaganych zależności. Na koniec uruchomiono testy jednostkowe dołączone do projektu w repozytorium.

![1](01.png)

![2](02.png)

![3](03.png)

![4](04.png)

![5](05.png)

![6](06.png)


2. Ponowienie wcześniejszego procesu w kontenerze (interaktywnie).

Uruchomienie kontenera z Node, instalacja git, sklonowanie repo w kontenerze, build, testy

![7](07.png)

![8](08.png)

![9](09.png)

![10](10.png)

![11](11.png)

![12](12.png)

![13](13.png)


3. Tworzenie plików Dockerfile (automatyzacja powyższych kroków)

Utworzenie pliku Dockerfile.build
![15](15.png)

![14](14.png)

Budowanie obrazu:

![16](16.png)
![17](17.png)


Utworzenie pliku Dockerfile.test, budowa drugiego obrazu
![19](19.png)

![18](18.png)

![20](20.png)

Uruchomienie testów z kontenera:

![21](21.png)
![22](22.png)


4. Obraz vs kontener

Obraz - szablon (np. node:18)
Kontener - uruchomiona instancja obrazu

W moim przypadku w kontenerze działa proces Node.js uruchamiający testy (npm test)

![23](23.png)

