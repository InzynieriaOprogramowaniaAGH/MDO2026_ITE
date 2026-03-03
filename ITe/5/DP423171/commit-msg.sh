#!/bin/sh
ME="$(which "$0")"
MDIR="${ME%/*}"
PDIR="${ME%/*/*}"
USR=DP423171
HOOK_NAME="$(basename $0 .sh)"

if [ "$(basename "$MDIR")" == "hooks" ] && [ "$(basename "$PDIR")" == ".git" ] && [ "$(basename "$ME")" == "$HOOK_NAME" ]; then
    ### 1. Wywołanie logiki hook'a
    case $HOOK_NAME in
        ## Walidacja autora (opcjonalny kod, bo to całkiem przydatna rzecz na przyszłość)
        pre-commit)
            COMMITER="$(git var GIT_COMMITTER_IDENT | sed -n 's/^\(.*\) <.*> .*/\1/p')"
            if [ "$COMMITER" == "$USR" ]; then
                exit 0
            fi
            echo "ERR: Invalid commiter name \"$COMMITER\"!" >&2;
            exit 1
            ;;
        ## Walidacja wiadomości (część wymagana)
        commit-msg)
            COMMITMSG_PREFIX="$(head -n1 "$1" | cut -b-$(printf "$USR" | wc -c))"
            if [ "$COMMITMSG_PREFIX" == "$USR" ]; then
                exit 0
            fi
            echo "ERR: Message not prefixed with \"$USR\""
            exit 1
            ;;
    esac
else
    ### 2. Auto instalka skryptu z złej ścieżki
    printf " --- Tryb instalacji hook'a... "
    # INFO: instalujemy poszukując .git z katalogu skryptu w kolejnych krokach
    #       warunkiem zakończnenia jest '/'
    # FIXME: może startować z PWD? nasz use-case w sumie to hook w repo skryptu,
    #        ale standardowo skrypty tego typu używają PWD.
    SEARCH_PATH="$MDIR/"
    while [ -n "$SEARCH_PATH" ]; do
        # Krążenie po ścieżkach rodzicielskich
        SEARCH_PATH="${SEARCH_PATH%/*}"
        # Warunek poprawności przeszukiwania
        if [ -d "${SEARCH_PATH}/.git" ] && [ -d "${SEARCH_PATH}/.git/hooks" ]; then
            INSTALL="$SEARCH_PATH/.git/hooks/$HOOK_NAME"
            if [ -f "$INSTALL" ]; then
                # Bulletproof backup
                mv "$INSTALL" "$INSTALL.old"
            fi
            ln -s "$ME" "$INSTALL"
            chmod +x "$INSTALL"
            if [ ! -f "$INSTALL" ]; then
                echo "ERR: Nie zainstalowano"
                exit 1
            fi
            if [ ! -x "$INSTALL" ]; then
                echo "ERR: Hook to nie plik wykonywalny"
                exit 2
            fi
            echo "OK"
            exit 0
        fi
    done
    echo 'ERR: Nie znaleziono repozytorium .git' >&2
    exit 3
fi
