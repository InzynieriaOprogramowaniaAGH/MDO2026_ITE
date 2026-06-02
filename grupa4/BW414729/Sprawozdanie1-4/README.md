# Sprawozdanie zbiorcze z laboratoriów 1-4

## 1. Architektura środowiska, SSH i System Kontroli Wersji (Git)

Pierwszy etap laboratoriów polegał na przygotowaniu profesjonalnego środowiska pracy opartego na maszynie wirtualnej z systemem Ubuntu Server. Dostęp do środowiska realizowany był zdalnie poprzez protokół **SSH** (Secure Shell) z wykorzystaniem środowiska Visual Studio Code oraz klienta FileZilla do transferu plików.

### Autoryzacja i praca z Gitem
Początkowo dostęp do uczelnianego repozytorium GitHub zrealizowano za pomocą tokenu **PAT (Personal Access Token)**. Jest to bezpieczniejsza alternatywa dla tradycyjnego hasła, pozwalająca na precyzyjne określenie uprawnień. Docelowo jednak wdrożono autoryzację opartą na kluczach kryptograficznych SSH (wygenerowano klucze `ecdsa` oraz `ed25519` zabezpieczone hasłem). 

**Praktyczne zastosowanie Git:**
* Utworzono odizolowaną gałąź roboczą (`BW414729`) z gałęzi grupowej (`grupa4`).
* Zrozumiano mechanizm działania **Git Hooks**. Napisano i wdrożono lokalny skrypt powłoki (`commit-msg`), który automatycznie weryfikował treść zatwierdzanych zmian (wymuszał obecność prefiksu `BW414729` w wiadomości commita). Pokazało to, jak wymuszać standardy kodowania w zespole jeszcze przed wysłaniem kodu na serwer (Push).
* Proces zakończono integracją zmian za pomocą mechanizmu Pull Request na platformie GitHub.

## 2. Podstawy Konteneryzacji (Docker)

Docker to platforma pozwalająca na pakowanie aplikacji wraz z jej wszystkimi zależnościami w ustandaryzowane, odizolowane jednostki zwane kontenerami. Rozwiązuje to klasyczny problem "u mnie działa", gwarantując powtarzalność środowiska.

**Obraz a Kontener:**
* **Obraz (Image):** To statyczny, wielowarstwowy szablon (np. `ubuntu` czy `busybox`).
* **Kontener:** To uruchomiona instancja obrazu. Przeanalizowano ten koncept, uruchamiając system Ubuntu interaktywnie (`-it`). Zauważono, że procesem o identyfikatorze `PID 1` jest powłoka `bash`, a nie pełny system inicjalizacji (jak `systemd`), co udowadnia, że kontener to de facto wyizolowany proces, a nie pełna maszyna wirtualna.

## 3. Automatyzacja budowania środowiska (Dockerfile)

Zamiast konfigurować środowisko ręcznie, proces ten zautomatyzowano za pomocą pliku **Dockerfile**. Jako projekt testowy wybrano narzędzie **`yt-dlp`**.

* Zbudowano dedykowany obraz bazujący na `python:3.10-slim`.
* Proces podzielono logicznie: wyodrębniono etap budowania (`Dockerfile.build`), który instalował kompilatory (`make`, `zip`), klonował kod i budował binarkę. Następnie utworzono obraz testowy (`Dockerfile.test`), który bazował na zbudowanym wcześniej środowisku i uruchamiał testy jednostkowe przy użyciu `pytest`. 
* **Wniosek:** Skonfigurowanie infrastruktury za pomocą kodu (Infrastructure as Code) pozwala na uzyskanie w 100% odtwarzalnego procesu budowania i testowania aplikacji, co jest fundamentem systemów CI.

## 4. Zarządzanie Stanem, Siecią i Usługami

Kontenery z definicji są ulotne (stateless). Aby zachować skompilowany plik binarny projektu `yt-dlp` po usunięciu kontenera budującego, zastosowano **Woluminy (Volumes)**.
* Stworzono woluminy `wejscie_kod` oraz `wyjscie_build`. Pozwoliło to na przekazywanie danych pomiędzy kontenerem pobierającym kod (`alpine/git`), a głównym kontenerem budującym.

### Konfiguracja Sieci (Docker Network)
Przeprowadzono analizę ruchu sieciowego między kontenerami za pomocą narzędzia `iperf3`.
* Początkowo testowano komunikację w domyślnej sieci `bridge` z użyciem adresów IP.
* Następnie utworzono **własną sieć Dockera**. Udowodniono, że w sieciach definiowanych przez użytkownika działa wbudowany serwer DNS, co pozwala na wygodną komunikację kontenerów z wykorzystaniem ich nazw, eliminując problem zmiennych adresów IP.
* Przetestowano również mechanizm **Port Forwardingu** (publikacji portów, `-p 5201:5201`), aby usługa w kontenerze była dostępna na hoście głównym.

## 5. Architektura CI/CD (Jenkins i DinD)

Zwieńczeniem cyklu zajęć było zestawienie pełnoprawnego środowiska CI/CD opartego na serwerze **Jenkins**. Ponieważ zadaniem serwera CI jest automatyzacja budowania m.in. kontenerów, sam Jenkins uruchomiony w kontenerze musiał otrzymać dostęp do demona Dockera.

Zastosowano bezpieczną architekturę **Docker-in-Docker (DinD)**:
* Uruchomiono uprzywilejowany kontener `jenkins-docker` pełniący rolę silnika, oraz współpracujący z nim kontener `jenkins-blueocean` z interfejsem użytkownika (port 8080).
* Zestawienie tego środowiska wymagało zaawansowanej orkiestracji: podpięcia wspólnej sieci, współdzielenia woluminów z certyfikatami TLS do bezpiecznej komunikacji między kontenerami oraz zapewnienia persystencji danych Jenkinsa. 
* Całość procesu ustrukturyzowano tworząc plik **`docker-compose.yml`**, co diametralnie uprościło przyszłe wdrażanie tego klastra.

*Dodatkowo przeanalizowano sens uruchamiania usługi serwera SSHD wewnątrz kontenerów. Stwierdzono, że choć daje to wygodę pracy podobną do VM, łamie to zasadę "jeden proces = jeden kontener" i zwiększa wektor ataku. Rekomendowanym podejściem do interakcji z uruchomionym kontenerem pozostała komenda `docker exec`.*

## 6. Podsumowanie

Laboratoria 1-4 pozwoliły na płynne przejście od lokalnego zarządzania kodem, przez ręczną konteneryzację procesów, aż po zautomatyzowane wdrażanie rozbudowanych architektur klastrowych. 
Rozwiązanie pojawiających się problemów – takich jak konfiguracja uprawnień Dockera (`usermod`), filtrowanie ukrytych plików na woluminach, blokady firewalla przy połączeniach zewnętrznych, czy błędy wtyczek podczas uruchamiania Jenkinsa – dostarczyło cennej, praktycznej wiedzy z zakresu administracji systemami operacyjnymi i inżynierii DevOps.