# SPRAWOZDANIE 11
 
## Środowisko uruchomieniowe
 
- System operacyjny: Ubuntu 24.04 LTS - maszyna wirtualna `devops`
- Silnik wirtualizacji: Oracle VirtualBox
- Metoda dostępu: Zdalna sesja przez SSH (użytkownik: `karro`)
- Narzędzie orkiestracji: Kubernetes (minikube v1.38.1, Kubernetes v1.35.1)
- Silnik kontenerów: Docker 29.2.1
- Edytor kodu: GNU nano / Visual Studio Code (Remote SSH)
- Projekt: nginx z własną konfiguracją HTML, wersje `portfinder-web:v1`, `portfinder-web:v2`, `portfinder-web:broken`

 
## 1. Przygotowanie środowiska
 
Na początku uruchomiono minikube, skonfigurowano kontekst Docker oraz alias `kubectl`:
 
```bash
minikube start --driver=docker
eval $(minikube docker-env)
alias kubectl="minikube kubectl --"
```
 
![1](<img/Zrzut ekranu 2026-05-26 104230.png>)
 
## 2. Przygotowanie wersji obrazów
 
Przygotowano plik `index-v1.html` z oznaczeniem wersji:
 
![2](<img/Zrzut ekranu 2026-05-26 104311.png>)
 
Oraz `Dockerfile.v1`:
 
![3](<img/Zrzut ekranu 2026-05-26 104334.png>)
 
```dockerfile
FROM nginx:alpine
COPY index-v1.html /usr/share/nginx/html/index.html
EXPOSE 80
```
 
Zbudowano obraz `portfinder-web:v1`:
 
```bash
docker build -t portfinder-web:v1 -f Dockerfile.v1 .
```
 
![4](<img/Zrzut ekranu 2026-05-26 104357.png>)
 
Przygotowano `index-v2.html` z treścią "v2 updated":
 
![5](<img/Zrzut ekranu 2026-05-26 104510.png>)
 
Oraz `Dockerfile.v2`:
 
![6](<img/Zrzut ekranu 2026-05-26 104620.png>)
 
Zbudowano obraz `portfinder-web:v2`. Budowanie zajęło 0.8s - warstwa bazowa `nginx:alpine` była już w cache:
 
```bash
docker build -t portfinder-web:v2 -f Dockerfile.v2 .
```
 
![7](<img/Zrzut ekranu 2026-05-26 104642.png>)
 
Obraz `portfinder-web:broken` zasymulowano przez użycie nieistniejącej nazwy lokalnego obrazu przy `imagePullPolicy: Never`. Kubernetes nie próbuje pobrać obrazu z zewnętrznego rejestru i zgłasza błąd `ErrImageNeverPull`, co pozwala zaobserwować zachowanie klastra przy wadliwym wdrożeniu bez modyfikowania Dockerfile.
 
Potwierdzono dostępność trzech wersji w lokalnym rejestrze minikube:
 
```bash
docker images | grep portfinder
```
 
Dostępne: `portfinder-web:latest` (z lab10), `portfinder-web:v1` oraz `portfinder-web:v2`:
 
![8](<img/Zrzut ekranu 2026-05-26 104912.png>)
 
---
 
## 3. Zmiany w deploymencie
 
Stworzono plik `deployment.yml` z 4 replikami obrazu `portfinder-web:v1` i serwisem NodePort na porcie 30080:
 
![9](<img/Zrzut ekranu 2026-05-26 104702.png>)
 
Zastosowano wdrożenie:
 
```bash
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
kubectl get pods
```
 
4 pody ze statusem `Running`. Rollout wypisał komunikaty o oczekujących starych replikach (deployment był już wcześniej zdefiniowany z lab10):
 
![10](<img/Zrzut ekranu 2026-05-26 104731.png>)
 
Potwierdzono działanie serwisu:
 
```bash
curl http://$(minikube ip):30080
```
 
![11](<img/Zrzut ekranu 2026-05-26 110141.png>)
 
```bash
sed -i 's/replicas: 4/replicas: 8/' deployment.yml
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
kubectl get pods
```
 
Kubernetes dodał 4 kolejne pody. Rollout zakończył się po osiągnięciu 8 dostępnych replik (widoczne komunikaty `6 of 8`, `7 of 8`):
 
![12](<img/Zrzut ekranu 2026-05-26 104801.png>)
 
```bash
sed -i 's/replicas: 8/replicas: 1/' deployment.yml
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
kubectl get pods
```
 
Rollout zakończył się natychmiast - zmniejszenie liczby replik nie wymaga aktualizacji podów. Widoczna 1 działająca replika:
 
![13](<img/Zrzut ekranu 2026-05-26 105926.png>)
 
```bash
sed -i 's/replicas: 1/replicas: 0/' deployment.yml
kubectl apply -f deployment.yml
kubectl get pods
```
 
Wszystkie pody deploymentu zostały usunięte. Na liście pozostał tylko pod `portfinder-deploy` (uruchomiony manualnie przez `kubectl run` w lab10):
 
![14](<img/Zrzut ekranu 2026-05-26 104836.png>)
 
```bash
sed -i 's/replicas: 0/replicas: 4/' deployment.yml
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
kubectl get pods
```
 
4 nowe pody uruchomione w ciągu kilku sekund:
 
![15](<img/Zrzut ekranu 2026-05-26 104935.png>)
 
```bash
sed -i 's/image: portfinder-web:v1/image: portfinder-web:v2/' deployment.yml
sed -i 's/version: v1/version: v2/' deployment.yml
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
kubectl get pods
```
 
Kubernetes zastąpił stare pody nowymi - hash ReplicaSet zmienił się z `d9d857dc5` na `7987cfd65c`. Rollout wypisał komunikaty o oczekiwaniu na zakończenie starych replik:
 
![16](<img/Zrzut ekranu 2026-05-26 105007.png>)
 
Weryfikacja przez curl potwierdziła serwowanie wersji v2:
 
![17](<img/Zrzut ekranu 2026-05-26 105059.png>)
 
```bash
sed -i 's/image: portfinder-web:v2/image: portfinder-web:v1/' deployment.yml
sed -i 's/version: v2/version: v1/' deployment.yml
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
curl http://$(minikube ip):30080
```
 
Rollout przebiegł analogicznie. Curl potwierdził powrót do v1:
 
![18](<img/Zrzut ekranu 2026-05-26 105039.png>)
 
```bash
sed -i 's/image: portfinder-web:v1/image: portfinder-web:broken/' deployment.yml
kubectl apply -f deployment.yml
kubectl get pods
kubectl rollout status deployment/portfinder-deployment
```
 
Pody z nową wersją weszły w stan `ErrImageNeverPull`. Dzięki domyślnej strategii RollingUpdate stare pody (v1) pozostały uruchomione - aplikacja nadal częściowo działała. Rollout utknął w oczekiwaniu:
 
![19](<img/Zrzut ekranu 2026-05-26 105133.png>)
 
---
 
## 4. Historia i cofanie wdrożeń
 
```bash
kubectl rollout history deployment/portfinder-deployment
```
 
Historia zawiera rewizje 1, 3, 4, 5 odpowiadające kolejnym zmianom. Rewizja 2 została skonsumowana przez wcześniejszą operację `undo`. Skalowanie (replicas) nie tworzy nowej rewizji, dlatego brak rewizji 2 w historii:
 
![20](<img/Zrzut ekranu 2026-05-26 105524.png>)
 
Późniejszy widok historii (rewizje 1, 3, 11, 12) po dalszych operacjach:
 
![21](<img/Zrzut ekranu 2026-05-26 115610.png>)
 
```bash
kubectl rollout undo deployment/portfinder-deployment
```
 
Polecenie cofnęło wdrożenie z wadliwego obrazu `broken` do poprzedniej działającej rewizji (v1). Deployment otrzymał status `rolled back`:
 
![22](<img/Zrzut ekranu 2026-05-26 105743.png>)
 
Po cofnięciu rollout status potwierdził poprawne wdrożenie, a curl zwrócił stronę v1:
 
![23](<img/Zrzut ekranu 2026-05-26 105855.png>)
 
```bash
kubectl rollout undo deployment/portfinder-deployment --to-revision=2
```
 
Próba zakończyła się błędem. Rewizja 2 nie istniała już w historii (została nadpisana przez wcześniejsze operacje `undo`). Jednocześnie widoczne jest, że rollout status nadal oczekiwał na zakończenie (wdrożenie wadliwego obrazu nadal trwało w tle):
 
![24](<img/Zrzut ekranu 2026-05-26 110024.png>)
 
Kolejne `rollout undo` po ponownym zastosowaniu wadliwego obrazu:
 
![25](<img/Zrzut ekranu 2026-05-26 113931.png>)
 
Potwierdzenie powrotu do v1 po undo `rollout status` i curl:
 
![26](<img/Zrzut ekranu 2026-05-26 110859.png>)
 
### Identyfikacja problemów w historii wdrożenia
 
Sekcja Events z `kubectl describe deployment portfinder-deployment` pokazuje pełną historię operacji `ScalingReplicaSet`. Widoczna sekwencja: skalowania w górę i w dół kolejnych ReplicaSetów, przy czym ReplicaSet z wadliwym obrazem (`5447bc6c9f`) nigdy nie osiągnął stanu Ready,zatrzymał się na 2 replikach, a stary ReplicaSet (`d9d857dc5`) utrzymał 3 działające pody:
 
![27](<img/Zrzut ekranu 2026-05-26 114340.png>)
 
## 5. Skrypt weryfikujący wdrożenie 
 
Pierwsza wersja skryptu używała bezpośrednio `kubectl`. Ponieważ alias `kubectl="minikube kubectl --"` zdefiniowany jest w `.bashrc` i nie jest eksportowany do środowiska skryptów bash, każde wywołanie kończyło się błędem `kubectl: command not found`:
 
![28](<img/Zrzut ekranu 2026-05-26 105441.png>)
 
Błąd widoczny przy próbie uruchomienia:
 
![29](<img/Zrzut ekranu 2026-05-26 113832.png>)
 
Skrypt poprawiono - zamiast aliasu używa pełnej komendy `minikube kubectl --`. Plik po edycji w nano oraz nadanie uprawnień wykonywalnych:
 
![30](<img/Zrzut ekranu 2026-05-26 105457.png>)
 
Treść poprawnego skryptu z wynikiem SUCCESS:
 
![31](<img/Zrzut ekranu 2026-05-26 114057.png>)
 
### Test na wadliwym obrazie (FAILED)
 
Po zastosowaniu wadliwego obrazu skrypt czekał 60 sekund, po czym wykrył timeout. W dodatkowych informacjach diagnostycznych widoczne pody z błędem `ErrImageNeverPull` oraz stan ReplicaSetów:
 
![32](<img/Zrzut ekranu 2026-05-26 113850.png>)
 
Pełny output skryptu FAILED z opisem deploymentu (Events, OldReplicaSets, NewReplicaSet):
 
![33](<img/Zrzut ekranu 2026-05-26 115313.png>)
 
---
 
## 6. Strategie wdrożeń
 
Stworzono plik `deployment-recreate.yml` ze strategią `type: Recreate`, 4 replikami i serwisem NodePort na porcie 30081:
 
![34](<img/Zrzut ekranu 2026-05-26 114318.png>)
 
```yaml
strategy:
  type: Recreate
```
 
Zastosowano wdrożenie i potwierdzono `successfully rolled out`:
 
![35](<img/Zrzut ekranu 2026-05-26 114340.png>)
 
Następnie zaktualizowano obraz do v2 i obserwowano zachowanie podów przez `get pods -w`:
 
```bash
sed -i 's/image: portfinder-web:v1/image: portfinder-web:v2/' deployment-recreate.yml
kubectl apply -f deployment-recreate.yml
kubectl get pods -w
```
 
Widoczna charakterystyczna cecha Recreate: wszystkie pody nowej wersji (`portfinder-recreate-6644fc6d58-*`) weszły w stan `ContainerCreating` jednocześnie, a po chwili wszystkie jednocześnie osiągnęły `Running`. Stare pody zostały usunięte w całości przed uruchomieniem nowych - przez chwilę żadna replika nie była dostępna:
 
![36](<img/Zrzut ekranu 2026-05-26 114449.png>)
 
Stworzono plik `deployment-rolling.yml` ze strategią `RollingUpdate` i parametrami `maxUnavailable: 2`, `maxSurge: 25%`:
 
![37](<img/Zrzut ekranu 2026-05-26 114628.png>)
 
Zastosowano wdrożenie. Rollout postępował etapami, wypisując kolejne dostępne repliki (`0 of 4`, `1 of 4`, `2 of 4`, `3 of 4`):
 
```bash
kubectl apply -f deployment-rolling.yml
kubectl rollout status deployment/portfinder-rolling
```
 
![38](<img/Zrzut ekranu 2026-05-26 114651.png>)
 
Następnie zaktualizowano obraz do v2. W widoku `get pods -w` wyraźnie widać stopniową wymianę: pody starej wersji (`85b997db85-*`) wchodzą w stany `Completed`/`Terminating`, podczas gdy nowe (`b58df78d6-*`) są równolegle tworzone w `ContainerCreating` i `Pending`. W każdej chwili część podów pozostaje dostępna - brak downtime:
 
![39](<img/Zrzut ekranu 2026-05-26 114554.png>)
 
Canary deployment umożliwia stopniowe wypuszczanie nowej wersji - mała liczba podów z nową wersją działa obok stabilnej, a wspólny serwis rozdziela ruch proporcjonalnie do liczby replik.
 
Stworzono trzy pliki:
 
**`deployment-canary-stable.yml`** - 3 repliki v1, etykiety `track: stable` i `app: portfinder-canary`:
 
![40](<img/Zrzut ekranu 2026-05-26 115313.png>)
 
**`deployment-canary-new.yml`** - 1 replika v2, etykiety `track: canary` i `app: portfinder-canary`:
 
![41](<img/Zrzut ekranu 2026-05-26 115336.png>)
 
**`service-canary.yml`** - serwis NodePort na porcie 30083, selektor po `app: portfinder-canary` (obejmuje oba deploymenty):
 
![42](<img/Zrzut ekranu 2026-05-26 115356.png>)
 
Zastosowano wszystkie trzy zasoby i zweryfikowano pody:
 
```bash
kubectl apply -f deployment-canary-stable.yml
kubectl apply -f deployment-canary-new.yml
kubectl apply -f service-canary.yml
kubectl get pods -l app=portfinder-canary
```
 
4 pody łącznie: 3 stable (v1) + 1 canary (v2), wszystkie `Running`:
 
![43](<img/Zrzut ekranu 2026-05-26 115426.png>)
 
Zweryfikowano rozdzielanie ruchu przez 8 kolejnych requestów:
 
```bash
for i in $(seq 1 8); do curl -s http://$(minikube ip):30083 | grep -o "v[0-9]*" | head -n 1; done
```
 
Wyniki: 7 requestów trafiło na v1, 1 na v2 - proporcja 3:1 (75%/25%) zgodna z liczbą podów. Potwierdzono działanie mechanizmu canary:
 
![44](<img/Zrzut ekranu 2026-05-26 115548.png>)
 
---
 
## 7. Widok końcowy, wszystkie deploymenty i serwisy
 
```bash
kubectl get deployments
kubectl get services
kubectl rollout history deployment/portfinder-deployment
```
 
Na liście deploymentów widoczne: `portfinder-canary` (1/1), `portfinder-deployment` (4/4), `portfinder-recreate` (4/4), `portfinder-rolling` (4/4), `portfinder-stable` (3/3). Historia rollout deploymentu głównego zawiera rewizje 1, 3, 11, 12:
 
![45](<img/Zrzut ekranu 2026-05-26 115610.png>)
 
## Podsumowanie
 
### Skalowanie
 
Kubernetes pozwala na błyskawiczną zmianę liczby replik przez modyfikację pola `replicas` i ponowne `kubectl apply`. Zmniejszenie do 0 replik skutecznie "wyłącza" aplikację bez usuwania definicji deploymentu. Skalowanie nie tworzy nowej rewizji w historii rollout - zmiana `replicas` nie jest uznawana za zmianę specyfikacji poda.
 
### Historia i rollback
 
`kubectl rollout history` przechowuje ograniczoną liczbę rewizji. `kubectl rollout undo` cofa do poprzedniej rewizji, natomiast `--to-revision=N` pozwala wrócić do konkretnej wersji, o ile nie została nadpisana przez kolejne operacje undo. Rewizje związane wyłącznie ze skalowaniem nie pojawiają się w historii.
 
### Skrypt weryfikujący
 
Skrypt `check-rollout.sh` z timeoutem 60 sekund poprawnie wykrywa zarówno udane wdrożenia (SUCCESS), jak i te, które nie zakończyły się w zadanym czasie (FAILED). Kluczowa obserwacja: aliasy zdefiniowane w `.bashrc` nie są dostępne w skryptach bash - należy używać pełnej komendy `minikube kubectl --` zamiast aliasu `kubectl`.
 
### Porównanie strategii wdrożeń
 
| Cecha | Recreate | Rolling Update | Canary |
| Downtime | Tak (chwilowy) | Nie | Nie |
| Obie wersje równocześnie | Nie | Tak (chwilowo) | Tak (długotrwale) |
| Kontrola nad ruchem | Brak | Ograniczona | Przez liczbę replik |
| Złożoność konfiguracji | Niska | Średnia | Wysoka (2 deploymenty) |
| Zastosowanie | Proste aplikacje, środowiska dev | Produkcja, zero-downtime | Testowanie nowej wersji na produkcji |
 
**Recreate** - wszystkie stare pody usuwane przed uruchomieniem nowych. Chwilowy downtime. Prosta konfiguracja.
 
**Rolling Update** - stopniowa wymiana podów. Parametry `maxUnavailable: 2` i `maxSurge: 25%` kontrolują tempo wymiany. Brak downtime, obie wersje krótko współistnieją.
 
**Canary** - nowa wersja obsługuje tylko część ruchu (1/4 = 25%). Wymaga dwóch deploymentów z etykietą `track` i wspólnego serwisu selektującego po `app`. Pozwala na bezpieczne testowanie nowej wersji na produkcji.
 
### Zapytania do LLM
 
Główne zapytania do LLM podczas realizacji zadania:
- „Jak działa Canary Deployment w Kubernetes bez dodatkowych narzędzi?"
- „Różnica między maxUnavailable a maxSurge w RollingUpdate"
Metoda weryfikacji: obserwacja stanów podów przez `kubectl get pods -w`, weryfikacja odpowiedzi HTTP przez `curl`, analiza historii przez `kubectl rollout history` i `kubectl describe deployment`.
 
*Pliki `deployment.yml`, `deployment-recreate.yml`, `deployment-rolling.yml`, `deployment-canary-stable.yml`, `deployment-canary-new.yml`, `service-canary.yml`, `check-rollout.sh`, `nginx-versions/Dockerfile.v1`, `nginx-versions/Dockerfile.v2` dostępne w katalogu `Sprawozdanie11`.*