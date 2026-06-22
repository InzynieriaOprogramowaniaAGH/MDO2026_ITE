# Sprawozdanie zbiorcze z laboratoriów 8–12

## Automatyzacja wdrożeń i konteneryzacja aplikacji

**Artur Niemiec**

## 1. Wprowadzenie

Laboratoria 8–12 obejmowały kolejne etapy przygotowania i wdrażania środowiska aplikacyjnego: automatyzację konfiguracji serwerów, instalację nienadzorowaną systemu operacyjnego, uruchamianie aplikacji w Kubernetesie, obsługę strategii aktualizacji oraz publikację kontenera w chmurze Azure.

Wspólnym motywem wszystkich ćwiczeń było odejście od ręcznej konfiguracji na rzecz powtarzalnych, opisanych w plikach procedur. Takie podejście ogranicza liczbę błędów administracyjnych, ułatwia odtwarzanie środowiska i pozwala szybciej przechodzić od czystej maszyny do działającej aplikacji.


# 2. Laboratorium 8 – Automatyzacja z wykorzystaniem Ansible

Ansible jest narzędziem służącym do automatyzacji konfiguracji systemów. Działa w modelu bezagentowym, co oznacza, że na maszynach zarządzanych nie trzeba instalować dodatkowego klienta. Komunikacja odbywa się najczęściej przez SSH, a administrator opisuje zadania w plikach YAML.

W ramach laboratorium przygotowano maszynę zarządzającą `ansible-master` oraz maszynę docelową `ansible-target`. Skonfigurowano logowanie SSH bez hasła z użyciem klucza publicznego oraz przygotowano plik inventory określający hosty i sposób połączenia.

W pierwszej kolejności wykonano test komunikacji przy użyciu modułu `ping`:

```bash
ansible all -m ping -i inventory.ini
```

Obie maszyny odpowiedziały statusem `SUCCESS`, co potwierdziło poprawność konfiguracji sieci i SSH.

![Test komunikacji Ansible](/grupa4/AN420700/sprawozdanie8/img/8s3.png)

Następnie wykorzystano polecenia ad-hoc oraz playbooki Ansible do wykonywania operacji administracyjnych, takich jak:

* kopiowanie plików,
* aktualizacja pakietów,
* restart usług systemowych.

Istotnym elementem ćwiczenia było sprawdzenie idempotentności playbooków, czyli możliwość wielokrotnego uruchamiania tego samego playbooka bez niepotrzebnego powtarzania zmian, które zostały już wykonane.

Dodatkowo utworzono własną rolę Ansible odpowiedzialną za instalację Dockera, uruchomienie kontenera oraz automatyczną weryfikację działania aplikacji HTTP.

![Wykonanie playbooka](/grupa4/AN420700/sprawozdanie8/img/8s4.png)

# 3. Laboratorium 9 – Instalacje nienadzorowane Kickstart

Instalacja nienadzorowana pozwala uruchomić system operacyjny bez ręcznego odpowiadania na pytania instalatora. W dystrybucjach opartych o rodzinę Red Hat, takich jak Fedora, służy do tego mechanizm Kickstart. Jego podstawą jest plik odpowiedzi `ks.cfg`, który zawiera informacje o partycjonowaniu, użytkownikach, sieci, pakietach oraz komendach wykonywanych po instalacji.

Najpierw wykonano ręczną instalację Fedory, aby uzyskać przykładowy plik `/root/anaconda-ks.cfg`. Następnie plik został zmodyfikowany tak, aby automatycznie konfigurował system, tworzył użytkownika, czyścił dysk oraz pobierał pakiety z repozytoriów.

W sekcji `%post` przygotowano automatyczną instalację Dockera oraz usługę systemd odpowiedzialną za uruchamianie kontenera po pierwszym uruchomieniu systemu.

Plik `ks.cfg` został udostępniony przez prosty serwer HTTP. Poprawność konfiguracji zweryfikowano poprzez pobranie pliku przy użyciu polecenia `curl`. Podczas uruchamiania instalatora Fedora plik został wskazany parametrem:

```text
inst.ks=http://192.168.2.11:8000/ks.cfg
```

![Uruchomienie instalacji Kickstart](/grupa4/AN420700/Sprawozdanie9/img/9s2.png)

Po zakończeniu instalacji nowy system był gotowy do pracy bez konieczności wykonywania dodatkowych czynności konfiguracyjnych.

![Weryfikacja działania systemu po instalacji](/grupa4/AN420700/Sprawozdanie9/img/9s4.png)
![Weryfikacja działania systemu po instalacji](/grupa4/AN420700/Sprawozdanie9/img/9s5.png)
![Weryfikacja działania systemu po instalacji](/grupa4/AN420700/Sprawozdanie9/img/9s6.png)

# 4. Laboratorium 10 – Wdrażanie aplikacji w Kubernetes

Kubernetes jest systemem orkiestracji kontenerów. Umożliwia automatyczne skalowanie aplikacji, monitorowanie ich stanu oraz realizację aktualizacji bez konieczności ręcznej ingerencji administratora. Zamiast zarządzać pojedynczymi kontenerami ręcznie, definiuje się obiekty opisujące stan docelowy aplikacji. Najważniejsze z nich to `Pod`, `Deployment` oraz `Service`.

`Pod` jest najmniejszą jednostką uruchomieniową w Kubernetesie. `Deployment` zarządza replikami Podów i dba o to, aby ich liczba była zgodna z deklaracją. `Service` pełni rolę stabilnego punktu dostępowego do aplikacji. Dzięki temu użytkownik nie komunikuje się bezpośrednio z Podami, których adresy IP mogą zmieniać się podczas restartów lub aktualizacji.

W celach testowania dostęp do aplikacji realizowano przy pomocy mechanizmu port-forwarding. Polega on na przekierowaniu lokalnego portu na port działającego Poda lub Service w klastrze Kubernetes.

W ramach laboratorium uruchomiono lokalny klaster Minikube. Następnie przygotowano prostą aplikację HTTP opartą na obrazie `nginx:alpine`. Obraz został zbudowany lokalnie i załadowany do Minikube.

Aplikację najpierw uruchomiono jako pojedynczy Pod, aby sprawdzić poprawność obrazu i komunikacji. Następnie przygotowano plik `deployment.yml`, w którym zadeklarowano 4 repliki aplikacji.

![Deployment z czterema replikami](/grupa4/AN420700/Sprawozdanie10/img/s10.png)

Po wdrożeniu aplikacji utworzono `Service` typu `ClusterIP`. Dostęp do aplikacji z poziomu maszyny lokalnej uzyskano przez port-forwarding:

```bash
kubectl port-forward service/k8s-lab-app 8080:80
```

Test przez `curl` potwierdził, że aplikacja odpowiada poprawnie po HTTP.

![Test aplikacji przez Service](/grupa4/AN420700/Sprawozdanie10/img/s12.png)

# 5. Laboratorium 11 – Aktualizacje i strategie wdrożeń Kubernetes

To laboratorium rozwijało poprzednie ćwiczenie o zarządzanie cyklem życia aplikacji. W praktycznych środowiskach produkcyjnych samo uruchomienie aplikacji nie wystarcza. Trzeba jeszcze umieć aktualizować ją bez długich przestojów, wycofywać błędne wersje oraz kontrolować proces rolloutów.

Przygotowano trzy wersje obrazu aplikacji:

- `lab11-app:v1` – wersja stabilna,
- `lab11-app:v2` – wersja zaktualizowana,
- `lab11-app:broken` – wersja celowo uszkodzona.

Na początku wdrożono aplikację w wersji `v1`, a następnie skalowano liczbę replik do różnych wartości: 8, 1, 0 i ponownie 4. Pokazało to, że Kubernetes automatycznie tworzy lub usuwa Pody, aby osiągnąć stan zadeklarowany w pliku deploymentu.

Następnie wykonano aktualizację obrazu z `v1` do `v2`. Domyślna strategia `RollingUpdate` wymienia Pody stopniowo, dzięki czemu aplikacja może pozostać dostępna podczas wdrożenia.

W dalszej części wdrożono celowo uszkodzony obraz. Kontenery kończyły działanie błędem, a rollout nie zakończył się poprawnie. Sprawdzono historię wdrożeń, a następnie wykonano rollback:

Mechanizm rollback pozwala przywrócić poprzednią wersję deploymentu zapisanej w historii rolloutów. Dzięki temu błędne wdrożenia mogą zostać szybko wycofane bez ręcznej rekonstrukcji konfiguracji.

```bash
kubectl rollout undo deployment/lab11-app
```

![Rollback wdrożenia](/grupa4/AN420700/Sprawozdanie11/img/s12.png)

Porównano również trzy strategie wdrożeń. 
### Recreate
usuwa stare Pody przed utworzeniem nowych, co jest proste, ale może powodować chwilową niedostępność.
### RollingUpdate
stopniowo wymienia stare Pody na nowe i jest bezpieczniejsze dla aplikacji wymagających ciągłości działania.

![RollingUpdate Update](/grupa4/AN420700/Sprawozdanie11/img/s16.png)

### Canary Deployment
zmniejsza ryzyko aktualizacji poprzez kierowanie jedynie części ruchu do nowej wersji aplikacji przed pełnym wdrożeniem.

W ćwiczeniu canary zrealizowano przez dwa osobne deploymenty: stabilny z 3 replikami oraz testowy z 1 repliką. Oba były wybierane przez wspólny Service na podstawie tej samej etykiety aplikacji.

![Canary Deployment](/grupa4/AN420700/Sprawozdanie11/img/s18.png)

# 6. Laboratorium 12 – Kontenery w Microsoft Azure

Ostatnie laboratorium przenosiło aplikację kontenerową ze środowiska lokalnego do chmury publicznej. Zamiast samodzielnie zarządzać klastrem Kubernetes, wykorzystano usługę Azure Container Instances. Jest to model uruchamiania kontenerów, w którym dostawca chmury zarządza infrastrukturą, a użytkownik dostarcza obraz kontenera oraz podstawową konfigurację zasobów.

Najpierw lokalny obraz został otagowany nazwą zgodną z repozytorium Docker Hub:

```bash
docker tag k8s-lab-app:1.0 mrntex/k8s-lab-app:1.0
```

Następnie obraz wypchnięto do Docker Hub:

```bash
docker push mrntex/k8s-lab-app:1.0
```

Po publikacji obrazu utworzono grupę zasobów w Azure oraz instancję kontenera z publicznym adresem IP i nazwą DNS. Azure uruchomił kontener na podstawie obrazu z Docker Hub i przypisał mu publiczny endpoint.

Stan kontenera sprawdzono poleceniem `az container show`. Kontener znajdował się w stanie `Running`, co oznaczało poprawne wdrożenie.

![Status kontenera w Azure](/grupa4/AN420700/Sprawozdanie12/img/s5.png)

Następnie wykonano test HTTP przez `curl`, korzystając z publicznej nazwy DNS przydzielonej przez Azure. Aplikacja zwróciła stronę HTML, co potwierdziło, że usługa jest dostępna z zewnątrz.

![Test HTTP w Azure](/grupa4/AN420700/Sprawozdanie12/img/s6.png)

Po zakończeniu ćwiczenia pobrano logi kontenera, zatrzymano go, usunięto instancję oraz całą resource group. Jest to ważny etap pracy w chmurze, ponieważ pozostawione zasoby mogą generować koszty.

---

# 7. Wnioski

Zrealizowane laboratoria pokazały pełny przepływ pracy charakterystyczny dla współczesnego DevOps. Proces zaczyna się od automatycznego przygotowania systemu operacyjnego, następnie obejmuje konfigurację środowiska, budowę obrazu kontenera, wdrożenie aplikacji oraz jej utrzymanie.

Najważniejszym wnioskiem jest znaczenie deklaratywnego opisu infrastruktury. W Ansible opisuje się oczekiwany stan pakietów, plików i usług. W Kickstart opisuje się końcową konfigurację zainstalowanego systemu. W Kubernetesie opisuje się oczekiwaną liczbę replik, wersję obrazu oraz sposób udostępnienia aplikacji. Dzięki temu środowisko można odtworzyć w powtarzalny sposób.

Drugim ważnym elementem jest obserwowalność i kontrola wdrożenia. Samo uruchomienie aplikacji nie wystarcza. Należy sprawdzać logi, status Podów, odpowiedzi HTTP, historię rolloutów oraz poprawność działania Service. Laboratorium z błędnym obrazem pokazało, że Kubernetes nie eliminuje błędów aplikacji, ale daje narzędzia do ich szybkiego wykrycia i wycofania.

Ostatecznie laboratoria 8–12 tworzą logiczny ciąg: automatyczna instalacja systemu, automatyczna konfiguracja, konteneryzacja, orkiestracja oraz wdrożenie w chmurze. Są to podstawowe elementy praktycznego procesu budowy i utrzymania aplikacji w środowiskach produkcyjnych.
