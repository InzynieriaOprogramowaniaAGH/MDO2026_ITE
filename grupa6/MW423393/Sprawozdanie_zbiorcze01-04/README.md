# Sprawozdanie zbiorcze – zajęcia 01–04

**Imię i nazwisko:** Mateusz Wiech  
**Nr indeksu:** 423393  
**Grupa:** 6  
**Branch:** `MW423393`

## 0. Środowisko pracy

Ćwiczenia wykonano w środowisku linuksowym (Ubuntu Server 24.04.4 LTS) działającym na maszynie wirtualnej z wykorzystaniem klienta `git` (2.43.0) i `OpenSSH` (9.6p1). Połączenie z maszyną realizowano przez SSH. Repozytorium było obsługiwane z poziomu terminala oraz edytora Visual Studio Code.

![VS Code Remote SSH](../Sprawozdanie01/SS/vscode.png)

## 1. Git i organizacja pracy z repozytorium

Skonfigurowano klienta `git`, dane użytkownika oraz dwa sposoby dostępu do GitHuba: przez `HTTPS` z użyciem `Personal Access Token` oraz przez `SSH` z uwierzytelnianiem kluczem publicznym.

Instalacja Git i SSH:
![Instalacja Git i SSH](../Sprawozdanie01/SS/apt_install.png)

Konfiguracja `git`:
![Konfiguracja Git](../Sprawozdanie01/SS/git_config.png)

Klonowanie repozytorium z wykorzystaniem HTTP:
![Klonowanie repo przez HTTPS](../Sprawozdanie01/SS/git_clone_https.png)

Klonowanie repozytorium przez SSH:
![Klonowanie repo przez SSH](../Sprawozdanie01/SS/git_clone_ssh.png)

Ważna była praca na odpowiednich gałęziach. Wykorzystano do tego gałąź grupy oraz utworzono własną gałąź roboczą z numerem indeksu.

Przełączenie na gałąź `main`, gałąź grupy oraz własną gałąź:
![Przełączenie na main i gałąź grupy](../Sprawozdanie01/SS/git_checkout.png)
![Utworzenie własnej gałęzi](../Sprawozdanie01/SS/git_branch.png)

Utworzenie odpowiednich katalogów:
![Utworzenie katalogu](../Sprawozdanie01/SS/mkdir.png)

Dodatkowo stworzono hook `commit-msg`, który automatycznie sprawdza treść commita. Git może służyć nie tylko do tworzenia historii kodu, ale również do przestrzegania ustalonych zasad pracy w repozytorium:

```sh
#!/bin/sh

PREFIX="MW423393"
COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

case "$COMMIT_MSG" in
  "$PREFIX"*)
    exit 0
    ;;
  *)
    echo "Error: commit message must start with $PREFIX"
    exit 1
    ;;
esac
```

Instalacja i test hooka:
![Instalacja hooka](../Sprawozdanie01/SS/git_hook.png)
![Test hooka](../Sprawozdanie01/SS/git_commit_test.png)

Poprawny commit i wysłanie zmian do zdalnego źródła:
![Poprawny commit](../Sprawozdanie01/SS/git_commit.png)
![Wysłanie zmian](../Sprawozdanie01/SS/git_push.png)

## 2. SSH jako mechanizm dostępu

Skonfigurowano klucze `SSH`, w tym klucze zabezpieczone hasłem, oraz dodano je do GitHuba. Umożliwia to bezpieczny dostęp do repozytorium oraz maszyny zdalnej. Upewniono się, że 2FA jest włączona na koncie.

Tworzenie kluczy SSH, z hasłem oraz bez.
![Tworzenie kluczy SSH](../Sprawozdanie01/SS/ssh-keygen.png)

Dodanie klucza do `ssh-agent`:
![Dodanie klucza do ssh-agent](../Sprawozdanie01/SS/ssh-add.png)

Poprawnie dodane klucze do konta GitHub:
![Klucze SSH na GitHub](../Sprawozdanie01/SS/SSH_keys_github.png)
![Konfiguracja 2FA](../Sprawozdanie01/SS/2FA.png)

## 3. Docker i podstawy konteneryzacji

`Docker` to narzędzie do uruchamiania oprogramowania w odizolowanych środowiskach. Obraz stanowi definicję środowiska, a kontener jest jego uruchomioną instancją wykonującą konkretny proces.

Instalacja Dockera:
![Instalacja Docker](../Sprawozdanie02/SS/apt_install_docker.png)
![Docker sprawdzenie wersji](../Sprawozdanie02/SS/docker_check.png)

Test Dockera na przykładzie obrazu `hello-world`:
![Docker run hello-world](../Sprawozdanie02/SS/docker_run_hello_world.png)

Na przykładowych obrazach pokazano różnice w działaniu kliku kontenerów. Jedne wykonują pojedyncze zadanie i kończą pracę, inne pozwalają na tryb interaktywny.

![Docker pull](../Sprawozdanie02/SS/docker_pull.png)
![Docker images](../Sprawozdanie02/SS/docker_images.png)

Uruchomienie przykładowych obrazów:
![Docker run](../Sprawozdanie02/SS/docker_run_echo.png)

Uruchomienie interaktywanego kontenera `busybox`:
![busybox shell](../Sprawozdanie02/SS/busybox_shell.png)

Uruchomienie systemu `ubuntu` w kontenerze:
![Ubuntu shell](../Sprawozdanie02/SS/docker_run_ubuntu.png)

Działające procesy Dockera na hoście:
![Docker ps](../Sprawozdanie02/SS/docker_ps.png)

Podstawowe działania na kontenerach: usuwanie zakończonych kontenerów, czyszczenie lokalnych obrazów.

Wyświetlenie zakończonych i uruchomionych kontenerów:
![Docker ps a](../Sprawozdanie02/SS/docker_ps_a.png)

Wyczyszczenie zakończonych kontenerów:
![Docker container prune](../Sprawozdanie02/SS/docker_container_prune.png)

Usuwanie lokalnych obrazów:
![Docker image prune](../Sprawozdanie02/SS/docker_image_prune.png)
![Docker image after](../Sprawozdanie02/SS/docker_images_after_prune.png)

## 4. Dockerfile - definicja środowiska

`Dockerfile` to tekstowa definicja obrazu, pozwala skonfigurować środowisko - wybrać obraz bazowy, zainstalować zależności, przygotować katalog roboczy czy sklonować kod.

Przykładowy `Dockerfile`:
```dockerfile
FROM ubuntu:latest

RUN apt update && apt install -y git ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
```

Budowanie obrazu:
![Docker build](../Sprawozdanie02/SS/docker_build.png)

Uruchomienie interaktywne obrazu:
![Docker run repo](../Sprawozdanie02/SS/docker_run_repo.png)

Pozwala to przenieść konfigurację środowiska do pojedynczego pliku, który może być odtwarzany wielokrotnie w dowolnym miejscu.

## 5. Build i test

Wykorzystany został projekt open source bazujący na `Node.js`, posiadający jawnie zdefiniowane kroki `build` i `test`. Wykonano build i testy lokalnie, aby potwierdzić sposób działania projektu i zależności środowiskowe.

Sklonowanie repo i sprawdzenie wersji `node` i `npm`:
![Sklonowanie repozytorium](../Sprawozdanie03/SS/git_clone.png)
![Wersja node i npm](../Sprawozdanie03/SS/node_v_npm_v.png)

Instalacja `npm`:
![Instalacja npm](../Sprawozdanie03/SS/npm_install.png)

Build i uruchomienie testów:
![Build i test programu](../Sprawozdanie03/SS/npm_run_build_npm_test.png)

Ten sam proces powtórzono w kontenerze. Build i test nie muszą zależeć od lokalnej konfiguracji użytkownika, lecz mogą być wykonywane w kontrolowanym, przenośnym środowisku.

Pobranie obrazu z wymaganym środowiskiem uruchomieniowym `node`:
![Docker pull node](../Sprawozdanie03/SS/docker_pull_node.png)

Uruchomienie kontenera interaktywnie i sklonowanie repo:
![Docker run it](../Sprawozdanie03/SS/docker_run_it.png)
![Git clone w kontenerze](../Sprawozdanie03/SS/docker_git_clone.png)

Build i uruchomienie testów w kontenerze:
![Build i test w kontenerze](../Sprawozdanie03/SS/docker_npm_run_build_npm_test.png)

Kontener wystepuje tu jako definicja etapu procesu, a nie tylko jako miejsce uruchomienia gotowej aplikacji.

## 6. Rozdzielenie etapu build i test w Dockerfile

Proces rozdzilono na dwa obrazy:
- jeden przygotowujący środowisko i wykonujący build,
- drugi bazujący na pierwszym i uruchamiający wyłącznie testy.

`Dockerfile.build`
```dockerfile
FROM node:18

RUN apt update && apt install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/mesqueeb/merge-anything.git .

RUN npm install
RUN npm run build
```

`Dockerfile.test`
```dockerfile
FROM merge-anything-build

WORKDIR /app

CMD ["npm", "test"]
```

Zbudowanie i uruchomienie pierwszego obrazu do buildowania:
![Dockerfile.build build](../Sprawozdanie03/SS/docker_build_merge_build.png)
![Dockerfile.build run](../Sprawozdanie03/SS/docker_run_merge_build.png)

Zbudowanie i uruchomienie drugiego obrazu do testowania:
![Dockerfile.test build](../Sprawozdanie03/SS/docker_build_merge_test.png)
![Dockerfile.test run](../Sprawozdanie03/SS/docker_run_merge_test.png)

Procesem głównym kontenera jest `bash` - kontener jest uruchomioną instancją obrazu i wykonuje konkretny proces:
![Proces w kontenerze build](../Sprawozdanie03/SS/docker_run_merge_build_ps.png)

Kontener wykonał polecenie `npm test`, uruchomił testy projektu i zakończył działanie kodem wyjścia (`Exited (0)`):
![Kontener testowy po zakończeniu pracy](../Sprawozdanie03/SS/docker_run_merge_test_ps.png)

Obraz jest przygotowanym środowiskiem, natomiast kontener uruchamia konkretny proces, np. `bash` albo `npm test`.

## 7. Docker Compose

`Docker Compose` umożliwia opisanie wielu usług w jednym pliku konfiguracyjnym. Zamiast ręcznie uruchamiać kolejne kontenery i przekazywać im parametry, można zdefiniować pełen zestaw środowisk.

## 8. Woluminy i zachowywanie stanu

Woluminy to mechanizm przechowywania danych poza cyklem życia pojedynczego kontenera. Pozwalają oddzielić dane wejściowe, proces builda oraz dane wyjściowe.

![Wyświetlenie obrazów](../Sprawozdanie04/SS/docker_images.png)

Utworzenie woluminów Dockera:
![Wyświetlenie woluminów docker](../Sprawozdanie04/SS/docker_volume.png)

Uruchomienie kontenera bazowego z podłączonymi woluminami:
![Uruchomienie kontenera bazowego](../Sprawozdanie04/SS/docker_run_it.png)

Pokazano dwa warianty dostarczania kodu do kontenera budującego. W pierwszym wariancie kod był przygotowany na hoście i kopiowany na wolumin wejściowy z użyciem kontenera pomocniczego oraz bind mounta. Dzięki temu możliwe było wykonanie builda bez użycia `git` wewnątrz właściwego kontenera.

Sklonowanie repozytorium na wolumin wejściowy:
![Skolonowanie repozytorium na wolumin](../Sprawozdanie04/SS/repo_clone.png)

Uruchomienie kontenera buildowego:
![Uruchomienie kontenera buildowego](../Sprawozdanie04/SS/docker_run.png)
![Build i dane wyjściowe](../Sprawozdanie04/SS/npm_run_build.png)

Dane wyjściowe poza kontenerem:
![Sprawdzenie woluminu](../Sprawozdanie04/SS/check.png)

W drugim wariancie repozytorium było klonowane bezpośrednio wewnątrz kontenera na wolumin wejściowy. Oba podejścia miały na celu rozdzielenie danych wejściowych, środowiska uruchomieniowego i danych wyjściowych.

![Klonowanie wewnątrz kontenera](../Sprawozdanie04/SS/git_clone.png)

Budowanie wewnątrz kontenera:
![Budowanie po klonowaniu w kontenerze](../Sprawozdanie04/SS/npm_install_build.png)

Sprawdzenie zawartości woluminów poza kontenerem:
![Sprawdzenie zawartości woluminów](../Sprawozdanie04/SS/woluminy.png)

## 9. Sieć kontenerowa i ekspozycja portów

Na przykładzie `iperf3` przedstawiono podstawy komunikacji sieciowej między kontenerami. Najpierw pokazano połączenie w domyślnej sieci `bridge`, oparte na adresach IP.

Uruchomienie kontenerów `iperf-server` oraz `iperf-client`:
![Uruchomienie kontenerów z iperf3](../Sprawozdanie04/SS/iperf3.png)

Sprawdzenie adresów IP utworzonych kontenerów:
![Sprawdzenie IP](../Sprawozdanie04/SS/iperf3_IP.png)

Test połączenia po IP:
![Połączenie w sieci bridge](../Sprawozdanie04/SS/iperf3_test.png)

Utworzono własną sieć mostkową, pozwalając na korzystanie z rozwiązywania nazw i odwoływania się do kontenerów po nazwie, bez ręcznego wskazywania adresu IP.

Stworzenie własnej sieci mostkowanej:
![Utworzenie sieci docker network](../Sprawozdanie04/SS/iperf3_net.png)

Test połączenia po nazwie kontenera:
![Połączenie po nazwie kontenera](../Sprawozdanie04/SS/iperf3_net_test.png)

Wystawiono również port na hosta i dostęp do usługi z poziomu hosta oraz spoza hosta. Kontenerowa usługa stała się dostępna poza wewnętrzną siecią Dockera.

Wystawienie portu:
![Wystawienie portu](../Sprawozdanie04/SS/iperf3_pub.png)

Test połączenia z hosta:
![Połączenie z hosta](../Sprawozdanie04/SS/iperf3_test_local.png)

Test połączenia spoza hosta:
![Połączenie spoza hosta](../Sprawozdanie04/SS/iperf3_host.png)

## 10. Usługi systemowe w kontenerze

Na przykładzie `sshd`, w kontenerze można uruchomić klasyczną usługę systemową. Wymaga to jednak dodatkowej konfiguracji, uruchomienia procesu serwera oraz odpowiedniego wystawienia portu.

![Docker run sshd](../Sprawozdanie04/SS/docker_run_sshd.png)

Instalacja i konfiguracja `sshd`:
![Instalacja i konfiguracja sshd](../Sprawozdanie04/SS/sshd.png)
![Uruchomienie sshd](../Sprawozdanie04/SS/sshd_run.png)

Połączenie po SSH:
![Udane połączenie SSH](../Sprawozdanie04/SS/ssh_connected.png)

Kontener może pełnić rolę zdalnego systemu dostępnego przez SSH. W praktyce kontenery zwykle uruchamiają pojedynczy proces aplikacyjny, a nie pełne środowisko systemowe.

## 11. Jenkins i Docker-in-Docker

Uruchomienie skonteneryzowanej instancji `Jenkins` z wykorzystaniem pomocniczego kontenera pokazuje, że środowisko może samo działać w kontenerach, a jednocześnie korzystać z usług Dockera potrzebnych do wykonywania zadań.

Utworzenie sieci i uruchomienie DIND: 
![Uruchomienie DIND](../Sprawozdanie04/SS/jenkins_run.png)

Uruchomienie Jenkins Controller:
![Uruchomienie kontrolera Jenkins](../Sprawozdanie04/SS/jenkins_controller.png)
![Działające kontenery Jenkinsa](../Sprawozdanie04/SS/jenkins_docker_ps.png)

Inicjalizacja Jenkinsa i instalacja pluginów:
![Inicjalizacja Jenkins](../Sprawozdanie04/SS/jenkins_initialize.png)
![Instalacja pluginów Jenkins](../Sprawozdanie04/SS/jenkins_install_plugins.png)

## 12. Wnioski

Środowisko wytwarzania oprogramowania nie opiera się jedynie na samym kodzie, ale również na powtarzalnym środowisku uruchomieniowym, wydzielonych etapach procesu, kontrolowanym przepływie danych oraz jawnie opisanej komunikacji między usługami.

Host jest warstwą kontrolną, maszyna wirtualna zapewnia odseparowane środowisko pracy, a kontenery służą do uruchamiania konkretnych procesów i usług w sposób lekki, kontrolowany i powtarzalny.