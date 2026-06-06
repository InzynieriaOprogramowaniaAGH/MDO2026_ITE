# Sprawozdanie z laboratoriów 08-12: Automatyzacja wdrożeń, instalacje nienadzorowane, Kubernetes oraz Azure


## Wprowadzenie

Celem zajęć było poznanie nowoczesnych metod automatyzacji zarządzania infrastrukturą oraz wdrażania aplikacji. W trakcie laboratoriów wykorzystano narzędzia Ansible, Fedora Kickstart, Kubernetes (Minikube) oraz platformę chmurową Microsoft Azure. Przeprowadzone ćwiczenia obejmowały automatyzację administracji systemami, przygotowanie instalacji nienadzorowanej, wdrażanie aplikacji kontenerowych oraz zarządzanie ich cyklem życia.

## Zajęcia 08 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

### Cel zajęć

Celem ćwiczenia było poznanie systemu Ansible służącego do automatyzacji zadań administracyjnych i zarządzania wieloma hostami z jednego miejsca.

### Przygotowanie środowiska

Przygotowano dwie maszyny wirtualne:

- maszynę zarządzającą (Ansible Controller),
- maszynę docelową ansible-target.

Na obu maszynach wykorzystano ten sam system operacyjny. Na maszynie docelowej skonfigurowano:

- usługę OpenSSH,
- narzędzie tar,
- użytkownika ansible,
- odpowiedni hostname.

Następnie wykonano wymianę kluczy SSH za pomocą ssh-copy-id, co umożliwiło logowanie bez podawania hasła.

### Inwentaryzacja hostów

Utworzono plik inventory zawierający grupy:

\[Orchestrators\]  
controller  
<br/>\[Endpoints\]  
ansible-target

Skonfigurowano rozpoznawanie nazw hostów poprzez:

- /etc/hosts,
- konfigurację DNS/systemd-resolved.

Zweryfikowano poprawność komunikacji pomiędzy hostami.

### Wykorzystanie Playbooków

Przygotowano playbook realizujący:

- test połączenia (ping),
- kopiowanie plików na hosty docelowe,
- aktualizację pakietów,
- restart usług sshd i rngd,
- obsługę błędów podczas niedostępności hosta.

Przykładowe moduły wykorzystane w ćwiczeniu:

- ping,
- copy,
- package,
- service,
- reboot.

### Automatyzacja wdrożenia aplikacji

Przy użyciu Ansible:

- Instalowano Docker na maszynie docelowej.
- Pobierano obraz aplikacji z Docker Hub.
- Uruchamiano kontener.
- Weryfikowano działanie usługi.
- Usuwano wdrożone zasoby.

Całość została opakowana w rolę Ansible wygenerowaną poleceniem:

ansible-galaxy role init deploy_app

Uzupełniono strukturę katalogów oraz plik meta/main.yml.

### Wnioski

Ansible umożliwia powtarzalne i bezpieczne wykonywanie operacji administracyjnych. Dzięki wykorzystaniu playbooków możliwe jest szybkie wdrażanie aplikacji oraz zarządzanie konfiguracją wielu serwerów jednocześnie.

## Zajęcia 09 - Instalacje nienadzorowane (Kickstart)

### Cel zajęć

Celem ćwiczenia było przygotowanie automatycznej instalacji systemu Fedora bez konieczności interakcji użytkownika.

### Konfiguracja pliku Kickstart

Jako punkt wyjścia wykorzystano plik:

/root/anaconda-ks.cfg

Następnie zmodyfikowano go poprzez:

- dodanie repozytoriów instalacyjnych,
- ustawienie własnej nazwy hosta,
- automatyczne czyszczenie dysku:

clearpart --all

- konfigurację użytkowników,
- automatyczny restart po zakończeniu instalacji.

### Instalacja oprogramowania

W sekcji `%packages` określono pakiety wymagane do uruchomienia aplikacji:

- docker  
- git  
- wget  
- curl

### Automatyzacja po instalacji

W sekcji `%post` przygotowano skrypt:

- pobierający artefakt aplikacji,
- konfigurujący środowisko,
- aktywujący wymagane usługi,
- uruchamiający aplikację po pierwszym starcie systemu.

Przykładowe działania:

```systemctl enable docker```

oraz pobieranie aplikacji przy użyciu:

`wget`

### Test instalacji

Uruchomiono nową maszynę wirtualną wykorzystując:

- obraz Fedora Server,
- przygotowany plik Kickstart.

Po zakończeniu procesu zweryfikowano:

- poprawną instalację systemu,
- konfigurację hosta,
- działanie aplikacji.

### Wnioski

Instalacje nienadzorowane znacząco skracają czas przygotowania środowisk testowych i produkcyjnych. Mechanizm Kickstart umożliwia pełną automatyzację instalacji systemu oraz wdrażania oprogramowania.

## Zajęcia 10 - Kubernetes (część 1)

### Cel zajęć

Celem zajęć było poznanie podstaw działania platformy Kubernetes oraz wdrażanie aplikacji kontenerowych.

### Instalacja środowiska

Zainstalowano:

- Minikube
- kubectl

Uruchomiono lokalny klaster:

```minikube start```

Zweryfikowano jego działanie:

```kubectl get nodes```

Uruchomiono również Kubernetes Dashboard.

### Podstawowe pojęcia Kubernetes

Poznano najważniejsze elementy architektury:

- Pod
- Deployment
- Service
- ReplicaSet
- Namespace

### Uruchomienie aplikacji

Przygotowano obraz Docker zawierający aplikację.

Następnie uruchomiono wdrożenie:
```
kubectl run app \\  
\--image=myimage \\  
\--port=80
```
Zweryfikowano działanie poda:

```kubectl get pods```

### Udostępnienie aplikacji

Skonfigurowano przekierowanie portów:

```kubectl port-forward pod/app 8080:80```

Następnie sprawdzono dostępność usługi z poziomu przeglądarki.

### Deployment YAML

Przygotowano plik wdrożenia.

Wdrożenie zostało uruchomione poleceniem:

```kubectl apply -f deployment.yaml```

### Replikacja

Zwiększono liczbę replik do czterech:

`replicas: 4`

Monitorowano przebieg wdrożenia:

```kubectl rollout status deployment/app```

### Wnioski

Kubernetes umożliwia automatyczne zarządzanie aplikacjami kontenerowymi oraz ich skalowanie. Deploymenty pozwalają definiować stan infrastruktury w postaci kodu.

## Zajęcia 11 - Kubernetes (część 2)

### Cel zajęć

Celem zajęć było poznanie zaawansowanych mechanizmów wdrażania i aktualizacji aplikacji.

### Przygotowanie wielu wersji obrazu

Przygotowano:

- wersję stabilną aplikacji
- nowszą wersję aplikacji
- wersję celowo uszkodzoną

Obrazy zostały opublikowane w Docker Hub.

### Skalowanie wdrożeń

Przeprowadzono operacje:

`replicas: 8`

następnie:

`replicas: 1`

oraz:

`replicas: 0`

Po czym ponownie uruchomiono wdrożenie z wieloma replikami.

### Aktualizacja obrazu

Zmieniano wersję obrazu w pliku YAML i obserwowano proces aktualizacji:

```kubectl apply -f deployment.yaml```

### Historia wdrożeń

Analizowano historię:

```kubectl rollout history deployment/app```

W przypadku błędnego wdrożenia wykonywano cofnięcie:

```kubectl rollout undo deployment/app```

### Automatyczna weryfikacja wdrożenia

Przygotowano skrypt sprawdzający, czy wdrożenie zakończyło się sukcesem w ciągu 60 sekund.

Przykładowe wykorzystanie:

```kubectl rollout status deployment/app --timeout=60s```

### Strategie wdrożeń

Przetestowano:

- Recreate: całkowite zatrzymanie starej wersji przed uruchomieniem nowej.

- Rolling Update: stopniowa wymiana instancji aplikacji.

Przykładowe parametry:

```
maxUnavailable: 2  
maxSurge: 25%
```
- Canary Deployment: jednoczesne działanie starej i nowej wersji aplikacji dla części użytkowników.

### Wnioski

Kubernetes dostarcza zaawansowanych mechanizmów aktualizacji aplikacji, umożliwiając bezpieczne wdrożenia i szybkie przywracanie poprzednich wersji.

## Zajęcia 12 - Microsoft Azure

### Cel zajęć

Celem zajęć było poznanie podstaw wdrażania kontenerów na platformie chmurowej Microsoft Azure.

### Utworzenie zasobów

Utworzono własną grupę zasobów:

```az group create```

W grupie zasobów uruchomiono usługę Azure Container Instance.

### Wdrożenie kontenera

Wykorzystano obraz znajdujący się w Docker Hub.

Uruchomienie wykonano przy użyciu polecenia:

```az container create```

Po wdrożeniu sprawdzono:

- stan instancji
- publiczny adres IP
- poprawność działania aplikacji

### Analiza logów

Pobrano logi kontenera:

```az container logs```

Zweryfikowano poprawne uruchomienie aplikacji oraz obsługę ruchu HTTP.

### Usuwanie zasobów

Po zakończeniu testów usunięto:

- kontener
- grupę zasobów

Przykład:

```az group delete```

Pozwoliło to uniknąć niepotrzebnego naliczania kosztów.

### Wnioski

Platforma Azure umożliwia szybkie wdrażanie aplikacji kontenerowych bez konieczności samodzielnego zarządzania serwerami. Wykorzystanie usług chmurowych znacząco upraszcza proces publikacji aplikacji.

## Podsumowanie

W trakcie laboratoriów poznano pełny proces automatyzacji wdrażania aplikacji:

- Automatyzację administracji serwerami za pomocą Ansible.
- Tworzenie instalacji nienadzorowanych przy użyciu Kickstart.
- Wdrażanie aplikacji kontenerowych w Kubernetes.
- Zarządzanie wersjami i aktualizacjami wdrożeń.
- Publikowanie aplikacji w środowisku chmurowym Microsoft Azure.

Przeprowadzone ćwiczenia pozwoliły zdobyć praktyczne doświadczenie w zakresie DevOps, automatyzacji infrastruktury oraz nowoczesnych metod wdrażania aplikacji opartych o kontenery.