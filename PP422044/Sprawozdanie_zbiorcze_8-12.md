# Sprawozdanie zbiorcze – Zajęcia 8-12

---

## Zajęcia 8 – Ansible: inwentaryzacja i automatyzacja konfiguracji

### Co zostało zrobione

Ćwiczenie dotyczyło wprowadzenia do Ansible – narzędzia do automatyzacji konfiguracji wielu maszyn jednocześnie bez potrzeby logowania się na każdą z nich ręcznie. Punktem wyjścia było przygotowanie pliku `/etc/hosts` oraz pliku inwentarza (`inventory.ini`), który definiuje listę maszyn zarządzanych przez Ansible. Łączność z maszynami docelowymi zweryfikowano `ping`, co potwierdziło że Ansible może się komunikować z hostami.

Następnie przygotowano dwa playbooki. Pierwszy – playbook systemowy – wykonywał podstawowe zadania utrzymaniowe: pingowanie maszyn, kopiowanie pliku inwentarza na endpoint, aktualizację pakietów i restart usługi SSH. Drugi – playbook deploy – odpowiadał za wdrożenie artefaktu Dockera: instalację Dockera, przesłanie zbudowanego obrazu, jego załadowanie, uruchomienie kontenera, weryfikację działania i końcowe oczyszczenie środowiska. Na zakończenie ćwiczenia przekształcono logikę z playbooka deploy w rolę Ansible Galaxy `deploy_counter_role`, co jest krokiem w stronę wielokrotnego użycia tej samej logiki w różnych projektach.

### Wnioski

Ansible pozwala opisać cały proces konfiguracji i wdrożenia jako deklaratywny plik YAML, który można odtworzyć w identyczny sposób na każdej maszynie. W porównaniu do ręcznego wykonywania tych samych kroków przez SSH, playbook eliminuje błędy ludzkie i pozwala wdrożyć tę samą konfigurację na dziesiątkach maszyn jednym poleceniem.

---

## Zajęcia 9 – Instalacja nienadzorowana systemu z plikiem Kickstart

### Co zostało zrobione

Tematem ćwiczenia była instalacja systemu Fedora bez żadnej interakcji użytkownika, z wykorzystaniem pliku odpowiedzi Kickstart `ks.cfg`. Plik ten zawierał wszystkie decyzje instalacyjne z góry: ustawienia językowe i strefę czasową, konfigurację sieci z niestandardowym hostname `licznik-prod`, hasło roota, oraz pełne czyszczenie dysku `clearpart --all` i automatyczne partycjonowanie LVM.

Kluczowym elementem była sekcja `%post`, wykonywana już w zainstalowanym systemie, ale przed jego pierwszym uruchomieniem. Ponieważ Docker nie działa podczas samej instalacji, rozwiązaniem było włączenie autostartu Dockera `systemctl enable docker` oraz utworzenie własnej usługi systemd, która – uruchomiona po restarcie systemu – wczytuje wcześniej pobrany obraz aplikacji i uruchamia z niego kontener. Artefakt aplikacji był hostowany lokalnie przez prosty serwer HTTP `python3 -m http.server`, z którego instalator pobierał plik przy pomocy `wget`. Plik Kickstart wskazano instalatorowi przez parametr `inst.ks=` dodany do linii bootowania.

### Wnioski

Instalacja nienadzorowana pokazała, że automatyzację można zacząć jeszcze przed uruchomieniem systemu operacyjnego, nie tylko konfigurować już działającą maszynę jak w Ansible, ale całkowicie zautomatyzować jej postawienie od zera. 

---

## Zajęcia 10 – Kubernetes (1): wdrożenie na lokalnym klastrze

### Co zostało zrobione

Ćwiczenie wprowadzało do Kubernetesa jako platformy do zarządzania kontenerami na większą skalę niż pojedynczy `docker run`. Zainstalowano Minikube i `kubectl`, uruchomiono jednowęzłowy klaster `minikube start --driver=docker` oraz dashboard webowy do wizualnego podglądu stanu klastra.

Ponieważ Minikube posiada własne, odizolowane środowisko Docker, obraz aplikacji zbudowany wcześniej przez pipeline Jenkinsa (działający w kontenerze dind) trzeba było wyeksportować i ręcznie załadować do Minikube `minikube image load`. Następnie uruchomiono poleceniem `kubectl run`, z flagą `--image-pull-policy=Never` wymuszającą użycie lokalnego obrazu. Połączenie z aplikacją uzyskano przez `kubectl port-forward`, co potwierdzono `curl` i otwarciem aplikacji w przeglądarce.

W drugiej części ćwiczenia ręczne polecenie `kubectl run` zostało zastąpione deklaratywnym opisem w plikach YAML: `deployment.yml` (z 4 replikami) oraz `service.yml` udostępniającym deployment jako stabilny punkt dostępowy. Wdrożenie przeprowadzono przez `kubectl apply`, a jego postęp monitorowano przy pomocy `kubectl rollout status`.

### Wnioski

Przejście od pojedynczego poda do deploymentu pokazało różnicę między Kubernetesem, a Dockerem: zamiast zarządzać pojedynczymi kontenerami, opisuje się pożądany stan systemu, a Kubernetes sam dba o jego utrzymanie.

---

## Zajęcia 11 – Kubernetes (2): zarządzanie wdrożeniami i strategie

### Co zostało zrobione

Drugie ćwiczenie z Kubernetesa skupiało się na dynamicznym zarządzaniu już działającym wdrożeniem. Przygotowano trzy wersje obrazu aplikacji: stabilną (`1.0.4`), nowszą (`1.0.5`) zbudowaną przez Jenkinsa oraz celowo wadliwą (`broken`), która natychmiast kończy działanie błędem.

Przeprowadzono serię zmian skali wdrożenia – z 4 replik do 8, następnie do 1, do 0 (całkowite zatrzymanie aplikacji bez usuwania deploymentu) i z powrotem do 4. Obserwując każdorazowo jak Kubernetes reaguje na te zmiany przez `kubectl get pods`. Następnie zaktualizowano deployment do wadliwego obrazu, co spowodowało, że nowe pody wpadały w `CrashLoopBackOff`, podczas gdy stare, działające pody pozostały aktywne aż do przekroczenia limitu czasu rollout. Sytuację naprawiono poleceniem `kubectl rollout undo`, które przywróciło poprzednią, stabilną wersję. Historię wszystkich zmian śledzono przez `kubectl rollout history`. Dodatkowo napisano skrypt PowerShell weryfikujący automatycznie, czy wdrożenie zakończyło się w ciągu 60 sekund.

W ostatniej części przygotowano trzy odrębne pliki deploymentów demonstrujące różne strategie aktualizacji: Recreate (usunięcie wszystkich starych podów przed utworzeniem nowych), Rolling Update z niestandardowymi parametrami `maxUnavailable` i `maxSurge` (stopniowa wymiana podów bez przestoju), oraz Canary Deployment, dwa równoległe deploymenty współdzielące jeden serwis przez wspólną labelkę, gdzie nowa wersja obsługuje tylko część ruchu.

### Wnioski

To ćwiczenie pokazało odporność Kubernetesa na błędy operacyjne: wdrożenie wadliwego obrazu nie spowodowało przestoju całej aplikacji, ponieważ Kubernetes domyślnie nie usuwa działających podów dopóki nowe nie staną się gotowe. Mechanizm `rollout undo` w połączeniu z historią rewizji daje praktyczną siatkę bezpieczeństwa przy każdej aktualizacji produkcyjnej. Porównanie trzech strategii wdrożenia pokazało wyraźny kompromis między prostotą (Recreate – przestój, ale gwarancja braku dwóch wersji naraz), dostępnością (Rolling Update – standard w większości zastosowań) i kontrolą ryzyka (Canary – najbezpieczniejsze testowanie nowej wersji na ograniczonym ruchu, ale wymagające najwięcej konfiguracji).

---

## Zajęcia 12 – Wdrożenie kontenera w chmurze Azure

### Co zostało zrobione

Ostatnie ćwiczenie przeniosło wdrożenie z lokalnego klastra Kubernetes do w pełni zarządzanej usługi chmurowej – Azure Container Instances. Wymagało to wcześniejszego opublikowania obrazu aplikacji na Docker Hub, co rozwiązało problem izolacji środowisk Docker, z którym borykano się w Minikube. W chmurze obraz pobierany jest bezpośrednio z publicznego rejestru, bez ręcznego eksportowania plików `.tar`.

Po zalogowaniu się przez konto AGH i uruchomieniu Azure Cloud Shell napotkano dwie istotne przeszkody administracyjne: politykę `sys.regionrestriction` ograniczającą wdrożenia do pięciu konkretnych regionów oraz brak rejestracji providera `Microsoft.ContainerInstance` w subskrypcji. Po rozwiązaniu obu problemów (wybór regionu `polandcentral` oraz `az provider register`) utworzono resource group i wdrożono kontener jednym poleceniem `az container create`, wskazując bezpośrednio obraz z Docker Hub. Działanie kontenera potwierdzono poprzez `az container show` (status `Running`), odczyt logów (`az container logs`) oraz test HTTP przez `curl` i przeglądarkę, korzystając z automatycznie przypisanej domeny publicznej. Na zakończenie kontener zatrzymano, usunięto, a cała resource group została skasowana, co zweryfikowano pustą listą z `az group list`.

### Wnioski

Jednym z wniosków z tego ćwiczenia jest to, że konta w chmurze mogą mieć nałożone restrykcyjne polityki (regiony, niezarejestrowane providery), które nie są widoczne na pierwszy rzut oka i wymagają samodzielnego zdiagnozowania przez narzędzia takie jak `az policy assignment list` czy zapytania REST API. W porównaniu do Kubernetesa lokalnego, ACI okazał się znacznie prostszy w obsłudze dla pojedynczego kontenera, nie trzeba zarządzać klastrem, deploymentem czy serwisem, wystarczy jedno polecenie `az container create`. Tę prostotę okupia się jednak mniejszą kontrolą: brak mechanizmów takich jak rollout, skalowanie deklaratywne czy strategie wdrożenia, które są domeną Kubernetesa. Równie istotne było przypomnienie sobie o kosztach, każdy zasób w Azure generuje opłaty tak długo jak istnieje, dlatego usunięcie resource group na końcu ćwiczenia było bardzo ważne.

---

## Podsumowanie ogólne

Pięć ćwiczeń, mimo że dotyczyły różnych narzędzi, układa się w jedną logiczną oś rozwoju w DevOps. Ansible pokazał automatyzację konfiguracji istniejących maszyn. Kickstart przesunął tę automatyzację jeszcze wcześniej, na etap samej instalacji systemu operacyjnego. Kubernetes wprowadził zarządzanie aplikacjami konteneryzowanymi na poziomie deklaratywnym, z mechanizmami skalowania, aktualizacji i odzyskiwania po błędach, których nie posiada ani Ansible, ani sam Docker. Azure na końcu pokazał, że te same kontenery można wdrożyć w chmurze publicznej bez konieczności utrzymywania własnej infrastruktury, choć kosztem części kontroli operacyjnej dostępnej w Kubernetesie.

Powtarzającym się motywem przez wszystkie ćwiczenia był problem przenoszenia artefaktów między środowiskami, obraz zbudowany w Jenkinsie trzeba było ręcznie eksportować do Minikube, podczas gdy w przypadku Azure rozwiązaniem okazało się skorzystanie z publicznego rejestru Docker Hub jako wspólnego punktu wymiany obrazów. To uświadamia praktyczne znaczenie rejestrów kontenerów w realnych pipeline'ach CI/CD, obraz budowany jest raz, a następnie pobierany z jednego źródła przez każde środowisko docelowe, niezależnie od tego czy jest to lokalny klaster Kubernetes, serwer produkcyjny, czy usługa chmurowa.
