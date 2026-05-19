# Sprawozdanie: Dodatkowa terminologia w konteneryzacji, instancja Jenkins
Autor: Maciej Fraś 

Data: 27 marca 2026 r.

Środowisko: Ubuntu 24.04.4 LTS (Virtual Machine / Hyper-V), Visual Studio Code (VSC)

1. Cel zajęć
Celem zajęć jest uruchomienie instancji Jenkins w środowisku skonteneryzowanym. Potrzebna jest do tego dodatkowa wiedza dotycząca kontenerów.

2. Pobranie repo i build w kontenerze

![PobranieRepo](Screenshots/PobranieRepo.png)
![Uruchomienie Kontenera](Screenshots/uruchamnianieKontener.png)
![Przygotowywanie Środowiska ](instalajca_gcc.png)
![Test](Screenshots/test_dzialania.png)

3. Łączność między kontenerami - IPerf3

![Stworzenie własnej sieci Dockerowej ](Screenshots/StworzenieSieciDocker.png)
![Łączenie się z serwerem i badanie przepustowosci sieci ](Screenshots/badaniePrzepustowosciIperf.png)

4. Usługa SSH w kontenerze

![Uruchomienie kontenera z usługą sshd](Screenshots/SshKontener.png)

5. Instalacja serwera Jenkins 

![Jenkins Server](Screenshots/uruchomieniJeetkinsa.png)
![alt text](Screenshots/uruchominieDInda.png)

6. Weryfikacja
![JenkinsPassw](jenkinsPasw.png)
![Usługa Jenkins na localhoscie w przegladarce](Screenshots/Localhost.png)

7. Podsumowanie i wnioski
Konteneryzacja pozwoliła na pełną izolację środowiska budowania od systemu operacyjnego hosta.