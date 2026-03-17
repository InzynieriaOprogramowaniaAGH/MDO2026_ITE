Wszystkie poniższe czynności zostały wykonane na maszynie wirtualnej Ubuntu Server za pomocą SSH.

# Zestawienie środowiska skonteneryzowanego

1. Zainstalowano Docker poprzez: \
Uaktualnienie apt: ![](./1.png) \
Zainstalowanie odpowiedniego package'a: ![](./2.png) \
Uruchomienie serwisu: ![](./3.png) \
Dodanie użytkownika do grupy która może pracować z dockerem: ![](./4.png)

2. Zarejestrowano konto na Dockerhub: \
![](./5.png)

3. Zapoznano się z obrazami: \
![busybox](./6.png) \
![ubuntu](./7.png) \
Sprawdzono ich rozmiary: \
![rozmiary obrazów](./8.png) \
oraz ich kody wyjścia: \
![kody wyjścia](./9.png) \
(Mariadb wymaga dodatkowej konfiguracji np. poprzez zmienną środowiskową, dlatego zwraca 1)

4. Uruchomiono kontener busybox interaktywnie (bez polecenia do wykonania busybox natychmiastowo się wyłącza): \
![interaktywny busybox](./10.png)

5. Uruchomiono kontener Ubuntu i zaktualizowano package:
![ubuntu aktualizacja](./11.png) \
W międzyczasie sprawdzono procesy dockera: ![procesy](./12.png)

6. Stworzono własnoręcznie Dockerfile dla obrazu pobierającego repozytorium: \

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git


WORKDIR /src
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git repo
WORKDIR /src/repo

CMD ["git", "branch"]
```

obraz zbudowano (z tagiem, aby był bardziej rozpoznawalny): \
![Build obrazu](./13.png)

oraz sprawdzono czy repozytorium rzeczywiście się sklonowało: \
![Sprawdzenie](./14.png)

7. Pokazano uruchomione kontenery: \
![Kontenery](./15.png) \
Oraz usunięto zakończone: \
![Usuwanie](./16.png) \

8. Wyczyszczono obrazy przechowywane w lokalnym magazynie: \
![Usuwanie wszystkich](./17.png)