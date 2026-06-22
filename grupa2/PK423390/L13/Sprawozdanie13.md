# Sprawozdanie 13

## 1. Przygotowanie forka i gałęzi deweloperskiej

Sforkowano repozytorium `expressjs/express` (lekki framework Node.js, czysty JavaScript) do własnego konta jako `PawelJD/express`. Repozytorium sklonowano lokalnie, usunięto istniejące w nim workflowy GitHub Actions i utworzono dedykowaną gałąź `ino_dev` w celu odizolowania potoku CI/CD od głównej gałęzi kodu:

```bash
git clone https://github.com/PawelJD/express.git
cd express
rm -rf .github
git checkout -b ino_dev
git push --set-upstream origin ino_dev
```

## 2. Konfiguracja potoku

Utworzono plik `.github/workflows/quality-check.yml` z triggerem uruchamiającym automatyzację wyłącznie po wykryciu push'a na gałąź `ino_dev`:

```yaml
name: Code Quality Pipeline

on:
  push:
    branches:
      - ino_dev

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm install

      - name: Run lint
        run: npm run lint -- -f json -o eslint-report.json

      - name: Run tests
        run: npm test

      - name: Upload lint report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: quality-report
          path: eslint-report.json
          if-no-files-found: ignore
```

## 3. Kontrola jakości kodu zamiast builda

Express jest projektem czystego JavaScriptu, nie ma tu etapu kompilacji/builda jak w przypadku TypeScriptu. Zgodnie z zasadą Shift-left, pipeline skupiono na wczesnym wykrywaniu błędów: weryfikacji statycznej jakości kodu za pomocą lintera (`npm run lint`, ESLint) oraz uruchomieniu pełnego zestawu testów jednostkowych i akceptacyjnych (`npm test`, Mocha + Supertest).

Wynik lintera zapisywany jest do pliku `eslint-report.json` (flaga `-f json -o`), dzięki czemu może zostać opublikowany jako artefakt końcowy.

## 4. Pierwsze uruchomienie i napotkany problem

Po pierwszym pushu na gałąź `ino_dev` pipeline uruchomił się automatycznie, jednak zakończył się niepowodzeniem już na etapie `Setup Node.js`:

![Push na ino_dev - pierwszy fail pipeline'u](IMG/Zrzut%20ekranu%202026-06-19%20104222.png)


```
Error: Dependencies lock file is not found in /home/runner/work/express/express.
Supported file patterns: package-lock.json, npm-shrinkwrap.json, yarn.lock
```

![Szczegóły błędu - brak lockfile dla cache npm](IMG/Zrzut%20ekranu%202026-06-19%20104315.png)

Przyczyną był brak pliku `package-lock.json` w repozytorium, wymaganego przez opcję `cache: 'npm'` w akcji `setup-node`. Ponieważ lockfile nie był wymagany do działania samego pipeline'u, usunięto tę opcję z konfiguracji.

## 5. Weryfikacja po poprawce

Po usunięciu cache'owania npm pipeline uruchomiono ponownie. Wszystkie kroki, czyli instalacja zależności, lint i testy - zakończyły się powodzeniem:

![Pipeline zakończony sukcesem po poprawce](IMG/Zrzut%20ekranu%202026-06-19%20104543.png)

## 6. Publikacja artefaktu końcowego

Skonfigurowana akcja `upload-artifact` opublikowała raport z lintera (`eslint-report.json`) jako artefakt `quality-report`, dostępny bezpośrednio w panelu GitHub Actions po zakończeniu runu:

![Artefakt quality-report dostępny do pobrania](IMG/Zrzut%20ekranu%202026-06-19%20105457.png)

---

**Wnioski:**

Zastosowanie zasady Shift-left w GitHub Actions pozwala wykrywać problemy z jakością kodu (błędy lintera, niepowodzenia testów) natychmiast po każdym pushu, zanim zmiany trafią do głównej gałęzi projektu. Praca na dedykowanej gałęzi `ino_dev` zapewnia, że niesprawdzony, eksperymentalny pipeline jest całkowicie odizolowany od głównego kodu repozytorium. W projektach niewymagających etapu kompilacji (jak czysty JavaScript) sensowniejszym artefaktem końcowym od skompilowanego builda jest raport jakości kodu, a w tym przypadku wynik działania lintera, automatycznie pakowany i udostępniany do pobrania przez akcję `upload-artifact`.