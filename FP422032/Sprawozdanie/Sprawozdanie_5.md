# Sprawozdanie: Instalacja i konfiguracja środowiska CI/CD (Jenkins)

## 1. Utworzenie instancji Jenkins i przygotowanie środowiska

Pracę rozpocząłem od weryfikacji, czy kontenery z poprzedniego zadania działają poprawnie. Następnie, opierając się na oficjalnej dokumentacji, przygotowałem środowisko zagnieżdżone (Docker-in-Docker) przy pomocy pliku `docker-compose.yml` oraz własnego pliku `Dockerfile`.

**Dyskusja - Różnica między obrazami:**
Zamiast gotowego rozwiązania, przygotowałem własny obraz `blueocean` na podstawie bazowego obrazu `jenkins/jenkins`. Główna różnica polega na tym, że oficjalny obraz to surowy serwer CI/CD. W moim pliku `Dockerfile` doinstalowałem do niego klienta CLI Dockera (umożliwiającego komunikację Jenkinsa z pomocniczym kontenerem DinD) oraz pakiet wtyczek Blue Ocean, który diametralnie zmienia i unowocześnia interfejs graficzny potoków.

**Zabezpieczenie logów:**
Aby spełnić wymóg archiwizacji i zabezpieczenia logów przed wysyceniem miejsca na dysku, w pliku `docker-compose.yml` dodałem dla obu usług sekcję `logging` z parametrami `max-size: "10m"` i `max-file: "3"`.

Po uruchomieniu środowiska, wyciągnąłem wygenerowane hasło inicjalizacyjne z wnętrza kontenera i przeszedłem przez proces wstępnej konfiguracji w przeglądarce.

![Odczytanie hasła inicjalizacyjnego z kontenera](UzyskanieHasla.png)

![Ekran główny skonfigurowanego Jenkinsa](SkonfigurowanyJenkins.png)

---

## 2. Zadanie wstępne: Uruchomienie (Freestyle Projects)

W celu sprawdzenia poprawnego działania powłoki wewnątrz Jenkinsa oraz jego integracji z demonem Dockera, utworzyłem trzy projekty typu "Ogólny projekt" (Freestyle project).

### Wyświetlenie `uname`
Skonfigurowałem zadanie wykonujące proste polecenie systemowe `uname -a`. Po uruchomieniu w logach konsoli wyświetliły się informacje o jądrze systemu Linux działającym wewnątrz kontenera.

![Wynik działania polecenia uname](JenkinsUname.png)

### Zwracanie błędu dla nieparzystej godziny
Napisałem skrypt w powłoce Bash, który pobiera obecną godzinę i weryfikuje jej parzystość, zwracając błąd (`exit 1`) lub sukces (`exit 0`). 

Zauważyłem, że skrypt pobrał godzinę 6:00 (zwracając zielony sukces), podczas gdy na moim fizycznym systemie była godzina 8:00. Wynika to zapewne z faktu, że środowisko kontenera jest w pełni odizolowane i domyślnie korzysta z uniwersalnej strefy czasowej UTC, podczas gdy mój komputer znajduje się w strefie UTC+2.

![Kod skryptu sprawdzającego godzinę](SprawdzanieGodziny.png)

![Sukces wykonania skryptu - parzysta godzina w strefie UTC](JenkinsGodzina.png)

### Pobranie obrazu kontenera `ubuntu`
Aby ostatecznie potwierdzić łączność z zagnieżdżonym środowiskiem Dockera, w trzecim projekcie wywołałem komendę `docker pull ubuntu:latest`. Proces zakończył się sukcesem, co widać po pobranych warstwach obrazu.

![Wynik pobierania obrazu Ubuntu](JenkinsObraz.png)

---

## 3. Zadanie wstępne: Obiekt typu Pipeline

Ostatnim etapem zajęć było utworzenie zadania typu Pipeline, które zamiast ręcznego "wyklikiwania" kroków, korzysta z kodu zdefiniowanego w języku Groovy. 

Wpisałem treść potoku bezpośrednio do konfiguracji obiektu. Jego zadaniem było sklonowanie wskazanego repozytorium przedmiotowego (z mojej osobistej gałęzi), wejście do katalogu z plikami z poprzedniego sprawozdania i zbudowanie obrazu Dockera na podstawie mojego pliku `Dockerfile.build`.

![Zdefiniowany skrypt Pipeline](PipelineScript.png)

**Pierwsze uruchomienie Pipeline:**
Podczas pierwszego uruchomienia proces zajął dłuższą chwilę. Jenkins poprawnie sklonował pliki, a Docker musiał pobrać ciężki obraz bazowy `node` oraz wykonać komendę `npm install`, co wiązało się ze ściąganiem wszystkich zależności z sieci.

![Logi pierwszego uruchomienia Pipeline - część 1](PierwszyPipeline1.png)

![Logi pierwszego uruchomienia Pipeline - część 2](PierwszyPipeline2.png)

**Drugie uruchomienie i wnioski z działania pamięci podręcznej:**
Zgodnie z instrukcją, kliknąłem przycisk budowania po raz drugi. 

![Logi drugiego uruchomienia Pipeline z widocznym użyciem Cache](DrugiPipeline.png)

**Wniosek:** Drugie uruchomienie potoku zajęło zaledwie ułamek czasu pierwszego. W logach konsoli pojawiły się wyraźne komunikaty `CACHED`. Jest to dowód na to, że kontener uruchamiający DinD zachowuje stan na swoim podmontowanym woluminie. Dzięki temu Docker poprawnie użył swojej pamięci podręcznej (cache) dla niezmienionych warstw instrukcji z pliku `Dockerfile.build` i nie musiał ponownie pobierać paczek z internetu. To idealnie obrazuje sposób optymalizacji czasu w systemach CI/CD.

