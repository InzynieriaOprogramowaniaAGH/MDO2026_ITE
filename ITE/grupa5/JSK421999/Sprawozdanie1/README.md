# Sprawozdanie z laboratorium 1

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Git

### Instalacja klienta Git i klonowanie repozytorium przez HTTPS

Wygenerowanie personal access token na GitHubie:

![Personal Access Token](img/personalToken.jpg)

Klonowanie repozytorium przedmiotowego przez HTTPS z użyciem tokena:

![Klonowanie repo HTTPS](img/Klonowanie_repo_https.jpg)

---

## 2. SSH

### Test połączenia z serwerem devops

Połączenie SSH z serwerem devops:

![Test połączenia SSH z devops](img/setup_ssh.jpg)

### Generowanie kluczy SSH

Wygenerowanie dwóch kluczy SSH (innych niż RSA), jeden zabezpieczony hasłem:

![Generowanie kluczy SSH](img/gen_ssh_2x.jpg)

### Konfiguracja klucza SSH na GitHubie

Dodanie klucza publicznego i test git clone'a:

![Dodanie klucza SSH do GitHuba](img/DodanieKluczaSsh.jpg)

### Uwierzytelnianie dwuskładnikowe (2FA)

Włączenie 2FA na koncie GitHub:

![2FA GitHub](img/2FA.jpg)

---

## 3. Narzędzia

### IDE — Visual Studio Code z SSH

Konfiguracja VS Code do pracy zdalnej przez SSH:

![VS Code SSH](img/vscodeSSH.jpg)

### Wymiana plików — FileZilla

Konfiguracja FileZilla do wymiany plików ze środowiskiem:

![FileZilla](img/filezilla.jpg)

---

## 4. Gałąź

### Przełączenie na main i gałąź grupy, utworzenie własnej gałęzi

Checkout na `main`, potem na branch grupy i utworzenie gałęzi `JSK421999`:

![Checkout main i grupa](img/checkoutmainGrupa.jpg)

### Git Hook — commit-msg

Napisanie hooka weryfikującego prefiks `JSK421999` w commit message.

Treść hooka (`commit-msg`):

```bash
#!/bin/bash

COMMIT_MSG=$1

FIRST_LINE=$(head -n 1 "$COMMIT_MSG")

MOJ_PREFIKS="JSK421999"

if [[ "$FIRST_LINE" != "$MOJ_PREFIKS"* ]]; then
    echo "==========================================================="
    echo "BŁĄD: Brak inicjalu"
    echo "Oczekiwano na początku: '$MOJ_PREFIKS'"
    echo "Twoja wiadomość:        '$FIRST_LINE'"
    echo "==========================================================="
    
    exit 1
fi

exit 0
```

### Konfiguracja hooka

Skopiowanie skryptu do `.git/hooks/commit-msg` i nadanie uprawnień:

![Setup hook](img/setup_hook.jpg)

### Poprawka i działanie hooka

Poprawka hooka po testach:

![Hook fix](img/hook_fix.jpg)

Hook działa poprawnie — commit z prefiksu jest poprawnie akceptowany:

![Działający hook](img/working_hook.jpg)

---
