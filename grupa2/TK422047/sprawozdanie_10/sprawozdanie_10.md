# Sprawozdanie Lab10, Tomasz Kamiński

 ## Instalacja minikube
 
![](./img/image1.png)

![](./img/image2.png)



 ## Zaopatrzenie się w polecenie kubectl

Ustawiono alias minikubctl zgodnie z rekomendacją w instrukcji.

![](./img/image4.png)

 ## Uruchomienie Klastra

Przy pierwszej próbie uruchomienia Minikube się nie odpalał ze względu na za małą ilość przydzielonych zasobów, w ustawnieniach maszyny wirtualnej zwiększono liczbe procesorów do 2 oraz podniesiono limit pamieci RAM. Po restarcie klaster wystartował już bez żadnych problemów na nowo utworzonym użytkowniku.

![](./img/image9.png)


Mechanizm Kubernetes zabrania uruchomienia drivera Docker z uprawnieniami roota

![](./img/image6.png)


Utworzenie nowego użytkownika
``` 
useradd Tomasz 
passwd Tomasz
    
//dodanie użytkownika do grupy Dockera
usermod -aG docker Tomasz
su -u Tomasz
``` 

Prawidłowe uruchomienie klastra:

![](./img/image7.png)



Sprawdzenie działającego węzła:

 
![](./img/image8.png)

# Uruchomienie interfejsu graficznego 

![](./img/image11.png)

![](./img/image10.png)

Weryfikacja łączności lokalnej:

![](./img/image12.png)

Ponieważ system operacyjny hosta nie ma bezpośredniego dostępu do adresu localhost maszyny wirtualnej, wykorzystano tunelowanie portów przez protokół SSH ```ssh -L 40381:127.0.0.1:40381```. Komendę tę zastosowano w celu zmapowania odizolowanego portu wirtualki na port lokalny fizycznego komputera i odpalenie dashbordu w przeglądarce na hoscie.

![](./img/image13.png)


## Analiza posiadanego kontenera

Wybrano wariant optimum, wykorzystano serwer nginx, który stale działa w tle i nie kończy natychmiast pracy. Utworzono Dockerfile, który podmienia domyślną stronę startową Nginxa na naszą własną index.html.
  
![](./img/image14.png)

eval $(minikube docker-env) - komenda przełącza terminal na środowisko Dockera wewnątrz minikube

Utworzony obraz: 

![](./img/image15.png)


##  Uruchamianie oprogramowania

![](./img/image16.png)


![](./img/image17.png)


Przekierowanie portu na 8085 oraz weryfikacja łączności lokalnej

![](./img/image18.png)

W celu uruchomienia w przeglądarce ponownie musimy skorzystać z ssh -L
```ssh -L 8085:127.0.0.1:8085 Tomasz@192.168.1.22```

![](./img/image19.png)


## Przekucie wdrożenia manualnego w plik wdrożenia 


Utworzenie nginx-deployment.yaml: 

![](./img/image20.png)

Uruchomienie wdrożenia :  ```minikubctl apply -f nginx-deployment.yaml```

Zbadanie stanu wdrożenia : ```minikubctl rollout status deployment/moja-aplikacja-deployment```


4 nowo utworzone pody:

![](./img/image21.png)

Wyeksportowanie wdrożenia jako serwis: 
``` minikubectl expose deployment moja-aplikacja-deployment --type=NodePort --port=80 --name=moja-aplikacja-service ```


Widok dashboardu :

![](./img/image22.png)


Aplikacja działa pod portem 8086

![](./img/image23.png)

![](./img/image24.png)