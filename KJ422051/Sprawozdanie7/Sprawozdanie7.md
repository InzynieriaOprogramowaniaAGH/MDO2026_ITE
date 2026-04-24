# Sprawdzenie Jenkinsfile

## SCM


## Sprzątanie



… sh "docker stop ${KONTENER_TESTOWY} || true
… sh "docker rm ${KONTENER_TESTOWY} || true


## Build i artefakt

Etap Build tworzy obraz testowy (Dockerfile.build), a potem osobny, lekki obraz produkcyjny (Dockerfile.runtime)

Etapy Build w Pipeline:



Dockerfile.build:


Dockerfile.runtime:


## Testy

Fragment stage2:


## Publish



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
