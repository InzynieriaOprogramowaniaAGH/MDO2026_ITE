# Sprawozdanie podsumowujące – ćwiczenia 1–4 (06.03–27.03.2026)

## Cel
Celem ćwiczeń 1–4 było praktyczne opanowanie pracy z repozytorium Git (w tym SSH i hooków), podstaw konteneryzacji w Dockerze (obrazy, kontenery, Dockerfile, uruchamianie i czyszczenie zasobów), uruchamiania procesu build/test w środowisku lokalnym i kontenerowym oraz wykorzystania woluminów, sieci i wybranych usług (iperf3, SSH, Jenkins) w środowisku Docker.

## Środowisko i narzędzia
- **Git + GitHub**: klonowanie repozytoriów, praca na gałęziach, autoryzacja PAT/SSH.
- **SSH**: generowanie kluczy i weryfikacja połączenia z GitHub.
- **Docker**: uruchamianie gotowych obrazów, budowa własnych obrazów, woluminy i sieci.
- **Node.js / npm**: instalacja zależności, budowanie projektu i uruchamianie testów (na przykładzie repo `axios`).
- **Dodatkowe narzędzia/usługi**: `iperf3`, `openssh-server` (w kontenerze), Jenkins (w Dockerze z dostępem do Docker CLI).

## Ćwiczenie 1 (06.03.2026) – Git, SSH, gałęzie i hooki
### Zakres prac
- Instalacja i weryfikacja działania Git na maszynie.
- Klonowanie repozytorium z GitHuba (z użyciem **personal access token** dla HTTPS).
- Generacja dwóch kluczy SSH:
  - **ed25519** (chroniony hasłem),
  - **ecdsa** (bez hasła),
  następnie dodanie jednego z kluczy do konta GitHub i test połączenia (`ssh -T`).
- Praca na repozytorium: przejście na `main`, następnie `grupa4` i utworzenie nowej gałęzi roboczej `GN421256`.
- Utworzenie **hooka Git** wymuszającego format wiadomości commita.

### Efekt
Skonfigurowano uwierzytelnianie przez SSH/HTTPS oraz przygotowano gałąź roboczą. Hook blokuje commity, jeśli wiadomość nie zaczyna się od zadanego prefiksu:
- **prefiks**: `GN421256: `

## Ćwiczenie 2 (13.03.2026) – Podstawy Dockera i własny obraz
### Zakres prac
- Instalacja Dockera na VM, włączenie usługi po restarcie i weryfikacja (`docker info`).
- Uruchomienie przykładowych obrazów i analiza zachowania kontenerów:
  - `hello-world`,
  - `busybox`,
  - `ubuntu`,
  - `mariadb` (w tle, z użyciem zmiennej hasła i inspekcją exit code),
  - obrazy `.NET` (runtime/aspnet/sdk) i porównanie.
- Sprawdzenie rozmiarów obrazów (`docker images`).
- Praca z kontenerem `busybox`:
  - uruchomienie w tle na dłużej (`sleep 3600`),
  - wejście do kontenera (`docker exec -it ... sh`).
- Praca z kontenerem `ubuntu` jako „mini-systemem”:
  - uruchomienie interaktywne,
  - sprawdzenie procesu PID 1,
  - aktualizacja pakietów (`apt upgrade`) i zakończenie.
- Stworzenie własnego `Dockerfile` na bazie `ubuntu:22.04` z instalacją `ca-certificates` i `git`, ustawieniem `WORKDIR` i domyślnym `CMD ["bash"]`, a następnie budowa i uruchomienie obrazu.
- Sprzątanie zasobów:
  - usuwanie zakończonych kontenerów,
  - usuwanie nieużywanych obrazów (`docker image prune -a`).

### Efekt
Poznano różnice między trybem interaktywnym i detached, sposób inspekcji stanu kontenera oraz podstawy budowy obrazu z `Dockerfile` (dobór tagów, łączenie poleceń w jednym `RUN`, czyszczenie cache APT).

## Ćwiczenie 3 (20.03.2026) – Build/test projektu na VM i w Dockerze + automatyzacja obrazami
### Część A: praca na VM (poza Dockerem)
- Klonowanie repozytorium i przygotowanie projektu.
- Instalacja zależności oraz budowa:
  - `npm ci` / instalacja zależności,
  - `npm run build`.
- Uruchomienie testów i weryfikacja raportu:
  - `npm run test`.

### Część B: praca w kontenerze
- Utworzenie i uruchomienie kontenera z Node.js (`node:20-bullseye`).
- W kontenerze: klonowanie repo, instalacja zależności, build i testy analogicznie jak na VM.

### Część C: automatyzacja (Dockerfile.build + Dockerfile.test)
Wykonano podejście „pipeline w obrazach”:
- `Dockerfile.build`: buduje środowisko, klonuje repo `axios`, instaluje zależności i wykonuje build.
- `Dockerfile.test`: bazuje na obrazie zbudowanym wcześniej i uruchamia `npm test` jako proces kontenera.

### Efekt
Ujednolicono proces build/test w odizolowanym środowisku oraz pokazano, jak składać kroki CI w postaci obrazów Dockera. Dodatkowo doprecyzowano pojęcia:
- **obraz**: statyczny szablon (warstwy, system/narzędzia/kod),
- **kontener**: uruchomiona instancja obrazu (proces + izolacja + stan runtime).

## Ćwiczenie 4 (27.03.2026) – Woluminy, sieci, iperf3, SSH w kontenerze, Jenkins
### Woluminy (build z wejściem/wyjściem)
- Utworzenie woluminów wejściowego i wyjściowego (`proj_input`, `proj_output`).
- Skopiowanie źródeł do woluminu (przez kontener narzędziowy `alpine`) i uruchomienie builda w kontenerze `node:20` z:
  - woluminem źródeł jako workspace,
  - woluminem wynikowym na artefakty (np. `dist`).
- Wariant alternatywny: klonowanie repo bezpośrednio do woluminu (git w `alpine`), a następnie build.

### Sieć i pomiary (iperf3)
- Uruchomienie serwera `iperf3` w kontenerze i połączenie klienta do serwera po IP.
- Powtórzenie testu w dedykowanej sieci Docker (`docker network create`) i łączenie po nazwie usługi/kontenera.
- Ekspozycja portu `5201` i test połączenia:
  - z VM,
  - z hosta Windows (wskazanie IP VM i portu).
- Weryfikacja działania poprzez logi serwera (`docker logs`).

### SSH w Ubuntu (kontener)
- Przygotowanie obrazu Ubuntu z `openssh-server` i użytkownikiem `student` (z sudo).
- Konfiguracja serwera SSH, wystawienie portu i uruchomienie `sshd` jako procesu kontenera.

### Jenkins w Dockerze
- Utworzenie sieci i woluminów dla Jenkinsa.
- Uruchomienie `docker:dind` jako „silnika Dockera” w sieci Jenkinsa.
- Zbudowanie obrazu Jenkinsa z doinstalowanym `docker-ce-cli` (w celu wykonywania poleceń Dockera z poziomu jobów).
- Uruchomienie Jenkinsa, inicjalna konfiguracja (hasło, utworzenie użytkownika) i weryfikacja działania w przeglądarce.

## Wnioski końcowe
- **Git/SSH**: klucze SSH znacząco upraszczają pracę z repozytoriami; hooki pozwalają wymuszać standardy (np. format wiadomości commit) na etapie lokalnym.
- **Docker – podstawy**: rozumienie różnicy obraz/kontener, trybów uruchomienia oraz inspekcji stanu jest kluczowe do diagnozowania problemów.
- **Dockerfile i optymalizacja**: używanie konkretnych tagów, łączenie operacji APT w jednym `RUN` i czyszczenie cache poprawia powtarzalność i rozmiar obrazów.
- **Automatyzacja build/test**: kontenery umożliwiają stabilny, przenośny proces budowania i testowania niezależny od hosta; rozbicie na obrazy (build/test) odzwierciedla podejście CI.
- **Woluminy i sieci**: woluminy ułatwiają przenoszenie danych między etapami (źródła/artefakty), a sieci Dockera upraszczają komunikację usług (DNS po nazwie kontenera) i testy przepustowości (iperf3).
- **Usługi w kontenerach (SSH/Jenkins)**: nawet złożone usługi można uruchamiać w Dockerze, ale wymagają poprawnej konfiguracji portów, woluminów (stan) i sieci (łączność), a w przypadku Jenkinsa także przemyślenia integracji z Dockerem (np. DIND + docker-cli).

