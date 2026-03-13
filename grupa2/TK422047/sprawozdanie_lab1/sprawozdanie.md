
# Sprawozdanie Lab1, Tomasz Kamiński

## Narzędzia i konfiguracja 
Ćwiczenie wykonano w środowisku **Ubuntu Server 24.04.4 LTS** uruchomionym na **VirtualBox**.
* **Port hosta:** 2222 
* **Port klienta:** 22

![Filezilla](./img/filezilla.png)

![VS Code](./img/image5.png)

## SSH
Wygenerowano parę kluczy SSH (jeden zabezpieczony hasłem, drugi bez)

![](./img/image1.png)
![](./img/image2.png)
![](./img/image3.png)

## Dodawanie klucza do GitHuba i autoryzacja




![doadanie klucza](./img/image4.png)
![Uwierzytelnianie dwuetapowe 2FA](./img/image9.png)

## Branch i praca z repozytorium
Sklonowano repozytorium przy użyciu protokołu SSH, a następnie utworzono nowy branch. Przy klonowaniu repo przez https:
git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git  

![Sklonowanie repo przez ssh](./img/image6.png) 

![Utworzenie nowego brancha](./img/image7.png)

### Skrypt Git hook (commit-msg)
W ramach zadania utworzono skrypt weryfikujący, czy każda zwartość commita zaczyna się od prefixu `TK422047`.

![bash](./img/image8.png)

Skrypt skopiowana do odpowiedniego folderu i przetestwowano przykładowy commit 

![Testowy commit](./img/image11.png)

Poprawny commit

![pierwszy commit](./img/image12.png)

Przesłanie cwiczenia do zdalnego repo

![push](./img/image13.png)

## Pull Request 

![pullrequest](./img/pullrequest.png)

