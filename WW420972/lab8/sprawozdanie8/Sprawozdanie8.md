## 1. Setup nowej maszyny
Utworzenie maszyny:

![](nowamaszyna.png)

Pierwsze uruchomienie:   

![](pierwsze-uruchomienie.png)

Posiada tar:   

![](tar.png)

Utworzono snapshota i wyeksportowano ją:   

![](snapshot.png)   

![](export.png)

Pobranie ansible:

![](ansible.png)


## 2. Inwentaryzacja i zdalne wywoływanie procedur
Sprawdzenie łączności:   

![](ping.png)

Ustawienie nazw:

![](nazwy.png)

![](etc-hosts.png)

Plik `inventory.ini`

![](inventoryini.png)

Plik inwentaryzacyjny:  

![](inwentaryzacja2plik.png)

![](inwentaryzacja2.png)

# Role

Utworzenie folderu na role przy pomocy komendy `ansible-galaxy role init docker_deploy`:

![](folder-role.png)

Plik `meta/main.yml`

![](meta.png)

Uruchomienie roli:

![](deploy-role.png)

Dodatkowo dodano zmiany w pliku `tasks/main.yml`

Rezultat:

![](zadanie_final.png)
