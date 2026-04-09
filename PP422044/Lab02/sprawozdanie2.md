# Sprawozdanie 2

## 1. Instalacja Dockera

	sudo apt update
	sudo apt install docker.io -y
	sudo usermod -aG docker $USER
	newgrp docker
	
	docker --version

![dockerversion](./dockerversion.png)

## 2. Pobranie obrazow

	docker pull hello-world

![helloworld](./helloworld.png)

	docker pull busybox

![busybox](./busybox.png)

	docker pull ubuntu

![ubuntu](./ubuntu.png)

	docker pull mariadb

![mariadb](./mariadb.png)

## 3. Sprawdzanie rozmiarow

	docker images

![images](./images.png)

## 4. Sprawdzanie kodu wyjscia

![kodwyjscia](./kodwyjscia.png)

## 5. Tryb interaktywny

![busyboxinteraktywny](./busyboxinteraktywny.png)


![ubuntuinteraktywny](./ubuntuinteraktywny.png)

## 6. Dockerfile

	Tresc Dockerfile:

![dockerfile](./dockerfile.png)

	Budowanie obrazu:
		docker build -t moje-repo-env .
		docker run -it moje-repo-env
		ls -la

![budowanieobrazu](./budowanieobrazu.png)

## 7. Czyszczenie srodowiska

	docker ps -a
	docker container prune -f

![czyszczeniekontenerow](./czyszczeniekontenerow.png)

	docker images
	docker image prune -a -f

![czyszczenieobrazow](./czyszczenieobrazow.png)


