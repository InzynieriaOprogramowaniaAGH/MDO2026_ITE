{\rtf1\ansi\ansicpg1251\cocoartf2818
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Sprawozdanie z \uc0\u262 wiczenia 1\
\
**Imi\uc0\u281 , nazwisko i numer indeksu:** Tatsiana Merzianiova TM424276  \
**Grupa:** 4  \
**\uc0\u346 rodowisko uruchomieniowe:** * Host: macOS (Apple Silicon)  \
* Maszyna Wirtualna: Ubuntu Server 24.04 ARM64 (VirtualBox)  \
\
\
\
### 1. Zalogowanie do maszyny\
Do wirtualnej maszyny zalogowano si\uc0\u281  poprzez protok\'f3\u322  SSH u\u380 ywaj\u261 c wbudowanego terminala systemu macOS oraz polecenia `ssh -p 2222 tatsiana@127.0.0.1`. \
Skonfigurowano r\'f3wnie\uc0\u380  narz\u281 dzia wspieraj\u261 ce prac\u281  zdaln\u261 :\
* **FileZilla:** Zestawiono po\uc0\u322 \u261 czenie SFTP do wymiany plik\'f3w ze \u347 rodowiskiem pracy.\
* **Visual Studio Code:** Zainstalowano wtyczk\uc0\u281  `Remote - SSH` i dodano wpis w pliku konfiguracyjnym `~/.ssh/config` w celu automatyzacji \u322 \u261 czenia si\u281  z maszyn\u261 .\
\
![Ustawienia VS Code SSH](img/config_vscode.png)\
![Po\uc0\u322 \u261 czenie z maszyn\u261  w VS Code](img/vscode.png)\
![Wymiana plik\'f3w w programie FileZilla](img/fileZilla.jpeg)\
\
### 2. Instalacja Git\
Z poziomu terminala zaktualizowano repozytoria pakiet\'f3w i zainstalowano system kontroli wersji Git komendami:\
```bash\
sudo apt update\
sudo apt install git\
```\
\
### 3. Konfiguracja u\uc0\u380 ytkownika Git\
Przed rozpocz\uc0\u281 ciem pracy z repozytorium skonfigurowano globalne dane to\u380 samo\u347 ci u\u380 ytkownika:\
```bash\
git config --global user.name "zni4ka"\
git config --global user.email \'abtania\'bb.merziniova@gmail.com\
```\
\
### 4. Klonowanie przez HTTPS\
Sklonowano repozytorium przedmiotowe po HTTPS. Zamiast standardowego has\uc0\u322 a, na stronie wygenerowano i u\u380 yto klucza **Personal Access Token (PAT)**.\
```bash\
git clone [https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git](https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git)\
```\
\
### 5. Utworzenie kluczy SSH\
Zgodnie z wymaganiami wygenerowano dwa klucze oparte na algorytmach innych ni\uc0\u380  RSA:\
1. Klucz zabezpieczony has\uc0\u322 em (ED25519): `ssh-keygen -t ed25519 -C "email" -f ~/.ssh/id_ed25519_haslo`\
2. Klucz bez has\uc0\u322 a (ECDSA): `ssh-keygen -t ecdsa -b 521 -C "email" -f ~/.ssh/id_ecdsa_bezhasla`\
\
Klucz publiczny zosta\uc0\u322  dodany do profilu GitHub, a samo konto zabezpieczono uwierzytelnianiem dwusk\u322 adnikowym (2FA).\
\
![Generowanie kluczy SSH](img/generowaniekluczy.png)\
![W\uc0\u322 \u261 czenie 2FA na koncie GitHub](img/2FA.png)\
\
### 6. Klonowanie repozytorium z u\uc0\u380 yciem SSH\
Po zweryfikowaniu dzia\uc0\u322 ania po\u322 \u261 czenia, pomy\u347 lnie pobrano repozytorium ponownie, tym razem wykorzystuj\u261 c protok\'f3\u322  SSH:\
```bash\
git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git\
```\
\
### 7. Utworzenie w\uc0\u322 asnej ga\u322 \u281 zi\
Wewn\uc0\u261 trz pobranego repozytorium prze\u322 \u261 czono si\u281  na ga\u322 \u261 \u378  dedykowan\u261  grupie czwartej, a nast\u281 pnie utworzono z niej w\u322 asn\u261 , oddzieln\u261  ga\u322 \u261 \u378 . Na nowej ga\u322 \u281 zi stworzono wymagan\u261  struktur\u281  folder\'f3w.\
```bash\
git checkout grupa4\
git checkout -b TM424276\
mkdir -p ITE/grupa4/TM424276\
```\
\
### 8. Githook\
Napisano skrypt bashowy pilnuj\uc0\u261 cy poprawno\u347 ci wiadomo\u347 ci wprowadzanych przy zatwierdzaniu zmian (commit). Plik ze skryptem umieszczono w ukrytym katalogu `.git/hooks/commit-msg` i nadano mu uprawnienia do wykonywania. \
\
**Kod skryptu:**\
```bash\
#!/bin/bash\
MSG_FILE=$1\
COMMIT_MSG=$(head -n 1 "$MSG_FILE")\
PREFIX="TM424276"\
if [[ ! $COMMIT_MSG =~ ^$PREFIX ]]; then\
    echo "BLAD: Wiadomosc commita musi zaczynac sie od $PREFIX"\
    exit 1\
fi\
```\
**Weryfikacja:** Pr\'f3ba wykonania commita bez wymaganego prefiksu zablokowa\uc0\u322 a operacj\u281  i wyrzuci\u322 a b\u322 \u261 d w terminalu. Zmiana formatu wiadomo\u347 ci na poprawny pozwoli\u322 a z sukcesem doda\u263  rewizj\u281 .\
\
![Dzia\uc0\u322 anie blokady skryptu Git Hook](img/hook_blad.png)}