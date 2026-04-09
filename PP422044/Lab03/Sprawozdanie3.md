# SPRAWOZDANIE 3

## 1. Instalacja npm i klonowanie repozytorium
	
	sudo apt update
	sudo apt install -y nodejs npm
	git clone https://github.com/expressjs/express.git .

![klonowanie](./klonowanie.png)

## 2. Przeprowadzenie testow

	npm test

![testy](./testy.png)

## 3. Czysty obraz nodejs

	Uruchomienie kontenera z flaga -it, praca na terminalu wewnatrz kontenera
	docker run -it node:18-bullseye /bin/bash

![czystyobraz](./czystyobraz.png)

## 4. Klonowanie repozytorium do obrazu

![klonowaniedoobrazu](./klonowaniedoobrazu.png)

## 5. Testy w obrazie

![testwobrazie](./testwobrazie.png)

## 6. Dockerfile

	Automatyzacja za pomoca Docker file, build zajmuje sie przygotowaniem srodowiska, a test uruchamia testy

	nano Dockerfile.build

![dockerfilebuild](./dockerfilebuild.png)

	nano Dockerfile.test

![dockerfiletest](./dockerfiletest.png)

## 7. Budowa i uruchomienie testow

	docker build tworzy obrazy, a docker run uruchamia kontener powiazany ze stworzonym obrazem

	docker build -t lab-3-build:latest -f Dockerfile.build .

![buildkontener](./buildkontener.png)

	docker build -t lab-3-test:latest -f Dockerfile.test .

![testkontener](./testkontener.png)

	docker run --rm lab-3-test:latest

![kontenertestyrun](./kontenertestyrun.png)
