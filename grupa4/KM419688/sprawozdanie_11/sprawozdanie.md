# Wdrażanie na zarządzalne kontenery: Kubernetes (2)

<br/>

## Przygotowanie nowego obrazu

Zaczynamy od przygotowanie dwóch działających wersji obrazu i jeden wadliwej:
`my-app:v1` - działająca wersja
`my-app:v2` - działająca wersja z nowymi funkcjonalnościami
`my-app:v3` - wadliwa wersja z błęd

Obrzy te będą zapisane w lokalnym rejestrze obrazów Minikube.

<br/>

### Startujemy lokalny klaster Kubernetes

```bash
minikube start --driver=docker
```

Sprawdzamy czy klaster działa poprawnie

![minikube status](<./img/Screenshot 2026-06-17 at 10.52.49.png>)

<br/>

### Budujemy 3 wersje obrazu

Najpierw mówimy dockerowi, żeby działał wewnątrz klastra Minikube

```bash
eval $(minikube docker-env)
```

![eval minikube docker-env](<./img/Screenshot 2026-06-17 at 10.55.53.png>)

Następnie budujemy trzy wersje obrazu na bazie pliku index.html z poprzednich zajęć.

Wykorzystamy do tego prosty Dockerfile

```Dockerfile
FROM nginx:alpine
COPY ./index.html /usr/share/nginx/html/index.html
```

```bash
docker build -t my-app:v1 .
docker build -t my-app:v2 .
docker build -t my-app:v3 . -f Dockerfile.broken
```

w wersji drugiej dodajemy style CSS, a wersję trzecią budujemy tak, żeby od razu się crashowała i wykorzystujemy do tego poniższy Dockerfile

```Dockerfile
FROM alpine
CMD ["false"]
```

<br/>

### Wyświetlamy listę obrazów

![images](<./img/Screenshot 2026-06-17 at 11.16.50.png>)

<br/>

### Sprawdzamy czy obraz 3. jest wadliwy

Uruchamiamy obraz v3 i sprawdzamy jego status wyjścia

```bash
docker run my-app:v3
echo $?
```

![run broken image](<./img/Screenshot 2026-06-17 at 11.18.44.png>)

<br/>

<br/>

## Zmiany w deploymencie

Następnie tworzymy plik deployment.yaml, który będzie zawierał definicję naszego wdrożenia, oraz którym będziemy mogli potem manipulować.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 8
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-app:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

Kluczowe jest ustawienie `imagePullPolicy: Never`, które mówi Kubernetesowi, żeby nie próbował pobierać obrazu z rejestru, tylko używał lokalnego.

Wysyłamy konfigurację do klastra

```bash
kubectl apply -f deployment.yaml

# Sprawdzamy status wdrożenia
kubectl get pods
kubectl get deployment my-app
```

![deployment](<./img/Screenshot 2026-06-17 at 11.40.47.png>)

wersja z 8 replikami

<br/>

### Zmniejszenie liczby replik do 4

![scale down](<./img/Screenshot 2026-06-17 at 11.43.14.png>)

<br/>

### Zmniejszenie liczby replik do 0

![scale down to 0](<./img/Screenshot 2026-06-17 at 11.43.55.png>)

<br/>

### Zwiększenie replik do 5

![scale up](<./img/Screenshot 2026-06-17 at 11.44.28.png>)

<br/>

### Zastosowanie nowej wersji obrazu (v2)

Zmieniamy na `image: my-app:v2` i wysyłamy konfigurację do klastra

```bash
kubectl apply -f deployment my-app
# Sprawdzamy status wdrożenia
kubectl rollout status deployment my-app
kubectl describe deployment my-app | grep Image
```

![rollout](<./img/Screenshot 2026-06-17 at 11.48.28.png>)

Możemy sprawdzić historię wdrożeń, gdzie rewizja rośnie wraz ze zmianą obrazu

```bash
kubectl rollout history deployment my-app
```

![rollout history](<./img/Screenshot 2026-06-17 at 11.50.17.png>)

<br/>

### Zastosowanie starczej wersji obrazu (v1)

Wrócić do poprzedniej wersji możemy za pomocą polecenia

```bash
kubectl rollout undo deployment my-app
```

i sprawdzamy wersję obrazu za pomocą `kubectl describe deployment my-app | grep Image`

![rollout undo](<./img/Screenshot 2026-06-17 at 11.53.03.png>)

<br/>

### Zastosowanie wadliwej wersji obrazu (v3)

Teraz wdrażamy wadliwą wersję obrazu i obserwujemy zachowanie.

Po wpisaniu `kubectl get pods` widzimy, że wszystkie repliki w kółko się restartują.

![rollout broken](<./img/Screenshot 2026-06-17 at 11.55.48.png>)

Sprawdzamy też za pomocą `kubectl describe pods | grep -A 5 "State:"` i widzimy, że wszystkie repliki mają status `Error` i `Exit Code: 1`.

![rollout broken describe](<./img/Screenshot 2026-06-17 at 11.57.30.png>)

Teraz możemy wycofać wadliwe wdrożenie za pomocą `kubectl rollout undo deployment my-app` i sprawdzić, że repliki wróciły do poprzedniej wersji.

![rollout undo broken](<./img/Screenshot 2026-06-17 at 12.00.32.png>)

<br/>

<br/>

## Kontrola wdrożenia

Tworzymy skrypt `check_deploy.sh`, który będzie sprawdzał status wdrożenia po 60 sekundach

```bash
#!/bin/bash
minikube kubectl -- rollout status deployment/my-app --timeout=60s

if [ $? -eq 0 ]; then
    echo "Deployment successful"
else
    echo "Deployment failed"
fi
```

nadajemy uprawnienia

```bash
chmod +x check_deploy.sh
```

i uruchamiamy

```bash
./check_deploy.sh
```

![check deploy](<./img/Screenshot 2026-06-17 at 12.09.43.png>)

zmieniamy obraz na wadliwy i uruchamiamy ponownie skrypt

![check deploy broken](<./img/Screenshot 2026-06-17 at 12.12.36.png>)

<br/>

<br/>

## Strategie wdrożenia

### Recreate

Tworzymy plik `deployment-recreate.yaml` z poniższą konfiguracją

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-recreate
spec:
  replicas: 8
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: my-app-recreate
  template:
    metadata:
      labels:
        app: my-app-recreate
    spec:
      containers:
        - name: my-app
          image: my-app:v1
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

Metoda ta polega na tym, że wszystkie stare repliki są usuwane, a następnie tworzone są nowe. Istnieje więc moment, w którym nie ma żadnych działających replik.

Wdrażamy nową konfigurację, następnie zmieniamy obraz na v2 i wdrażamy ponownie. Widzimy, że wszystkie repliki są usuwane, a następnie tworzone są nowe.

```bash
kubectl apply -f deployment-recreate.yaml
kubectl get pods -w
```

![recreate](<./img/Screenshot 2026-06-17 at 18.20.37.png>)

<br/>

### Rolling Update

Ta strategia jest włączona domyślnie i polega na tym, że stare repliki są stopniowo zastępowane nowymi. W tym czasie działają zarówno stare, jak i nowe.

<br/>

### Canary

Tworzymy kolejny plik `deployment-canary.yaml` z poniższą konfiguracją

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: my-app
          image: my-app:v2
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

Ta strategia polega na tym, że nowa wersja jest wdrażana tylko na jednej lub kilku replikach, a reszta nadal działa na starej wersji. Po pewnym czasie, jeśli wszystko działa poprawnie, można zwiększyć liczbę replik z nową wersją.

![canary](<./img/Screenshot 2026-06-17 at 18.32.49.png>)

<br/>

### Wyeksponowanie aplikacji przez Service

Tworzymy service

```bash
kubectl expose deployment my-app \
  --type=ClusterIP \
  --port=80

# Sprawdzamy status service
kubectl get svc
```

Pody mają losowe adresy IP, które się zmieniają przy każdym restarcie. Service daje nam stabilny wewnętrzny adres (CluserIP), przez ktory możemy zawsze dotrzeć do aplikacji. Ruch jest balansowany między wszystkimi podami.

![service](<./img/Screenshot 2026-06-17 at 18.37.34.png>)

Teraz wykonujemy port-forward i sprawdzamy, czy aplikacja jest dostępna pod localhost:8080

```bash
kubectl port-forward svc/my-app 8080:80
```

![port forward](<./img/Screenshot 2026-06-17 at 18.40.38.png>)

<br/>

<br/>

## Podsumowanie

Podczas laboratorium przygotowano trzy wersje obrazu aplikacji nginx (v1, v2, v3) i wdrożono je w klastrze Minikube. Przeprowadzono skalowanie replik, aktualizację wersji obrazu z v1 na v2 (RollingUpdate) oraz rollback. Wdrożono wadliwy obraz, zaobserwowano stan CrashLoopBackOff i przywrócono działającą wersję. Przetestowano strategie Recreate, RollingUpdate i Canary oraz wyeksponowano aplikację przez serwis ClusterIP.
