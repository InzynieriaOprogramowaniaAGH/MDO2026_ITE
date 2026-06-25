# Sprawozdanie zbiorcze z zajęć 8-12

### Laboratorium 8: Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

- **Opis technologii:** Ansible to bezagentowe narzędzie klasy _Infrastructure as Code_ (IaC), które umożliwia centralne zarządzanie konfiguracją, instalację oprogramowania oraz orkiestrację zadań na wielu maszynach docelowych jednocześnie za pośrednictwem protokołu SSH.
    
- **Implementacja środowiska:** Prace rozpoczęto od przygotowania infrastruktury składającej się z maszyny zarządzającej (`ansible-master`) oraz maszyny docelowej (`ansible-target`), działających pod kontrolą systemu Ubuntu Server.
    
- **Autoryzacja i łączność:** Bezpieczną i bezhasłową komunikację zrealizowano poprzez wygenerowanie pary kluczy kryptograficznych w standardzie `ed25519` na węźle głównym i przesłanie klucza publicznego do dedykowanego użytkownika `ansible` na maszynie docelowej za pomocą polecenia `ssh-copy-id`.
    
- **Inwentaryzacja:** Strukturę sieci zdefiniowano w pliku inwentaryzacji `inventory.ini`, dzieląc hosty na logiczne grupy `Orchestrators` (z połączeniem lokalnym) oraz `Endpoints` (zarządzane węzły końcowe).
    
- **Wykonanie procedur:** Łączność oraz stan maszyn zweryfikowano za pomocą poleceń _ad-hoc_ (moduł `ping`), a następnie za pomocą deklaratywnych skryptów _Playbook_ w formacie YAML (`ping.yml`). Architektura ta pozwala na pełne zarządzanie cyklem życia aplikacji, w tym na zdalną instalację silnika Docker za pomocą ról Ansible szkieletowanych przez `ansible-galaxy`.
    

### Laboratorium 9: Pliki odpowiedzi dla wdrożeń nienadzorowanych (Kickstart)

- **Opis technologii:** Instalacja nienadzorowana (unattended installation) to technika automatycznego wdrażania systemów operacyjnych na maszynach wirtualnych lub fizycznych. Wykorzystuje ona predefiniowany plik odpowiedzi (np. format Kickstart dla instalatora Anaconda w systemach z rodziny Red Hat/Fedora), który zawiera gotowe instrukcje konfiguracji i eliminuje potrzebę interakcji z użytkownikiem.
    
- **Konfiguracja struktury systemu:** Plik odpowiedzi (np. `anaconda-ks.cfg`) pozwala na automatyczne zdefiniowanie unikalnej nazwy hosta, konfigurację interfejsów sieciowych oraz wymuszenie pełnego formatowania i partycjonowania przestrzeni dyskowej za pomocą dyrektywy `clearpart --all`. Sieciowe źródła pakietów są definiowane za pomocą instrukcji `url` oraz `repo`.
    
- **Automatyzacja post-instalacyjna:** Kluczowym elementem technologii jest podział na sekcję `%packages` (gdzie deklaruje się instalację wymaganych zależności systemowych) oraz sekcję skryptową `%post`.
    
- **Wdrażanie artefaktów:** Wewnątrz sekcji `%post` implementuje się skrypty automatycznie pobierające zbudowane artefakty (aplikacje binarne lub kontenery) z zewnętrznych serwerów (np. przez `wget` z serwera Jenkins lub SFTP). W przypadku wdrożeń kontenerowych, sekcja ta służy do włączenia demona zarządzającego (`systemctl enable docker`), co gwarantuje automatyczne pobranie i uruchomienie kontenera aplikacji przy pierwszym rozruchu systemu operacyjnego.
    

### Laboratorium 10: Wdrażanie na zarządzalne kontenery: Kubernetes (1)

- **Opis technologii:** Kubernetes (K8s) to platforma do automatyzacji wdrażania, skalowania i zarządzania aplikaczeniami skonteneryzowanymi. Do celów deweloperskich i testowych wykorzystuje się narzędzie Minikube, które uruchamia lokalny, jedno-węzłowy klaster K8s wewnątrz dedykowanego środowiska (np. sterownika Docker).
    
- **Inicjalizacja i narzędzia:** Środowisko skonfigurowano poprzez pobranie plików wykonywalnych `minikube` oraz `kubectl`. Weryfikację stanu zasobów oraz Worker Node realizowano z poziomu CLI oraz graficznego panelu Kubernetes Dashboard uruchomionego w tle jako proces proxy.
    
- **Wdrożenie manualne:** W pierwszym etapie uruchomiono pojedynczy obiekt typu Pod o nazwie `lab10app` na bazie obrazu `nginx:alpine` za pomocą bezpośredniego polecenia `kubectl run`.
    
- **Wdrożenie deklaratywne i ekspozycja:** Następnie zaimplementowano podejście deklaratywne za pomocą manifestu YAML (`deploy.yml`), tworząc obiekt `Deployment` o nazwie `lab10dep` wyskalowany do 4 replik. Aby umożliwić ruch sieciowy do kontenerów, wdrożenie wyeksponowano na zewnątrz klastra jako obiekt typu `Service` (ClusterIP) na porcie 80, a dostęp do witryny w przeglądarce uzyskano poprzez mechanizm przekierowania portów `kubectl port-forward`.
    

### Laboratorium 11: Wdrażanie na zarządzalne kontenery: Kubernetes (2)

- **Opis technologii:** Zaawansowana orkiestracja w Kubernetes obejmuje dynamiczne zarządzanie replikami, wersjonowanie uruchomionych komponentów, monitorowanie stanu wdrożenia oraz stosowanie zaawansowanych strategii aktualizacji aplikacji bez przestojów.
    
- **Wersjonowanie obrazów:** Na bazie kontenera `nginx:alpine` zbudowano lokalnie trzy wersje obrazu: `lab11-app:v1` (z napisem Wersja 1), `lab11-app:v2` (z napisem Wersja 2) oraz celowo uszkodzony obraz `lab11-app:broken`, który symulował awarię krytyczną (exit 1). Obrazy załadowano do rejestru klastra komendą `minikube image load`.
    
- **Skalowanie i inspekcja:** Przeprowadzono testy elastyczności infrastruktury poprzez modyfikację liczby replik w zakresie od 0 do 8 instancji. Wdrożenie wadliwego obrazu pozwoliło zaobserwować pętlę błędów `CrashLoopBackOff` i automatyczne wstrzymanie aktualizacji przez mechanizmy ochronne K8s. Stan stabilny przywracano komendami `kubectl rollout history` oraz `kubectl rollout undo`.
    
- **Automatyzacja wdrożeń (Skrypt check_deploy.sh):** Napisano skrypt powłoki Bash monitorujący status wdrożenia nowej wersji z parametrem `--timeout 60s`, co pozwoliło na automatyczną weryfikację poprawności rolloutu w określonym oknie czasowym.
    
- **Strategie aktualizacji:** Przetestowano i porównano trzy podejścia architektoniczne:
    
    - _Recreate:_ Całkowite wygaszenie starszych Podów przed powołaniem nowych, eliminujące konflikty wersji kosztem chwilowego braku dostępności usługi (_downtime_).
        
    - _Rolling Update:_ Płynna wymiana Podów w małych partiach (sterowana parametrami `maxUnavailable: 1` i `maxSurge: 20%`), zapewniająca nieprzerwane działanie aplikacji (_zero-downtime_).
        
    - _Canary Deployment:_ Równoległe utrzymywanie dwóch Deploymentów (`app-stable` oraz `app-canary`) podpiętych pod wspólny `Service` przy użyciu etykiet, co pozwoliło skierować testowo 25% ruchu sieciowego do nowej wersji aplikacji (1 pod kanarkowy vs 3 pody stabilne).
        

### Laboratorium 12: Wdrażanie na zarządzalne kontenery w chmurze (Azure)

- **Opis technologii:** Przejście ze środowisk lokalnych do chmury publicznej w modelu PaaS (Platform as a Service) realizowane jest za pomocą usług bezserwerowych (Serverless), takich jak Azure Container Instances (ACI). Technologia ta umożliwia uruchamianie pojedynczych kontenerów bezpośrednio w chmurze, eliminując potrzebę zarządzania systemem operacyjnym maszyn wirtualnych.
    
- **Przygotowanie mikroserwisu:** Zaimplementowano prostą aplikację serwerową w technologii Node.js nasłuchującą na porcie 3000 i spakowano ją przy użyciu pliku `Dockerfile` (obraz bazowy `node:18-alpine`). Gotowy kontener opublikowano w publicznym rejestrze Docker Hub.
    
- **Zarządzanie infrastrukturą chmurową:** Interakcję z chmurą prowadzono w narzędziu Azure Cloud Shell przy użyciu interfejsu wiersza poleceń Azure CLI (`az login`). Ze względu na restrykcyjne polityki subskrypcji studenckich (`Allowed locations`), zidentyfikowano dozwolone regiony geograficzne i powołano Grupę Zasobów (`lab12-rg`) w lokalizacji `francecentral`.
    
- **Uruchomienie kontenera (ACI):** Za pomocą polecenia `az container create` utworzono instancję kontenerową, definiując system Linux, mapowanie portu 3000 oraz ścisłe limity sprzętowe wynoszące 1 vCPU i 1 GB pamięci RAM.
    
- **Weryfikacja i czyszczenie:** Poprawność operacji zweryfikowano poleceniem `az container logs` oraz poprzez bezpośrednie wywołanie przypisanego adresu FQDN (`mydlitor-lab12.francecentral.azurecontainer.io:3000`) w przeglądarce. Po zakończeniu testów cała grupa zasobów została trwale usunięta komendą `az group delete`, co stanowi kluczową praktykę optymalizacji kosztów (FinOps) w chmurach obliczeniowych.