# Sprawozdanie Lab9 Tomasz Kamiński

## Utworzenie nowej maszyny z fedora

Wykorzystano obraz Fedora-Server-netinst-x86_64-44-1.7.iso

![](./img/image1.png)


## Przygotowanie pliku kickstar

Skrypt kickstar służy do całkowitego zautomatyzowania procesu instalacji systemu operacyjnego, zamiast ręcznie wybierać opcje w interfejsce graficznym modyfikujemy plik konfiguracyjny z którego instalator będzie korzystał.

Zmodyfikowany plik anaconda-ks.cfg: 

![](./img/image2.png)



## Automatyczna instalacja nienadzorowana


Zmieniono tryb sieci w ustawieniach obu maszyn z NAT na Kartę sieciową typu mostek oraz wyłączono firewall na pierwszej maszynie, aby odblokować ruch przychodzący na porcie 8080.



Na zainstalowanej maszynie uruchomiono serwer HTTP za pomocą Pythona, aby udostępnić plik anaconda-ks.cfg:

![](./img/image12.png)



Wskazanie instalatorowi przygotowanego pliku odpowiedzi:

![](./img/image7.png)

![](./img/image9.png)

![](./img/image10.png)

Instalacja przebiegła poprawnie, nowa maszyna pomyślnie połączyła się z serwerem http i pobrała plik .cfg 


Logowanie na nowo utworzonej maszynie Fedora-new 

![](./img/image13.png)



Zmodyfikowany plik anaconda-ks.cfg: 

![](./img/image15.png)


Logowanie na nowo utworzonej maszynie Fedora-new(hostname tk)

![](./img/image17.png)