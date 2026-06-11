# Sprawozdanie Lab 11 - Wdrażanie na zarządzalne kontenery: Kubernetes (2)

---

## 1. Przygotowanie nowego obrazu

Na bazie istniejącego obrazu `apl:latest` z poprzednich zajęć przygotowano trzy wersje obrazu:

- `apl:v1` – wersja bazowa (tag z `apl:latest`)
- `apl:v2` – zmodyfikowana strona startowa (`index.html` z nagłówkiem *Lab 11 - Zmodyfikowany*)
- `apl:v3-bad` – obraz celowo wadliwy: zawiera nieprawidłową komendę startową (`CMD ["nieistniejaca-komenda"]`), co powoduje `CrashLoopBackOff` przy uruchomieniu poda

```bash
docker tag apl:latest apl:v1
# zmiana index.html, rebuild
docker build -t apl:v2 .
# wadliwy Dockerfile z błędnym CMD
docker build -t apl:v3-bad -f Dockerfile.bad .
```

Wszystkie obrazy załadowano do środowiska minikube:

```bash
minikube image load apl:v1
minikube image load apl:v2
minikube image load apl:v3-bad
```

![Dostępne obrazy Docker](IMG/Zrzut%20ekranu%202026-06-09%20221844.png)

---

## 2. Zmiany w deploymencie

### Plik deployment.yml

Wdrożenie bazowe z 4 replikami i obrazem `apl:v1`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apl-deployment
  labels:
    app: apl
spec:
  replicas: 4
  selector:
    matchLabels:
      app: apl
  template:
    metadata:
      labels:
        app: apl
    spec:
      containers:
      - name: nginx-kontener
        image: apl:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
```

```bash
minikubectl apply -f deployment.yml
minikubectl rollout status deployment/apl-deployment
```

![Rollout status - successfully rolled out](IMG/Zrzut%20ekranu%202026-06-09%20222841.png)

### Skalowanie replik

Do zmiany liczby replik bez edycji pliku YAML użyto komendy `scale`:

```bash
minikubectl scale deployment/apl-deployment --replicas=8
minikubectl get pods
```

![8 replik Running](IMG/Zrzut%20ekranu%202026-06-09%20223106.png)

```bash
minikubectl scale deployment/apl-deployment --replicas=1
minikubectl get pods
```

![1 replika Running](IMG/Zrzut%20ekranu%202026-06-09%20223214.png)

```bash
minikubectl scale deployment/apl-deployment --replicas=0
minikubectl get pods
```

![0 replik - brak podów apl-deployment](IMG/Zrzut%20ekranu%202026-06-09%20223319.png)

```bash
minikubectl scale deployment/apl-deployment --replicas=4
minikubectl get pods
```

![Powrót do 4 replik Running](IMG/Zrzut%20ekranu%202026-06-09%20223453.png)

### Aktualizacja obrazu i rollback

Zastosowanie nowej wersji obrazu `apl:v2`:

```bash
minikubectl set image deployment/apl-deployment nginx-kontener=apl:v2
minikubectl rollout history deployment/apl-deployment
```

Kubernetes odnotował zmianę jako REVISION 2. Następnie wykonano cofnięcie do poprzedniej wersji:

```bash
minikubectl rollout undo deployment/apl-deployment
minikubectl rollout history deployment/apl-deployment
```

Po cofnięciu w historii pojawiła się REVISION 3 - Kubernetes traktuje powrót jako nową rewizję, a nie usunięcie poprzedniej.

![Historia rewizji i rollback do v1](IMG/Zrzut%20ekranu%202026-06-09%20223631.png)

### Wgranie wadliwej wersji `v3-bad`

```bash
minikubectl set image deployment/apl-deployment nginx-kontener=apl:v3-bad
minikubectl get pods
```

Pody nowej wersji natychmiast przeszły w stan `CrashLoopBackOff` i `Error` - obraz uruchamia się poprawnie, lecz nieistniejąca komenda powoduje natychmiastowy crash kontenera. Kubernetes automatycznie ponawia próby uruchomienia (widoczny licznik RESTARTS).

![CrashLoopBackOff przy wadliwym obrazie](IMG/Zrzut%20ekranu%202026-06-09%20223713.png)

Błyskawiczny powrót do sprawnej wersji:

```bash
minikubectl rollout undo deployment/apl-deployment
minikubectl get pods
```

![Pody Running po rollback](IMG/Zrzut%20ekranu%202026-06-09%20223809.png)

---

## 3. Kontrola wdrożenia

Napisano skrypt `verify.sh` weryfikujący, czy wdrożenie zakończy się w ciągu 60 sekund. Użyto zmiennych dla czytelności i łatwości modyfikacji:

```bash
#!/bin/bash

DEPLOYMENT="apl-deployment"
TIMEOUT=60

echo "Sprawdzam wdrożenie: $DEPLOYMENT (limit: ${TIMEOUT}s)"

minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s

STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Wdrożenie gotowe."
    exit 0
else
    echo "Wdrożenie nie ukończyło się w czasie ${TIMEOUT}s."
    exit 1
fi
```

```bash
chmod +x verify.sh
./verify.sh
```

Skrypt uruchomiono dwukrotnie: raz na sprawnym wdrożeniu (v1), drugi raz po ustawieniu wadliwego obrazu (v3-bad). W pierwszym przypadku wdrożenie zakończyło się sukcesem przed upływem limitu. W drugim skrypt odczekał pełne 60 sekund i zgłosił błąd, ponieważ repliki nie osiągnęły stanu `Ready`.

![Wynik skryptu - sukces i timeout](IMG/Zrzut%20ekranu%202026-06-09%20224942.png)

---

## 4. Strategie wdrożeń

### Recreate

```yaml
spec:
  replicas: 4
  strategy:
    type: Recreate
```

```bash
minikubectl apply -f deployment-recreate.yml
minikubectl set image deployment/apl-recreate nginx-kontener=apl:v2
minikubectl get pods -w
```

W strategii Recreate Kubernetes najpierw usuwa **wszystkie** działające pody jednocześnie (stan `Completed`), a dopiero potem tworzy nowe (`ContainerCreating`). Przez krótki moment klaster nie ma żadnej działającej instancji aplikacji - występuje przerwa w dostępności (downtime).

![Recreate - wszystkie pody Completed jednocześnie, potem nowe ContainerCreating](IMG/Zrzut%20ekranu%202026-06-09%20225611.png)

![Recreate - nowe pody wchodzą w stan Running](IMG/Zrzut%20ekranu%202026-06-09%20225641.png)

### Rolling Update

```yaml
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2
      maxSurge: 25%
```

```bash
minikubectl apply -f deployment-rolling.yml
minikubectl set image deployment/apl-rolling nginx-kontener=apl:v2
minikubectl get pods -w
```

W strategii Rolling Update wymiana odbywa się stopniowo. Parametr `maxUnavailable: 2` pozwala na jednoczesne wyłączenie maksymalnie 2 starych podów, a `maxSurge: 25%` dopuszcza 1 dodatkowy pod ponad docelową liczbę replik. Dzięki temu aplikacja pozostaje dostępna przez cały czas aktualizacji - w każdej chwili działają co najmniej 2 pody.

![Rolling Update - stopniowa wymiana, część podów Running, część Terminating/ContainerCreating](IMG/Zrzut%20ekranu%202026-06-09%20225941.png)

### Canary Deployment

Canary to strategia polegająca na równoległym uruchomieniu dwóch niezależnych wdrożeń obsługiwanych przez jeden serwis. Ruch jest rozdzielany proporcjonalnie do liczby replik: 3 pody `v1` i 1 pod `v2` oznacza, że około 25% ruchu trafia do nowej wersji.

Stworzono trzy pliki:
- `deployment-canary.yml` - główne wdrożenie (3 repliki, `apl:v1`, etykieta `version: v1`)
- `deployment-canary-test.yml` - wdrożenie testowe (1 replika, `apl:v2`, etykieta `version: v2`)
- `deployment-canary-serv.yml` - serwis z selektorem `app: apl-canary` (łapie pody obu wdrożeń)

```bash
minikubectl apply -f deployment-canary.yml
minikubectl apply -f deployment-canary-test.yml
minikubectl apply -f deployment-canary-serv.yml
minikubectl get pods --show-labels
```

![Canary - pody v1 i v2 widoczne jednocześnie z etykietami version=v1 i version=v2](IMG/Zrzut%20ekranu%202026-06-09%20230641.png)

---

## Porównanie strategii

| Strategia | Downtime | Szybkość | Ryzyko |
|-----------|----------|----------|--------|
| Recreate | Tak | Najszybsza | Wysokie - brak rollback w trakcie |
| Rolling Update | Nie | Stopniowa | Niskie - zawsze działa część podów |
| Canary | Nie | Kontrolowana | Minimalne - nowa wersja obsługuje tylko część ruchu |

---
## Wnioski
Kubernetes oferuje elastyczne mechanizmy zarządzania wdrożeniami. Skalowanie replik odbywa się natychmiastowo jedną komendą, bez edycji plików YAML. Historia rewizji (rollout history) i możliwość błyskawicznego cofnięcia (rollout undo) znacząco skracają czas reakcji na błędy produkcyjne, tak jak pokazał test z v3-bad, powrót do sprawnej wersji zajmuje kilka sekund.

Wybór strategii wdrożenia zależy od charakteru aplikacji: Recreate sprawdza się tam gdzie dopuszczalna jest krótka przerwa, Rolling Update zapewnia ciągłość działania przy stopniowej wymianie podów, a Canary pozwala testować nową wersję na małym procencie ruchu przed pełnym wdrożeniem.