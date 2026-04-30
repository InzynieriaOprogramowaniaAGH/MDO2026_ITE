# Srodowisko
Ćwiczenie wykonywane było na Ubuntu Serverze, pracującym na maszynie wirtualnej oraz w terminalu hosta połączonym przez SSH z wirtualką.

1. Git
Instalacja klienta Git i obsługa kluczy SSH na maszynie wirtualnej:
![1](1.png)

2. Klucze SSH
Utworzenie dwóch kluczy SSH
![2](2.png)

![3](3.png)

Konfiguracja klucza SSH jako metoda dostępu do GitHuba:
![4](4.png)

Sklonowanie repozytorium z wykorzystaniem SSH:
![5](5.png)

Konfiguracja uwierzytelniania dwuskładnikowego na koncie GitHub:
![6](6.png)

3. Narzędzia
Konfiguracja Visual Studio Code:
![7](7.png)

Zainstalowanie FileZilla + konfiguracja:
![8](8.png)

4. Gałąź

Przełączenie się na gałąź main, a potem na gałąź swojej grupy,
utworzenie gałęzi o nazwie "inicjały & nr indeksu"
![9](9.png)

![10](10.png)

Skrypt:
#!/bin/bash

if [[ "$1" != KW423138* ]]; then
echo "Commit message musi zaczynać się od KW423138"
exit 1
fi

![11](11.png)

![12](12.png)

![13](12.png)

