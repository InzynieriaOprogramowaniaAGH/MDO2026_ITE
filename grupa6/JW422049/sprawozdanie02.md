# Sprawozdanie 02 - Docker

**Jan Wojsznis 422049**

---

## 1. Instalacja Dockera w systemie linuksowym

W systemie *Ubuntu 24.04* zainstalowano pakiet `docker.io` z repozytorium dystrybucji. Następnie sprawdzono poprawność instalacji oraz działanie usługi Dockera.

![Instalacja i uruchomienie Dockera](./ss/2/docker_install.png)

---

## 2. Rejestracja w Docker Hub i zapoznanie z obrazami

Założono konto w serwisie *Docker Hub* oraz zapoznano się z dostępnymi obrazami kontenerów.

---

## 3. Uruchomienie i sprawdzenie wybranych obrazów

Sprawdzono obrazy `hello-world`, `busybox`, `ubuntu`, `mariadb`, `runtime`, `aspnet` oraz `sdk` dla Microsoft .NET.  
Dla każdego obrazu wykonano uruchomienie, sprawdzono kod wyjścia oraz rozmiar obrazu. Tutaj pokazane tylko 3 obrazy

![Obrazy Docker](./ss/2/hello_world.png)

![Obrazy Docker](./ss/2/busy_box.png)

![Obrazy Docker](./ss/2/ubuntu.png)

---

## 4. Kontener z obrazu busybox

Uruchomiono kontener z obrazu `busybox`. Następnie połączono się z nim interaktywnie i wyświetlono numer wersji programu.

![Kontener busybox](./ss/2/busybox.png)

---

## 5. System w kontenerze

Uruchomiono kontener z obrazu `ubuntu` w trybie interaktywnym. Następnie pokazano proces `PID 1` w kontenerze, procesy Dockera na hoście oraz wykonano aktualizację pakietów. Po zakończeniu prac wyjście z kontenera wykonano poleceniem `exit`.

![System w kontenerze](./ss/2/system.png)

---

## 6. Własny Dockerfile

Przygotowano własny plik `Dockerfile` bazujący na obrazie `ubuntu:24.04`. W obrazie zainstalowano `git`, a następnie sklonowano repozytorium przedmiotowe. Obraz został zbudowany i uruchomiony w trybie interaktywnym, po czym zweryfikowano obecność repozytorium w kontenerze.

![Dockerfile i własny obraz](./ss/2/dockerfile.png)

---

## 7. Wyświetlenie i czyszczenie kontenerów

Wyświetlono wszystkie kontenery, także zakończone, a następnie usunięto zakończone kontenery z lokalnego środowiska.

![Kontenery Docker](./ss/2/kontenery.png)

---

## 8. Czyszczenie obrazów z lokalnego magazynu

Wyświetlono lokalne obrazy Dockera, a następnie usunięto nieużywane obrazy z lokalnego magazynu.

![Obrazy lokalne](./ss/2/obrazy_l.png)

---

## 9. Dodanie Dockerfile do repozytorium

Utworzony plik `Dockerfile` został dodany do katalogu sprawozdania w repozytorium na własnej gałęzi.
