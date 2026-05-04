# Sprawozdanie Zbiorcze - Laboratoria 5-7 (CI/CD, Jenkins i Docker)

W tym dokumencie zebrałem najważniejsze informacje i efekty prac z laboratoriów 5, 6 i 7. Cały ten blok był poświęcony automatyzacji CI/CD (Continuous Integration / Continuous Deployment) przy pomocy Jenkinsa oraz konteneryzacji w Dockerze. Poniżej znajduje się krótkie omówienie tego, jak ewoluował proces wdrażania aplikacji.

## Laboratorium 5: Pierwsze kroki z automatyzacją
Na piątych laboratoriach postawiliśmy fundamenty pod działania CI/CD. Zapoznaliśmy się z serwerem Jenkins i jego interfejsem. Skupiliśmy się na spięciu Jenkinsa z repozytorium (systemem kontroli wersji Git), tak aby serwer wykrywał kod i potrafił na niego reagować. To był wstęp, który przygotował bazę do pisania pełnoprawnych rurociągów.

* **Pełny opis ćwiczenia oraz zrzuty ekranu znajdują się w:** [Sprawozdaniu 5](../Sprawozdanie5/README.md)

## Laboratorium 6: "Pipeline as Code" i konteneryzacja
Szóste laboratoria to przejście na wyższy poziom. Zamiast wyklikiwać zadania w interfejsie Jenkinsa, cała konfiguracja została przeniesiona do kodu w pliku `Jenkinsfile`. Zbudowany został rurociąg, który automatycznie klonował repozytorium, budował aplikację, testował ją, a na koniec tworzył gotowy do wdrożenia obraz za pomocą wydzielonego pliku `Dockerfile.deploy`. Aby lepiej udokumentować architekturę tego wdrożenia, przygotowany został również schemat w języku PlantUML (`diagram.puml`).

* **Pełny opis ćwiczenia oraz zrzuty ekranu znajdują się w:** [Sprawozdaniu 6](../Sprawozdanie6/README.md)

## Laboratorium 7: Zarządzanie artefaktami
Siódme zajęcia stanowiły domknięcie procesu CI/CD. Ponieważ pipeline potrafił już poprawnie zbudować i przetestować aplikację, należało sensownie zarządzać wynikiem jego pracy. Plik `Jenkinsfile` został zmodyfikowany w taki sposób, by po pomyślnym przejściu testów (tzw. smoke testów), aplikacja (w tym przypadku serwer Redis) była pakowana do archiwum `.tar.gz` i bezpiecznie odkładana w Jenkinsie jako gotowy do użycia artefakt. Dzięki temu uzyskano stabilną paczkę gotową do późniejszych wdrożeń na serwery docelowe.

* **Pełny opis ćwiczenia oraz zrzuty ekranu znajdują się w:** [Sprawozdaniu 7](../Sprawozdanie7/README.md)
