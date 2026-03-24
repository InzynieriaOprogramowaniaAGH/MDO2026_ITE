# Sprawozdanie 04 - Dodatkowa terminologia w konteneryzacji, instancja Jenkins

**Data zajęć:** 24.03.2026 r.

**Imię i nazwisko:** Mateusz Wiech

**Nr indeksu:** 423393

**Grupa:** 6

**Branch:** MW423393

---

## 0. Środowisko

Ćwiczenie wykonano w środowisku linuksowym (Ubuntu Server 24.04.4 LTS) działającym na maszynie wirtualnej z wykorzystaniem klienta `git` (2.43.0) i `OpenSSH` (9.6p1). Połączenie z maszyną realizowano przez SSH. Repozytorium było obsługiwane z poziomu terminala oraz edytora Visual Studio Code.

---

## 1. Zachowywanie stanu między kontenerami

Do kontenera bazowego wykorzystano obraz z poprzednich zajęć - `merge-anything-build`, który potrafi już budować projekt i ma zainstalowane wszystkie dependencje.
![Wyświetlenie obrazów](./SS/docker_images.png)

Utworzono dwa woluminy - wejściowy `merge-input` oraz wyjściowy `merge-output`.
![Wyświetlenie woluminów docker](./SS/docker_volume.png)

Podłączenie woluminów do kontenera i uruchomienie go.
![Uruchomienie kontenera bazowego](./SS/docker_run_it.png)

Repozytorium sklonowano lokalnie na hoście, następnie przeniesiono jego zawartość na wolumin wejściowy `merge-input` z wykorzystaniem kontenera pomocniczego. Lokalny katalog projektu podłączono do kontenera jako bind mount tylko od odczytu. Wolumin wejściowy podłączono jako katalog docelowy. W kontenerze skopiowano pliki z `/src` do `/input`. Przy tym podejściu nie wykorzystano `git` wewnątrz kontenera.
![Skolonowanie repozytorium na wolumin](./SS/repo_clone.png)

Uruchomiono kontener z podłączonymi woluminami oraz build wewnątrz niego. Wykonano polecenia `npm install` oraz `npm run build`. Katalog z powstałymi plikami `dist` został skopiowany do `/output` na wolumin wyjściowy.
![Docker_run](./SS/docker_run.png)
![Output](./SS/npm_run_build.png)

Widoczność plików po zakończeniu pracy kontenera zweryfikowano przez uruchomienie nowego kontenera z podłączonym tym samym woluminem `merge-output`.
![Sprawdzenie woluminu](./SS/check.png)

Przed ponowynym klonowaniem, ale tym razem wewnątrz kontenera, wyczyszczono oba woluminy. Repozytorium sklonowano bezpośrednio na wolumin wejściowy z poziomu kontenera. W katalogu `/input` wykonano `git clone https://github.com/mesqueeb/merge-anything.git .`. Wykonano `npm install` oraz `npm run build`, katalog `dist` skopiowano na wolumin wyjściowy `/output`.
![Klonowanie wewnątrz kontenera](./SS/git_clone.png)
![Budowanie obrazu npm](./SS/npm_install_build.png)

Sprawdzenie czy pliki pozostają dostępne po zakończeniu pracy kontenera.
![Sprawdzenie zawartości woluminów](./SS/woluminy.png)

Część kroków można zautomatyzować za pomocą `docker build` i `Dockerfile` - sklonowanie repo, instalację zależności i wykonanie builda, a `RUN --mount` może tymczasowo udostępnić źródła podczas budowania obrazu. Nie zastępuje to jednak named volume, ponieważ `RUN --mount` działa tylko w czasie budowania obrazu oraz nie służy do trwałego przechowywania danych między uruchomieniami kontenerów.

---

## 2. Eksponowanie portu i łączność między kontenerami

Uruchomienie obrazów iperf3 w dwóch kontenerach - w jednym w trybie serwera, w drugim klienta.
![Uruchomienie kontenerów z iperf3](./SS/iperf3.png)

Sprawdzenie adresów IP kontenerów.
![Sprawdzenie IP](./SS/iperf3_IP.png)

Uruchomienie testu `iperf3 -c adres_serwera`
![Sprawdzenie połączenia iperf3](./SS/iperf3_test.png)

Utworzenie własnej sieci poprzez `docker network create` i uruchomnienie nowych kontenerów z tą siecią.
![Utworzenie sieci docker network](./SS/iperf3_net.png)

Test połączenia z wykorzystaniem nazwy, a nie adresu IP.
![Test połączenia docker network](./SS/iperf3_net_test.png)

Połączernie się z kontenerem z hosta. Wystawienie portu serwera na hosta.
![Wystawienie portu](./SS/iperf3_pub.png)

Test połączenia z hosta.
![Test połączenia z hosta](./SS/iperf3_test_local.png)
`localhost`, ponieważ z punktu widzenia hosta usługa jest dostępna lokalnie na jego własnym porcie 5201.

Test połączenia spoza hosta.
![Test połączenia spoza hosta](./SS/iperf3_host.png)

Do tworzenia maszyn wirtualnych korzystam z serwera zdalnego, z którym jestem połącznony po prywatnym VPN-ie. Ograniczeniem tutaj jest więc przepustowość łącza udostępniana przez ISP.

W domyślnej sieci `bridge`, przy połączeniu kontener–kontener po adresie IP, uzyskano przepustowość około `37.0 Gbit/s`. Po utworzeniu własnej sieci mostkowej i wykorzystaniu rozwiązywania nazw, przy połączeniu do kontenera `iperf-server-net` po nazwie, uzyskano około `33.6 Gbit/s`.

Połączenie z hosta przez `localhost`, uzyskało około `26.2 Gbit/s`. Połączenie spoza hosta, do adresu `192.168.0.155`, uzyskało około `22.4 Mbit/s`. Różnica względem komunikacji wewnątrz Dockera wynika z faktu, że ostatni pomiar obejmował rzeczywisty ruch sieciowy między urządzeniami, a nie tylko komunikację lokalną wewnątrz hosta.

---

## 3. Usługi w rozumieniu systemu, kontenera i klastra

Uruchomienie kontenera Ubuntu i wystawienie `sshd` na porcie hosta.
![Docker run sshd](./SS/docker_run_sshd.png)

Wewnątrz kontenera wykonano polecenie `apt install -y openssh-server` do instalacji serwera `openssh`.
![sshd setup](./SS/sshd.png)
![sshd run](./SS/sshd_run.png)

Próba połączenia po SSH.
![SSH połączenie](./SS/ssh_denied.png)

Należy w konfiguracji `sshd` zmienić ustawienia na:
```
PermitRootLogin yes
PasswordAuthentication yes
```

Ponowna próba połączenia.
![SSH połączenie](./SS/ssh_connected.png)

Komunikacja z kontenerem przez SSH może być wygodna w sytuacjach, w których chcemy traktować kontener podobnie do zdalnego systemu. Ułatwia to logowanie z użyciem standardowego klienta `ssh`.
Wadą jest jednak fakt, że w kontenerach zwykle uruchamia się pojedynczy proces aplikacyjny, a nie pełną usługę systemową. Dodawanie `sshd` zwiększa złożoność obrazu, wymaga dodatkowej konfiguracji, otwierania portów i zarządzania hasłami lub kluczami, a także zmniejsza prostotę kontenera.

---

## 4. Przygotowanie do uruchomienia serwera Jenkins

Utworzenie sieci i uruchomienie DIND.
![Jenkins](./SS/jenkins_run.png)

Uruchomienie Jenkins Contorller.
![Jenkins Controller](./SS/jenkins_controller.png)

Oba kontenery działają.
![Jenkins ps](./SS/jenkins_docker_ps.png)

Aby zainicjalizować Jenkins należy wydobyć hasło z logów (polecenie `docker logs jenkins-blueocean`) i użyć go na stronie pod adresem hosta (np. `http://192.168.0.155:8080`).
![Jenkins initialize](./SS/jenkins_initialize.png)

Instalacja zalecanych pluginów.
![Jenkins install plugins](./SS/jenkins_install_plugins.png)

---
