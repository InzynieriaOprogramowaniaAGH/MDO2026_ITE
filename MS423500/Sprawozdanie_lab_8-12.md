# Mateusz Sadowski - Sprawozdanie zbiorcze z laboratoriów 8-12

## Ansible

Ansible - narzędzie do automatyzacji zarządzania infrastrukturą IT. Służy do wykonywania powtarzalnych zadań na wielu maszynach jednocześnie, bez konieczności ręcznej konfiguracji każdego serwera osobno. Działa w oparciu o połączenie SSH, więc nie wymaga instalowania dodatkowego agenta na maszynach docelowych. 

Ansible cechuje się podejściem deklaratywnym, oznacza to, że korzystając z tego narzędzia definiuje się, jaki stan ma mieć system po wykonaniu playbooka, a nie każdy pojedynczy krok ręcznie.

Playbooki piszą się w YAML, czyli uniwersalnym języku do zapisywania danych strukturalnych, w którym opisuje się kolejne kroki do wykonania. 

Docelowe hosty organizowane są w Inventory, które może przyjmować formę plików statycznych (.ini/.yaml) lub nowoczesnego Dynamic Inventory, automatycznie pobierającego listę maszyn z chmury. Umożliwia to logiczne grupowanie węzłów i automatyzację provisioningu na masową skalę. Dzięki temu skalowanie infrastruktury na wielu środowiskach staje się powtarzalne, a ryzyko błędów z ręcznej konfiguracji znacznie maleje.

**Moduły Ansible są w większości idempotentne, co oznacza, że ponowne uruchomienie playbooka na już skonfigurowanej maszynie nie wprowadzi niepotrzebnych zmian ani błędów**

Struktura playbooków:

- `name: nazwa zadania` - określa nazwę zadania i ułatwia odróżnienie kolejnych kroków w playbooku.

Zadanie składa się z:

- definicji hostów, których dotyczy, czyli `hosts: `,
- listy poleceń lub modułów, które mają zostać wykonane (np. `ansible.builtin.ping` - który wysyła ping do hosta),
- ewentualnych dodatkowych parametrów, takich jak zmienne czy uprawnienia (np. `become: yes`, czyli odpowiednik sudo). 

## Automatyzacja instalacji systemu operacyjnego

Automatyzacja instalacji systemu operacyjnego jest kluczowym elementem infrastruktury as a Code. Można ją osiągnąć poprzez instalację nienadzorowaną z wykorzystaniem pliku `anaconda-ks.cfg`.

### Instalacja nienadzorowana

Instalacja nienadzorowana to proces automatycznego zainstalowania systemu operacyjnego bez interwencji użytkownika. System przechodzi przez wszystkie kroki konfiguracyjne w oparciu o wcześniej przygotowaną konfigurację. 
Dzięki temu można szybko i powtarzalnie wdrożyć to samo środowisko na wiele maszyn, co minimalizuje błędy wynikające z ręcznej konfiguracji.

### Plik anaconda-ks.cfg

Plik `anaconda-ks.cfg` to plik konfiguracyjny dla instalatora Kickstart, który jest używany przez dystrybucje Linuxa oparte na Red Hat (takie jak Fedora czy CentOS). 

**Plik ten:**
- Automatyzuje proces instalacji, eliminując potrzebę ręcznego wyboru ustawień
- Umożliwia tę samą konfigurację systemową na wielu maszynach
- Pozwala na integrację instalacji z pipeline'ami CI/CD i wdrożeniami infrastruktury

**Główne elementy składni anaconda-ks.cfg:**
- **Dyrektywy sieci i hosta**: `network --bootproto=dhcp --hostname=nazwa` — konfiguruje interfejs sieciowy i nazwę hosta
- **Repozytoria pakietów**: `url` oraz `repo` — definiują źródła, skąd pobierane są pakiety i aktualizacje
- **Język i klawiatura**: `lang pl_PL.UTF-8`, `keyboard --vckeymap=pl` — ustawienia lokalizacji
- **Partycjonowanie dysku**: `clearpart --all --initlabel` oraz `autopart` — formatowanie i automatyczne partycjonowanie
- **Instalowane pakiety**: sekcja `%packages` ... `%end` — lista pakietów do zainstalowania
- **Skrypty poinstalacyjne**: sekcja `%post` ... `%end` — polecenia do wykonania po instalacji systemu (np. pobieranie artefaktów, włączanie usług, konfiguracja Dockera)
- **Hasło roota**: `rootpw` — szyfrowane hasło dla konta administratora
- **Strefa czasowa**: `timezone Europe/Warsaw --utc` — ustawienie zegara systemowego

## Kubernetes

Kubernetes to platforma służąca do orkiestracji kontenerów. Automatyzuje ich wdrażanie, skalowanie i przede wszystkim utrzymanie ruchu bez przerw. Narzędzia takie jak Ansible przygotowują infrastrukturę sprzętową, natomiast K8s zarządza cyklem życia samych aplikacji uruchamianych na tych maszynach.

Minikube to lekka, lokalna implementacja Kubernetesa działająca na maszynie dewelopera. Pozwala testować i uruchamiać aplikacje zgodne z Kubernetesem w środowisku zbliżonym do produkcji, bez potrzeby wdrażania pełnego klastra na wielu serwerach. Minikube uruchamia się w maszynie wirtualnej lub kontenerze i stanowi idealny punkt wejścia do nauki Kubernetesa.

Polecenia zaczynające się od `minikube` to komendy sterujące tym lokalnym klastrem. `minikube start` uruchamia klaster, `minikube stop` go zatrzymuje, a `minikube kubectl --` to narzędzie do bezpośredniego uruchamiania poleceń kubectl (narzędzia sterującego Kubernetesem) na lokalnym klastrze. Dzięki temu nie trzeba instalować kubectl oddzielnie ani konfigurować połączenia do zdalnego klastra.

Klaster w kontekście Kubernetesa to zbiór węzłów, które współpracują ze sobą w celu uruchamiania skonteneryzowanych aplikacji. Uruchamia się go właśnie przy pomocy `minikube start`.

Kubernetes posiada własny interfejs graficzny przeznaczony do zarządzania klastrem i monitorowania jego pracy. Służy on wyłącznie do wizualizacji aktualnego, zadeklarowanego stanu infrastruktury i aplikacji.

W kontekście K8s często używa się następujących pojęć:

- **Pod** – najmniejsza jednostka w Kubernetesie, zawierająca jeden lub wiele kontenerów. Pod jest tymczasowy i może zostać usunięty oraz ponownie utworzony w dowolnym momencie. Zwykle jeden kontener == jeden pod.

- **Deployment** – obiekt deklarujący pożądany stan aplikacji, w tym ilość replik (kopii poda), obraz Dockera oraz strategię aktualizacji. Deployment automatycznie zarządza, aby liczba uruchomionych podów zawsze odpowiadała deklaracji.

- **Job** – obiekt przeznaczony do uruchamiania jednorazowych zadań, takich jak backup czy przetwarzanie danych. Job zapewnia, że zadanie zostanie wykonane z powodzeniem do konca, a następnie się zakończy (inaczej niż deployment, który uruchamia się bezterminowo).

- **Service** – abstrakcja definiująca logiczny zbiór podów i politykę dostępu do nich. Service przypisuje stały adres IP i port, dzięki czemu inne aplikacje mogą się z nimi komunikować bez martwienia się, które konkretnie pody są uruchomione.

**Aby uruchomić aplikację oraz monitorować ją przy użyciu Kubernetes, potrzeba, by aplikacja była zamknięta w kontenerze!**

Kontener można uruchomić przy pomocy polecenia `minikube kubectl -- run`. Warto podkreślić, że polecenie to tworzy tzw. "nagiego poda", który przepada w przypadku awarii lub wyłączenia.

Sprawdzenie, czy kontener działa w klastrze (jako pod), można wykonać przy pomocy `minikube kubectl -- get pods`.

Pliki służące do deploymentu w K8s to manifesty formatu YAML. Manifest to plik, w którym deklaruje się pożądany stan infrastruktury, opisuje się, jakie pody mają być uruchomione, ile ich musi być (repliki), jaki obraz Dockera mają używać oraz jakie porty udostępniać. Kubernetes czyta taki manifest i automatycznie zapewnia, że rzeczywisty stan systemu odpowiada deklaracji.


Wdrożenie manifestu odbywa się przy pomocy `minikube kubectl -- apply -f nazwa-pliku`. Polecenie to przekazuje manifest do klastra i mówi Kubernetesowi, że ma utworzyć albo zaktualizować obiekt opisany w pliku YAML.

Sprawdzenie statusu można wykonać poprzez konsolę `minikube kubectl -- rollout status deployment/nazwa-deploymentu`.

Manifest zawiera:

`apiVersion` - wersja API Kubernetes, dla której przygotowano manifest. Określa, jakiej wersji składni i pól używa dany zasób.

`kind` - typ zasobu, który manifest ma utworzyć, na przykład `Pod`, `Deployment` lub `Service`.

`metadata` - dane identyfikujące obiekt. Zawiera między innymi `name` (unikalną nazwę w danej przestrzeni nazw) oraz często `labels` (etykiety pomocne przy grupowaniu i selekcjonowaniu obiektów).

`spec` - tutaj definiuje się pożądany stan obiektu, czyli właściwą konfigurację zasobu. W zależności od typu może zawierać na przykład `replicas`, `template` oraz `selector`.

Deployment można wystawić jako Service, tworząc odpowiedni obiekt Service: `minikube kubectl -- expose deployment nazwa-deploymentu`.

Budowanie obrazu używanego przez Kubernetesa wykonuje się przy pomocy polecenia `minikube image build -t <nazwa-obrazu> -f <plik Dockerfile> .`.

Przy pomocy `minikube kubectl -- rollout history deployment/nazwa-deploymentu` można sprawdzić historię wdrożeń. Natomiast przy pomocy `minikube kubectl -- rollout undo deployment/nazwa-deploymentu` można dokonać rollbacku, czyli przywrócenia poprzedniej wersji.

**Praktycznym rozwiązaniem jest stosowanie skryptów, które kończą deployment lub przywracają poprzednią wersję, gdy coś idzie nie tak, na przykład gdy deployment wdraża się zbyt długo.**

Możliwe są różne strategie wdrożenia, wpływają one na przebieg zarządzania aplikacją przez minikube:
- `Recreate`: usuwa wszystkie stare Pody, a następnie tworzy nowe (pełny restart).
- `Rolling Update`: jest to domyślna strategia Kubernetesa, ale przy użyciu parametrów `maxUnavailable` i `maxSurge` można kontrolować, ile starych Podów może być niedostępnych jednocześnie oraz ile nowych może być utworzonych ponad aktualny stan.


**Canary deployment** - wzorzec polegający na uruchamianiu równolegle deploymentu stabilnego i kanarkowego. Stabilny przyjmuje większość ruchu i na nim uruchamiana jest wersja aplikacji, której poprawne działanie jest potwierdzone, a na kanarkowym uruchamiana jest nowo wprowadzana lub testowana wersja aplikacji. Oba deploymenty mogą być eksponowane przez ten sam Service, który wybiera Pody po etykiecie `app=nginx`.

## Azure

**Microsoft Azure** - platforma chmurowa firmy Microsoft, wykorzystywana do tworzenia, uruchamiania i skalowania aplikacji oraz do zarządzania zasobami IT bez potrzeby utrzymywania własnej infrastruktury fizycznej. 

W praktyce Azure umożliwia między innymi:

- tworzenie maszyn wirtualnych,
- zarządzanie siecią, dyskami i bazami danych,
- wdrażanie aplikacji webowych i kontenerowych,
- automatyczne skalowanie zasobów,
- monitorowanie i zabezpieczanie środowisk.

Jest to jedno z najpopularniejszych rozwiązań chmurowych stosowanych w biznesie, ponieważ pozwala szybko uruchamiać środowiska testowe i produkcyjne oraz płacić tylko za rzeczywiście wykorzystane zasoby.

**Microsoft Cloud Shell** - jest to przeglądarkowe, interaktywne środowisko powłoki udostępnione przez Microsoft w ramach usługi Azure, które pozwala na uruchamianie Azure CLI, PowerShell i narzędzi DevOps bez potrzeby instalowania lokalnych zależności.

**Azure CLI** - narzędzie wiersza poleceń do zarządzania usługami Azure. Pozwala tworzyć i konfigurować zasoby chmurowe, takie jak maszyny wirtualne, grupy zasobów, sieci, konta magazynu czy aplikacje, bez korzystania z interfejsu graficznego. Jest bardzo przydatne przy automatyzacji, ponieważ te same operacje można zapisać w skryptach i wykonywać wielokrotnie w taki sam sposób.

### Udostępnianie usług aplikacji

Aby zalogować się do Azure CLI, po jego pobraniu należy wpisać polecenie `az login`, a następnie przejść przez proces logowania. 

Celem wdrożenia kontenera do Azure jest wystawienie aplikacji na dostępność dla użytkowników z całego świata, bez posiadania własnej serwerowni. Platforma ma dostępnych bardzo wiele opcji, od których wyboru zależy to, ile się płaci za jej użytkowanie. Ponadto Azure gwarantuje niemal nieograniczoną skalowalność.

**Container Group** - jest to logiczna grupa jednego lub kilku kontenerów uruchamianych razem w Azure Container Instances. Kontenery w jednej grupie dzielą tę samą sieć, adres IP, przestrzeń nazw i mogą współdzielić woluminy, dzięki czemu łatwiej uruchamiać aplikację wraz z dodatkowymi usługami pomocniczymi, np. proxy lub zadaniami wspierającymi.

W tym przypadku Container Group umożliwia uruchomienie aplikacji jako jednego, spójnego środowiska w chmurze Azure. To właśnie ona odpowiada za izolację uruchomienia, przydział zasobów CPU i pamięci oraz za to, że kontener jest dostępny pod przypisanym adresem i portem. Dzięki temu nie trzeba zarządzać osobnym serwerem ani całym klastrem, a wdrożenie pozostaje proste i szybkie.

W Azure CLI kontener do deploya tworzy się, zaczynając od przesłania do Azure obrazu z aplikacją. Można to zrobić między innymi przez Docker Hub. Gdy ten krok zostanie wykonany, przy pomocy `az container create` z odpowiednimi flagami można stworzyć kontener.
Przykład utworzenia kontenera:

        az container create \
        --resource-group rg-studia-devops-ms1408 \
        --name my-nest-api \
        --image sanioljr/nest-api:latest \
        --dns-name-label devops-nest-sanioljr \
        --ports 3003 \
        --os-type linux \
        --memory 1.5 \
        --cpu 1 \
        --location polandcentral

Po utworzeniu kontenera przy pomocy `az container show --resource-group <nazwa-grupy> --name <nazwa-kontenera>` można wyświetlić jego status oraz wyświetlić logi, używając `az container logs --resource-group <nazwa-grupy> --name <nazwa-kontenera>`. Oba te polecenia są bardzo przydatne przy monitorowaniu aplikacji, która jest dostępna pod adresem URL podanym przez `az container create`.

### Sprzątanie zasobów

Po zakończeniu pracy aplikacji warto zwolnić zasoby, aby uniknąć dalszego naliczania rachunków przez Microsoft. Polega to na usunięciu kontenera oraz całej grupy zasobów.

Usunięcie kontenera:

        az container delete \
        --resource-group rg-studia-devops-ms1408 \
        --name my-nest-api \
        --yes

Usunięcie resource group:

        az group delete \
        --name rg-studia-devops-ms1408 \
        --yes --no-wait