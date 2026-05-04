# Sprawozdanie laboratoria 5–7
**Autor:** Artur Niemiec  

---

## 5–6. Budowa potoku CI/CD i konfiguracja Jenkinsa (Lab 5 i 6)

Celem zajęć było przygotowanie środowiska Continuous Integration oraz demonstracja podstawowych mechanizmów automatyzacji. Zgodnie z najlepszymi praktykami, do obsługi Dockera wewnątrz Jenkinsa wykorzystano wzorzec **Docker-in-Docker**. Utworzono współdzieloną sieć, w której uruchomiono kontener `docker:dind` pełniący rolę demona Dockera, oraz własny obraz Jenkinsa oparty na `jenkins/jenkins:2.541.3-jdk21`.

### Konfiguracja i pierwsze kroki
Po pomyślnej inicjalizacji i uzyskaniu hasła administratora, przetestowano trzy typy zadań o swobodnej konfiguracji:
1. Wyświetlanie informacji o systemie (`uname`).
2. Zadanie generujące błąd zależny od godziny.
3. Pobieranie i weryfikację obrazów kontenerowych.

### Mechanizm Pipeline i Optymalizacja
Zdefiniowano pierwszy obiekt typu **Pipeline** w języku Groovy. Kluczowym wnioskiem z tego etapu była demonstracja działania mechanizmu **Docker Cache**. 

Przy pierwszym uruchomieniu proces budowy obrazu CPython trwał ok. 15 minut. Przy powtórnym uruchomieniu czas ten skrócił się do kilku sekund, ponieważ Jenkins wykonał jedynie `git fetch`, a Docker wykorzystał gotowe warstwy obrazu z dysku, pomijając czasochłonną kompilację.

**Fragment podstawowego skryptu Pipeline:**
```groovy
pipeline {
    agent any
    stages {
        stage('Clone') {
            steps {
                git branch: 'AN420700', url: '[https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git)'
            }
        }
        stage('Build Builder Image') {
            steps {
                dir('grupa4/AN420700/cpython') {
                    sh 'docker build -t python-builder:latest -f Dockerfile.build .'
                }
            }
        }
    }
}
```

## 7. Zaawansowany, pełnoprawny potok CI/CD oparty o SCM (Lab 7)

Zaimplementowano kompletny cykl życia aplikacji (Build -> Test -> Deploy -> Publish) w postaci skryptu Jenkinsfile, który tym razem dostarczany był bezpośrednio z repozytorium kodu przez SCM. Rozwiązuje to problem twardego kodowania potoków wewnątrz UI Jenkinsa.

Zadbano o pełną higienę przestrzeni roboczej oraz higienę obrazów lokalnych. Potok podwójnie czyści środowisko robocze przed rozpoczęciem i po zakończeniu budowania za pomocą cleanWs() oraz usuwa stworzone obrazy w sekcji post { always { ... } }, co wymusza pracę na najnowszym kodzie przy kolejnych uruchomieniach.

Rozdzielono etap kompilacji (`BUILDER_IMAGE`) od etapu uruchomieniowego (`DEPLOY_IMAGE`). Dodano również dedykowany etap testowania na osobnym obrazie (`TESTER_IMAGE`), w którym logi z wykonanych testów są eksportowane i archiwizowane jako artefakty potoku.

Kluczowe kroki zaawansowanego potoku:

*   **Testy i archiwizacja artefaktów:**
    ```groovy
    stage('Test') {
      steps {
          script {
              sh "docker build -f Dockerfile.test -t ${TESTER_IMAGE} ."
              sh "docker run --name cpython-test-run ${TESTER_IMAGE}"
              sh "docker logs cpython-test-run > test-results.log"
          }
      }
      post {
          always { archiveArtifacts artifacts: 'test-results.log', fingerprint: true }
      }
    }
    ```


*   **Smoke Test (lokalne wdrożenie testowe):**
    ```groovy
    stage('Smoke Test / Local Deploy') {
        steps {
            script {
                sh "docker run --rm ${DEPLOY_IMAGE} python3 -c \"print('Smoke test przeszedł pomyślnie!')\""
            }
        }
    }
    ```
*   **Czyszczenie środowiska (sekcja post):**
    ```groovy
    post {
      always {
          script {
              sh "docker rmi ${BUILDER_IMAGE} ${TESTER_IMAGE} ${DEPLOY_IMAGE} || true"
          }
          cleanWs()
      }
    }
    ```

---

### Wnioski i podsumowanie

| Lab | Zakres | Kluczowe narzędzia i koncepcje |
|-----|--------|--------------------------------|
| 5-6 | Jenkins, DinD, Freestyles, UI Pipeline, Caching | Jenkins, Docker-in-Docker, Groovy, Docker Cache |
| 7 | Pełny cykl CI/CD, Pipeline z SCM, Artefakty, Cleanup | Jenkinsfile (SCM), multi-stage, `cleanWs()`, `archiveArtifacts` |

Laboratoria 5–7 stanowią praktyczne wdrożenie wiedzy z poprzednich zajęć (Dockera i Gita) w scentralizowanym środowisku CI/CD. Główne założenia to **automatyzacja, powtarzalność i higiena potoku**. Dzięki poprawnemu zdefiniowaniu struktury w Jenkinsfile, proces od pobrania kodu, poprzez budowę wyspecjalizowanych obrazów (Builder, Tester, Deploy), uruchomienie środowiska testowego, aż do otagowania i publikacji, wykonuje się bez udziału człowieka, będąc w pełni odpornym na zaszłości i pozostałości po wcześniejszych buildach.
