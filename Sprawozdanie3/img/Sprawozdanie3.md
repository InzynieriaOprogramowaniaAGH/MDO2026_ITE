# Metodyki Devops – lab3

Wybrane oprogramowanie – biblioteka do parsowania URL https://github.com/unshiftio/url-parse

1. Klon repo i instalacja zależności
![img1](img1.png)

2. Wykonanie testów (poprzez npm test)
![img2](img2.png)

3. Uruchomienie kontenera, wewnątrz klonowanie repo (uruchomienie nastąpiło komendą `docker run -it --name devops-build node:18-slim /bin/bash`)
![img3](img3.png)

4. Plik Dockerfile.build
![img4](img4.png)

5. Plik Dockerfile.test
![img5](img5.png)

6. Budowanie pierwszego obrazu
![img6](img6.png)

7. Budowanie drugiego obrazu
![img7](img7.png)

8. Sprawdzenie poprawności działania
![img8](img8.png)

Po wykonaniu `docker run --name testowy-k my-test`
Testy przebiegły poprawnie.

Dodatkowo po wykonaniu `docker ps -a` kontener ma status exited, co oznacza że proces wewnątrz kontenera zakończył się bez żadnych błędów. 

Odpowiadając na pytanie co pracuje w takim kontenerze – pracuje w nim tylko npm test (silnik node.js).
