1.	Powiązanie terminala z Dockerem wewnątrz Minikube:
```bash
eval $(minikube docker-env)
```
2.	Zbudowanie Wersji 1 (v1);
 
 ![alt text](img/image.png)
 
3.	Zbudowanie Wersji 2 (v2):
 
![alt text](img/image-1.png)

4.	Zbudowanie Wersji 3 (v3-broken - celowo uszkodzona):
 
![alt text](img/image-2.png)

5.	Weryfikacja (wyświetli tabelkę z obrazami)
 
![alt text](img/image-3.png)

6.	Utworzenie pliku YAML dla nowej aplikacji
 
![alt text](img/image-4.png)

7.	Uruchomienie wdrożenia
 
![alt text](img/image-5.png)

8.	Aktualizacje pliku YAML
    •   Zwiększenie replik do 8:

    ![alt text](img/image-6.png)

    •	Zmniejszenie liczby replik do 1:  

    ![alt text](img/image-7.png)

    •	Zmniejszenie liczby replik do 0 :  

    ![alt text](img/image-8.png)

    •	Ponowne przeskalowanie w górę do 4 replik (stan docelowy): 

    ![alt text](img/image-9.png)

    •	Zastosowanie nowej wersji obrazu (v2) 

    ![alt text](img/image-10.png)

    •	Zastosowanie starszej wersji obrazu (v1)  

    ![alt text](img/image-11.png)
    
    •	Wdrożenie "wadliwego" obrazu (v3-broken) 

    ![alt text](img/image-12.png)

9.	Analiza historii wdrożeń

![alt text](img/image-13.png)

10.	Wycofanie zepsutej wersji i powrót do działającej (v2)  

![alt text](img/image-14.png)

11.	Utworzenie skryptu weryfikującego 

![alt text](img/image-15.png)

12.	Nadanie uprawnień i test skryptu 

![alt text](img/image-16.png)

13.	Utworzenie uniwersalnego Serwisu kierującego ruchem 

![alt text](img/image-17.png)

14.	Wersje wdrożeń
    
    •	STRATEGIA 1: Recreate 

    ![alt text](img/image-18.png)

    Obserwacje

    ![alt text](img/image-19.png)

    ![alt text](img/image-20.png)

    Wszystkie 4 stare kontenery w ułamku sekundy wejdą w stan Terminating (Zabijanie). Zanim nowe zaczną się tworzyć (ContainerCreating), przez moment nie będziesz miała ani jednego działającego kontenera.
    
    •	STRATEGIA 2: Rolling Update 

    ![alt text](img/image-21.png)

    obserwacje 

    ![alt text](img/image-22.png)

    Kubernetes najpierw stworzy nowe kontenery, a stare będzie wyłączał powoli, sztuka po sztuce. Zawsze będziesz miała co najmniej kilka podów w stanie Running. Aplikacja ani przez sekundę nie przestanie działać z punktu widzenia klienta.
    
    •	STRATEGIA 3: Canary Deployment 

    ![alt text](img/image-23.png)

    Obserwacje
 
    ![alt text](img/image-24.png)

