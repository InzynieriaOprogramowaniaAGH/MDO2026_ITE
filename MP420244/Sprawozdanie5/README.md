# 1. Przygotowanie

Żeby rozpocząć pracę z usługą Jenkins należy uruchomić wcześniej utworzone kontenery `blueocean` i `entrypoint`:

![Działające kontenery](images/0.%20Działające%20kontenery.png)

Jenkins jest osiągalny pod adresem http://localhost:8080. Przejście pod ten adres ujawnia stronę konfiguracyjną:

![Strona powitalna Jenkins](images/1.%20Strona%20powitalna%20Jenkins.png)

Sugerowane pluginy zawierają wszystkie potrzebne narzędzia do wykonania zadań, więc wybrana jest ta opcja:

![Instalowanie pluginów](images/2.%20Instalowanie%20pluginów.png)

Następnie, po skonfigurowaniu konta i zalogowaniu się, pojawia się strona powitalna:

![Skonfigurowany Jenkins](images/3.%20Skonfigurowany%20Jenkins.png)

Od tego momentu można zacząć pracę nad projektami.

# 2. Freestyle projects

Freestyle project to prosta, uniwersalna instancja robocza, służąca przeważnie do wykonywania jednokrokowych czynności. Będzie ona wykorzystana do wykonania zadań związanych z uruchamianiem prostych skryptów.

## Wyświetlenie uname

Zadanie polega na wywołaniu polecenia `uname` za pomocą instancji. Wykonywane polecenia wpisuje się w polu **Execute shell** w ustawieniach projektu:

![Wyświetlanie uname](images/4.%20Wyświetlanie%20uname.png)

Następnie, realizując **Build** projektu, polecenie wykonuje się:

![Output uname](images/5.%20Output%20uname.png)

Jenkins daje możliwość uruchamiania skryptów podczas budowania projektu, co umożliwia przygotowywanie i konfigurowanie środowiska oraz pobieranie zmiennych, potencjalnie korzystnych podczas debuggowania.

## Weryfikacja godziny

Następne zadanie polega na odrzuceniu **Builda** kiedy godzina jest nieparzysta. Skrypt wygląda następująco:

![Sprawdzenie godziny](images/6.%20Sprawdzenie%20godziny.png)

Wykonanie w godzinę parzystą:

![Godzina parzysta](images/7.%20Godzina%20parzysta.png)

Wykonanie w godzinę nieparzystą:

![Godzina nieparzysta](images/8.%20Godzina%20nieparzysta.png)

Jenkins daje możliwość przerwania budowania przy wystąpieniu określonych warunków. Wprowadza to dodatkową warstwę weryfikacji poprawnego przebiegu budowy.

# 3. Pipeline

Pipeline jest jednostką roboczą, zaprojektowaną do sekwencyjnego wykonywania kroków tworzenia projektów. Dzięki nim atomizuje się rozwój oprogramowania na pojedyncze akcje: budowanie, testowanie, wdrażanie i publikację.

Zadaniem było sklonowanie repozytorium i zbudowanie jego Dockerfile.

## Skrypt

Skrypt pipeline różni się nieco od skryptu freestyle project. Posiada dodatkową składnię, dzielącą kod na bloki:
* `pipeline`: otacza cały wykonywany skrypt;
* `stages`: otacza etapy budowania;
* `stage`: oznacza pojedynczy etap;
* `steps`: zawiera kroki etapu;
* `script`: wykonuje skrypt *shell*.

Skrypt pipeline do zadania wygląda następująco:

![Skrypt pipeline](images/9.%20Skrypt%20pipeline.png)

Budowanie podzielone zostało na dwa etapy:

1. Klonowanie repozytorium:
Checkout wykonywany na branchu `MP420244` z repozytorium przedmiotowego.

2. Budowanie Dockerfile:
Wykonanie skryptu budującego plik na ścieżce brancha.

Podział na etapy jest o tyle korzystny, że kiedy zawiedzie jeden z nich, wiadomo gdzie szukać błędu.

## Budowanie

Budowanie stworzonego pipeline po raz pierwszy:

![Kroki pipaline nr 1](images/10.%20Kroki%20pipeline%20nr%201.png)

Całość wykonała się w przeciągu ok. 2 minut. Widać, że najbardziej kosztownym czasowo krokiem jest budowanie obrazu z Dockerfile (stanowi on prawie całość wykorzystanego czasu).


Budowanie po raz drugi:

![Kroki pipaline nr 2](images/11.%20Kroki%20pipeline%20nr%202.png)

Budowanie zakończyło się w ok. 5 sekund. Tworzenie obrazu zajęło tym razem ok. 3 sekundy. Postęp został zapisany w pamięci *cache* i przywołany podczas wykonania, co znacznie skróciło czas budowania.

## Pliki workspace

Pliki powstałe na skutek budowania projektu przechowywane są w kontenerze `endpoint` Jenkins na ścieżce: `/var/jenkins_home/workspace/(nazwa workspace)`. Można je podejrzeć, wykonując polecenia na kontenerze:

![Workspace kontenera Jenkins](images/12.%20Workspace%20kontenera%20Jenkins.png)

Jak widać, rapozytorium zostało sklonowane, a obraz - utworzony.

*logi budowania w osobnym folderze*