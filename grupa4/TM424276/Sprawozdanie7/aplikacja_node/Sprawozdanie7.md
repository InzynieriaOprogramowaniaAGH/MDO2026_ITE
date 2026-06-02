# Sprawozdanie z Laboratorium 7 – Infrastruktura jako Kod (Jenkinsfile)


## 1. Cel laboratorium
Celem zajęć było przeniesienie logiki budowania aplikacji do repozytorium kodu w postaci deklaratywnego pliku `Jenkinsfile` (Pipeline as Code) oraz weryfikacja ścieżki krytycznej potoku zgodnie z listą kontrolną.

---

## 2. Realizacja listy kontrolnej Jenkinsfile

### 2.1. Przepis dostarczany z SCM (Pipeline from SCM)
Definicja potoku nie jest przechowywana na sztywno w ustawieniach obiektu Jenkins, lecz pobierana bezpośrednio z repozytorium GitHub. W konfiguracji zadania wskazano ścieżkę do pliku wewnątrz repozytorium.

* **Weryfikacja (Konfiguracja):** W ustawieniach potoku wybrano opcję "Pipeline script from SCM" i podpięto zdalne repozytorium Git wraz z odpowiednią gałęzią (`*/TM424276`).
* **Dowód:** ![Dowód - SCM Konfiguracja](/l7_screen/konfiguracja_scm.png)

* **Weryfikacja (Wykonanie):** Logi potoku udowadniają, że Jenkins pomyślnie pobiera kod (Checkout SCM), co potwierdza unikalny identyfikator rewizji Git widoczny przy udanym buildzie.
* **Dowód:** ![Dowód - SCM Build](/l7_screen/udany_build.png)


### 2.2. Gwarancja czystego środowiska (Brak cache'u)
Zapewniono, że każdy przebieg potoku korzysta z najnowszego kodu i świeżych zależności:
1. W poleceniach `docker build` zastosowano flagę `--no-cache`, wymuszając budowanie od zera.
2. W sekcji `post` potoku dodano krok `cleanWs()`, który bezwzględnie usuwa pliki z przestrzeni roboczej po zakończeniu pracy potoku.

* **Dowód (Brak cache'u w logach):** ![Dowód - No cache](/l7_screen/target_test.png)
* **Dowód (Czyszczenie Workspace):** ![Dowód - Clean Workspace](/l7_screen/clean.png)

### 2.3. Etap Build i Multi-stage Dockerfile
Wykorzystano wieloetapowy plik `Dockerfile`. Etap budowania dysponuje pełnym kodem źródłowym i tworzy dwa odrębne obrazy:
* **Obraz testowy (`target test`):** Zawiera pełne środowisko deweloperskie (BLDR).
* **Obraz wdrożeniowy (`target deploy`):** Odchudzona wersja produkcyjna.

* **Dowód (Multi-stage build):** ![Dowód - Obraz Deploy](/l7_screen/budowanie_obrazu.png)

### 2.4. Etap Test (Weryfikacja automatyczna)
Wewnątrz kontenera budującego wykonywane są automatyczne testy jednostkowe poleceniem `npm test`. Ich pomyślny wynik jest warunkiem koniecznym do kontynuacji potoku.

* **Dowód (Logi z testów):** ![Dowód - Testy](/l7_screen/nmp_test.png)

### 2.5. Etap Deploy i Smoke Test (Weryfikacja sandboxowa)
Przed ostateczną publikacją artefaktu, potok uruchamia wygenerowany kontener w środowisku izolowanym i weryfikuje jego responsywność.
* **Proces:** Kontener jest uruchamiany w tle (`docker run -d`), skrypt oczekuje 5 sekund na podniesienie usług, a następnie narzędzie `wget` odpytuje główny endpoint aplikacji na porcie 3000.
* **Wynik:** Serwer poprawnie zwrócił oczekiwaną odpowiedź w formacie JSON (ciąg znaków emoji), co jest absolutnym potwierdzeniem gotowości operacyjnej obrazu. Po teście kontener jest natychmiast usuwany.

* **Dowód (Wynik Smoke Test):** ![Dowód - Smoke Test](/l7_screen/smoke_test.png)

### 2.6. Etap Publish (Archiwizacja artefaktu)
Po pomyślnych weryfikacjach, obraz docelowy produkcyjny jest eksportowany do archiwum `.tar.gz` i dodawany do historii wywołań (builda) w systemie Jenkins jako gotowy artefakt.

* **Dowód (Zapis do pliku i archiwizacja):** ![Dowód - Publikacja](/l7_screen/publikacja_artefaktu.png)

---

## 3. "Definition of done"

Proces jest skuteczny, ponieważ na "końcu rurociągu" powstaje pełnoprawny, możliwy do wdrożenia artefakt (deployable). Poniżej znajduje się ostateczna weryfikacja założeń:

**1. Czy opublikowany obraz może być pobrany z Rejestru i uruchomiony w Dockerze bez modyfikacji?**
Tak. Opublikowany przez Jenkinsa artefakt (`express-api-v1.0.4.tar.gz`) to kompletny obraz kontenera. Po pobraniu i załadowaniu (`docker load`), można go uruchomić bez żadnych modyfikacji w kodzie czy dodatkowych instalacji. Obraz ma zaszyte w sobie wszystkie wymagane zależności produkcyjne (dzięki instrukcji `npm install --omit=dev` na etapie wdrożeniowym). Nie wysyłamy w świat rozwiązania "działającego tylko u nas".

**2. Czy dołączony do jenkinsowego przejścia artefakt, gdy pobrany, ma szansę zadziałać od razu na maszynie o oczekiwanej konfiguracji docelowej?**
Tak. Oczekiwaną konfiguracją docelową dla aplikacji skonteneryzowanej jest po prostu dowolny system operacyjny z zainstalowanym silnikiem Docker. Artefakt posiada prawidłowo skonfigurowany punkt wejścia (`CMD ["npm", "start"]`) oraz wyeksponowany port (`EXPOSE 3000`). Dowodem na jego natychmiastowe działanie "od razu" jest udany etap "Smoke Test", gdzie potok uruchomił aplikację w tle i z powodzeniem odebrał od niej odpowiedź HTTP.

---

## 4. Wnioski
Wdrożenie definicji potoku do repozytorium w formie pliku `Jenkinsfile` w pełni urzeczywistniło paradygmat "Pipeline as Code", znacząco poprawiając skalowalność i ułatwiając proces audytowania zmian. Skuteczne odseparowanie warstwy budującej od wdrożeniowej (Multi-stage) zminimalizowało wektor ataku i wagę artefaktu. Integracja zautomatyzowanego testu akceptacyjnego (Smoke Test) gwarantuje rzetelną walidację aplikacji bezpośrednio przed oddaniem jej do użytku.