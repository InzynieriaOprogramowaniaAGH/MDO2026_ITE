Zachowywanie stanu między kontenerami  
Woluminy wejściowy i wyjściowy:  
Wolumin wejściowy: redis_src  
Wolumin wyjściowy: redis_bin  
![][image1]  
Używam metody kontenera pomocniczego  
Bezpośrednie kopiowanie do /var/lib/docker/volumes na hoście wymaga uprawnień roota i jest ryzykowne (Docker zarządza tymi plikami). Bind mount jest prosty, ale jeśli chcemy trzymać się czystych woluminów Dockera, kontener pomocniczy z gitem jest najlepszy.  
Kontener pomocniczy z gitem:  
![][image2]  
Build w kontenerze bazowym bez gita  
![][image3]  
![][image4]  
Build z gitem:  
![][image5]  
![][image6]  
Metoda mount:  
Zaletą tej metody jest brak konieczności zarządzania woluminami, ponieważ docker sam dba, by kod był dostępny podczas budowania a finalny obraz nie miał kodu źródłowego i gita.  
![][image7]

Eksponowanie portu i łączność między kontenerami  
Uruchomienie serwera:  
![][image8]  
Uruchomienie klienta i sprawdzenie IP:  
![][image9]  
Test połączenia:  
![][image10]  
Sieć bridge, łączenie domyślne i po nazwie kontenera:  
![][image11]  
Łączenie się z hosta:  
![][image12]  
Połączenie spoza kontenera (zamazany adres ip komputera):  
![][image13]  
Uruchomienie z mapowaniem portu:  
![][image14]  
Prędkość z tego samego komputera:  
![][image15]  
Prędkość z innego urządzenia:  
![][image16]  
Usługi w rozumieniu systemu, kontenera i klastra  
Zestawienie kontenera ubuntu z sshd:  
Dockerfile:  
![][image17]  
Budowanie i uruchamianie:  
![][image18]  
![][image19]  
![][image20]  
Wady i zalety komunikacji z kontenerem z wykorzystaniem SSH:  
Instalowanie SSH w kontenerze jest uznawane za anti-pattern, ponieważ kłóci się z fundamentalną zasadą Single Responsibility, według której jeden kontener powinien uruchamiać tylko jeden główny proces aplikacji, a nie dodatkowe demony systemowe. Chociaż rozwiązanie to ma swoje zalety, takie jak obsługa legacy workflow, łatwe tunelowanie portów do lokalnego komputera, wygodna praca z zdalnymi IDE czy prosty transfer plików przez scp, to lista wad jest znacznie dłuższa. Głównym problemem jest bezpieczeństwo, ponieważ każdy dodatkowy proces zwiększa powierzchnie ataku, a zarządzanie kluczami SSH wewnątrz efemerycznych kontenerów grozi ich wyciekiem w warstwach obrazu. Ponadto instalacja OpenSSH i powiązanych bibliotek niepotrzebnie zwiększa rozmiar obrazu o setki megabajtów, co spowalnia procesy CI/CD. Największym zagrożeniem jest jednak fakt, że kontenry nie mogą być łatwo zastępowalne, ponieważ można się do nich logować z ssh i zmieniać wewnętrzną konfigurację

Przygotowanie do uruchomienia serwera Jenkins:  
Przygotowanie infrastruktury:  
![][image21]  
Uruchomienie pomocnika DinD:  
![][image22]  
Uruchomienie Jenkinsa:  
![][image23]  
Działające kontenery:  
![][image24]  
Ekran logowania:  
![][image25]  
![][image26]

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
