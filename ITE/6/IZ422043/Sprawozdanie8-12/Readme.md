# Sprawozdanie podsumowujące – Automatyzacja wdrożeń i zarządzanie aplikacjami w środowiskach Linux oraz Kubernetes

# 1. Cel realizowanych ćwiczeń

Celem zrealizowanych ćwiczeń było poznanie nowoczesnych metod automatyzacji administracji systemami, wdrażania aplikacji oraz zarządzania środowiskami kontenerowymi. W ramach zajęć wykorzystano narzędzia Ansible, Kickstart, Docker, Podman oraz Kubernetes. Ćwiczenia obejmowały zarówno automatyzację konfiguracji systemów operacyjnych, jak i wdrażanie, skalowanie oraz udostępnianie aplikacji działających w kontenerach.

# 2. Zakres wykonanych prac
## 2.1. Automatyzacja administracji przy użyciu Ansible

Przygotowano środowisko składające się z kilku maszyn wirtualnych, pomiędzy którymi skonfigurowano komunikację SSH opartą o klucze publiczne. Utworzono plik inventory definiujący zarządzane hosty, a następnie wykonano szereg operacji administracyjnych za pomocą playbooków Ansible.

W ramach ćwiczenia:

- zweryfikowano komunikację pomiędzy hostami,
- kopiowano pliki na zdalne maszyny,
- aktualizowano pakiety systemowe,
- restartowano usługi,
- analizowano zachowanie systemu w przypadku niedostępności hosta,
- wdrażano aplikację w kontenerze Docker,
- utworzono własną rolę Ansible umożliwiającą automatyzację procesu wdrożeniowego.

Szczególną uwagę zwrócono na mechanizm idempotencji, dzięki któremu wielokrotne uruchomienie tych samych zadań nie powodowało zbędnych zmian w systemie.

## 2.2. Automatyczna instalacja systemu Fedora z wykorzystaniem Kickstart

Drugie ćwiczenie dotyczyło przygotowania całkowicie nienadzorowanej instalacji systemu Fedora.

Na podstawie wygenerowanego pliku Kickstart skonfigurowano:

- źródło pakietów instalacyjnych,
- ustawienia sieciowe,
- nazwę hosta,
- użytkownika administracyjnego,
- automatyczne partycjonowanie i formatowanie dysku,
- automatyczny restart po zakończeniu instalacji.

W sekcji %packages zdefiniowano wymagane pakiety, natomiast w sekcji %post przygotowano skrypty odpowiedzialne za pobranie oraz uruchomienie aplikacji webowej w kontenerze Podman.

Dodatkowo utworzono usługę systemd zapewniającą automatyczne uruchamianie aplikacji po każdym restarcie systemu.

Efektem ćwiczenia było uzyskanie w pełni automatycznego procesu instalacji i konfiguracji systemu operacyjnego bez konieczności interwencji użytkownika.

# 2.3. Wdrażanie aplikacji w Kubernetes

Kolejnym etapem było poznanie podstaw działania platformy Kubernetes na lokalnym klastrze Minikube.

W ramach ćwiczenia:

- uruchomiono klaster Kubernetes,
- skonfigurowano dostęp do dashboardu administracyjnego,
- utworzono i uruchomiono pojedynczy pod z serwerem Nginx,
- zbudowano własny obraz kontenera,
- wdrożono aplikację za pomocą Deploymentu,
- utworzono Service zapewniający dostęp do aplikacji,
- przeprowadzono skalowanie wdrożenia,
- wykonano aktualizację aplikacji do nowej wersji,
- przetestowano mechanizm rollback,
- przeanalizowano zachowanie klastra po wdrożeniu błędnej wersji aplikacji.

Ćwiczenie pozwoliło zapoznać się z podstawowymi mechanizmami orkiestracji kontenerów oraz sposobami zapewniania wysokiej dostępności aplikacji.

# 2.4. Eksponowanie aplikacji i skalowanie w Kubernetes

Kolejne ćwiczenie koncentrowało się na sposobach udostępniania aplikacji działających w Kubernetes oraz zarządzaniu liczbą replik.

Przygotowano Deployment zawierający dużą liczbę instancji aplikacji webowej, a następnie przetestowano różne metody dostępu:

- bezpośrednio do pojedynczego poda,
- poprzez Deployment,
- poprzez Service typu ClusterIP.

Dodatkowo wykonano skalowanie aplikacji:

- metodą imperatywną przy użyciu polecenia kubectl scale,
- metodą deklaratywną poprzez modyfikację plików YAML.

Zaobserwowano automatyczne dostosowywanie liczby uruchomionych podów do wartości zadeklarowanej w konfiguracji Deploymentu.

# 2.5. Wdrażanie kontenerów w chmurze Microsoft Azure

Ostatnie ćwiczenie dotyczyło wdrażania aplikacji kontenerowych w środowisku chmurowym Microsoft Azure z wykorzystaniem usługi Azure Container Instances (ACI).

W pierwszym etapie utworzono własną grupę zasobów (Resource Group), która służyła do logicznego grupowania wszystkich elementów wykorzystywanych podczas realizacji zadania. Następnie, korzystając z narzędzia Azure CLI dostępnego w usłudze Azure Cloud Shell, przygotowano środowisko umożliwiające uruchamianie kontenerów bez konieczności tworzenia i zarządzania maszynami wirtualnymi.

Do wdrożenia wykorzystano publicznie dostępny obraz serwera Nginx znajdujący się w repozytorium Docker Hub. Podczas tworzenia instancji kontenera określono podstawowe parametry, takie jak:

- nazwa kontenera,
- typ systemu operacyjnego (Linux),
- ilość przydzielonej pamięci RAM i zasobów procesora,
- publiczny adres IP,
- port HTTP wykorzystywany przez aplikację.

Następnie sprawdzono dostępność usługi HTTP udostępnianej przez serwer Nginx oraz przeanalizowano logi działania kontenera. Pozwoliło to potwierdzić poprawność wdrożenia oraz zapoznać się z podstawowymi mechanizmami monitorowania aplikacji uruchamianych w chmurze.

W ramach ćwiczenia wykonano również:

- pobieranie informacji o stanie kontenera,
- analizę logów aplikacji,
- uzyskanie adresu umożliwiającego dostęp do usługi HTTP,
- usunięcie wdrożonego kontenera,
- usunięcie grupy zasobów po zakończeniu pracy.

Szczególną uwagę zwrócono na konieczność usuwania nieużywanych zasobów chmurowych, co pozwala uniknąć niepotrzebnego zużycia przyznanych środków oraz naliczania dodatkowych kosztów.


# 3. Wnioski

Przeprowadzone ćwiczenia pokazały, że automatyzacja stanowi kluczowy element współczesnej administracji systemami i procesów DevOps. Narzędzia takie jak Ansible oraz Kickstart znacząco upraszczają konfigurację środowisk i eliminują konieczność wykonywania wielu powtarzalnych czynności ręcznie.

Technologie kontenerowe, takie jak Docker i Podman, umożliwiają łatwe pakowanie aplikacji wraz z ich zależnościami, natomiast Kubernetes zapewnia zaawansowane mechanizmy orkiestracji, skalowania oraz aktualizacji usług działających w środowiskach produkcyjnych.

Istotnym elementem zajęć było również zapoznanie się z usługami chmurowymi Microsoft Azure. Wdrożenie aplikacji przy użyciu Azure Container Instances pokazało, że uruchamianie kontenerów w chmurze może odbywać się bez konieczności zarządzania infrastrukturą serwerową. Dzięki wykorzystaniu Azure CLI możliwe było tworzenie, monitorowanie oraz usuwanie zasobów w sposób zautomatyzowany i zgodny z praktykami Infrastructure as Code.

Ćwiczenia pozwoliły zdobyć praktyczne doświadczenie w zakresie automatyzacji infrastruktury, konteneryzacji, orkiestracji aplikacji oraz wykorzystania usług chmurowych. Poznane technologie stanowią obecnie podstawę nowoczesnych środowisk DevOps i są szeroko wykorzystywane podczas projektowania, wdrażania oraz utrzymywania systemów informatycznych.