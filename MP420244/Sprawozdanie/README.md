# 0. Wstęp
Zadania zostały wykonane w środowisku Oracle VirtualBox na maszynie wirtualnej z obrazem systemu Ubuntu.

# 1. Instalacja
Zainstalowane zostały: klient git oraz klient i serwer SSH.

![Instalacja gita](images/1.%20Instalacja%20gita.png)

![Instalacja klienta SSH](images/2.%20Instalacja%20klienta%20SSH.png)

![Instalacja serwera SSH](images/3.%20Instalacja%20serwera%20SSH.png)

Lista poleceń:
* sudo apt-get install git-all
* sudo apt install openssh-client
* sudo apt install openssh-server

# 2. Klonowanie przez HTTPS
Żeby sklonować repozytorium przez HTTPS nie potrzeba dodatkowej konfiguracji. Odpowiednie uprawnienia są wystarczające:

![Klonowanie repozytorium przez HTTPS](images/4.%20Skopiowanie%20repo%20z%20HTTPS.png)

* git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

# 3. Klonowanie przez SSH
Klonowanie przez SSH wymaga odpowiedniego przygotowania. Należy wygenerować parę kluczy ssh: prywatny i publiczny.

* ssh-keygen -t ed25519 -C "email@example.com"

Klucz prywatny ma być umieszczony w ukrytym folderze .ssh, a jego treść nie powinna zostać nikomu zdradzona.

Klucz publiczny należy umieścić na zdalnym repozytorium GitHub:

![Dodanie klucza SSH do GitHuba](images/5.%20Dodanie%20klucza%20SSH%20do%20GitHuba.png)

Po dodaniu klucza można przetestować połączenie:

![Weryfikacja połączenia SSH](images/6.%20Weryfikacja%20połączenia%20SSH.png)

* (ssh -T git@github.com)

Jeżeli wszystko działa, możliwe jest sklonowanie repozytorium:

![Klonowanie repozytorium przez SSH](images/7.%20Skopiowanie%20repo%20z%20SSH.png)

* git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

# 4. Konfiguracja narzędzi

## Dostęp do maszyny wirtualnej przez VSCode
Żeby uzyskać zdalny dostęp do maszyny wirtualnej przez IDE należy zainstalować odpowiednie rozszerzenie, w tym przypadku "Remote -SSH". Potrzebna jest też nowa para kluczy ssh: klucz prywatny w folderze użytkownika (np. C:/users/user/), a klucz publiczny w pliku "authorized_keys" w ukrytym folderze .ssh na maszynie wirtualnej.

Kolejne kroki:
1. Uruchomić SSH na maszynie wirtualnej: "sudo systemctl start ssh";
2. Skonfigurować firewall: "sudo ufw allow ssh";
3. W "Command Palette..." dostępne pod skrótem [CTRL][SHIFT][P] wybrać opcję "Remote-SSH: Connect to Host...";
4. Podać adres hosta SSH według szablonu: "ssh nazwa@adres";
5. Podać hasło hosta.

Po wykonaniu tych kroków możliwe jest zdalne połączenie się z urządzeniem:

![Połączenie SSH w VSCode](images/8.%20Połączenie%20przez%20SSH%20w%20VSCode.png)

Należy upewnić się, że sieć w środowisku wirtualnym jest ustawiona na "bridged". Jeżeli nie działa ona poprawnie, co zdaża się na systemie Windows, przełączenie sieci na NAT i konfiguracja port forwarding'u rozwiązuje problem. Wtedy podczas podawania adresu hosta SSH w kroku drugim należy dopisać numer portu udostępnianego przez hosta: "ssh nazwa@adres -p nr_portu".

## Konfiguracja współdzielonego folderu
Konfiguracja przestrzeni współdzielonej przebiega następująco:

1. W ustawieniach VirtualBox, w zakładce "Współdzielone foldery" dodać udostępniany folder.
![Opcje współdzielania folderów](images/9.%20Współdzielone%20foldery.png)

2. Wyznaczyć ścieżkę i nazwę folderu oraz zaznaczyć opcje automatycznego montowania i machine-permanance.
![Edycja udziału](images/10.%20Edytuj%20udział.png)

3. Zainstalować odpowiednie pakiety na wirtualizowanym systemie, przygotować katalogi i przeprowadzić reboot:
* sudo apt install build-essential dkms linux-headers-$(uname -r)
* sudo mkdir /media/cdrom
* sudo mount /dev/cdrom /media/cdrom
* sudo sh /media/cdrom/VBoxLinuxAdditions.run
* sudo reboot

Po ponownym uruchomieniu systemu, folder będzie umieszczony w katalogu /media/:
![Współdzielona treść](images/11.%20Współdzielona%20treść.png)

# 5. Praca na gałęzi

Lista poleceń:

Tworzenie gałęzi i folderu:
* git switch -c MP420244
* mkdir MP420244

Tworzenie git hook'a:
* touch commit-msg
* mv commit-msg .git/hooks/

Tworzenie pliku ze sprawozdaniem:
* mkdir MP420244/Sprawozdanie
* touch MP420244/Sprawozdanie/README.md

Wysłanie pull request'a:
* git add .
* git commit -m 'MP420244: oddanie sprawozdania'
* git push origin MP420244

Używając interfejsu GitHub'a stworzony zostaje pull request wciągnięcia zmian wprowadzonych na obecnej gałęzi do grupy 5:

![Pull request](images/12.%20Pull%20request.png)

Treść hook'a:
```
#!/bin/sh

my_custom_begin="MP420244"

if grep -q "^$my_custom_begin" "$1"; then
    echo "Commit message is valid."
    exit 0
else
    echo "Commit message is invalid. It should start with '$my_custom_begin'."
    exit 1
fi
```