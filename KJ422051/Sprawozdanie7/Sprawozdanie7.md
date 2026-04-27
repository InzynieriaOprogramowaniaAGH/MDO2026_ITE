# Sprawdzenie Jenkinsfile

## SCM

<img width="945" height="561" alt="image" src="https://github.com/user-attachments/assets/31968add-e116-4209-98e8-612477df6e8a" />


## Sprzątanie

<img width="945" height="447" alt="image" src="https://github.com/user-attachments/assets/5d3a9d35-f8a7-4e3f-a602-f07a5ab901a4" />


… sh "docker stop ${KONTENER_TESTOWY} || true

… sh "docker rm ${KONTENER_TESTOWY} || true


## Build i artefakt

Etap Build tworzy obraz testowy (Dockerfile.build), a potem osobny, lekki obraz produkcyjny (Dockerfile.runtime)

Etapy Build w Pipeline:

<img width="945" height="334" alt="image" src="https://github.com/user-attachments/assets/843cc15a-49b2-423d-ad68-9e1bcadf165a" />

<img width="858" height="173" alt="image" src="https://github.com/user-attachments/assets/4a03f939-3c40-4c4a-a5df-f584c36a0acc" />


Dockerfile.build:

<img width="314" height="283" alt="image" src="https://github.com/user-attachments/assets/12b0acf6-ad26-4de3-b49f-bf76cbada075" />


Dockerfile.runtime:

<img width="441" height="331" alt="image" src="https://github.com/user-attachments/assets/c574434a-f077-4aba-9993-6753c5f6dbc6" />


## Testy

Fragment stage2:

<img width="945" height="115" alt="image" src="https://github.com/user-attachments/assets/8d21da39-36be-4e5d-a971-98ee978ba0c2" />


## Publish

<img width="945" height="349" alt="image" src="https://github.com/user-attachments/assets/729e1978-f55a-4bd7-9ebd-0a19d0e492b7" />



Tar -czvf – tworzy skompresowane archiwum app-v1.0.7.tar.gz zawierające kluczowe pliki aplikacji (package.json oraz app.js).

Dzięki funkcji archveArtifacts gotowa paczka zostaje trwale zapisana w Jenkins.



## Podsumowanie

W procesie powstają dwa rodzaje artefaktów: 

- Obraz Dockerowy (Dockerfile.runtime): jest gotowy do uruchomienia, zawiera całe środowisko uruchomieniowe (Node.js), zależności oraz sam kod.
  
- Archiwum app-v1.0.7.tar.gz: Jest to artefakt paczkowany, który zawiera kluczowe pliki aplikacji (package.json, app.js).

Opublikowany obraz może być porbany i uruchomiony bez modyfikacji. Etap 4 (Smoke test) polega na uruchomieniu zbudowanego obrazu i sprawdzenie jego działania poprzez curl. Skoro kontener uruchomił się w Jenkinsie i odpowiedział na porcie 3000 oznacza to, że obraz jest poprawnie skonfigurowany.


Artefakt pobrany z Jenkinsa może zadziałać od razu na maszynie docelowej:

- Obraz Docker - najbardziej pewny artefakt - zadziała wszędzie, gdzie zainstalowany jest Docker.
	
- Paczka tar.gz - zadziała od razu na każdej maszynie, która ma zainstalowane środowisko Node.js.
