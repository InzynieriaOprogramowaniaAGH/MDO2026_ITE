# Praca z Jenkinsfile

Zajęcia były poświęcone doskonaleniu skryptu pipeline i pracy z nim.

## Konfiguracja

Skrypt został przeniesiony do repozytorium, gdzie może podlegać dynamicznym zmianom. Żeby pipeline wykonywał go, należy wprowadzić dane, odpowiadające repozytorium w którym skrypt się znajduje.

Wprowadzony adres repozytorium:

![Script repo](images/1.%20Script%20repo.png)

Gałąź i ścieżka skryptu:

![Script path](images/2.%20Script%20path.png)

Teraz gdy zostanie uruchomiony build, pipeline sklonuje repozytorium i wykona skrypt.

## Uruchamianie

Build nie musi być uruchamiany ręcznie za każdym razem. Do automatyzacji tego procesu mogą posłużyć:

* **Webhook (wymaga uprawnień)**: narzędzie stworzone do wykonywania operacji HTTP po wykryciu wydarzenia.
![Webhook](images/6.%20Webhook.png)

* **GitHub Workflow**: skrypt podobny do pipeline'a w Jenkins, do wykonywania czynności po wykryciu operacji.
![Workflow](images/7.%20Workflow.png)

Zwykły git hook nie może zostać wykorzystany do automatyzacji build'a ponieważ brakuje hook'a, który wykonywałby polecenia po `git push`, kiedy skrypt został zaktualizowany i umieszczony na repozytorium.

## Skrypt Jenkinsfile

Pipeline podlega takiemu samemu szeregowi czynności co na poprzednich zajęciach, jednak został on znacznie rozbudowany. Zawiera większą ilość funkcjonalności, które zupełnie automatyzują proces testowania i wdrażania oprogramowania.

Celem skryptu jest takie zarządzanie środowiskiem, żeby każdy nowy build przebiegał tak, jakby był pierwszy, tzn. należy uniknąć cachowania plików, obrazów itp.

### 0. Początek skryptu

Ponieważ skrypt znajduje się w repozytorium, które jest klonowane przez konfigurację pipeline'a, krok klonujący nie jest wymagany w skrypcie. Po zdefiniowaniu zmiennych środowiskowych można przejść bezpośrednio do budowania projektu.

### 1. Przygotowania

Pierwszym krokiem jest usunięcie wszystkich (jeżeli istnieją) artefaktów, pozostałych po poprzednich wykonaniach. Przyjętą konwencją jest nadawanie wszystkim artefaktom prefixu *"ART_"*.

### 2. Budowanie

Ten krok jest odpowiedzialny na wszystkie polecenia `docker build`. Powstają tu dwa obrazy za pomocą jednego Dockerfile podzielonego na etapy: *my-app-build:BLDR* i *my-app-build:(build_number)*. Pierwszy to obraz budujący, pobierający wszystkie pliki i konstruujący projekt. Drugi (ze względu na bardzo niedużą złożoność projektu) nie różni się prawie niczym od pierwszego, kopiując od niego wszystkie skonstruowane pliki i wywołując `echo` jako mock-up wdrożenia.

### 3. Testowanie

Ten krok uruchamia tymczasowy kontener na podstawie pierwszego obrazu i wywołuje w nim skrypt testujący program, zapisując wyniki do pliku tekstowego jako artefakt. Zapisywany jest status tej operacji, który decyduje o powodzeniu build'a. W przypadku niepowodzenia na tym etapie, w pliku będzie można znaleźć przyczynę, nawet jeżeli nie jest ona związana z samym programem.

Treść pliku po powodzeniu:

![Test results](images/4.%20Test%20results.png)

### 4. Wdrażanie

Krok wdrażający uruchamia kontener na bazie drugiego obrazu, symulując prawdziwe wdrożenie programu. Biorąc pod uwagę brak dużych różnic między obrazami, ten krok powinien zakończyć się sukcesem, jeżeli testy przeszły.

### 5. Publikacja

Jeżeli wszystko przebiegło pomyślnie, obraz wdrażany otrzymuje tag 'latest' i zostaje zarchiwizowany, skompresowany i zapisany jako artefakt:

![Artifacts](images/3.%20Artifacts.png)

### 6. Czynności zamykające (czyszczenie)

Po przejściu przez wszystkie etapy pipeline, środowisko zostaje oczyszczone przez `cleanWs()` i wszystkie instancje dockera są usuwane przez `docker prune`. Przywrócony zostaje stan sprzed uruchomienia build'a.

## Rezultat

Pomyślnie uruchomiony pipeline:

![Stages](images/5.%20Stages.png)

Jeżeli wszystkie etapy zakończyły się sukcesem, zwracane są dwa artefakty: zbudowany obraz i wyniki testów. Cały proces budowania, testowania i wdrażania oprogramowania został skutecznie zautomatyzowany.