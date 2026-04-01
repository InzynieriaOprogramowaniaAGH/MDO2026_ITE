## Sprawozdanie

### 1. Woluminy

**Utworzenie woluminów**

![Utworzenie woluminów](1.jpg)

**Uruchomienie kontenera bez Gita**

![Uruchomienie kontenera bez gita](2.jpg)

**Klonowanie repozytorium na wolumin poprzez skopiowanie plików z hosta**

![Klonowanie repozytorium na wolumin poprzez skopiowanie plików z hosta](3.jpg)

Skopiowałem w ten sposób ponieważ był on zwyczajnie najprostszy bez użycia Gita.

**Uruchomienie build w kontenerze**

![Uruchomienie build w kontenerze](4.jpg)

**Kopiowanie plików na wolumin wyjściowy**

![Kopiowanie plików na wolumin wyjściowy](5.jpg)

![(6.jpg)](6.jpg)

**Uruchomienie kontenera z Git**

![Uruchomienie kontenera z git](7.jpg)

**Klonowanie repo przez Git w kontenerze**

![Klonowanie repo przez git w kontenerze](8.jpg)

Wyżej wymienione kroki można wykonać przez docker build z plikiem Dockerfile. Dzięki RUN --mount można dodawać zasoby podczas budowania. Jest to dobre podejście do automatyzacji procesów, jednak przy jednokrotnym wykonaniu standardowa metoda jest równie dobra.

![(9.jpg)](9.jpg)
![(10.jpg)](10.jpg)

### 2. IPerf

**Uruchomienie kontenerów serwera i klienta IPerf**

![Uruchomienie kontenerów serwera i Klienta Iperf](11.jpg)

**Sieć mostkowa**

![Sieć mostkowa](12.jpg)

**Łączenie się z IPerf przez hosta**

![Łączenie się z Iperf przez hosta](13.jpg)

**Logi z iperf**

![Logi z iperf](15.jpg)

### 3. SSHD

**Utworzenie pliku do instalacji SSHD**

![Utworzenie pliku do instalacji SSHD](16.jpg)

**Połączenie z SSHD**

![Połączenie z SSHD się udało - usługa działa](17.jpg)

Zalety SSH - popularność, bezpieczeństwo przez szyfrowanie i kontrola dostępu do kontenera.  
Wady - Powiększenie kontenera i skomplikowanie przez zarządzanie kluczami.

### 4. Jenkins

**Utworzenie sieci Docker dla Jenkins i uruchomienie kontenera docker:dind**

![Utworzenie sieci Docker dla jenkins i uruchomienie kontenera docker:dind](18.jpg)

**Uruchomienie kontenera Jenkinsa**

![Uruchomienie kontenera jenkinsa](19.jpg)

**Działający Jenkins**

![Działający Jenkins](20.jpg)
