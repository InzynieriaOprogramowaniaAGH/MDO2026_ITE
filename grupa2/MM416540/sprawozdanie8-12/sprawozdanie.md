# Sprawozdanie zbiorcze – Zajęcia 8–12
### DevOps i orkiestracja kontenerów

**Autor:** Mateusz Malaga  
**Data:** 13.06.2026

---

## Spis treści

1. [Zajęcia 08 – Ansible](#zajęcia-08--ansible)
2. [Zajęcia 09 – Pliki odpowiedzi (Kickstart)](#zajęcia-09--pliki-odpowiedzi-kickstart)
3. [Zajęcia 10 – Kubernetes (minikube)](#zajęcia-10--kubernetes-minikube)
4. [Zajęcia 11 – Kubernetes: Strategie wdrożeń](#zajęcia-11--kubernetes-strategie-wdrożeń)
5. [Zajęcia 12 – Wdrażanie w chmurze (Azure)](#zajęcia-12--wdrażanie-w-chmurze-azure)

---

# Zajęcia 08 – Ansible

**Temat:** Automatyzacja konfiguracji i wdrożeń za pomocą Ansible.

Skonfigurowano dwie maszyny wirtualne: główną (ansible-controller) oraz docelową (ansible-target). Wymieniono klucze SSH, zainstalowano Ansible i zweryfikowano połączenie pingiem do wszystkich hostów.

---

## CZĘŚĆ 1: Instalacja i konfiguracja środowiska

### Instalacja Ansible

![alt text](s8_image-3.png)

![alt text](s8_image-4.png)

### Weryfikacja instalacji

![alt text](s8_image-5.png)

### Wymiana kluczy SSH

![alt text](s8_image-8.png)

---

## CZĘŚĆ 2: Inwentaryzacja

### Plik inwentaryzacji (inventory)

![alt text](s8_image-12.png)

### Ping do wszystkich hostów

![alt text](s8_image-11.png)

---

## CZĘŚĆ 3: Playbook – zdalne wywoływanie procedur

### Treść playbooka

![alt text](s8_image-13.png)

### Pierwsze uruchomienie – status `changed`

![alt text](s8_image-14.png)

### Ponowne uruchomienie – status `ok` (idempotentność)

![alt text](s8_image-15.png)

![alt text](s8_image-16.png)

---

## CZĘŚĆ 4: Wdrożenie kontenera Express przez Ansible

### Playbook instalujący Dockera na ansible-target

![alt text](s8_image-17.png)

### Playbook wdrażający kontener Express

![alt text](s8_image-19.png)

---

## CZĘŚĆ 5: Rola Ansible (ansible-galaxy)

### Szkielet roli (`ansible-galaxy init`)

![alt text](s8_image-20.png)

### Definicja zadań – tasks/main.yml

![alt text](s8_image-23.png)

### Playbook używający roli i wynik uruchomienia

![alt text](s8_image-25.png)

![alt text](s8_image-26.png)

---

# Zajęcia 09 – Pliki odpowiedzi (Kickstart)

**Temat:** Automatyczna instalacja systemu Fedora Server przy użyciu pliku Kickstart (anaconda-ks.cfg).

Celem było przygotowanie pliku odpowiedzi umożliwiającego instalację nienadzorowaną, po której system automatycznie hostuje aplikację Express.js w kontenerze Docker.

---

## 1. Instalacja wstępna i pobranie pliku odpowiedzi

### Instalacja Fedory w VirtualBox

![alt text](s9_image.png)

### Wygenerowany plik anaconda-ks.cfg

![alt text](s9_image-1.png)

### Skopiowanie pliku na główną maszynę

![alt text](s9_image-2.png)

### Kluczowe modyfikacje pliku Kickstart

| Zmiana | Powód |
|--------|-------|
| Dodano `url --mirrorlist=...` | Brak repozytoriów w wygenerowanym pliku |
| Dodano `clearpart --all` | Zawsze formatuj cały dysk |
| Zmieniono hostname na `express-host` | Wymaganie zadania |
| Dodano `reboot --eject` | Automatyczny restart po instalacji |
| Rozszerzono `%packages` | Docker i zależności |
| Dodano sekcję `%post` | Instalacja Dockera, konfiguracja autostartu |

---

## 2. Dlaczego `docker run` nie działa w `%post`?

Sekcja `%post` wykonuje się podczas instalacji, zanim system zostanie w pełni uruchomiony – demon `dockerd` jeszcze nie działa. Rozwiązaniem jest `systemctl enable`, który uruchamia kontener dopiero przy pierwszym restarcie:

```
Instalacja → %post (enable) → reboot → Docker start → express-app.service → docker run
```

---

## 3. Uruchomienie instalacji nienadzorowanej

### Serwer HTTP udostępniający plik odpowiedzi

![alt text](s9_image-3.png)

### Modyfikacja GRUB – dodanie parametru `inst.ks`

```
inst.ks=http://10.119.160.27:8888/anaconda-ks.cfg
```

![alt text](s9_image-6.png)

---

## 4. Weryfikacja po instalacji

![alt text](s9_image-7.png)

![alt text](s9_image-8.png)

---

## 5. Dyskusja – kiedy instalacja nienadzorowana ma sens?

| | |
|---|---|
| **Zalety** | Powtarzalność, automatyzacja, skalowalność (setki maszyn równocześnie), plik kickstart jako dokumentacja konfiguracji |
| **Wady** | Złożoność konfiguracji, trudne debugowanie, ograniczenia sekcji `%post` |
| **Zastosowania** | Provisioning chmurowy (AWS, Azure), CI/CD, systemy IoT, obrazy bazowe VM |

---

# Zajęcia 10 – Kubernetes (minikube)

**Temat:** Wprowadzenie do Kubernetes – uruchamianie aplikacji w lokalnym klastrze minikube.

---

## CZĘŚĆ 1: Instalacja i uruchomienie klastra

### Instalacja minikube

![alt text](s10_image.png)

### Uruchomienie klastra (po dodaniu rdzenia CPU w VirtualBox)

![alt text](s10_image-5.png)

### Status klastra

![alt text](s10_image-7.png)

---

## CZĘŚĆ 2: Dashboard i załadowanie obrazu

### Kubernetes Dashboard

![alt text](s10_image-8.png)

### Załadowanie obrazu Express do minikube

![alt text](s10_image-9.png)

---

## CZĘŚĆ 3: Uruchomienie poda i dostęp do aplikacji

### Uruchomienie poda

![alt text](s10_image-12.png)

### Status poda

![alt text](s10_image-15.png)

### Port-forward i działająca aplikacja

![alt text](s10_image-16.png)

![alt text](s10_image-17.png)

---

## CZĘŚĆ 4: Deployment YAML i serwis

### Plik deployment.yml

![alt text](s10_image-20.png)

### Deployment Express z 4 replikami

![alt text](s10_image-21.png)

### Eksport jako serwis

![alt text](s10_image-23.png)

---

## CZĘŚĆ 5: Koncepcje Kubernetes

| Obiekt | Opis |
|--------|------|
| **Pod** | Najmniejsza jednostka; jeden lub więcej kontenerów współdzielących sieć i storage |
| **Deployment** | Zarządza zestawem replik; obsługuje rolling updates i rollback |
| **Service** | Stały punkt dostępu do podów; load balancer (ClusterIP / NodePort / LoadBalancer) |
| **ReplicaSet** | Zarządza liczbą replik; tworzony automatycznie przez Deployment |

### Typowe pułapki

| Objaw | Przyczyna | Rozwiązanie |
|-------|-----------|-------------|
| `ImagePullBackOff` | k8s próbuje pobrać obraz z Docker Hub | `imagePullPolicy: Never` |
| `pull access denied` | Pomyłka nazwy obrazu | Sprawdź nazwę: `express-app:latest` |
| DNS klastra nie działa | Sieć minikube odcięta od internetu | Buduj obraz na hoście, użyj `minikube image load` |

---

# Zajęcia 11 – Kubernetes: Strategie wdrożeń

**Temat:** Skalowanie, rollback i strategie aktualizacji wdrożeń w Kubernetes.

Przygotowano trzy wersje obrazu: `5.2.1` (stabilna), `5.2.2` (nowa) i `5.2.3-broken` (celowo wadliwa, do testowania rollbacku).

---

## CZĘŚĆ 1: Przygotowanie obrazów

### Lista dostępnych obrazów

![alt text](s11_image-2.png)

### Bazowy plik deployment.yml (4 repliki)

![alt text](s11_image-4.png)

---

## CZĘŚĆ 2: Skalowanie

### Zwiększenie replik do 8

![alt text](s11_image-5.png)

![alt text](s11_image-6.png)

### Zmniejszenie replik do 0 i powrót do 4

![alt text](s11_image-8.png)

---

## CZĘŚĆ 3: Aktualizacja obrazu i rollback

### Zastosowanie nowej wersji 5.2.2

![alt text](s11_image-11.png)

### Powrót do wersji 5.2.1

![alt text](s11_image-12.png)

### Wadliwy obraz 5.2.3-broken – deployment zawiesza się

Po zastosowaniu wadliwej wersji nowe pody nie startowały, a stare nadal działały.

![alt text](s11_image-13.png)

![alt text](s11_image-14.png)

### Historia wdrożeń i cofnięcie

![alt text](s11_image-15.png)

![alt text](s11_image-19.png)

![alt text](s11_image-20.png)

---

## CZĘŚĆ 4: Skrypt weryfikujący wdrożenie

![alt text](s11_image-21.png)

---

## CZĘŚĆ 5: Strategie wdrożeń

### Recreate – wszystkie pody zatrzymują się jednocześnie

![alt text](s11_image-22.png)

### Rolling Update – stopniowa aktualizacja

![alt text](s11_image-23.png)

![alt text](s11_image-24.png)

### Canary Deployment – 25% ruchu na nową wersję

![alt text](s11_image-25.png)

![alt text](s11_image-26.png)

---

## CZĘŚĆ 6: Porównanie strategii

| Strategia | Downtime | Ryzyko | Rollback | Kiedy używać |
|-----------|---------|--------|----------|--------------|
| **Recreate** | TAK (~10 s) | Wysokie | Szybki | Środowiska testowe |
| **RollingUpdate** | NIE | Średnie | Automatyczny | Produkcja, stopniowa aktualizacja |
| **Canary** | NIE | Niskie | Usuń canary deployment | Testowanie nowej wersji na części ruchu |

---

# Zajęcia 12 – Wdrażanie w chmurze (Azure)

**Temat:** Uruchamianie kontenerów w Azure Container Instances (ACI).

---

## 1. Przygotowanie i publikacja obrazu

### Weryfikacja obrazu lokalnie

![alt text](s12_image.png)

### Publikacja na Docker Hub

![alt text](s12_image-2.png)

![alt text](s12_image-3.png)

---

## 2. Platforma Azure – cennik ACI

Kluczowe informacje: opłata per sekunda za vCPU i RAM, bezpłatny tier 180 000 vCPU-s/miesiąc.

![alt text](s12_image-5.png)

---

## 3. Wdrożenie kontenera

### Utworzenie Resource Group i wdrożenie kontenera

![alt text](s12_image-6.png)

![alt text](s12_image-8.png)

![alt text](s12_image-9.png)

### Status kontenera

![alt text](s12_image-11.png)

### Logi kontenera

![alt text](s12_image-10.png)

### Weryfikacja HTTP – aplikacja dostępna publicznie

![alt text](s12_image-12.png)

`http://mm416540-express.polandcentral.azurecontainer.io:3000/`

![alt text](s12_image-13.png)

---

## 4. Zatrzymanie i usunięcie zasobów

![alt text](s12_image-14.png)

![alt text](s12_image-16.png)

---

## 5. Dyskusja

**Dlaczego nie potrzeba Azure Container Registry?**  
Obraz jest publiczny na Docker Hub – ACI pobiera go bezpośrednio. ACR byłoby potrzebne dla obrazów prywatnych lub wymagających integracji z Azure AD / niskiej latencji pobierania.

**Porównanie z minikube:**

| Aspekt | minikube | Azure ACI |
|--------|----------|-----------|
| Dostępność | Tylko lokalnie | Publiczny internet |
| Koszty | Brak | Per sekunda (180k vCPU-s/mies. gratis) |
| Konfiguracja | Złożona | Jedno polecenie `az container create` |
| Skalowanie | Ręczne | Automatyczne |
| Zastosowanie | Deweloperskie | Produkcyjne / testowe |

---

# Podsumowanie

Zajęcia 8–12 tworzyły spójną ścieżkę od automatyzacji konfiguracji serwerów, przez instalacje nienadzorowane, aż po orkiestrację kontenerów lokalnie i w chmurze.

## Zdobyte umiejętności

| Zajęcia | Technologia | Kluczowe pojęcia |
|---------|------------|------------------|
| 08 | Ansible | Playbook, inwentaryzacja, idempotentność, rola ansible-galaxy |
| 09 | Kickstart / Anaconda | Instalacja nienadzorowana, sekcja `%post`, GRUB |
| 10 | Kubernetes / minikube | Pod, Deployment, Service, ReplicaSet, kubectl |
| 11 | Kubernetes (zaawansowany) | Skalowanie, rollback, Recreate / RollingUpdate / Canary |
| 12 | Azure ACI | Wdrożenie w chmurze, Docker Hub, Resource Group |

## Wspólny wątek – aplikacja Express.js

Przez wszystkie zajęcia przewijał się ten sam artefakt – kontener `express-prod:5.2.1`. Pozwoliło to prześledzić pełny cykl życia aplikacji:

1. **Ansible (zaj. 08)** – automatyczne wdrożenie kontenera na zdalnej maszynie przez playbook
2. **Kickstart (zaj. 09)** – automatyczna instalacja systemu, który po restarcie uruchamia kontener
3. **Kubernetes lokalnie (zaj. 10–11)** – orkiestracja wielu replik, strategie aktualizacji bez przestojów
4. **Azure ACI (zaj. 12)** – publikacja obrazu i uruchomienie aplikacji dostępnej publicznie w internecie

## Wnioski

- **Ansible** sprawdza się przy zarządzaniu konfiguracją wielu maszyn – idempotentność gwarantuje powtarzalność operacji.
- **Kickstart** eliminuje ręczną instalację systemów, co jest kluczowe przy provisioningu na dużą skalę.
- **Kubernetes** zapewnia wysoką dostępność i elastyczne skalowanie – strategia RollingUpdate i mechanizm rollback chronią przed skutkami wadliwych wdrożeń.
- **Azure ACI** to najprostszy sposób na udostępnienie kontenera publicznie – bez konieczności zarządzania infrastrukturą, z rozliczeniem per sekunda.
