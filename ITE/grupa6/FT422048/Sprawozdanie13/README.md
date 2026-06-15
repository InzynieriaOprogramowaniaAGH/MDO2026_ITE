# Sprawozdanie 13 - Shift-left: GitHub Actions

**Imię i Nazwisko:** Franciszek Tokarek  
**Numer albumu:** FT422048  

---

## 1. Wybór projektu i przygotowanie gałęzi
W ramach zadania sforkowano projekt open-source [Kilo](https://github.com/antirez/kilo) – miniaturowy i lekki edytor tekstu napisany w języku C.

Zgodnie z wymaganiami:
* Usunięto istniejące akcje z oryginalnego projektu.
* Utworzono nową gałąź o nazwie `ino_dev`.
* *Uwaga: Sforkowane repozytorium znajduje się pod adresem: https://github.com/FTokarek/kilo*

## 2. Implementacja GitHub Actions (Continuous Integration)
Zdefiniowano własną konfigurację akcji (plik `.github/workflows/build.yml`), która automatyzuje budowanie aplikacji natychmiast po wykonaniu instrukcji `git push`. 

Konfiguracja jest wyzwalana (`trigger`) wyłącznie dla modyfikacji na gałęzi `ino_dev`.

Zawartość zaimplementowanego pliku pipeline'u:
```yaml
name: C/C++ CI Build

on:
  push:
    branches: [ "ino_dev" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Pobranie repozytorium
      uses: actions/checkout@v4

    - name: Kompilacja kodu (Make)
      run: make

    - name: Zapisanie zbudowanego artefaktu
      uses: actions/upload-artifact@v4
      with:
        name: kilo-executable
        path: kilo
```
