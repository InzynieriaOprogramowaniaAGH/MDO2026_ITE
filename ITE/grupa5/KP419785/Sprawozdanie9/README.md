# SPRAWOZDANIE 9

## Środowisko uruchomieniowe

- System operacyjny (maszyna główna): Ubuntu 24.04 LTS – maszyna wirtualna `devops`
- System operacyjny (maszyna docelowa instalacji): Fedora Linux 44 (Forty Four) – nowa maszyna wirtualna `fedora-portfinder`
- Silnik wirtualizacji: Oracle VirtualBox
- Metoda dostępu: Konsola VirtualBox (instalacja nienadzorowana) + SSH po instalacji
- Narzędzie instalacji: Anaconda 44.30-2.fc44 z plikiem odpowiedzi Kickstart
- Projekt: portfinder (artefakt `portfinder-12.tar.gz` z poprzednich laboratoriów)
- Edytor kodu: GNU nano / Visual Studio Code (Remote SSH)

## 1. Przygotowanie serwera HTTP z artefaktem

Przed rozpoczęciem instalacji nienadzorowanej konieczne było udostępnienie dwóch zasobów przez sieć:
- pliku odpowiedzi `portfinder-ks.cfg`
- artefaktu `portfinder-12.tar.gz` (obraz Docker)

Na maszynie `devops` uruchomiono prosty serwer HTTP przy użyciu wbudowanego modułu Pythona. Serwer nasłuchuje na porcie 8000 i serwuje zawartość bieżącego katalogu:

```
    cd ~
    python3 -m http.server 8000 &
```

![2](<img/Zrzut ekranu 2026-05-05 022732.png>)

Po poprawnym uruchomieniu serwer wyświetlił komunikat `Serving HTTP on 0.0.0.0 port 8000`, co oznacza, że jest dostępny dla wszystkich interfejsów sieciowych pod adresem `http://192.168.1.34:8000/`.

## 2. Przygotowanie pliku odpowiedzi Kickstart

Plik odpowiedzi wymaga podania hasła w formie zaszyfrowanej. Do wygenerowania hasha SHA-512 użyto Pythona:

```
    python3 -c "import crypt; print(crypt.crypt('mojehaslo', crypt.mksalt(crypt.METHOD_SHA512)))"
```

![3](<img/Zrzut ekranu 2026-05-05 172735.png>)

Wynikiem jest długi hash w formacie `$6$...`, który trafia bezpośrednio do dyrektywy `rootpw --iscrypted` w pliku kickstart. 

Plik odpowiedzi stworzono w edytorze nano. Zawiera on kompletną konfigurację instalacji systemu oraz sekcję `%post` odpowiedzialną za instalację Dockera i pobranie artefaktu:

```
    nano ~/portfinder-ks.cfg
```

Widok pliku w edytorze:

![5](<img/Zrzut ekranu 2026-05-05 022426.png>)

## 3. Uruchomienie instalacji nienadzorowanej

Przy pierwszej próbie instalacji parametr `inst.ks` wskazywał bezpośrednio na `http://192.168.1.34:8000/portfinder-ks.cfg`, jednak instalator zwrócił komunikat:

```
    Kickstart file /run/install/ks.cfg is missing.
```

![6](<img/Zrzut ekranu 2026-05-05 023005.png>)

Błąd wynikał z tego, że serwer HTTP nie był jeszcze uruchomiony w momencie startu instalatora lub plik nie był dostępny pod podanym URL-em. Problem rozwiązano przez upewnienie się, że serwer HTTP działa i plik jest dostępny, a następnie ponowne uruchomienie maszyny z poprawnym parametrem.

### Wskazanie pliku kickstart przez GRUB

Po uruchomieniu VM z płyty ISO Fedory 44 Server DVD, w menu bootloadera GRUB naciśnięto klawisz `e` w celu edycji parametrów startowych. Na końcu linii `linux` (zawierającej `inst.stage2=...`) dodano parametr wskazujący na plik kickstart:

```
    inst.ks=http://192.168.1.34:8000/portfinder-ks.cfg
```

![7](<img/Zrzut ekranu 2026-05-05 023619.png>)

Po poprawnym wskazaniu pliku kickstart instalator Anaconda rozpoczął instalację nienadzorowaną. Widoczny jest komunikat `Not asking for remote desktop session because of an automated install` oraz `Rozpoczynanie instalacji automatycznej`, co potwierdza, że plik kickstart został prawidłowo odczytany:

![8](<img/Zrzut ekranu 2026-05-05 023705.png>)

![9](<img/Zrzut ekranu 2026-05-05 030005.png>)

## 4. Ręczna instalacja Fedory (pobranie anaconda-ks.cfg)

Równolegle przeprowadzono instalację ręczną Fedory 44 w celu uzyskania bazowego pliku `/root/anaconda-ks.cfg` i zapoznania się z możliwymi opcjami konfiguracji. Na ekranie powitalnym wybrano język polski:

![10](<img/Zrzut ekranu 2026-05-05 171745.png>)

## 5. Weryfikacja po instalacji

Po zakończeniu instalacji i automatycznym restarcie maszyna uruchomiła się jako `fedora-portfinder`. Zalogowano się jako `root` przez konsolę VirtualBox:

![11](<img/Zrzut ekranu 2026-05-05 172817.png>)

Po zalogowaniu uruchomiono Dockera i sprawdzono jego status:

```
    systemctl enable --now docker
    systemctl status docker
```

![12](<img/Zrzut ekranu 2026-05-05 183220.png>)

Docker działa poprawnie.

Artefakt `portfinder-12.tar.gz` pobrano z maszyny `devops` przez HTTP:

```
    wget -q "http://192.168.1.34:8000/MDO2026_ITE/ITE/grupa5/KP419785/Sprawozdanie9/portfinder-12.tar.gz" -O /root/portfinder-12.tar.gz
    docker load -i /root/portfinder-12.tar.gz
```

![13](<img/Zrzut ekranu 2026-05-05 185917.png>)

Wynik `Loaded image: app-deploy:latest` potwierdza, że obraz Docker z poprzednich laboratoriów załadował się poprawnie. Nazwa obrazu to `app-deploy:latest`, co jest zgodne z tym, co zwrócił pipeline Jenkins przy publikacji artefaktu.

Próba uruchomienia kontenera:

```
    docker run -d --name portfinder --restart=unless-stopped app-deploy
```

![14](<img/Zrzut ekranu 2026-05-05 185943.png>)

Kontener uruchomił się pomyślnie, zwróciło pełny hash ID kontenera:

![15](<img/Zrzut ekranu 2026-05-05 190011.png>)


Sprawdzono listę działających kontenerów oraz wywołano `docker --help` wewnątrz systemu, co potwierdza działanie Dockera zainstalowanego przez Kickstart:

```
    docker ps
    docker --help
```

Wynik `docker ps` pokazuje pustą tabelę, kontener `portfinder` uruchomił się, wykonał swoje zadanie (wyświetlenie help) i zakończył działanie, ponieważ `portfinder` (`pf`) to narzędzie konsolowe, nie serwer działający ciągle w tle. Jest to oczekiwane zachowanie, identyczne jak przy smoke teście w Laboratorium 5 (`docker run --rm portfinder-deploy --help`):

![16](<img/Zrzut ekranu 2026-05-05 183307.png>)

Pełna lista komend Dockera dostępna w systemie, co potwierdza poprawną instalację:

![17](<img/Zrzut ekranu 2026-05-05 183403.png>)

![18](<img/Zrzut ekranu 2026-05-05 183413.png>)


### Plik odpowiedzi Kickstart

Kickstart umożliwia w pełni automatyczną instalację systemu operacyjnego bez ingerencji użytkownika. Kluczowe dyrektywy użyte w tym laboratorium to `text` (tryb tekstowy), `clearpart --all` (czyszczenie dysku), `autopart` (automatyczne partycjonowanie), `network --hostname` (ustawienie nazwy hosta) oraz `%post` (sekcja poleceń wykonywanych po instalacji). Dzięki `reboot` na końcu instalacji system restartuje się automatycznie.

### Sekcja %post i ograniczenia instalatora

Sekcja `%post` działa w chroot na zainstalowanym systemie, ale bez uruchomionego jądra docelowego. Oznacza to, że polecenia `docker run` i `systemctl start` nie działają na tym etapie, można jednak użyć `systemctl enable`, które tworzy odpowiednie dowiązania symboliczne. Kontener uruchamia się dopiero przy pierwszym starcie systemu przez zdefiniowany serwis `portfinder.service`.

### Idempotentność i powtarzalność

Plik kickstart jest samowystarczalny, zawiera wszystkie informacje potrzebne do odtworzenia identycznej instalacji na dowolnej maszynie z dostępem do internetu i serwera HTTP z artefaktem. Każda instalacja tworzy system z dokładnie tą samą konfiguracją.

Główne zapytania do LLM:
- "Jak skonfigurować serwis systemd uruchamiający kontener Docker po starcie systemu w Fedorze?"
- "Jak wygenerować zaszyfrowane hasło dla rootpw w kickstart?"

Weryfikacja odpowiedzi: testowanie poleceń bezpośrednio w systemie, analiza komunikatów błędów instalatora Anaconda, porównanie z dokumentacją Kickstart.

*Plik `portfinder-ks.cfg` dostępny w katalogu `Sprawozdanie9`*