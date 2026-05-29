# Sprawozdanie laboratorium nr 8
**Autor:** Aleksandra Duda, grupa 2

## Cel
Celem laboratorium było wdrożenie na zarządzalne kontenery oraz zapoznanie się z Kubernetes.

--------------------------------------------------------------------------------------

## Zadania do wykonania
### Instalacja klastra Kubernetes
 * Zaopatrz się w implementację stosu k8s: [minikube](https://minikube.sigs.k8s.io/docs/start/)
 * Przeprowadź instalację, wykaż poziom bezpieczeństwa instalacji
![alt text](image.png)
 Dodatkowo posprzątałam pobrany plik tymczasowy.

 Poziom bezpieczeństwa instalacji:
![alt text](image-1.png)
- Izolacja środowiska: Wykorzystanie sterownika docker sprawia, że Kubernetes działa wewnątrz odrębnego, odizolowanego kontenera i dedykowanej sieci Dockerowej na mojej maszynie wirtualnej.

 * Zaopatrz się w polecenie `kubectl` w wariancie minikube, może być alias `minikubctl`, jeżeli masz już "prawdziwy" `kubectl
Minikube ma już wbudowane narzędzie kubectl. Żeby nie instalować kolejnego programu i zachować kompatybilność, stworzyłam alias w konfiguracji mojego terminala (.bashrc). source ~/.bashrc przeładowuje konfiguracje, aby alias zaczął działać w obecnej sesji.
![alt text](image-2.png)
 * Uruchom Kubernetes, pokaż działający kontener/worker
Sprawdzenie działającego węzła - użyłam nowo utworzonego aliasu, żeby odpytać API Kubenertesa:
![alt text](image-3.png)
Nie zadziałał on niestety poprawnie. Problemem był brak uprawnień przy poleceniu minikube start --driver=docker, naprawiłam problem dodając użytkownika do grupy docker:
![alt text](image-4.png)
Tym razem Minikube odpalił się poprawnie.
Weryfikacja:
![alt text](image-5.png)

 * Uruchom Dashboard, otwórz w przeglądarce, przedstaw łączność
![alt text](image-6.png)
Łączność z graficznym panelem sterowania została uzyskana dzięki wbudowanemu w Minikube mechanizmowi proxy, który wystawia bezpieczny punkt dostępowy do API klastra. Środowisko VS Code automatycznie tuneluje ten ruch z maszyny wirtualnej na port hosta, umożliwiając interaktywne monitorowanie bezpośrednio z poziomu lokalnej przeglądarki internetowej.

 * Zapoznaj się z koncepcjami funkcji wyprowadzanych przez Kubernetesa (*pod*, *deployment* itp)
Pod to najmniejsza, podstawowa jednostka w Kubernetesie, która uruchamia i izoluje kontener z aplikacją, natomiast Deployment to nadrzędny zarządca (kontroler), który automatycznie dba o to, aby zadeklarowana liczba podów stale działała, samodzielnie je restartując lub skalując w przypadku awarii.

 
### Analiza posiadanego kontenera
   W powyższej sekcji wybrałam opcję optimum, czyli serwer nginx, ponieważ na ostatnich zajęciach wykorzystałam aplikację hello-world która tylko wypisywała tekst i od razu się wyłączała. Kubernetes potrzebuje aplikacji, która działa bez przerwy.
   Najpierw stworzyłam prosty plik index.html z napisem.
   ![alt text](image-7.png)
   Następnie stworzyłam Dockerfile, który bazuje na nginx i podmienia domyślną stronę na moją.
   ![alt text](image-8.png)

   Połączyłam terminal ze środowiskiem Dockera w Minikube - Minikube ma swój wewnętrzny silnik Dockera. Żeby Kubernetes widział obraz bez wysyłania go do internetu (Docker Hub), nakazałam terminalowi budowanie obrazu bezpośrednio wewnątrz Minikube.
   ![alt text](image-9.png)

   Następnie zbudowałam obraz aplikacji:
   ![alt text](image-10.png)
   
### Uruchamianie oprogramowania
Po uruchomieniu aplikacji:
    ![alt text](image-11.png)
Pod działa:
![alt text](image-14.png)

Wyprowadziłam port celem dotarcia do eksponowanej funkcjonalności:
    ![alt text](image-13.png)

Przedstawienie komunikacji z eskopnowaną funkcjonalnością - wyswietlenie mojej strony (niestety umieściłam w tekście polskie znaki):
    ![alt text](image-12.png)


### Przekucie wdrożenia manualnego w plik wdrożenia (wprowadzenie)
Stworzyłam plik deployment.yaml:
![alt text](image-15.png)
Zadeklarowałam w nim 4 repliki.

Uruchomiłam wdrożenie:
![alt text](image-16.png)

Zbadałam stan za pomocą ```kubectl rollout status```:
![alt text](image-17.png)
Działają wszystkie 4 pody.

Wyeksponowałam wdrożenie jako serwis, żebt ruch sieciowy rozkładał się automatycznie na wszystkie 4 pody:
![alt text](image-18.png)

Następnie przekierowałam port do serwisu:
![alt text](image-19.png)
Wszystko działa, tym razem za pomocą 4 zsynchronizowanych podów:
![alt text](image-20.png)

Widok z dashboardu:
![alt text](image-21.png)
Dashboard wskazał łączną liczbę 5 działających podów. Wynika to z faktu, że klaster utrzymuje teraz 4 pody wygenerowane automatycznie oraz 1 pod uruchomiony wcześniej drogą manualną.

--------------------------------------------------------------------------------------------

 ## Wnioski
Lokalny Minikube na Dockerze pozwala szybko postawić całego Kubenertesa wewnątrz zwykłej maszyny wirtualnej. Najlepszym rozwiązaniem jest zamiana ręcznego wklepywania komend na jeden gotowy plik YAML, dzięki czemu wystarczy raz napisać konfigurację, a orkiestrator sam ją wdroży. Obiekty deployment i service pokazały, jak łatwo można sklonować aplikację do kilku kopii i automatycznie rozdzielać między nimi ruch, żeby serwer nie przestał działać pod dużym obciążeniem.

 Treść Dockerfile:
 ```Dockerfile
 FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
 ```

Treść deployment.yaml:
```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-lab10-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: app-lab10-multipod
  template:
    metadata:
      labels:
        app: app-lab10-multipod
    spec:
      containers:
      - name: nginx-container
        image: app-lab10:v1
        ports:
        - containerPort: 80
```