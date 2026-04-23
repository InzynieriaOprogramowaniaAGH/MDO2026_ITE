# Jenkins

Jenkins jest narzędziem, służącym do rozwoju oprogramowania zgodnie z praktykami CI/CD (Continuous Integration & Continuous Delivery/Deployment). Pozwala on automatyzować proces budowania, testowania i wdrażania kodu, oszczędzając dużą ilość czasu deweloperom.

## Pipeline

Pipeline jest określeniem ciągu etapów procesu, przez które przechodzi tworzone oprogramowanie, by mogło zostać uznane za gotowy produkt. Strukturą przypomina taśmociąg, transportujący produkty między czynnościami weryfikującymi ich jakość, spójność i gotowość do dystrybucji.

Na ścieżkę krytyczną pipeline'a składają się następujące kroki:

### Klonowanie (clone)

Krok klonujący pobiera oprogramowanie z repozytorium i przygotowuje środowisko do pracy.
Jeżeli ten krok zawodzi - pipeline nie ma dostępu do kodu źródłowego.

### Budowanie (build)

Krok budujący odpowiada za tworzenie wersji produktów dla następnych etapów przez np. kompilację, tworzenie *docker image*. Kroki testujący i wdrażający powinny pracować na odrębnych instancjach oprogramowania.
Jeżeli ten krok zawodzi - w kodzie znajdują się błędy składniowe lub konfiguracja jest niepoprawna.

### Testowanie (test)

Ten krok przeprowadza unit testy i weryfikuje warunki zdefiniowane w skrypcie pipeline'a. Jest kontrolą jakości oprogramowania, która może zostać odpowiednio dostrojona, by przepuszczać produkt dalej tylko w sprzyjających okolicznościach.
Jeżeli ten krok zawodzi - kod nie przechodzi testów i nie jest gotowy do dystrybucji.

### Wdrożenie (deploy)

Jeżeli program spełnia zdefiniowane oczekiwania, przechodzi do tego etapu, gdzie podlega ostatniemu testowi, którym jest symulacja uruchomienia w kontrolowanym środowisku. Dzięki temu można zapobiec wypuszczeniu produktu, który działa tylko na konkretnie skonfigurowanej maszynie, a nie na dowolnym urządzeniu potencjalnego klienta.
Jeżeli ten krok zawodzi - kod musi zostać odpowiednio zmodyfikowany, by działał w wybranych środowiskach.

Na tym kroku kończy się kontrola.

### Publikacja (publish)

Jeżeli oprogramowanie dociera do tego etapu, oznacza to że jest ono gotowe do dystrybucji. Krok publikacji decyduje co zrobić z wykończonym produktem. Może zostać on odesłany z powrotem na repozytorium przez `git push`, zapisany w formie lokalnego pliku lub nawet wcielony bezpośrednio w produkcję.

---

Jeżeli pipeline zawiedzie na jednym z etapów, następne uruchomienie nie musi powtarzać wszystkich operacji. Jenkins cachuje utworzone instancje, co dodatkowo przyspiesza proces rozwoju.

## Syntax

Za przebieg procesu odpowiada *Jenkins pipeline script*, który posiada własną składnię:

### Bloki

Skrypt jest podzielony na bloki. Najważniejsze z nich to:
* `pipeline {...}`: otacza cały skrypt;
* `stages {...}`: otacza etapy pipeline'a;
* `stage('name') {...}`: definiuje pojedynczy etap i wszystkie jego operacje;
* `environment {...}`: otacza utworzone zmienne środowiskowe;
* `agent {...}`: definiuje agenta etapu, np. docker, git, gcc, node;
* `script {...}`: otacza wykonywane polecenia terminala;
* `post {...}`: otacza operacje wykonywane zawsze po poprzednim bloku.

Przykładowa struktura skryptu:

``` r
pipeline {
    environment {...}
    stages {
        stage('first') {
            script {...}
        }
        stage('second') {
            agent {...}
            script {...}
            post {...}
        }
        stage('third') {
            script{...}
            post{...}
        }
    }
    post {...}
}
```

### Agenty

Agent definiuje miejsce, w którym Jenkins wywoła podane polecenie. Zamiast pisać sam skrypt terminala jak w np. bash, Jenkins daje możliwość wywoływania poleceń programów, podając tylko wartości argumentów.

Przykłady agentów:
* git
* docker
* dockerfile
* node
* any/none: automatyczne dopasowanie agenta/brak domyślnego agenta.

Przykład definiowania agenta:

``` r
agent {
    dockerfile {
        filename 'Dockerfile.build'
        dir 'build'
        label 'my-defined-label'
        additionalBuildArgs  '--build-arg version=1.0.2'
        args '-v /tmp:/tmp'
    }
}
```
(Równowartość: `docker build -f Dockerfile.build --build-arg version=1.0.2 ./build/`)

### Zmienne środowiskowe

Jenkins posiada zestaw wbudowanych zmiennych środowiskowych, możliwych do odczytania w skrypcie. Wywołuje się je w następujący sposób: `${NAZWA_ZMIENNEJ}`

Przykładowe zmienne:
* `BUILD_NUMBER`: number obecnego build'a;
* `GIT_URL`: adres zdalnego repozytorium;
* `GIT_BRANCH`: nazwa branch'a;
* `WORKSPACE`: ścieżka do przestrzeni roboczej pipeline'a;