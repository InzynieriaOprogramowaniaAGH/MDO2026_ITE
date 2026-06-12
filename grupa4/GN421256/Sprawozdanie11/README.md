# Sprawozdanie 11 - Gabriel Nowak

## Kubernetes (2) - wersje obrazu, skalowanie, rollback, strategie wdrożeń

Ćwiczenie jest kontynuacją zajęć 10 i bazuje na własnym obrazie `gn-nginx` (prosty `nginx` z własnym `index.html`).

---

## 1. Przygotowanie nowych wersji obrazu

Stan wyjściowy klastra `minikube` i przygotowanie środowiska.

![](1'.png)

Nowy `Dockerfile` dla wersji **2.0** (zmieniona treść strony).

![](2-nowydockerfile.png)

`Dockerfile` wersji **wadliwej** - kontener celowo kończy pracę błędem (`exit 1`).

![](3-dockerfile-fail.png)

Załadowanie obrazów do `minikube` - dostępne trzy wersje: `1.0`, `2.0`, `broken`.

![](4-load-do-cube.png)

---

## 2. Zmiany w deploymencie - skalowanie replik

Skalowanie do **8 replik** (edycja YAML + `apply`).

![](5-osiemreplik.png)

Zmniejszenie do **1 repliki**.

![](6-repliki-jedna.png)

Zmniejszenie do **0 replik** (deployment `0/0`, brak podów).

![](7-repliki-zero.png)

Ponowne przeskalowanie w górę do **4 replik**.

![](8.png)

---

## 3. Zmiana wersji obrazu + historia wdrożeń

Zastosowanie nowej / starszej wersji obrazu (`2.0` ↔ `1.0`).

![](9.png)

Zastosowanie obrazu **wadliwego** - pody w stanie `CrashLoopBackOff` / `Error`.

![](10-brokendeploy.png)

`kubectl describe deployment` - szczegóły problemu wdrożenia.

![](11-describedeploy.png)

`kubectl rollout undo` - cofnięcie do działającej wersji.

![](12-undo.png)

---

## 4. Skrypt weryfikujący wdrożenie (60 s)

Skrypt `verify-rollout.sh` sprawdzający, czy wdrożenie zdążyło się wykonać w 60 sekund.

![](13-verify.png)

Wynik dla poprawnego wdrożenia - **OK**.

![](14-verified-ok.png)

Wynik dla wadliwego wdrożenia - **BŁĄD** (timeout).

![](15-verified-fail.png)

---

## 5. Strategie wdrożeń

### Recreate

Deployment ze strategią `Recreate`.

![](16-deployment-recreate.png)

Wdrożenie strategii.

![](17-recreate-rollout.png)

Aktualizacja do v2.0 - wszystkie stare pody znikają naraz, potem powstają nowe.

![](18-recreatev2.png)

### Rolling Update

Deployment ze strategią `RollingUpdate` (`maxUnavailable: 2`, `maxSurge: 50%`).

![](19-rolling.png)

Aktualizacja - stopniowa wymiana podów (stare i nowe działają równolegle).

![](20-rolling.png)

### Canary

Deployment **stable** (3 repliki, v1.0).

![](21-canary-stable.png)

Deployment **canary** (1 replika, v2.0).

![](22-canary-new.png)

Wspólny serwis obejmujący oba deploymenty (selektor `app=gn-nginx-canary`).

![](23-service-canary.png)

Pody i endpointy serwisu - 3× stable + 1× canary.

![](24.png)

Test ruchu z wnętrza klastra (curl do ClusterIP) - widoczny podział ruchu między wersję v1.0 i v2.0.

![](25-curltest.png)

---

## Wnioski

- **Recreate** - krótka przerwa w dostępności (najpierw kasowane są wszystkie stare pody).
- **Rolling Update** - brak przerwy, pody wymieniane stopniowo.
- **Canary** - nowa wersja na małej części replik; serwis dzieli ruch między stable i canary.
- `kubectl port-forward svc/...` przypina się do jednego poda i nie rozkłada ruchu - podział widać dopiero przy odpytywaniu ClusterIP serwisu z wnętrza klastra (kube-proxy).
- Wersja "wadliwa" obrazu skutkuje `CrashLoopBackOff`; przywrócenie działającej wersji wykonano przez `kubectl rollout undo`.
