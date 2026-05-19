# Sprawozdanie – Wdrażanie na zarządzalne kontenery: Kubernetes (1)

## 1. Wprowadzenie do Kubernetes i Minikube

Kubernetes (k8s) to system do automatycznego wdrażania, skalowania i zarządzania aplikacjami kontenerowymi. Umożliwia grupowanie kontenerów w logiczne jednostki zwane **podami**, które są następnie zarządzane przez klaster.

**Minikube** to lokalna implementacja Kubernetes, uruchamiająca jednowęzłowy klaster na jednej maszynie. Jest przeznaczona do celów deweloperskich i edukacyjnych. Minikube obsługuje różne sterowniki wirtualizacji – w tym laboratorium użyto sterownika Docker.

Kluczowe koncepcje Kubernetes:
- **Pod** – najmniejsza jednostka wdrożeniowa, zawierająca jeden lub więcej kontenerów,
- **Deployment** – opisuje pożądany stan aplikacji (ile replik, jaki obraz),
- **Service** – eksponuje aplikację jako sieciowy punkt dostępu,
- **ReplicaSet** – zapewnia że działa odpowiednia liczba replik podów,
- **Namespace** – logiczne oddzielenie zasobów w klastrze.

---

## 2. Instalacja klastra Kubernetes

### Instalacja kubectl i minikube

Narzędzie `kubectl` zostało pobrane bezpośrednio z oficjalnych serwerów Google i zainstalowane w `/usr/local/bin`:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version --client
```

Analogicznie zainstalowano `minikube`:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

Zainstalowane wersje:
- `kubectl` – v1.36.1
- `minikube` – v1.38.1

> **Zrzut ekranu 1** – instalacja kubectl i minikube, potwierdzenie wersji (`instalacja.png`)

### Poziom bezpieczeństwa instalacji

Instalacja przeprowadzona została poprzez pobieranie binarnych plików z oficjalnych, zaufanych źródeł (dl.k8s.io, storage.googleapis.com). Pliki zostały nadane uprawnienia wykonywania i przeniesione do systemowego katalogu `/usr/local/bin`. Minikube uruchomiono ze sterownikiem Docker, co zapewnia izolację klastra w kontenerze.

### Uruchomienie klastra

Ze względu na ograniczoną ilość RAM (1.9 GB) klaster uruchomiono z flagą `--force` i ograniczeniem pamięci:

```bash
minikube start --driver=docker --memory=1800 --cpus=2 --force
```

Wynik polecenia `minikube status`:

```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

Polecenie `kubectl get nodes` potwierdziło działający węzeł:

```
NAME       STATUS   ROLES           AGE     VERSION
minikube   Ready    control-plane   4m29s   v1.35.1
```

> **Zrzut ekranu 2** – `minikube status` oraz `kubectl get nodes` (`minikube_working.png`)

### Mitigacja problemów sprzętowych

Serwer posiadał jedynie 1.9 GB RAM oraz 2 GB wolnego miejsca na dysku, co jest poniżej wymagań minimalnych Kubernetes (2 GB RAM, 20 GB dysku). Podjęto następujące kroki mitigacyjne:

| Problem | Rozwiązanie |
|---------|------------|
| Za mało RAM | Uruchomienie z flagą `--force --memory=1800` |
| Za mało miejsca na dysku | Rozszerzenie dysku VDI z 36 GB do 80 GB, rozszerzenie partycji LVM (`growpart`, `lvextend`, `resize2fs`) |
| Niestabilność | Użycie lekkiego obrazu nginx zamiast Jenkins (746 MB) |

---

## 3. Kubernetes Dashboard

Dashboard uruchomiono poleceniem:

```bash
minikube dashboard &
```

Łączność z dashboardem zapewniono poprzez przekierowanie portów VirtualBox (NAT) – port 8090 hosta przekierowany na port 8090 maszyny wirtualnej. Dashboard dostępny był w przeglądarce pod adresem:

```
http://127.0.0.1:39223/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

Dashboard prezentuje widok zasobów klastra: Workloads, Services, Config and Storage, Cluster. Umożliwia zarządzanie podami, deploymentami, serwisami i innymi zasobami Kubernetes przez interfejs graficzny.

> **Zrzut ekranu 3** – Kubernetes Dashboard w przeglądarce (`kubernetes_dashboard.png`)

---

## 4. Analiza i wybór kontenera

Na potrzeby laboratorium wybrano obraz **nginx** jako aplikację wdrażaną na klaster Kubernetes. Jest to serwer HTTP eksponujący interfejs funkcjonalny przez sieć (port 80), co spełnia wymagania instrukcji.

Obraz nginx pobierany jest bezpośrednio z Docker Hub (`nginx:latest`) i waży około 50 MB, co jest znacznie mniejsze niż obraz Jenkins (746 MB) – istotne przy ograniczonych zasobach serwera.

Weryfikacja działania kontenera:

```bash
docker run -d -p 8080:80 nginx
```

Kontener nginx uruchamia się i nie kończy natychmiast pracy – działa jako serwer HTTP nasłuchujący na porcie 80.

---

## 5. Uruchamianie oprogramowania na stosie Kubernetes

### Uruchomienie poda

Pod z nginx uruchomiono poleceniem:

```bash
minikube kubectl -- run nginx \
  --image=nginx \
  --port=80 \
  --labels app=nginx
```

Wynik: `pod/nginx created`

Sprawdzenie stanu poda:

```bash
kubectl get pods
```

```
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          25m
```

> **Zrzut ekranu 4** – pod nginx w stanie Running (`running_nginx.png`)

### Wyprowadzenie portu

Port poda wyprowadzono poleceniem:

```bash
kubectl port-forward pod/nginx 8090:80 --address 0.0.0.0 &
```

Dzięki przekierowaniu portów VirtualBox aplikacja była dostępna z przeglądarki na hoście Windows pod adresem `http://127.0.0.1:8090`, gdzie wyświetliła się strona powitalna nginx: **"Welcome to nginx!"**.

---

## 6. Wdrożenie jako plik YAML

### Plik deployment.yaml

Wdrożenie zapisano jako plik YAML zgodnie z dokumentacją Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

### Wdrożenie i weryfikacja

```bash
kubectl apply -f deployment.yaml
kubectl rollout status deployment/nginx-deployment
```

Wynik rollout:

```
Waiting for deployment "nginx-deployment" rollout to finish: 0 of 4 updated replicas are available...
Waiting for deployment "nginx-deployment" rollout to finish: 1 of 4 updated replicas are available...
Waiting for deployment "nginx-deployment" rollout to finish: 2 of 4 updated replicas are available...
Waiting for deployment "nginx-deployment" rollout to finish: 3 of 4 updated replicas are available...
deployment "nginx-deployment" successfully rolled out
```

Wszystkie 4 repliki uruchomione:

```
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-75fdcbbc74-4jfcg  1/1     Running   0          36s
nginx-deployment-75fdcbbc74-698wx  1/1     Running   0          36s
nginx-deployment-75fdcbbc74-d5r86  1/1     Running   0          36s
nginx-deployment-75fdcbbc74-dj922  1/1     Running   0          36s
```

### Ekspozycja jako serwis

```bash
kubectl expose deployment nginx-deployment --port=80 --type=ClusterIP
kubectl get services
```

```
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP   63m
nginx-deployment   ClusterIP   10.101.94.215   <none>        80/TCP    9s
```

Port serwisu wyprowadzono poleceniem:

```bash
kubectl port-forward service/nginx-deployment 8090:80 --address 0.0.0.0 &
```

Aplikacja dostępna przez serwis pod adresem `http://127.0.0.1:8090`.

> **Zrzut ekranu 5** – eksponowanie serwisu i port-forward (`wystawiony_serwis.png`)

---

## 7. Porównanie: Pod vs Deployment

| Cecha | Pod (kubectl run) | Deployment (kubectl apply) |
|-------|------------------|---------------------------|
| Liczba replik | 1 | Konfigurowalna (tu: 4) |
| Odporność na awarie | Brak – pod nie jest restartowany | ReplicaSet pilnuje liczby replik |
| Wdrożenie | Manualne | Deklaratywne (YAML) |
| Aktualizacje | Brak rolling update | Rolling update wbudowany |
| Produkcyjność | Tylko dev/test | Zalecane produkcyjnie |

---

## 8. Wnioski

- Minikube umożliwia uruchomienie pełnoprawnego klastra Kubernetes na pojedynczej maszynie, nawet przy ograniczonych zasobach sprzętowych
- Kubernetes automatyzuje zarządzanie cyklem życia kontenerów – zapewnia ich restartowanie, skalowanie i load balancing
- Podejście deklaratywne (pliki YAML) jest bardziej powtarzalne i audytowalne niż manualne wydawanie poleceń
- Serwis ClusterIP umożliwia wewnętrzny load balancing między replikami – ruch jest automatycznie rozdzielany między 4 pody nginx
- Ograniczenia sprzętowe (RAM, dysk) są realną przeszkodą przy uruchamianiu Kubernetes i wymagają świadomej mitigacji
