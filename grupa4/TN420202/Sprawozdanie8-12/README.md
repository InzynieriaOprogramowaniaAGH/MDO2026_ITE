# Sprawozdanie zbiorcze - Zajęcia 8-12

## Zajęcia 8 – Automatyzacja z wykorzystaniem Ansible

W pierwszym etapie przygotowano środowisko składające się z maszyny zarządzającej oraz maszyny docelowej. Skonfigurowano komunikację SSH z wykorzystaniem kluczy publicznych, utworzono plik inventory oraz zweryfikowano poprawność komunikacji za pomocą modułu ping.

Następnie przygotowano playbooki realizujące podstawowe zadania administracyjne:

- kopiowanie plików na host docelowy
- aktualizację pakietów systemowych
- restart usług systemowych
- obsługę sytuacji awaryjnych związanych z niedostępnością hosta

W dalszej części wykorzystano Ansible do instalacji Dockera oraz uruchomienia kontenera nginx na zdalnym serwerze. Zweryfikowano poprawność działania usługi HTTP, a następnie przeprowadzono automatyczne usunięcie wdrożonego kontenera.

Najważniejszym rezultatem zajęć było poznanie infrastruktury jako kodu oraz możliwości zdalnego zarządzania systemami przy użyciu playbooków Ansible.

---

## Zajęcia 9 - Instalacja nienadzorowana Fedora Kickstart

Podczas laboratorium przygotowano środowisko do automatycznej instalacji systemu Fedora Server.

Po wykonaniu standardowej instalacji pobrano wygenerowany plik:

```bash
anaconda-ks.cfg
```

Plik został zmodyfikowany poprzez:

- ustawienie własnej nazwy hosta
- automatyczne czyszczenie dysku
- konfigurację użytkownika
- instalację dodatkowych pakietów
- aktywację usługi SSH
- dodanie sekcji **%post** wykonywanej po zakończeniu instalacji

Przygotowany plik Kickstart został udostępniony za pomocą prostego serwera HTTP.

Następnie uruchomiono nową maszynę wirtualną Fedora Server i wskazano przygotowany plik odpowiedzi za pomocą parametru:

```bash
inst.ks=http:///anaconda-ks.cfg
```

Po poprawkach konfiguracji instalacja przebiegła całkowicie automatycznie, bez udziału użytkownika.

Laboratorium pokazało sposób automatycznego przygotowania systemów operacyjnych wykorzystywanych później jako środowiska uruchomieniowe dla aplikacji.

---

## Zajęcia 10 - Kubernetes (część 1)

W ramach kolejnego etapu wdrożono lokalny klaster **Kubernetes** przy użyciu **Minikube**.

Wykonano:

- instalację **kubectl**
- instalację **Minikube**
- uruchomienie klastra **Kubernetes**
- weryfikację działania node w stanie **Ready**

Następnie uruchomiono **Dashboard Kubernetes** umożliwiający wizualne zarządzanie zasobami klastra.

Do testów wykorzystano kontener *nginx* uruchomiony jako pojedynczy **Pod**. Zweryfikowano działanie poda przy pomocy:

```bash
kubectl get pods
```

oraz

```bash
kubectl describe pod
```

W kolejnym kroku wykorzystano *port forwarding* w celu udostępnienia aplikacji HTTP lokalnie.

Następnie przygotowano pierwszy plik YAML opisujący **Deployment** oraz **Service**. Wdrożenie zostało wykonane poleceniem:

```bash
kubectl apply -f
```

**Deployment** uruchamiał cztery repliki *nginx*, natomiast **Service** umożliwiał dostęp do aplikacji poprzez jeden punkt wejścia.

Laboratorium wprowadziło podstawowe pojęcia **Kubernetes**:

- Pod
- Deployment
- ReplicaSet
- Service
- Rollout

---

## Zajęcia 11 - Kubernetes (część 2)

Druga część laboratoriów **Kubernetes** koncentrowała się na zarządzaniu wdrożeniami.

Przeprowadzono:

- skalowanie deploymentu do 8 replik
- zmniejszenie liczby replik do 1
- zmniejszenie liczby replik do 0
- ponowne zwiększenie liczby replik do 4

Następnie wykonano aktualizację obrazu *nginx* do nowej wersji oraz przeprowadzono rollback do wersji wcześniejszej.

W celu demonstracji błędów wdrożeniowych użyto nieistniejącego obrazu:

```bash
nginx
```

co spowodowało wystąpienie błędów:

- ErrImagePull
- ImagePullBackOff

Do analizy wdrożeń wykorzystano:

```bash
kubectl rollout history
```

oraz

```bash
kubectl rollout undo
```

Przygotowano również skrypt automatycznie sprawdzający poprawność wdrożenia z limitem czasu 60 sekund.

W ostatniej części laboratorium porównano strategie wdrożeń:

- Recreate
- RollingUpdate
- Canary Deployment

Pozwoliło to zaobserwować różnice pomiędzy całkowitym zatrzymaniem usługi a stopniową wymianą instancji aplikacji.

---

## Zajęcia 12 - Wzdrożenie kontenera w Azure

Ostatnie laboratorium dotyczyło wdrożenia aplikacji kontenerowej do chmury **Microsoft Azure**.

Przygotowano własny obraz Docker zawierający serwer *nginx* oraz statyczną stronę HTML.

Obraz został opublikowany w **Docker Hub**.

Następnie:

1. Utworzono Resource Group
2. Skonfigurowano Azure Cloud Shell
3. Zweryfikowano ograniczenia subskrypcji Azure for Students
4. Utworzono Container Instance korzystający z obrazu Docker Hub

Do wdrożenia wykorzystano:

```bash
az container create
```

Po uruchumieniu zweryfikowano:

- status kontenera
- publiczny adres DNS
- dostępność usługi HTTP
- logi aplikacji

Po zakończeniu ćwiczenia usunięto **Resource Group** w celu uniknięcia dalszego wykorzystania zasobów i naliczania kosztów.

## Podsumowanie

W trakcie laboratoriów zrealizowano pełny proces automatyzacji środowiska uruchomieniowego:

1. Automatyzacja administracji serwerami przy użyciu Ansible
2. Automatyczna instalacja systemów operacyjnych z wykorzystaniem Kickstart
3. Wdrażanie aplikacji kontenerowych w Kubernetes
4. Zarządzanie wersjami i strategiami wdrożeń
5. Wdrożenie aplikacji do środowiska chmurowego Microsoft Azure

