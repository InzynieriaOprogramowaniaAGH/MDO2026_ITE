# Sprawozdanie 11 - Wdrażanie na zarządzalne kontenery: Kubernetes (2)

**Jan Wojsznis 422049**

---

## 1. Cel ćwiczenia

Celem ćwiczenia było rozwinięcie wdrożenia aplikacji w klastrze *Kubernetes* przygotowanym na poprzednich zajęciach. W ramach zadania przygotowano kolejne wersje obrazu kontenera, przeprowadzono aktualizacje deploymentu, sprawdzono skalowanie liczby replik, wykonano rollback po błędnym wdrożeniu oraz przetestowano różne strategie aktualizacji aplikacji.

Do ćwiczenia wykorzystano lokalny klaster *minikube*, obraz aplikacji oparty o `nginx:alpine` oraz pliki manifestów YAML zapisane w katalogu `k8s11`.

---

## 2. Przygotowanie wersji obrazów

Przygotowano trzy wersje obrazu aplikacji:

    jw422049-nginx-k8s:v1
    jw422049-nginx-k8s:v2
    jw422049-nginx-k8s:bad

Wersje `v1` i `v2` różniły się zawartością pliku `index.html`. Obie wersje były poprawnymi obrazami aplikacji nginx. Wersja `bad` została przygotowana jako obraz wadliwy. W pliku `Dockerfile.bad` nadpisano komendę startową kontenera:

    CMD ["false"]

Powoduje to natychmiastowe zakończenie procesu w kontenerze i błąd uruchomienia poda.

Obrazy zbudowano lokalnie w środowisku Dockera wykorzystywanym przez minikube:

    eval $(minikube docker-env)
    docker build -t jw422049-nginx-k8s:v1 -f Dockerfile.v1 .
    docker build -t jw422049-nginx-k8s:v2 -f Dockerfile.v2 .
    docker build -t jw422049-nginx-k8s:bad -f Dockerfile.bad .

Następnie sprawdzono dostępne obrazy:

    docker images | grep jw422049-nginx-k8s

Na liście widoczne były wersje `v1`, `v2` oraz `bad`.

![Przygotowanie obrazów v1, v2 i bad](./ss/11/01-images-v1-v2-bad.png)

---

## 3. Bazowe wdrożenie aplikacji

Jako punkt wyjścia przygotowano deployment `jw422049-nginx-lab11`. Wykorzystywał on obraz `jw422049-nginx-k8s:v1` i cztery repliki.

Fragment pliku `deployment.yml`:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: jw422049-nginx-lab11
    spec:
      replicas: 4
      selector:
        matchLabels:
          app: jw422049-nginx-lab11
      template:
        metadata:
          labels:
            app: jw422049-nginx-lab11
        spec:
          containers:
            - name: jw422049-nginx
              image: jw422049-nginx-k8s:v1
              imagePullPolicy: Never
              ports:
                - containerPort: 80

Deployment wdrożono poleceniem:

    minikubectl apply -f deployment.yml

Następnie sprawdzono status wdrożenia:

    minikubectl rollout status deployment/jw422049-nginx-lab11
    minikubectl get deployment jw422049-nginx-lab11
    minikubectl get pods -l app=jw422049-nginx-lab11

Wynik potwierdził poprawne wdrożenie aplikacji. Deployment miał stan `4/4`, a wszystkie pody działały jako `Running`.

![Bazowy deployment](./ss/11/02-base-deployment.png)

---

## 4. Skalowanie deploymentu

Następnie przetestowano zmianę liczby replik. Deployment został kolejno przeskalowany do 8, 1, 0 oraz ponownie do 4 replik.

Użyto poleceń:

    minikubectl scale deployment jw422049-nginx-lab11 --replicas=8
    minikubectl scale deployment jw422049-nginx-lab11 --replicas=1
    minikubectl scale deployment jw422049-nginx-lab11 --replicas=0
    minikubectl scale deployment jw422049-nginx-lab11 --replicas=4

Po zakończeniu skalowania sprawdzono stan końcowy:

    minikubectl get deployment jw422049-nginx-lab11
    minikubectl get pods -l app=jw422049-nginx-lab11

Kubernetes automatycznie tworzył lub usuwał pody tak, aby doprowadzić rzeczywisty stan klastra do stanu zadeklarowanego w deploymentcie. Stan końcowy po ponownym skalowaniu wynosił `4/4`, a wszystkie pody były w stanie `Running`.

![Skalowanie replik](./ss/11/03-scale-replicas.png)

---

## 5. Aktualizacja wersji obrazu

Kolejnym etapem była aktualizacja obrazu używanego przez deployment. Najpierw wdrożono wersję `v2`, a następnie przywrócono starszą wersję `v1`.

Aktualizacja do wersji `v2`:

    minikubectl set image deployment/jw422049-nginx-lab11 jw422049-nginx=jw422049-nginx-k8s:v2
    minikubectl rollout status deployment/jw422049-nginx-lab11

Powrót do wersji `v1`:

    minikubectl set image deployment/jw422049-nginx-lab11 jw422049-nginx=jw422049-nginx-k8s:v1
    minikubectl rollout status deployment/jw422049-nginx-lab11

Po każdej zmianie sprawdzono deployment i pody:

    minikubectl get deployment jw422049-nginx-lab11
    minikubectl get pods -l app=jw422049-nginx-lab11

Na końcu sprawdzono historię wdrożeń:

    minikubectl rollout history deployment/jw422049-nginx-lab11

Rollout zakończył się poprawnie, a historia deploymentu zawierała kolejne rewizje odpowiadające zmianom obrazu.

![Aktualizacja obrazu v2 i powrót do v1](./ss/11/04-rollout-v2-v1.png)

---

## 6. Wadliwy obraz i rollback

Następnie wdrożono wadliwą wersję obrazu:

    minikubectl set image deployment/jw422049-nginx-lab11 jw422049-nginx=jw422049-nginx-k8s:bad

Sprawdzono rollout z limitem czasu 60 sekund:

    minikubectl rollout status deployment/jw422049-nginx-lab11 --timeout=60s

Wdrożenie nie zakończyło się poprawnie. Pody uruchamiane z obrazu `bad` przechodziły w stan `Error`, ponieważ kontener kończył pracę natychmiast po starcie. W historii wdrożenia pojawiła się kolejna rewizja odpowiadająca wadliwej aktualizacji.

Sprawdzono historię:

    minikubectl rollout history deployment/jw422049-nginx-lab11

Następnie wykonano rollback do poprzedniej działającej wersji:

    minikubectl rollout undo deployment/jw422049-nginx-lab11
    minikubectl rollout status deployment/jw422049-nginx-lab11
    minikubectl get pods -l app=jw422049-nginx-lab11

Po cofnięciu wdrożenia pody wróciły do stanu `Running`, a deployment ponownie działał poprawnie.

![Wadliwy obraz i rollback](./ss/11/05-bad-image-rollback.png)

---

## 7. Skrypt kontroli wdrożenia

Przygotowano skrypt `check-rollout.sh`, który sprawdza, czy wskazany deployment zdążył poprawnie się wdrożyć w czasie 60 sekund.

Treść skryptu:

    #!/bin/bash
    DEPLOYMENT="$1"

    if [ -z "$DEPLOYMENT" ]; then
        echo "Uzycie: $0 <deployment>"
        exit 1
    fi

    minikube kubectl -- rollout status deployment/"$DEPLOYMENT" --timeout=60s
    STATUS=$?

    if [ $STATUS -eq 0 ]; then
        echo "Wdrozenie zakonczone sukcesem w czasie <= 60s"
    else
        echo "Wdrozenie nie zakonczylo sie sukcesem w czasie 60s"
    fi

    exit $STATUS

Nadano uprawnienia wykonywania:

    chmod +x check-rollout.sh

Skrypt uruchomiono dla bazowego deploymentu:

    ./check-rollout.sh jw422049-nginx-lab11

Wynik potwierdził, że wdrożenie zakończyło się sukcesem w czasie krótszym lub równym 60 sekund.

![Skrypt check-rollout.sh](./ss/11/06-check-rollout-script.png)

---

## 8. Strategia Recreate

Pierwszą przetestowaną strategią była `Recreate`. Przy tej strategii Kubernetes usuwa stare pody przed uruchomieniem nowych. Oznacza to prosty mechanizm aktualizacji, ale może powodować chwilową przerwę w dostępności aplikacji.

Przygotowano plik `strategies/recreate.yml`:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: jw422049-nginx-recreate
    spec:
      replicas: 4
      strategy:
        type: Recreate
      selector:
        matchLabels:
          app: jw422049-nginx-recreate
      template:
        metadata:
          labels:
            app: jw422049-nginx-recreate
        spec:
          containers:
            - name: jw422049-nginx
              image: jw422049-nginx-k8s:v1
              imagePullPolicy: Never
              ports:
                - containerPort: 80

Deployment wdrożono, a następnie zaktualizowano obraz do wersji `v2`:

    minikubectl apply -f strategies/recreate.yml
    minikubectl rollout status deployment/jw422049-nginx-recreate
    minikubectl set image deployment/jw422049-nginx-recreate jw422049-nginx=jw422049-nginx-k8s:v2
    minikubectl rollout status deployment/jw422049-nginx-recreate

Po aktualizacji deployment osiągnął stan `4/4`, a wszystkie pody działały poprawnie.

![Strategia Recreate](./ss/11/07-strategy-recreate.png)

---

## 9. Strategia RollingUpdate

Drugą strategią była `RollingUpdate`. W tym wariancie Kubernetes stopniowo wymienia stare pody na nowe. Dzięki temu aplikacja może pozostać dostępna w trakcie aktualizacji.

Przygotowano plik `strategies/rolling.yml` z parametrami:

    maxUnavailable: 2
    maxSurge: 25%

Fragment konfiguracji:

    strategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 2
        maxSurge: 25%

Cały deployment wykorzystywał cztery repliki i obraz `jw422049-nginx-k8s:v1`. Po wdrożeniu zmieniono obraz na `v2`:

    minikubectl apply -f strategies/rolling.yml
    minikubectl rollout status deployment/jw422049-nginx-rolling
    minikubectl set image deployment/jw422049-nginx-rolling jw422049-nginx=jw422049-nginx-k8s:v2
    minikubectl rollout status deployment/jw422049-nginx-rolling

W trakcie aktualizacji widoczne było stopniowe zastępowanie podów. Część starych replik kończyła pracę, a nowe pody pojawiały się bez pełnego zatrzymania deploymentu.

![Strategia RollingUpdate](./ss/11/08-strategy-rolling.png)

---

## 10. Strategia Canary

Ostatnim wariantem była strategia *Canary*. Została ona wykonana przez równoległe uruchomienie dwóch deploymentów: stabilnego oraz testowego.

Deployment stabilny:

    jw422049-nginx-stable

wykorzystywał obraz `jw422049-nginx-k8s:v1` i trzy repliki.

Deployment testowy:

    jw422049-nginx-canary

wykorzystywał obraz `jw422049-nginx-k8s:v2` i jedną replikę.

Oba deploymenty miały wspólną etykietę:

    app: jw422049-nginx-canary

oraz różniły się etykietą:

    track: stable
    track: canary

Dzięki temu Service mógł wybierać wszystkie pody aplikacji po etykiecie `app`, a jednocześnie dało się rozróżnić wersję stabilną i canary po etykiecie `track`.

Przygotowano pliki:

    strategies/canary-stable.yml
    strategies/canary-canary.yml
    strategies/canary-service.yml

Wdrożenie wykonano poleceniami:

    minikubectl apply -f strategies/canary-stable.yml
    minikubectl apply -f strategies/canary-canary.yml
    minikubectl apply -f strategies/canary-service.yml

Następnie sprawdzono deploymenty, pody z etykietami oraz service:

    minikubectl get deployments | grep jw422049-nginx
    minikubectl get pods -l app=jw422049-nginx-canary --show-labels
    minikubectl get service jw422049-nginx-canary-service

Wynik pokazał trzy pody stabilne oraz jeden pod canary. Taki układ pozwala testować nową wersję obrazu na ograniczonej części ruchu, bez pełnej wymiany całej aplikacji.

![Strategia Canary](./ss/11/09-strategy-canary.png)

---

## 11. Końcowy stan plików i zasobów

Na końcu sprawdzono strukturę plików oraz stan zasobów w klastrze:

    find . -maxdepth 3 -type f | sort
    minikubectl get deployments | grep jw422049-nginx
    minikubectl get pods | grep jw422049-nginx
    minikubectl get services | grep jw422049-nginx

W katalogu `k8s11` znajdowały się pliki:

    Dockerfile.v1
    Dockerfile.v2
    Dockerfile.bad
    deployment.yml
    check-rollout.sh
    strategies/recreate.yml
    strategies/rolling.yml
    strategies/canary-stable.yml
    strategies/canary-canary.yml
    strategies/canary-service.yml

W klastrze widoczne były działające deploymenty, pody oraz serwisy przygotowane w ramach testów. Stan końcowy potwierdził, że wszystkie wymagane warianty zostały zapisane jako pliki i wdrożone w Kubernetesie.

![Końcowy stan plików i zasobów](./ss/11/10-final-state-files.png)

---

## 12. Wnioski

W ramach ćwiczenia przygotowano kilka wersji obrazu aplikacji nginx i wykorzystano je do testowania aktualizacji w Kubernetesie. Wersje `v1` i `v2` działały poprawnie, natomiast wersja `bad` celowo kończyła działanie błędem. Pozwoliło to sprawdzić zachowanie deploymentu przy nieudanej aktualizacji oraz mechanizm cofania zmian przez `rollout undo`.

Skalowanie deploymentu pokazało, że Kubernetes automatycznie dopasowuje liczbę działających podów do zadeklarowanej liczby replik. Historia wdrożeń pozwala śledzić kolejne rewizje, a rollback umożliwia szybki powrót do poprzedniego działającego stanu.

Skrypt `check-rollout.sh` pozwala automatycznie sprawdzić, czy deployment osiągnął gotowość w czasie 60 sekund. Strategie `Recreate`, `RollingUpdate` i `Canary` różnią się sposobem wymiany wersji aplikacji. `Recreate` jest proste, ale może powodować przerwę w działaniu. `RollingUpdate` stopniowo wymienia pody i ogranicza przerwę w dostępności. `Canary` pozwala uruchomić nową wersję tylko na części replik, co jest bezpieczniejsze przy testowaniu zmian.