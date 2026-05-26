# Kubernetes

Kontynuacja ćwiczeń z Kubernetesa.

## Nowe obrazy

Utworzono trzy pary obrazów komponentów aplikacji, o różnych tagach:
* `latest` dla najnowszej wersji oprogramowania;
* `old` bazujące na starszych wersjach obrazów;
* `bad` wywołujących runtime error.

![Obrazy Dockera](images/1.%20Obrazy%20Dockera.png)

## Konfiguracja wdrażania

Po zbudowaniu obrazów, wykonywany był ciąg poleceń `kubectl apply` wykonujący wdrożenia o różnych ilościach replik:

**8 replik podów**

![Apply 8 replik](images/2.%20Apply%208%20replik.png)

![Pody 8 replik](images/3.%20Pody%208%20replik.png)

Baza danych nie posiada replik ze względu na jej osobliwy charakter przy występowaniu wielu instancji.

**1 replika podów**

![Apply 1 replika](images/9.%20Apply%201%20replika.png)

![Pody 1 replika](images/4.%20Pody%201%20replika.png)

**0 replik podów**

![Pody i inne 0 replik](images/5.%20Pody%20i%20inne%200%20replik.png)

**4 repliki podów**

![Pody 4 repliki](images/6.%20Pody%204%20repliki.png)

Łatwość w zmienianiu wielkości zestawów replik wpływa korzystnie na skalowalność aplikacji.

Po przywróceniu ilości replik na 4, zmieniano wersję obrazów komponentów:

**Obraz z tagiem 'old'**

![Apply start obraz](images/10.%20Apply%20stary%20obraz.png)

![Pody stary obraz](images/7.%20Pody%20stary%20obraz.png)

**Obraz z tagiem 'bad'**

![Pody wadliwy obraz (chain-apply)](images/14.%20Pody%20wadliwy%20obraz.png)

Mimo występowania 4 replik każdego poda, wdrożenie nie przebiegło pomyślnie i przerwało wykonywanie. Jeden z podów backendu jest zatrzymany na statusie `Terminating`. Dzieje się tak dlatego, że deployment jest wadliwy (przyczyną są złe obrazy), więc Kubernetes nie zajmuje się dokończeniem go. Chroni to aplikację przed szkodliwymi zmianami.

![Status wdrożenia złego obrazu](images/11.%20Status%20wdrożenia%20złego%20obrazu.png)

Kolejnym krokiem w procesie rozwoju oprogramowania powinno być cofnięcie wdrożeń do poprzedniego stanu poprzez `kubectl rollout undo`:

![Rollout undo](images/13.%20Rollout%20undo%20full.png)

Sytuacja wygląda inaczej, gdy wadliwy deployment jest pierwszym w kolejności:

![Pody wadliwy obraz](images/8.%20Pody%20wadliwy%20obraz.png)

Wszystkie pody zostają utworzone i ciągle kończą wykonywanie błędem. Kubernetes nie ma historii wdrażania, z którą mógłby porównać wdrożenie, więc zostaje ono doprowadzone do końca. Jest to dobre zachowanie, gdyż następny deployment mógłby zawierać pozytywne zmiany, naprawiające problem, przez co odnawianie klastra nie byłoby konieczne.

Kolejnym przydatnym poleceniem jest `kubectl rollout history`:

![Rollout history](images/15.%20Rollout%20history.png)

Wyświetla ono historię podanego wdrożenia. Luka na zdjęciu spowodowana jest niedokończonym wdrożeniem wadliwych obrazów.

## Skrypt kontrolny

Przygotowany został skrypt do weryfikowania przebiegu deploymentów. Poniżej jest wynik skryptu uruchomionego po wdrożeniu wadliwych obrazów:

![Deployment check](images/16.%20Deployment%20check.png)

Baza danych jest wdrażana poprawnie, ponieważ używa domyślnego obrazu `mysql` i nie bierze aktywnego udziału w laboratorium.

Odtworzono stan wdrożenia obrazu z tagiem `old` i wywołano skrypt ponownie, w celu przygotowania środowiska do wykorzystania strategii wdrażania.

![Fresh deployment check](images/17.%20Fresh%20deployment%20check.png)

## Strategie wdrażania

Dzięki strategiom wdrażania możliwe jest aktualizowanie programu uruchomionego przez Kubernetes bez odtwarzania struktury klastra od nowa.

### Recreate

Aby zastosować strategię **Recreate** należy wprowadzić do deploymentu pole `strategy` w pliku YAML i przypisać mu wartość `Recreate`. Cały proces strategii przebiega automatycznie:

![Recreate check](images/18.%20Recreate%20check.png)

Przeprowadzono również `rollout undo` na deploymencie:

![Rollout undo all](images/19.%20Rollout%20undo%20all.png)

Strategia odtwarzania usuwa stare pody i zastępuje je nowymi, co powoduje przerwę w udostępnianiu usług przez program. Recreate jest proste do zaimplementowania, ale należy się liczyć z występowaniem downtime-u.

### Rolling update

Strategię **Rolling update** implementuje się w identyczny sposób co strategię Recreate, tzn. przez pole `strategy` w pliku YAML. Pozwala ono zdefiniować dodatkowe parametry, w tym:
* `maxUnavailable`: największa ilość niedostępnych starych podów deploymentu;
* `maxSurge`: największa ilość dodatkowych nowych podów deploymentu.

Oba pola mogą przyjmować wartości zarówno liczbowe jak i procentowe, zaokrąglając w dół przy niecałkowitych wynikach.

![Rolling update check](images/20.%20Rolling%20update%20check.png)

Strategia przekładania działa podobnie do strategii Recreate, jednak jej proces jest mniej nagły. Pody stopniowo są wymieniane na nowe, co zapobiega wystąpieniu przerwy w dostawie usług.

### Canary Deployment

Ta strategia nie jest wbudowana w Kubernetesa - należy ją zaimplementować samodzielnie. Robi się to przez zdefiniowanie nowych deploymentów w pliku YAML, będących "kanarkami". Są to nowe pody, które zostaną dołączone do klastra w celu zbadania ich zachowania.

Ważne jest to, żeby nowe deploymenty dzieliły etykiety ze starymi. Umożliwia to równe ich traktowanie przez serwisy, zarządzające siecią.

![Canary check](images/21.%20Canary%20check.png)

Jeżeli nowy pod zachowuje się prawidłowo, można wymienić wsztstkie stary pody na nowe:

![Canary fin check](images/22.%20Canary%20fin%20check.png)

Strategia ta różni się od pozostałych tym, że nie wymienia się całego systemu od razu. Dołącza się najpierw kilka podów do programu w celu ich zweryfikowania, po czym można podjąć decyzję o dalszym przebiego rozwoju oprogramowania.

### Krótkie podsumowanie strategii

**Recreate**
* wymiana wszystkich komponentów;
* łatwe do zaimplementowania;
* przerwa w dostawie usług.
**Rolling update**
* stopniowa wymiana wszystkich komponentów;
* zapewnienie ciągłości pracy programu.
**Canary Deployment**
* przetestowanie oprogramowania w aktywnym środowisku;
* wypróbowanie nowego komponentu;
* niezauważalne cofnięcie testowanego poda.