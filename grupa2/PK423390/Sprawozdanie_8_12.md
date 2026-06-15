# Sprawozdanie zbiorcze - Laboratoria 8-12

---

## Laboratorium 8 - Automatyzacja i zdalne wykonywanie poleceń za pomocą Ansible

### 1. Konfiguracja połączenia SSH

Ansible działa bezagentowo - cała komunikacja z maszynami docelowymi odbywa się przez SSH, dlatego pierwszym krokiem było ustawienie logowania bez hasła. Klucz publiczny z maszyny głównej przesłano na maszynę docelową (`ansible-target`, 192.168.0.101):

```bash
ssh-copy-id ansible@192.168.0.101
```

Po stronie maszyny głównej zainstalowano Ansible z repozytorium dystrybucji.

![ssh-copy-id i konfiguracja](L8/IMG/Zrzut%20ekranu%202026-05-15%20061311.png)
![Wersja Ansible](L8/IMG/Zrzut%20ekranu%202026-05-15%20062003.png)

### 2. Inwentarz i pierwszy test

Plik `inventory.ini` podzielono na dwie grupy:

```ini
[Orchestrators]
localhost ansible_connection=local

[Endpoints]
192.168.0.101 ansible_user=ansible
```

`Orchestrators` to maszyna sterująca - `ansible_connection=local` pozwala wykonywać na niej zadania bez przechodzenia przez stos SSH. `Endpoints` to maszyna zarządzana.

```bash
ansible all -i inventory.ini -m ping
```

Moduł `ping` nie jest klasycznym ICMP - sprawdza, czy Ansible jest w stanie zalogować się po SSH, uruchomić mały skrypt w Pythonie i odebrać poprawną odpowiedź JSON. Obie maszyny zwróciły `SUCCESS`.

![ansible ping - SUCCESS](L8/IMG/Zrzut%20ekranu%202026-05-15%20062304.png)

### 3. Pojedyncze polecenia ad-hoc

Przed napisaniem playbooka przetestowano kilka pojedynczych modułów z linii komend:

```bash
# kopiowanie pliku
ansible Endpoints -i inventory.ini -m copy -a "src=inventory.ini dest=/tmp/inventory.ini"

# aktualizacja pakietów (z podniesieniem uprawnień)
ansible Endpoints -i inventory.ini -m apt -a "update_cache=yes" -b -K

# restart usługi
ansible Endpoints -i inventory.ini -m service -a "name=ssh state=restarted" -b -K
```

Przy pierwszym kopiowaniu pliku status to `CHANGED`. Przy ponownym uruchomieniu tej samej komendy Ansible zwrócił `ok` - plik już istniał i był identyczny, więc nic nie zostało zmienione. To pierwszy praktyczny przykład idempotentności: ten sam efekt niezależnie od liczby uruchomień.

Przy próbie restartu usługi `rngd`, której nie ma na maszynie docelowej, polecenie zakończyło się błędem (`Could not find the requested service rngd: host`).

![kopiowanie pliku - CHANGED/ok](L8/IMG/Zrzut%20ekranu%202026-05-15%20062539.png)
![apt update na Endpoints](L8/IMG/Zrzut%20ekranu%202026-05-15%20063343.png)
![restart sshd](L8/IMG/Zrzut%20ekranu%202026-05-15%20063545.png)

### 4. Playbook zbierający wszystkie operacje

Powyższe komendy ad-hoc zebrano w jednym playbooku `playbook_system.yml`, dodając flagę `ignore_errors: true` przy zadaniu z `rngd`, żeby błąd nie przerwał całego przebiegu:

```yaml
---
- name: Zdalne wywolywanie procedur systemowych
  hosts: Endpoints
  become: true
  tasks:
    - name: 1. Wyslij zadanie ping do wszystkich maszyn
      ping:

    - name: 2. Skopiuj plik inwentaryzacji na maszyne Endpoints
      copy:
        src: inventory.ini
        dest: /tmp/inventory.ini

    - name: 3. Ponow operacje kopiowania (porownaj roznice)
      copy:
        src: inventory.ini
        dest: /tmp/inventory.ini

    - name: 4. Zaktualizuj pakiety w systemie
      apt:
        update_cache: yes

    - name: 5. Zrestartuj uslugi sshd
      service:
        name: ssh
        state: restarted

    - name: 6. Zrestartuj uslugi rngd
      service:
        name: rngd
        state: restarted
      ignore_errors: yes
```

Przy uruchomieniu zadanie 3 (powtórne kopiowanie) zwróciło `ok` zamiast `changed`, co potwierdza wcześniejszą obserwację. Zadanie 6 zgłosiło `FAILED`, ale zostało zignorowane i playbook dokończył się normalnie.

![Uruchomienie playbooka - widoczne ok/changed i zignorowany fail](L8/IMG/Zrzut%20ekranu%202026-05-15%20065213.png)

### 5. Rola Ansible - wdrożenie kontenera

Do zarządzania bardziej rozbudowanym zestawem zadań stworzono rolę:

```bash
ansible-galaxy role init deploy_app
```

W pliku `roles/deploy_app/tasks/main.yml` zapisano cały proces: sprawdzenie czy maszyna odpowiada, instalację Dockera, uruchomienie usługi Docker, przygotowanie katalogu roboczego, wygenerowanie Dockerfile na miejscu (przez moduł `copy` z treścią inline), zbudowanie obrazu, uruchomienie kontenera, weryfikację odpowiedzi HTTP modułem `uri`, a na końcu usunięcie kontenera.

```yaml
- name: 5. Stworzenie Dockerfile - Artefakt
  copy:
    dest: /tmp/app_build/Dockerfile
    content: |
      FROM nginx:alpine
      RUN echo "<h1>Laboratorium 8 - Ansible i Docker</h1>" > /usr/share/nginx/html/index.html

- name: 6. Zbudowanie obrazu - Requirement Build
  command: docker build -t moja-apka:v1 /tmp/app_build/

- name: 7. Uruchomienie kontenera - Requirement Run
  command: docker run -d -p 8080:80 --name final-app moja-apka:v1

- name: 8. Weryfikacja lacznosci - Requirement Verify
  uri:
    url: "http://localhost:8080"
    status_code: 200
  register: result

- name: 9. Oczyszczenie - zatrzymanie kontenera - Requirement Cleanup
  command: docker rm -f final-app
  ignore_errors: yes
```

Cały przebieg zakończył się raportem `ok=10 changed=7 unreachable=0 failed=0`.

![Wynik wykonania roli deploy_app](L8/IMG/Zrzut%20ekranu%202026-05-15%20071001.png)

**Podsumowanie:** różnica między pojedynczymi komendami ad-hoc a playbookiem/rolą jest taka jak między poleceniami w terminalu a skryptem - playbook można uruchomić ponownie w każdej chwili i otrzyma się ten sam efekt końcowy, niezależnie od stanu wyjściowego maszyny.

---

## Laboratorium 9 - Pliki odpowiedzi dla wdrożeń nienadzorowanych

### 1. Punkt wyjścia - instalacja referencyjna

Żeby nie pisać pliku Kickstart od zera, najpierw przeprowadzono normalną, ręczną instalację Fedora Server 44 (`Fedora-Server-dvd-x86_64-44-1.7.iso`) w VirtualBox (2048 MB RAM, 20 GB dysk, sieć NAT). Po jej zakończeniu system sam zapisuje wszystkie dokonane wybory w pliku `/root/anaconda-ks.cfg` - to właśnie ten plik posłużył jako szkielet do dalszej pracy.

![Ekran instalatora Fedory](L9/IMG/Zrzut%20ekranu%202026-05-28%20214409.png)
![Wybór dysku / partycjonowanie](L9/IMG/Zrzut%20ekranu%202026-05-28%20214527.png)
![Trwająca instalacja](L9/IMG/Zrzut%20ekranu%202026-05-28%20220313.png)
![Koniec instalacji referencyjnej](L9/IMG/Zrzut%20ekranu%202026-05-28%20220445.png)

### 2. Co dopisano do pliku odpowiedzi

Wyeksportowany `anaconda-ks.cfg` zawierał już podstawową konfigurację (klawiatura, strefa czasowa, użytkownicy), ale wymagał ręcznych poprawek, żeby instalacja przebiegła w pełni automatycznie i dała system gotowy do pracy:

- dodanie repozytoriów Fedory 44 (`url`, `repo`), bo domyślne mogły nie wskazywać na odpowiednią wersję
- `clearpart --all`, żeby instalator nie zatrzymywał się na pytaniu o istniejące partycje
- ustawienie hostname na `fedora-l9`
- dodanie pakietów potrzebnych do dalszej pracy: `docker`, `docker-compose`, `wget`, `curl`
- sekcja `%post`, w której włączono Docker (`systemctl enable docker`) i przygotowano serwis systemd `nginx-app.service` startujący kontener `nginx:alpine` na porcie 8080
- `reboot` jako ostatnia instrukcja, żeby system od razu wystartował po instalacji

Tak zmodyfikowany plik wystawiono publicznie jako Gist na GitHubie, żeby instalator mógł go pobrać po HTTP.

### 3. Uruchomienie instalacji z parametrem inst.ks

Druga maszyna wirtualna wystartowała z tego samego obrazu ISO. W momencie pojawienia się menu GRUB wciśnięto `e`, żeby edytować linię bootowania, i dopisano:

```
inst.ks=https://gist.githubusercontent.com/PawelJD/.../anaconda-ks.cfg
```

Od tego momentu instalacja przebiegła całkowicie automatycznie - bez żadnego pytania o język, partycje, użytkowników czy pakiety.

![Edycja linii GRUB z inst.ks](L9/IMG/Zrzut%20ekranu%202026-05-29%20064249.png)
![Instalacja w trakcie - brak interakcji](L9/IMG/Zrzut%20ekranu%202026-05-29%20065835.png)
![Koniec instalacji nienadzorowanej](L9/IMG/Zrzut%20ekranu%202026-05-29%20070003.png)

### 4. Weryfikacja efektu

Po automatycznym restarcie zalogowano się na nowy system. Hostname był już ustawiony na `fedora-l9`, a `docker ps` / `systemctl status nginx-app` pokazały, że kontener nginx wystartował sam, bez żadnej dodatkowej komendy z naszej strony.

**Wniosek:** różnica między tą instalacją a pierwszą (ręczną) sprowadza się do jednego dopisanego parametru w GRUB - całą resztę "zapamiętał" plik Kickstart. To pokazuje, jak można skalować wdrażanie systemów operacyjnych bez powtarzania pracy ręcznej.

---

## Laboratorium 10 - Wdrażanie na zarządzalne kontenery: Kubernetes (1)

### 1. Instalacja minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

Pobraną binarkę zweryfikowano przed instalacją, porównując jej sumę SHA256 z opublikowaną przez Google:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64.sha256
sha256sum minikube-linux-amd64
cat minikube-linux-amd64.sha256
```

![Wersja minikube po instalacji](L10/IMG/Zrzut%20ekranu%202026-06-05%20072038.png)
![Porównanie sum SHA256](L10/IMG/Zrzut%20ekranu%202026-06-05%20072641.png)

Dla wygody dodano alias, bo `minikube kubectl --` jest długie do wpisywania przy każdym poleceniu:

```bash
echo "alias minikubectl='minikube kubectl --'" >> ~/.bashrc
source ~/.bashrc
```

![Alias minikubectl działający](L10/IMG/Zrzut%20ekranu%202026-06-05%20073822.png)

### 2. Start klastra jako zwykły użytkownik

Minikube z driverem Docker odmawia uruchomienia jako root, więc dodano nowego użytkownika i dopisano go do grupy `docker`:

```bash
useradd pablo
passwd pablo
usermod -aG docker pablo
su - pablo
minikube start --driver=docker
```

```bash
minikubectl get nodes
minikube status
```

Po starcie node `minikube` miał status `Ready`, a komponenty `host`, `kubelet` i `apiserver` - `Running`.

![Start klastra minikube](L10/IMG/Zrzut%20ekranu%202026-06-05%20081143.png)
![Node Ready, komponenty Running](L10/IMG/Zrzut%20ekranu%202026-06-05%20081632.png)

### 3. Dashboard przez tunel SSH

`minikube dashboard --url &` uruchomiono w tle. Maszyna hosta nie miała jednak bezpośredniego dostępu do sieci wirtualnej VM (NAT w VirtualBox), więc dodano kartę sieciową typu Host-Only (adres VM: `192.168.56.101`) i połączono się przez tunel:

```bash
ssh -L 41881:localhost:41881 pablo@192.168.56.101
```

Po tunelu dashboard był dostępny lokalnie pod `http://127.0.0.1:41881/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/`.

![Dashboard widoczny przez tunel SSH](L10/IMG/Zrzut%20ekranu%202026-06-05%20083609.png)

### 4. Obraz aplikacji

Wybrano wariant z `nginx:alpine` i podmienioną stroną startową - prosty, stale działający serwer HTTP, idealny do pierwszych testów w Kubernetes:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

```bash
docker build -t apl:latest .
docker run -d -p 8080:80 --name test-app apl:latest
curl http://localhost:8080
```

### 5. Od jednego poda do deploymentu z serwisem

Najpierw przetestowano pojedynczy pod, ręcznie, dla zrozumienia mechanizmu:

```bash
minikube image load apl:latest
minikubectl run apl --image=apl:latest --port=80 --labels app=apl --image-pull-policy=Never
```

Flaga `--image-pull-policy=Never` jest tu kluczowa - bez niej Kubernetes próbowałby pobrać obraz z internetu, a `apl:latest` istnieje tylko lokalnie w minikube.

```bash
minikubectl port-forward pod/apl 8085:80 &
curl http://localhost:8085
```

Po sprawdzeniu, że to działa, ten sam efekt zapisano deklaratywnie w `deployment.yml` z 4 replikami i zastosowano:

```bash
minikubectl apply -f ~/apl/deployment.yml
minikubectl rollout status deployment/api-deployment
minikubectl get pods
```

a następnie wyeksponowano jako serwis `ClusterIP`:

```bash
minikubectl apply -f ~/apl/service.yml
minikubectl port-forward service/apl-service 8086:80 &
curl http://localhost:8086
```

Łącznie w klastrze działało 5 podów - 4 z deploymentu plus 1 manualny pozostały z wcześniejszego testu.

**Wniosek:** kontrast między `minikubectl run` (jednorazowa komenda, łatwo zapomnieć co się uruchomiło) a plikiem `deployment.yml` (jeden plik, który w każdej chwili można odtworzyć) jest dobrze widoczny po przejściu obu ścieżek na tym samym obrazie.

---

## Laboratorium 11 - Wdrażanie na zarządzalne kontenery: Kubernetes (2)

### 1. Trzy warianty obrazu do testów

Na bazie `apl:latest` przygotowano:

```bash
docker tag apl:latest apl:v1
# zmiana index.html (nagłówek "Lab 11 - Zmodyfikowany"), rebuild
docker build -t apl:v2 .
# Dockerfile.bad z CMD ["nieistniejaca-komenda"]
docker build -t apl:v3-bad -f Dockerfile.bad .

minikube image load apl:v1
minikube image load apl:v2
minikube image load apl:v3-bad
```

`apl:v3-bad` ma celowo błędną komendę startową - obraz się zbuduje i pod wystartuje, ale proces wewnątrz natychmiast się wykrzaczy.

![Trzy obrazy widoczne w docker images](L11/IMG/Zrzut%20ekranu%202026-06-09%20221844.png)

### 2. Bazowy deployment i skalowanie

Deployment z 4 replikami `apl:v1`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apl-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: apl
  template:
    metadata:
      labels:
        app: apl
    spec:
      containers:
      - name: nginx-kontener
        image: apl:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
```

```bash
minikubectl apply -f deployment.yml
minikubectl rollout status deployment/apl-deployment
```

![Rollout status - successfully rolled out](L11/IMG/Zrzut%20ekranu%202026-06-09%20222841.png)

Skalowanie odbywa się jedną komendą, bez edycji pliku. Przetestowano cały zakres od 8 replik do 0 i z powrotem do 4:

```bash
minikubectl scale deployment/apl-deployment --replicas=8
minikubectl scale deployment/apl-deployment --replicas=1
minikubectl scale deployment/apl-deployment --replicas=0
minikubectl scale deployment/apl-deployment --replicas=4
```

![8 replik](L11/IMG/Zrzut%20ekranu%202026-06-09%20223106.png)
![1 replika](L11/IMG/Zrzut%20ekranu%202026-06-09%20223214.png)
![0 replik](L11/IMG/Zrzut%20ekranu%202026-06-09%20223319.png)
![Powrót do 4 replik](L11/IMG/Zrzut%20ekranu%202026-06-09%20223453.png)

Przy `--replicas=0` `kubectl get pods` nie pokazuje żadnych podów `apl-deployment`. Kubernetes nie usuwa samego deploymentu, tylko liczbę kopii.

### 3. Aktualizacja obrazu, rollback i awaria

Podmiana obrazu na `apl:v2`:

```bash
minikubectl set image deployment/apl-deployment nginx-kontener=apl:v2
minikubectl rollout history deployment/apl-deployment
```

Ta zmiana zapisała się jako REVISION 2. Cofnięcie:

```bash
minikubectl rollout undo deployment/apl-deployment
minikubectl rollout history deployment/apl-deployment
```

Po cofnięciu w historii pojawiła się REVISION 3, nie usunięcie rewizji 2. Kubernetes zawsze dopisuje nową rewizję, nawet jeśli jej efekt jest "powrotem do starego".

![Historia rewizji 1-3](L11/IMG/Zrzut%20ekranu%202026-06-09%20223631.png)

Następnie ustawiono celowo wadliwy obraz:

```bash
minikubectl set image deployment/apl-deployment nginx-kontener=apl:v3-bad
minikubectl get pods
```

Nowe pody przeszły w `CrashLoopBackOff`/`Error` - obraz startuje, ale nieistniejąca komenda powoduje natychmiastowe zakończenie procesu, a Kubernetes wciąż próbuje go odtworzyć.

```bash
minikubectl rollout undo deployment/apl-deployment
minikubectl get pods
```

Powrót do działającej wersji zajął kilka sekund.

![CrashLoopBackOff dla v3-bad](L11/IMG/Zrzut%20ekranu%202026-06-09%20223713.png)
![Pody Running po rollback](L11/IMG/Zrzut%20ekranu%202026-06-09%20223809.png)

### 4. Skrypt sprawdzający wdrożenie

```bash
#!/bin/bash

DEPLOYMENT="apl-deployment"
TIMEOUT=60

echo "Sprawdzam wdrożenie: $DEPLOYMENT (limit: ${TIMEOUT}s)"

minikube kubectl -- rollout status deployment/$DEPLOYMENT --timeout=${TIMEOUT}s

STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Wdrożenie gotowe."
    exit 0
else
    echo "Wdrożenie nie ukończyło się w czasie ${TIMEOUT}s."
    exit 1
fi
```

Na działającej wersji skrypt zakończył się sukcesem przed limitem. Po podstawieniu `v3-bad` skrypt czekał pełne 60 sekund i zwrócił błąd, bo żaden pod nie osiągnął stanu `Ready`.

![Skrypt - sukces i timeout](L11/IMG/Zrzut%20ekranu%202026-06-09%20224942.png)

### 5. Trzy strategie aktualizacji obok siebie

**Recreate** - najpierw kończą się wszystkie stare pody, potem startują nowe. Przez moment nic nie odpowiada:

```yaml
spec:
  replicas: 4
  strategy:
    type: Recreate
```

```bash
minikubectl apply -f deployment-recreate.yml
minikubectl set image deployment/apl-recreate nginx-kontener=apl:v2
minikubectl get pods -w
```

![Recreate - wszystkie pody Completed, potem ContainerCreating](L11/IMG/Zrzut%20ekranu%202026-06-09%20225611.png)
![Recreate - nowe pody Running](L11/IMG/Zrzut%20ekranu%202026-06-09%20225641.png)

**RollingUpdate** - wymiana podów po kawałku, przy zachowanej dostępności:

```yaml
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 2
      maxSurge: 25%
```

`maxUnavailable: 2` oznacza, że maksymalnie 2 stare pody mogą być wyłączone jednocześnie, a `maxSurge: 25%` dopuszcza jeden dodatkowy pod ponad docelową liczbę. W każdej chwili działają co najmniej 2 pody.

![RollingUpdate - część podów Running, część w wymianie](L11/IMG/Zrzut%20ekranu%202026-06-09%20225941.png)

**Canary** - dwa osobne deploymenty (3 repliki `v1` + 1 replika `v2`, etykiety `version: v1`/`version: v2`) i jeden serwis łapiący pody obu przez wspólny selektor `app: apl-canary`. Przy takim podziale ~25% ruchu trafia do nowej wersji:

![Pody v1 i v2 obok siebie, etykiety version](L11/IMG/Zrzut%20ekranu%202026-06-09%20230641.png)

### Porównanie

| Strategia | Downtime | Tempo | Ryzyko |
|-----------|----------|-------|--------|
| Recreate | Tak | Najszybsza | Wysokie - brak fallbacku w trakcie |
| Rolling Update | Nie | Stopniowa | Niskie - część podów zawsze działa |
| Canary | Nie | Kontrolowana | Minimalne - nowa wersja widzi tylko część ruchu |

**Wniosek:** dobór strategii to kwestia tego, co aplikacja może sobie pozwolić: Recreate jest prosta i szybka, ale wymaga akceptacji przerwy; RollingUpdate i Canary kosztują więcej konfiguracji, ale eliminują ryzyko. Canary dodatkowo pozwala ograniczyć skalę ewentualnej awarii do ułamka ruchu.

---

## Laboratorium 12 - Wdrażanie na zarządzalne kontenery w chmurze (Azure)

### 1. Aktualizacja obrazu na Docker Hub

Obraz `apl:v2` z lab. 11 (z nagłówkiem "Lab 11 - Zmodyfikowany") otagowano pod konto na Docker Hub i wypchnięto:

```bash
docker tag apl:v2 madpapito/apl:v2
docker login
docker push madpapito/apl:v2
```

Logowanie odbyło się metodą web-based (kod jednorazowy + potwierdzenie w przeglądarce). Wszystkie warstwy obrazu zostały wysłane do `docker.io/madpapito/apl`.

![docker push - wszystkie warstwy Pushed](L12/IMG/Zrzut%20ekranu%202026-06-12%20005845.png)

### 2. Cloud Shell i przygotowanie subskrypcji

Po zalogowaniu na portal Azure kontem studenckim (`@student.agh.edu.pl`, subskrypcja Azure for Students) uruchomiono Cloud Shell w trybie Bash. Cloud Shell wyświetlił ostrzeżenie o niezarejestrowanej subskrypcji w usłudze CloudShell. Naprawiono to rejestrując dostawcę:

![Cloud Shell po starcie - ostrzeżenie o rejestracji](L12/IMG/Zrzut%20ekranu%202026-06-12%20010245.png)

Z tego samego powodu (świeża subskrypcja studencka) zarejestrowano też dostawcę Container Instances, bez tego `az container create` zwróciłby błąd o braku dostępu do usługi:

![Status Registered dla Microsoft.ContainerInstance](L12/IMG/Zrzut%20ekranu%202026-06-12%20010751.png)

### 3. Grupa zasobów

![az group create - Succeeded](L12/IMG/Zrzut%20ekranu%202026-06-12%20010509.png)

### 4. Wdrożenie kontenera

```bash
az container create \
  --resource-group rg-pablo-apl \
  --name aci-pablo-apl \
  --image madpapito/apl:v2 \
  --ports 80 \
  --dns-name-label pablo-apl-12345 \
  --location francecentral \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5
```

Azure pobrał obraz z Docker Hub samodzielnie i nie był potrzebny żaden prywatny rejestr (Azure Container Registry). W odpowiedzi przydzielony został adres:

```
pablo-apl-12345.francecentral.azurecontainer.io
```

![Wynik az container create z przydzielonym FQDN](L12/IMG/Zrzut%20ekranu%202026-06-12%20010902.png)

### 5. Czy kontener działa

![Stan kontenera Running](L12/IMG/Zrzut%20ekranu%202026-06-12%20011102.png)

Logi:

```bash
az container logs \
  --resource-group rg-pablo-apl \
  --name aci-pablo-apl
```

W logach widać pełną sekwencję startową nginx (`/docker-entrypoint.sh: Configuration complete; ready for start up`, `nginx/1.31.1`, `start worker processes`).

![Logi kontenera - nginx wystartował poprawnie](L12/IMG/Zrzut%20ekranu%202026-06-12%20011148.png)

W przeglądarce, pod adresem `http://pablo-apl-12345.francecentral.azurecontainer.io`, widoczna była strona z nagłówkiem **"Lab 11 - Zmodyfikowany"**, czyli ten sam obraz, który wcześniej testowano lokalnie w minikube.

![Aplikacja w przeglądarce z nagłówkiem Lab 11 - Zmodyfikowany](L12/IMG/Zrzut%20ekranu%202026-06-12%20011205.png)

### 6. Porządki

Usunięcie grupy zasobów jedną komendą wystarczyło, żeby pociągnąć za sobą kontener i wszystkie powiązane zasoby, osobne usuwanie kontenera nie było konieczne, ale wykonano je też ze względu na kolejność z instrukcji.

![az container delete](L12/IMG/Zrzut%20ekranu%202026-06-12%20011325.png)
![az group delete --no-wait](L12/IMG/Zrzut%20ekranu%202026-06-12%20011333.png)
![ResourceGroupNotFound - grupa usunięta](L12/IMG/Zrzut%20ekranu%202026-06-12%20011411.png)

**Wniosek:** w porównaniu do konfiguracji klastra Kubernetes z lab. 10-11, wdrożenie w ACI to praktycznie jedna komenda, ale za tę prostotę płaci się brakiem skalowania, rollbacku czy strategii wdrożeń, które poznano wcześniej. ACI ma sens tam, gdzie potrzebny jest pojedynczy, krótkotrwały kontener bez narzutu operacyjnego całego klastra.

---

## Podsumowanie

Pięć laboratoriów pokrywa różne poziomy automatyzacji: Ansible (8) automatyzuje konfigurację już działających maszyn, Kickstart (9) automatyzuje samą instalację systemu, a Kubernetes (10-11) i Azure ACI (12) automatyzują uruchamianie i utrzymanie aplikacji w kontenerach, od lokalnego klastra po publiczną chmurę. Charakterystyczne dla wszystkich tych narzędzi jest podejście deklaratywne: opisuje się pożądany stan końcowy (skonfigurowana maszyna, zainstalowany system, działający deployment, uruchomiony kontener w chmurze), a narzędzie samo dba o doprowadzenie do niego, co w praktyce widać było wielokrotnie, np. przy idempotentnych playbookach Ansible czy automatycznym rollbacku w Kubernetes po wykryciu `CrashLoopBackOff`.

Obraz Docker przygotowany w pierwszych laboratoriach (nginx z podmienioną stroną startową) przeszedł przez cały ten cykl, od pojedynczego `docker run`, przez pody i deploymenty w minikube, aż po publicznie dostępny kontener w Azure, co dobrze pokazuje, że ten sam artefakt można wdrażać w bardzo różnych środowiskach bez zmian w jego zawartości.