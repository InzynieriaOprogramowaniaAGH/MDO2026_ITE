# Zajęcia 10 – Kubernetes (minikube)

---

## CZĘŚĆ 1: Instalacja minikube i kubectl

### 1: Instalacja minikube
![alt text](image.png)

### 2: Instalacja kubectl

![alt text](image-2.png)
![alt text](image-6.png)

###  3: uruchomienie minikube ( i problemy ze względu na specyfikację )

![alt text](image-3.png)
Dodałem dodatkowy core w maszynie witualnej 

![alt text](image-4.png)

![alt text](image-5.png)

###  4:  status klastra

![alt text](image-7.png)

## CZĘŚĆ 2: Dashboard

###  5: Uruchomienie Dashboarda

![alt text](image-8.png)

## CZĘŚĆ 3: Analiza kontenera – Express.js

###  6: obraz do minikube

![alt text](image-9.png)
![alt text](image-10.png)

###  7: Weryfikacja że kontener pracuje (nie kończy od razu)

![alt text](image-11.png)


---

## CZĘŚĆ 4: Uruchomienie na Kubernetes

###  8: Uruchomienie pod z aplikacją

![alt text](image-12.png)
![alt text](image-14.png)

`--image-pull-policy=Never` – używa lokalnego obrazu zamiast pobierać z Docker Hub.

###  9:  Status poda

![alt text](image-12.png)
![alt text](image-15.png)

### 10: Wyprowadzanie portu

![alt text](image-16.png)
![alt text](image-17.png)

---

## CZĘŚĆ 5: Plik wdrożenia (Deployment YAML)

### 11: utworzyłem plik deployment.yml i Próbne wdrożenie nginx (test)

![alt text](image-20.png)
![alt text](image-19.png)



### 13: Wdrożenie Express z 4 replikami

![alt text](image-18.png)

![alt text](image-21.png)
![alt text](image-22.png)


### 14: Eksportacja jako serwis

![alt text](image-23.png)

### 15: Przekierowanie portu do serwisu

![alt text](image-25.png)
![alt text](image-24.png)

## CZĘŚĆ 6: Koncepcje Kubernetes

### Pod
Najmniejsza jednostka w Kubernetes. Zawiera jeden lub więcej kontenerów współdzielących sieć i storage. Tymczasowy – może być tworzony i usuwany automatycznie.

### Deployment
Zarządza zestawem identycznych podów. Zapewnia że zawsze działa określona liczba replik. Obsługuje rolling updates i rollback.

### Service
Stały punkt dostępu do zestawu podów. Działa jako load balancer. Typy: ClusterIP, NodePort, LoadBalancer.

### ReplicaSet
Zarządza liczbą replik podów. Tworzony automatycznie przez Deployment.

---

## Wymagania sprzętowe – mitygacja problemów

| Problem | Rozwiązanie |
|---------|-------------|
| Mało RAM (< 2 GB) | `minikube start --memory=1800mb` |
| Brak docker grupy | `sudo usermod -aG docker $USER && newgrp docker` |
| Wolny dysk | `minikube start --disk-size=10g` |
| Brak CPU (< 2 rdzenie) | `minikube start --cpus=1` |

Minimalne wymagania minikube: 2 CPU, 2 GB RAM, 20 GB dysk.

---

## Typowe pułapki

| Objaw | Przyczyna | Rozwiązanie |
|-------|-----------|-------------|
| `ImagePullBackOff` / `ErrImagePull` | k8s próbuje pobrać `:latest` z Docker Hub | `imagePullPolicy: Never` w YAML lub `--image-pull-policy=Never` w `kubectl run` |
| `failed to read dockerfile: open Dockerfile.production` | Zła nazwa pliku lub zły katalog kontekstu | Plik nazywa się `Dockerfile`, kontekst to `/opt/express-app` |
| `pull access denied for express-prod` | Pomyłka nazwy obrazu | Właściwa nazwa: `express-app:latest` |
| `failed to resolve reference docker.io/...` podczas `docker build` w docker-env minikube | Sieć/DNS klastra minikube nie dociera do internetu | Buduj na hoście (Metoda 1 w kroku 6) i `minikube image load` |
