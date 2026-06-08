# Sprawozdanie 8-12
## 1. Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible *(Lab8)*

### Przygotowanie środowiska i instalacja
- Maszyna docelowa (ansible-target): W środowisku VirtualBox utworzono minimalistyczną maszynę wirtualną z systemem Ubuntu 26.04 LTS. Zweryfikowano obecność pakietu tar. Wykonano punkt przywracania o nazwie "Czysta instalacja - przed Ansible" oraz wyeksportowano maszynę do pliku ansible-target.ova.
- Maszyna kontrolna: Na maszynie głównej potwierdzono instalację pakietu `ansible [core 2.16.3]`

### Inwentaryzacja i mapowanie sieci (Inventory)
- Mapowanie nazw: Za pomocą hostnamectl ustawiono nazwy hostów: ansible-controller dla maszyny zarządzającej oraz ansible-target dla końcówki. W pliku /etc/hosts powiązano te nazwy z adresami IP 192.168.1.1 oraz 192.168.1.2.
- Plik inventory.ini: Stworzono strukturę inwentarza z podziałem na grupy [Orchestrators] (wskazujący na local) oraz [Endpoints] z zdefiniowanym użytkownikiem ansible_user=ansible. Łączność potwierdzono testem ad-hoc: ansible all -i inventory.ini -m ping.

### Zdalne wywoływanie procedur (Playbooks)

- Testowy ping za pomocą modułu ansible.builtin.ping.

- Kopiowanie pliku inwentaryzacji do katalogu /home/ansible/inventory_backup.ini.

- Aktualizacja pakietów systemowych narzędziem apt (status changed na hoście docelowym).

- Restart usługi sshd oraz próba restartu usługi rngd. Ta druga celowo została zabezpieczona parametrem ignore_errors: yes, dzięki czemu mimo braku usługi w systemie (status fatal), Ansible pomyślnie kontynuował i zakończył wykonywanie playbooka.


### Strukturyzacja ról i zarządzanie artefaktem (Ansible Roles)

- Szkieletowanie: Narzędziem ansible-galaxy role init docker_deploy wygenerowano oficjalną strukturę katalogów dla nowej roli. W pliku meta/main.yml uzupełniono metadane autora oraz licencję MIT:
  - Instalacja środowiska docker.io oraz uruchomienie usługi Docker.

  - Uruchomienie wskazanego kontenera aplikacji.

  - Wykonanie weryfikacji połączenia (Sanity check) – potwierdzone komunikatem końcowym: "Kontener odpowiedzial! Sanity check zaliczony.".

  - Bezpieczne zatrzymanie oraz usunięcie kontenera po zakończonym teście w celu oczyszczenia środowiska.

![](zadanie_final.png)

### Przydatne komendy: 

`sudo hostnamectl set-hostname <nazwa>` - służy do permanentnej zmiany nazwy hosta systemowego

`ssh-copy-id <user>@<host>` - kopiuje klucz publiczny SSH na maszynę docelową, umożliwiając późniejszą autentykację bez podawania hasła

`ansible all -i inventory.ini -m ping` - wywołanie modułu ping na wszystkich (all) hostach zdefiniowanych w pliku inwentaryzacyjnym

`ansible-playbook -i inventory.ini <plik.yml> -K` - uruchomienie przygotowanego scenariusza (playbooka)

`ansible-galaxy role init <nazwa_roli>` - automatyczne generowanie ustrukturyzowanego szkieletu katalogów i plików (w tym `meta/`, `tasks/`, `handlers/`) zgodnego z najlepszymi praktykami współdzielenia kodu w Ansible

## 2. Pliki odpowiedzi dla wdrożeń nienadzorowanych *(Lab9)*

### Generowanie wzorcowej konfiguracji bazowej

- Cel: Aby zautomatyzować instalację systemu na setkach maszyn, najpierw musimy poznać strukturę konfiguracji, jaką generuje instalator systemu.
- Jak zrealizowano: Przeprowadzono instalację systemu Fedora 44 Server. Posłużyło to do przechwycenia pliku /root/anaconda-ks.cfg, który stał się szablonem do dalszej automatyzacji.

### Dostosowanie pliku Kickstart do wymogów produkcyjnych

Celem było stworzenie pliku odpowiedzi, który przeprowadzi instalację w 100% samodzielnie, wyczyści dyski, pobierze aktualne pakiety sieciowe i automatycznie przygotuje środowisko pod wybraną aplikację.

Jak zrealizowano:

  - Repozytoria zewnętrzne: Dodano dyrektywy url i repo, aby instalator sam dociągał najnowsze pakiety z serwerów lustrzanych.

  - Czyszczenie dysku: Wprowadzono clearpart --all --initlabel w celu bezwarunkowego formatowania dysku – zapobiega to blokowaniu instalatora przez stare partycje.

  - Instalacja Docker: Dopasowano sekcję %packages, aby system od razu po instalacji posiadał zainstalowane środowisko kontenerowe.

  - Skrypt post-instalacyjny: Zaimplementowano skrypt aktywujący usługę Docker oraz tworzący procedurę startową aplikacji.

  - Automatyczny restart: Dodano na końcu dyrektywę restartu, aby maszyna po zainstalowaniu była od razu gotowa do pracy, bez czekania na reakcję administratora.


### Zapewnienie automatycznego startu aplikacji na nowym systemie

Środowisko instalatora działa w ograniczonej przestrzeni chroot – nie można tam uruchomić działającego kontenera Docker, bo usługi systemowe jeszcze nie działają. Musieliśmy zaprogramować system tak, aby uruchomił aplikację dopiero po swoim pierwszym pełnym zbootowaniu.

Jak zrealizowano: 

W sekcji %post stworzono skrypt /usr/local/bin/start-my-app.sh (opóźniony o sleep 10 na podniesienie sieci) wykonujący docker run -d --name moja-aplikacja hello-world. Skrypt ten dopisano do crona z flagą @reboot, co gwarantuje jego uruchomienie przy każdym starcie maszyny.

### Sieciowe wdrożenie nienadzorowane i weryfikacja
Cel: Aby zasilić nową, czystą maszynę wirtualną plikiem odpowiedzi bez fizycznego przenoszenia go na pendrive/dysku.

Jak zrealizowano:
Na maszynie kontrolnej uruchomiono serwer HTTP (python3 -m http.server 80), aby sieciowo udostępnić plik konfiguracji.

Efekt finalny - połączenie z główną maszyną:

![](fedora1logi.png)

![](fedorafinal.png)

## 3. Wdrażanie na zarządzalne kontenery: Kubernetes (1) *(Lab10)*

### Uruchomienie lokalnego środowiska Kubernetes (Minikube)

Celem jest stworzenie odizolowanego, bezpiecznego środowiska testowego, które wiernie odwzorowuje działanie chmury obliczeniowej oraz klastra produkcyjnego Kubernetes na pojedynczej stacji roboczej.

- Jak zrealizowano: Zainstalowano narzędzie minikube (wersja v1.38.1) oraz skonfigurowano alias minikubctl do komunikacji z klastrem.

- Wykazanie bezpieczeństwa: Środowisko uruchomiono z parametrem --driver=docker. Zapewnia to pełną izolację kontenerową – wszystkie procesy i worker Kubernetes działają wewnątrz odrębnej sieci i dedykowanego kontenera Docker, przez co aplikacja jest widoczna wyłącznie lokalnie na maszynie i nie ingeruje w system gospodarza.

- Weryfikacja łączności: Stan węzłów klastra potwierdzono poleceniem minikubctl get nodes oraz poprzez uruchomienie graficznego panelu minikube dashboard, prezentującego status klastra przez interfejs HTTP.

### Weryfikacja działania aplikacji w strukturze Podu (Wdrożenie manualne)

Aby manualnie przetestować, czy przygotowany obraz poprawnie integruje się z podstawową jednostką obliczeniową Kubernetes (Podem) oraz czy ruch sieciowy prawidłowo dociera do wnętrza klastra.

Jak zrealizowano: 

- Uruchomienie: Poleceniem minikubctl run stworzono pojedynczy Pod o nazwie moja-web-aplikacja, mapując go na port 80 i nadając etykietę rozpoznawczą.
- Wystawienie usługi: Ponieważ pody działają w zamkniętej sieci, do celów testowych wykorzystano mechanizm mapowania portów: minikubctl port-forward pod/moja-web-aplikacja 8081:80.
- Efekt: Przeglądarka pod adresem localhost:8081 wyświetliła naszą stronę, udowadniając integralność sieciową klastra

### Automatyzacja, skalowanie i wysoka dostępność

Ręczne zarządzanie pojedynczymi Podami uniemożliwia automatyczne skalowanie i nie zapewnia odporności na awarie. Cel zakładał przejście na model deklaratywny za pomocą pliku konfiguracyjnego YAML oraz zapewnienie wysokiej dostępności poprzez powielenie instancji aplikacji.

Jak zrealizowano: 

- Skalowanie (Deployment): Przygotowano plik deployment.yaml o strukturze kind: Deployment, gdzie zadeklarowano parametr replicas: 4. Konfigurację wdrożono komendą minikubctl apply -f deployment.yaml. Status operacji sprawdzono przez rollout status, a polecenie get pods wykazało 4 niezależnie pracujące, stabilne kopie aplikacji realizujące założenie redundancji.

- Udostępnianie (Service): W celu stworzenia jednego, stałego punktu dostępowego dla wszystkich replik, wyeksponowano wdrożenie jako obiekt typu Service poleceniem minikubctl expose ... --type=NodePort --name=moja-aplikacja-serwis.

- Tunelowanie portów: Za pomocą sekcji portów w VS Code przekierowano ruch z serwisu na lokalny port 8082. Poprawność wdrożenia całego klastra potwierdzono pomyślnym wyświetleniem aplikacji w przeglądarce pod adresem localhost:8082.

![](4-wdrozenie.png)

![](4-strona.png)


## 4. Wdrażanie na zarządzalne kontenery: Kubernetes (2) *(Lab11)*

### Weryfikacja skalowalności i elastyczności klastra
Systemy produkcyjne muszą dynamicznie reagować na zmiany natężenia ruchu (np. nagły skok liczby użytkowników lub okno serwisowe). Cel polegał na zbadaniu elastyczności klastra i zdolności do natychmiastowej alokacji zasobów bez przerywania pracy systemu.

Jak zrealizowano:
- Wykorzystano mechanizm imperatywnego skalowania w locie za pomocą polecenia minikubctl scale. Przeprowadzono pełen cykl zmian
  - Zwiększono liczbę replik do 8 w celu obsługi dużego obciążenia.

  - Zredukowano liczbę replik do 1, a następnie do 0 (całkowite wygaszenie środowiska w celu oszczędności zasobów).

  - Przywrócono stabilny stan docelowy 4 działających replik.

### Zarządzanie wersjonowaniem i wycofywaniem zmian
Aktualizacje oprogramowania niosą ryzyko błędów. Cel zakładał opanowanie mechanizmu śledzenia historii poprawek oraz natychmiastowego cofnięcia wadliwej aktualizacji w celu minimalizacji przestojów produkcyjnych.

Jak zrealizowano: 
- Aktualizacja (v2): Podniesiono wersję obrazu komendą minikubctl set image do stanu moja-aplikacja:v2.

- Historia: Polecenie minikubctl rollout history potwierdziło zarejestrowanie dwóch rewizji.

- Wycofanie poprawnie działającej wersji: Poleceniem minikubctl rollout undo przywrócono stabilną wersję v1.

- Test awarii (v3-bad): Zbudowano specjalny, uszkodzony obraz v3-bad z błędną komendą startową CMD ["zepsuj-serwer"]. Po jego wdrożeniu Kubernetes wykrył awarię aplikacji – pody natychmiast przeszły w stan Error oraz CrashLoopBackOff, co dowodzi sprawnego działania mechanizmów ochronnych klastra.

### Automatyczna kontrola poprawności wdrożeń
Administrator lub potok CI/CD musi automatycznie wiedzieć, czy nowa wersja aplikacji wstała pomyślnie, czy też uległa awarii, blokując potok wdrożeniowy w przypadku przekroczenia limitu czasu (Timeout).

Jak zrealizowano:
- Napisano skrypt powłoki weryfikuj.sh wykorzystujący komendę minikube kubectl -- rollout status ... --timeout=60s. Skrypt poprawnie przeszedł testy: dla wersji v1 zwrócił sukces (Poprawne wdrożenie), a dla wadliwej wersji v3-bad przerwał działanie po 60 sekundach z kodem błędu (Przekroczenie limitu 60 sekund lub awaria!), co umożliwia integrację tego kroku z Jenkinsami.

### Różne strategie wdrażania aplikacji
Wybór strategii wdrożenia decyduje o tym, jak aplikacja zachowuje się podczas aktualizacji z punktu widzenia użytkownika końcowego. Przetestowano trzy podejścia

**Recreate** - Stosowana, gdy aplikacja nie może działać w dwóch różnych wersjach jednocześnie (np. z powodu blokad bazy danych). Pody są usuwane jednocześnie, a klaster na moment zostaje z zerem działających aplikacji, po czym stawia nowe pody.

![](4-recreate.png)


**Rolling Update** - Zapewnienie ciągłości działania usługi i całkowity brak przestojów dla użytkowników podczas aktualizacji. Kubernetes najpierw powołuje 1 dodatkowy pod dla jednej wersji po aktualizacji, potem gasi 2 stare pody a na ich miejsce wstawia kolejne nowe.

![](4-rolling.png)


**Canary Deployment** - Bezpieczne testowanie nowej wersji oprogramowania na małej grupie realnych użytkowników przed pełnym wdrożeniem. Jeden serwis rozdziela ruch między dwa niezależne zdrożenia:
![](4-canary.png)

## 5. Wdrażanie na zarządzalne kontenery w chmurze (Azure) *(Lab12)*

### Publikacja i dostęp do chmury
Udostępnienie aplikacji globalnie i uzyskanie uprawnień do zarządzania zasobami dostawcy.

Jak zrealizowano: 
- Wypchnięto obraz do rejestru komendą docker push wwachel/node-app:latest oraz zalogowano się do subskrypcji akademickiej Azure for Students przez az login --use-device-code.

### Izolacja zasobów
Kontrola kosztów (zgodnie z cennikiem ACI) oraz porządek w infrastrukturze poprzez spięcie sieci i kontenerów w jedną grupę administracyjną.

Jak zrealizowano: 
- Ustawiono zmienne środowiskowe (region polandcentral, domena wiktoria-node-app-2026) i stworzono grupę poleceniem az group create --name $RG --location $LOC.

### Wdrożenie bezserwerowe
Natychmiastowe uruchomienie aplikacji bez kosztów i narzutu na konfigurację oraz utrzymanie maszyn wirtualnych (model Serverless).

Jak zrealizowano:
- Uruchomiono kontener komendą az container create, przydzielając 1 rdzeń CPU, 1.5 GB RAM oraz otwierając produkcyjny port 3000.

### Weryfikacja działania usługi
Potwierdzenie, że chmura prawidłowo wystawiła aplikację do internetu i powiązała rekordy DNS.

Jak zrealizowano:
- Sprawdzono status przez az container show (wynik: Succeeded). Aplikacja odpowiedziała komunikatem "Hello World!" pod publicznym adresem http://wiktoria-node-app-2026.polandcentral.azurecontainer.io:3000.

![](5_webpage.png)

### Czyszczenie i retencja kosztów
Uniknięcie ciągłego naliczania opłat i bezproduktywnego zużywania darmowych kredytów studenckich po zakończeniu testów.

Jak zrealizowano:
- Całkowicie usunięto całą grupę zasobów asynchronicznym poleceniem az group delete --name $RG --yes --no-wait.