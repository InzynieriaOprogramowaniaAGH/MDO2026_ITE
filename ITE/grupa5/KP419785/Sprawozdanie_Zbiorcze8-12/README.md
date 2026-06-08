# SPRAWOZDANIE ZBIORCZE 8-12

### Kinga Pytel
 
## Srodowisko uruchomieniowe
    System operacyjny: Ubuntu 24.04 LTS (Maszyna wirtualna "devops")
    Metoda dostepu: Zdalna sesja przez SSH (uzytkownik: karro)
    Silnik kontenerow: Docker 29.2.1
    Projekt testowy: portfinder (jezyk Go) + portfinder-web (nginx z wlasna konfiguracja HTML)
    Edytor kodu: GNU nano / Visual Studio Code polaczony zdalnie (Remote - SSH)
    Narzedzia wirtualizacji: Oracle VirtualBox, Kubernetes (minikube v1.38.1, Kubernetes v1.35.1)
    Rejestr obrazow: Docker Hub (`karro28/portfinder-web`)
    Platforma chmurowa: Microsoft Azure (subskrypcja: Azure for Students)
    Narzedzie zarzadzania: Azure Cloud Shell (Bash) + Azure CLI (`az`)
 
# LABORATORIUM 8
 
## 1. Utworzenie nowej maszyny wirtualnej
 
Utworzono druga maszyne wirtualna z minimalnym zestawem oprogramowania opartym na Ubuntu 26.04 LTS. Podczas instalacji ustawiono hostname `ansible-target` oraz uzytkownika `ansible`. Poprawne uruchomienie i zalogowanie sie do nowej maszyny potwierdzono bezposrednio w konsoli VirtualBox:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 015248.png>)
 
## 2. Instalacja Ansible i wymiana kluczy SSH
 
Na glownej maszynie wirtualnej (`devops`) zainstalowano Ansible z repozytorium dystrybucji. Nastepnie wygenerowano pare kluczy SSH (ED25519) i wymieniono je z uzytkownikiem `ansible` na maszynie docelowej.
 
Wygenerowanie klucza na maszynie `ansible-target` oraz pobranie adresu IP (192.168.1.38):
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 014539.png>)
 
Skopiowanie klucza publicznego do maszyny `ansible-target` i weryfikacja logowania bez hasla:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 014504.png>)
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 014718.png>)
 
Skopiowanie klucza publicznego dla uzytkownika `ansible` i weryfikacja logowania bez hasla:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 015335.png>)
 
## 3. Inwentaryzacja
 
Na glownej maszynie dopisano adres IP maszyny docelowej do pliku `/etc/hosts`, przypisujac jej nazwe `ansible-target`. Dzieki temu mozliwe jest odwolywanie sie do maszyny po nazwie zamiast po adresie IP:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 020151.png>)
 
Stworzono plik `inventory.ini` z sekcjami `[Orchestrators]` (glowna maszyna `devops`) oraz `[Endpoints]` (maszyna docelowa `ansible-target`):
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 020351.png>)
 
Przeprowadzono test lacznosci modulem `ping` do wszystkich hostow. Przy pierwszym uruchomieniu pojawil sie komunikat weryfikacji klucza hosta SSH dla `ansible-target`, potwierdzono polaczenie wpisujac `yes`:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 021539.png>)
 
Po zaakceptowaniu klucza hosta obie maszyny (`devops` i `ansible-target`) zwrocily wynik `SUCCESS` z `"ping": "pong"`:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 021843.png>)
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 021955.png>)
 
## 4. Konfiguracja sudo dla uzytkownika ansible
 
Aby umozliwic Ansible wykonywanie zadan z podwyzszonymi uprawnieniami (`become: yes`) bez podawania hasla, zalogowano sie na maszyne `ansible-target` i dodano uzytkownika `ansible` do sudoers z opcja `NOPASSWD`:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023025.png>)
 
## 5. Playbook - zdalne procedury podstawowe
 
Stworzono plik `playbook_podstawy.yml` realizujacy kilka zadan na maszynach z grupy `Endpoints`: skopiowanie pliku inwentaryzacji, aktualizacja cache pakietow i restart SSH:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 022708.png>)
 
Uruchomienie zakonczylo sie sukcesem. Wynik `changed=3` potwierdza, ze wszystkie trzy operacje faktycznie zmodyfikowaly stan systemu:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023115.png>)
 
Ponowne uruchomienie playbooka pokazuje idempotentnosc - `changed=1` zamiast `changed=3`. Kopiowanie pliku i aktualizacja cache zwrocily `ok`, gdyz stan systemu byl juz zgodny z oczekiwanym. Jedynie restart SSH zawsze powoduje zmiane stanu:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023124.png>)
 
## 6. Test z odpieta karta sieciowa
 
Przeprowadzono probe polaczenia przy odpietej karcie sieciowej maszyny `ansible-target`. Ansible zwrocil blad `UNREACHABLE!` z komunikatem `No route to host`, natomiast polaczenie z `devops` (localhost) zakonczylo sie sukcesem:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023406.png>)
 
## 7. Rola Ansible
 
Stworzono szkielet roli za pomoca narzedzia `ansible-galaxy`:
 
```bash
ansible-galaxy role init deploy_portfinder
```
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023444.png>)
 
W pliku `deploy_portfinder/tasks/main.yml` zdefiniowano zadania: instalacja wymaganych pakietow (ca-certificates, curl, gnupg), dodanie klucza GPG Dockera, dodanie repozytorium Dockera, instalacja Docker CE, dodanie uzytkownika `ansible` do grupy `docker`, skopiowanie artefaktu `portfinder-12.tar.gz`, zaladowanie obrazu Docker i uruchomienie kontenera:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023627.png>)
 
Stworzono plik `wdrozenie.yml` wywolujacy role `deploy_portfinder`:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 023703.png>)
 
## 8. Uruchomienie roli
 
Uruchomienie `ansible-playbook -i inventory.ini wdrozenie.yml` spowodowalo wykonanie wszystkich taskow roli. Docker zostal zainstalowany Ansiblem na maszynie docelowej. Widoczne statusy `changed` dla kluczowych krokow:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 025745.png>)
 
Ponowne uruchomienie playbooka wykazalo idempotentnosc roli - wszystkie wczesniej zainstalowane komponenty zwrocily `ok`. Krok uruchomienia kontenera zwrocil blad `FAILED` z kodem `rc: 125` (Docker probowal pobrac obraz `portfinder-deploy:latest` z Docker Hub zamiast uzywac lokalnie zaladowanego `app-deploy`). Krok mial ustawiony `ignore_errors: yes`, wiec playbook zakonczyl sie wynikiem `ok=11 changed=4 failed=0 ignored=1`. Blad wynika z rozbienznosci nazwy obrazu - korekta polega na ujednoliceniu nazwy tagu w tasku:
 
![8](<../Sprawozdanie8/img/Zrzut ekranu 2026-04-28 033856.png>)
 
## Podsumowanie
 
### Ansible i inwentaryzacja
Ansible umozliwia zarzadzanie wieloma maszynami z jednego miejsca. Plik inwentaryzacji z sekcjami `Orchestrators` i `Endpoints` pozwala precyzyjnie kierowac taski do odpowiednich maszyn. Wymiana kluczy SSH eliminuje potrzebe podawania hasel podczas automatyzacji.
 
### Idempotentnosc playbooku
Kluczowa cecha Ansible jest idempotentnosc - ponowne uruchomienie tego samego playbooka nie zmienia juz skonfigurowanego systemu. Widac to wyraznie w porownaniu pierwszego (`changed=3`) i drugiego (`changed=1`) uruchomienia `playbook_podstawy.yml`.
 
### Wdrozenie artefaktu Docker przez Ansible
Docker zainstalowany Ansiblem na maszynie docelowej umozliwia pelne wdrozenie aplikacji bez manualnej interwencji. Zidentyfikowana rozbiesznosc nazwy obrazu jest trywialna korekcja konfiguracji roli.
 
Glowne zapytania do LLM:
- "Jak skonfigurowac sudo dla uzytkownika ansible bez hasla?"
- "Jak napisac role Ansible instalujaca Docker na Ubuntu?"
Weryfikacja: testowanie polecen bezposrednio w systemie, analiza komunikatow bledow, dokumentacja Ansible.
*Pliki `inventory.ini`, `playbook_podstawy.yml`, `wdrozenie.yml`, `deploy_portfinder/tasks/main.yml` dostepne w katalogu `Sprawozdanie8/lab8_ansible`.*
 
# LABORATORIUM 9
 
## 1. Przygotowanie serwera HTTP z artefaktem
 
Przed rozpoczeciem instalacji nienadzorowanej konieczne bylo udostepnienie pliku odpowiedzi `portfinder-ks.cfg` oraz artefaktu `portfinder-12.tar.gz` przez siec. Na maszynie `devops` uruchomiono prosty serwer HTTP przy uzyciu wbudowanego modulu Pythona:
 
```bash
cd ~
python3 -m http.server 8000 &
```
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 022732.png>)
 
Po poprawnym uruchomieniu serwer wyswietlil komunikat `Serving HTTP on 0.0.0.0 port 8000`, co oznacza dostepnosc pod adresem `http://192.168.1.34:8000/`.
 
## 2. Przygotowanie pliku odpowiedzi Kickstart
 
Do wygenerowania hasha SHA-512 dla hasla uzyto Pythona:
 
```bash
python3 -c "import crypt; print(crypt.crypt('mojehaslo', crypt.mksalt(crypt.METHOD_SHA512)))"
```
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 172735.png>)
 
Wynikiem jest hash w formacie `$6$...`, ktory trafia bezposrednio do dyrektywy `rootpw --iscrypted` w pliku kickstart. Plik odpowiedzi stworzono w edytorze nano - zawiera kompletna konfiguracje instalacji oraz sekcje `%post` odpowiedzialna za instalacje Dockera i pobranie artefaktu:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 022426.png>)
 
## 3. Uruchomienie instalacji nienadzorowanej
 
Przy pierwszej probie instalacji parametr `inst.ks` wskazywal na `http://192.168.1.34:8000/portfinder-ks.cfg`, jednak instalator zwrocil komunikat `Kickstart file /run/install/ks.cfg is missing.`:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 023005.png>)
 
Blad wynikal z tego, ze serwer HTTP nie byl jeszcze uruchomiony lub plik nie byl dostepny. Problem rozwiazano przez upewnienie sie, ze serwer HTTP dziala, a nastepnie ponowne uruchomienie maszyny z poprawnym parametrem.
 
Po uruchomieniu VM z plyty ISO Fedory 44 Server, w menu bootloadera GRUB nacisnieto klawisz `e` i na koncu linii `linux` dodano parametr:
 
```
inst.ks=http://192.168.1.34:8000/portfinder-ks.cfg
```
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 023619.png>)
 
Po poprawnym wskazaniu pliku kickstart instalator Anaconda rozpoczal instalacje nienadzorowana. Widoczny komunikat `Rozpoczynanie instalacji automatycznej` potwierdza poprawne odczytanie pliku:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 023705.png>)
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 030005.png>)
 
## 4. Reczna instalacja Fedory (pobranie anaconda-ks.cfg)
 
Rownoleglie przeprowadzono instalacje reczna Fedory 44 w celu uzyskania bazowego pliku `/root/anaconda-ks.cfg` i zapoznania sie z dostepnymi opcjami konfiguracji. Na ekranie powitalnym wybrano jezyk polski:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 171745.png>)
 
## 5. Weryfikacja po instalacji
 
Po zakonczeniu instalacji i automatycznym restarcie maszyna uruchomila sie jako `fedora-portfinder`. Zalogowano sie jako `root` przez konsole VirtualBox:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 172817.png>)
 
Uruchomiono Dockera i sprawdzono jego status:
 
```bash
systemctl enable --now docker
systemctl status docker
```
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 183220.png>)
 
Artefakt `portfinder-12.tar.gz` pobrano z maszyny `devops` przez HTTP i zaladowano obraz Docker:
 
```bash
wget -q "http://192.168.1.34:8000/MDO2026_ITE/ITE/grupa5/KP419785/Sprawozdanie9/portfinder-12.tar.gz" -O /root/portfinder-12.tar.gz
docker load -i /root/portfinder-12.tar.gz
```
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 185917.png>)
 
Wynik `Loaded image: app-deploy:latest` potwierdza poprawne zaladowanie obrazu Docker z poprzednich laboratoriow.
 
Proba uruchomienia kontenera:
 
```bash
docker run -d --name portfinder --restart=unless-stopped app-deploy
```
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 185943.png>)
 
Kontener uruchomil sie pomyslnie, zwracajac pelny hash ID:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 190011.png>)
 
Sprawdzono liste dzialajacych kontenerow oraz wywolano `docker --help` wewnatrz systemu. Wynik `docker ps` pokazuje pusta tabele - kontener `portfinder` uruchomil sie, wykonal swoje zadanie (wyswietlenie help) i zakonczyl dzialanie, poniewaz `portfinder` (`pf`) to narzedzie konsolowe, a nie serwer. Jest to oczekiwane zachowanie, identyczne jak przy smoke tescie w Laboratorium 5:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 183307.png>)
 
Pelna lista komend Dockera dostepna w systemie, co potwierdza poprawna instalacje:
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 183403.png>)
 
![9](<../Sprawozdanie9/img/Zrzut ekranu 2026-05-05 183413.png>)
 
## Podsumowanie
 
### Plik odpowiedzi Kickstart
Kickstart umozliwia w pelni automatyczna instalacje systemu operacyjnego bez ingerencji uzytkownika. Kluczowe dyrektywy: `text` (tryb tekstowy), `clearpart --all` (czyszczenie dysku), `autopart` (automatyczne partycjonowanie), `network --hostname` (ustawienie nazwy hosta) oraz `%post` (polecenia po instalacji). Dzieki `reboot` na koncu instalacji system restartuje sie automatycznie.
 
### Sekcja %post i ograniczenia instalatora
Sekcja `%post` dziala w chroot na zainstalowanym systemie, ale bez uruchomionego jadra docelowego. Polecenia `docker run` i `systemctl start` nie dzialaja na tym etapie - mozna jednak uzywac `systemctl enable`, ktore tworzy odpowiednie dowiazania symboliczne. Kontener uruchamia sie dopiero przy pierwszym starcie systemu przez zdefiniowany serwis.
 
### Idempotentnosc i powtarzalnosc
Plik kickstart jest samowystarczalny - kazda instalacja tworzy system z dokladnie ta sama konfiguracja.
 
Glowne zapytania do LLM:
- "Jak skonfigurowac serwis systemd uruchamiajacy kontener Docker po starcie systemu w Fedorze?"
- "Jak wygenerowac zaszyfrowane haslo dla rootpw w kickstart?"
Weryfikacja: testowanie polecen bezposrednio w systemie, analiza komunikatow bledow instalatora Anaconda, dokumentacja Kickstart.
*Plik `portfinder-ks.cfg` dostepny w katalogu `Sprawozdanie9`.*
 
# LABORATORIUM 10

## 1. Instalacja klastra Kubernetes (minikube)
 
Binarny plik `minikube-linux-amd64` pobrano ze strony producenta i przetransferowano na maszyne wirtualna `devops` przy uzyciu programu FileZilla (SFTP):
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 082955.png>)
 
Zainstalowano minikube w systemie i zweryfikowano wersje:
 
```bash
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```
 
Wynik potwierdza instalacje wersji `v1.38.1`:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 083052.png>)
 
Klaster uruchomiono z uzyciem sterownika Docker:
 
```bash
minikube start --driver=docker
```
 
Przy pierwszej probie pojawilo sie ostrzezenie o niewystarczajacej pamieci (calkowita pamiec systemu: 1967 MiB). Mimo ostrzezenia klaster uruchomil sie poprawnie. Poniewaz przy kolejnych probach pojawial sie blad uprawnien do gniazda Docker, dodano uzytkownika do grupy `docker`:
 
```bash
sudo usermod -aG docker $USER && newgrp docker
minikube start --driver=docker
```
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 104840.png>)
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 105202.png>)
 
Kolejne uruchomienie (po wlaczeniu addonu Dashboard) zakonczylo sie sukcesem z komunikatem `Done! kubectl is now configured to use "minikube" cluster`:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 110006.png>)
 
Sprawdzono stan wezla i ogolny status klastra:
 
```bash
minikube kubectl -- get nodes
minikube status
```
 
Wezel `minikube` zwrocil status `Ready` z rola `control-plane`. Komponenty `host`, `kubelet`, `apiserver` i `kubeconfig` dzialaja poprawnie:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 112102.png>)
 
Aby uproscic korzystanie z `kubectl`, ustawiono alias i zapisano go w `~/.bashrc`:
 
```bash
alias kubectl="minikube kubectl --"
echo 'alias kubectl="minikube kubectl --"' >> ~/.bashrc
source ~/.bashrc
kubectl get nodes
```
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 112146.png>)
 
## 2. Uruchomienie Dashboard
 
Wlaczono addon Dashboard i uruchomiono go w tle, uzyskujac adres proxy:
 
```bash
minikube dashboard --url &
```
 
Przy pierwszej probie dashboard nie dzialal (komunikat `Exit 112`). Po ponownym uruchomieniu minikube z addonem `dashboard` URL zostal poprawnie wyswietlony:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 163227.png>)
 
Po wlaczeniu addonu i restarcie klastra dashboard zaladowal sie poprawnie:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 190323.png>)
 
URL dashboardu: `http://127.0.0.1:37005/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 191015.png>)
 
Aby udostepnic Dashboard z maszyny fizycznej, uruchomiono `kubectl proxy` z adresem `0.0.0.0`:
 
```bash
kubectl proxy --address='0.0.0.0' --disable-filter=true &
```
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 191953.png>)
 
Dashboard otwarto w przegladarce na maszynie fizycznej pod adresem `192.168.1.34:8001/...`:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 193205.png>)
 
Na poczatku sekcja Workloads byla pusta - zadne wdrozenia nie byly jeszcze uruchomione:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-19 193253.png>)
 
## 3. Analiza posiadanego kontenera i przygotowanie obrazu
 
Projekt `portfinder` to narzedzie CLI, ktore konczy prace natychmiast po wykonaniu, wiec nie nadaje sie bezposrednio do wdrozenia w Kubernetes. Zdecydowano sie na podejscie optymalne: obraz-gotowiec nginx z wlasna konfiguracja nawiazujaca do projektu portfinder.
 
Aby obraz byl dostepny dla Kubernetes bez zewnetrznego registry, skonfigurowano srodowisko Docker w kontekscie minikube:
 
```bash
eval $(minikube docker-env)
```
 
Nastepnie utworzono katalog `nginx-custom` i przygotowano pliki konfiguracyjne:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 172235.png>)
 
Zbudowano obraz:
 
```bash
docker build -t portfinder-web:latest .
```
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 172547.png>)
 
Budowanie zakonczylo sie sukcesem, obraz `portfinder-web:latest` jest dostepny lokalnie w srodowisku minikube:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 173427.png>)
 
## 4. Uruchamianie oprogramowania w Kubernetes
 
Uruchomiono pod z obrazem `portfinder-web:latest`. Flaga `--image-pull-policy=Never` informuje Kubernetes, zeby nie probowal pobierac obrazu z Docker Hub, lecz uzyl lokalnie dostepnego:
 
```bash
kubectl run portfinder-deploy \
  --image=portfinder-web:latest \
  --port=80 \
  --labels app=portfinder-deploy \
  --image-pull-policy=Never
```
 
Pod natychmiast osiagnal status `Running`:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 173717.png>)
 
Przekierowano port 8082 na port 80 poda:
 
```bash
kubectl port-forward pod/portfinder-deploy 8082:80 &
curl http://localhost:8082
```
 
Serwer nginx zwrocil poprawna strone HTML z konfiguracja portfinder:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 173759.png>)
 
## 5. Przekucie wdrozenia manualnego w plik wdrozenia
 
Wdrozenie zapisano jako plik YAML zawierajacy jednoczesnie definicje `Deployment` (4 repliki) i `Service` (typ NodePort). Oba zasoby rozdzielone sa separatorem `---`:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 173844.png>)
 
Zastosowano plik wdrozenia:
 
```bash
kubectl apply -f deployment.yml
```
 
Weryfikacja dzialania przez NodePort:
 
```bash
curl http://$(minikube ip):30080
```
 
Serwer poprawnie zwrocil strone HTML:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 173925.png>)
 
Sprawdzono status rollout deploymentu oraz szczegoly poda manualnego:
 
```bash
kubectl rollout status deployment/portfinder-deployment
kubectl describe pod portfinder-deploy
```
 
Polecenie `rollout status` potwierdzilo pomyslne zakonczenie wdrozenia:
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 174653.png>)
 
![10](<../Sprawozdanie10/img/Zrzut ekranu 2026-05-25 174704.png>)
 
## Podsumowanie
 
Minikube z driverem Docker pozwala uruchomic lokalny klaster Kubernetes bez dedykowanego serwera. Ograniczenie sprzETowe (1967 MiB RAM) spowodowalo ostrzezenie, jednak klaster dzialal stabilnie. Alias `kubectl="minikube kubectl --"` upraszcza codzienna prace - uwaga: alias nie dziala wewnatrz skryptow bash, tam wymagana jest pelna forma polecenia.
 
### Koncepcje Kubernetes
- **Pod** - najmniejsza jednostka wdrozenia; jeden lub wiecej kontenerow wspoldzielacych siec i storage
- **Deployment** - zarzadza zestawem podow, zapewnia zadana liczbe replik i umozliwia rolling update
- **Service** - stabilny punkt dostepu do podow; typ NodePort eksponuje usluge na porcie wezla klastra
- **ReplicaSet** - tworzony automatycznie przez Deployment, pilnuje zadanej liczby replik
Zapytania do LLM:
- "Jak skonfigurowac kubectl proxy zeby Dashboard byl dostepny z zewnatrz VM?"
- "Jak polaczyc Deployment i Service w jednym pliku YAML?"
Weryfikacja: sprawdzenie statusow przez `kubectl get pods` i `kubectl get services`, weryfikacja odpowiedzi HTTP przez curl, widok w Dashboardzie Kubernetes.
*Pliki `deployment.yml`, `Dockerfile`, `index.html` dostepne w folderze `Sprawozdanie10/nginx-custom`.*
 
# LABORATORIUM 11

## 1. Przygotowanie nowych wersji obrazu
 
Aby umozliwic testowanie aktualizacji i wycofywania wdrozen, przygotowano trzy wersje obrazu. Tag `v1` to pierwotna wersja strony, `v2` to wersja z opisem "v2 updated", a `broken` to celowo zepsuta wersja, ktorej uruchomienie konczy sie bledem (np. bledna konfiguracja nginx).
 
Obrazy otagowano i wypchnięto na Docker Hub:
 
```bash
docker tag portfinder-web:v1 karro28/portfinder-web:v1
docker tag portfinder-web:v2 karro28/portfinder-web:v2
docker tag portfinder-web:broken karro28/portfinder-web:broken
docker push karro28/portfinder-web:v1
docker push karro28/portfinder-web:v2
docker push karro28/portfinder-web:broken
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 120000.png>)
 
## 2. Zmiany w deploymencie - skalowanie replik
 
Aktualizowano plik YAML wdrozenia i aplikowano zmiany poleceniem `kubectl apply`. Kolejne kroki skalowania:
 
Zwiekszenie do 8 replik - zmieniono `replicas: 8` w pliku YAML:
 
```bash
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 130000.png>)
 
Zmniejszenie liczby replik do 1:
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 130500.png>)
 
Zmniejszenie liczby replik do 0 (zatrzymanie wszystkich podow):
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 131000.png>)
 
Ponowne przeskalowanie w gore do 4 replik:
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 131500.png>)
 
## 3. Aktualizacja i wycofywanie obrazow
 
Zastosowanie nowej wersji obrazu `v2` - zmieniono `image: karro28/portfinder-web:v2` w pliku YAML:
 
```bash
kubectl apply -f deployment.yml
kubectl rollout status deployment/portfinder-deployment
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 132000.png>)
 
Zastosowanie starszej wersji obrazu `v1` - Kubernetes przeprowadzil rolling update do wersji poprzedniej:
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 132500.png>)
 
Zastosowanie wadliwego obrazu `broken` - pod nie mogl sie uruchomic, pojawil sie status `CrashLoopBackOff`:
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 133000.png>)
 
## 4. Przywracanie poprzednich wersji wdrozen
 
Sprawdzono historie wdrozenia:
 
```bash
kubectl rollout history deployment/portfinder-deployment
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 133500.png>)
 
Wycofanie do poprzedniej wersji:
 
```bash
kubectl rollout undo deployment/portfinder-deployment
kubectl rollout status deployment/portfinder-deployment
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 134000.png>)
 
## 5. Skrypt weryfikujacy wdrozenie
 
Napisano skrypt sprawdzajacy, czy wdrozenie zakonczylo sie w ciagu 60 sekund. Skrypt uzywa `kubectl rollout status --timeout=60s` i sprawdza kod wyjscia:
 
```bash
#!/bin/bash
if minikube kubectl -- rollout status deployment/portfinder-deployment --timeout=60s; then
    echo "Wdrozenie zakonczone sukcesem"
    exit 0
else
    echo "Wdrozenie nie zakonczylo sie w ciagu 60 sekund lub napotkalo blad"
    exit 1
fi
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 134500.png>)
 
## 6. Strategie wdrozenia

Strategia `Recreate` zatrzymuje wszystkie stare pody przed uruchomieniem nowych. Powoduje chwilowa niedostepnosc uslugi, ale gwarantuje, ze nie dzialaja jednoczesnie dwie wersje aplikacji:
 
```yaml
strategy:
  type: Recreate
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 135000.png>)
 
Strategia `RollingUpdate` z parametrami `maxUnavailable: 2` i `maxSurge: 25%` aktualizuje pody stopniowo. Usluga pozostaje dostepna przez caly czas aktualizacji:
 
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 2
    maxSurge: 25%
```
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 135500.png>)

Wdrozenie kanarkowe polega na uruchomieniu nowej wersji tylko dla czesci ruchu. Zdefiniowano dwa osobne Deploymenty z rozna liczba replik, korzystajace z tego samego Service przez wspolna etykiete `app: portfinder`:
 
- `portfinder-stable` z obrazem `v1` (3 repliki)
- `portfinder-canary` z obrazem `v2` (1 replika)
Service balansuje ruch rowno miedzy wszystkimi podami, wiec ~25% ruchu trafia do wersji `v2`:
 
![11](<../Sprawozdanie11/img/Zrzut ekranu 2026-05-26 140000.png>)
 
## Podsumowanie
 
Kubernetes umozliwia zarzadzanie cyklem zycia wdrozen przez mechanizmy skalowania, aktualizacji i wycofywania. Historia wdrozen (`rollout history`) pozwala na natychmiastowe cofniecie do dowolnej poprzedniej wersji. Rozne strategie wdrozenia odpowiadaja roznym potrzebom: `Recreate` zapewnia czystosc wersji, `RollingUpdate` zapewnia ciaglosc dzialania, a wdrozenie kanarkowe pozwala na bezpieczne testowanie nowej wersji na czesci ruchu produkcyjnego.
 
# LABORATORIUM 12

## 1. Przygotowanie kontenera
 
Uzyto webowego flow logowania do Docker Hub. Terminal wyswietlil jednorazowy kod urzadzenia `QMSL-QDCW` i link do strony aktywacji:
 
```bash
docker login
```
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 220444.png>)
 
Kod wprowadzono na stronie `login.docker.com/activate`:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 220423.png>)
 
Po potwierdzeniu tozsamosci urzadzenia:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 220456.png>)
 
Strona potwierdzila pomyslne polaczenie urzadzenia ("Your device is now connected"):
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 220635.png>)
 
W terminalu pojawilo sie potwierdzenie `Login Succeeded`. Ostrzezenie o niezaszyfrowanych danych uwierzytelniajacych w `~/.docker/config.json` jest informacyjne - w srodowisku produkcyjnym nalezy skonfigurowac credential helper:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 220651.png>)
 
Obraz `portfinder-web:v2` z poprzednich laboratoriow otagowano nazwa uzytkownika Docker Hub `karro28` i wypchnięto jako dwa tagi:
 
```bash
docker tag portfinder-web:v2 karro28/portfinder-web:v2
docker tag portfinder-web:v2 karro28/portfinder-web:latest
docker images | grep karro28
```
 
Obraz `b4cf95b67853` o rozmiarze 92.7 MB dostepny pod oboma tagami:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 223022.png>)
 
```bash
docker push karro28/portfinder-web:v2
docker push karro28/portfinder-web:latest
```
 
Push tagu `v2` przeslal wszystkie warstwy. Push tagu `latest` wskazal na te same warstwy (`Layer already exists`). Obraz jest identyczny, roznia sie jedynie tagi:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 223202.png>)
 
Potwierdzono dostepnosc obrazu w publicznym repozytorium `karro28/portfinder-web` na Docker Hub. Tag `latest` widoczny jako ostatnio zaktualizowany:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 223259.png>)
 
## 2. Zapoznanie z platforma Azure
 
Zalogowano sie do Azure Portal przy uzyciu konta studenckiego AGH (`kipytel@student.agh.edu.pl`) z subskrypcja **Azure for Students**. Uruchomiono Azure Cloud Shell (Bash) bezposrednio z poziomu portalu:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 230131.png>)
 
```bash
az account show
```
 
Wynik potwierdza aktywna subskrypcje "Azure for Students" przypisana do konta AGH:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 230617.png>)
 
## 3. Wdrozenie kontenera na Azure
 
Utworzono grupe zasobow. Poczatkowa proba wdrozenia w regionie westeurope zostala odrzucona przez system - prawdopodobnie z powodu restrykcji dla studenckich subskrypcji. Aplikacja zostala z sukcesem uruchomiona w alternatywnym regionie `swedencentral`:
 
```bash
az group create --name KP419785-rg3 --location swedencentral
```
 
Status `"provisioningState": "Succeeded"` potwierdza pomyslne utworzenie grupy zasobow:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 231309.png>)
 
Przed wykonaniem komendy zweryfikowano stan dostawcy uslug kontenerowych:
 
```bash
az provider show -n Microsoft.ContainerInstance --query "registrationState"
```
 
Stan `"Registering"` wskazal, ze dostawca byl jeszcze w trakcie rejestracji. Mimo to polecenie `az container create` zakonczylo sie sukcesem:
 
```bash
az container create \
  --resource-group KP419785-rg3 \
  --name portfinder-kp419785 \
  --image karro28/portfinder-web:latest \
  --dns-name-label portfinder-kp419785-sweden \
  --ports 80 \
  --os-type Linux \
  --cpu 1 \
  --memory 1
```
 
Zwrocony JSON zawiera `"state": "Running"` oraz zdarzenie `"Pulling"` potwierdzajace pobranie obrazu z Docker Hub:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 231408.png>)
 
```bash
az container show \
  --resource-group KP419785-rg3 \
  --name portfinder-kp419785 \
  --query "{Status:instanceView.state, FQDN:ipAddress.fqdn, IP:ipAddress.ip}" \
  --output table
```
 
Logi nginx potwierdzaja poprawne uruchomienie serwera - widoczna inicjalizacja konfiguracji, uruchomienie nginx v1.31.1 na Alpine Linux (srodowisko Azure):
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 231641.png>)
 
Pobrano FQDN i przetestowano dostep przez curl:
 
```bash
FQDN=$(az container show \
  --resource-group KP419785-rg3 \
  --name portfinder-kp419785 \
  --query "ipAddress.fqdn" \
  --output tsv)
curl http://$FQDN
```
 
Serwer zwrocil poprawna strone HTML z wersja v2 obrazu:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 231712.png>)
 
Weryfikacja dostepu przez bezposrednie uzycie FQDN:
 
```bash
curl http://portfinder-kp419785-sweden.swedencentral.azurecontainer.io
```
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 231844.png>)
 
Obie metody potwierdzaja, ze kontener pracuje i serwuje aplikacje HTTP. Strona "Portfinder Deploy - KP419785 v2" jest dostepna publicznie pod adresem DNS przypisanym przez Azure.
 
## 4. Zatrzymanie i usuniecie zasobow
 
```bash
az container stop --resource-group KP419785-rg3 --name portfinder-kp419785
 
az group delete --name KP419785-rg3 --yes --no-wait
```
 
Flaga `--no-wait` powoduje natychmiastowy powrot do promptu. Usuniecie odbywa sie asynchronicznie w tle:
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 231957.png>)
 
Bezposrednio po wydaniu komendy `az group show` zwrocil stan `"provisioningState": "Deleting"`. Po chwili powtorzone zapytanie zwrocilo blad `ResourceGroupNotFound`, potwierdzajac calkowite usuniecie grupy zasobow:
 
```bash
az group show --name KP419785-rg3
# "provisioningState": "Deleting"
 
az group show --name KP419785-rg3
# (ResourceGroupNotFound) Resource group 'KP419785-rg3' could not be found.
```
 
![12](<../Sprawozdanie12/img/Zrzut ekranu 2026-06-01 232016.png>)
 
## Podsumowanie
 
### Docker Hub jako rejestr obrazow
Docker Hub pozwala na publiczne udostepnienie obrazu bez koniecznosci tworzenia prywatnego rejestru w Azure. Wystarczy otagowac obraz nazwa uzytkownika i wykonac `docker push`. Azure Container Instances pobiera obraz bezposrednio z Docker Hub podczas tworzenia kontenera, widoczne w Events jako zdarzenie `"Pulling"`.
 
### Azure Container Instances
ACI to usluga bezserwerowa, nie wymaga konfiguracji klastra ani wezlow (w przeciwienstwie do Kubernetes). Wdrozenie sprowadza sie do jednej komendy `az container create`. Kontener otrzymuje publiczny adres IP i opcjonalna nazwe DNS. Usluga jest rozliczana per sekunda, co czyni ja odpowiednia do krotkich zadan lub demonstracji.
 
### Zarzadzanie kosztami
Kluczowa praktyka jest usuniecie calej Resource Group po zakonczeniu pracy, a nie tylko kontenera. `az group delete --yes --no-wait` usuwa wszystkie zasoby w grupie asynchronicznie. Weryfikacje usuniecia zapewnia `az group show` zwracajace `ResourceGroupNotFound`. Zatrzymanie kontenera (`az container stop`) przed usunieciem grupy jest dobra praktyka, ale samo usuniecie grupy jest operacja wystarczajaca.
 
# Podsumowanie
 
### Ansible 
Ansible umozliwia deklaratywne zarzadzanie konfiguracja wielu maszyn. Idempotentnosc gwarantuje, ze wielokrotne uruchomienie playbooka nie zmienia juz skonfigurowanego systemu. Role ansible-galaxy pozwalaja organizowac i wielokrotnie uzywac kodu automatyzacji. Wymiana kluczy SSH eliminuje potrzebe hasel w automatyzacji.
 
### Instalacja nienadzorowana
Kickstart pozwala w pelni zautomatyzowac instalacje systemu Fedora. Sekcja `%post` wykonuje polecenia po instalacji, ale bez uruchomionego jadra - `systemctl enable` zadziala, `docker run` nie. Samowystarczalny plik `.cfg` gwarantuje powta rzalnosc instalacji.
 
### Kubernetes lokalny
Minikube uruchamia lokalny klaster k8s wewnatrz kontenera Docker. Projekt portfinder jako narzedzie CLI nie nadaje sie do pracy ciaglej - zastosowano obraz nginx z wlasna konfiguracja. `eval $(minikube docker-env)` pozwala budowac obrazy bezposrednio w kontekscie minikube bez zewnetrznego registry.
 
### Kubernetes - zaawansowane zarzadzanie
Rozne strategie wdrozenia (Recreate, RollingUpdate, Canary) odpowiadaja roznym wymaganiom dotyczacym dostepnosci i bezpieczenstwa aktualizacji. `kubectl rollout history` i `kubectl rollout undo` umozliwiaja szybkie przywracanie poprzednich wersji. Wdrozenie kanarkowe pozwala testowac nowa wersje na czesci ruchu.
 
### Azure Container Instances
ACI to najprostsza forma wdrozenia kontenera w chmurze - jedna komenda, publiczny adres DNS, rozliczanie per sekunda. Kluczowe: usuwac cala Resource Group po zakonczeniu pracy, aby nie generowac kosztow. Docker Hub zastepuje prywatne registry - nie trzeba tworzyc ACR w Azure.
 
Glowne zapytania do LLM:
- "Jak skonfigurowac sudo dla uzytkownika ansible bez hasla?"
- "Jak skonfigurowac kubectl proxy zeby Dashboard byl dostepny z zewnatrz VM?"
- "Jak zrealizowac Canary Deployment w Kubernetes bez Istio?"
- "Jak skonfigurowac serwis systemd uruchamiajacy kontener Docker po starcie systemu w Fedorze?"
Weryfikacja: testowanie polecen bezposrednio w systemach, analiza logów i komunikatow bledow, porownanie z oficjalna dokumentacja Ansible, Kubernetes i Azure.
