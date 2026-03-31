# Laboratorium nr.1
Celem laboratorium było tylko zestawienie maszyny wirtualnej i zaimplementowanie odpowiedniego git hooka.

Git hook to skrypt wykonywany gdy zostaje wykonana dana czynność w gicie, hooki są zapisane w folderze .git/hooks

# Laboratorium nr.2
Celem laboratorium było zestawienie środowiska skonteneryzowanego do pracy nad CI.

## Wprowadzono nowe pojęcia:

1. Docker - platforma do konteneryzacji, pozwalająca na izolowanie aplikacji wraz z zależnościami w lekkich, przenośnych środowiskach (kontenerach). Umożliwia łatwe budowanie, uruchamianie i zarządzanie kontenerami.
2. Docker Hub - publiczny rejestr obrazów Docker, gdzie można wyszukiwać, pobierać i udostępniać gotowe obrazy (np. ubuntu, mariadb). Służy jako centralne repozytorium dla obrazów kontenerów.
3. Obrazy Dockera (hello-world, busybox, ubuntu, fedora, mariadb, runtime, aspnet, sdk dla .NET) - szablony tylko do odczytu, zawierające system plików i konfigurację potrzebną do uruchomienia kontenera. Różnią się rozmiarem, przeznaczeniem (np. runtime vs SDK) i zawartością.
4. Dockerfile - skrypt zawierający instrukcje (np. FROM, RUN, COPY) do budowania obrazu Docker.

## Poruszone polecenia:

1. docker --version - sprawdza wersję zainstalowanego Dockera.
2. docker pull [obraz] - pobiera obraz z rejestru (np. docker pull hello-world).
3. docker run [obraz] - tworzy i uruchamia kontener z danego obrazu.
4. docker ps - pokazuje uruchomione kontenery.
5. docker ps -a - pokazuje wszystkie (również zakończone).
6. docker stop [kontener] - zatrzymuje działający kontener.
7. docker start [kontener] - uruchamia zatrzymany kontener.

# Laboratorium nr. 3
Celem laboratorium było stworzenie powtarzalnego środowiska do kompilacji i testowania programu otwartoźródłowego.

## Poruszone pojęcia:
Systemy budowania (automake, configure, itp.) - narzędzia do automatyzacji procesu kompilacji i zarządzania zależnościami w różnych ekosystemach (C/C++, JavaScript, Java, .NET itp.). W zadaniu wymagane do zbudowania wybranego oprogramowania open source.

## Poruszone polecenia:
1. docker run -it - uruchamia kontener interaktywnie (dołączając TTY).

# Laboratorium nr.4
Celem laboratorium było wprowadzenie pojęć woluminów oraz sieci dla kontenerów.

## Wprowadzono nowe pojęcia:
1. Woluminy Docker (volumes, bind mounts) - mechanizmy trwałego przechowywania danych niezależnie od cyklu życia kontenera. Woluminy są zarządzane przez Dockera, bind mounty wskazują na dowolny katalog na hoście. Używane do udostępniania kodu źródłowego (wolumin wejściowy) i zbierania artefaktów (wolumin wyjściowy).
2. Sieci Docker (network create, mostkowa) - umożliwiają komunikację między kontenerami. Domyślna sieć mostkowa pozwala na łączność przez IP; własna sieć mostkowa z wbudowanym DNS umożliwia komunikację poprzez nazwy kontenerów.
3. Jenkins - serwer CI/CD do automatyzacji budowania, testowania i wdrażania oprogramowania. W zadaniu instalowany jako kontener z pomocnikiem DinD (Docker in Docker), co pozwala mu uruchamiać kontenery Docker wewnątrz własnego środowiska.
4. DinD (Docker in Docker) - technika polegająca na uruchomieniu demona Dockera wewnątrz kontenera. Używana w scenariuszach CI, gdzie kontener Jenkins potrzebuje budować i uruchamiać inne kontenery.

## Poruszone polecenia:
1. docker network create [nazwa] - tworzy sieć mostkową.
2. docker volume create [nazwa] - tworzy wolumin.
3. parametr -v $(pwd)/kod:/src - załącza wolumin