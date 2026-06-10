# Zbiorcze Sprawozdanie z Laboratoriów: Wdrażanie na zarządzalne kontenery (Kubernetes)
**Zajęcia:** Laboratorium 10 oraz 11
**Autor:** Krzysztof Mamcarz (KM414315)

---

## Wstęp
Celem zrealizowanych ćwiczeń było zapoznanie się z architekturą, administracją oraz mechanizmami wysokiej dostępności oferowanymi przez system orkiestracji Kubernetes (K8s). Prace podzielono na dwa etapy: instalację klastra i podstawowe wdrożenia deklaratywne (Lab 10) oraz zaawansowane zarządzanie cyklem życia aplikacji, skalowanie i ewaluację różnych strategii aktualizacji oprogramowania (Lab 11).

---

## CZĘŚĆ I: Laboratorium 10 – Architektura klastra i podstawowe wdrożenia

### 1. Inicjalizacja środowiska i weryfikacja
Wdrożenie klastra zrealizowano w środowisku lokalnym za pomocą narzędzia `minikube` z wykorzystaniem silnika wirtualizacji Docker. 
```bash
minikube start --driver=docker
```
Poprawność uruchomienia węzła sterującego (control-plane) zweryfikowano komendą `kubectl get nodes`, uzyskując status `Ready` dla węzła bazowego. Uruchomiono również wbudowany panel administracyjny (`minikube dashboard`), potwierdzając komunikację z interfejsem graficznym klastra.4

### 2. Uruchomienie jednostki uruchomieniowej (Pod)

```bash
kubectl run apka-lab10 --image=nginx:latest --port=80 --labels app=apka-lab10
```

Aby zweryfikować dostępność usługi, wyprowadzono port z wnętrza kontenera na interfejs lokalny (port-forwarding), co pozwoliło uzyskać poprawną odpowiedź HTTP (`Welcome to nginx!`) pod adresem `localhost:8080`.

### 3. Wdrożenie deklaratywne (Deployment) i Serwis

Pojedynczy Pod nie zapewnia wysokiej dostępności. Dlatego proces wdrożenia przekuto w plik konfiguracyjny YAML realizujący obiekt typu `Deployment`, upewniając się, że klaster będzie utrzymywał pożądaną liczbę 4 replik aplikacji.

```yml
# Plik: deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apka-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: apka-lab10
  template:
    metadata:
      labels:
        app: apka-lab10
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

Stan rozruchu wdrożenia pomyślnie zbadano komendą `kubectl rollout status deployment/apka-deployment`.
Aby zunifikować dostęp do rozproszonych replik, obiekt wyeksponowano za pomocą Serwisu (`NodePort`), zlecając Kubernetesowi automatyczne równoważenie ruchu sieciowego (Load Balancing).

## CZĘŚĆ II: Laboratorium 11 – Zarządzanie zasobami i strategie wdrożeń

### 1. Skalowanie poziome (Horizontal Scaling)

W ramach zapoznania się z elastycznością środowiska zaktualizowano liczbę replik aplikacji. Wykorzystano polecenie modyfikujące stan wdrożenia w locie:

```bash
kubectl scale deployment apka-deployment --replicas=8
```

Przetestowano również ekstremalne przypadki redukcji zasobów: zmniejszenie do 1 repliki, całkowite wygaszenie środowiska (0 replik - tzw. Scale-to-Zero) oraz ponowne przywrócenie operacyjności na poziomie 4 instancji.

### 2. Dystrybucja obrazów operacyjnych

W celu przeprowadzenia symulacji wdrożeniowych zbudowano trzy odrębne obrazy Docker bazujące na systemie Alpine:

    Stabilne wersje oprogramowania: `moja-apka:v1` oraz `moja-apka:v2`.

    Wersja krytycznie wadliwa, zawierająca komendę kończącą proces awarią: `exit 1` (`moja-apka:faulty`).

Obrazy te, zamiast dystrybucji poprzez zewnętrzny Docker Hub, zostały bezpośrednio załadowane do wewnętrznego silnika klastra komendą `minikube image load`, optymalizując tym samym zużycie pamięci.

### 3. Aktualizacje Rollout oraz obsługa błędu (Rollback)

Przećwiczono nałożenie nowej wersji obrazu na funkcjonujący system. Następnie celowo naruszono stabilność środowiska, wdrażając obraz `faulty`.

```bash
kubectl set image deployment/apka-deployment nginx=moja-apka:faulty
```

Architektura wdrożenia `RollingUpdate` zadziałała prawidłowo – K8s po wykryciu awarii w nowo powołanych kontenerach (`CrashLoopBackOff`), zatrzymał postęp aktualizacji, nie wyłączając stabilnych starych instancji. Sytuację krytyczną zneutralizowano za pomocą operacji cofnięcia aktualizacji:

```bash
kubectl rollout undo deployment/apka-deployment
```

### 4. Skrypt zautomatyzowanej kontroli wdrożenia

Aby ułatwić potoki CI/CD, napisano poniższy skrypt `bash`, sprawdzający, czy nowo definiowane wdrożenie osiągnie fazę stabilną w akceptowalnym oknie czasowym (60 sekund).

```bash
#!/bin/bash
# Plik: sprawdz-wdrozenie.sh
if kubectl rollout status deployment/apka-deployment --timeout=60s; then
  echo "SUKCES: Wdrozenie stabilne i gotowe!"
else
  echo "BLAD: Wdrozenie nie powiodlo sie w wyznaczonym czasie (60s)."
  exit 1
fi
```

### 5. Architektoniczne strategie wdrożeniowe

W ostatnim etapie poddano ocenie trzy odmienne strategie aktualizacji oprogramowania w środowisku rozproszonym.

**A) Strategia Recreate**
Wymusza usunięcie wszystkich istniejących Podów przed utworzeniem nowych. Powoduje całkowitą przerwę w dostępie, ale zapobiega problemom ze współdzieleniem zasobów. Zdefiniowano ją poprzez blok:

```yml
strategy:
  type: Recreate
```

**B) Zmodyfikowany Rolling Update**
Umożliwia łagodną aktualizację bez przestojów. Dostosowano parametry szybkości wygaszania starych węzłów względem tolerancji nadmiarowości nowo powstających instancji:

```yml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 2
    maxSurge: 25%
```

**C) Canary Deployment (Wdrożenie Kanarkowe)**

Architekturę tę osiągnięto poprzez użycie selektorów powiązanych z istniejącym Serwisem. Wdrożono niezależny manifest z pojedynczą repliką aplikacji w wersji ewaluacyjnej, współdzielący etykietę `app: apka-lab10`. Taki zabieg sprawił, że klaster dynamicznie dystrybuował mniejszą pulę żądań sieciowych w kierunku nowej architektury, chroniąc główny ruch na wypadek nieprzewidzianej awarii nowej wersji.

**Wnioski**: Laboratoria wykazały, że wykorzystanie w pełni deklaratywnych obiektów konfiguracyjnych YAML pozwala nie tylko na osiągnięcie absolutnej powtarzalności środowiska operacyjnego, ale i gwarantuje stabilność oraz ciągłość dostępu w przypadku aktualizacji oprogramowania na platformie produkcyjnej.
