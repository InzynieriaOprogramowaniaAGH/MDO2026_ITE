# Wdrażanie na zarządzalne kontenery: Kubernetes (1)

## Instalacja Klastra Kubernetes

Najpierw pobieramy minikube, który jest narzędziem do uruchamiania lokalnego klastra Kubernetes.

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
```

![Instalacja minikube](<./img/Screenshot 2026-05-29 at 09.39.31.png>)

Dodajemy alias, uruchamiamy klaster i weryfikujemy, że wszystko działa poprawnie

```bash
echo "alias minikubctl='minikube kubectl --'" >> ~/.bashrc
source ~/.bashrc

minikube start
```

Możemy sprawdzić działania wywołując komendy `minikube status`, `minikubctl get nodes`

![Uruchomienie klastra](<./img/Screenshot 2026-05-29 at 09.41.57.png>)

![Klaster uruchomiony](<./img/Screenshot 2026-05-29 at 09.42.20.png>)

### Uruchomienie dashboardu

```bash
minikube dashboard --url
```

![Dashboard](<./img/Screenshot 2026-05-29 at 08.50.47.png>)

Zwracamy uwagę na port, tutaj jest `36111`, ja poniżej użyłem innego, ze względu na to, że uruchamiałem dshboard kilka razy. Za każdym razem dostajemy inny port.

Następnie otwieramy nowy terminal i wykonujemy tunelowanie:

```bash
ssh -L 8080:localhost:<powyższy-port> kamil@192.168.1.133
```

![Tunelowanie](<./img/Screenshot 2026-05-29 at 09.00.01.png>)

Sprawdzamy czy dashboard jest dostępny pod adresem `http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`

![Dashboard dostępny](<./img/Screenshot 2026-05-29 at 13.53.44.png>)

## Analiza posiadanego kontenera

W kubernetesie kontener ma działać cały czas, więc musimy się upewnić, że nasz kontener jest w stanie działać bez końca. W innym przypadku, zostanie uznany za wadliwy i będzie nieustannie restartowany, co nie jest pożądane.

Posłużę się przygotowanym obrazem, bazującym na nginx, który będzie serwował statyczną stronę HTML.

### Wygenerowanie strony HTML

Generujemy prostą stronę HTML, która będzie serwowana przez nasz kontener i zapisujemy ja jako `index.html`. Plik ten musi się znaleźć w folderze `/usr/share/nginx/html/`, z którego nginx domyślnie serwuje stronę.

### Przygotowanie obrazu dockera

```Dockerfile
FROM nginx:alpine

RUN rm /usr/share/nginx/html/*

COPY ./index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]
```

Teraz budujemy obraz

```bash
docker build -t aplikacja-html:v1 .
```

![Budowanie obrazu](<./img/Screenshot 2026-05-29 at 14.11.19.png>)

![Obraz zbudowany](<./img/Screenshot 2026-05-29 at 14.12.12.png>)

### Uruchomienie kontenera i wykazanie że działa

```bash
docker run -d --name test-html -p 8081:80 aplikacja-html:v1
docker ps
```

![Uruchomienie kontenera](<./img/Screenshot 2026-05-29 at 14.14.57.png>)

Poprawność możemy sprawdzić uruchamiając logi kontenera `docker logs test-html`, wykonując zapytanie do serwera `curl http://localhost:8081` lub otwierając adres `http://192.168.1.133:8081` w przeglądarce.

![Sprawdzenie działania](<./img/Screenshot 2026-05-29 at 14.16.51.png>)

## Uruchamianie oprogramowania

### Przesłanie lokalnego obrazu do minikuba

```bash
minikube image load aplikacja-html:v1
```

![Przesyłanie obrazu](<./img/Screenshot 2026-05-30 at 10.34.36.png>)
![Obraz przesłany](<./img/Screenshot 2026-05-30 at 10.34.46.png>)

### Uruchomienie aplikacji na stosie k6s

Uruchamiamy nasz spersonizowany kontener z wykorzystaniem przesłanego obrazu:

```bash
minikubctl run kb-chmura --image=aplikacja-html:v1 --port=80 --labels app=kb-chmura
```

![Uruchomienie aplikacji](<./img/Screenshot 2026-05-30 at 10.36.24.png>)

Sprawdzamy, czy nasz pod został uruchomiony:

```bash
minikubctl get pods
```

![Lista podów](<./img/Screenshot 2026-05-30 at 10.36.45.png>)

Można też sprawdzić działanie poprzez dashboard. Należy go najpierw uruchomić w tle, zestawić tunel a następnie otworzyć w przeglądarce:

![Dashboard](<./img/Screenshot 2026-05-30 at 10.37.30.png>)

### Wyprowadzenie portu

Aby uzyskać dostęp do naszej aplikacji, musimy przekierować port z naszego lokalnego komputera do portu, na którym nasz pod nasłuchuje (port-forwarding):

```bash
minikubctl port-forward pod/kb-chmura --address 0.0.0.0 7777:80
```

Ważne jest wskazanie adresu `0.0.0.0`, aby nasza aplikacja była dostępna z innych urządzeń w sieci, a nie tylko z naszego lokalnego komputera.

![Port forwarding](<./img/Screenshot 2026-05-30 at 10.39.22.png>)

### Przedstawienie komunikacji z eksponowaną funkcjonalnością

![Komunikacja z aplikacją](<./img/Screenshot 2026-05-30 at 10.40.02.png>)

## Przekucie wdrożenia manualnego w plik wdrożenia (wprowadzenie)

### Zapisanie wdrożenia jako plik `YAML`

Najpierw towrzymy plik wdrożenia `wdrozenie.yaml`, który będzie zawierał definicję naszego wdrożenia. W tym pliku określamy, ile replik naszej aplikacji chcemy uruchomić, jakie obrazy kontenerów mają być używane, oraz jakie porty mają być otwarte.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strona-www-deployment
  labels:
    app: strona-www-chmura
spec:
  replicas: 4
  selector:
    matchLabels:
      app: strona-www-chmura
  template:
    metadata:
      labels:
        app: strona-www-chmura
    spec:
      containers:
        - name: strona-www-container
          image: aplikacja-html:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
```

### Przeprowadzenie próbnego wdrożenia

Teraz uruchamiamy nasze wdrożenie, jednak zanim to zrobimy to czyścimy nasz klaster z poprzednich podów, za pomocą polecenia `minikubctl delete pod <nazwa-poda>`.

![Usuwanie poda](<./img/Screenshot 2026-05-30 at 10.51.11.png>)

Najpierw nakazujemy Kubernetesowi, aby przeczytał nasz plik i zastosował zapisaną w nim konfigurację:

```bash
minikubctl apply -f wdrozenie.yaml
```

![Zastosowanie konfiguracji](<./img/Screenshot 2026-05-30 at 10.51.52.png>)

Aby upewnić się, że proces wdrażania przebiegł pomyślnie, stosujemy polecenie:

```bash
minikubctl rollout status deployment/strona-www-deployment
```

Teraz możemy sprawdzić listę podów, wówczas okaże się, że Kubernetes faktycznie uruchomił 4 repliki naszej aplikacji, zgodnie z tym co zapisaliśmy w pliku wdrożenia.

![Lista podów](<./img/Screenshot 2026-05-30 at 10.55.09.png>)

### Wyeksponowanie wdrożenia jako serwis

Pody mogą się restartować i zmeiniać swoje IP, żeby mieć do nich jeden stały punkt dostępu, musimy utworzyć serwis, który będzie rozdzielał ruch sieciowy pomiędzy pody.

Tworzymy i sprawdzamy czy serwis został utworzony:

```bash
minikubctl expose deployment strona-www-deployment --type=NodePort --port=80 --target-port=80 --name=strona-www-serwis

minikubctl get service strona-www-serwis
```

- `--type=NodePort` - oznacza, że serwis będzie dostępny na porcie na węźle klastra.
- `--port=80` - to port, na którym serwis będzie nasłuchiwał.
- `--target-port=80` - to port, na który serwis będzie przekierowywał ruch do podów.
- `--name=strona-www-serwis` - nazwa serwisu.

![Serwis](<./img/Screenshot 2026-05-30 at 10.58.26.png>)

### Przekierowanie portu do serwisu

Musimy zrobić tunelowanie ruchu z naszego lokalnego komputera do całego serwisu.

```bash
minikubctl port-forward service/strona-www-serwis --address 0.0.0.0 7891:80
```

- `--address 0.0.0.0` - serwis będzie dostępny na wszystkich interfejsach sieciowych naszego komputera.
- `7891:80` - ruch z portu 7891 na naszym komputerze będzie przekierowywany do portu 80 serwisu w klastrze.

![Tunelowanie ruchu](<./img/Screenshot 2026-05-30 at 11.01.51.png>)

### Sprawdzenie działania aplikacji

Wchodzimy na adres `http://localhost:7891` i sprawdzamy, czy nasza aplikacja jest dostępna.

![Działanie aplikacji](<./img/Screenshot 2026-05-30 at 11.02.14.png>)
