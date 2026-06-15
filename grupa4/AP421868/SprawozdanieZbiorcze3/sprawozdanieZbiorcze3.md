# Zbiorcze Sprawozdanie Laboratoria 8-12
Aleksandra Pac 421868
## Cel
Celem tej części zajęć było płynne przejście od automatyzacji konfiguracji pojedynczych maszyn wirtualnych do zarządzania rozbudowanym środowiskiem kontenerowym w chmurze.
W praktyce przechodziliśmy krok po kroku przez narzędzia ułatwiające pracę administratora i DevOpsa: od Ansible (zarządzanie stanem maszyn), przez Kickstart (nienadzorowane instalacje systemów), aż po Kubernetes (orkiestracja) i chmurę publiczną Azure.
## 1. Automatyzacja infrastruktury za pomocą Ansible
Na początku przygotowano stabilne środowisko wirtualne oparte na systemie Ubuntu 24.04 LTS. Zarządzanie konfiguracją zautomatyzowano przy pomocy Ansible, opierając komunikację między maszyną zarządzającą (ansible-master) a docelową (ansible-target) na logowaniu SSH bez użycia hasła (wymiana kluczy).

Podczas konfiguracji skupiono się na następujących aspektach:

### Inwentaryzacja i Playbooki
W celu umożliwienia stabilnej komunikacji po nazwach sieciowych, w pierwszej kolejności zmodyfikowano plik /etc/hosts na maszynie głównej, przypisując adresy IP maszyn wirtualnych do ich nazw tekstowych.

Następnie infrastrukturę podzielono logicznie w pliku `inventory.ini` na grupy `Orchestrators` oraz `Endpoints`. Stworzono playbook, który automatyzował rutynowe zadania administracyjne, takie jak aktualizacja pakietów, dystrybucja plików oraz restart usług systemowych (sshd, rngd).
Wdrożenie uruchamiano poleceniem:
`ansible-playbook -i inventory.ini zadania.yml --ask-become-pass`

### Idempotentność i odporność na awarie
Ansible świetnie sprawdziło się pod kątem utrzymania pożądanego stanu (idempotentność) - przy ponownym uruchomieniu skryptu narzędzie pomijało wykonane już zadania. Przetestowano również zachowanie w sytuacjach awaryjnych (wyłączone SSH, odłączona karta sieciowa). Ansible bezpiecznie przerywało pracę na niedostępnym hoście, bezproblemowo kontynuując zadania na pozostałych, dostępnych węzłach.

### Wdrażanie przez Ansible Roles
Ostatnim krokiem było utworzenie ustandaryzowanej roli poleceniem `ansible-galaxy role init deploy_app`. Jej zadaniem był sanity check (sprawdzenie miejsca na dysku), instalacja Dockera oraz pobranie i uruchomienie zdefiniowanego obrazu z Docker Hub (`al5ksandra/list:latest`).

## 2. Nienadzorowane wdrożenia z użyciem Kickstart
Kolejnym etapem było przygotowanie w pełni zautomatyzowanej, bezobsługowej instalacji systemu Fedora 44. Logikę całego procesu zamknięto w pliku odpowiedzi `ks.cfg`.

### Konfiguracja i skrypty poinstalacyjne
W pliku określono parametry takie jak partycjonowanie dysku (LVM), nazwa hosta (`fedora-autodeploy`) oraz pakiety niezbędne do obsługi kontenerów (np. silnik Dockera).
Najważniejszym elementem była sekcja `%post`, w której utworzono usługę systemd (`myapp-deploy.service`). Dzięki niej, natychmiast po pierwszym uruchomieniu systemu, maszyna automatycznie pobierała i uruchamiała kontener z aplikacją.

### Dystrybucja pliku instalacyjnego i weryfikacja
Aby instalator Anaconda mógł pobrać konfigurację w sieci lokalnej, na maszynie gospodarza uruchomiono lekki serwer HTTP wbudowany w Pythona:
`python -m http.server 8000 --bind 0.0.0.0`

Podczas uruchamiania nowej maszyny wirtualnej, w menu rozruchowym GRUB podano lokalizację pliku ks.cfg za pomocą dyrektywy wejściowej. Po automatycznej instalacji i restarcie systemu, pomyślnie zweryfikowano działanie środowiska wywołując polecenia `systemctl status myapp-deploy.service` oraz `docker ps -a`, co ostatecznie potwierdziło obecność i poprawne działanie zdefiniowanego artefaktu.

## 3. Zarządzanie klastrem Kubernetes
Głównym punktem projektu było przeniesienie aplikacji do zarządzalnego środowiska Kubernetes (uruchomionego lokalnie przez Minikube na silniku Docker).

### Konteneryzacja i bezpieczeństwo lokalnego środowiska
Podczas konfiguracji klastra Minikube zadbano o to, żeby działał stabilnie nawet na ograniczonych zasobach. Wystarczyły mu co najmniej 2 procesory vCPU i 2 GB pamięci RAM. Sprawdzono też bezpieczeństwo całego środowiska - najważniejsze elementy klastra, w tym Control Plane i API Server, uruchamiane są w odizolowanym kontenerze systemowym, a cała wewnętrzna komunikacja jest chroniona certyfikatami TLS opartymi na standardzie X.509.
Dodatkowo, dla ułatwienia monitorowania środowiska, pomyślnie uruchomiono i zweryfikowano łączność z graficznym panelem zarządzania - Kubernetes Dashboard.

Ponieważ biblioteka z poprzednich zajęć (C) nie posiadała interfejsu sieciowego, obudowano ją w prostą aplikację webową opartą na Nginx. Serwer w kontenerze działał w trybie pierwszoplanowym (daemon off;), utrzymując proces PID 1 przy życiu.
Aby uniknąć każdorazowego pobierania obrazów z sieci, ładowano je bezpośrednio do klastra poleceniem:
`minikube image load moja-aplikacja:v1`

### Manualne uruchomienie aplikacji
Przed wdrożeniem deklaratywnym przetestowano manualne uruchomienie aplikacji jako pojedynczego wdrożenia jednopodowego w klastrze za pomocą polecenia `kubectl run`. W celu weryfikacji działania usługi, wykonano przekierowanie portu z kontenera na port lokalny hosta (`kubectl port-forward ... 8081:80`). Testowe zapytanie curl potwierdziło prawidłową odpowiedź HTTP bezpośrednio z działającego Poda.
### Wdrażanie deklaratywne i Rollout
Zarządzanie aplikacją przeniesiono do manifestów YAML. Aplikację uruchomiono w 4 replikach, a obiekt Service zapewniał jeden stały punkt dostępowy. Wdrożenie aplikowano poleceniem:
`kubectl apply -f deployment.yaml`

Przetestowano możliwości elastycznego i dynamicznego skalowania aplikacji poprzez modyfikację parametru replicas w manifeście YAML. Zweryfikowano działanie klastra zmieniając liczbę instancji z 4 na 8, następnie zmniejszając do 1, redukując do 0, by na koniec skutecznie przywrócić stabilny stan 4 replik.

Przetestowano również zarządzanie awariami. Wysłano do klastra uszkodzony obraz (kończący się błędem /bin/false), co poskutkowało statusem *CrashLoopBackOff*. Środowisko naprawiono wykorzystując wbudowany mechanizm historii wdrożeń - wykonano szybki rollback do stabilnej wersji za pomocą:
`kubectl rollout undo deployment/moja-aplikacja-deployment`
Dodatkowo proces weryfikacji zdrowia aplikacji zabezpieczono skryptem powłoki z sztywnym limitem czasu (60 sekund), który automatycznie przerywał nieudane aktualizacje.

### Zaawansowane strategie wdrożeniowe
Porównano w praktyce różne podejścia do aktualizacji aplikacji:

*Recreate*: Stara wersja była w całości wygaszana przed powołaniem nowej. Skutkowało to najdłuższą przerwą w dostępie do usługi.

*Rolling Update*: Domyślna, płynna wymiana podów (jeden po drugim). Dzięki sterowaniu parametrami maxUnavailable oraz maxSurge zapewniono ciągłość działania bez jakichkolwiek przerw.

*Canary Deployment*: Wdrożenie "kanarkowe", w którym obok 4 podów głównej wersji uruchomiono 1 pod nowej, testowej wersji. Dzięki współdzieleniu etykiety (app: moja-aplikacja) usługa sieciowa kierowała część ruchu do nowej instancji w celach testowych.

# 4. Przeniesienie artefaktu do chmury Azure
Ostatnim testem była migracja wypracowanego artefaktu (obraz aplikacyjny zaktualizowany do wersji v3) na publiczną platformę chmurową Microsoft Azure.

Za pomocą narzędzia Azure Cloud Shell wydzielono nową grupę zasobów w regionie swedencentral:
`az group create --name rg-aleksandra-421868-v2 --location swedencentral`

Instancję kontenera uruchomiono bezpośrednio z wiersza poleceń, przydzielając mu publiczny adres IP i unikalną etykietę DNS. Weryfikacja działania przebiegła pomyślnie (status Running oraz prawidłowa odpowiedź HTTP z publicznego adresu URL).
Po zakończeniu prac i pobraniu logów, środowisko posprzątano całkowicie usuwając grupę zasobów poleceniem:
`az group delete --name rg-aleksandra-421868 --yes`
# Wnioski
Najważniejszym wnioskiem jest to, że zastąpienie ręcznych konfiguracji podejściem deklaratywnym (Ansible YAML, Kickstart, Kubernetes Manifests) pozwala na szybkie, przewidywalne i bezpieczne odtwarzanie środowisk.

Narzędzia takie jak Ansible zdejmują z administratora ciężar pamiętania o stanie końcowym maszyn.

Użycie Kubernetes uświadamia, jak proste może być skalowanie usług (np. zmiana liczby replik z 1 do 8 w kilka sekund) i jak łatwo odratować środowisko po nieudanej aktualizacji (Rollout Undo).

Ostatni etap z Azure udowodnił, że poprawnie skonteneryzowana aplikacja jest całkowicie niezależna od infrastruktury fizycznej i można ją w kilka minut przenieść z lokalnego miniklastra na globalną chmurę publiczną.