# GitHub Actions

Skorzystam z forka repozytorium `express.js`, który wykonałem już podczas wcześniejszych zajęć. Do celów tego ćwiczenia stworzę nową gałąź (`ino_dev`), an której będę pracował.

<br/>

## Skopiowanie repozytorium i stworzenie gałęzi `ino_dev`

```bash
git clone git@github.com:kamilmarchewka/express.git
git checkout -b ino_dev
```

![github_actions_1](<./img/Screenshot 2026-06-20 at 12.04.59.png>)

Ustawiamy jeszcze gdzie mają iść zmiany, które wprowadzimy

```bash
git push -u origin ino_dev
```

![github_actions_2](<./img/Screenshot 2026-06-20 at 12.07.31.png>)

<br/>

## Usunięcie istniejących workflows

```bash
git rm ./.github/workflows/*
git commit -m "Remove existing workflows"
git push
```

![github_actions_3](<./img/Screenshot 2026-06-20 at 12.11.04.png>)

<br/>

## Stworzenie własnej akcji

```bash
mkdir -p ./.github/workflows/
touch ./.github/workflows/ino_build.yml
```

Teraz tworzymy akcję, która będzie reagować na push do gałęzi `ino_dev`. Będzie pobierać kod z repozytorium do runnera, instalować zależności, uruchamiać testy i tworzyć artefakt.

```yaml
name: INO Build

on:
  push:
    branches:
      - ino_dev

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout kodu
        uses: actions/checkout@v4

      - name: Ustaw Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22

      - name: Instalacja zależności
        run: npm install

      - name: Uruchomienie Testów
        run: npm run test

      - name: Upload artefaktów
        uses: actions/upload-artifact@v4
        with:
          name: express-build
          path: |
            lib/
            index.js
            package.json
          retention-days: 7
```

`retention-days` określa, jak długo artefakty będą przechowywane na serwerach GitHub. Po tym czasie zostaną automatycznie usunięte. Domyślna wartość to 90 dni.

Comitujemy zmiany i pushujemy do zdalnego repozytorium.

![github_actions_4](<./img/Screenshot 2026-06-20 at 12.29.28.png>)

<br/>

## Uruchomienie akcji

Po wykonaniu push do gałęzi `ino_dev` akcja automatycznie się uruchomiła. Możemy to sprawdzić w zakładce `Actions` naszego repozytorium.

![github_actions_5](<./img/Screenshot 2026-06-20 at 12.37.52.png>)

Jak widać wszystko udało się pomyślnie. Teraz możemy zobaczyć i pobrać artefakty, które zostały stworzone.

![github_actions_6](<./img/Screenshot 2026-06-20 at 12.52.39.png>)
