# Sprawozdanie - zajęcia 13

### Fork wybranego repozytorium, clone

![1](obrazyLab13/7.png)
![2](obrazyLab13/1.png)

### Usunięcie istniejące workflows w projekcie

![3](obrazyLab13/2.png)

### Utworzenie gałęzi `ino_dev`

![4](obrazyLab13/3.png)

### Utworzenie własnego pliku workflow `build.yaml`

```yaml
name: Build

on:
  push:
    branches:
      - ino_dev
  workflow_dispatch:

jobs:
  quality:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm install

      - name: Check package integrity
        run: npm ls --depth=0

      - name: Count source files
        run: |
          mkdir artifacts
          find . -name "*.js" | wc -l > artifacts/js-files.txt

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: quality-report
          path: artifacts/

```

### Pokazanie utworzonej gałęzi, commit, push, akcja, artefakt

![5](obrazyLab13/4.png)
![6](obrazyLab13/6.png)
![7](obrazyLab13/5.png)
![8](obrazyLab13/8.png)

**Utworzony artefakt znajduje się w folderze `Sprawozdanie13`**
