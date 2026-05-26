# Sprawozdanie 10 - Wdrażanie na zarządzalne kontenery: Kubernetes (1)

**Jan Wojsznis 422049**

---

## 1. Cel ćwiczenia

Celem ćwiczenia było uruchomienie lokalnego klastra *Kubernetes* z wykorzystaniem narzędzia *minikube*, przygotowanie aplikacji kontenerowej, uruchomienie jej jako *pod*, a następnie przeniesienie wdrożenia do plików konfiguracyjnych YAML. W ramach zadania wykorzystano obraz *nginx* z własną stroną `index.html`, dzięki czemu aplikacja działała jako kontener i udostępniała funkcjonalność przez HTTP.

W ćwiczeniu wykorzystano maszynę `devops`, środowisko Docker, narzędzie `minikube` oraz polecenie `kubectl` uruchamiane w wariancie dostarczanym przez `minikube`.

---

## 2. Instalacja i uruchomienie klastra Kubernetes

Na początku pobrano i zainstalowano narzędzie `minikube`. Program został pobrany jako plik binarny i przeniesiony do katalogu `/usr/local/bin`, dzięki czemu był dostępny globalnie w systemie.

Do obsługi klastra przygotowano alias:

    alias minikubectl="minikube kubectl --"

Alias pozwala korzystać z `kubectl` w wariancie minikube bez wpisywania pełnej komendy za każdym razem.

Klaster uruchomiono z wykorzystaniem sterownika Docker:

    minikube start --driver=docker --memory=3072 --cpus=2

Podczas uruchamiania pojawiło się ostrzeżenie o małej ilości miejsca dostępnej dla Dockera. Problem został uwzględniony w dalszej pracy przez czyszczenie niepotrzebnych danych Dockera oraz ograniczenie zasobów klastra do `3072 MB` pamięci i `2` CPU. Po uruchomieniu sprawdzono stan klastra:

    minikube status
    minikubectl get nodes
    minikubectl get pods -A

Wynik potwierdził, że klaster działa, a node `minikube` ma status `Ready`. Widoczne były również podstawowe pody systemowe w przestrzeni nazw `kube-system`.

![Instalacja i status minikube](./ss/10/01-minikube-install-status.png)

---

## 3. Sprawdzenie kontekstu i Dashboardu

Po uruchomieniu klastra sprawdzono aktualny kontekst Kubernetes oraz konfigurację dostępu do klastra:

    minikubectl config current-context
    minikubectl config view --minify

Kontekst wskazywał na lokalny klaster `minikube`. Konfiguracja dostępu wykorzystywała lokalny plik `kubeconfig` oraz certyfikaty klienta wygenerowane przez minikube.

Sprawdzono również uprawnienia bieżącego użytkownika:

    minikubectl auth can-i get pods
    minikubectl auth can-i create deployments

W obu przypadkach otrzymano odpowiedź `yes`, co oznacza, że użytkownik posiadał uprawnienia wymagane do dalszej pracy z podami i deploymentami.

Następnie uruchomiono *Kubernetes Dashboard*:

    minikube addons enable dashboard
    minikube dashboard --url

Dashboard został udostępniony przez lokalny adres HTTP i otwarty w przeglądarce. Początkowo w przestrzeni nazw `default` nie było jeszcze własnych zasobów aplikacyjnych, dlatego Dashboard pokazywał pusty widok workloadów.

![Kontekst, uprawnienia i Dashboard URL](./ss/10/02-security-dashboard-url.png)

![Dashboard Kubernetes](./ss/10/03-dashboard-view.png)

---

## 4. Przygotowanie obrazu Docker z aplikacją

Jako aplikację wybrano `nginx` z własną stroną HTML. Rozwiązanie to spełnia wymaganie uruchomienia kontenera, który działa stale i udostępnia funkcjonalność przez sieć.

Utworzono katalog `k8s/app` oraz plik `index.html` z prostą stroną:

    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>JW422049 Kubernetes</title>
    </head>
    <body>
        <h1>JW422049 - Kubernetes</h1>
        <p>Aplikacja nginx uruchomiona w klastrze minikube.</p>
    </body>
    </html>

Następnie przygotowano plik `Dockerfile`:

    FROM nginx:alpine
    COPY app/index.html /usr/share/nginx/html/index.html
    EXPOSE 80

Obraz zbudowano w środowisku Docker wykorzystywanym przez minikube:

    eval $(minikube docker-env)
    docker build -t jw422049-nginx-k8s:1.0 .
    docker images | grep jw422049-nginx-k8s

Wynik potwierdził, że obraz `jw422049-nginx-k8s:1.0` został poprawnie zbudowany i był dostępny lokalnie dla klastra minikube.

![Budowanie obrazu Docker](./ss/10/04-app-docker-build.png)

---

## 5. Ręczne uruchomienie aplikacji jako pod

Aplikację uruchomiono ręcznie jako pojedynczy *pod* za pomocą polecenia `kubectl run`:

    minikubectl run jw422049-nginx-pod --image=jw422049-nginx-k8s:1.0 --port=80 --labels app=jw422049-nginx-pod --image-pull-policy=Never

Opcja `--image-pull-policy=Never` była potrzebna, ponieważ obraz został zbudowany lokalnie w środowisku minikube i nie był pobierany z zewnętrznego rejestru.

Stan poda sprawdzono poleceniami:

    minikubectl get pods
    minikubectl describe pod jw422049-nginx-pod

Po chwili pod osiągnął stan `Running`. Następnie wykonano przekierowanie portu z poda na lokalny port `8081`:

    minikubectl port-forward pod/jw422049-nginx-pod 8081:80

![Pod i port-forward](./ss/10/05-pod-port-forward.png)

Działanie aplikacji sprawdzono poleceniem:

    curl http://127.0.0.1:8081

Otrzymano odpowiedź HTML z własną stroną `JW422049 - Kubernetes`, co potwierdziło, że kontener działa poprawnie w Kubernetesie i udostępnia funkcjonalność przez HTTP.

![Curl do poda](./ss/10/06-pod-curl.png)

---

## 6. Deployment zapisany jako plik YAML

Po przetestowaniu ręcznego uruchomienia aplikacji przygotowano deklaratywne wdrożenie w pliku `deployment.yml`.

Plik definiował obiekt typu `Deployment`, wykorzystujący obraz `jw422049-nginx-k8s:1.0`. Wdrożenie zostało skonfigurowane na 4 repliki:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: jw422049-nginx-deployment
    spec:
      replicas: 4
      selector:
        matchLabels:
          app: jw422049-nginx
      template:
        metadata:
          labels:
            app: jw422049-nginx
        spec:
          containers:
            - name: jw422049-nginx
              image: jw422049-nginx-k8s:1.0
              imagePullPolicy: Never
              ports:
                - containerPort: 80

Deployment wdrożono poleceniem:

    minikubectl apply -f deployment.yml

Następnie sprawdzono przebieg wdrożenia:

    minikubectl rollout status deployment/jw422049-nginx-deployment
    minikubectl get deployments
    minikubectl get pods -l app=jw422049-nginx

Wynik pokazał, że deployment został poprawnie utworzony, a wszystkie 4 repliki działały jako pody w stanie `Running`.

![Deployment i rollout](./ss/10/07-deployment-rollout.png)

---

## 7. Service dla deploymentu

Aby zapewnić stabilny punkt dostępu do replik aplikacji, przygotowano plik `service.yml`. Obiekt typu *Service* wybierał pody po etykiecie `app: jw422049-nginx` i kierował ruch na port `80`.

Plik `service.yml`:

    apiVersion: v1
    kind: Service
    metadata:
      name: jw422049-nginx-service
    spec:
      selector:
        app: jw422049-nginx
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
      type: ClusterIP

Service wdrożono poleceniem:

    minikubectl apply -f service.yml

Następnie sprawdzono jego stan:

    minikubectl get services
    minikubectl describe service jw422049-nginx-service

W opisie serwisu widoczne były endpointy odpowiadające podom utworzonym przez deployment. Oznacza to, że Service poprawnie powiązał się z replikami aplikacji.

![Service YAML](./ss/10/08-service-yaml.png)

---

## 8. Przekierowanie portu do Service

Aby sprawdzić działanie aplikacji przez Service, wykonano przekierowanie portu lokalnego `8091` do portu `80` serwisu:

    minikubectl port-forward service/jw422049-nginx-service 8091:80

![Port-forward do Service](./ss/10/09-service-port-forward.png)

Następnie wykonano zapytanie HTTP:

    curl http://127.0.0.1:8091

Odpowiedź zawierała stronę HTML przygotowaną w obrazie Docker, co potwierdziło, że ruch przechodzi przez Service do jednego z podów deploymentu.

![Curl do Service](./ss/10/10-service-curl.png)

Aplikację sprawdzono również w przeglądarce przez port `8091`.

![Aplikacja w przeglądarce](./ss/10/11-browser-app.png)

---

## 9. Widok zasobów w Dashboardzie

Po wykonaniu deploymentu i utworzeniu serwisu odświeżono Kubernetes Dashboard. W widoku *Workloads* widoczny był deployment `jw422049-nginx-deployment`, cztery działające pody oraz ReplicaSet utrzymujący wymaganą liczbę replik.

Dashboard pokazywał, że:
- deployment działa poprawnie,
- liczba podów wynosi `4/4`,
- wszystkie pody są w stanie `Running`,
- zasoby zostały utworzone w namespace `default`.

![Dashboard z workloadami](./ss/10/12-dashboard-workloads.png)

---

## 10. Końcowy stan plików i zasobów

Na końcu sprawdzono stan zasobów Kubernetes oraz pliki przygotowane w katalogu `k8s`.

Wykonano polecenia:

    minikubectl get all
    minikubectl get pods -o wide
    ls -la

Wynik potwierdził, że w klastrze działa:
- deployment `jw422049-nginx-deployment`,
- cztery pody aplikacji,
- ReplicaSet utrzymujący cztery repliki,
- Service `jw422049-nginx-service`.

W katalogu roboczym znajdowały się również pliki:
- `Dockerfile`,
- `deployment.yml`,
- `service.yml`,
- katalog `app` z plikiem `index.html`.

![Końcowy stan klastra i plików](./ss/10/13-final-state-files.png)

---

## 11. Podsumowanie

W ramach ćwiczenia uruchomiono lokalny klaster Kubernetes z wykorzystaniem narzędzia minikube i sterownika Docker. Przygotowano alias `minikubectl`, sprawdzono stan klastra, działający node oraz podstawowe pody systemowe. Zweryfikowano również kontekst klastra i uprawnienia użytkownika.

Następnie przygotowano własny obraz Docker oparty o `nginx:alpine`, zawierający prostą stronę `index.html`. Obraz został uruchomiony ręcznie jako pojedynczy pod, a jego działanie sprawdzono przez `port-forward` i `curl`.

W kolejnym kroku ręczne wdrożenie zostało zastąpione deklaratywnym plikiem `deployment.yml`. Deployment uruchomiono z czterema replikami, a poprawność wdrożenia potwierdzono poleceniem `rollout status`, widokiem podów oraz Dashboardem. Aplikację wystawiono przez obiekt `Service`, a komunikację z usługą potwierdzono przez przekierowanie portu i żądanie HTTP.

Ćwiczenie zakończyło się powodzeniem. Aplikacja kontenerowa została poprawnie uruchomiona w Kubernetesie, wdrożona jako deployment z czterema replikami i udostępniona przez Service.