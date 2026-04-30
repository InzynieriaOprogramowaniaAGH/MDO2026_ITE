# Sprawozdanie - zajęcia 4

1. Przygotowanie woluminów: wejściowego i wyjściowego.

![1](obrazyLab4/01.png)

2. Uruchomienie kontenera z woluminami, zainstalowanie niezbędnych wymagań (bez Gita).

![2](obrazyLab4/02.png)

![3](obrazyLab4/03.png)
![4](obrazyLab4/04.png)

3. Sklonowanie repozytorium na wolumin wejściowy.
W moim przypadku został użyty wolumin Dockera jako "wejścia", a następnie uruchomiono kontener.

Jest to dobra praktyka, ponieważ:
	a) kontener można usunąć, ale wolumin zostaje (trwałość danych).
	b) separujemy dane od kontenera.
	c) ten sam wolumin może być podpięty do różnych kontenerów.

Alternatywne podejścia:
	a) Bind mount (lokalny katalog) -v /home/user/project:/input (dzięki temu pliki widoczne są na hoście)
	b) Kopiowanie do /var/lib/docker (raczej mniej zalecane, ze względu na mniejszą kontrolę).

W zastosowanym podejściu nie był potrzebny wolumin pomocniczy (wystarczył jeden kontener - builder).

![9](obrazyLab4/09.png)

![7](obrazyLab4/07.png)
![8](obrazyLab4/08.png)

4. Build w kontenerze, zapisanie danych na wolumnie wyjściowym.

![10](obrazyLab4/10.png)

![11](obrazyLab4/11.png)
![12](obrazyLab4/12.png)

5. Klonowanie wewnątrz kontenera.

![13](obrazyLab4/13.png)

6. Dyskusja na temat możliwosci wykonania ww. kroków za pomocą docker build i pliku Dockerfile:

Kroki realizacji (klonowanie repozytorium, instalacja zależności oraz budowa projektu) mogą zostać zrealizowane również w trakcie budowania obrazu Docker przy użyciu Dockerfile oraz mechanizmu RUN --mount.
W tym podejściu operacje takie jak git clone lub dostęp do katalogów projektu mogą być wykonywane w warstwie builda, bez konieczności ręcznego uruchamiania kontenera i montowania wolumenów w runtime.

W przeciwieństwie do podejścia opartego o woluminy Docker, dane uzyskane w RUN --mount są tymczasowe i istnieją jedynie w trakcie budowania obrazu, chyba że zostaną jawnie zapisane do warstwy obrazu (COPY/RUN).

7. Uruchomienie wewnątrz kontenerów serweru iperf.

![16](obrazyLab4/16.png)
![17](obrazyLab4/17.png)

![18](obrazyLab4/18.png)

8. Znalezienie adresu IP, połączenie się z "kontenerem-serverem" z drugiego kontenera.

![20](obrazyLab4/20.png)
![21](obrazyLab4/21.png)
![22](obrazyLab4/22.png)

9. Ponowienie poprzedniego kroku, ale z wykorzystaniem własnej sieci mostkowej (wykorzystanie nazw zamiast adresów IP).

![23](obrazyLab4/23.png)
![25](obrazyLab4/25.png)

10. Połączenie z poza kontenera.

![26](obrazyLab4/26.png)

11. SSH w kontenerze.

![28](obrazyLab4/28.png)
![29](obrazyLab4/29.png)
![31](obrazyLab4/31.png)

Nastąpił problem z zalogowaniem się do root`a. Wszelkie próby szukania/zmienienia hasła zakończyły się niepowodzeniem.

![32](obrazyLab4/32.png)

12. Zalety i wady komunikacji z kontenerem z wykorzystaniem SSH.

Wykorzystanie SSH do komunikacji z kontenerem umożliwia interaktywne zarządzanie środowiskiem w sposób podobny do klasycznych serwerów. Rozwiązanie to ułatwia diagnostykę oraz integrację z istniejącymi narzędziami administracyjnymi.
Jednakże podejście to stoi w sprzeczności z ideą konteneryzacji, gdzie zaleca się uruchamianie pojedynczego procesu oraz zarządzanie kontenerami przez mechanizmy natywne Dockera.

13. Instalacja, inicjalizacja, uruchomienie skonteneryzowanej instancji Jenkinsa z pomocnikiem DIND.

![35](obrazyLab4/35.png)
![36](obrazyLab4/36.png)
![37](obrazyLab4/37.png)

inicjalizacja
![39](obrazyLab4/39.png)
![40](obrazyLab4/40.png)

sprawdzenie czy kontener działa
![38](obrazyLab4/38.png)

14. Ekran logowania.

![41](obrazyLab4/41.png)
![42](obrazyLab4/42.png)
