# Sprawozdanie podsumowujące laboratoria 5-7

Autor: Jan Pawelec

---

## Spis treści
1. [Ansible](#1-ansible)
2. [Instalacja nienadzorowana](#2-instalacja-nienadzorowana)
3. [Kubernetes](#3-kubernetes)
4. [Azure](#4-azure)
5. [Wnioski](#5-wnioski)

---

# 1. Ansible
Ansible pozwala na pełną automatyzację konfiguracji serwerów. Wykorzystanie narzędzia Ansible pozwala na orkiestrację i sprawne zarządzanie rozproszoną infrastrukturą, bez konieczności utrzymywania dodatkowych procesów klienckich.

## Architektura bezagentowa i komunikacja SSH
Model działania Ansible opiera się na architekturze bezagentowej, co eliminuje narzut związany z instalowaniem i aktualizowaniem dedykowanego oprogramowania na maszynach zarządzanych. Do kontrolowania węzła docelowego (`ansible-target`), opartego na zminimalizowanym systemie operacyjnym, wykorzystuje się SSH. W celu bezobsługowej automatyzacji zadań i wykluczenia interaktywnego podawania danych uwierzytelniających, stosuje się uwierzytelnianie oparte na parze kluczy kryptograficznych. Poprawność oraz stabilność niskopoziomowego kanału komunikacyjnego jest weryfikowana za pomocą wbudowanego modułu diagnostycznego ping.

```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@ansible-target
ansible -i hosts.ini all -m ping
```

## Inwentaryzacja i struktura hosts.ini
Podstawą sprawnego zarządzania środowiskiem jest zdefiniowanie i sparametryzowanie infrastruktury docelowej. Zadanie to realizuje się w pliku inwentaryzacyjnym hosts.ini, w którym przypisuje się czytelne nazwy sieciowe do konkretnych adresów IP maszyn. Taki podział pozwala na logiczne grupowanie hostów w zależności od ich funkcji w systemie (np. bazy danych, serwery aplikacyjne). Przekłada się to bezpośrednio na ułatwione skalowanie środowiska, gdyż rozbudowa infrastruktury o nowe węzły nie wymaga modyfikacji samych scenariuszy wdrożeniowych, a jedynie aktualizacji pliku inwentarza.

```bash
[targets]
ansible-target ansible_host=192.168.56.101 ansible_user=ubuntu
```

---

# 2. Instalacja nienadzorowana
W procesach wdrażania systemów operacyjnych na dużą skalę kluczowym wyzwaniem jest powtarzalność. Automatyzację tego procesu realizuje się poprzez instalację nienadzorowaną, opierając się na plikach odpowiedzi, które dostarczają parametry konfiguracyjne bezpośrednio do instalatora systemu operacyjnego, co oszczędza czasu Devopsowi.

## Mechanizm Kickstart na przykładzie Fedory
Podstawą automatyzacji instalacji dystrybucji z rodziny `Red Hat` (w tym Fedora) jest plik konfiguracyjny Kickstart (wygenerowany po ręcznej instalacji systemu jako /root/anaconda-ks.cfg). Plik ten poddaje się redakcji, definiując m.in. czyszczenie przestrzeni dyskowej oraz wskazując zewnętrzne repozytoria pakietów. Poniżej przykładowy dla instalacji `Fedory 43`.

```bash
lang pl_PL.UTF-8
keyboard --vckeymap=pl --xlayouts='pl'

timezone Europe/Warsaw --utc

rootpw --plaintext 123467

clearpart --all --initlabel
autopart --type=lvm

url --url="https://dl.fedoraproject.org/pub/fedora/linux/releases/43/Everything/x86_64/os/"

%packages
@core
curl
tar
%end
```

## Konfiguracja bootloadera
Inicjalizacja instalacji nienadzorowanej wymaga przekazania odpowiednich parametrów do jądra systemu. Konfigurację tę definiuje się bezpośrednio w GRUB, wskazując lokalizację sieciową pliku instalacyjnego za pomocą parametru `inst.ks`.
```bash
inst.ks=http://10.0.2.15:8000/anaconda-ks.cfg
```

## Sekcja %post
Najważniejszym etapem dostosowywania systemu do roli serwerowej jest sekcja %post w pliku odpowiedzi. Pozwala ona na uruchomienie skryptów bezpośrednio po zakończeniu instalacji pakietów systemowych, lecz jeszcze przed pierwszym restartem maszyny docelowej. W sekcji tej programuje na przykład pobranie skompilowanych wcześniej artefaktów.

```bash
%post --log=/root/ks-post-install.log
curl -o /tmp/library.tar.gz http://10.0.2.15:8000/library.tar.gz
tar -xzf /tmp/library.tar.gz -C /usr/local/lib/
%end
```

---

# 3. Kubernetes
Wytwarzanie oprogramowania w architekturze mikrousługowej wymaga zastosowania systemów skomplikowanej orkiestracji. Świetnym rozwiązaniem jest Kubernetes, a do celów deweloperskich i testowych powszechnie stosuje się lekki klaster `Minikube` kontrolowany za pomocą narzędzia `kubectl`.

## Konfiguracja klastra
Uruchomienie klastra wymaga alokacji odpowiednich zasobów, wskazanych w dokumentacji. Do monitorowania stanu klastra wykorzystuje się graficzny interfejs `Dashboard`. W środowiskach, w których bezpośredni dostęp z poziomu sieci zewnętrznej jest utrudniony, stosuje się mechanizm tunelowania i przekierowania portów w celu udostępnienia konsoli administratora na interfejsie sieciowym hosta.

```bash
kubectl proxy --port=8081 --address='0.0.0.0' --accept-hosts='^.*'
```

## Deklaratywne wdrożenia
Wdrażanie kontenerów w środowisku orkiestracji opiera się na plikach manifestów w formacie `.yaml`, co pozwala na zachowanie zasad podejścia `Infrastructure as Code`. W przypadku testowania własnych obrazów aplikacyjnych, kluczowym aspektem jest przesłanie przygotowanego pliku `.tar` bezpośrednio do pamięci klastra oraz wymuszenie pomijania zdalnego repozytorium podczas rozruchu.

```bash
minikube image load nginx:v0
```

Przykładowy manifest deklaratywnego wdrożenia:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:v0
        imagePullPolicy: Never
        ports:
        - containerPort: 80
```

## Skalowanie i tolerancja błędów wdrożeń
Platforma Kubernetes pozwala na dynamiczną zmianę liczby replik, automatycznie zarządzając cyklem życia podów i bezpiecznie kończąc zbędne procesy. Niezwykle istotną cechą orkiestratora jest odporność na awarie podczas wdrażania nowych wersji aplikacji. W przypadku próby wdrożenia uszkodzonego obrazu, mechanizm `rollout` wstrzymuje aktualizację. Dotychczas działające pody nie są wyłączane, dzięki czemu aplikacja końcowa zachowuje ciągłość działania i pełną funkcjonalność mimo błędu w nowym kodzie. Do automatycznej weryfikacji statusu aktualizacji stosuje się dedykowane skrypty monitorujące.

## Strategie aktualizacji oprogramowania
W zależności od wymagań dotyczących bezawaryjności i dostępności systemu, stosuje się różne strategie:
- `Recreate`: Wszystkie pody starszej wersji są terminowane przed uruchomieniem nowych instancji. Zapobiega to konfliktom wersji, lecz generuje chwilową przerwę w działaniu usługi.
- `RollingUpdate`: Stopniowa i bezprzerwowa wymiana kontenerów. Kubernetes sukcesywnie zastępuje stare pody nowymi, utrzymując stałą dostępność aplikacji dla użytkowników końcowych.
- `Canary`: Wdrożenie hybrydowe, polegające na jednoczesnym uruchomieniu nowej i starej wersji aplikacji w określonej proporcji. Umożliwia to testowanie zmian na ograniczonej grupie użytkowników przed pełnym wdrożeniem produkcyjnym.

---

# 4. Azure
Do szybkiego wdrażania i testowania pojedynczych aplikacji skonteneryzowanych, bez konieczności utrzymywania i konfigurowania pełnego klastra orkiestracji, wykorzystuje się usługi typu `Container-as-a-Service`, takie jak `Azure Container Instances` na platformie Microsoft Azure.

## Publikacja obrazu w publicznym rejestrze
Wdrażanie kontenerów w chmurze publicznej wymaga zapewnienia dostępu do obrazu aplikacyjnego z poziomu zewnętrznego rejestru. W tym celu wcześniej zbudowany, lokalny obraz kontenera z aplikacją zostaje przesłany do publicznego rejestru `Docker Hub`.

```bash
docker tag nginx jaian400/nginx
docker push jaian400/nginx
```

## Konfiguracja grup zasobów
Prace na platformie Azure rozpoczyna się od zdefiniowania kontenera na zasoby, czyli `Resource Group`, za pomocą wiersza poleceń `Azure CLI` bądź interfejsu graficznego.

```bash
az group create --name resourceGroupJP --location germanywestcentral
```

## Wdrażanie kontenerów
Po poprawnym zdefiniowaniu grupy zasobów i wyborze optymalnego regionu, następuje proces uruchomienia kontenera. Usługa ACI pozwala na precyzyjne określenie parametrów wydajnościowych oraz konfigurację sieciową, w tym przypisanie publicznego adresu IP oraz unikalnego rekordu DNS w domenie usługi Azure.

```bash
az container create \
  --resource-group resourceGroupJP \
  --name nginx \
  --image jaian400/nginx \
  --dns-name-label jp-nginx\
  --ports 80 \
  --ip-address Public \
  --cpu 1 \
  --memory 1 \
  --location germanywestcentral
```

Po zakończeniu procesu wdrażania poprawność działania aplikacji jest weryfikowana poprzez interakcję z hostowaną stroną. Ostatnim etapem procedury jest analiza logów kontenera w celu potwierdzenia stabilności uruchomionej usługi oraz usunięcie grupy zasobów, co pozwala na zwolnienie limitów subskrypcji i zachowanie higieny środowiska chmurowego.

```bash
az container logs --resource-group resourceGroupJP --name nginx
az group delete --name resourceGroupJP --yes --no-wait
```

---

# 5. Wnioski
Automatyzacja procesów wdrożeniowych stanowi kluczowy element pracy w duchu nowoczesnego DevOps. `Ansible` umożliwia sprawne zarządzanie konfiguracją zarówno na pojedynczych maszynach, jak i na całych grupach rozproszonych serwerów docelowych. Dzięki bezagentowej architekturze opartej na standardowym protokole SSH, narzędzie to pozwala na zdalne wdrażanie usług bez potrzeby instalowania i utrzymywania dodatkowego oprogramowania klienckiego. Użycie skryptów `Kickstart` pozwala na znaczne skrócenie czasu instalacji systemów operacyjnych poprzez ich pełną autokonfigurację. Rozwiązanie to umożliwia automatyczny podział dysków, pobranie pakietów sieciowych oraz bezobsługowe wykonanie skryptów poinstalacyjnych na czystym systemie. `Kubernetes` otwiera z kolei drogę do budowania stabilnych i bezpiecznych środowisk opartych na architekturze mikroserwisów. Dzięki funkcjom takim jak automatyczne skalowanie replik oraz zaawansowane strategie wdrożeń, klaster dba o ciągłość działania aplikacji nawet w przypadku wykrycia awarii w nowej wersji kodu. Konteneryzacja w chmurze `Azure` to natomiast wysoce przydatne rozwiązanie do szybkiego wdrażania projektów i ich publicznej prezentacji. Korzystanie z usługi Azure Container Instances pozwala na szybkie wystawienie kontenera w internecie pod unikalną nazwą DNS, co eliminuje konieczność konfigurowania i utrzymywania własnej infrastruktury sieciowej.