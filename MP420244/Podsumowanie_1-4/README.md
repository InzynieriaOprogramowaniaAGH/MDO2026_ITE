# Git

Git jest systemem kontroli wersji plików. Dzięki niemu możliwe jest szybkie zapisywanie zmian i zarządzanie nimi.

## Inicjalizacja (init, clone)

Rozpoczęcie pracy z git zaczyna się od stworzenia repozytorium. Można to zrobić na dwa sposoby:
* `git init`: tworzy nowe lokalne repozytorium;
* `git clone (adres)`: kopiuje repozytorium z sieci.

Po wywołaniu jednego z poleceń, w folderze roboczym pojawi się nowy folder **.git**, przechowujący wszystkie zmiany i konfiguracje. Od tego momentu można rozpocząć pracę w repozytorium.

## Praca (add, commit, push, pull)

Nowo utworzone lub zmodyfikowane pliki muszą zostać dodane przy pomocy polecenia `git add (plik)`. Wtedy git śledzi podane pliki i zapisuje ich stan. Żeby git przestał śledzić plik, należy wywołać polecenie `git reset (plik)`. Ogólny stan repozytorium można sprawdzić wykonując `git status`.

Przydatne:
* `git add .`: zaczyna śledzić wszystkie zmiany;
* `git reset`: przestaje śledzić wszystkie pliki.

Po wprowadzeniu dostatecznej ilości zmian, warto stworzyć nowy **commit**. Jest to punkt kontrolny, zapisujący wszystkie śledzone zmiany jako węzeł na drzewie. Wykonuje się to poleceniem `git commit`, do którego można dodać flagę `-m` z własną wiadomością.

Przydatne:
* `git commit -am (wiadomość)`: flaga `-a` dodaje do commit-a wszystkie nieśledzone zmiany.

Jeżeli wszystkie **commit-y** zawierają zmiany, które powinny zostać wprowadzone, realizuje się je dzięki `git push`. Jest to ostateczny krok utwierdzający cały postęp w repozytorium. Każdy **push** powinien zawierać tylko te zmiany, które warto wprowadzić, czyli te zmieniające kod na lepsze.

Żeby pobrać zmiany z repozytorium, stosuje się polecenie `git pull`, które wprowadza zmiany do lokalnego kodu. Pobranie zmian bez ich wprowadzenia jest możliwe dzięki poleceniu `git fetch`.

## Zarządzanie (branch, merge)

Dla lepszej kontroli nad wprowadzanymi zmianami, git oferuje drzewiastą strukturę zmian, która umożliwia jednoczesną pracę nad wieloma różnymi częściami projektu, bez nachodzenia na siebie nawzajem. Drzewo zmian jest podzielone na **branch-e** (gałęzie), które zapisują zmiany osobno. Tworzy się je przy pomocy polecenia `git switch -c (nazwa)`. Wadliwe gałęzie mogą zostać usunięte poleceniem `git branch -d (gałąź)`, a te przechowujące korzystne zmiany, mogą zostać wcielone do innych gałęzi poleceniem `git merge (gałąź)`.

Dzięki **branch-om** struktura repozytorium jest uporządkowana i czytelna.

Przydatne:
* `git branch`: wypisuje listę gałęzi;
* `git switch (gałąź)`: przechodzi na podaną gałąź;
* `git rebase (gałąź)`: wciela do obecnej gałęzi tą podaną, kiedy jest ona 'w tyle';
* `git merge --squash (gałąź)`: wciela zmiany z podanej gałęzi jako jeden **commit**.

## Git hook

Git **hook** jest lokalnym narzędziem, kontrolującym jakość wprowadzanych zmian. Przyjmuje formę skryptu, który uruchamia się w momencie zależnym od swojej nazwy (pre-commit: przed commit-em, pre-push: przed push-em) i akceptuje lub odrzuca operację, co zależy od zwróconej wartości (0 - akceptacja, każda inna - odrzucenie).

Stosowanie **hook-ów** jest przydatne w momencie, w którym trzeba ściśle kontrolować kod tak, żeby przestrzegał narzucone konwencje i standardy jak np. struktura kodu, nazywanie **commit-ów** itp. Mogą one również wykonywać drobne dynamiczne poprawki, jak np. usuwanie zbędnych białych znaków.

# SSH

Protokół SSH (secure shell) służy do zdalnej, bezpiecznej komunikacji między urządzeniami.

Żeby połączyć się z urządzeniem, musi ono być aktywne i z uruchomionym serwisem SSH. Do połączenia się służy polecenie `ssh (użytkownik)@(adres)`. Następnie, w zależności od konfiguracji, mogą zajść dwie metody walidacji: hasło lub klucz.

Hasło jest domyślną metodą walidacji w przypadku braku klucza. Dostęp jest udzielany po jego wpisaniu.

Klucz z kolei jest bardziej zaawansowaną metodą, która automatycznie przyznaje dostęp po odpowiednim skonfigurowaniu.
SSH polega na parze kluczy: public i private. Klucz publiczny jest umieszczany na urządzeniach, z którymi można się później połączyć za pomocą klucza prywatnego. Można o tym pomyśleć w następujący sposób: klucze publiczne to umieszczane na urządzeniach zamki, które można otworzyć za pomocą odpowiadającym im kluczy prywatnych.

Do generowania kluczy służy polecenie `ssh-keygen -t (metoda szyfrowania)`. Wygenerowane klucze powinny być przechowywane w specjalnym folderze `/ssh`, którego położenie różni się między systemami operacyjnymi.

Łącząc się z urządzeniem po raz pierwszy, wyświetli się komunikat ostrzegawczy z **fingerprint-em** jego klucza. Żeby zweryfikować, czy połączenie ma nastąpić z poprawnym urządzeniem, należy wywołać `ssh-keygen -lf (plik z kluczem)`, co wypisze **fingerprint** swojego klucza. Odcisk pasującej pary kluczy zawsze jest identyczny. Jeżeli nie pokrywa się on z tym na ostrzeżeniu, oznacza to, że klient próbuje połączyć się ze złym urządzeniem, czyli takim, które poprawnego klucza nie posiada. Weryfikacja odcisku nawiązaniem połaczenia zapobiega padnięciu ofiarą ataku "man-in-the-middle".

Kiedy połączenie SSH zostaje nawiązane, klient otrzymuje zdalny dostęp do terminala odległego urządzenia, tak jakby korzystał z niego bezpośrednio. Wygodnie można wtedy wykonywać polecenia, modyfikować pliki; ogółem prowadzić pracę na urządzeniu. Samo urządzenie zostanie dodane do listy znanych hostów, co przyśpieszy następny proces łączenia o brak ostrzeżenia.

# Docker

Docker jest narzędziem do uruchamiania tymczasowych paczek oprogramowania, zwanych kontenerami. Wykorzystywany jest głównie do testowania programów w kontrolowanym środowisku. Dzięki niemu można symulować pracę baz danych, API lub nawet całych systemów operacyjnych. Dobór środowiska kontenera niweluje problem potencjalnych różnic w działaniu kodu ze względu na inne systemy operacyjne i wersje programów współpracujących deweloperów.

## Obrazy

Obraz jest przepisem na kontener wybranego środowiska, jak klasa dla obiektu w języku programowania. Gotowe obrazy można wyszukiwać przy pomocy polecenia `docker search (obraz)` i pobierać poleceniem `docker pull (obraz)`.

Obraz może również zostać stworzony przez specjalny plik **Dockerfile**. Dzięki niemu można dodatkowo skonfigurować i rozbudować obraz z sieci. Służy do tego polecenie `docker build -f (ścieżka pliku) (nazwa obrazu)`. Dzięki **Dockerfile** można przygotować cały system plików i wywołać inicjujące polecenia nowopostawionego kontenera.

## Kontenery

Kontener jest instancją obrazu, jak obiekt instancją klasy. Jest to działający proces, na którym można wykonywać polecenia przy pomocy terminala i uruchamiać programy. Do zarządzania kontenerami służy szereg poleceń:
* `docker run (obraz)`: tworzy kontener na podstawie obrazu i uruchamia go; Pomocne flagi: `--rm` automatycznie kasuje kontener po skończeniu działania; `-it` zapewnia interaktywny system TTY; `--name (nazwa)` nadaje kontenerowi nazwę; `-p (port):(port)` ujawnia podany port kontenera;
* `docker exec (kontener) (polecenie)`: wykonuje polecenie wewnątrz kontenera;
* `docker start/stop (kontener)`: uruchamia/zatrzymuje kontener;
* `docker ps`: wypisuje listę działających kontenerów;
* `docker inspect (kontener)`: wypisuje informacje o kontenerze;
* `docker log (kontener)`: wypisuje co działo się w kontenerze;

## Woluminy

Kontenery z natury są tymczasowe. Do przenoszenia danych i zapisywania zmian w kontenerze służą woluminy. Są one przechowywane w plikach lokalnych i same przechowują w sobie pliki, zwykle pochodzące z kontenerów. Woluminy tworzy się poleceniem `docker volume create (nazwa)`.

Pliki trafiają z kontenera do woluminu za pomocą specjalnie zamontowanych folderów, będących dzielonymi między nimi. Usuwając kontener, wolumin zachowa w sobie dane, które normalnie zostałyby utracone. Folder montuje się, dodając do polecenia `docker run` następujące flagi:
* `--mount`: flaga montująca;
* `type=volume`: montowany jest wolumin;
* `src=(wolumin)`: nazwa woluminu;
* `dst=(ścieżka)`: ścieżka zamontowanego folderu, wewnątrz kontenera.

Przykładowe polecenie: `docker run --mount type=volume, src=my-volume, dst=/shared-dir/nested-dir -it --rm --name my-container fedora:latest`

Wywołanie tego polecenia stworzy i uruchomi `run` tymczasowy `--rm` kontener o nazwie *my-container* `--name`, będący instancją najnowszego dostępnego systemu *fedora*. Kontener będzie wyposarzony w interaktywny terminal `-it` i folder współdzielony `--mount` z woluminem `type` o nazwie *my-volume* `src` na ścieżce *~/shared-dir/nested-dir* `dst`.

## Sieci

Docker zawiera wbudowany system sieci, symulujący prawdziwą sieć. Dzięki sieciom można symulować system komunikujących się ze sobą komponentów jak np. baza danych z serwerem, API i klientem. Sieć tworzy się poleceniem `docker network create (nazwa)`. Kontenery dodaje się do sieci poleceniem: `docker network connect (sieć) (kontener)`.

Docker zapewnia domyślną sieć, z którą połączone są wszystkie kontenery, dlatego komunikacja między nimi jest zawsze możliwa bez wcześniejszej ręcznej konfiguracji.