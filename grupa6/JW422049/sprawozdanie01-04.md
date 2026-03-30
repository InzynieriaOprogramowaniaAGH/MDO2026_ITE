# Sprawozdanie podsumowujące - Git, SSH, Docker i konteneryzacja

**Jan Wojsznis 422049**

---

## 0. Środowisko pracy

Wszystkie ćwiczenia wykonano w środowisku *Ubuntu Server* uruchomionym na maszynie wirtualnej. Połączenie z maszyną realizowano przez *SSH*, a głównym środowiskiem pracy był *Visual Studio Code* z wykorzystaniem *Remote SSH*. Do wymiany plików użyto także *FileZilla* przez *SFTP*. Tak przygotowane środowisko pozwoliło na wykonywanie poleceń bezpośrednio na systemie linuksowym, bez pracy w konsoli maszyny wirtualnej.

![VS Code Remote SSH](./ss/1/vscode_ssh.png)

![FileZilla SFTP](./ss/1/filezilla.png)

---

## 1. Git i przygotowanie repozytorium

W pierwszym etapie sprawdzono dostępność klienta `git` oraz skonfigurowano podstawowe dane użytkownika wykorzystywane przy commitach. Następnie repozytorium przedmiotowe sklonowano z użyciem protokołu *HTTPS*. W dalszej części skonfigurowano również dostęp po *SSH*, dzięki czemu możliwe było korzystanie z repozytorium bez użycia hasła przy każdej operacji.

![Konfiguracja Git](./ss/1/git_config.png)

![Klonowanie repozytorium przez HTTPS](./ss/1/https_clone.png)

![Klonowanie repozytorium przez SSH](./ss/1/ssh_clone.png)

---

## 2. SSH i zabezpieczenie dostępu

Przygotowano dwa klucze *SSH* inne niż *RSA*: `ed25519` oraz `ecdsa 521`. Jeden z kluczy został zabezpieczony hasłem. Następnie uruchomiono *ssh-agent* i dodano do niego oba klucze. Klucz publiczny został dodany do konta *GitHub*, po czym zweryfikowano poprawność logowania przez `ssh -T git@github.com`. Dodatkowo na koncie *GitHub* skonfigurowano uwierzytelnianie dwuskładnikowe *2FA*.

![Klucze SSH](./ss/1/ssh_keys.png)

![Dodanie kluczy do ssh-agent](./ss/1/ssh_agent.png)

![GitHub SSH](./ss/1/github_ssh.png)

![2FA GitHub](./ss/1/github_2fa.png)

---

## 3. Praca na gałęziach i organizacja repozytorium

Repozytorium zostało przygotowane do pracy zespołowej przez przełączenie na gałąź `main`, następnie na gałąź grupową `grupa6`, a potem przez utworzenie własnej gałęzi `JW422049`. W katalogu właściwym dla grupy utworzono własny katalog roboczy. Dzięki temu wszystkie kolejne sprawozdania i pliki pomocnicze mogły być porządkowane w jednym miejscu na osobnej gałęzi użytkownika.

W repozytorium przygotowano również skrypt `commit-msg`, który sprawdzał, czy komunikat commita zaczyna się od `JW422049`. Pozwoliło to wymusić spójny format commitów. Skrypt został skopiowany do `.git/hooks/commit-msg` i zweryfikowany zarówno na błędnym, jak i poprawnym commicie. Po zakończeniu zmian własna gałąź została wysłana do zdalnego repozytorium, a następnie utworzono *pull request* do gałęzi grupowej.

```sh
#!/bin/sh

PREFIX="JW422049"
MSG_FILE="$1"
FIRST_LINE=$(head -n 1 "$MSG_FILE")

case "$FIRST_LINE" in
  "$PREFIX"*)
    exit 0
    ;;
  *)
    echo "Blad: commit message musi zaczynac sie od $PREFIX"
    exit 1
    ;;
esac
```

![Niepoprawny commit](./ss/1/commit_test.png)

![Poprawny commit](./ss/1/commit_ok.png)

![Pull request](./ss/1/pull_request.png)

![Status pull request](./ss/1/pull_request_status.png)

---

## 4. Instalacja Dockera i podstawy pracy z obrazami

W kolejnym etapie zainstalowano *Docker* w systemie *Ubuntu* z użyciem pakietu `docker.io`. Po instalacji sprawdzono poprawność działania usługi oraz wersję programu. Następnie zapoznano się z działaniem podstawowych obrazów, takich jak `hello-world`, `busybox`, `ubuntu`, `mariadb`, a także obrazy `runtime`, `aspnet` i `sdk` dla Microsoft .NET. Dla wybranych obrazów wykonano uruchomienie, sprawdzenie kodu wyjścia oraz rozmiaru.

![Instalacja Dockera](./ss/2/docker_install.png)

![hello-world](./ss/2/hello_world.png)

![busy box](./ss/2/busy_box.png)

![ubuntu](./ss/2/ubuntu.png)

---

## 5. Kontenery interaktywne i własny Dockerfile

Uruchomiono kontener z obrazu `busybox` i sprawdzono jego wersję w trybie interaktywnym. Następnie uruchomiono kontener z obrazu `ubuntu`, w którym pokazano proces `PID 1`, procesy Dockera na hoście oraz wykonano aktualizację pakietów. Pozwoliło to pokazać, jak działa prosty system uruchomiony wewnątrz kontenera.

W dalszej części przygotowano własny plik `Dockerfile` bazujący na obrazie `ubuntu:24.04`. W obrazie zainstalowano `git`, a następnie sklonowano repozytorium przedmiotowe. Zbudowany obraz został uruchomiony, a obecność repozytorium w kontenerze została zweryfikowana.

![Kontener busybox](./ss/2/busybox.png)

![System w kontenerze](./ss/2/system.png)

![Dockerfile](./ss/2/dockerfile.png)

---

## 6. Czyszczenie kontenerów i obrazów

Po zakończeniu pracy wyświetlono wszystkie kontenery, w tym zakończone, a następnie usunięto zatrzymane kontenery. W analogiczny sposób pokazano listę lokalnych obrazów Dockera i wyczyszczono nieużywane obrazy z lokalnego magazynu. Ostatnim krokiem w tym etapie było dodanie pliku `Dockerfile` do repozytorium w katalogu sprawozdania.

![Kontenery Docker](./ss/2/kontenery.png)

![Obrazy lokalne](./ss/2/obrazy_l.png)

---

## 7. Budowanie i testowanie aplikacji w kontenerach

W kolejnych ćwiczeniach wykorzystano repozytorium aplikacji *Node.js*. Najpierw projekt został sklonowany lokalnie, zainstalowano zależności przez `npm`, a następnie uruchomiono testy lokalnie. Pozwoliło to sprawdzić, że aplikacja działa poprawnie poza kontenerem.

![Klonowanie repozytorium](./ss/3/clone.png)

![Instalacja zależności npm](./ss/3/npm.png)

![Lokalne testy aplikacji](./ss/3/test.png)

Następnie uruchomiono kontener interaktywny z obrazem *Node.js*. Wewnątrz kontenera doinstalowano potrzebne narzędzia, ponownie sklonowano repozytorium projektu oraz wykonano instalację zależności, build i testy. Dzięki temu zweryfikowano działanie projektu również w środowisku kontenerowym.

![Uruchomienie kontenera interaktywnego](./ss/3/contener.png)

![Klonowanie repozytorium w kontenerze](./ss/3/clone_contener.png)

![Build i testy w kontenerze](./ss/3/test_build_contener.png)

---

## 8. Dockerfile wieloetapowy logicznie: build i test

W dalszej części przygotowano dwa pliki `Dockerfile`. Pierwszy plik służył do zbudowania środowiska aplikacji i wykonania procesu build. Drugi plik bazował na pierwszym obrazie i uruchamiał jedynie testy aplikacji. Dzięki temu nie było potrzeby powtarzania całego procesu instalacji i builda przy każdym uruchomieniu testów.

Na podstawie przygotowanego `Dockerfile` zbudowano pierwszy obraz Dockera, a następnie zweryfikowano jego obecność lokalnie. Po tym zbudowano drugi obraz bazujący na pierwszym i użyto go do uruchomienia testów. Kontener utworzony z drugiego obrazu wykonał testy bez potrzeby ponownego budowania środowiska od podstaw.

![Treść Dockerfile](./ss/3/dockerfile.png)

![Budowanie pierwszego obrazu](./ss/3/build.png)

![Pierwszy obraz Dockera](./ss/3/build_obraz1.png)

![Drugi obraz Dockera](./ss/3/build_obraz2.png)

![Uruchomienie testów z drugiego obrazu](./ss/3/obraz2-test.png)

---

## 9. Woluminy Dockera i zachowanie stanu

W kolejnej części wykorzystano woluminy Dockera do zachowania stanu między uruchomieniami kontenerów. Przygotowano wolumin wejściowy i wyjściowy, a następnie uruchomiono kontener bazowy zdolny do budowania projektu. Repozytorium aplikacji zostało sklonowane na wolumin wejściowy, po czym wykonano build w kontenerze, a wynik zapisano na woluminie wyjściowym.

Po wyjściu z kontenera sprawdzono, że wynik builda nadal znajduje się na woluminie, co potwierdziło zachowanie stanu poza samym cyklem życia kontenera. Następnie powtórzono operację w drugim wariancie, tym razem wykonując klonowanie bezpośrednio z poziomu kontenera.

![Obraz bazowy użyty do budowania projektu](./ss/4/04-base-image.png)

![Utworzenie woluminów](./ss/4/04-volumes-created.png)

![Uruchomienie kontenera bazowego z podpiętymi woluminami](./ss/4/04-build-container-start.png)

![Wynik builda zapisany na woluminie wyjściowym](./ss/4/04-build-output-volume.png)

![Drugi wariant builda z klonowaniem w kontenerze](./ss/4/04-volume-build-b.png)

![Repozytorium sklonowane na wolumin](./ss/4/04-volume-clone.png)

![Sprawdzenie zachowania danych po wyjściu z kontenera](./ss/4/04-output-persisted.png)

---

## 10. Sieci Docker i komunikacja między kontenerami

Do zbadania komunikacji między kontenerami wykorzystano narzędzie `iperf3`. Najpierw uruchomiono serwer w domyślnej sieci Dockera, a klient połączył się z nim po adresie IP odczytanym z konfiguracji kontenera. Następnie przygotowano własną sieć mostkową i powtórzono test, tym razem wykorzystując nazwę kontenera zamiast ręcznego wskazywania adresu IP.

W dalszym kroku wystawiono port serwera `iperf3` na hosta i sprawdzono możliwość połączenia z poziomu systemu gospodarza. Pozwoliło to pokazać zarówno połączenie między kontenerami, jak i sposób udostępniania usług poza kontener.

![Połączenie przez domyślną sieć Dockera](./ss/4/04-iperf-default-network.png)

![Połączenie przez własną sieć mostkową](./ss/4/04-iperf-custom-network.png)

![Dostęp do usługi z hosta](./ss/4/04-iperf-host-access.png)

---

## 11. SSHD w kontenerze

Uruchomiono kontener systemowy z obrazu `ubuntu`, w którym doinstalowano pakiet `openssh-server`, przygotowano katalog `/run/sshd`, ustawiono hasło użytkownika `root` i uruchomiono usługę `sshd`. Następnie z poziomu hosta wykonano połączenie przez `ssh` na wystawiony port kontenera.

Takie rozwiązanie pozwala zdalnie wejść do kontenera przy użyciu standardowych narzędzi administracyjnych. Z drugiej strony sprawia, że kontener zaczyna zachowywać się bardziej jak klasyczna maszyna systemowa, a mniej jak lekki, jednofunkcyjny komponent.

![Uruchomienie SSHD w kontenerze](./ss/4/04-sshd-container.png)

![Logowanie do kontenera przez SSH](./ss/4/04-sshd-login.png)

---

## 12. Jenkins i Docker-in-Docker

W ostatnim etapie uruchomiono środowisko złożone z `Docker-in-Docker` oraz `Jenkins`. Najpierw przygotowano dedykowaną sieć i uruchomiono kontener `jenkins-dind` w trybie uprzywilejowanym. Następnie uruchomiono kontener `jenkins`, który został podłączony do tej samej sieci i skonfigurowany do komunikacji z usługą Dockera działającą w kontenerze DIND.

Po uruchomieniu środowiska pobrano hasło startowe Jenkinsa, otwarto interfejs WWW i zalogowano się do panelu administracyjnego. W ten sposób potwierdzono, że zarówno `jenkins-dind`, jak i `jenkins` działają poprawnie, a interfejs WWW jest dostępny z poziomu przeglądarki.

![Uruchomienie Docker-in-Docker](./ss/4/04-jenkins-dind-run.png)

![Uruchomienie kontenera Jenkins](./ss/4/04-jenkins-run.png)

![Panel Jenkins](./ss/4/04-jenkins-ui.png)

![Interfejs Jenkins po uruchomieniu](./ss/4/04-jenkins-ui2.png)

---

## 13. Podsumowanie

W ramach wszystkich czterech laboratoriów skonfigurowano środowisko pracy zdalnej, przygotowano dostęp do repozytorium przez *Git* i *SSH*, przećwiczono pracę na gałęziach i *pull requestach*, a następnie wykonano pełne wprowadzenie do pracy z *Dockerem*. Kolejne ćwiczenia obejmowały uruchamianie gotowych obrazów, budowanie własnych obrazów, testowanie aplikacji w kontenerach, użycie woluminów, konfigurację sieci, uruchamianie usług takich jak `SSHD` oraz przygotowanie środowiska `Jenkins + Docker-in-Docker`.

Całość pozwoliła przejść od podstawowej pracy z repozytorium kodu aż do bardziej zaawansowanego wykorzystania kontenerów i narzędzi automatyzacji w środowisku linuksowym.
