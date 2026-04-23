# Sprawozdanie – Jenkins, Pipeline CI/CD (Zajęcia 1–3)

## 1. Wprowadzenie

Celem zajęć było zaprojektowanie oraz implementacja pipeline’u CI/CD w środowisku Jenkins, obejmującego pełny cykl życia aplikacji: od pobrania kodu, przez budowanie i testowanie, aż po wdrożenie i publikację artefaktów.

Zajęcia koncentrowały się na:
- automatyzacji procesów build/test/deploy/publish,
- wykorzystaniu konteneryzacji (Docker),
- definiowaniu pipeline’u jako kodu (Jenkinsfile),
- zapewnieniu powtarzalności i przenośności środowiska.

---

## 2. Zajęcia 1 – Jenkins, Pipeline, izolacja etapów

### Przygotowanie środowiska

- Uruchomiono instancję Jenkins w środowisku Docker
- Skonfigurowano środowisko Docker-in-Docker (DIND)
- Przygotowano i uruchomiono interfejs Blue Ocean
- Przeprowadzono inicjalną konfigurację Jenkinsa:
  - logowanie
  - konfiguracja użytkownika
  - zabezpieczenie i archiwizacja logów

### Zadania wstępne

- Utworzono projekt wyświetlający wynik polecenia `uname`
- Utworzono projekt generujący błąd w zależności od warunku (np. nieparzysta godzina)
- Wykonano operację `docker pull` w pipeline (pobranie obrazu Ubuntu)

### Pipeline (pierwsza wersja)

- Utworzono obiekt typu pipeline bez użycia SCM
- Zdefiniowano pipeline bezpośrednio w Jenkinsie
- Pipeline realizował:
  - klonowanie repozytorium
  - checkout odpowiedniej gałęzi
  - budowanie obrazu Dockerfile
- Pipeline został uruchomiony wielokrotnie w celu weryfikacji działania

### Najważniejsze zagadnienia

- Pipeline jako sekwencja etapów (stages)
- Izolacja środowiska dzięki kontenerom
- Integracja Jenkins z Dockerem
- Różnica między klasycznym interfejsem a Blue Ocean

### Wnioski

- Jenkins umożliwia automatyzację procesów budowania i testowania
- Kontenery zapewniają izolację i powtarzalność środowiska
- Pipeline może być rozwijany iteracyjnie

---

## 3. Zajęcia 2 – Pipeline jako proces CI/CD (lista kontrolna)

### Ścieżka krytyczna pipeline’u

Zdefiniowano podstawowy przepływ CI/CD:

- commit / trigger
- clone
- build
- test
- deploy
- publish

Każdy z tych etapów został przeanalizowany i zaplanowany.

### Kluczowe elementy pipeline’u

- Wybór aplikacji open-source
- Weryfikacja licencji
- Poprawne budowanie aplikacji
- Przechodzenie testów jednostkowych

### Konteneryzacja procesu

- Build wykonywany w kontenerze
- Testy wykonywane w osobnym kontenerze
- Kontener testowy oparty na buildowym

### Artefakty i logi

- Logi procesu zapisywane jako artefakty
- Określenie formy artefaktu (np. obraz Docker lub plik binarny)
- Wersjonowanie artefaktów (np. semantic versioning)

### Deploy i testy końcowe

- Przygotowanie kontenera deploy
- Uruchomienie aplikacji w kontenerze
- Weryfikacja działania (smoke test)

### Publikacja

- Publikacja artefaktów:
  - do rejestru (np. Docker Hub)
  - jako artefakt w Jenkinsie

### Dokumentacja procesu

- Utworzenie diagramu UML pipeline’u
- Opis wszystkich etapów i decyzji projektowych
- Porównanie planu z rzeczywistą implementacją

### Najważniejsze zagadnienia

- CI/CD jako proces ciągłej integracji i dostarczania
- Artefakty jako rezultat pipeline’u
- Wersjonowanie i identyfikowalność buildów
- Rozdzielenie etapów build/test/deploy

### Wnioski

- Pipeline musi być kompletny i jednoznaczny
- Kontenery znacząco upraszczają zarządzanie środowiskiem
- Dokumentacja jest kluczowa dla utrzymania projektu
- Automatyzacja zmniejsza ryzyko błędów ludzkich

---

## 4. Zajęcia 3 – Jenkinsfile i Pipeline jako kod

### Pipeline jako kod (Pipeline as Code)

- Pipeline został przeniesiony do repozytorium w postaci pliku `Jenkinsfile`
- Jenkins pobiera definicję pipeline’u z systemu kontroli wersji (SCM)

### Weryfikacja pipeline’u

Pipeline został dostosowany do pełnej ścieżki krytycznej:

#### Etapy pipeline’u

1. **Clone**
   - pobranie kodu z repozytorium
   - zapewnienie pracy na aktualnej wersji (brak cache)

2. **Build**
   - budowanie obrazu Docker (np. BLDR)
   - przygotowanie artefaktu

3. **Test**
   - uruchomienie testów w kontenerze
   - wykorzystanie obrazu buildowego

4. **Deploy**
   - przygotowanie środowiska wdrożeniowego
   - uruchomienie kontenera lub aplikacji

5. **Publish**
   - publikacja artefaktu:
     - do rejestru
     - jako artefakt Jenkins

### Powtarzalność pipeline’u

- Pipeline został uruchomiony wielokrotnie
- Zweryfikowano brak zależności od cache
- Każde uruchomienie korzystało z aktualnego kodu

### Definition of Done

Pipeline uznano za poprawny, gdy:

- powstaje działający artefakt
- artefakt można uruchomić poza środowiskiem lokalnym
- obraz Docker działa bez modyfikacji
- artefakt jest możliwy do ponownego użycia

### Najważniejsze zagadnienia

- Jenkinsfile jako deklaratywna definicja pipeline’u
- Integracja CI/CD z repozytorium
- Powtarzalność i deterministyczność buildów
- Automatyczne wdrażanie aplikacji

### Wnioski

- Pipeline jako kod zwiększa przejrzystość i kontrolę
- Jenkinsfile umożliwia wersjonowanie procesu CI/CD
- Powtarzalność jest kluczowa dla niezawodności
- Automatyczne pipeline’y są podstawą DevOps

---

## 5. Podsumowanie końcowe

Podczas zajęć zdobyto praktyczne umiejętności w zakresie:

- konfiguracji i obsługi Jenkinsa  
- tworzenia pipeline’ów CI/CD  
- integracji Jenkins z Dockerem  
- budowania i testowania aplikacji w kontenerach  
- wdrażania i publikowania artefaktów  
- definiowania pipeline’u jako kodu (Jenkinsfile)  

### Najważniejsze wnioski

- Jenkins jest narzędziem umożliwiającym pełną automatyzację procesu CI/CD  
- Konteneryzacja zapewnia izolację i powtarzalność środowiska  
- Pipeline jako kod jest kluczowy dla utrzymania i rozwoju projektu  
- CI/CD znacząco przyspiesza proces dostarczania oprogramowania  
- Poprawnie zaprojektowany pipeline powinien być:
  - powtarzalny  
  - automatyczny  
  - jednoznaczny  
  - możliwy do uruchomienia w dowolnym środowisku  
