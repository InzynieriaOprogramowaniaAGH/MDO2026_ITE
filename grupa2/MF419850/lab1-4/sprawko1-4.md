## Sprawozdanie

### 1. Laboratorium 1

Celem laboratorium było skonfigurowanie połączenia z Git, środowiskiem umożliwiającym stopniowe zamieszczanie zmian w kodzie, śledzenie ich i tworzenie wariantów poprzez rozgałęzianie

#### Utworzenie kluczy uwierzytelniających

Służyło do zapewnienia dostępu do repozytorium przez konto github z poziomu konsoli.

![](1.PNG)

#### Odgałęzianie

Należało utworzyć własną gałąź odgałęzioną od gałęzi grupy, dzięki temu można dodawać swoje zmiany na własną gałąź i dołączyć je do gałęzi grupy. Najważniejsze komendy: 
git clone - pobiera zdalne repozytorium.
git checkout <nazwa gałęzi> - przechodzimy na wybraną gałąź repozytium. flaga -b oznacza że towrzymy
nową gałąź (odgałęzienie). 
git pull <nazwa gałęzi> - aktualizuje naszą lokalną gałąź o zmiany wprowadzone do podanej gałęzi zdalnej. Konieczne do wykonania git push.

![](2.PNG)

#### Dodawanie zmian

Aby dodać swoje zmiany na przykład sprawozdanie, używa się następujący komend: 
git add - dodaje zmiany do repozytorium lokalnego, jako argumenty przyjmuje "." - dodając wszystko "nazwa pliku" lub "nazwa
folderu" które chcemy dodać.
git commit - przygotowuje zmiany do wysłania, zawiera opis. Napisany we wcześniejszej części ćwiczeń hook sprawia że opis zawsze musi zawierać inicjały i numer indeksu. Zastosowana
flaga -m pozwala dodać komentarz w histori. 
git push - dodanie zmian do repozytorium zdalnegoLaboratorium 4. Argumenty
origin <nazwa gałęzi> definiją, na którą gałąź dodajemy zmiany.

![](3.PNG)

#### Pull Request

Prośba o scalenie jednej gałęzi ze zmianami z drugiej. Wykonywana ręcznie na stronie.

![](4.PNG)

### Laboratorium 2

Celem laboratorium było opanowanie dockera, środowiska pozwalającego tworzyć kontenery na aplikacje i ich
zależności takie jak biblioteki, ustawienia, bazy danych gwarantując ich działanie bez względu na to gdzie są
uruchamiane.

#### Praca z obrazami

Należało pobrać i uruchomić wybrane obrazy, proces odbywał się za pomocą komend: Docker pull Docker run.

![](5.PNG)

Należało podłączyć sie pod kontenery busybox i wywołać numer serii.

![](6.PNG)

Oraz podłączyć się pod kontener fedora i zaprezentować PID.

![](7.PNG)

#### Budowanie Dockerfile

Należało stworzyć własny plik Dockerfile klonujący repozytorium grupowe a następnie go zbudować i
uruchomić.

![](8.PNG)

na własnym pliku: Docker build Docker run

### Laboratorium 3

#### Zdalne repozytorium

Wybrano i sklonowano repozytorium zawierające potrzebne funkcje. Zbudowano je i uruchomiono testy.
Wykorzystano make i make test.

![](9.PNG)

![](10.PNG)

#### kontener

Ponownie wykonano make i maketest ale wewnątrz kontenera ubuntu.

![](11.PNG)

Wykonano dwa pliki Dockerfile automatycznie wykonujące build(make) i test Następnie wykonano proces ponownie za ich pomocą.

![](12.PNG)

### Laboratorium 4

#### Docker

Utworzono woluminy wejściowy i wyjściowy: docker volume create mdo_input_volume docker volume create mdo_output_volume

![](13.JPG)

Następnie uruchomiono kontener z zamontowanymi woluminami ale bez git. brak środowiska git sprawił że projekt należało ręcznie skopiować z hosta. Projekt uruchomiono a jego wyniki zostały przekazane na wolumin wyjściowy.

![](14.JPG)

Kontener uruchomiono ponownie ale tym razem z git. Następnie analogicznie wykonano poprzedni proces z tym że projekt został pobrany przez git.

![](15.JPG)

#### Iperf3

Uruchomiono serwer i klienta Iperf w kontenerze, znaleziono IP serwera.

![](16.JPG)

Następnie powtórzono proces w sieci mostkowej. Połączono się z serwerem przez port 5201.

![](17.JPG)

#### SSH

Utworzono plik Dockerfile instalujący serwer SSH, zbudowano obraz ubuntu i połączono się z kontenerem SSH.

![](18.JPG)

![](19.JPG)

#### Jenkins

Utworzono sieć dla Jenkins i uruchomiono kontener Docker:dind. Następnie uruchomiono kontener Jenkins.

![](20.JPG)

![](21.JPG)
