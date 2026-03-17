# Sprawozdanie z zajęć 2 - Franciszek Tokarek (422048)
1. Cel zajęć
Zestawienie środowiska Docker, analiza obrazów, sprawdzenie izolacji procesów i stworzenie własnego Dockerfile.

2. Instalacja
Zainstalowano Dockera w wersji docker.io (zgodnie z instrukcją unikano Snapa). Dodano użytkownika do grupy docker, żeby móc używać komend bez sudo. Poprawność sprawdzono przez docker version.

3. Praca z obrazami
Pobrano i uruchomiono obrazy: ubuntu, fedora, alpine, mariadb, busybox, runtime, aspnet, sdk

Wnioski:

Rozmiary: Obrazy mocno się różnią – od alpine (ok. 9MB) po dotnet/sdk (ok. 942MB).

Kody wyjścia: Sprawdzono statusy przez docker ps -a, mariadb wyświetliła błąd spowodowany brakiem hasła, reszta przeszła poprawnie.

4. Izolacja procesów (PID 1)
W kontenerze ubuntu proces bash otrzymał PID 1. Na systemie macierzystym (hoście) ten sam proces był widoczny pod bardzo wysokim numerem PID, co pokazuje, jak Docker izoluje środowisko.

5. Dockerfile
Stworzono plik Dockerfile, który:

Bazuje na ubuntu:latest.

Instaluje narzędzie git.

Automatycznie klonuje repozytorium do folderu /app.
Zbudowano obraz i sprawdzono pliki komendą ls -la wewnątrz uruchomionego kontenera.

6. Czyszczenie
Po wykonaniu zadań usunięto wszystkie kontenery (docker rm) oraz obrazy (docker rmi), żeby nie zajmować miejsca na dysku.
