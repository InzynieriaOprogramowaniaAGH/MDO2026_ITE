# Sprawozdanie 3

Sprawozdanie dla [ćwiczenia trzeciego][ex3].

## Cel ćwiczenia

Konteneryzacja środowiska budowy oprogramowania: wykorzystanie
praktyczne Dockerfile i Docker Compose dla odtwarzalnego środowiska
budowy i separacji cyklu wdrażania oprogramowania.

## Sprzęt

Wykorzystano jednostkę fizyczną z zainstalowanym systemem Linux.

## Przebieg ćwiczenia

> ![NOTE]
> Dla animacji terminala wykorzystano oprogramowanie `asciinema`
> wraz z programem `agg` do ich konwersji do formatu GIF.

### 1. Wybór oprogramowania dla kompilacji spełniającego kryteria

Jako przykładowe oprogramowanie wybrałem [`pacman`] z trzech powodów:

1. [`pacman`] jest częścią infrastruktury krytycznej systemu operacyjnego,
   błędy w jego działaniu mają dla większości przypadków wpływ na stabilność
   całego systemu. Nie może być więc programem bez testów / sprawdzania kodu.

2. [`pacman`] też dobrze integruje się z budową na systemie `archlinux`,
   daje mi to też wymówkę na wykorzystanie właśnie tej dystrybucji jako
   bazy dla konteneryzacji – sami współutrzymujący system Arch Linux
   wykorzystują Arch Linux dla budowy i wdrażania w system menedżer pakietów
   [`pacman`], a sam [`pacman`] ma spory wpływ na ów proces wdrażania.

  - Trochę jak starszy `gcc` będący kompilatorem nowszego.

  - …choć [`pacman`] jako pakiet, a nie plik wykonywalny, nie jest akurat
    najważniejszym narzędziem dla procesu wdrażania, bardziej wydaje się nim
    być `makepkg` i szereg innych narzędzi wdrażających pakiet w repozytorium.

3. Korzystam z Arch Linux od dłuższego czasu, wykazanie nieumiejętności budowy
   menedżera pakietów byłaby rażącym brakiem wiedzy jako administrator systemu.

### 2. Budowa i testy w terminalu bez konteneryzacji (bezpośrednio na Arch Linux)

Pierwszym etapem, jest w ogóle sprawdzenie procesu budowy na maszynie fizycznej:

![Okno terminala 1](anim/01-no-container.gif)

Na załączonej animacji wykonano proces zaciągania repozytorium, konfiguracji procesu
budowy (posłużyłem się procesem i flagami, z jakich korzystają współutrzymujący
systemu Arch Linux), testowania i prostego uruchamiania przez sprawdzenie wersji
zbudowanej aplikacji w terminalu.

### 3. Budowa bezpośrednio w bazowym kontenerze

Po udanej budowie, podjęto próbę odtworzenia tych samych kroków, ale w kontenerze:

![Okno terminala 2](anim/02-simple-container.gif)

### 4. Automatyzacja procesu budowy:

Podjęto automatyzację procesu cyklu budowy i testowania w kontenerze to budowania
odpowiednich obrazów przez utworzenie plików `Dockerfile`:

- 📁️ [`main/Dockerfile`]: skupiającym się na głównym procesie budowy,
- 📁️ [`test/Dockerfile`]: dodatkowo rozszerzającym ów proces o wywołanie testów.

W oparciu o ów pliki przeprowadzono ponownie proces budowy obrazu i uruchamiania
kontenerów z gotowym

![Okno terminala 3](anim/03-dockerfile-container.gif)

### 5. Ujednolicenie procesu: `docker-compose`

Dla ujednolicenia procesu i możliwości sprawdzenia obu wariantów obrazów jednocześnie,
posłużono się plikiem [`docker-compose.yml`](docker/docker-compose.yml).

Ponownie przeprowadzono te same kroki, tym razem dzięki wykorzystaniu `docker-compose`
polecenie uruchomienia kontenera (i potrzebnej autobudowy obrazów) jest ograniczone
do polecenia `docker-compose up`:

![Okno terminala 4](anim/04-dockercompose.gif)

## Wnioski / dyskusja wyników

> Czy program nadaje się do wdrażania i publikowania jako kontener, czy taki sposób interakcji nadaje się tylko do builda?

Program wykorzystałem właściwie przy procesie budowy programu, tak więc jest jasnym,
że jego sama natura pozwala na konteneryzację. Mam też głęboką nadzieję, że
samym procesem udowowodniłem też, że ma to sens, nawet jeżeli sam system jest
zależny od komponentu: wdrażać można własne eksperymentalne (lub udoskonalone)
warianty menedżera pakietu, wychodzić nim poza zastosowania w systemie Arch Linux
(z czego co wiem CachyOS jest dobrym przykładem modyfikacji [`pacman`] dla własnych
zastosowań, także ma to sens praktyczny) lub też utrzymywać dla wersji testowych
w ramach systemu CI/CD, umożliwiając na stabilne środowisko testowe dla samego
menedżera pakietów.

> Opisz w jaki sposób miałoby zachodzić przygotowanie finalnego artefaktu:
>
>  * jeżeli program miałby być publikowany jako kontener - czy trzeba go
>    oczyszczać z pozostałości po buildzie?
>  * A może dedykowany *deploy-and-publish* byłby oddzielną ścieżką
>    (inne Dockerfiles)?
>  * Czy zbudowany program należałoby dystrybuować jako pakiet, np. JAR, DEB,
>    RPM, EGG?
>  * W jaki sposób zapewnić taki format? Dodatkowy krok (trzeci kontener)?
>    Jakiś przykład?

Najprostszą ścieżką (jako że ostatnio miałem okazję pracować nad konteneryzacją,
wciąż jednak jest to ścieżka WIP + bez testów i jednego wytyczonego programu)
by osiągnąć wszystkie te kroki (oczyszczanie, pakowanie w pakiet dystrybucyjny,
integracja z systemem) byłoby:

- Dla oczyszczania: umiejętne zarządzanie zależnościami (flaga `--asdeps` w
  Arch Linux, którą właśnie wykorzystałem już do częściowego oczyszczania).

  - Krok ten pozwala oznaczyć pakiety jako możliwe do usunięcia, gdy są
    tylko wymagane na proces budowy.

  - Warto zaznaczyć, że ta flaga stosowana jest przy automatycznym rozwiązywaniu
    i instalowaniu zależności dla odpowiednich pakietów.

- Korzystanie z standardowego formatu dla automatyzacji budowy i pakowania w
  Arch Linux: `PKGBUILD`.

  - Workflow budowy zmienia się: przechodzimy na narzędzie `makepkg`.

  - Arch Linux posiada kolekcję PKGBUILD dla pakietów w repozytorium,
    istnieje także gotowa kolekcja dla znanego oprogramowania w AUR.
  
  - `makepkg` pozwala na wpływ w przebieg budowy: bezpośrednio można
    w nim sterować, czy chcemy przeprowadzać testy, czy może lepiej
    jest je pominąć (gdy zależy nam tylko na budowie + deployment).
  
  - Dodatkowo, `makepkg` określa ściśle ścieżki, w których przekowywany
    jest stan przejściowy (źródła, organizacja w strukturze katalogowej
    systemu przy instalacji) zarówno w konfiguracji, jak i dla przypadków
    domyślnych: łatwo jest więc oczyszczać końcowo obraz.
  
- Oczyszczanie menedżera pakietów: usuwanie pakietów oprogramowania, zaciągniętych
  baz danych dla listy zależności, czyszczenie bazy danych kluczy GPG
  (Arch Linux podpisuje źródła i `makepkg` definiuje, że należy je sprawdzać
  zgodnie z kluczem publicznym programistów).

Tak więc, przy faktycznej realizacji *nie-labowej* wdrażania (nowej wersji?)
oprogramowania `pacman` w opublikowany obraz dla konteneryzacji, należałoby
rozważyć inne kroki i ścieżkę budowy pakietu, która by była dobrze dopasowana
dla oczekiwanych przez nas efektów.

---

Kończąc więc, mam nadzieję że moim podejściem, jak i samym sprawozdaniem, uzasadniłem,
jak przydatne jest wykorzystanie konteneryzacji w wdrażaniu, testowaniu czy budowaniu
oprogramowania. Laboratorium pozwoliło mi to przedstawić również w odniesieniu
wykorzystania konteneryzacji dla środowisk testowych (dla CI/CD) i możliwości
sprawdzenia praktycznego oprogramowania w piaskownicy, bez ryzyka uszkodzenia
głównego systemu operacyjnego i innych nieprzewidzianych efektów ubocznych.

<!-- Linki: --->
[ex3]: ../../../../READMEs/03-Class.md "Dockerfiles, kontener jako definicja etapu"
[`pacman`]: https://www.archlinux.org/pacman/ "Menedżer pakietów systemu Arch Linux"
[`main/Dockerfile`]: docker/main/Dockerfile
[`test/Dockerfile`]: docker/test/Dockerfile
