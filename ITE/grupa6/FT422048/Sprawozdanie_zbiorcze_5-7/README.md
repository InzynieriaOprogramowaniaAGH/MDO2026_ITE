# Sprawozdanie Zbiorcze - Laboratoria 5-7 (CI/CD, Jenkins i Docker)

W tym dokumencie zebrałem najważniejsze informacje i efekty prac z laboratoriów 5, 6 i 7. Cały ten blok był poświęcony automatyzacji CI/CD (Continuous Integration / Continuous Deployment) przy pomocy Jenkinsa oraz konteneryzacji w Dockerze. Poniżej znajduje się krótkie omówienie tego, jak ewoluował nasz proces wdrażania aplikacji.

## Laboratorium 5: Pierwsze kroki z automatyzacją
Na piątych laboratoriach postawiliśmy fundamenty pod nasze CI/CD. Zapoznaliśmy się z samym serwerem Jenkins i jego interfejsem. Skupiliśmy się na spięciu Jenkinsa z naszym repozytorium (systemem kontroli wersji Git), tak aby serwer "widział" nasz kod i potrafił na niego reagować. To był dobry wstęp, który przygotował nas do pisania prawdziwych rurociągów.

* **Szczegóły i zrzuty ekranu znajdziesz tutaj:** [Przejdź do Sprawozdania 5](../Sprawozdanie5/README.md)

## Laboratorium 6: "Pipeline as Code" i konteneryzacja
Szóste laby to już konkretne przejście na wyższy poziom. Zamiast wyklikiwać zadania w interfejsie Jenkinsa, całą konfigurację przenieśliśmy do kodu w pliku `Jenkinsfile`. Zbudowaliśmy pełnoprawny rurociąg, który automatycznie klonował repozytorium, budował aplikację, testował ją, a na koniec tworzył gotowy do wdrożenia obraz za pomocą wydzielonego pliku `Dockerfile.deploy`. Żeby lepiej zrozumieć i udokumentować architekturę tego wdrożenia, przygotowałem też schemat w języku PlantUML (`diagram.puml`).

* **Szczegóły i zrzuty ekranu znajdziesz tutaj:** [Przejdź do Sprawozdania 6](../Sprawozdanie6/README.md)

## Laboratorium 7: Zarządzanie artefaktami
Siódme zajęcia były domknięciem procesu CI/CD. Skoro nasz pipeline potrafił już poprawnie zbudować i przetestować aplikację, musieliśmy sensownie zarządzać wynikiem jego pracy. Zmodyfikowaliśmy `Jenkinsfile` w taki sposób, by po pomyślnym przejściu testów (tzw. smoke testów), aplikacja (w naszym przypadku serwer Redis) była pakowana do archiwum `.tar.gz` i bezpiecznie odkładana w Jenkinsie jako gotowy do użycia artefakt. Dzięki temu mamy pewną i sprawdzoną paczkę, z której możemy skorzystać podczas późniejszych wdrożeń na serwery docelowe.

* **Szczegóły i zrzuty ekranu znajdziesz tutaj:** [Przejdź do Sprawozdania 7](../Sprawozdanie7/README.md)
