# Sprawozdanie 01 - Wprowadzenie, Git, Gałęzie, SSH

**Data zajęć:** 03.03.2026 r.
**Imię i nazwisko:** Mateusz Wiech
**Nr indeksu:** 423393
**Grupa:** 6
**Branch:** MW423393

---

## 0. Środowisko

Ćwiczenie wykonano w środowisku linuksowym (Ubuntu Server 24.04.4 LTS) działającym na maszynie wirtualnej z wykorzystaniem klienta `git` (2.43.0) i `OpenSSH` (9.6p1). Połączenie z maszyną realizowano przez SSH. Repozytorium było obsługiwane z poziomu terminala oraz edytora Visual Studio Code.

---

## 1. Git

Zainstalowano klienta `git` oraz narzędzia SSH w systemie.

![Instalacja Git i SSH](./SS/01/apt_install.png)

Skonfigurowano dane użytkownika Git.

![Konfiguracja Git](./SS/01/git_config.png)

Repozytorium przedmiotowe sklonowano przez HTTPS z użyciem Personal Access Token.

![Klonowanie repozytorium przez HTTPS](./SS/01/git_clone_https.png)

---

## 3. SSH

Utworzono dwa klucze SSH typu `ed25519`, w tym jeden zabezpieczony hasłem.

![Tworzenie kluczy SSH](./SS/01/ssh-keygen.png)

Dodano klucze do agenta SSH i skonfigurowano dostęp do GitHub przez SSH.

![Dodanie klucza do ssh-agent](./SS/01/ssh-add.png)

Oba klucze publiczne zostały pomyślnie dodane do konta na GitHub-ie.

![Klucze SSH na GitHub](./SS/01/SSH_keys_github.png)

Repozytorium sklonowano również z użyciem protokołu SSH.

![Klonowanie repozytorium przez SSH](./SS/01/git_clone_ssh.png)

Włączono uwierzytelnianie dwuskładnikowe na koncie GitHub.

![Konfiguracja 2FA](./SS/01/2FA.png)

---

## 4. Narzędzia

Skonfigurowano dostęp do maszyny i repozytorium w Visual Studio Code.

![VS Code Remote SSH](./SS/01/vscode.png)

Skonfigurowano wymianę plików z użyciem FileZilla przez SFTP.

![FileZilla SFTP](./SS/01/FileZilla.png)
![FileZilla key](./SS/01/FileZilla_key.png)

---

## 5. Gałąź

Przełączono się na gałąź `main`, następnie na gałąź grupową `grupa6`.

![Przełączenie na main i gałąź grupy](./SS/01/git_checkout.png)

Na podstawie gałęzi grupowej utworzono własną gałąź `MW423393` i rozpoczęto na niej pracę.

![Utworzenie własnej gałęzi](./SS/01/git_branch.png)

W katalogu właściwym dla grupy utworzono katalog `MW423393`.

![Utworzenie katalogu](./SS/01/mkdir.png)

---

## 6. Git hook

Przygotowano skrypt `commit-msg`, który sprawdza, czy każdy komunikat commita zaczyna się od `MW423393`.

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

![Treść pliku commit-msg](./SS/01/commit-msg.png)

Skrypt dodano do katalogu `MW423393`, a następnie skopiowano do `.git/hooks/commit-msg`, aby był uruchamiany przy każdym commicie.

![Instalacja hooka](./SS/01/git_hook.png)

Sprawdzenie działania hooka.

![Test hooka](./SS/01/git_commit_test.png)

Poprawny commit.

![Poprawny commit](./SS/01/git_commit.png)

Wysłanie zmian do zdalengo źródła.

![Wysłanie zmian](./SS/01/git_push.png)

---

## 7. Pull request

Po wysłaniu zmian stworzono Pull Request z własnej gałęzi do gałęzi grupy z pomocą odpowiedniego mechanizmu na GitHubie.

![Pull request](./SS/01/pull_request.png)

Status utworzonego Pull Requesta.

![Potwierdzenie Pull request](./SS/01/pull_request_confirm.png)

Brak konfliktów merge'owania - może odbyć się automatycznie.
Na koniec zaktualizowano sprawozdanie o brakujące kroki, utworzono nowy commit i przesłano aktualizację do zdalnego źródła.

---