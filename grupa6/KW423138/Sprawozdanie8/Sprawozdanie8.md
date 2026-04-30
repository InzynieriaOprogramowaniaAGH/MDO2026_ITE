# Sprawozdanie - zajęcia 8
---
## Wprowadzenie - przygotowanie środowiska

Przed rozpoczęciem laboratorium zainstalowano ansible na głównej maszynie oraz utworzono drugą maszynę wirtualną `ansible-target`
Wymieniono klucze ssh między maszyną główną a ansible-target, aby było możliwe szybkie logowanie bez podawania hasła.

Kopiowanie klucza nastąpiło za pomocą komendy:
```ssh-copy-id ansible@ansible-target```
Następnie można było przystąpić do realizacji ćwiczenia.

## Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible
Nazwy maszyny i użytkownika ansible i ansible-target były ustawiane podczas instalacji.

1. Wprowadzenie nazw DNS dla maszyn wirtualnych.

![1](obrazyLab8/00.png)
![2](obrazyLab8/04.png)
2. Weryfikacja łączności przez SSH bez hasła.

![3](obrazyLab8/03.png)

3. Stworzenie pliku inwentaryzacji.

![4](obrazyLab8/05.png)

4. Wysłanie rządania ping do wszystkich maszyn.

![5](obrazyLab8/01.png)
![6](obrazyLab8/02.png)
![7](obrazyLab8/07.png)

### Zdalne wywoływanie procedur za momocą playbooka

Doinstalowanie wymaganych zależności:
![8](obrazyLab8/14.png)

1. Utworzenie pliku `playbook.yaml` w którym uwzględniono wszystkie poniższe kroki, a następnie uruchomiono:
- wysłanie żądanie ping do wszystkich maszyn
- skopiowanie pliku inwentaryzacji na maszynę Endpoints
- zaktualizowanie pakietów
- zrestartowanie usługo ssh i rngd

plik `playbook.yaml`:
![9](obrazyLab8/17.png)

Uruchomienie:
![10](obrazyLab8/16.png)

2. Przeprowadzenie operacji z wyłączonym serwerem SSH:
![11](obrazyLab8/18.png)

Zgodnie z oczekiwaniami błąd został złapany.

### Zarządzanie stworzonym artefaktem

Utworzono nowy plik: `playbook2.yaml` i uruchomiono go.
Instalacja docker, uruchomienie kontenera, pobranie dockerHub, zweryfikowanie łączności z kontenerem, zatrzymanie i usunięcie kontenera:

![12](obrazyLab8/19.png)
![13](obrazyLab8/20.png)
![14](obrazyLab8/21.png)
![15](obrazyLab8/22.png)
![16](obrazyLab8/23.png)
![17](obrazyLab8/24.png)
![18](obrazyLab8/25.png)

### Sanity Check

![19](obrazyLab8/26.png)

### Rola ansible

Utworzenie roli, sprawdzenie struktury:
![20](obrazyLab8/27.png)
![21](obrazyLab8/28.png)

Wypełnienie `meta/main.yaml`, użycie roli:
![22](obrazyLab8/29.png)
![23](obrazyLab8/30.png)


Upewnienie się czy inwentory działają, uruchomienie roli, sprawdzenie czy docker działa na ansible-target:

![24](obrazyLab8/31.png)
![25](obrazyLab8/32.png)
![26](obrazyLab8/33.png)

Struktura została umieszczona w katalogu Sprawozdanie8 w podkatalogu `myrole`.
