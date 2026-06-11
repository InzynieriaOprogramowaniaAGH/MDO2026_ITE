# Sprawozdanie Lab 10 - Wdrażanie na zarządzalne kontenery: Kubernetes (1)

---

## 1. Instalacja klastra Kubernetes

### Instalacja minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

![Instalacja minikube - weryfikacja wersji](IMG/Zrzut%20ekranu%202026-06-05%20072038.png)

### Weryfikacja bezpieczeństwa instalacji

W celu potwierdzenia integralności pobranego pliku pobrano plik sumy kontrolnej SHA256 i porównano z obliczoną sumą dla pobranej binarki:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64.sha256
sha256sum minikube-linux-amd64
cat minikube-linux-amd64.sha256
```

![Weryfikacja sumy SHA256](IMG/Zrzut%20ekranu%202026-06-05%20072641.png)

### Alias kubectl

Ustawiono alias `minikubectl` w pliku `~/.bashrc`:

```bash
echo "alias minikubectl='minikube kubectl --'" >> ~/.bashrc
source ~/.bashrc
minikubectl version
```

![Alias minikubectl - weryfikacja](IMG/Zrzut%20ekranu%202026-06-05%20073822.png)

### Uruchomienie klastra

Kubernetes wymaga uruchomienia spoza konta root. Utworzono nowego użytkownika `pablo` i dodano go do grupy `docker`, co umożliwia korzystanie z drivera Docker bez uprawnień administratora:

```bash
useradd pablo
passwd pablo
usermod -aG docker pablo
su - pablo
minikube start --driver=docker
```

![Uruchomienie klastra minikube](IMG/Zrzut%20ekranu%202026-06-05%20081143.png)

Weryfikacja działającego węzła:

```bash
minikubectl get nodes
minikube status
```

![Status klastra i działający node](IMG/Zrzut%20ekranu%202026-06-05%20081632.png)

Node `minikube` jest w stanie `Ready`, a wszystkie komponenty (`host`, `kubelet`, `apiserver`) mają status `Running`.

### Uruchomienie Dashboardu

Dashboard uruchomiono w tle z flagą `&`, aby terminal pozostał dostępny:

```bash
minikube dashboard --url &
```

Ponieważ system hosta nie ma bezpośredniego dostępu do adresu lokalnego maszyny wirtualnej (środowisko VirtualBox z NAT), zastosowano tunelowanie SSH. W tym celu dodano kartę sieciową Host-Only w ustawieniach VirtualBox (uzyskując adres `192.168.56.101`), a następnie uruchomiono tunel:

```bash
ssh -L 41881:localhost:41881 pablo@192.168.56.101
```

Dashboard dostępny w przeglądarce hosta pod adresem:
`http://127.0.0.1:41881/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`

![Kubernetes Dashboard w przeglądarce](IMG/Zrzut%20ekranu%202026-06-05%20083609.png)

---

## 2. Analiza posiadanego kontenera

Wybrano wariant **optimum** - obraz oparty na `nginx:alpine` z podmienioną stroną startową. Jest to serwer HTTP, który stale działa w tle i nie kończy pracy natychmiast po uruchomieniu, co czyni go odpowiednim do wdrożenia w klastrze Kubernetes.

Przygotowano `index.html` oraz `Dockerfile`:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

```bash
docker build -t apl:latest .
docker run -d -p 8080:80 --name test-app apl:latest
docker ps
curl http://localhost:8080
```

![Budowanie obrazu i weryfikacja działającego kontenera](IMG/Zrzut%20ekranu%202026-06-05%20084323.png)

Kontener działa poprawnie - `docker ps` potwierdza status `Up`, a `curl` zwraca stronę aplikacji.

---

## 3. Uruchamianie oprogramowania w Kubernetes

### Uruchomienie poda

Przed uruchomieniem poda załadowano lokalny obraz Docker do środowiska minikube:

```bash
minikube image load apl:latest
```

Następnie uruchomiono pod:

```bash
minikubectl run apl --image=apl:latest --port=80 --labels app=apl --image-pull-policy=Never
minikubectl get pods
```

Flaga `--image-pull-policy=Never` nakazuje Kubernetes używać lokalnego obrazu zamiast próbować pobrać go z rejestru.

![Pod apl - status Running](IMG/Zrzut%20ekranu%202026-06-05%20084455.png)

### Weryfikacja poda w Dashboardzie

![Pod apl w Dashboardzie Kubernetes](IMG/Zrzut%20ekranu%202026-06-05%20084924.png)

Pod `apl` widoczny w dashboardzie ze statusem `Running`.

### Wyprowadzenie portu i weryfikacja łączności

```bash
minikubectl port-forward pod/apl 8085:80 &
curl http://localhost:8085
```

![Port-forward do poda i weryfikacja curl](IMG/Zrzut%20ekranu%202026-06-05%20084954.png)

Aplikacja odpowiada poprawnie na porcie 8085.

---

## 4. Przekucie wdrożenia manualnego w plik wdrożenia

### Plik deployment.yml

Wdrożenie zapisano jako plik YAML z 4 replikami:

![Plik deployment.yml w edytorze nano](IMG/Zrzut%20ekranu%202026-06-05%20085912.png)

### Wdrożenie i weryfikacja rollout

```bash
minikubectl apply -f ~/apl/deployment.yml
minikubectl rollout status deployment/api-deployment
minikubectl get pods
```

![Wynik apply, rollout status i 4 działające pody](IMG/Zrzut%20ekranu%202026-06-05%20090325.png)

Rollout zakończony sukcesem. Widoczne 4 pody `api-deployment-*` ze statusem `Running`.

### Wyeksponowanie jako serwis

Wdrożenie wyeksponowano jako serwis typu `ClusterIP`:

```bash
minikubectl apply -f ~/apl/service.yml
minikubectl get services
minikubectl port-forward service/apl-service 8086:80 &
curl http://localhost:8086
```

![Serwis, port-forward i weryfikacja łączności](IMG/Zrzut%20ekranu%202026-06-05%20090853.png)

Aplikacja dostępna przez serwis na porcie 8086.

### Widok końcowy w Dashboardzie

![Dashboard - Deployments i 4 repliki podów](IMG/Zrzut%20ekranu%202026-06-05%20091101.png)

Dashboard potwierdza: 1 Deployment (`api-deployment`) z 4/4 działającymi podami, 1 Replica Set, łącznie 5 podów (4 z deploymentu + 1 manualny).

![Workload Status - finalne podsumowanie](IMG/Zrzut%20ekranu%202026-06-05%20091210.png)