# Zajęcia 10 - Wdrażanie na zarządzalne kontenery: Kubernetes (1)
## Wojciech Pieńkowski

---

### Pobranie oraz instalavja binarówn narzzedzia kubectl w systemie operacyjnym ubuntu w celu umożliwienia zarządzania klastrem Kubernetes z poziomu terminala.
![2](sprawozdanie10/2.png)

### Inicjalizacja lokalnego klastra komendą minikube start, w celu zapobiegnięcia problemów, musiłem start oraz ustawiłem ilość cpu i memory
![3](sprawozdanie10/3.png)

### Weryfikacja stanu klastra poleceniem minikube status, pokazująca pełny sukces konfiguracyjny, w którym wszystkie kluczowe komponenty uzyskały status Running.
![4](sprawozdanie10/4.png)

### Sprawdzenie dostępnych węzłów komendą kubectl get nodes, wskazujące, że węzeł minikube jest jeszcze w stanie NotReady.
![5](sprawozdanie10/5.png)

### Wywołanie usługi minikube dashboard, uruchamiające proces proxy w celu otwarcia graficznego panelu zarządzania klastrem w przeglądarce internetowej.
![6](sprawozdanie10/6.png)

### Przygotowanie pliku YAML dla zasobu typu Pod o nazwie moja-aplikacja-k8s.
![yml](sprawozdanie10/yml.png)

### Pomyślne wdrożenie aplikacji w klastrze za pomocą polecenia kubectl apply -f pod-nginx.yml oraz weryfikacja statusu Running dla utworzonego Poda.
![7](sprawozdanie10/7.png)

### Uruchomienie procesu ciągłego przekierowania portów poleceniem kubectl port-forward, które umożliwiło mapowanie ruchu sieciowego z portu kontenera na lokalny port 8080 maszyny wirtualnej.
![8](sprawozdanie10/8.png)

### Weryfikacja poprawnego działania serwera WWW za pomocą programu curl, która potwierdziła zwrócenie kodu źródłowego strony startowej Nginx.
![9](sprawozdanie10/9.png)
