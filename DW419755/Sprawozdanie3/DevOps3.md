Dawid Wypych Sprawozdanie 3:

Repozytorium spełniające wymogi, które znalazłem to redis
https://github.com/redis/redis

Klonowanie repozytorium:
![][image1]
Budowanie:
![][image2]
![][image3]
Testowanie:
![][image4]
Uruchamianie kontenera:
![][image5]  
Budowanie w kontenerze:
![][image6]
![][image7]  
Testowanie w kontenerze:
![][image8]

Dockerfile.build:
![][image9]
![][image10]
![][image11]
Dockerfile.test
![][image12]
![][image13]
![][image14]

docker-compose.yml:

![][image15]

Dyskusja:
Redis nadaje się do publikowania jako kontener, ponieważ jako usługa sieciowa łatwo może się skalować, izolować zależoności i zapewnia łatwosć w konfiguracji.
W przygotowaniu do finalnego artefaktu należałoby przperowadzić Multi-stage Build w jednym pliku Dockerfile. Pozwala to na separację etapów wewnątrz jednego procesu budowania, dzięki czemu zmiejszyłoby to jego rozmiar. Zbudowny program nie trzeba dystrybułować jako pakiet, ponieważ jest Docker Engine.


[image1]: image1.png
[image2]: image2.png
[image3]: image3.png
[image4]: image4.png
[image5]: image5.png
[image6]: image6.png
[image7]: image7.png
[image8]: image8.png
[image9]: image9.png
[image10]: image10.png
[image11]: image11.png
[image12]: image12.png
[image13]: image13.png
[image14]: image14.png
[image15]: image15.png