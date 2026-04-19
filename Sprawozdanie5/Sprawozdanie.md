# Sprawozdanie 5 - Automatyzacja CI/CD: Jenkins Pipeline i Docker-in-Docker

**Autor:** Maciej Szewczyk (MS422035)  
**Kierunek:** ITE  
**Grupa:** G6

## 1. Architektura Jenkins Docker-in-Docker (DinD)

Celem zadania było skonfigurowanie zaawansowanego środowiska Continuous Integration, w którym serwer Jenkins zarządza cyklem życia kontenerów Docker. Zastosowano architekturę Sidecar, izolując procesy Jenkinsa od silnika budującego obrazy (Docker-in-Docker).

### Konfiguracja infrastruktury
Przygotowałem dedykowaną sieć wirtualną `jenkins` oraz wolumin trwały `jenkins-data`. Uruchomiłem dwa kontenery: `jenkins-docker` (serwer pomocniczy DinD) oraz `jenkins-blueocean` (serwer Jenkins). Komunikacja odbywa się bez szyfrowania TLS na porcie 2375 wewnątrz odizolowanej sieci.

![Uruchomienie kontenerów Jenkins i DinD](obrazy/01_Jenkins.png)

## 2. Bezpieczeństwo i Administracja Logów

Kluczowym aspektem zarządzania serwerem CI jest ochrona logów oraz zasobów systemowych przed nadmiarowym zużyciem miejsca na dysku.

### Zabezpieczenie dostępu
W sekcji *Security* skonfigurowałem model autoryzacji "Logged-in users can do anything" oraz wyłączyłem dostęp dla użytkowników anonimowych. Gwarantuje to poufność przebiegu buildów.

![Konfiguracja zabezpieczeń Jenkins](obrazy/02_bezpieczeństwo_logów.png)

### Archiwizacja i rotacja logów
Zaimplementowałem mechanizm *Build Discarder*. System został skonfigurowany tak, aby przechowywać historię jedynie 5 ostatnich budowań, co zapewnia optymalizację miejsca na woluminie `jenkins-data`.

![Konfiguracja rotacji logów w Pipeline](obrazy/05_archiwizacja_logów.png)

## 3. Zadania wstępne (Freestyle Project)

Przed wdrożeniem pełnego potoku CI, zweryfikowałem łączność Jenkinsa z silnikiem Docker oraz poprawność działania skryptów warunkowych.

### Test środowiska i pobieranie obrazów
Stworzyłem zadanie testowe pobierające obrazy. Dodatkowo zaimplementowałem skrypt sprawdzający parzystość godziny w strefie UTC – build kończy się sukcesem tylko przy parzystej godzinie.

![Logi konsoli: pobieranie obrazów i test godziny](obrazy/03_projekt_wstępny.png)
![Logi konsoli: pobieranie obrazu Ubuntu](obrazy/04_projekt_kontener.png)

## 4. Zaawansowany Pipeline CI/CD

Finałowym etapem było stworzenie potoku (Pipeline) zdefiniowanego jako kod, integrującego się z systemem kontroli wersji GitHub.

### Integracja z GitHub i Multistage Build
Pipeline został skonfigurowany do pracy z gałęzią personalną `MS422035`. Wykorzystałem flagę `-f` do wskazania dedykowanych plików:
*   **Dockerfile.build**: Kompilacja aplikacji Calculator (Maven).
*   **Dockerfile.test**: Uruchomienie testów jednostkowych JUnit na bazie zbudowanego obrazu.

![Wynik testów jednostkowych w Pipeline](obrazy/06_pipeline.png)

### Optymalizacja czasu budowania (Docker Cache)
Przeprowadziłem analizę wydajności poprzez powtórne uruchomienie zadania. 
*   **Pierwszy build:** 31 sekund (pełne pobieranie zależności).
*   **Drugi build:** 10 sekund (użycie warstw CACHED).

Zysk czasowy na poziomie ok. 67% potwierdza skuteczność mechanizmu *Docker Layer Caching*.

| Build # | Czas trwania | Status |
| :--- | :--- | :--- |
| Pierwszy | 31 sek | SUCCESS |
| Drugi | 10 sek | SUCCESS |

![Czas trwania pierwszego buildu](obrazy/07_1_pipeline.png)
![Czas trwania drugiego buildu - optymalizacja](obrazy/07_2_pipeline.png)

## 5. Wnioski
Zastosowanie Jenkins Pipeline pozwala na pełną automatyzację cyklu życia aplikacji. Wykorzystanie architektury Docker-in-Docker umożliwia budowanie obrazów w odizolowanym środowisku, a mechanizmy cachowania warstw znacząco przyspieszają procesy CI/CD, co jest kluczowe w profesjonalnym wytwarzaniu oprogramowania.