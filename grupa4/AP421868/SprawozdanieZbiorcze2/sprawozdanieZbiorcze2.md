# Sprawozdanie z laboratoriów 5 - 7

## 1. Wstęp

Celem zajęć było zbudowanie kompletnego środowiska CI/CD.  
W praktyce przechodziliśmy krok po kroku od ręcznego uruchamiania kontenerów Dockera, przez automatyzację budowania obrazów, aż do stworzenia w pełni działającego pipeline’u w Jenkinsie, połączonego z repozytorium kodu i rejestrem obrazów.

Cały proces pozwolił lepiej zrozumieć, jak wygląda automatyzacja pracy nad projektem od momentu wprowadzenia zmian w kodzie aż do publikacji gotowego artefaktu.

## 2. Architektura środowiska i podstawy automatyzacji

Na początku należało przygotować stabilne środowisko, na którym można było budować kolejne elementy automatyzacji.  
Wykorzystano model **Docker-in-Docker (DinD)**, w którym główny kontener z Jenkinsen współpracował z osobnym kontenerem odpowiedzialnym za obsługę Dockera.

Podczas konfiguracji skupiono się na kilku ważnych elementach:

### Personalizacja Jenkinsa
Zbudowano własny obraz Jenkinsa na podstawie pliku `Dockerfile-jenkins`.  
Został on rozszerzony o **Blue Ocean**, czyli wygodniejszy interfejs do podglądu i zarządzania pipeline’ami.

### Trwałość danych
Aby nie tracić konfiguracji po restarcie kontenera, użyto woluminów Dockera, np.  
`-v jenkins-data:/var/jenkins_home`.

Dzięki temu zachowywane były:
- ustawienia Jenkinsa,
- historia budowań,
- logi wykonywanych zadań.

### Testy podstawowe
Na początku utworzono kilka prostych projektów testowych, które miały sprawdzić, czy automatyzacja działa poprawnie.  
Były to m.in.:
- wykonanie prostej komendy systemowej `uname -a`,
- testy z użyciem instrukcji warunkowych,
- pobieranie zewnętrznych obrazów, np. `docker pull ubuntu`.

## 3. Izolacja etapów i konteneryzacja procesu build & test

Do testowania całego procesu CI/CD wybrano bibliotekę **clibs/list** napisaną w języku C.  
Taki projekt wymagał środowiska z odpowiednimi narzędziami, przede wszystkim **GCC** i **Make**.

W tej części ważne były następujące rzeczy:

### Podział procesu na etapy
Proces budowania i testowania został rozdzielony na osobne pliki:
- `Dockerfile.build` - odpowiedzialny za kompilację w obrazie `gcc:latest`,
- `Dockerfile.test` - odpowiedzialny za uruchamianie testów jednostkowych na bazie wcześniej zbudowanego obrazu.

Takie podejście było wygodniejsze i bardziej czytelne, bo każdy etap miał jasno określone zadanie.

### Orkiestracja przez Docker Compose
Zanim cały proces trafił do Jenkinsa, kontenery zostały ujęte w plik `docker-compose.yml`.  
Pozwoliło to uruchamiać cały stos jednym poleceniem i znacznie ułatwiło testowanie środowiska.

## 4. Pełna integracja CI/CD z SCM i rejestrem obrazów

W ostatnim etapie, realizowanym w laboratorium 7, definicję środowiska przeniesiono do kodu.  
Cały proces został połączony z systemem kontroli wersji Git.

### Jak wyglądał pipeline
Najważniejsze elementy tego etapu były następujące:

#### Integracja z repozytorium
Zamiast ręcznie wklejać skrypty do Jenkinsa, definicja pipeline’u została zapisana w pliku `Jenkinsfile` bezpośrednio w repozytorium.  
Dzięki temu cała logika budowania była wersjonowana razem z kodem.

Każde uruchomienie pipeline’u zaczynało się od czyszczenia katalogu roboczego, co gwarantowało start w świeżym środowisku.

#### Testy i obraz do sprawdzenia artefaktu
Po przejściu testów jednostkowych tworzony był lekki obraz oparty na **Alpine Linux**.  
Służył on do wykonania testu dymnego, czyli szybkiego sprawdzenia, czy plik `libclibs_list.a` został poprawnie wygenerowany.

#### Publikacja i archiwizacja
Gotowy obraz był:
- tagowany,
- wysyłany do **Docker Hub**,
- archiwizowany przez Jenkinsa wraz z fingerprintami, które pozwalały powiązać artefakty z konkretnym commitem w Git.

### Definicja zakończenia sukcesem
Za pełny sukces uznano sytuację, w której obraz pobrany z rejestru działał poprawnie na lokalnej maszynie, niezależnie od środowiska, w którym został zbudowany.

## 5. Wnioski

Laboratoria 5-7 pokazały, jak wygląda przejście od ręcznego uruchamiania usług do pełnej automatyzacji procesu.  
Najważniejszy efekt pracy polegał na tym, że zarówno środowisko budowania, jak i logika pipeline’u zostały zapisane w repozytorium, dzięki czemu projekt stał się łatwiejszy do odtwarzania, rozwijania i przenoszenia między maszynami.

Dodatkową zaletą okazało się wykorzystanie cache’owania warstw Dockera, które znacząco przyspieszało kolejne uruchomienia pipeline’u.

Najważniejszy wniosek jest taki, że trzymanie konfiguracji w plikach `Dockerfile` i `Jenkinsfile` daje większą kontrolę nad projektem, ułatwia pracę zespołową i pozwala uniknąć zależności od jednej konkretnej maszyny budującej.