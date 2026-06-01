# Kubernetes Lab 2 — Wdrażanie na zarządzalne kontenery

## Opis laboratorium

Laboratorium obejmuje zarządzanie wdrożeniami w Kubernetes: przygotowanie obrazów Docker w wielu wersjach, skalowanie Deploymentów, obsługę rollbacków oraz implementację trzech strategii wdrożeń (Recreate, Rolling Update, Canary).

---

## Struktura projektu

```
k8s-lab2/
├── images/
│   ├── Dockerfile.v1        # httpd v1.0 – niebieski UI
│   ├── Dockerfile.v2        # httpd v2.0 – zielony UI
│   └── Dockerfile.broken    # celowo błędny kontener (CrashLoopBackOff)
├── deployments/
│   ├── deploy-base.yaml     # bazowy deployment do skalowania
│   ├── deploy-recreate.yaml # strategia Recreate
│   ├── deploy-rolling.yaml  # strategia RollingUpdate
│   ├── deploy-canary.yaml   # strategia Canary (stable + canary)
│   └── service.yaml         # NodePort na porcie 30080
└── scripts/
    ├── check_rollout.sh     # weryfikacja wdrożenia (60s timeout)
    └── demo_all.sh          # automatyczne demo wszystkich kroków
```

---

## 1. Przygotowanie obrazów Docker

Przygotowano trzy obrazy oparte na `httpd:2.4-alpine` (własny zmodyfikowany kontener):

| Obraz | Tag | Opis |
|-------|-----|------|
| `<DOCKERHUB>/myapp` | `v1` | Działający serwer HTTP, niebieski interfejs |
| `<DOCKERHUB>/myapp` | `v2` | Działający serwer HTTP, zielony interfejs |
| `<DOCKERHUB>/myapp` | `broken` | Kontener kończy się błędem `exit 1` — symuluje CrashLoopBackOff |

### Budowanie i publikacja

```bash
# Wersja v1
docker build -f Dockerfile.v1 -t <DOCKERHUB>/myapp:v1 .
docker push <DOCKERHUB>/myapp:v1

# Wersja v2
docker build -f Dockerfile.v2 -t <DOCKERHUB>/myapp:v2 .
docker push <DOCKERHUB>/myapp:v2

# Wersja broken
docker build -f Dockerfile.broken -t <DOCKERHUB>/myapp:broken .
docker push <DOCKERHUB>/myapp:broken
```

---

## 2. Zmiany w Deploymencie i skalowanie

Wszystkie operacje wykonywane na `deploy-base.yaml` z podmianą tagu obrazu lub wartości `replicas`.

| Operacja | Komenda |
|----------|---------|
| Zastosowanie pliku YAML | `kubectl apply -f deploy-base.yaml` |
| Skalowanie do 8 replik | `kubectl scale deployment/myapp --replicas=8` |
| Skalowanie do 1 repliki | `kubectl scale deployment/myapp --replicas=1` |
| Skalowanie do 0 (zatrzymanie) | `kubectl scale deployment/myapp --replicas=0` |
| Ponowne skalowanie do 4 | `kubectl scale deployment/myapp --replicas=4` |
| Aktualizacja obrazu do v2 | `kubectl set image deployment/myapp myapp=<DOCKERHUB>/myapp:v2` |
| Powrót do v1 | `kubectl set image deployment/myapp myapp=<DOCKERHUB>/myapp:v1` |
| Wdrożenie broken | `kubectl set image deployment/myapp myapp=<DOCKERHUB>/myapp:broken` |

Po wdrożeniu broken widać `CrashLoopBackOff` w `kubectl get pods`.

---

## 3. Rollback wdrożenia

```bash
# Podgląd historii rewizji
kubectl rollout history deployment/myapp

# Cofnięcie do poprzedniej wersji
kubectl rollout undo deployment/myapp

# Cofnięcie do konkretnej rewizji
kubectl rollout undo deployment/myapp --to-revision=2
```

Historia wdrożenia zapisuje każdą zmianę (skalowanie, zmiana obrazu). Rewizje z `broken` są widoczne jako zakończone błędem — można je skorelować z wykonywanymi czynnościami przez `kubectl describe deployment/myapp` oraz `kubectl get events --sort-by=.metadata.creationTimestamp`.

---

## 4. Skrypt weryfikujący wdrożenie (60 sekund)

Plik: `scripts/check_rollout.sh`

```bash
#!/bin/bash
DEPLOYMENT=${1:-myapp}
TIMEOUT=60

echo "Sprawdzam wdrożenie: $DEPLOYMENT (timeout: ${TIMEOUT}s)..."
if kubectl rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s; then
    echo "OK: Wdrożenie zakończone pomyślnie."
    exit 0
else
    echo "BŁĄD: Wdrożenie nie zakończyło się w ${TIMEOUT}s."
    kubectl get pods -l app=$DEPLOYMENT
    exit 1
fi
```

Skrypt zwraca `exit 0` przy sukcesie lub `exit 1` przy przekroczeniu czasu — gotowy do użycia w pipeline Jenkins jako krok weryfikacyjny.

### Integracja z Jenkins (zakres rozszerzony)

```groovy
stage('Verify Rollout') {
    steps {
        sh './scripts/check_rollout.sh myapp'
    }
}
```

---

## 5. Strategie wdrożeń

### 5.1 Recreate

```yaml
strategy:
  type: Recreate
```

Wszystkie stare pody są **usuwane jednocześnie** przed uruchomieniem nowych. Powoduje krótką przerwę w działaniu usługi.

**Zastosowanie:** aktualizacje wymagające całkowitego zatrzymania (np. migracje bazy, niekompatybilne zmiany API).

---

### 5.2 Rolling Update

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 2
    maxSurge: 2        # >20% przy 8 replikach
```

Stare pody są zastępowane nowymi **stopniowo** — w każdym momencie działa część starych i część nowych. Brak przestoju.

**Zastosowanie:** standardowe aktualizacje aplikacji bezstanowych.

---

### 5.3 Canary Deployment

Dwa osobne Deploymenty z tym samym selektorem `app: myapp`, obsługiwane przez jeden Service:

- `myapp-stable` — 4 repliki (v1), etykieta `track: stable`
- `myapp-canary` — 1 replika (v2), etykieta `track: canary`

Ruch jest rozdzielany proporcjonalnie do liczby podów (4:1 = ~80% stable, ~20% canary). Pozwala przetestować nową wersję na małej części ruchu bez pełnego wdrożenia.

```bash
# Sprawdzenie rozkładu podów
kubectl get pods -l app=myapp --show-labels
```

---

## 6. Etykiety (Labels)

| Etykieta | Wartości | Cel |
|----------|----------|-----|
| `app` | `myapp`, `myapp-recreate`, `myapp-rolling` | Selektor Service – łączy pody z serwisem |
| `version` | `1.0`, `2.0` | Śledzenie wersji obrazu |
| `track` | `stable`, `canary` | Rozróżnienie replik w strategii Canary |

---

## 7. Porównanie strategii

| Strategia | Przestój | Kontrola | Użycie |
|-----------|----------|----------|--------|
| Recreate | Tak (chwilowy) | Pełna zamiana | Niekompatybilne zmiany |
| Rolling Update | Nie | Stopniowa zamiana | Standardowe aktualizacje |
| Canary | Nie | Częściowy rollout | Testowanie na podzbiorze ruchu |

---

## 8. Przydatne komendy

```bash
# Status podów
kubectl get pods -o wide

# Historia wdrożenia
kubectl rollout history deployment/myapp

# Szczegóły deploymentu
kubectl describe deployment myapp

# Logi poda (np. po CrashLoopBackOff)
kubectl logs <nazwa-poda> --previous

# Eventy posortowane czasowo
kubectl get events --sort-by=.metadata.creationTimestamp

# Dostęp do serwisu przez minikube
minikube service myapp-service --url
```

---

## 9. Screenshoty

### Środowisko i obrazy
| Plik | Opis |
|------|------|
| `minikube_dziala.png` | Uruchomiony minikube — `minikube status` |
| `obrazy.png` | Lista obrazów Docker — `docker images` |

### Skalowanie Deploymentu
| Plik | Opis |
|------|------|
| `0replik.png` | Deployment ze skalowaniem do 0 replik |
| `1replika.png` | Deployment z 1 repliką |
| `8replik.png` | Deployment z 8 replikami |
| `8replik_running.png` | 8 replik w stanie Running |
| `back4repliki.png` | Powrót do 4 replik |

### Wersje obrazów
| Plik | Opis |
|------|------|
| `nowsza_wersja.png` | Wdrożenie nowej wersji obrazu (v2) |
| `starsza_wersja.png` | Rollback do starszej wersji (v1) |
| `broken.png` | Wdrożenie wadliwego obrazu — CrashLoopBackOff |
| `working.png` | Powrót do działającej wersji po rollbacku |

### Rollback
| Plik | Opis |
|------|------|
| `rollout.png` | `kubectl rollout history` — historia rewizji |
| `rollout2.png` | Historia po kolejnych zmianach |
| `undo.png` | `kubectl rollout undo` — cofnięcie do poprzedniej wersji |

### Strategie wdrożeń
| Plik | Opis |
|------|------|
| `recreate.png` | Strategia Recreate — pody usuwane jednocześnie |
| `rolling_update.png` | Strategia Rolling Update — stopniowa zamiana |
| `canary.png` | Strategia Canary — stable (4 repliki) + canary (1 replika) |

### Skrypt weryfikujący
| Plik | Opis |
|------|------|
| `skrypt_wdrozeniowy.png` | Działanie `check_rollout.sh` — weryfikacja w 60s |

---


