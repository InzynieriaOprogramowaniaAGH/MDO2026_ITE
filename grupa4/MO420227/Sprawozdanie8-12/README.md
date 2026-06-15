# Sprawozdanie z laboratoriów 8-12

## Wstęp

Niniejsze sprawozdanie stanowi syntezę zagadnień teoretycznych oraz architektonicznych związanych z nowoczesnymi metodami zarządzania infrastrukturą IT, automatyzacją procesów wdrożeniowych (Deployment) oraz orkiestracją mikrousług. Analiza obejmuje zagadnienia od niskopoziomowej konfiguracji systemów operacyjnych metodami nienadzorowanymi, przez paradygmat *Infrastructure as Code*, aż po zaawansowane strategie zarządzania cyklem życia aplikacji w klastrach Kubernetes oraz w chmurze obliczeniowej Microsoft Azure.

---

## 1. Paradygmat Infrastructure as Code i automatyzacja systemowa

### 1.1. Koncepcja deklaratywnego zarządzania konfiguracją
Tradycyjne, imperatywne podejście do administracji systemami polega na sekwencyjnym wykonywaniu poleceń w celu osiągnięcia pożądanego stanu środowiska. Podejście to jest podatne na błędy ludzkie oraz zjawisko rozbieżności konfiguracyjnej między serwerami. 

Narzędzia takie jak Ansible wprowadzają model **deklaratywny**. Administrator definiuje stan docelowy infrastruktury np. „pakiet X ma być zainstalowany”, „usługa Y ma być uruchomiona”, a silnik wykonawczy odpowiada za dobór i realizację odpowiednich kroków systemowych. Architektura Ansible opiera się na modelubezagentowym, wykorzystującym istniejący protokół komunikacyjny SSH do przesyłania tymczasowych modułów wykonywalnych na maszyny docelowe. Eliminuje to narzut związany z utrzymaniem dedykowanego oprogramowania klienckiego na zarządzanych węzłach.

### 1.2. Zasada idempotentności
Kluczową cechą systemów IaC jest idempotentność. Oznacza to, że wielokrotne uruchomienie tego samego skryptu konfiguracyjnego na maszynie docelowej przyniesie dokładnie taki sam rezultat, nie powodując skutków ubocznych ani ponownego wykonywania operacji, które zostały już zrealizowane. 

Podczas pierwszej interpretacji skryptu system wprowadza wymagane zmiany. Kolejne wywołania weryfikują jedynie zgodność stanu rzeczywistego z deklarowanym, jeśli są one tożsame, system nie podejmuje akcji modyfikujących. Wyjątek stanowią moduły jawnie wymuszające akcje przejściowe, takie jak restart usług.

### 1.3. Modularyzacja konfiguracji poprzez role
W miarę wzrostu złożoności systemów, utrzymywanie monolitycznych plików konfiguracyjnych staje się nieefektywne. W systemie Ansible standardem strukturyzacji kodu są role (np. zarządzane poprzez repozytorium Ansible Galaxy). Role pozwalają na podział konfiguracji na niezależne, reużywalne komponenty zawierające:
*   Zadania – właściwą logikę wdrożeniową.
*   Zmienne – parametryzujące zachowanie roli.
*   Szablony – dynamicznie generowane pliki konfiguracyjne.
*   Pliki statyczne oraz handlery – wywoływane reaktywnie w odpowiedzi na zmiany stanu środowiska.

---

## 2. Automatyzacja instalacji systemów operacyjnych

Przed wdrożeniem narzędzi orkiestracji lub konfiguracji wyższego poziomu niezbędne jest przygotowanie bazowego środowiska systemowego. Proces ten realizowany jest za pomocą instalacji nienadzorowanej.

```
[ Serwer HTTP / Nośnik ] --(Plik Kickstart: ks.cfg)--> [ Instalator Anaconda ] --> [ Konfiguracja OS & Post-install ]
```

W ekosystemie systemów opartych na dystrybucji Red Hat standardem jest mechanizm **Kickstart**. Opiera się on na pliku odpowiedzi (zazwyczaj `ks.cfg`), który dostarcza instalatorowi systemowemu kompletnych danych konfiguracyjnych, takich jak:
*   Schemat partycjonowania dysków i systemy plików.
*   Konfiguracja interfejsów sieciowych i strefy czasowej.
*   Poświadczenia użytkowników, hasła, klucze SSH.
*   Lista pakietów oprogramowania do zainstalowania w pierwszym kroku.

Niezwykle istotnym elementem pliku Kickstart jest sekcja `%post`. Pozwala ona na wykonanie skryptów powłoki bezpośrednio po zakończeniu kopiowania plików systemowych, ale przed pierwszym uruchomieniem maszyny. Umożliwia to m.in. automatyczną instalację silników kontenerowych (np. Docker, Moby) oraz definiowanie jednostek systemd odpowiedzialnych za uruchamianie usług aplikacyjnych przy starcie systemu. Taka synergia pozwala na natychmiastowe włączenie nowo zainstalowanego serwera do puli maszyn roboczych bez ingerencji administratora.

---

## 3. Orkiestracja kontenerów: Architektura i abstrakcje Kubernetes

Konteneryzacja zapewnia powtarzalność środowiska uruchomieniowego aplikacji. Jednak zarządzanie dziesiątkami lub setkami kontenerów na wielu fizycznych maszynach wymaga systemu orkiestracji. Standardem w tej dziedzinie jest Kubernetes (K8s).

### 3.1. Podstawowe abstrakcje Kubernetes
Kubernetes odchodzi od bezpośredniego zarządzania pojedynczymi kontenerami na rzecz logicznych warstw abstrakcji:
*   **Pod:** Najmniejsza jednostka wdrażalna w Kubernetes. Grupuje jeden lub więcej kontenerów współdzielących przestrzeń sieciową, przestrzeń dyskową oraz specyfikację uruchomieniową. Kontenery wewnątrz jednego Poda komunikują się ze sobą za pośrednictwem interfejsu *localhost*.
*   **Deployment:** Deklaratywny kontroler wyższego poziomu, który definiuje pożądany stan aplikacji np. wersję obrazu kontenerowego, liczbę replik. Deployment stale monitoruje stan klastra poprzez pętlę uzgadniania. Jeśli rzeczywista liczba działających Podów różni się od zadeklarowanej np. w wyniku awarii węzła, kontroler dąży do przywrócenia stanu zadanego, powołując do życia nowe instancje.
*   **Service:** Stabilny punkt dostępowy do grupy Podów realizujących tę samą funkcję. Ponieważ Pody są efemeryczne, ich adresy IP zmieniają się przy każdym odtworzeniu, Service udostępnia stały adres IP wewnątrz klastra lub na zewnątrz oraz realizuje automatyczne równoważenie ruchu pomiędzy aktywnymi Podami oznaczonymi odpowiednimi etykietami.

### 3.2. Komunikacja i translacja portów
Sieć Kubernetes jest płaska – każdy Pod posiada unikalny adres IP w skali klastra. Dostęp do aplikacji z poziomu systemu operacyjnego hosta w celach deweloperskich realizowany jest często za pomocą Port Forwarding, który tuneluje ruch sieciowy z lokalnego portu maszyny klienckiej bezpośrednio do interfejsu sieciowego wybranego Poda lub Usługi.

---

## 4. Strategie aktualizacji i zarządzanie cyklem życia aplikacji

W środowiskach produkcyjnych kluczowe jest minimalizowanie czasu niedostępności usług podczas wdrażania nowych wersji oprogramowania. Kubernetes natywnie wspiera różne strategie aktualizacji.

| Strategia | Zalety | Wady | Ryzyko |
| :--- | :--- | :--- | :--- |
| **Recreate** | Brak problemów ze zgodnością wersji wstecznej bazy danych i API. | Występuje całkowita, chwilowa niedostępność aplikacji dla użytkowników końcowych. | Niskie pod kątem spójności stanowej; wysokie pod kątem biznesowym. |
| **Rolling Update** | Brak przestojów w działaniu aplikacji; stopniowa wymiana zasobów. | Wymaga pełnej kompatybilności wstecznej (przez pewien czas koegzystują wersje starsza i nowsza). | Średnie (wymaga dbałości o architekturę aplikacji). |
| **Canary Deployment** | Bezpieczne testowanie na produkcji; minimalizacja wpływu ewentualnych błędów. | Złożona konfiguracja routingowa i konieczność zaawansowanego monitorowania logów. | Bardzo niskie (błąd dotyka tylko ułamka użytkowników). |

### 4.1. Charakterystyka strategii wdrożeniowych

#### Recreate
Wszystkie istniejące instancje wersji starszej są terminowane przed uruchomieniem jakiejkolwiek instancji nowej wersji. 

#### Rolling Update
Kubernetes stopniowo zastępuje stare Pody nowymi. Proces ten jest parametryzowany za pomocą dwóch kluczowych wskaźników:
*   `maxSurge`: Określa, ile nadmiarowych Podów ponad zadeklarowaną liczbę replik może zostać utworzonych podczas aktualizacji.
*   `maxUnavailable`: Określa, ile Podów może być niedostępnych w trakcie procesu migracji.

```
[Pod v1] [Pod v1] [Pod v1]  --> (Rozpoczęcie Rolloutu) --> [Pod v1] [Pod v1] [Pod v2] (maxSurge=1)
                                                       --> [Pod v1] [Pod v2] [Pod v2]
                                                       --> [Pod v2] [Pod v2] [Pod v2] (Koniec)
```

#### Canary Deployment (Wdrożenie kanarkowe)
Polega na uruchomieniu nowej wersji oprogramowania obok stabilnej wersji produkcyjnej, lecz przy skierowaniu do niej jedynie niewielkiego odsetka ruchu sieciowego. W środowisku Kubernetes realizuje się to najczęściej poprzez współdzielenie etykiet selektora przez dwa różne obiekty typu Deployment (stabilny o dużej liczbie replik oraz testowy o małej liczbie replik). Po zweryfikowaniu poprawności działania wersji testowej, skala wdrożenia stabilnego jest redukowana, a wersja testowa staje się nowym standardem.

### 4.2. Mechanizmy Rollback i automatyczna kontrola stanu
System wersjonowania wdrożeń w Kubernetes pozwala na rejestrowanie historii zmian. W przypadku wykrycia anomalii (np. błędu pętli restartów kontenera – `CrashLoopBackOff`), administrator lub zautomatyzowany skrypt CI/CD może natychmiast wycofać zmiany za pomocą polecenia wycofania (`rollout undo`), przywracając stabilny stan klastra do wskazanej rewizji historycznej. 

Wprowadzenie limitów czasowych na wykonanie procedury aktualizacji pozwala na automatyczną detekcję zawieszonych procesów wdrożeniowych.

---

## 5. Konteneryzacja w chmurze publicznej: Model CaaS

Alternatywą dla zarządzania pełnym klastrem Kubernetes w scenariuszach o mniejszej złożoności lub dla aplikacji monolitycznych jest model **CaaS (Container-as-a-Service)**, realizowany m.in. przez usługę Azure Container Instances.

```
[ Użytkownik ] ---> [ Publiczny adres IP / FQDN (Azure) ] ---> [ Azure Container Instances (Silnik zarządzany) ]
```

### 5.1. Charakterystyka bezserwerowego uruchamiania kontenerów
W modelu tym użytkownik nie zarządza warstwą maszyn wirtualnych ani systemem operacyjnym hosta. Odpowiedzialność za aprowizację zasobów sprzętowych (CPU, RAM), utrzymanie silnika kontenerowego oraz izolację jądra systemu operacyjnego spoczywa na dostawcy chmurowym. Główne cechy tego podejścia to:
*   **Szybkość aprowizacji:** Kontenery są uruchamiane bezpośrednio w odpowiedzi na żądanie API chmurowego, bez narzutu czasowego potrzebnego na konfigurację klastra orkiestracji.
*   **Optymalizacja kosztów:** Rozliczenie opiera się na rzeczywistym zużyciu zasobów (vCPU/pamięć na sekundę działania kontenera), co jest opłacalne przy zadaniach efemerycznych, testowych lub przetwarzaniu wsadowym.
*   **Zintegrowana sieć:** Usługi CaaS oferują natywne przypisywanie publicznych adresów IP oraz automatyczną rejestrację nazw w strefach DNS dostawcy (przypisywanie Fully Qualified Domain Name – FQDN).

### 5.2. Cykl życia zasobów w chmurze
W chmurach publicznych podstawową jednostką organizacyjną jest **grupa zasobów** (ang. *Resource Group*). Stanowi ona logiczny kontener grupujący powiązane usługi (bazy danych, instancje kontenerowe, interfejsy sieciowe). Ułatwia to zarządzanie uprawnieniami, monitorowanie kosztów oraz pozwala na bezproblemowe i kompletne usuwanie całych środowisk aplikacyjnych po zakończeniu ich cyklu życia, minimalizując ryzyko pozostawienia nieużywanych, płatnych zasobów.

---

## Podsumowanie

Przedstawione technologie układają się w spójny stos technologiczny:

1.  **Warstwa sprzętowa i systemowa:** Automatyzowana na poziomie instalacji nienadzorowanej Kickstart.
2.  **Warstwa konfiguracji systemowej:** Standaryzowana deklaratywnie za pomocą kodu Ansible, co gwarantuje idempotentność i powtarzalność środowisk.
3.  **Warstwa uruchomieniowa i orkiestracji:** Zarządzana przez Kubernetes, co pozwala na automatyczne skalowanie, samooczyszczanie klastra oraz bezprzestojowe aktualizacje usług.
4.  **Warstwa Cloud:** Umożliwia elastyczne skalowanie zasobów w modelach bezserwerowych i optymalizację kosztów operacyjnych.

Zrozumienie teoretycznych fundamentów tych mechanizmów takich jak pętla uzgadniania stanu, separacja ruchu sieciowego od instancji obliczeniowych czy paradygmat deklaratywny stanowi klucz do projektowania systemów o wysokiej dostępności i odporności na awarie.