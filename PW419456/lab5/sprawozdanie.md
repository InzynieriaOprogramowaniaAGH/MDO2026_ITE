# Sprawozdanie - lab 5

**Piotr Walczak**
**419456**

## 1. Przygotowanie

- Utworzono własny plik `Dockerfile.jenkins` bazujący na oficjalnym obrazie Jenkinsa oraz plik `docker-compose.yml` spinający to środowisko z kontenerem zagnieżdżonym Dockera (DinD). 
- Uruchomiono klaster poleceniem `docker compose up -d --build`.
- Wyciągnięto hasło początkowe administratora, zalogowano się do panelu i skonfigurowano Jenkinsa.

![](sprawozdanie-ss/devops_lab5_1.png)
![](sprawozdanie-ss/devops_lab5_2.png)
![](sprawozdanie-ss/devops_lab5_3.png)

> **Czym się różni przygotowany obraz od standardowego obrazu Jenkinsa?**
> Standardowy obraz `jenkins/jenkins` posiada jedynie klasyczny interfejs graficzny. W przygotowanym obrazie doinstalowano ręcznie wtyczkę **Blue Ocean** (nowoczesny, wizualny interfejs ułatwiający tworzenie i śledzenie etapów CI/CD) oraz klienta `docker-ce-cli`. Dzięki temu Jenkins potrafi wysyłać polecenia do zagnieżdżonego demona Dockera działającego w równoległym kontenerze (DinD).

> **Archiwizacja i zabezpieczenie logów:**
> Bezpieczeństwo danych (logów budowania, historii zadań, konfiguracji) zrealizowano za pomocą woluminów platformy Docker. W pliku `docker-compose.yml` zmapowano nazwany wolumin `jenkins-data` do ścieżki `/var/jenkins_home` wewnątrz kontenera. Dzięki temu po ewentualnym usunięciu lub awarii kontenera, Jenkins po ponownym uruchomieniu odzyska pełen stan środowiska.

## 2. Zadanie wstępne: uruchomienie

Przygotowano trzy projekty typu *Freestyle project* konfigurujące proste komendy powłoki.

- **Projekt 1: Wyświetlanie `uname`**
  Utworzono projekt wykonujący polecenie `uname -a`. Po uruchomieniu w logach konsoli zaobserwowano poprawne wypisanie informacji o jądrze systemu linux, na którym działa kontener Jenkinsa.

![](sprawozdanie-ss/devops_lab5_4.png)

- **Projekt 2: Błąd przy nieparzystej godzinie**
  Napisano skrypt bashowy pobierający aktualną godzinę i sprawdzający resztę z dzielenia przez 2.

![](sprawozdanie-ss/devops_lab5_5.png)
![](sprawozdanie-ss/devops_lab5_6.png)

- **Projekt 3: Pobranie kontenera `ubuntu`**
  Utworzono projekt wykonujący komendę `docker pull ubuntu`. 

![](sprawozdanie-ss/devops_lab5_7.png)
![](sprawozdanie-ss/devops_lab5_8.png)

- Podsumowanie statusu zadań w głównym panelu Jenkinsa:

![](sprawozdanie-ss/devops_lab5_9.png)

## 3. Zadanie wstępne: obiekt typu pipeline

- Utworzono nowy obiekt typu **Pipeline**. Wprowadzono deklaratywny skrypt bezpośrednio do definicji zadania.
- W skrypcie wykorzystano kroki izolujące etapy: `Checkout` (klonowanie repozytorium i przejście na gałąź `PW419456`) oraz `Build Docker Image` (budowanie obrazu bazowego z wykorzystaniem `Dockerfile.build` z katalogu `PW419456/lab3`).

![](sprawozdanie-ss/devops_lab5_10.png)

- Uruchomiono Pipeline. Pomyślnie zaciągnięto kod z repozytorium zdalnego i skompilowano obraz kontenera.

![](sprawozdanie-ss/devops_lab5_11.png)

- **Drugie uruchomienie (widok Blue Ocean / Stage view):** Zgodnie z poleceniem, uruchomiono skonfigurowany pipeline po raz drugi. 

![](sprawozdanie-ss/devops_lab5_12.png)