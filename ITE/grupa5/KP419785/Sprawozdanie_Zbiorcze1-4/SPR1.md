# SPRAWOZDANIE ZBIORCZE 1-4

## Środowisko uruchomieniowe
    Środowisko uruchomieniowe
    System operacyjny: Ubuntu 24.04 LTS (Maszyna wirtualna)
    Metoda dostępu: Zdalna sesja przez SSH (użytkownik: karro)
    Silnik kontenerów: Docker 27.x
    Projekt testowy: portfinder (język Go)
    Edytor kodu: Visual Studio Code połączony zdalnie (Remote - SSH)

# LABORATORIUM 1

## 1. Stworzenie maszyny wirtualnej (instalacja VirtualBox i konfiguracja)

![1](<img1/Zrzut ekranu 2026-03-03 084443.png>)
![1](<img1/Zrzut ekranu 2026-03-03 084456.png>)
![1](<img1/Zrzut ekranu 2026-03-03 084510.png>)
![1](<img1/Zrzut ekranu 2026-03-03 084618.png>)
![1](<img1/Zrzut ekranu 2026-03-03 084631.png>)
![1](<img1/Zrzut ekranu 2026-03-03 085025.png>)
![1](<img1/Zrzut ekranu 2026-03-03 085309.png>)
![1](<img1/Zrzut ekranu 2026-03-03 085618.png>)

## 2. Przygotowanie środowiska i instalacja Git
Pierwszym krokiem po przygotowaniu maszyny wirtualnej, było zestawienie interfejsu sieciowego (Mostkowana karta sieciowa / Bridged) oraz sprawdzenie przypisanego adresu IP w celu nawiązania zdalnego połączenia SSH, co pozwala uniknąć pracy bezpośrednio w konsoli KVM jako użytkownik root.

![1](<img1/Zrzut ekranu 2026-03-04 103413.png>)

Następnie nawiązano połączenie z maszyny hosta przez terminal PowerShell i zainstalowano system kontroli wersji Git:

![1](<img1/Zrzut ekranu 2026-03-04 103541.png>)
![1](<img1/Zrzut ekranu 2026-03-04 210216.png>)
![1](<img1/Zrzut ekranu 2026-03-04 211525.png>)

    ```
    ip a
    ssh karro@192.168.1.34
    sudo apt update
    sudo apt install git-all
    git --version
    ```

## 3. Klonowanie repozytorium 
![1](<img1/Zrzut ekranu 2026-03-04 211658.png>)

W ustawieniach konta wygenerowano Personal Access Token (PAT) z uprawnieniami repo oraz workflow.

![1](<img1/Zrzut ekranu 2026-03-04 211402.png>)
![1](<img1/Zrzut ekranu 2026-03-04 211431.png>)

## 4. Konfiguracja kluczy SSH i uwierzytelniania 
Kolejnym etapem było skonfigurowanie dostępu opartego o bezpieczniejsze klucze asymetryczne (SSH) oraz zabezpieczenie konta w serwisie GitHub metodą uwierzytelniania dwuskładnikowego.
Wygenerowano nową parę kluczy z wykorzystaniem nowoczesnego algorytmu ed25519.

![1](<img1/Zrzut ekranu 2026-03-04 212156.png>)
![1](<img1/Zrzut ekranu 2026-03-04 212241.png>)
![1](<img1/Zrzut ekranu 2026-03-04 212643.png>)
![1](<img1/Zrzut ekranu 2026-03-04 212653.png>)
![1](<img1/Zrzut ekranu 2026-03-04 213658.png>)

Skopiowany klucz publiczny dodano w ustawieniach GitHub. Aby zweryfikować poprawność konfiguracji, sklonowano repozytorium ponownie, tym razem wykorzystując protokół SSH:

![1](<img1/Zrzut ekranu 2026-03-04 213715.png>)

    ```
    ssh-keygen -t ed25519
    cat ~/.ssh/id_ed25519.pub
    git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
    ```

## 5. Konfiguracja wymiany plików i IDE
Skonfigurowano środowisko Visual Studio Code wykorzystując dodatek Remote SSH, co pozwala na natywną edycję plików znajdujących się na serwerze. Dodatkowo zestawiono połączenie za pomocą programu FileZilla, wykorzystując protokół SFTP, w celu szybkiej, wizualnej wymiany plików.

![1](<img1/Zrzut ekranu 2026-03-04 103835.png>)
![1](<img1/Zrzut ekranu 2026-03-04 210407.png>)
![1](<img1/Zrzut ekranu 2026-03-04 215605.png>)
![1](<img1/Zrzut ekranu 2026-03-04 214710.png>)
![1](<img1/Zrzut ekranu 2026-03-04 214842.png>)
![1](<img1/Zrzut ekranu 2026-03-04 214911.png>)

## 6. Praca z gałęziami (branches) i struktura katalogów
Zgodnie z wymaganiami, po sklonowaniu repozytorium utworzono odpowiednią strukturę pracy. W pierwszej kolejności przełączono się na gałąź main, a następnie na gałąź dedykowaną grupie (grupa5). Z gałęzi grupowej utworzono nową, prywatną gałąź o nazwie zgodnej z inicjałami i numerem indeksu (KP419785).
Następnie, we właściwym dla grupy miejscu, stworzono własny katalog.

![1](<img1/Zrzut ekranu 2026-03-04 215810.png>)
![1](<img1/Zrzut ekranu 2026-03-04 220015.png>)
![1](<img1/Zrzut ekranu 2026-03-04 220206.png>)
![1](<img1/Zrzut ekranu 2026-03-04 220218.png>)
![1](<img1/Zrzut ekranu 2026-03-04 220305.png>)

    ```
    git checkout main
    git checkout grupa5
    git checkout -b KP419785
    mkdir ITE/grupa5/KP419785
    ```
    
Aby wymusić odpowiednie formatowanie wiadomości w commitach, utworzono i skonfigurowano skrypt commit-msg wewnątrz ukrytego katalogu .git/hooks/. Skrypt ten sprawdza, czy wprowadzana wiadomość zaczyna się od ciągu znaków "KP419785".
Po nadaniu plikowi uprawnień do wykonywania przeprowadzono testy działania skryptu. Następnie podjęto próbę wykonania commita z błędną wiadomością.

![1](<img1/Zrzut ekranu 2026-03-30 194038.png>)
![1](<img1/Zrzut ekranu 2026-03-30 194131.png>)
![1](<img1/Zrzut ekranu 2026-03-30 194828.png>)

    ```
    nano .git/hooks/commit-msg
    chmod +x .git/hooks/commit-msg
    git commit -m "To jest zly commit bez prefiksu"
    ```
    
Ostatnim krokiem było zatwierdzenie poprawnych zmian oraz wysłanie ich do zdalnego repozytorium. Tym razem użyto poprawnego prefiksu, więc Git hook przepuścił commita.

![1](<img1/Zrzut ekranu 2026-03-30 194911.png>)
![1](<img1/Zrzut ekranu 2026-03-30 195659.png>)

    ```
    git add ITE/grupa5/KP419785/commit-msg
    git commit -m "KP419785 dodanie hook"
    git push --set-upstream origin KP419785
    ```

# LABORATORIUM 2

## 1. Instalacja docker w systemie Linuxowym
Proces rozpoczęto od aktualizacji indeksów pakietów systemowych. Zamiast korzystać z domyślnych, często przestarzałych pakietów dystrybucji, poprawnie dodano oficjalne repozytorium Docker apt. Wymagało to instalacji niezbędnych narzędzi, pobrania klucza GPG Dockera oraz dodania wpisu do sources.list. Następnie zainstalowano najnowszą wersję silnika docker-ce.

![Zrzut ekranu 2026-03-10 083217.png](<img2/Zrzut ekranu 2026-03-10 083217.png>)
![Zrzut ekranu 2026-03-10 083325.png](<img2/Zrzut ekranu 2026-03-10 083325.png>)
![Zrzut ekranu 2026-03-10 084056.png](<img2/Zrzut ekranu 2026-03-10 084056.png>)
![Zrzut ekranu 2026-03-10 084110.png](<img2/Zrzut ekranu 2026-03-10 084110.png>)
![Zrzut ekranu 2026-03-10 085045.png](<img2/Zrzut ekranu 2026-03-10 085045.png>)
![Zrzut ekranu 2026-03-10 092039.png](<img2/Zrzut ekranu 2026-03-10 092039.png>)

Aby umożliwić zarządzanie Dockerem bez konieczności ciągłego używania komendy sudo, dodano obecnego użytkownika do grupy docker.

![Zrzut ekranu 2026-03-10 092051.png](<img2/Zrzut ekranu 2026-03-10 092051.png>)

```
    sudo apt update
    sudo apt install ca-certificates curl gnupg -y
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo         "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker $USER
    newgrp docker
```
    
    Uwaga: Ze względu na ograniczenia przepustowości łącza, proces pobierania pakietów i konfiguracji zajął znaczną część czasu przewidzianego na zajęcia.

## 2. Zapoznanie z obrazami i sprawdzenie ich rozmiarów
Pobrano zestaw popularnych obrazów z Docker Hub, obejmujący systemy operacyjne (ubuntu, fedora), narzędzia diagnostyczne (busybox) oraz bazy danych (mariadb). 

![Zrzut ekranu 2026-03-10 093033.png](<img2/Zrzut ekranu 2026-03-10 093033.png>)
![Zrzut ekranu 2026-03-10 095804.png](<img2/Zrzut ekranu 2026-03-10 095804.png>)
![Zrzut ekranu 2026-03-10 102933.png](<img2/Zrzut ekranu 2026-03-10 102933.png>)

   ```
   - docker pull hello-world
   - docker pull busybox
   - docker pull ubuntu
   - docker pull fedora
   - docker pull mariadb
   ```

![Zrzut ekranu 2026-03-10 103112.png](<img2/Zrzut ekranu 2026-03-10 103112.png>)

   ```- docker images```

## 3. Sprawdzenie kodu wyjścia
Uruchomiono kontener hello-world w celu przetestowania poprawnej komunikacji demona z silnikiem kontenerów. Po zakończeniu działania sprawdzono kod wyjścia.

![Zrzut ekranu 2026-03-10 103501.png](<img2/Zrzut ekranu 2026-03-10 103501.png>)
![Zrzut ekranu 2026-03-10 103639.png](<img2/Zrzut ekranu 2026-03-10 103639.png>)

```
    docker run hello-world
    docker ps -a
```

## 4. Uruchomienie w trybie interaktywnym i sprawdzenie wersji 

![Zrzut ekranu 2026-03-10 103745.png](<img2/Zrzut ekranu 2026-03-10 103745.png>)
![Zrzut ekranu 2026-03-10 103803.png](<img2/Zrzut ekranu 2026-03-10 103803.png>)

```
    docker run -it busybox sh
    busybox
    exit
 ```

## 5. Sprawdzanie PID w kontenerze oraz w maszynie
Przeprowadzono porównanie identyfikatorów procesów (PID). Wewnątrz kontenera proces główny (powłoka) posiada zawsze PID 1. Z perspektywy hosta ten sam proces jest widoczny z wysokim, unikalnym numerem identyfikacyjnym, co dowodzi, że kontenery są jedynie odizolowanymi procesami w jądrze systemu Linux.

![Zrzut ekranu 2026-03-10 103858.png](<img2/Zrzut ekranu 2026-03-10 103858.png>)
![Zrzut ekranu 2026-03-10 103949.png](<img2/Zrzut ekranu 2026-03-10 103949.png>)

   PID między przypadkami różni się.
   
```
    docker run -it ubuntu bash
    ps -ef | grep "bash$"
```

## 6. Aktualizacja pakietów
Uruchomiono pełny obraz ubuntu, a następnie przeprowadzono aktualizację wewnętrznych pakietów. Operacja ta pokazuje, że kontener posiada własny, odizolowany system plików i menedżer pakietów, niezależny od maszyny hosta.

![Zrzut ekranu 2026-03-10 105244.png](<img2/Zrzut ekranu 2026-03-10 105244.png>)
![Zrzut ekranu 2026-03-10 105419.png](<img2/Zrzut ekranu 2026-03-10 105419.png>)

```
    docker run -it ubuntu bash
    apt update && apt upgrade -y
    exit
```

## 7. Dockerfile w trybie interaktywnym i weryfikacja wersji git
Zbudowanie własnego Dockerfile. Zastosowano dobre praktyki (Best Practices) optymalizacji obrazów, łącząc instalację pakietów z komendą apt clean all, która usuwa pobrane archiwa i skutecznie zmniejsza końcowy rozmiar obrazu. Skonfigurowano również dedykowany katalog roboczy (WORKDIR /app), w którym zainstalowany git pomyślnie sklonował repozytorium przedmiotowe.

![Zrzut ekranu 2026-03-30 203828.png](<img2/Zrzut ekranu 2026-03-30 203828.png>)

Proces budowania napotkał wielokrotne, przejściowe problemy z połączeniem sieciowym maszyny, jednak po ponowieniach zakończył się sukcesem.

![Zrzut ekranu 2026-03-10 112939.png](<img2/Zrzut ekranu 2026-03-10 112939.png>) 
![Zrzut ekranu 2026-03-10 115902.png](<img2/Zrzut ekranu 2026-03-10 115902.png>)
![Zrzut ekranu 2026-03-10 120102.png](<img2/Zrzut ekranu 2026-03-10 120102.png>)
![Zrzut ekranu 2026-03-10 120229.png](<img2/Zrzut ekranu 2026-03-10 120229.png>)

 ```
    docker build -t spr2_docker .
    docker run -it spr2_docker bash
    ls -la 
  ```

## 8. Czyszczenie środowiska (kontenery, obrazy)
Po zakończeniu prac usunięto wszystkie kontenery oraz obrazy, aby zwolnić zasoby dyskowe maszyny wirtualnej.

![Zrzut ekranu 2026-03-10 120326.png](<img2/Zrzut ekranu 2026-03-10 120326.png>)
![Zrzut ekranu 2026-03-10 120338.png](<img2/Zrzut ekranu 2026-03-10 120338.png>)
![Zrzut ekranu 2026-03-10 120354.png](<img2/Zrzut ekranu 2026-03-10 120354.png>)


# LABORATORIUM 3

## 1. Repozytorium z kodem oprogramowania

Na potrzeby zadania utworzono i sklonowano własne repozytorium z programem napisanym w C++. Aby spełnić wymóg otwartości (Open Source), kod został udostępniony publicznie z licencją MIT. Projekt zawiera Makefile umożliwiający uruchomienie procesu budowania (make build) oraz testów (make test). Testy są wbudowane bezpośrednio w kod aplikacji. Program uruchomiony z argumentem test wykonuje scenariusze testowe i wypisuje raport końcowy.

![3](<img3/Zrzut ekranu 2026-03-16 200251.png>)

Dodatkowo sklonowano repozytorium **portfinder** (aplikacja Go do skanowania portów) w celu przetestowania procesu na projekcie zewnętrznym:
    
```
    git clone https://github.com/doganarif/portfinder
```

## 2. Instalacja zależności oraz pobranie repozytorium

### Własne repozytorium (C++)
Zainstalowano kompilator g++ i narzędzie make na maszynie wirtualnej, a następnie sklonowano repozytorium.

![3](<img3/Zrzut ekranu 2026-03-16 210008.png>)
![3](<img3/Zrzut ekranu 2026-03-16 210241.png>)

```
    sudo apt update && sudo apt install g++ make -y
    git clone git@github.com:Karro707/devops-cpp-app-test.git
```

### Repozytorium portfinder (Go)
Zainstalowano środowisko Go i sklonowano repozytorium portfinder

![3](<img3/Zrzut ekranu 2026-03-17 090021.png>)
![3](<img3/Zrzut ekranu 2026-03-17 090036.png>)

```
    sudo apt update && sudo apt install golang-go -y
    git clone https://github.com/doganarif/portfinder
```

## 3. Uruchomienie procesu build oraz testów

### Własne repozytorium (C++)
Przeprowadzono build i uruchomiono testy na hoście.

![3](<img3/Zrzut ekranu 2026-03-16 210401.png>)

```
    make build
    make test
 ```

### Repozytorium portfinder (Go)
Próba uruchomienia make build na hoście zakończyła się błędem toolchain not available. Zainstalowana wersja Go (golang-go z repozytoriów apt) jest starsza niż wymagana przez projekt (go1.24). Problem rozwiązano wykonując build wewnątrz kontenera golang:1.24-alpine, który zawiera właściwą wersję kompilatora.

![3](<img3/Zrzut ekranu 2026-03-17 091603.png>)

## 4. Powtórzenie procesu w kontenerze (interaktywnie)

### Własne repozytorium (C++)
Uruchomiono kontener ubuntu:latest interaktywnie, zainstalowano wymagane narzędzia, sklonowano repozytorium i wykonano build oraz testy wewnątrz kontenera:

![3](<img3/Zrzut ekranu 2026-03-16 211638.png>)

![3](<img3/Zrzut ekranu 2026-03-16 215449.png>)

![3](<img3/Zrzut ekranu 2026-03-16 222915.png>)

![3](<img3/Zrzut ekranu 2026-03-16 223044.png>)

```
    docker run -it ubuntu bash
    apt update && apt install -y g++ make git
    git clone https://github.com/Karro707/devops-cpp-app-test.git
    cd devops-cpp-app-test/devops-test/devops-test
    make build
    make test
```

### Repozytorium portfinder (Go)
Uruchomiono kontener golang:1.24-alpine, zainstalowano git i make, sklonowano repozytorium i wykonano build oraz testy. Użycie obrazu golang:1.24-alpine rozwiązało problem z wersją toolchain:

![3](<img3/Zrzut ekranu 2026-03-17 094310.png>)
![3](<img3/Zrzut ekranu 2026-03-17 095553.png>)

Wynik make test zwrócił [no test files] bo projekt portfinder nie zawiera plików testowych jednostkowych w sensie frameworka Go. Komenda go test ./...działa poprawnie, jednak projekt nie dostarcza żadnych testów. Jest to cecha projektu, nie błąd konfiguracji.

```
    docker run -it golang:1.24-alpine sh
    apk add git make
    git clone https://github.com/doganarif/portfinder.git
    cd portfinder
    make build
    make test
```

## 5. Automatyzacja procesu
Celem jest przeniesienie kroków wykonanych interaktywnie do plików Dockerfile, aby proces był w pełni powtarzalny. 
Stworzono dwa oddzielne pliki:
    - `Dockerfile.build` — instaluje zależności, pobiera kod i kompiluje projekt
    - `Dockerfile.test` — bazuje na obrazie z `Dockerfile.build` i uruchamia testy (bez ponownego budowania)

Kontener testowy celowo nie wykonuje ponownie buildu, bo korzysta z artefaktów już skompilowanych w obrazie bazowym. Odpowiada to zasadzie, że build i testy to oddzielne, niezależne etapy pipeline'u CI.

### Własne repozytorium (C++)

![3](<img3/Zrzut ekranu 2026-03-16 223210.png>)
![3](<img3/Zrzut ekranu 2026-03-16 223238.png>)

Podczas pierwszej próby wystąpiły dwa błędy.

![3](<img3/Zrzut ekranu 2026-03-16 223636.png>)

![3](<img3/Zrzut ekranu 2026-03-16 231550.png>)

Podczas pierwszej próby wystąpiły dwa błędy.

![3](<img3/Zrzut ekranu 2026-03-16 223636.png>)
![3](<img3/Zrzut ekranu 2026-03-16 231550.png>)

Poprawione:

![3](<img3/Zrzut ekranu 2026-03-16 232031.png>)
![3](<img3/Zrzut ekranu 2026-03-16 232109.png>)
![3](<img3/Zrzut ekranu 2026-03-16 232137.png>)

 ```
    docker build -t app-build -f Dockerfile.build .
    docker build -t devops-test -f Dockerfile.test .
    docker run devops-test
   ```

### Repozytorium portfinder (Go)

![3](<img3/Zrzut ekranu 2026-03-17 085041.png>)
![3](<img3/Zrzut ekranu 2026-03-17 085014.png>)

Podczas prac napotkano kilka błędów.

![3](<img3/Zrzut ekranu 2026-03-17 085000.png>)
![3](<img3/Zrzut ekranu 2026-03-17 085014.png>)
![3](<img3/Zrzut ekranu 2026-03-17 085041.png>)
![3](<img3/Zrzut ekranu 2026-03-17 085740.png>)
![3](<img3/Zrzut ekranu 2026-03-17 090340.png>)
![3](<img3/Zrzut ekranu 2026-03-17 090857.png>)
![3](<img3/Zrzut ekranu 2026-03-17 091011.png>)

Poprawione:

![3](<img3/Zrzut ekranu 2026-03-17 095942.png>)
![3](<img3/Zrzut ekranu 2026-03-17 105050.png>)
![3](<img3/Zrzut ekranu 2026-03-17 105233.png>)
![3](<img3/Zrzut ekranu 2026-03-17 105311.png>)

```
    docker build -t app-build -f Dockerfile.build .
    docker build -t portfinder-test -f Dockerfile.test .
    docker run portfinder-test
```


## 6. Docker Compose

Zamiast uruchamiać kontenery ręcznie, zastosowano narzędzie Docker Compose, które automatyzuje cały proces za pomocą jednego polecenia `docker compose up --build`.

### Własne repozytorium (C++)

![3](<img3/Zrzut ekranu 2026-03-17 105514.png>)
![3](<img3/Zrzut ekranu 2026-03-16 232217.png>)
![3](<img3/Zrzut ekranu 2026-03-16 232239.png>)
![33](<img3/Zrzut ekranu 2026-03-16 232434.png>)

```
    docker compose up --build
 ```

### Repozytorium portfinder (Go)

![3](<img3/Zrzut ekranu 2026-03-17 105514.png>)
![3](<img3/Zrzut ekranu 2026-03-17 105448.png>)
![3](<img3/Zrzut ekranu 2026-03-17 105514.png>)
![3](<img3/Zrzut ekranu 2026-03-17 105535.png>)

```
    docker compose up --build
 ```

## 7. Dyskusja

### Czy program nadaje się do wdrażania jako kontener?

Własna aplikacja C++ jest prostą aplikacją konsolową. Kontenery sprawdzają się tu bardzo dobrze jako środowisko do budowania i testów, natomiast wdrażanie jej jako stale działającego kontenera produkcyjnego nie ma sensu, bo nie jest to usługa sieciowa ani demon działający w tle. Program uruchamia się, wykonuje zadanie i kończy działanie (exit code 0).
Podobnie projekt portfinder to narzędzie CLI. Uruchamiane jednorazowo, nie nadaje się do ciągłego działania jako kontener.

### Jak przygotować finalny artefakt?
Jeśli program miałby być publikowany jako kontener, wymagany jest Multi-stage build. W pierwszym etapie (builder) kompilujemy aplikację z pełnym toolchainem, a w drugim etapie kopiujemy tylko gotowy plik binarny do lekkiego obrazu bazowego (np. alpine lub scratch). Finalny obraz nie zawiera kompilatora, kodu źródłowego ani narzędzi deweloperskich — drastycznie zmniejsza to jego rozmiar i powierzchnię ataku.

Jeśli program miałby być dystrybuowany jako pakiet systemowy, najlepszym rozwiązaniem byłoby przygotowanie pakietu .deb. Można to zautomatyzować przez trzeci kontener (dedykowany etap package), który używa narzędzia fpm do wygenerowania pakietu instalacyjnego na podstawie skompilowanego pliku binarnego. Taki pakiet można opublikować w repozytorium APT lub jako release na GitHubie.

*Listing historii poleceń zawarty w pliku `history.txt` w folderze Sprawozdanie3*

# SPRAWOZDANIE 4

## 1. Zachowywanie stanu między kontenerami

Celem zadania jest zbudowanie projektu Go w izolowanym środowisku kontenerowym, w którym kod źródłowy i artefakty budowania są przechowywane niezależnie od cyklu życia kontenera.
    Zgodnie z dokumentacją Dockera, do przechowywania stanu aplikacji wybrano zarządzane woluminy (Named Volumes) zamiast montowania katalogów z hosta (Bind mounts). Woluminy są w pełni zarządzane przez silnik Dockera, niezależne od struktury plików na maszynie wirtualnej hosta i bezpieczniejsze.
    Aby spełnić wymóg zbudowania projektu w środowisku niezawierającym narzędzia Git, wykorzystano podejście z "Kontenerem Pomocniczym" (Helper Container).
    Dzięki temu:
    - kontener budujący nigdy nie ma dostępu do narzędzia Git
    - odpowiedzialności są rozdzielone zgodnie z zasadą single-responsibility
    - środowisko budowania pozostaje czyste i powtarzalne
    Alternatywne podejścia (bind mount z lokalnym katalogiem, kopiowanie do /var/lib/docker) odrzucono ze względu na silne powiązanie ze strukturą hosta lub konieczność uprawnień roota na hoście.

Utworzone woluminy vol_in (kod źródłowy) oraz vol_out (wyniki budowania):
![1](<img4/Zrzut ekranu 2026-03-23 153954.png>)
Sklonowanie repozytorium na wolumin vol_in przy użyciu kontenera pomocniczego alpine/git (pozwala to na pełną izolacje i czystość środowiska budującego)
![2](<img4/Zrzut ekranu 2026-03-23 155553.png>)
Uruchomienie buildu (bez git)
![3](<img4/Zrzut ekranu 2026-03-23 155756.png>)
![4](<img4/Zrzut ekranu 2026-03-23 155846.png>)
![5](<img4/Zrzut ekranu 2026-03-23 160540.png>)
![6](<img4/Zrzut ekranu 2026-03-23 160607.png>)
Po usunięciu kontenera budującego, dane na woluminie vol_out są nadal dostępne.
![7](<img4/Zrzut ekranu 2026-03-23 160650.png>)
Powtórzenie operacji (Git wewnątrz kontenera)
![8](<img4/Zrzut ekranu 2026-03-23 190707.png>)
![9](<img4/Zrzut ekranu 2026-03-23 190729.png>)

```
    docker volume create vol_in
    docker volume create vol_out 
    docker run --rm -v vol_in:/workspace alpine/git clone https://github.com/doganarif/portfinder.git /workspace/projekt
    docker run -it --rm -v vol_in:/src -v vol_out:/build golang:1.24-alpine sh
    apk add make
    cd /src/projekt
    make build
    cp bin/pf /build/
    docker run --rm -v vol_out:/check alpine ls -la /check
    apk add make git
    git clone https://github.com/doganarif/portfinder.git projekt2
    cd projekt2
    make build
    cp bin/pf /build/
    exit
 ```

Powyższe kroki z woluminami można zautomatyzować podczas budowania obrazu: zastosowanie RUN --mount=type=bind w pliku Dockerfile pozwala na zamontowanie kodu źródłowego tylko na czas budowania, bez kopiowania go do warstw obrazu. Jest to rozwiązanie optymalne, ponieważ finalny obraz zawiera tylko plik binarny, co drastycznie zmniejsza jego rozmiar i poprawia bezpieczeństwo. 
    Rozwiązanie to wymaga włączonego silnika BuildKit, co jest obecnie standardem w nowoczesnych wersjach Dockera.

## 2. Eksponowanie portu i łączność między kontenerami
Celem zadania jest zbadanie komunikacji sieciowej między kontenerami przy użyciu narzędzia `iperf3`.
Uruchomiono serwer iperf3, sprawdzono jego IP (172.17.0.3) i połączono się z drugiego kontenera.

![10](<img4/Zrzut ekranu 2026-03-23 191055.png>)

Utworzono sieć my-net. Uruchomiono kontenery z flagą --network. Dzięki temu możliwa była komunikacja po nazwie kontenera iperf-server.

![11](<img4/Zrzut ekranu 2026-03-23 191113.png>)
![12](<img4/Zrzut ekranu 2026-03-23 191538.png>)
![13](<img4/Zrzut ekranu 2026-03-23 191552.png>)
![14](<img4/Zrzut ekranu 2026-03-23 191954.png>)
![15](<img4/Zrzut ekranu 2026-03-23 192008.png>)
![16](<img4/Zrzut ekranu 2026-03-23 192209.png>)
![17](<img4/Zrzut ekranu 2026-03-23 192237.png>)

Wyeksponowano port 5201 na hosta. Test wykonano komendą iperf3 -c 127.0.0.1.

![18](<img4/Zrzut ekranu 2026-03-23 192252.png>)

```
    docker run -it --rm --name iperf-server alpine sh -c "apk add iperf3 && iperf3 -s"
    docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
    docker run -it --rm alpine sh -c "apk add iperf3 && iperf3 -c 172.17.0.3"
    docker network create my-net
    docker run -it --rm --name iperf-server --network my-net -p 5201:5201 alpine sh -c "apk add iperf3 && iperf3 -s"
    docker run -it --rm --network my-net alpine sh -c "apk add iperf3 && iperf3 -c iperf-server"
 ```

Aby uniezależnić komunikację od adresów IP, utworzono dedykowaną sieć my-net. W odróżnieniu od domyślnej sieci bridge, sieci użytkownika w Dockerze mają wbudowany serwer DNS, który umożliwia odwoływanie się do kontenerów po nazwie. Jest to rozwiązanie zalecane w produkcji, ponieważ jest odporne na zmiany adresów IP.

Wyniki testu iperf3 między kontenerami w sieci my-net pokazały przepustowość na poziomie ok. 6.65 Gbit/s (w domyślnej sieci było to ok. 6.50 Gbit/s). Tak wysoki wynik wynika z tego, że komunikacja odbywa się wewnątrz jednego hosta przez wirtualny interfejs sieciowy (bez fizycznej karty sieciowej). Jest to typowy wynik dla kontenerów na tej samej maszynie.
Wyeksponowano port 5201 na hosta (-p 5201:5201) i przetestowano połączenie z poziomu hosta komendą iperf3 -c 127.0.0.1. Przepustowość wyniosła ok. 4.18 Gbit/s. Była ona zauważalnie niższa w porównaniu z komunikacją między samymi kontenerami, co w praktyce potwierdza i doskonale obrazuje narzut wydajnościowy (overhead) wprowadzany przez warstwę NAT i mechanizm mapowania portów w Dockerze.

## 3. Usługi SSH w kontenerze
Zestawiono usługę SSHD w kontenerze bazującym na systemie Ubuntu i udostępniono ją na porcie 2222.
![19](<img4/Zrzut ekranu 2026-03-23 194728.png>)
![20](<img4/Zrzut ekranu 2026-03-23 200726.png>)
Pomyślnie połączono się z usługą korzystając z hosta:
![21](<img4/Zrzut ekranu 2026-03-23 200735.png>)

```
    docker run -it --rm --name ssh-server -p 2222:22 ubuntu:24.04 bash
    apt update && apt install -y openssh-server
    echo 'root:testpass' | chpasswd
    /usr/sbin/sshd
    ssh root@127.0.0.1 -p 2222
```

Z punktu widzenia dobrych praktyk konteneryzacji, uruchamianie demona SSH wewnątrz kontenera jest uznawane za anty-wzorzec. Łamie zasadę jednej odpowiedzialności kontenera, zwiększa wagę obrazu oraz otwiera nową powierzchnię ataku dla potencjalnych intruzów. Do debugowania służy natywna komenda docker exec.
    Zaletą i przypadkiem użycia dla SSH w kontenerze może być natomiast stworzenie tzw. "Bastion Host" (bezpiecznego punktu wejściowego do podsieci), środowisk typu Honeypot do łapania ataków, lub utrzymywanie kompatybilności ze starymi agentami systemów CI/CD.
    Uzasadnione przypadki użycia SSH w kontenerze to:
    - Bastion Host - bezpieczny, jednopunktowy punkt wejściowy do izolowanej podsieci kontenerów
    - Honeypot - środowisko pułapkowe do wykrywania i analizowania ataków
    - Legacy CI/CD - kompatybilność ze starymi agentami systemów CI/CD, które komunikują się wyłącznie przez SSH

## 4. Instancja Jenkins
Zestawiono Jenkinsa z pomocnikiem Docker-in-Docker (DIND), co pozwala agentom Jenkinsa na swobodne budowanie własnych kontenerów.
Uruchomiono kontener docker:dind

![22](<img4/Zrzut ekranu 2026-03-23 203609.png>)

Zbudowano własny obraz Jenkinsa (Dockerfile.jenkins) z zainstalowanym klientem Dockera.

![23](<img4/Zrzut ekranu 2026-03-23 203738.png>)
![24](<img4/Zrzut ekranu 2026-03-23 215048.png>)
![25](<img4/Zrzut ekranu 2026-03-23 215104.png>)
![26](<img4/Zrzut ekranu 2026-03-23 215148.png>)
![27](<img4/Zrzut ekranu 2026-03-23 215219.png>)
![28](<img4/Zrzut ekranu 2026-03-23 215243.png>)

Odczytano hasło inicjalizacyjne z logów i pomyślnie zalogowano się do panelu.

![29](<img4/Zrzut ekranu 2026-03-23 220002.png>)
![30](<img4/Zrzut ekranu 2026-03-23 220039.png>)
![31](<img4/Zrzut ekranu 2026-03-23 221103.png>)
![32](<img4/Zrzut ekranu 2026-03-23 221124.png>)
![33](<img4/Zrzut ekranu 2026-03-24 091411.png>)

Plik `Dockerfile.jenkins` rozszerza oficjalny obraz Jenkinsa o klienta Docker.

```
    docker network create jenkins
    docker run --name jenkins-docker --rm --detach --privileged --network jenkins --network-alias docker --env DOCKER_TLS_CERTDIR=/certs --volume jenkins-docker-certs:/certs/client --volume jenkins-data:/var/jenkins_home --publish 2376:2376 docker:dind --storage-driver overlay2
    docker build -t myjenkins-blueocean:2.492.2-1 --file Dockerfile.jenkins .
    docker run --name jenkins-blueocean --restart=on-failure --detach --network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --publish 8080:8080 --publish 50000:50000 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro myjenkins-blueocean:2.492.2-1
    docker ps
```

Główne zapytania do LLM: 
"Jak przygotować woluminy i sklonować repozytorium bez Gita w kontenerze budującym?"
"Wyjaśnij różnice w przepustowości iperf3 między kontenerami w tej samej sieci Dockera a komunikacją na linii host kontener."
"Jak poprawnie zestawić usługę SSH w kontenerze z Ubuntu i jakie są wady oraz zalety takiego podejścia?"
Weryfikacja nastąpiła przez uruchamianie i testowanie na maszynie, analizie logów, porównywanie z oficjalną dokumentacją. 


*Listing historii poleceń zawarty w pliku `history.txt` w folderze Sprawozdanie4*

# Podsumowanie:

### Git
Git to system kontroli wersji umożliwiający śledzenie zmian w plikach i współpracę nad kodem. Repozytorium tworzy się przez git init lub klonuje przez git clone. Zmiany zapisuje się sekwencją add -> commit  ->  push, a pobiera przez git pull. Gałęzie (branch) pozwalają pracować nad różnymi funkcjonalnościami równolegle i łączyć je przez merge. Git hooki to skrypty uruchamiane automatycznie przy operacjach git (np. przed commitem), służące do egzekwowania konwencji.

### SSH
SSH (Secure Shell) to protokół zdalnego dostępu do terminala. Uwierzytelnianie odbywa się hasłem lub parą kluczy (publiczny/prywatny). Klucz publiczny umieszcza się na serwerze, prywatny pozostaje lokalnie. Weryfikacja fingerprinta przy pierwszym połączeniu chroni przed atakiem man-in-the-middle.

### Docker
Docker to narzędzie do uruchamiania aplikacji w izolowanych kontenerach. Obraz to przepis na środowisko (definiowany przez Dockerfile), a kontener to jego uruchomiona instancja. Woluminy umożliwiają trwałe przechowywanie danych niezależnie od cyklu życia kontenera. Sieci pozwalają kontenerom komunikować się ze sobą. Dedykowane sieci użytkownika oferują dodatkowo rozwiązywanie nazw DNS między kontenerami.
