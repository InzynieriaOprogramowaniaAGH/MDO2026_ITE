LAB1:
 
Sprawozdanie Dawid Wypych grupa 6:  
Git:
Zainstaluj klienta Git i obsługę kluczy SSH (w maszynie wirtualnej lub środowisku uniksowym):

SSH:
Utwórz klucze SSH:

![][image1]  
![][image2]  
![][image3]  
![][image4]  
![][image5]

Uwierzytelnianie dwuskładnikowe:

![][image6]  
Konfiguracja VSC:  
![][image7]  
![][image8]  
Kongiguracja WinSCP:  
![][image9]  
Gałęzie github:  
![][image10]  
![][image11]  
Git hook:  
![][image12]
Push na github:
![][image13]

LAB2:
Dawid Wypych Sprawozdanie 2:

Instalacja Dockera:

![][image14]

Utworzenie konta na docker hub:

![][image15]

Zapoznanie się z obrazami; Uruchamianie obrazów

![][image16]  
![][image17]  
![][image18]  
![][image19]  
![][image20]  
![][image21]  
Sprawdzenie rozmiarów:  
![][image22]  
Sprawdzenie kodów wyjścia:  
![][image23]

Uruchomie kontenera busybox, podłączenie interaktywne

![][image24]

Uruchomienie systemu w kontenerze, pokazanie PID1 na kontenerze

![][image25]  
Pokazanie PID1 na hoście:  
![][image26]  
Aktualizacja i wyjście:  
![][image27]

Utworzenie Dockerfile

![][image28]  
Uruchomienie w trybie interaktywnym  
![][image29]  
Weryfikacja czy jest to nasze repo:  
![][image30]

Uruchomione kontenery

![][image31]  
Czyszczenie zakończonych:  
![][image32]

Wyczyszczenie obrazów z lokalnego magazynu

![][image33]

Dockerfile załączony w commicie

LAB3:
Dawid Wypych Sprawozdanie 3:

Repozytorium spełniające wymogi, które znalazłem to redis
https://github.com/redis/redis

Klonowanie repozytorium:
![][image34]
Budowanie:
![][image35]
![][image36]
Testowanie:
![][image37]
Uruchamianie kontenera:
![][image38]  
Budowanie w kontenerze:
![][image39]
![][image40]  
Testowanie w kontenerze:
![][image41]

Dockerfile.build:
![][image42]
![][image43]
![][image44]
Dockerfile.test
![][image45]
![][image46]
![][image47]

docker-compose.yml:

![][image48]

Dyskusja:
Redis nadaje się do publikowania jako kontener, ponieważ jako usługa sieciowa łatwo może się skalować, izolować zależoności i zapewnia łatwosć w konfiguracji.
W przygotowaniu do finalnego artefaktu należałoby przperowadzić Multi-stage Build w jednym pliku Dockerfile. Pozwala to na separację etapów wewnątrz jednego procesu budowania, dzięki czemu zmiejszyłoby to jego rozmiar. Zbudowny program nie trzeba dystrybułować jako pakiet, ponieważ jest Docker Engine.

LAB4:
Zachowywanie stanu między kontenerami  
Woluminy wejściowy i wyjściowy:  
Wolumin wejściowy: redis_src  
Wolumin wyjściowy: redis_bin  
![][image49]  
Używam metody kontenera pomocniczego  
Bezpośrednie kopiowanie do /var/lib/docker/volumes na hoście wymaga uprawnień roota i jest ryzykowne (Docker zarządza tymi plikami). Bind mount jest prosty, ale jeśli chcemy trzymać się czystych woluminów Dockera, kontener pomocniczy z gitem jest najlepszy.  
Kontener pomocniczy z gitem:  
![][image50]  
Build w kontenerze bazowym bez gita  
![][image51]  
![][image52]  
Build z gitem:  
![][image53]  
![][image54]  
Metoda mount:  
Zaletą tej metody jest brak konieczności zarządzania woluminami, ponieważ docker sam dba, by kod był dostępny podczas budowania a finalny obraz nie miał kodu źródłowego i gita.  
![][image55]

Eksponowanie portu i łączność między kontenerami  
Uruchomienie serwera:  
![][image56]  
Uruchomienie klienta i sprawdzenie IP:  
![][image57]  
Test połączenia:  
![][image58]  
Sieć bridge, łączenie domyślne i po nazwie kontenera:  
![][image59]  
Łączenie się z hosta:  
![][image60]  
Połączenie spoza kontenera (zamazany adres ip komputera):  
![][image61]  
Uruchomienie z mapowaniem portu:  
![][image62]  
Prędkość z tego samego komputera:  
![][image63]  
Prędkość z innego urządzenia:  
![][image64]  
Usługi w rozumieniu systemu, kontenera i klastra  
Zestawienie kontenera ubuntu z sshd:  
Dockerfile:  
![][image65]  
Budowanie i uruchamianie:  
![][image66]  
![][image67]  
![][image68]  
Wady i zalety komunikacji z kontenerem z wykorzystaniem SSH:  
Instalowanie SSH in kontenerze jest uznawane za anti-pattern, ponieważ kłóci się z fundamentalną zasadą Single Responsibility, według której jeden kontener powinien uruchamiać tylko jeden główny proces aplikacji, a nie dodatkowe demony systemowe. Chociaż rozwiązanie to ma swoje zalety, takie jak obsługa legacy workflow, łatwe tunelowanie portów do lokalnego komputera, wygodna praca z zdalnymi IDE czy prosty transfer plików przez scp, to lista wad jest znacznie dłuższa. Głównym problemem jest bezpieczeństwo, ponieważ każdy dodatkowy proces zwiększa powierzchnie ataku, a zarządzanie kluczami SSH wewnątrz efemerycznych kontenerów grozi ich wyciekiem w warstwach obrazu. Ponadto instalacja OpenSSH i powiązanych bibliotek niepotrzebnie zwiększa rozmiar obrazu o setki megabajtów, co spowalnia procesy CI/CD. Największym zagrożeniem jest jednak fakt, że kontenry nie mogą być łatwo zastępowalne, ponieważ można się do nich logować z ssh i zmieniać wewnętrzną konfigurację

Przygotowanie do uruchomienia serwera Jenkins:  
Przygotowanie infrastruktury:  
![][image69]  
Uruchomienie pomocnika DinD:  
![][image70]  
Uruchomienie Jenkinsa:  
![][image71]  
Działające kontenery:  
![][image72]  
Ekran logowania:  
![][image73]  
![][image74]


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
[image16]: image16.png
[image17]: image17.png
[image18]: image18.png
[image19]: image19.png
[image20]: image20.png
[image21]: image21.png
[image22]: image22.png
[image23]: image23.png
[image24]: image24.png
[image25]: image25.png
[image26]: image26.png
[image27]: image27.png
[image28]: image28.png
[image29]: image29.png
[image30]: image30.png
[image31]: image31.png
[image32]: image32.png
[image33]: image33.png
[image34]: image34.png
[image35]: image35.png
[image36]: image36.png
[image37]: image37.png
[image38]: image38.png
[image39]: image39.png
[image40]: image40.png
[image41]: image41.png
[image42]: image42.png
[image43]: image43.png
[image44]: image44.png
[image45]: image45.png
[image46]: image46.png
[image47]: image47.png
[image48]: image48.png
[image49]: image49.png
[image50]: image50.png
[image51]: image51.png
[image52]: image52.png
[image53]: image53.png
[image54]: image54.png
[image55]: image55.png
[image56]: image56.png
[image57]: image57.png
[image58]: image58.png
[image59]: image59.png
[image60]: image60.png
[image61]: image61.png
[image62]: image62.png
[image63]: image63.png
[image64]: image64.png
[image65]: image65.png
[image66]: image66.png
[image67]: image67.png
[image68]: image68.png
[image69]: image69.png
[image70]: image70.png
[image71]: image71.png
[image72]: image72.png
[image73]: image73.png
[image74]: image74.png
