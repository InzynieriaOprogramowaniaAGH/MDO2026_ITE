# Sprawozdanie 4 - Terminologia konteneryzacji i instancja Jenkins
**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE  
**Grupa:** G6  

## 1. Zachowywanie stanu między kontenerami (Storage)
Celem zadania było przetestowanie różnych metod przechowywania danych w środowisku Docker: Bind Mounts (mapowanie z hosta) oraz Named Volumes (woluminy zarządzane przez Docker).

### Metoda 1: Bind Mount (Kod z hosta)
W pierwszym etapie przygotowałem woluminy i uruchomiłem kontener bazowy `gcc`, montując kod źródłowy bezpośrednio z katalogu serwera (`~/hello-world-test`) w trybie tylko do odczytu (`:ro`).

![Tworzenie woluminów wejściowych i wyjściowych](01_woluminy.png)
![Uruchomienie kontenera z mapowaniem Bind Mount](02_1_bind-mount.png)

Wewnątrz kontenera przeprowadziłem kompilację pliku `hello.c`. Wynikowy plik binarny został zapisany na woluminie wyjściowym `vol-wyjsciowy`, co gwarantuje jego trwałość po usunięciu kontenera.

![Kompilacja kodu i zapis na wolumin wyjściowy](02_2_bind-mount.png)

### Metoda 2: Named Volume (Git wewnątrz kontenera)
W drugim scenariuszu kod został pobrany bezpośrednio wewnątrz kontenera do dedykowanego woluminu `vol-wejsciowy`. Ta metoda izoluje proces pobierania kodu od systemu plików hosta.

![Klonowanie repozytorium do woluminu wewnątrz kontenera](03_1_git.png)

Poprawność zapisu danych w woluminie zweryfikowałem za pomocą osobnego, lekkiego kontenera `alpine`. Dane (plik `hello.c`) "przeżyły" restart i były dostępne dla kolejnego środowiska.

![Weryfikacja trwałości danych w woluminie za pomocą kontenera Alpine](03_2_git.png)

## 2. Łączność między kontenerami (Networking)
Kolejnym etapem było zbadanie komunikacji wewnątrz sieci Docker. Stworzyłem dedykowaną sieć mostkową (`moja-siec`), aby umożliwić kontenerom komunikację przy użyciu nazw (DNS), a nie zmiennych adresów IP.

### Test przepustowości IPerf3
Uruchomiłem serwer `iperf3` w tle, a następnie połączyłem się z nim z drugiego kontenera. Test wykazał przepustowość na poziomie ok. 19 Gbits/sec, co udowadnia sprawność komunikacji wewnątrz wirtualnego mostu (bridge).

![Test wydajności sieci i komunikacja po nazwie kontenera](04_iperf.png)

## 3. Usługi: Konfiguracja SSHD
Zestawiłem usługę SSH (OpenSSH Server) wewnątrz kontenera Ubuntu. Skonfigurowałem dostęp dla użytkownika root i przekierowałem port 22 kontenera na port 2222 hosta.

![Instalacja i konfiguracja serwera SSH w kontenerze](05_1_openssh.png)
![Uruchomienie demona sshd i ustawienie uprawnień](05_2_openssh.png)

Połączenie z hosta do kontenera zakończyło się sukcesem.

![Udane logowanie SSH do wnętrza kontenera](05_3_openssh.png)

**Wnioski:** Komunikacja przez SSH jest użyteczna w specyficznych przypadkach użycia, jednak w nowoczesnej konteneryzacji uznaje się ją za zbędną (lepiej stosować `docker exec`), gdyż zwiększa rozmiar obrazu i obniża bezpieczeństwo.

## 4. Instancja Jenkins (Docker-in-Docker)
Finałem prac było uruchomienie serwera CI Jenkins w architekturze Sidecar. Zastosowałem mechanizm **DIND (Docker-in-Docker)**, który pozwala Jenkinsowi na budowanie i uruchamianie własnych kontenerów.

### Instalacja i inicjalizacja
Proces wymagał dwóch kontenerów: `jenkins-docker` (pomocnik z uprawnieniami uprzywilejowanymi) oraz `jenkins-main` (właściwy serwer Jenkins).

![Uruchomienie Jenkinsa wraz z pomocnikiem DinD](06_1_jenkins.png)

Po uruchomieniu, Jenkins wymagał odblokowania przy użyciu tymczasowego hasła administratora wygenerowanego wewnątrz woluminu danych.

![Ekran odblokowania Jenkinsa](06_2_jenkins.png)
![Ekran wyboru wtyczek po zainicjalizowaniu instancji](06_3_jenkins.png)

### Weryfikacja środowiska
Na koniec zweryfikowałem poprawność działania wszystkich komponentów. Komenda `docker ps` wykazuje działające kontenery Jenkinsa oraz serwer iperf w tej samej infrastrukturze.

![Wykaz działających kontenerów Jenkinsa i usług pomocniczych](07_kontenery.png)