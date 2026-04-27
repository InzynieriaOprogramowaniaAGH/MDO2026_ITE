# Sprawozdanie podsumowujące laboratoria 5-7

Autor: Jan Pawelec

---

## Spis treści
1. [Jenkins i Blue Ocean](#1-jenkins-i-blue-ocean)
2. [Pipeline w postaci Jenkinsfile](#2-pipeline-w-postaci-jenkinsfile)
3. [Multi-stage Dockerfile w Jenkins](#3-multi-stage-dockerfile-w-jenkins)
4. [Zarządzanie artefaktami](#4-zarządzanie-artefaktami)
5. [Lista kontrolna](#5-lista-kontrolna)
6. [Wnioski](#6-wnioski)
---

# 1. Jenkins i Blue Ocean
Fundamentem nowoczesnego podejścia DevOps jest pełna automatyzacja cyklu życia oprogramowania. Wykorzystanie serwera `Jenkins` w architekturze skonteneryzowanej pozwala na stworzenie elastycznego i izolowanego środowiska orkiestracji.

## Środowisko uruchomieniowe Jenkins i Blue Ocean
W celu zapewnienia nowoczesnego interfejsu i przejrzystości procesów, stosuje się rozszerzenie `Blue Ocean`. Pozwala ono na wizualizację potoków zadań w podziale na etapy, co znacząco ułatwia diagnostykę błędów na ścieżce krytycznej. Całość systemu operuje wewnątrz sieci mostkowej Dockera, zapewniając bezpieczną komunikację między serwerem a agentami.

## Technologia Docker-in-Docker
Kluczowym aspektem technologicznym jest umożliwienie Jenkinsowi zarządzania kontenerami bez instalowania demona Dockera bezpośrednio na jego obrazie. Wykorzystuje się do tego model `DinD`, gdzie Jenkins komunikuje się z dedykowanym kontenerem pomocniczym. Dzięki temu procesy budowania obrazów aplikacji zachodzą w pełnej izolacji, nie wpływając na stabilność głównego serwera automatyzacji.

---

# 2. Pipeline w postaci Jenkinsfile
Nowoczesne potoki CI/CD definiuje się w postaci kodu w pliku `Jenkinsfile`, co pozwala na ich wersjonowanie w systemie Git. 

## Struktura i integracja z SCM
Logika budowania jest nierozerwalnie związana z kodem źródłowym. Wykorzystanie instrukcji `checkout scm` pozwala Jenkinsowi na automatyczne pobranie odpowiedniej gałęzi repozytorium. Potok dzieli się na fazy (stages), takie jak:
- `Cleanup`: Czyszczenie przestrzeni roboczej przed startem.
- `Build/Test`: Operacje na kodzie.
- `Publish`: Dystrybucja gotowych pakietów.

Przykładowy fragment deklaratywnego potoku:
```bash
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps { checkout scm }
        }
        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }
    }
}
```

# 3. Multi-stage Dockerfile w Jenkins
Wytwarzanie oprogramowania w kontenerach wymaga dbałości o bezpieczeństwo i rozmiar obrazów wynikowych. Standardem staje się technologia Multi-stage Build.

## Separacja środowisk: Builder, Tester, Deploy
W pliku Dockerfile definiuje się niezależne etapy, które pozwalają na odseparowanie narzędzi deweloperskich od środowiska produkcyjnego:
- Stage Builder: Zawiera pełny zestaw narzędzi (np. gcc, make). Tu następuje kompilacja kodu źródłowego do postaci binarnej.
- Stage Tester: Bazuje na builderze i uruchamia testy jednostkowe. Niepowodzenie na tym etapie natychmiast przerywa cały proces CI.
- Stage Deploy: Najważniejszy etap, budowany na minimalistycznym obrazie (np. Alpine). Kopiowane są do niego wyłącznie gotowe biblioteki binarne, co drastycznie zmniejsza powierzchnię ataku (brak kompilatorów i kodu źródłowego w obrazie końcowym).

# 4. Zarządzanie artefaktami
Efektem końcowym poprawnego potoku CI/CD jest artefakt – zwersjonowany, gotowy do dystrybucji plik lub obraz.

## Ekstrakcja binarek i archiwizacja
W przypadku bibliotek, stosuje się metodę tymczasowego kontenera, aby wydobyć skompilowany plik binarny (.so) na system plików hosta, a następnie spakować go do archiwum .tar.gz. Jenkins wykorzystuje dyrektywę archiveArtifacts, która trwale dołącza wynik budowania do historii danego wydania.

## Dynamiczne wersjonowanie
Technologia ta pozwala na automatyczne nadawanie wersji na podstawie numeru budowania Jenkinsa (np. `1.0.${env.BUILD_NUMBER}`). Zapewnia to pełną identyfikowalność – każda paczka binarna posiada swój unikalny identyfikator powiązany z konkretnym przebiegiem procesu automatyzacji.

# 5. Lista kontrolna
Aby potok CI/CD był wiarygodny, musi być deterministyczny – każde uruchomienie powinno dawać przewidywalny rezultat.

## Higiena środowiska i blokada cache
W celu uniknięcia błędów wynikających z "zastanych" danych, stosuje się:
- Clean Workspace: Funkcja `cleanWs()` w sekcji post gwarantuje, że po każdym buildzie przestrzeń robocza zostaje wyczyszczona.
- No-cache Build: Wykorzystanie flagi --no-cache podczas budowania obrazów Dockera wymusza każdorazowe pobieranie najświeższych zależności, eliminując problemy związane z przestarzałą pamięcią podręczną warstw.

## Definition of Done
Przed uznaniem artefaktu za gotowy i dopuszczeniem go do wydania, potok automatycznie weryfikuje twarde kryteria akceptacji:
- Kompilacja: Brak błędów podczas budowania biblioteki.
- Testy automatyczne: Pomyślne przejście testów jednostkowych.
- Bezpieczeństwo i Optymalizacja: Finalny obraz nie może zawierać zbędnych narzędzi deweloperskich (jest lekki i bezpieczny).
- Smoke Testing: Wykonanie testu wdrożeniowego (`docker run --rm`) sprawdzającego fizyczne istnienie biblioteki w kontenerze docelowym.
- Identyfikowalność: Artefakt musi posiadać sumę kontrolną oraz unikalną nazwę z numerem buildu.

# 6. Wnioski
Zaawansowane techniki CI/CD przenoszą punkt ciężkości z manualnego wdrażania na automatyzację. Integracja Jenkins Pipeline z Multi-stage Docker Builds pozwala na tworzenie procesów, które są jednocześnie bezpieczne, szybkie i wysoce powtarzalne. Kluczowym osiągnięciem jest pełna izolacja etapów – od kompilacji, przez testy, aż po publikację zwersjonowanego artefaktu. Dzięki takiemu podejściu każda zmiana w kodzie przechodzi rygorystyczną, automatyczną kontrolę jakości przed trafieniem do dystrybucji.