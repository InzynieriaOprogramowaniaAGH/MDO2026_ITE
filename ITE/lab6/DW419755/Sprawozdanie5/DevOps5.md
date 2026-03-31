Przygotowanie:
Uruchomienie środowiska zagnieżdżonego (Docker-in-Docker):
![Obraz](image.png)
Przygotowanie obrazu Blue Ocean:
![alt text](image-2.png)
Budowanie obrazu:
![alt text](image-1.png)
![alt text](image-3.png)
Uruchomienie kontenera Blue Ocean:
![alt text](image-4.png)
Strona startowa Jankins:
![alt text](image-5.png)
Gotowy setup:
![alt text](image-8.png)
Zabezpiecznia Jenkinsa:
max-size (10m): Jeden plik logu nie przekroczy 10 megabajtów.
max-file (3): Docker będzie trzymał maksymalnie 3 archiwalne pliki logów.
![alt text](image-7.png)

Zadanie wstępne: uruchomienie:
Uname
![alt text](image-6.png)
Wyświetlanie uname:
![alt text](image-9.png)
Execute shell dla godziny nieprarzystej:
![alt text](image-10.png)
Działa:
![alt text](image-11.png)
Pobieranie obrazu kontenera ubuntu:
![alt text](image-12.png)

Obiekt typu pipeline
Towrzenie pipeline:
![alt text](image-13.png)
Wykonany pipeline:
![alt text](image-14.png)
Wykonany drugi pipeline:
![alt text](image-15.png)
Drugi pipeline wykonał się dużo szybciej, ponieważ obraz ubuntu został już pobrany podczas pierwszego pipeline'a.