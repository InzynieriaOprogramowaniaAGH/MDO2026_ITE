# Sprawozdanie 10
Autor: Jan Pawelec

---

# Instalacja klastra Kubernetes
Zainstalowano pakiety `minikube` i `kubectl`.
![alt text](1_inst.png)

Uruchomiono klaster na minimalnej ilości zasobów, zgodnie z tym co przedstawia dokumentacja. Radzi ona także posiadać 20GB przestrzeni dyskowej, co jest zachowane, gdyż przy tworzeniu maszyny zadbano o to. 
![alt text](1_start.png)

Uruchomiono dashboard. Klasycznym poleceniem z dokumentacji nir uzyskano pozytywnych rezultatów, więc zastosowano `kubectl proxy --port=8081 --address='0.0.0.0' --accept-hosts='^.*'`.
![alt text](1_dash.png)

---

# Analiza posiadanego kontenera
Wcześniej wybrana aplikacja (biblioteka cJSON) nie spełnia nowopostawionych warunków. Z tego powodu, w tym laboratorium będzie prowadzony deplot `nginx`. Stworzono prostego html obrazującego działanie z nagłówkiem `devops nginx-0`. Napisano Dockerfile (załączony). Nastęnie zbudowano obraz.
![alt text](2_build.png)

Sprawdzono poprawność działania Dockera.
![alt text](2_docker_ok.png)

Następnie zapisano rezultat do `.tar` i wczytano do minikube poleceniem `minikube image load`.

---

# Uruchamianie oprogramowania
Załadowany obraz uruchomiono w podzie. Dodano `--image-pull-policy=Never`, gdyż w innym przypadku k8s nie szuka w lokalnych obrazach tylko w swej bazie.
![alt text](3_nginx_pod.png)

Sprawdzono także poprawność działania w dashboard.
![alt text](3_nginx_dash.png)

Uruchomiono eksponowaną przez pod stronę, która włączyła się poprawnie.
![alt text](3_nginx_kom.png)

---

# Przekucie wdrożenia manualnego w plik wdrożenia (wprowadzenie)
Sporządzono plik `.yaml` (załączony). Sprawdzono status za pomocą `rollout`.
![alt text](4_deploy_terminal.png)

Potwierdzono działanie wyeksponowanej usługi.
![alt text](4_deploy_site.png)