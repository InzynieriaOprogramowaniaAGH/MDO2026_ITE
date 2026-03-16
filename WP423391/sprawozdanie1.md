# Sprawozdanie - Laboratorium 1
## Wojciech Pieńkowski
---
### Git
Na maszynie wirtualnej Oracle Virtual box pobrałem obraz Ubuntu,
najpierw zainstalowałem gita oraz obsługę kluczy ssh.
![pobranie git](sprawozdanie1/1.png)
![pobranie ssh](sprawozdanie1/ssh.png)

Następnie w ustawieniach deweloperskich profilu github utworzyłem personal access token,    a potem skolowałem nasze repozytorium z pomocą HTTPS
![sklonowanie HTTPS](sprawozdanie1/https.png)

### SSH
W kolejnej części utworzyłem dwa klucze ssh, jeden z hasłem a drugi bez, przy uwadze że nie mogą znajdywać się w tym samym folderze
![klucz1](sprawozdanie1/2.png)
![klucz2](sprawozdanie1/3.png)
oraz skopiowałem publiczny klucz w celu dodania go w ustawieniach jako metody dostępu do github

```bash
 cat ~/.ssh/id_ed25519_klient1.pub
```

![ssh](sprawozdanie1/4.png)

po utworzeniu kluczy pozostało sklonować repozytorium za pomocą protokołu ssh
![clone](sprawozdanie1/5.png)

### Narzędzia
Kolejną częścią było skonfigurowanie dostępu do repozytorium w edytorze IDE, w tym celu pobrałem rozszerzenie Remote-SSH w Visual Studio Code, a następnie za pomocą ip serwera linux połączyłem się z wirtualną maszyną

![vsc](sprawozdanie1/6.png)

Dzięki temu, że wybrałem VSC nie musiałem pobierać dodatkowego menadżera plików, ponieważ wystarczy przeciągniecie plików z komputera do folderu wyświetlonego w edytorze.

### Gałąź

Ostatnią częścią było utworzenie własnej gałęzi oraz wykonanie na niej pracy, zadanie rozpocząłem od przełączenie się na gałąź main, a następnie swojej grupy. 
Następnie utworzyłem gałąź o nazwie WP423391

![galaz](sprawozdanie1/7.png)

Na nowej gałęzi mialem utworzyć git hooka, który miał za zadanie weryfikować czy każdy mój commit zaczyna się od moich inicjałów i numeru indeksu

![kod](sprawozdanie1/trescskryptu.png)

Test skryptu: 
![testbledny](sprawozdanie1/test1.png)
![testpopr](sprawozdanie1/test2.png)

Dodanie pull requesta:
![pullrq](sprawozdanie1/pull.png)
