# SPRAWOZDANIE 10
 
## Środowisko uruchomieniowe
 
- System operacyjny: Ubuntu 24.04 LTS - maszyna wirtualna `devops`
- Silnik wirtualizacji: Oracle VirtualBox
- Metoda dostępu: Zdalna sesja przez SSH (użytkownik: `karro`)
- Narzędzie orkiestracji: Kubernetes (minikube v1.38.1, Kubernetes v1.35.1)
- Silnik kontenerów: Docker 29.2.1
- Edytor kodu: GNU nano / Visual Studio Code (Remote SSH)
- Projekt: portfinder (artefakt z poprzednich laboratoriów) + nginx z własną konfiguracją
## 1. Instalacja klastra Kubernetes (minikube)
 
Binarny plik `minikube-linux-amd64` pobrano ze strony producenta i przetransferowano na maszynę wirtualną `devops` przy użyciu programu FileZilla (SFTP):
 
![1](<img/Zrzut ekranu 2026-05-19 082955.png>)
 
Następnie zainstalowano minikube w systemie i zweryfikowano wersję:
 
```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```
 
Wynik potwierdza instalację wersji `v1.38.1`:
 
![2](<img/Zrzut ekranu 2026-05-19 083052.png>)
 
Klaster uruchomiono z użyciem sterownika Docker:
 
```bash
minikube start --driver=docker
```
 
Przy pierwszej próbie pojawiło się ostrzeżenie o niewystarczającej pamięci dla sterownika Docker (całkowita pamięć systemu: 1967 MiB). Minikube zasugerował zmniejszenie alokacji pamięci, jednak mimo ostrzeżenia klaster uruchomił się poprawnie:
 
![3](<img/Zrzut ekranu 2026-05-19 104840.png>)
 
Ponieważ przy kolejnych próbach pojawiał się błąd uprawnień do gniazda Docker, dodano użytkownika do grupy `docker`:
 
```bash
sudo usermod -aG docker $USER && newgrp docker
minikube start --driver=docker
```
 
![4](<img/Zrzut ekranu 2026-05-19 105202.png>)
 
Kolejne uruchomienie (po włączeniu addonu Dashboard) zakończyło się sukcesem z komunikatem `Done! kubectl is now configured to use "minikube" cluster`:
 
![5](<img/Zrzut ekranu 2026-05-19 110006.png>)
 
Sprawdzono stan węzła i ogólny status klastra:
 
```bash
minikube kubectl -- get nodes
minikube status
```
 
Węzeł `minikube` zwrócił status `Ready` z rolą `control-plane`. Komponenty `host`, `kubelet`, `apiserver` i `kubeconfig` działają poprawnie:
 
![6](<img/Zrzut ekranu 2026-05-19 112102.png>)
 
Aby uprościć korzystanie z `kubectl`, ustawiono alias i zapisano go w `~/.bashrc`:
 
```bash
alias kubectl="minikube kubectl --"
echo 'alias kubectl="minikube kubectl --"' >> ~/.bashrc
source ~/.bashrc
kubectl get nodes
```
 
![7](<img/Zrzut ekranu 2026-05-19 112146.png>)
 
Minikube z driverem Docker uruchamia klaster wewnątrz kontenera Docker, co zapewnia izolację od systemu hosta. Kubeconfig skonfigurowany lokalnie umożliwia dostęp wyłącznie dla użytkownika `karro`.
 
## 2. Uruchomienie Dashboard
 
Włączono addon Dashboard i uruchomiono go w tle, uzyskując adres proxy:
 
```bash
minikube dashboard --url &
```
 
Przy pierwszej próbie dashboard nie działał, co widać na screenie z komunikatem `Exit 112`. Po ponownym uruchomieniu minikube z addonem `dashboard` URL został poprawnie wyświetlony:
 
![8](<img/Zrzut ekranu 2026-05-19 163227.png>)
 
Po włączeniu addonu i restarcie klastra dashboard załadował się poprawnie:
 
![9](<img/Zrzut ekranu 2026-05-19 190323.png>)
 
URL dashboardu: `http://127.0.0.1:37005/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`
 
![10](<img/Zrzut ekranu 2026-05-19 191015.png>)
 
Aby udostępnić Dashboard na zewnątrz maszyny wirtualnej (z fizycznego komputera przez przeglądarkę), uruchomiono `kubectl proxy` z adresem `0.0.0.0`:
 
```bash
kubectl proxy --address='0.0.0.0' --disable-filter=true &
```
 
![11](<img/Zrzut ekranu 2026-05-19 191953.png>)
 
Dashboard otwarto w przeglądarce na maszynie fizycznej pod adresem `192.168.1.34:8001/...`:
 
![12](<img/Zrzut ekranu 2026-05-19 193205.png>)
 
Na początku sekcja Workloads była pusta - żadne wdrożenia nie były jeszcze uruchomione:
 
![13](<img/Zrzut ekranu 2026-05-19 193253.png>)
 
## 3. Analiza posiadanego kontenera i przygotowanie obrazu
 
Projekt `portfinder` to narzędzie CLI, które kończy pracę natychmiast po wykonaniu, więc nie nadaje się bezpośrednio do wdrożenia w Kubernetes, który wymaga kontenerów działających ciągle. Zdecydowano się na podejście optymalne: obraz-gotowiec nginx z własną konfiguracją nawiązującą do projektu portfinder.
 
Aby obraz był dostępny dla Kubernetes bez zewnętrznego registry, skonfigurowano środowisko Docker tak, żeby budować bezpośrednio w kontekście minikube:
 
```bash
eval $(minikube docker-env)
```
 
Następnie utworzono katalog `nginx-custom` i przygotowano pliki:
 
```bash
mkdir -p nginx-custom
cd nginx-custom
```
 
![14](<img/Zrzut ekranu 2026-05-25 172235.png>)
 
Zbudowano obraz poleceniem:
 
```bash
docker build -t portfinder-web:latest .
```
 
![15](<img/Zrzut ekranu 2026-05-25 172547.png>)
 
Budowanie zakończyło się sukcesem, obraz `portfinder-web:latest` jest dostępny lokalnie w środowisku minikube:
 
![16](<img/Zrzut ekranu 2026-05-25 173427.png>)
 
## 4. Uruchamianie oprogramowania w Kubernetes
 
Uruchomiono pod z obrazem `portfinder-web:latest`. Flaga `--image-pull-policy=Never` informuje Kubernetes, żeby nie próbował pobierać obrazu z Docker Hub, lecz użył lokalnie dostępnego:
 
```bash
kubectl run portfinder-deploy \
  --image=portfinder-web:latest \
  --port=80 \
  --labels app=portfinder-deploy \
  --image-pull-policy=Never
```
 
Pod natychmiast osiągnął status `Running`:
 
![17](<img/Zrzut ekranu 2026-05-25 173717.png>)
 
Przekierowano port 8082 na port 80 poda:
 
```bash
kubectl port-forward pod/portfinder-deploy 8082:80 &
curl http://localhost:8082
```
 
Serwer nginx zwrócił poprawną stronę HTML z konfiguracją portfinder:
 
![18](<img/Zrzut ekranu 2026-05-25 173759.png>)
 
## 5. Przekucie wdrożenia manualnego w plik wdrożenia
 
Wdrożenie zapisano jako plik YAML zawierający jednocześnie definicję `Deployment` (4 repliki) i `Service` (typ NodePort). Oba zasoby rozdzielone są separatorem `---`:
 
![19](<img/Zrzut ekranu 2026-05-25 173844.png>)
 
Zastosowano plik wdrożenia:
 
```bash
kubectl apply -f deployment.yml
```
 
Weryfikacja działania przez NodePort:
 
```bash
curl http://$(minikube ip):30080
```
 
Serwer poprawnie zwrócił stronę HTML:
 
![20](<img/Zrzut ekranu 2026-05-25 173925.png>)
 
Sprawdzono status rollout deploymentu oraz szczegóły poda manualnego:
 
```bash
kubectl rollout status deployment/portfinder-deployment
kubectl describe pod portfinder-deploy
```
 
Polecenie `rollout status` potwierdziło pomyślne zakończenie wdrożenia.
 
![21](<img/Zrzut ekranu 2026-05-25 174653.png>)
 
![22](<img/Zrzut ekranu 2026-05-25 174704.png>)
 
## Podsumowanie
 
Minikube z driverem Docker pozwala uruchomić lokalny klaster Kubernetes bez dedykowanego serwera. Ograniczenie sprzętowe (1967 MiB RAM) spowodowało ostrzeżenie, jednak klaster działał stabilnie. Alias `kubectl="minikube kubectl --"` upraszcza codzienną pracę.
 
Kubernetes Dashboard stanowi graficzny interfejs do monitorowania stanu klastra. Wymaga włączenia addonu (`minikube addons enable dashboard`) oraz dodatkowej konfiguracji proxy (`kubectl proxy --address='0.0.0.0'`), żeby był dostępny z zewnątrz maszyny wirtualnej.
 
Projekt `portfinder` jako narzędzie CLI nie nadaje się do długotrwałej pracy w kontenerze. Zastosowano obraz `nginx:alpine` z własną konfiguracją HTML nawiązującą do projektu, co jest podejściem rekomendowanym przez treść zadania (obraz-gotowiec z dorzuconą własną konfiguracją). Obraz zbudowano wewnątrz kontekstu minikube (`eval $(minikube docker-env)`), dzięki czemu nie było konieczne zewnętrzne registry.
 
Pojedynczy pod uruchomiony przez `kubectl run` posłużył jako weryfikacja działania obrazu. Docelowe wdrożenie zdefiniowano jako plik `deployment.yml` z 4 replikami i usługą NodePort, co umożliwia dostęp do aplikacji przez IP węzła bez konieczności przekierowania portów.
 
### Koncepcje Kubernetes                      
- **Pod** - najmniejsza jednostka wdrożenia; jeden lub więcej kontenerów współdzielących sieć i storage
- **Deployment** - zarządza zestawem podów, zapewnia żądaną liczbę replik i umożliwia rolling update
- **Service** - stabilny punkt dostępu do podów; typ NodePort eksponuje usługę na porcie węzła klastra
- **ReplicaSet** - tworzony automatycznie przez Deployment, pilnuje żądanej liczby replik

Zapytania do LLM:
- „Jak skonfigurować kubectl proxy żeby Dashboard był dostępny z zewnątrz VM?"
- „Jak połączyć Deployment i Service w jednym pliku YAML?"
Metoda weryfikacji: sprawdzenie statusów przez kubectl get pods i kubectl get services, weryfikacja odpowiedzi HTTP przez curl, widok w Dashboardzie Kubernetes.
 
*Pliki `deployment.yml`, `Dockerfile`, `index.html` dostępne w folderze `Sprawozdanie10/nginx-custom`.*