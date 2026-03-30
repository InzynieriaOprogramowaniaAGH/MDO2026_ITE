# Sprawozdanie łączone (1-4) - Franciszek Tokarek (FT422048)

## Cel sprawozdania

Sprawozdanie to stanowi zbiorcze podsumowanie czterech wcześniejszych sprawozdań.  
Celem było przedstawienie pełnego przebiegu prac: od konfiguracji środowiska i organizacji pracy w repozytorium, przez podstawy konteneryzacji, po automatyzację build/test i elementy związane z CI.

Zakres obejmuje:

- konfigurację dostępu i pracy na repozytorium (Git/SSH)
- podstawowe operacje na Dockerze
- automatyzację build/test na Redisie
- zagadnienia dodatkowe: woluminy, sieć, SSH w kontenerze i Jenkins DIND

## Środowisko pracy

Prace realizowano na systemie macOS oraz na maszynie wirtualnej z dostępem przez SSH.  
Wykorzystywane narzędzia: git, docker, docker compose, iperf3, Jenkins.

## Sprawozdanie 1 - Git, SSH i organizacja pracy

Pierwszy etap dotyczył przygotowania bezpiecznego i powtarzalnego środowiska pracy.

Wykonane działania:

- wygenerowano klucze SSH (ED25519)
- skonfigurowano dostęp do GitHub po SSH i zweryfikowano logowanie
- przygotowano połączenie z maszyną wirtualną przez SSH
- dodano hook `commit-msg`, który wymusza prefiks `FT422048` w commitach

Najważniejsze obserwacje:

- hook faktycznie blokował złe komunikaty commitów
- po poprawnym prefiksie commit przechodził normalnie
- etap zakończono przez PR do gałęzi grupowej

Podsumowanie: pierwszy etap uporządkował workflow, co ułatwiło realizację kolejnych zadań.

## Sprawozdanie 2 - Docker (podstawy)

Drugi etap obejmował praktyczne wprowadzenie do pracy z Dockerem.

Wykonane działania:

- zainstalowano Dockera i zweryfikowano poprawność działania
- uruchomiono różne obrazy (m.in. Ubuntu, Fedora, Alpine, MariaDB, BusyBox i obrazy .NET)
- porównano rozmiary obrazów i zachowanie kontenerów po uruchomieniu
- sprawdzono izolację procesów przez porównanie PID wewnątrz kontenera i na hoście
- przygotowano własny Dockerfile (Ubuntu + Git + klon repo do /app), zbudowano obraz i uruchomiono kontener

Najważniejsze obserwacje:

- różnice rozmiarów obrazów są bardzo duże (od lekkich po naprawdę ciężkie),
- kontenery uzyskiwały różne statusy wyjścia zależnie od konfiguracji (np. MariaDB bez hasła),
- izolacja PID działa tak, jak powinna.

Podsumowanie: etap dał solidne podstawy do dalszej, bardziej zaawansowanej pracy z kontenerami.

## Sprawozdanie 3 - Redis i automatyzacja build/test

Trzeci etap koncentrował się na powtarzalności procesu build/test.

Wykonane działania:

- wybrano Redis jako projekt testowy (kompilacja przez make, rozbudowany zestaw testów)
- wykonano kompilację i testy lokalnie na hoście
- powtórzono te same działania w czystym kontenerze Ubuntu po doinstalowaniu zależności
- rozdzielono proces na dwa pliki:
  - `Dockerfile.build` - instalacja i kompilacja
  - `Dockerfile.test` - uruchamianie testów
- zautomatyzowano uruchamianie przez `docker-compose.yml`

Najważniejsze obserwacje:

- lokalnie testy kończyły się błędami
- w kontenerze wynik był stabilniejszy i bardziej przewidywalny

Podsumowanie: etap potwierdził praktyczną wartość odseparowanego środowiska dla build/test.

## Sprawozdanie 4 - woluminy, sieć, SSHD, Jenkins

W czwartym etapie skupiono się na zagadnieniach operacyjnych i podstawach CI.

Wykonane działania:

- użyto woluminów wejściowych i wyjściowych do rozdzielenia kodu i artefaktów
- dostosowano przepływ tak, aby wynik builda był dostępny poza kontenerem po jego zakończeniu
- wykonano test połączenia kontener-kontener przez iperf3 w dedykowanej sieci
- uruchomiono SSHD w kontenerze i zweryfikowano połączenie
- uruchomiono Jenkins w modelu Docker-in-Docker i przeprowadzono inicjalizację

Najważniejsze obserwacje:

- woluminy rozwiązują problem trwałości danych między uruchomieniami
- sieć Dockera ułatwia komunikację po nazwach usług/kontenerów
- Jenkins DIND pozwala zbliżyć się do realnego scenariusza CI

Podsumowanie: czwarty etap domknął wszystkie, łącząc build, test, sieć i podstawy CI w jednym.

## Wnioski końcowe

- **Powtarzalność** — w kontenerze łatwiej o ten sam wynik niż na „losowym” hoście (*szczególnie widoczne przy testach Redis*)
- **Podział pracy** — osobne etapy build i test to mniej chaosu przy błędach i przy dalszym rozwoju
- **Dane i komunikacja** — woluminy trzymają artefakty po zatrzymaniu kontenera, sieć ułatwia sensowne łączenie usług
- **CI** — Jenkins w DIND daje serwerowi CI własny Docker do budowy obrazów i kroków w kontenerach: tak jak lokalnie, ale z jednego miejsca 

