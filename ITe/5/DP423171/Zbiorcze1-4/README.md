# Zbiorcze sprawozdanie z ćwiczeń 1–4

Zbiorcze podsumowanie czterech laboratoriów poświęconych
praktycznym aspektom DevOps — od walidacji commitów w Git,
przez konteneryzację i budowę artefaktów, po zarządzanie
danymi woluminów, testy sieciowe i instalację systemu CI
(Jenkins).

## 1. Cele

Celem serii ćwiczeń było nabycie praktycznych umiejętności
potrzebnych do:

1. Poprawnego zarządzania repozytorium Git z użyciem hook'ów
   walidujących zmiany.

2. Poznania i konfiguracji środowiska konteneryzacji (Docker),
   w tym trybu rootless.

3. Tworzenia odtwarzalnych środowisk budowy i testów przy
   użyciu `Dockerfile` i `docker-compose`.

4. Wydzielenia etapów budowy i testowania oraz optymalizacji
   obrazów i zarządzania zależnościami.

5. Współdzielenia danych między kontenerami (woluminy i punkty
   montowania typu `bind`), zrozumienia stosu sieciowego
   kontenerów (`iperf`) oraz uruchomienia instancji Jenkins w
   kontenerze jako przykładu środowiska CI na własnym serwerze.

## 2. Poruszone zagadnienia teoretyczne

### Git

#### Polecenia

- `git clone` — sklonowanie repozytorium.
- `git add` / `git rm` — przygotowanie zmian do commita.
- `git commit` — zapis lokalnych zmian z opisem.
- `git push` / `git pull` — synchronizacja ze zdalnym repo.
- `git checkout` — przełączanie gałęzi.
- `git merge` / `git rebase` — łączenie historii.

#### Strategie przyłączania (`merge`) zmian:

- ***Fast-foward***: dodawanie nowych zmian dla wspólnej bazy.

- **Zmiana bazy** (`rebase`): przyłączanie przez uwspólnianie
  commitów bazowych, niezalecane dla głównego brancha jako że
  wymaga zwykle *force push* (ale często używane dla branchy
  pobocznych). Strategia `rebase` pozwala zachować liniową
  historię przy różnicach w bazie commitów między branchem
  głównym a pobocznymi.

- **Klasyczne przyłącznie**: skutkuje commit'em przyłączającym,
  który pozwala na modyfikację historii bez wpływu na zmianę
  bazy. Nierzadko chce się uzyskać liniową historię, sam
  GitHub posiada opcję blokady zmian wpływających na liniowość
  historii, także może być niestosowany dla przypadku takiej
  polityki.

### Hooki

Funkcją hook'ów jest umożliwienie definicji lokalnych polityk
dla walidacji stanu repozytorium na poszczególnych etapach,
przy wywoływaniu poleceń `git`.

#### Typowe (przydatne) hooki:

- `pre-commit` — sprawdzenia przed wykonaniem commita.
- `commit-msg` — walidacja treści wiadomości commita.
- `pre-push` — uruchamianie testów przed wysłaniem na serwer.

#### Implementacja i dystrybucja

- Hooki zwykle umieszczamy w katalogu `.git/hooks` jako pliki
  wykonywalne lub instalujemy je skryptem w repozytorium.

- Dodatkowo zaimplementowałem hook samo-instalujący, który
  *inteligentnie* jest w stanie zrozumieć, że przy wykonaniu
  z błędnej ścieżki, powinien podjąć próbę instalacji.

- W praktycze inżynierskiej istnieją takie rozwiązania jak
  `husky` (dla Node.js), które instalują hook'i w ramach
  pracy z zależnościami kodu.

### Konteneryzaca (Docker)

Docker to platforma do tworzenia, wdrażania i uruchamiania
aplikacji w kontenerach. Kontenery to lekkie, przenośne,
samowystarczalne jednostki, które zawierają wszystko, co
potrzebne do uruchomienia aplikacji: kod, środowisko
wykonawcze, narzędzia systemowe, biblioteki i ustawienia.
Dzięki Dockerowi możliwe jest izolowanie aplikacji od
środowiska hosta oraz zapewnienie spójności działania
niezależnie od miejsca wdrożenia.

#### Polecenia

- `docker build` — budowanie obrazu Docker na podstawie
  `Dockerfile`.

- `docker run` — uruchomienie kontenera z obrazu.

- `docker ps` — wyświetlenie uruchomionych kontenerów.

- `docker stop` / `docker start` — zatrzymywanie/uruchamianie
                                   kontenerów.

- `docker container prune` — usuwanie wszystkich zatrzymanych
                             kontenerów.

- `docker image prune` — usuwanie nieużywanych obrazów
                         Dockera.

- `docker images` — wyświetlenie dostępnych obrazów.

- `docker exec` — wykonywanie poleceń wewnątrz działającego
                  kontenera.

- `docker-compose up` — uruchamianie i zarządzanie aplikacjami
              wielokontenerowymi z pliku `docker-compose.yml`.

- `docker-compose down` — zatrzymywanie i usuwanie kontenerów
                        zdefiniowanych w `docker-compose.yml`.

#### Reprodukowalna budowa i separacja etapów

Odtwarzalność budowy wymaga, aby zawsze, niezależnie od
środowiska i czasu, ten sam kod źródłowy prowadził do
identycznego artefaktu. Jest to kluczowe dla spójności
wdrożeń i łatwego debugowania. W kontekście Dockera,
odtwarzalność uzyskuje się poprzez ścisłe definiowanie
środowiska i zależności w plikach `Dockerfile`.

Separację etapów wdrożono za pomocą wieloetapowych budowań
(`multi-stage builds`) w pojedynczych `Dockerfile`'ach,
gdzie każdy etap odpowiada za inną część procesu (np.
kompilacja, testowanie, pakowanie). Następnie, do
koordynacji i uruchomienia wielu usług (kontenerów)
składających się na aplikację, zastosowano `docker-compose`.
Umożliwia to zdefiniowanie całego stosu aplikacji w jednym
pliku `docker-compose.yml`, zarządzając zależnościami,
sieciami i woluminami między kontenerami, co gwarantuje
odtwarzalne środowiska zarówno budowy, jak i uruchamiania.

#### Woluminy i zarządzanie danymi

Woluminy Docker to preferowany mechanizm do utrwalania
danych generowanych i używanych przez kontenery, a także
do współdzielenia danych między kontenerami a hostem.
Zapewniają trwałość danych, nawet po usunięciu kontenera,
oraz izolację od systemu plików kontenera.

Prócz woluminów możliwe jest też stosowanie punktów
montowania typu `bind`, które *mapują* wybraną ścieżkę
systemu plików na ścieżkę jako punkt montowania w
kontenerze. Umożliwia to na łatwy dostęp do danych
hosta z poziomu konteneru. Woluminy są przy tym jednak
mniej zależne od systemu pliku hosta oraz łatwiejsze
dla współdzielenia między kontenerami.

Ich zastosowanie pozwala na wydajne zarządzanie stanem
aplikacji, utrzymywanie danych pomiędzy restartami
kontenerów, a także wymianę informacji między hostem a
kontenerem, zachowując jednocześnie bezpieczeństwo i
przenośność.

#### Sieć kontenerów i testy wydajności

Docker zapewnia elastyczny system sieciowy, umożliwiający
kontenerom komunikację ze sobą oraz ze światem zewnętrznym.
Domyślnie kontenery są łączone do sieci typu `bridge`, ale
często tworzy się dedykowane sieci, aby zapewnić izolację
i lepszą kontrolę nad przepływem danych. W ćwiczeniach
wykorzystano narzędzie `iperf` do testowania wydajności
sieciowej między kontenerami, co pozwoliło na zrozumienie
wpływu konfiguracji sieciowej na przepustowość i opóźnienia.
Dedykowane sieci są tworzone, aby zapewnić izolację między
różnymi grupami kontenerów, poprawić bezpieczeństwo, a także
umożliwić łatwiejszą konfigurację reguł komunikacji.

### CI w kontenerach (Jenkins)

Jenkins to otwarte oprogramowanie serwera automatyzacji,
szeroko wykorzystywane w praktykach Continuous Integration
(CI) i Continuous Delivery (CD). Umożliwia automatyzację
procesów tworzenia oprogramowania, takich jak kompilacja,
testowanie, raportowanie i wdrażanie, co znacząco przyspiesza
cykl dostarczania wartości. Dzięki bogatemu ekosystemowi
wtyczek, Jenkins jest niezwykle elastyczny i może integrować
się z różnorodnymi narzędziami i technologiami. Może być
uruchamiany na maszynach wirtualnych, fizycznych, a także
w kontenerach, co zapewnia przenośność i skalowalność.

W ramach ćwiczeń poruszono prostą instalację Jenkins w
środowisku skonteneryzowanym przez pomocnika DND (Docker in
Docker) oraz wstępną konfigurację serwera CI przez aplikację
webową, w najbardziej podstawowym tego zakresie.

## 3. Wnioski końcowe

1. Reprodukowalność jest kluczowa — konteneryzacja oraz
   skrypty budowy (`Dockerfile`, `docker-compose`) zwiększają
   przewidywalność środowiska budowy i testów.

2. Modularność pipeline'u (oddzielne obrazy/etapy) upraszcza
   optymalizację, pozwala na definicję wariantów względem
   zmiennych wymagań i zmniejsza rozmiar obrazów produkcyjnych.

3. Woluminy są świetną metodą współdzielenia danych i stanu
   między kontenerami, a także i hostem. Ich zastosowanie,
   czy to w cache czy przepływie danych z/od kontenera,
   znacząco rozszerza możliwości konteneryzacji przy (dalej)
   zapewnieniu bezpiecznego środowiska *piaskownicy*.

4. Uruchomienie narzędzi do testów sieciowych i CI w
   kontenerach jest praktyczne; produkcyjne wdrożenie
   powinno uwzględniać backup i polityki zabezpieczeń.

5. Technologia Jenkins jest świetnym, modularnym i otwartym
   środowiskiem CI.

  - Jest otwarty, w przeciwieństwie do GitHub Actions.
  - Jest niezależny od serwera Git.
  - Alternatywnie, słyszałem o Woodpecker CI, które stosowane
    jest dla *zastąpienia GitHub Actions* na platformach
    typu Codeberg.

---

Podsumowując, seria ćwiczeń połączyła teorię z praktyką:
od kontroli jakości commitów, przez budowę odtwarzalnych
środowisk w kontenerach, po zarządzanie danymi i testami
sieciowymi oraz uruchomienie podstawowego CI. Zdobyte
umiejętności tworzą solidną podstawę do projektowania
powtarzalnych i bezpieczniejszych procesów CI/CD i stanowią
podstawę poznanych praktyk dla stosowania DevOps w
projektach oprogramowania.
