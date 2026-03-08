## 1. Dostęp do maszyny

![Logowanie SSH](ssh.png)

## 2. Zainstalowany Git

![Instalacja Git](git_zainstalowany%20.png)

## 3. Zalogowany Git

![Logowanie Git](gh_login.png)

## 4. Konfiguracja VS Code Remote

![VS Code Remote](vscode_remote.png)

## 5. Praca na gałęziach

![Własny branch](swoj_branch.png)

## 6. Konfiguracja git hooka

![Git Hook](git_hook.png)

Git hook o treści:
```bash
#!/bin/bash

PREFIX="DS419547"

COMMIT_MSG=$1

if ! grep -q "^$PREFIX" "$COMMIT_MSG"; then
        echo "Commit musi zaczynać się od $PREFIX"
        exit 1
fi

exit 0
```

## 7. Pull Request

![PR](pr.png)