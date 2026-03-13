# Sprawozdanie - DevOps - Lab 1 - Andrzej Janaszek

## Narzędzia i konfiguracja:

### Konfiguracja maszyny wirtualnej
Ustawienie przekierowania portu Host:2137 na VM:22 (ssh)

#### Konfiguracja VS Code i Remote SSH (wtyczka)
Zainstalowanie wtyczki Remote SSH (Microsoft) i skonfigurowanie połączenia

![Konfiguracja VS Code i Remote SSH (wtyczka)](./img/img01_vscode_remote_ssh.png)

### Konfiguracja połączenia SFTP w File Zilla
![Konfiguracja połączenia SFTP w File Zilla](./img/img02_filezilla.png)

### Utworzenie klucza SSH i dodanie go na githubie
![Utworzenie klucza SSH ](./img/img03_klucz_ssh_vm.png)

![dodanie go na githubie](./img/img04_klucz_ssh_github.png)

## Klonowanie

### Klonowanie repo HTTP
![Klonowanie repo HTTP](./img/img05_klonowanie_http.png)

### Klonowanie repo SSH
![Klonowanie repo SSH](./img/img06_klonowanie_ssh.png)

## Branching

#### Przełączenie się na branch grupy
![Przełączenie się na branch grupy](./img/img07_branch_grupa.png)

#### Utworzenie własnego brancha
![Utworzenie własnego brancha](./img/img08_branch_wlasny.png)

## Git Hook

### Utworznie Git Hook'a do weryfikacji prefixu

Kod hooka
```bash
#!/bin/bash

PREFIX="AJ420697"
msg="$(cat "$1")"

if [[ $msg =~ ^$PREFIX ]]; then
    echo "[OK]: jest prefix w commit msg"
    exit 0
else
    echo "[ERROR]: Commit musi zaczynać się od prefixa inicjały i nr"
    exit 1
fi
```

## Pull Request
![](./img/img09_pull_request.png)