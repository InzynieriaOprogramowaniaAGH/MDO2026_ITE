# Sprawozdanie zbiorcze 8 -12

# Lab 8:
## Wstęp teoretyczny i cel ćwiczenia:
Celem ćwiczenia było zapoznanie się z koncepcją Infrastructure as Code (IaC) przy użyciu narzędzia Ansible. W odróżnieniu od tradycyjnego, ręcznego konfigurowania serwerów, podejście IaC pozwala na definiowanie stanu infrastruktury za pomocą czytelnego dla człowieka kodu (w przypadku Ansible jest to język YAML).
Ansible polega na pisaniu przez administratora skryptów określającyc jaki ma być docelowy stan systemu (np. pakiet ma być zainstalowany, usługa uruchomiona). Kluczową cechą Ansible jest że maszyny docelowe nie wymagają instalacji dedykowanego oprogramowania (poza standardowym serwerem SSH oraz interpreterem języka Python).
## Przygotowanie środowiska i konfiguracja komunikacji
Podstawą działania Ansible jest bezpieczna komunikacja pomiędzy węzłem sterującym węzłami zarządzanymi.
Wygenerowano nową maszynę wirtualną poprzez operację pełnego klonowania. Kluczowym krokiem było wygenerowanie nowych adresów MAC dla kart sieciowych klona. W sieciach TCP/IP identyfikatory MAC muszą być unikalne; ich duplikacja spowodowałaby konflikty w tablicach ARP ruterów i błędy przy przydzielaniu adresów z serwera DHCP.
Dla zabezpieczenia stanu maszyny przed modyfikacjami wykonano migawkę systemu (Snapshot). Jest to ważny element, pozwalający na błyskawiczne przywrócenie w przypadku błędu.
Do zapewnienia bezhasłowego i bezpiecznego uwierzytelniania Ansible użyto asymetrycznej kryptografii klucza publicznego (RSA):
1.	Wygenerowano parę kluczy za pomocą ssh-keygen.
2.	Przesłano klucz publiczny na maszynę docelową za pomocą ssh-copy-id.
 
 

## Inwentaryzacja
Zarządzanie środowiskiem oparto na logicznych nazwach DNS. W pliku /etc/hosts powiązano IP maszyny docelowej z nazwą ansible-target. Utworzono statyczny plik inwentarza hosts.ini podzielony na grupy:
•	[Orchestrators] – węzeł zarządzający.
•	[Endpoints] – maszyny docelowe.
Komunikację zweryfikowano komendą ad-hoc: ansible all -i hosts.ini -m ping.
 
 


## Zdalne wywołanie procedur
Procedury konfiguracyjne zdefiniowano w pliku YAML, używając dyrektywy become: yes do eskalacji uprawnień (sudo).
•	Zastosowane moduły (np. apt, service, copy) wprowadzają zmiany w systemie tylko wtedy, gdy stan rzeczywisty różni się od zadeklarowanego.
•	Przy aktualizacji pakietów użyto parametru ignore_errors: yes w celu ominięcia problemu zablokowanego procesu menedżera dpkg.
•	Podczas wykonywania zadań zaobserwowano poprawne zachowanie Ansible w przypadku odcięcia maszyny (błąd UNREACHABLE z powodu braku miejsca na dysku, skutkującego zatrzymaniem działania hosta docelowego).
 

## Modularyzacja infrastruktury
W celu uporządkowania kodu i możliwości jego ponownego wykorzystania, zadania przeniesiono do Roli. Strukturę wygenerowano poleceniem ansible-galaxy role init. Konfigurację umieszczono w tasks/main.yml, a niezbędne metadane (autor, licencja) zadeklarowano w meta/main.yml.

 

## Wdrożenie artefaktu – Docker
W ramach działania zbudowanej Roli zautomatyzowano proces wdrożenia aplikacji:
1.	Instalacja środowiska: Modułami Ansible zainstalowano zależności i uruchomiono usługę Dockera.
2.	Wdrożenie: Modułem shell uruchomiono w tle serwer nginx z mapowaniem portów.
3.	Sanity Check: Wykonano test poprawności działania. Przechwycono wynik polecenia docker ps a następnie wyświetlono go modułem debug na maszynie zarządzającej, potwierdzając uruchomienie aplikacji.

## Podsumowanie
Wykorzystanie Ansible pozwoliło całkowicie wyeliminować ręczne błędy konfiguracyjne. Stworzono powtarzalny, samo-dokumentujący się potok (pipeline), który w sposób zautomatyzowany przygotowuje środowisko, instaluje wymagane pakiety oraz wdraża docelową aplikację webową.

# Lab 9 :
## Wstęp teoretyczny i cel ćwiczenia
Celem zadania było zapoznanie się z automatyzacją procesu instalacji systemu operacyjnego z wykorzystaniem plików odpowiedzi. 
W systemach typu Fedora proces ten realizowany jest za pomocą narzędzia Kickstart i instalatora Anaconda. Zamiast ręcznego przeklikiwania opcji instalatora, wszystkie parametry – od układu partycji, przez konfigurację sieci, po wybór pakietów – definiuje się w jednym pliku tekstowym (.cfg). Pozwala to na masowe i powtarzalne wdrażanie identycznych środowisk.
Z powodu braku wystarczającej przestrzeni na dysku nie udało się wykonać ćwiczenia – początek problemu był widoczny już we wcześniejszym ćwiczeniu. Warunki sprzętowe nie pozwoliły na zwolnienie ponad 20 GB pamięci do pełnego wykonania ćwiczenia.
## Projekt i modyfikacja pliku odpowiedzi
Aby przygotować w pełni nienadzorowaną instalację, należy odpowiednio zmodyfikować plik wygenerowany przez instalator  anaconda-ks.cfg. Zgodnie z wytycznymi, zaplanowano następujące modyfikacje:
1.	Konfiguracja dysku:
Aby instalacja mogła przebiec bez pytań o nadpisanie danych na używanym wcześniej dysku, konieczne jest użycie dyrektyw czyszczących:
clearpart --all –initlabel
autopart --type=lvm
2.	Konfiguracja siec:
Ustalenie stałej, rozpoznawalnej nazwy hosta zamiast domyślnego localhost:
	network --hostname=fedora-docker-target
3.	Konfiguracja repozytoriów:
Wskazanie instalatorowi źródeł, z których ma pobrać pakiety w wersji aktualnej

4.	Zakończenie instalacji:
Zastosowanie dyrektywy reboot, dzięki której maszyna po zakończonym procesie automatycznie uruchomi się ponownie, gotowa do pracy.

## Automatyzacja wdrażania oprogramowania
Zgodnie z wymaganiami, maszyna natychmiast po instalacji powinna uruchomić wybraną aplikację w kontenerze Docker. Wymaga to odpowiedniego przygotowania sekcji %post w pliku Kickstart.

W sekcji %packages zaplanowano instalację pakietu Dockera. Następnie w sekcji %post zaprojektowano aktywację usługi Dockera oraz stworzenie dedykowanej usługi Systemd, która uruchomi kontener dopiero podczas pierwszego, właściwego startu systemu:
 
## Oczekiwany przebieg instalacji
Tak przygotowany plik należało udostępnić w sieci lokalnej (np. za pomocą prostego serwera python3 -m http.server). Następnie, po zbootowaniu nowej maszyny wirtualnej z obrazu ISO Fedory, należało w menu GRUB dopisać parametr jądra.
System po pobraniu pliku powinien wykonać cały proces bez jakiejkolwiek interakcji ze strony użytkownika.
## Podsumowanie 
Laboratorium pozwoliło na dogłębne zapoznanie się z mechanizmami nienadzorowanej instalacji systemów operacyjnych. Udowodniono, że wykorzystanie plików odpowiedzi stanowi kluczowy element podejścia Infrastructure as Code, zapewniając powtarzalność wdrażanych środowisk.
Najważniejszym wnioskiem z przeprowadzonej analizy jest zrozumienie ograniczeń środowiska instalatora. Poprawne zaprojektowanie sekcji %post – opierające się na tworzeniu usług Systemd zamiast bezpośredniego wywoływania komend Dockera.

# Lab 10:
## Wstęp teoretyczny i cel ćwiczenia
Celem ćwiczenia było zapoznanie się z podstawami organizacji kontenerów przy użyciu platformy Kubernetes. Środowiskiem roboczym wykorzystanym do symulacji klastra była platforma Minikube, która pozwala na uruchomienie jedno-węzłowego klastra Kubernetes w lokalnym systemie operacyjnym. W ramach zajęć przeprowadzono proces instalacji, konfiguracji środowiska, uruchomienia pojedynczego kontenera (Pod), a następnie zaimplementowano deklaratywne wdrożenie (Deployment) z mechanizmem skalowania i udostępnieniem usługi (Service) na zewnątrz klastra.

## Instalacja i konfiguracja środowiska Minikube
Minikube został pobrany bezpiecznym kanałem (HTTPS) bezpośrednio z oficjalnego repozytorium.
Uruchomienie Minikube zrealizowano za pomocą polecenia minikube start --driver=docker. Wybór środowiska uruchomieniowego (drivera) opartego na Dockerze,, jest optymalnym sposobem na mitygację wysokich wymagań sprzętowych. Kubernetes uruchamia swoje komponenty bezpośrednio w kontenerach platformy Docker, co znacząco oszczędza zasoby procesora i pamięci RAM.
Aby ułatwić zarządzanie klastrem, skonfigurowano alias dla polecenia kubectl (alias kubectl="minikube kubectl --"). Sprawdzenie stanu węzłów (kubectl get nodes) wykazało, że lokalny węzeł minikube posiada status Ready (gotowy do pracy). Następnie uruchomiono graficzny interfejs zarządzania klastrem – Kubernetes Dashboard, który został pomyślnie wyeksponowany na lokalnym porcie, co udowodniło poprawną łączność z klastrem.

## Uruchomienie kontenera
W Kubernetes najmniejszą jednostką wdrożeniową nie jest pojedynczy kontener, lecz Pod. Pod to kapsuła, która może zawierać jeden lub więcej ściśle powiązanych ze sobą kontenerów, współdzielących przestrzeń dyskową, adres IP oraz porty.
Do testów wybrano gotowy obraz serwera WWW – nginx. Za pomocą trybu imperatywnego uruchomiono Poda poleceniem:
kubectl run apk --image=nginx --port=80 --labels app=apk
Wygenerowało to obiekt Pod o nazwie apk. Ponieważ klaster Kubernetes posiada własną, wewnętrzną sieć (izolowaną od hosta), kontener uruchomił się poprawnie ale nie był domyślnie dostępny z zewnątrz.
Aby uzyskać dostęp do aplikacji, zrealizowano przekierowanie portów:
kubectl port-forward pod/apk 8080:80
To polecenie utworzyło tunel pomiędzy portem 8080 na maszynie lokalnej a portem 80 wewnątrz Poda. Pozwoliło to na weryfikację, że serwer NGINX pracuje poprawnie i nie kończy natychmiast pracy.

## Deployment
Uruchamianie pojedynczych Podów nie jest dobrą praktyką produkcyjną, ponieważ w przypadku awarii Poda, Kubernetes nie utworzy go ponownie. Rozwiązaniem tego problemu jest kontroler Deployment.
Utworzono plik wdrozenie.yaml. Opisano w nim pożądany stan klastra (w przeciwieństwie do poleceń używanych wcześniej).
Kluczowe elementy zdefiniowane w pliku YAML:
•	kind: Deployment – określa typ zasobu.
•	replicas: 4 – mechanizm skalowania. Informuje klaster, że w każdej chwili mają działać dokładnie 4 identyczne instancje aplikacji.
•	image: nginx:latest – wskazanie obrazu kontenera.
Wdrożenie uruchomiono poleceniem kubectl apply, a jego przebieg monitorowano za pomocą kubectl rollout status deployment/wdrozenie. System zaraportował płynne wdrożenie replik.
 
## Service
Posiadanie 4 replik aplikacji rodzi problem dostępu: każdy z 4 Podów ma własny, zmienny adres IP wewnątrz klastra. Aby połączyć je w jeden spójny punkt dostępowy, Kubernetes wykorzystuje zasób typu Service.

Użyto polecenia minikube service wdrozenie. Wygenerowało to usługę łączącą się z utworzonym wcześniej Deployment.
Zrzut ekranu wskazuje, że Minikube powiązał wewnętrzny port 80 aplikacji z wyeksponowanym na zewnątrz klastra adresem URL: http://192.168.49.2:31653.

Usługa Servic działa tutaj jako wewnętrzny router. Użytkownik wpisując w przeglądarkę adres 192.168.49.2:31653 trafia do Usługi, która następnie przekierowuje ten ruch do jednego z 4 działających Podów NGINX. Jeśli jeden z Podów ulegnie awarii, Deployment automatycznie powoła nowy, a Service zaktualizuje listę dostępnych adresów IP, zapewniając ciągłość działania aplikacji.
 
Ostatni zrzut ekranu z Dashboardu stanowi doskonałe podsumowanie wykonanej pracy:
•	Widoczny jest 1 Deployment .
•	Widoczny jest 1 Replica Set (kontroler dbający o utrzymanie określonej liczby replik, utworzony automatycznie przez Deployment).
•	Widoczne są 4 Pody działające równolegle (skalowanie poziome).
 
## Podsumowanie
Przejście od ręcznego uruchamiania pojedynczego kontenera do wdrożenia za pomocą pliku YAML z mechanizmem skalowania (4 repliki) i udostępnieniem usługi, obrazuje główną zaletę platformy Kubernetes. Narzędzie to nie tylko uruchamia kontenery, ale przede wszystkim nimi zarządza  – dba o ich odporność na awarie. Użycie środowiska Minikube z silnikiem Dockerowym pozwoliło na sprawną realizację zadań w izolowanym, bezpiecznym środowisku lokalnym.

# Lab 11:
## Wstęp teoretyczny i cel ćwiczenia

Celem laboratorium było zaawansowane zarządzanie cyklem życia aplikacji w Kubernetes. Skupiono się na mechanizmach gwarantujących ciągłość działania usług podczas aktualizacji oprogramowania. W ramach ćwiczenia przeanalizowano różne strategie wdrażania nowych wersji kontenerów (takie jak Recreate, Rolling Update oraz Canary Deployment), a także przetestowano wbudowane w Kubernetesa mechanizmy reagowania na awarie i automatycznego przywracania środowiska do ostatniej działającej wersji (Rollback).
## Przygotowanie obrazów kontenerowych
Proces wdrożenia rozpoczęto od przygotowania obrazów aplikacji, wykorzystując jako bazę lekki serwer nginx:alpine. Skonstruowano pliki Dockerfile, w których nadpisano domyślny plik index.html.
•	Zbudowano i otagowano dwie w pełni funkcjonalne wersje obrazu (wersja:v1 oraz wersja:v2), co umożliwiło późniejsze testowanie procesu aktualizacji.
•	Stworzono celowo wadliwy obraz (wersja:v3). Błąd polegał na wymuszeniu uruchomienia wewnątrz kontenera nieistniejącego polecenia (CMD ["./niema"]), co pozwoliło na symulację awarii środowiska produkcyjnego.


## Deployment
Utworzono podstawowy manifest YAML deklarujący wdrożenie testowej aplikacji. Następnie wykorzystano polecenie kubectl scale deployment do zbadania mechanizmów klastra. Obserwowano zachowanie mechanizmu ReplicaSet podczas:
•	Dynamicznego skalowania poziomego w górę do 8 replik w celu obsługi wzmożonego ruchu.
•	Drastycznego skalowania w dół do 1 repliki.
•	Całkowitego wygaszenia podów (0 replik), co udowadnia, że kontroler Kubernetes zachowuje definicję wdrożenia nawet przy braku aktywnych instancji.
•	Ponownego podniesienia środowiska do wymaganych 4 replik.

## Mechanizm RollBack
Przetestowano cykl życia aplikacji pod kątem aktualizacji wersji oprogramowania, wykorzystując komendę kubectl set image.
•	Po próbie aktualizacji do uszkodzonego obrazu (wersja:v3), system Kubernetes, wbudowanym mechanizmem monitorowania stanu, wykrył niemożność uruchomienia aplikacji. Pody weszły w stan awaryjny (Error oraz CrashLoopBackOff), zapobiegając całkowitemu usunięciu starych, poprawnie działających replik.
•	Wykorzystano polecenie kubectl rollout history do identyfikacji poszczególnych rewizji oraz diagnozy zaistniałych problemów. Następnie uruchomiono polecenie kubectl rollout undo, które z sukcesem i bezprzerwowo przywróciło wdrożenie do ostatniej działającej rewizji (v2).

## Automatyzacja weryfikacji wdrożenia
Zaprojektowano i zaimplementowano skrypt powłoki, np. w celu ewentualnego włączenia go w potoki CI/CD (np. Jenkins). Skrypt wykorzystywał polecenie kubectl rollout status z parametrem --timeout=60s. Mechanizm ten został skonstruowany na bazie instrukcji warunkowej (if...else), dzięki czemu systematycznie i programowo weryfikował, czy wdrożenie zostało przeprowadzone w wymaganym limicie czasu, kończąc się pomyślnym statusem wyjścia (exit 0) lub błędem (exit 1).
 
## Zaawansowane strategie wdrożenia
•	Recreate: Wymuszenie strategii (type: Recreate), w której w pierwszej kolejności niszczone są wszystkie istniejące pody, a nowe uruchamiane są dopiero na zwolnionych zasobach. Strategia ta generuje jednak krótkotrwałą przerwę w dostępności usługi.
 
•	Rolling Update: Skonfigurowano domyślną strategię aktualizacji stopniowej, ustalając zaawansowane reguły ograniczające: maxUnavailable: 2 (maksymalnie dwa pody niedostępne) i maxSurge: 25% (możliwość tymczasowego przekroczenia puli podów). Pozwoliło to na płynną aktualizację z zachowaniem dostępności.
 
•	Canary Deployment: Wdrożono strategię kanarkową za pomocą dwóch osobnych manifestów wdrożeń. Stworzono stabilną część (wersja:v1 – 4 repliki) oraz zaledwie 1 replikę z nową wersją oprogramowania (wersja:v2). Obu wdrożeniom nadano tę samą etykietę (app: canary-app), co pozwoliło wspólnemu Serwisowi Kubernetes (Canary Service) na rozdzielanie ruchu sieciowego w proporcji zbliżonej do 80% do 20% – umożliwiając bezpieczne testy nowej aplikacji na ułamku realnego obciążenia.
 
 

## Podsumowanie
Przeprowadzone ćwiczenia udowodniły, że Kubernetes to nie tylko środowisko uruchomieniowe, ale potężne narzędzie do  bezpiecznego wdrażania zmian. Przejście od prostej strategii Recreate do Rolling Update pokazało, jak można realizować aktualizacje bez przerw w dostępie do usługi. Z kolei zastosowanie strategii Canary udowodniło możliwość bezpiecznego testowania nowych funkcjonalności na wyizolowanym ułamku realnego ruchu sieciowego. 

# Lab 12:

## Cel ćwiczenia
Celem laboratorium było zapoznanie się z platformą chmurową Microsoft Azure w kontekście wdrażania skonteneryzowanych aplikacji. 

## Przygotowanie środowiska
Przed rozpoczęciem pracy w chmurze, należało upewnić się, że lokalne środowisko ma dostęp do niezbędnych narzędzi oraz zautoryzować się w odpowiednich usługach.
Do zarządzania zasobami Azure można używać portalu webowego , wbudowanego Azure Cloud Shell lub lokalnie zainstalowanego wiersza poleceń (Azure CLI). Wybrano podejście oparte na Azure CLI (instalacja poprzez skrypt instalacyjny dla systemów Ubuntu), co pozwala na automatyzację zadań i pełną kontrolę z poziomu własnego terminala. Logowanie do chmury przeprowadzono z wykorzystaniem mechanizmu --use-device-code, który jest zalecaną metodą uwierzytelniania na urządzeniach bez interfejsu graficznego dla przeglądarki. Dodatkowo zalogowano się do Docker Huba.
## Utworzenie grupy zasobów
Kolejnym krokiem było utworzenie logicznego kontenera na zasoby chmurowe.
W architekturze Azure  Grupa Zasobów to podstawowy element organizacyjny. Jest to logiczny folder, w którym grupuje się powiązane ze sobą zasoby (np. maszyny wirtualne, bazy danych, kontenery) dla danej aplikacji. Ułatwia to zarządzanie uprawnieniami, monitorowanie kosztów oraz późniejsze usuwanie całego środowiska – usunięcie grupy zasobów kaskadowo usuwa wszystkie znajdujące się w niej elementy, co chroni przed niechcianymi kosztami.

## Wdrożenie kontenera z Docker Hub
Polecenie az container create wysyła żądanie do Azure Resource Manager API w celu przydzielenia zasobów obliczeniowych dla kontenera.
Użyte parametry definiują infrastrukturę jako kod:
•	--image jakarekk/apk:v1 – wskazuje źródło obrazu (publiczny Docker Hub). Chmura Azure sama pobiera ten obraz.
•	--dns-name-label testjakarekk – deleguje do Azure utworzenie w pełni kwalifikowanej nazwy domeny. Dzięki temu kontener będzie dostępny pod przyjaznym adresem URL, a nie tylko pod zmiennym adresem IP.
•	--ports 80 – otwiera port HTTP na zewnątrz, pozwalając na ruch sieciowy do kontenera.
•	--cpu 1 --memory 1.5 – ściśle określa limity zasobów dla instancji (1 rdzeń procesora, 1.5 GB RAM).
 
## Weryfikacja działania
Ponieważ kontenery ACI są bezstanowe i mogą być restartowane, adres IP może ulec zmianie. Niezawodnym sposobem komunikacji jest użycie wygenerowanego wcześniej adresu FQDN. Azure CLI pozwala na filtrowanie odpowiedzi API (parametr --query), co ułatwia automatyczne wyciągnięcie samego adresu URL bez czytania całego pliku JSON.
Za pomocą terminala pobrano przypisany adres FQDN, a następnie wprowadzono go do przeglądarki internetowej, co poskutkowało wyświetleniem interfejsu aplikacji webowej ("Aplikacja v1"). Z sukcesem pobrano również logi z wewnątrz kontenera (logi serwera Nginx potwierdzające m.in. start procesów workerów).
 
## Czyszczenie środowiska
Utrzymywanie włączonego kontenera generowałoby niepotrzebne zużycie limitu kredytów. Zamiast usuwać pojedynczy kontener, najlepszą praktyką jest usunięcie całej Grupy Zasobów. Gwarantuje to, że żaden powiązany komponent (np. karta sieciowa, wolumen) nie pozostanie w chmurze i nie będzie generował kosztów.

Zlecono usunięcie grupy zasobów lab12. Parametr --no-wait pozwolił na natychmiastowe zwrócenie kontroli w terminalu, zlecając zadanie usunięcia jako proces w tle po stronie serwerów Microsoft Azure. 
 
## Podsumowanie 

Wykorzystanie publicznego obrazu z repozytorium Docker Hub oraz automatyzacja procesu za pomocą Azure CLI pokazały, jak sprawnie można zarządzać cyklem życia kontenera – od konfiguracji zasobów CPU i RAM, przez monitoring logów, aż po udostępnienie usługi pod unikalną domeną FQDN. Istotnym aspektem laboratorium było również nabycie dobrych praktyk w zakresie optymalizacji kosztów chmurowych, co zrealizowano poprzez skuteczne usunięcie całej grupy zasobów, eliminując tym samym ryzyko niepotrzebnego zużycia kredytów studenckich po zakończeniu testów.

