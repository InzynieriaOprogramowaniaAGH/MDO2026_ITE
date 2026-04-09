# Sprawozdanie Lab4, Tomasz Kamiński


## Narzędzia i konfiguracja 
Ćwiczenie wykonano w środowisku **Ubuntu Server 24.04.4 LTS** uruchomionym na **VirtualBox**.


## Utworzenie woluminów

![](./img/image2.png)

![](./img/image1.png)

![](./img/image3.png)


## Sklonowanie Repo 

Repozytorium zostało sklonowane przy użyciu kontenera pomocniczego opartego na obrazie alpine/git. Pozwoliło to uniknąć instalowania narzędzia Git w kontenerze bazowym.

![](./img/image5.png)


## Uruchomienienie kontenera budującego 

![](./img/image6.png)



## Build projektu i skopiowanie wynikow do woluminu

![](./img/image7.png)


## Klonowanie wewnątrz kontenera

W drugim podejściu repozytorium zostało sklonowane bezpośrednio w kontenerze bazowym po zainstalowaniu narzędzia Git.

![](./img/image9.png)

![](./img/image10.png)

Sprawdzenie czy się pliki skopiowały

![](./img/image11.png)


## Eksponowanie portu i łączność między kontenerami
Utworzenie sieci my-network 

![](./img/e4.png)

Uruchomienie kontenera iperf w trybie serwera 

![](./img/e.png)

Sprawdzenie ip komenda docker inspect iperf-server

![](./img/e2.png)

Test kontenera w trybie klienta 

![](./img/e3.png)

Utworzonie nowego serwera przyłączonego do sieci my-network

![](./img/e5.png)

![](./img/e6.png)

Sprawdzenie łącznosci z hostem 

![](./img/e7.png)

Z poza hosta:

![](./img/iperf.png)



## Usługa SSH w kontenerze

sudo docker run -dit --name ssh_container -p 2222:22 ubuntu bash

Instalacja w ssh w kontenerze
apt install -y openssh-server

Zmiana konfiguracji 

![](./img/image19.png)
![](./img/image20.png)

Na hoście:

![](./img/image21.png)


Zalety: 
możliwość debugowania kontenera, zdalny dostęp jak do normalnego serwera, integracja ze starszymi systemami

Wady:
większe zużycie zasobów, możliwe problemy z bezpieczeństwem, konieczność zarządzania użytkownikami i hasłami


## Jenkins

Stworzenie sieci dla Jenkinsa i woluminów

![](./img/image23.png)


Uruchomienie kontenera DIND

![](./img/image24.png)


Uruchomienie Kontenera Jenkins

Aby uzyskać dostęp do Jenkins z przeglądarki, konieczne było dodanie nowej reguły przekierowania portów w ustawieniach VM, port hosta, gościa 8080

![](./img/image25.png)

docker ps 

![](./img/image26.png)


odczytanie hasła komendą: sudo docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
0e83f355ede04ed59e3f24886be1eba5

Apliakcja uruchomiona pod adresem:http://localhost:8080


![](./img/last.png)

Zakończona konfiguracja: 


![](./img/last2.png)

