# Sprawozdanie 9 - Pliki odpowiedzi dla wdrożeń nienadzorowanych

## 1. Pobranie ISO i utworzenie VM

Pobrano `Fedora-Server-dvd-x86_64-44-1.7.iso` i utworzono maszynę wirtualną w VirtualBox (2048 MB RAM, 20 GB dysk, NAT).

## 2. Pierwsza instalacja - pobranie pliku anaconda-ks.cfg

Przeprowadzono instalację graficzną Fedory 44 Server w celu uzyskania automatycznie wygenerowanego pliku odpowiedzi.

![](IMG/Zrzut%20ekranu%202026-05-28%20214409.png)
![](IMG/Zrzut%20ekranu%202026-05-28%20214527.png)
![](IMG/Zrzut%20ekranu%202026-05-28%20220313.png)
![](IMG/Zrzut%20ekranu%202026-05-28%20220445.png)

## 3. Modyfikacja pliku odpowiedzi

Plik `anaconda-ks.cfg` został zmodyfikowany o:
- repozytoria Fedory 44 (`url`, `repo`)
- `clearpart --all` - czyszczenie dysku
- hostname `fedora-l9`
- pakiety: `docker`, `docker-compose`, `wget`, `curl`
- sekcję `%post` z `systemctl enable docker` i serwisem `nginx-app.service`
- `reboot` na końcu instalacji

Plik opublikowano na GitHub Gist i podano instalatorowi przez parametr `inst.ks=`.

## 4. Instalacja nienadzorowana

Przy starcie instalatora w GRUB wciśnięto `e` i dopisano:
```
inst.ks=https://gist.githubusercontent.com/PawelJD/.../anaconda-ks.cfg
```

![](IMG/Zrzut%20ekranu%202026-05-29%20064249.png)
![](IMG/Zrzut%20ekranu%202026-05-29%20065835.png)
![](IMG/Zrzut%20ekranu%202026-05-29%20070003.png)

## 5. Uruchomiony system

System uruchomił się automatycznie po instalacji z hostname `fedora-l9`. Docker został włączony przy starcie, serwis `nginx-app` uruchamia kontener nginx:alpine na porcie 8080 po każdym starcie systemu.

![](IMG/Zrzut%20ekranu%202026-05-29%20083630.png)