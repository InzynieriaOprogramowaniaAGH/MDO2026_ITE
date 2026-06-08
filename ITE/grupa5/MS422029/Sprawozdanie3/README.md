# Zbiorowe Sprawozdanie: Technologie Automatyzacji, Orkiestracji i Chmury 

**Autor:** Mateusz Stępień(422029)
**Zakres:** Laboratoria 08 - 12

## 1. Automatyzacja na poziomie systemu operacyjnego

Zanim jakakolwiek aplikacja zostanie uruchomiona, niezbędne jest przygotowanie samego środowiska. Tradycyjne, ręczne instalowanie i konfigurowanie serwerów nie skaluje się w nowoczesnym IT. Do rozwiązania tego problemu służą narzędzia z kategorii *Provisioning* oraz *Configuration Management*.

### Nienadzorowane instalacje (Kickstart) 
**[LAB09]**

* **Jaki problem to rozwiązuje?** Tradycyjna instalacja systemu (np. 100 serwerów z rzędu) wymaga obecności człowieka, który klika "Dalej", wybiera układ klawiatury i partycjonuje dysk. To ogromna strata czasu i ryzyko błędu.
* **Do czego się to stosuje?** Pliki odpowiedzi (takie jak `ks.cfg`) pozwalają na tzw. *Zero-Touch Provisioning*. Zapisujemy w nich raz całą pożądaną konfigurację maszyny. Podajemy ten plik instalatorowi sieciowemu, a serwer instaluje się całkowicie sam – od sformatowania dysku, przez ustawienie sieci, aż po uruchomienie własnych usług systemd (np. automatyczny start Dockera) w sekcji `%post`.

### Zarządzanie konfiguracją (Ansible) 
**[LAB08]**

* **Jaki problem to rozwiązuje?** Gdy mamy już postawione serwery, musimy dbać o to, aby na wszystkich działały te same wersje oprogramowania, poprawne klucze SSH i aktualne biblioteki. Logowanie się ręcznie po SSH na każdą maszynę z osobna, aby wpisać `apt update`, jest nieefektywne.
* **Do czego się to stosuje?** Ansible pozwala zarządzać całymi farmami serwerów z poziomu jednego komputera. Za pomocą plików YAML (Playbooków) deklarujemy, *jaki ma być stan końcowy* (np. "pakiet Nginx ma być zainstalowany"). Ansible sam łączy się z węzłami bez instalowania dodatkowych agentów i wykonuje paczkę zadań. Strukturyzacja kodu w Rolach (Roles) pozwala na reużywalność tych konfiguracji w innych projektach.

---

## 2. Orkiestracja Kontenerów: Kubernetes (K8s)

Zwykły Docker świetnie sprawdza się lokalnie na komputerze programisty, ale uruchomienie pojedynczych kontenerów na serwerach produkcyjnych rodzi problemy z zarządzaniem awariami i nagłymi skokami ruchu sieciowego.

### Wysoka dostępność (High Availability) i Samonaprawianie 
**[LAB10iLAB11]**

* **Jaki problem to rozwiązuje?** Jeśli serwer fizyczny z naszym kontenerem spłonie, albo sam kontener zawiesi się z powodu błędu kodu, aplikacja przestaje działać, a użytkownicy widzą błąd 404.
* **Do czego się to stosuje?** W Kubernetes używamy obiektów typu *Deployment* , w których deklarujemy, że np. chcemy mieć zawsze 4 działające kopie naszej aplikacji rozrzucone po klastrze. Jeśli jedna z instancji zginie, Kubernetes natychmiast to wykryje i automatycznie uruchomi nową, zapewniając nieprzerwane działanie usługi.

### Bezpieczne strategie aktualizacji (Zero-Downtime)
**[LAB11]**

* **Jaki problem to rozwiązuje?** Aktualizacja aplikacji często wiąże się z koniecznością jej zatrzymania, co oznacza przerwę w działaniu dla klientów.
* **Do czego się to stosuje?** K8s natywnie wspiera płynne aktualizacje. System wymienia stare kontenery na nowe partiami, najpierw upewniając się, że nowa wersja wstaje poprawnie. Istnieje też strategia *Canary Deployment*, gdzie puszczamy nową wersję tylko dla ułamka ruchu sieciowego. W razie problemów, system chroni środowisko  i pozwala na natychmiastowe wycofanie zmian jednym poleceniem (`rollout undo`).

### Abstrakcja sieciowa (Serwisy)
**[LAB10iLAB11]**

* **Jaki problem to rozwiązuje?** Pody w Kubernetes są efemeryczne – ciągle powstają i giną, za każdym razem dostając nowy adres IP.
* **Do czego się to stosuje?** Do stworzenia obiektu *Service*. Stanowi on stały, niezmienny punkt dostępowy. Niezależnie od tego, jak klastrowi tasują się adresy IP działających w tle aplikacji, ruch sieciowy jest poprawnie przekierowywany do sprawnych replik.

---

## 3. Infrastruktura w Chmurze Publicznej 

Ostatnim etapem ewolucji jest wyjście poza fizyczne serwerownie i własne maszyny wirtualne (jak np. Minikube w VirtualBoxie).

### Kontenery jako usługa (Azure)
**[LAB12]**

* **Jaki problem to rozwiązuje?** Utrzymanie i zabezpieczanie własnych, fizycznych serwerów oraz klastrów Kubernetes jest niewyobrażalnie drogie i wymaga dedykowanego zespołu administratorów 24/7.
* **Do czego się to stosuje?** Technologie Serverless, takie jak Azure Container Instances (ACI), zwalniają nas z myślenia o sprzęcie. Programistę interesuje tylko wypchnięcie gotowego obrazu na Docker Hub. W chmurze wskazujemy tylko ten obraz, prosimy np. o 1 GB RAM-u i ułamek mocy procesora. Chmura sama dba o to, gdzie i jak to uruchomić, wystawiając usługę od razu pod publicznym adresem (FQDN). Płacimy tu ułamki groszy wyłącznie za sekundy rzeczywistej pracy aplikacji.

---
