# Sprawozdanie LAB10
### Jakub Padło, 422018

# Instalacja klastra Kubernetes
## Czym jest minikube?
Jest to lekki Kubernetes spakowany do jednego kontenera/VM'a. Idealny do nauki i lokalnego testowania, ale nie nadaje się na produkcję

**DISCLAIMER**: Prawdziwy Kubernetes to zespół wielu serwerów tworzących potężny organizm. Wyróżnia się wtedy węzły sterujące i węzły robocze. Wielowęzłowść zapewnia High Availibilty i Load Balancing.

<img src="struct.png" width="600">

<img src="ss/1.png" width="800">

<img src="ss/3.png" width="600">

## `get nodes` i `get pods`

`get nodes` - pokazuje listę maszyn tworzących klaster

`get pods -A` - pokazuje wszystkie pody systemowe konieczne dla działania Kubernetesa
* **kube-apiserver-minikube**: Główny punkt kontaktu. To on odbiera komendy `kubectl`
* **etcd-minikube**: Baza danych klastra.
* **kube-scheduler-minikube**: "Planista". Decyduje, na którym węźle uruchomić nowy kontener
* **kube-controller-manager-minikube**: Pilnuje, aby stan faktyczny zgadzał się z pożądanym 
* **coredns**: Odpowiada za nazewnictwo wewnątrz klastra. Dzięki niemu kontenery mogą komunikować się ze sobą po nazwach
* **kube-proxy**: Odpowiada za sieć. To on kieruje ruch do odpowiednich kontenerów.
* **storage-provisioner**: Dodatek od Minikube, który pozwala łatwo tworzyć wirtualne dyski (wolumeny) dla danych.

<img src="ss/4.png" width="1000">

## dashboard
`minikube dashobard` odpala specjalny dodatek dla minikube.
W przeglądarce otwiera się graficzny interfejs do zarządzania klastrem.


<img src="ss/5.png" width="900">

# Analiza posiadanego kontenera

## Stworzenie deploymentu, który sam zadba o utworzenie poda i pobranie wskazanego obrazu dockera
<img src="ss/6.png" width="600">

## Sprawdzenie, że kontener wstał
<img src="ss/7.png" width="900">

## Zweryfikowanie łączności
<img src="ss/8.png" width="600">

# Uruchamianie oprogramowania

## WAŻNE: Pod vs Deployment

### Pod (`kubectl run`)
* Pojedynczy kontener
* Po wywaleniu znika na zawsze
* Tylko do szybkich testów

### Deployment (`kubectl create deployment`)
* Zarządca, który tworzy pody
* Pilnuje zdefiniowanego stanu - po wywaleniu poda stawia nowy na jego miejsce
* Łatwe skalowanie
* W prawdziej pracy w 99% używa się deployment

<img src="ss/9.png" width="1000">

## Zweryfikowanie że pod wstał i działa

<img src="ss/10.png" width="900">

## Łączenie się po prywatnym IP klastra

<img src="ss/11.png" width="1000">

## Wystawienie poda 'na świat' i połączenie się do oprogramowania przez IP hosta.

<img src="ss/16.png" width="1000">


# Przekucie wdrożenia manualnego w plik wdrożenia

```yml
apiVersion: apps/v1      
kind: Deployment         # Typ obiektu
metadata:
  name: nginx-deployment # Unikalna nazwa
  labels:
    app: nginx           
spec:
  replicas: 4            # Deklaracja pożądanego stanu: Kubernetes ma zawsze utrzymywać 4 działające pody
  selector:
    matchLabels:
      app: nginx        
  template:              # Szablon, z którego powstaną nowe Pody 
    metadata:
      labels:
        app: nginx       # MUSI pasować do pola matchLabels powyżej!
    spec:
      containers:        # Definicja kontenerów, które będą działać wewnątrz każdego Poda
      - name: nginx     
        image: nginx:1.25 # Obraz kontenera pobierany z Docker Hub 
        ports:
        - containerPort: 80 
```
## Utworzenie pojedynczej instancji
<img src="ss/12.png" width="800">

## Zmieniając jedną cyferkę w kodzie możemy momentalnie postawić kolejne 3 instancje
<img src="ss/13.png" width="800">

## Wystawienie portu poda z zamkniętej sieci wewnętrznej do sieci hosta
<img src="ss/14.png" width="800">
