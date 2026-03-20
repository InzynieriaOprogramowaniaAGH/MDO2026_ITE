## 1. Wybór oprogramowania i analiza wymagań

Do realizacji zadania wybrano projekt **Express.js**, będący jednym najpopularniejszych frameworkow webowym dla środowiska Node.js.

### Charakterystyka repozytorium:
* **Repozytorium:** `https://github.com/expressjs/express`
* **Licencja:** MIT (Otwarta, dopuszczająca swobodne kopiowanie i modyfikację).
* **Narzędzia budowania:** Projekt wykorzystuje `npm`. Plik `package.json` pełni tu rolę odpowiednika `Makefile`, definiując skrypty do instalacji zależności (`npm install`) oraz testowania.
* **Testy:** Projekt zawiera setki testów jednostkowych, które generują czytelny raport końcowy w terminalu.

![alt text](IMG/Zrzut%20ekranu%202026-03-20%20100737.png)
![alt text](IMG/Zrzut%20ekranu%202026-03-20%20101222.png)
![alt text](IMG/Zrzut%20ekranu%202026-03-20%20101402.png)

## 2. Budowa i testy

### Przebieg sesji interaktywnej:
1.  **Uruchomienie czystego kontenera:**

![alt text](IMG/Zrzut%20ekranu%202026-03-20%20101855.png)

2.  **Pobranie i budowanie:**

![alt text](IMG/Zrzut%20ekranu%202026-03-20%20102037.png)
![alt text](IMG/Zrzut%20ekranu%202026-03-20%20102147.png)

3.  **Uruchomienie testów:**

![alt text](IMG/Zrzut%20ekranu%202026-03-20%20102226.png)

## 3. Automatyzacja: Dockerfile (Build i Test)

Zaimplementowano dwa pliki Dockerfile, aby oddzielić etap przygotowania oprogramowania od etapu jego weryfikacji.

### Plik 1: `Dockerfile.build`
Ten plik tworzy obraz bazowy ze sklonowanym i zbudowanym oprogramowaniem.

![alt text](IMG/Zrzut%20ekranu%202026-03-20%20102847.png)
![alt text](IMG/Zrzut%20ekranu%202026-03-20%20102929.png)

### Plik 2: `Dockerfile.test`
Ten plik bazuje na obrazie zbudowanym powyżej i definiuje komendę uruchamiającą testy.

![alt text](IMG/Zrzut%20ekranu%202026-03-20%20103115.png)
![alt text](IMG/Zrzut%20ekranu%202026-03-20%20103236.png)
![alt text](IMG/Zrzut%20ekranu%202026-03-20%20103319.png)

## Różnica pomiędzy obrazem a kontenerem?
Obraz jest statycznym, niezmiennym wzorcem (szablonem) zawierającym system plików, kod aplikacji i biblioteki, natomiast kontener to jego uruchomiona, żywa instancja działająca jako odizolowany proces w systemie.