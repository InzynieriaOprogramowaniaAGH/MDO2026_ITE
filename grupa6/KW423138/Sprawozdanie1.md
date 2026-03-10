# Srodowisko
Ćwiczenie wykonywane było na Ubuntu Serverze, pracującym na maszynie wirtualnej oraz w terminalu hosta połączonym przez SSH z wirtualką.

1. Git
Instalacja klienta Git i obsługa kluczy SSH na maszynie wirtualnej:
![1](instalacja git i ssh w VM.png)

2. Klucze SSH
Utworzenie dwóch kluczy SSH
![2](utworzenie klucza1.png)
![3](utworzenie klucza2.png)

Konfiguracja klucza SSH jako metoda dostępu do GitHuba:
![4](dodanie klucza do github.png)

Sklonowanie repozytorium z wykorzystaniem SSH:
![5](klonowanie repo przez SSh.png)

Konfiguracja uwierzytelniania dwuskładnikowego na koncie GitHub:
![6](założenie autoryzacji 2F.png)

3. Narzędzia
Konfiguracja Visual Studio Code:
![7](Konfiguracja Visual Studio Code.png)

Zainstalowanie FileZilla + konfiguracja:
![8](Dostęp przez FileZilla.png)

4. Gałąź

Przełączenie się na gałąź main, a potem na gałąź swojej grupy,
utworzenie gałęzi o nazwie "inicjały & nr indeksu"
![9](Gałęzie Git.png)
![10](Gałęzie Git2.png)

Skrypt:
#!/bin/bash

if [[ "$1" != KW423138* ]]; then
echo "Commit message musi zaczynać się od KW423138"
exit 1
fi

![11](katalog, skrypt.png)
