# Sprawozdanie 03 - Dockerfile i testowanie aplikacji

**Jan Wojsznis 422049**

---

## 1. Wybór repozytorium i uruchomienie lokalne

Do wykonania zadania wybrane zostało repozytorium aplikacji *Node.js*. Repozytorium zostało sklonowane lokalnie do katalogu roboczego, a następnie sprawdzono jego zawartość.

![Klonowanie repozytorium](./ss/3/clone.png)

Po sklonowaniu repozytorium zainstalowano zależności projektu przy użyciu `npm`.

![Instalacja zależności npm](./ss/3/npm.png)

Następnie uruchomiono testy aplikacji lokalnie i sprawdzono, czy projekt działa poprawnie poza kontenerem.

![Lokalne testy aplikacji](./ss/3/test.png)

---

## 2. Uruchomienie aplikacji w kontenerze interaktywnym

W kolejnym kroku uruchomiono kontener na bazie obrazu z *Node.js* w trybie interaktywnym.

![Uruchomienie kontenera interaktywnego](./ss/3/contener.png)

Wewnątrz kontenera doinstalowano wymagane narzędzia, a następnie ponownie sklonowano repozytorium.

![Klonowanie repozytorium w kontenerze](./ss/3/clone_contener.png)

Po sklonowaniu repozytorium w kontenerze wykonano instalację zależności, build oraz testy aplikacji. Pozwoliło to sprawdzić, czy projekt działa poprawnie również w środowisku kontenerowym.

![Build i testy w kontenerze](./ss/3/test_build_contener.png)

---

## 3. Przygotowanie plików Dockerfile

Następnie przygotowano własne pliki `Dockerfile`, zgodnie z treścią zadania.  
Pierwszy plik służy do zbudowania środowiska aplikacji i wykonania procesu build.  
Drugi plik bazuje na pierwszym obrazie i uruchamia testy aplikacji.

![Treść Dockerfile](./ss/3/dockerfile.png)

---

## 4. Budowanie obrazów

Na podstawie przygotowanego `Dockerfile` zbudowano pierwszy obraz Dockera.

![Budowanie pierwszego obrazu](./ss/3/build.png)

Po zakończeniu budowania sprawdzono lokalnie utworzony obraz.

![Pierwszy obraz Dockera](./ss/3/build_obraz1.png)

Następnie zbudowano drugi obraz, który bazował na pierwszym i był wykorzystywany do uruchamiania testów.

![Drugi obraz Dockera](./ss/3/build_obraz2.png)

---

## 5. Uruchomienie testów z drugiego obrazu

W ostatnim kroku uruchomiono kontener z drugiego obrazu. Kontener wykonał testy aplikacji, bez potrzeby ponownego budowania środowiska od podstaw. Dzięki temu pokazano, że drugi obraz korzysta z pierwszego i realizuje tylko etap testowania.

![Uruchomienie testów z drugiego obrazu](./ss/3/obraz2-test.png)