### Metodyki DevOps – Sprawozdanie Zbiorcze lab 1-4
### Autor: Kinga Sulej gr.6 

## LAB1

1.	Instalacja VirtualBox i konfiguracja

![img1](1.1.png)

2.	Instalacja i uruchomienie środowiska (debian)

![img2](1.2.png)

3.	Po ustawieniu port forwarding rule udało się połączyć przez ssh

![img3](1.3.png)
 
4.	Przeslanie pliku na VM

![img4](1.4.png)

Obraz przesłał się poprawnie do maszyny 

![img5](1.5.png)
 
5.	Klonwowanie repo z wewnątrz maszyny

![img6](1.6.png)

Klonowanie działa

![img7](1.7.png)

6.	Połączenie przez filezilla

![img8](1.8.png)
 
7.	Zadania – class1
Instalacja klienta GIT i klonowanie repozytorium grupy

![img9](1.9.png)
 
Tworzenie kluczy SSH
![img10](1.10.png)

![img11](1.11.png)

Konfiguracja w Visual Studio Code

![img12](1.12.png)

Git Hook

![img13](1.13.png)

Zdalne źródło

![img14](1.14.png)

![img15](1.15.png)

## LAB2

1. Instalacja dockera
   
![img16](img1.png)

2. Pobranie obrazów

![img17](img2.png)

3. Uruchomienie kontenerów i sprawdzenie kodu wyjścia
   
![img18](img3.png)

4. Busybox

![img19](img4.png)

5. System w kontenerze

![img20](img5.png)

Z drugiego terminala:

![img21](img6.png)

6. Dockerfile i klonowanie repo 

![img22](img7.png)

![img23](img8.png)

7. Czyszczenie kontenerów (dla kroku 6 z instrukcji nie udało się zrobić zrzutu w 
odpowiednim momencie, więc dodatkowo wrzucam „dowód” że było to 
zrobione”

![img24](img9.png)

![img25](img10.png)

 ## LAB3

Wybrane oprogramowanie – biblioteka do parsowania URL https://github.com/unshiftio/url-parse

1. Klon repo i instalacja zależności

![img26](3img1.png)

2. Wykonanie testów (poprzez npm test)

![img27](3img2.png)

3. Uruchomienie kontenera, wewnątrz klonowanie repo (uruchomienie nastąpiło komendą `docker run -it --name devops-build node:18-slim /bin/bash`)
   
![img28](3img3.png)

4. Plik Dockerfile.build
   
![img29](3img4.png)

5. Plik Dockerfile.test
   
![img30](3img5.png)

6. Budowanie pierwszego obrazu
   
![img31](3img6.png)

7. Budowanie drugiego obrazu
   
![img32](3img8.png)

8. Sprawdzenie poprawności działania
   
![img33](3img9.png)

Po wykonaniu `docker run --name testowy-k my-test`
Testy przebiegły poprawnie.

Dodatkowo po wykonaniu `docker ps -a` kontener ma status exited, co oznacza że proces wewnątrz kontenera zakończył się bez żadnych błędów.

![img34](3img10.png)

Odpowiadając na pytanie co pracuje w takim kontenerze – pracuje w nim tylko npm test (silnik node.js).

## LAB4

### Zachowywanie stanu między kontenerami 
1. Utworzenie dwóch woluminów

![img35](1.png)

2. Sklonowanie repozytorium bez Gita w kontenerze docelowym

Skoro kontener budujący nie może mieć gita, używam kontenera pomocniczego bazującego na alpine, który pobiera kod kod na wolumin i jest od razu usuwany

![img36](2.png)

Jak widać na powyższym zdjęciu, następnie uruchomiono właściwy kontener bazowy ze środowiskiem Node.js,  za pomocą flag -v podłączono do niego woluminy wejściowy (zawierający pobrany wcześniej kod źródłowy) i wyjściowy (pusty, przeznaczony na gotowy build).
 
3. Po wykonaniu wewnątrz kontenera  ```npm install``` i następnym ```npm test``` - procesy zakończyły się pomyślnie.

![img37](3.png)

4. Skopiowanie do drugiego woluminu

![img38](4.png)

5. Powtórzenie czynności z klonowaniem na wolumin wejściowy wewnątrz kontenera

Uruchomienie czystego kontenera

![img39](5.png)

Instalacja gita komendą ```apt-get update && apt-get install -y git```\
Klon repo do woluminu

![img40](6.png)

testy przebiegły pomyślnie 

![img41](7.png)

6. Automatyzacja za pomocą ```docker build``` i ```Dockerfile```

Ręczne uruchamianie kontenerów, mapowanie woluminów i wpisywanie komend powinno być stosowane głównie do celów badawczych/naukowych (tak jak na labie), w praktyce te procesy są automatyzowane - Docker BuildKit udostępnia flagę ```--mount``` dla instrukcji RUN, co pozwala odtworzyć wyżej wykonane kroki

 ## Eksponowanie portu i łączność między kontenerami

1. Uruchomienie serwera iperf wewnątrz kontenera i znalezienie jego adresu IP

![img42](8.png)

2. Połączenie z drugiego kontenera

![img43](9.png)

W domyślnej sieci mostkowej Dockera, kontenery komunikują się ze sobą, ale trzeba najpierw znać ich adres IP

3. Własna sieć

Tworzenie sieci, odpalanie nowego serwera z wpięciem go do nowo utworzonej sieci, odpalenie klienta i połączenie 

![img44](10.png)

Dzięki utworzeniu dedykowanej sieci mostkowej,  kontenery mogą się komunikować ze sobą przy użyciu swoich nazw, dzięki czemu nie trzeba polegać na przydzielanych adresach IP

4. Połączenie się z hosta

Pierwszy krok to przygotowanie serwera 
``` docker run -d --name iperf_next -p 5201:5201 networkstatic/iperf3 -s ```
Połączenie z hosta 

![img45](11.png)

Test przebiega pozytywnie - przepustowość jest wysoka, co wynika z faktu, że ruch nie przechodzi przez fizyczną kartę sieciową, tylko przez wirtualny interfejs w pamięci RAM - prędkość jest ograniczona jedynie mocą cpu

Połączenie spoza hosta jest problemem, ponieważ maszyna wirtualna działa domyślnie w sieci typu NAT (co widać po adresie ```10.0.2.15``` - jest schowana za wirtualnym routerem i system (Windows) jej nie widzi, aby test się udał, należy zrobić Port Forwarding w ustawieniach VMKi 

![img46](12.png)

Wyciągnięcie logów z kontenera

![img47](13.png)

## Usługi w rozumieniu systemu, kontenera i klastra
1. Zestawienie ubuntu w tle i wejście do niego

![img48](14.png)

Instalacja SSH wewnątrz kontenera (```apt-get install -y openssh-server```) i uruchomienie

![img49](15.png)

2. Łączenie 

![img50](16.png)

Z reguły, zestawianie SSH w kontenerze to zazwyczaj zły pomysł, ponieważ kontener ma z załozenia uruchamiać tylko jeden proces, dlatego SSH generuje dodatkowe obciążenie i jest zresztą zbędne, ponieważ Docker posiada swoje narzędzie do wchodzenia do kontenerów (```docker exec```) - może to mieć sens w przypadku tworzenia honeypotów lub jumpboxów

## Przygotowanie do uruchomienia Jenkins
1. Tworzenie sieci dla Jenkinsa i odpalenie DinD (Docker-in-Docker)

![img51](17.png)

2. Uruchomienie Jenkinsa

![img52](18.png)

3. Działające kontenery + ekran logowania

![img53](19.png) \


![img54](20.png)















 
 

















 

