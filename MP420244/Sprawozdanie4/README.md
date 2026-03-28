# 1. Woluminy

## Kopiowanie repozytorium

Woluminy tworzone są pojedynczym poleceniem:
* `docker volume create (nazwa woluminu)`

![Tworzenie woluminów](images/1.%20Tworzenie%20woluminów.png)

Utworzone woluminy trafiają do lokalnego folderu: `var/lib/docker/volumes`

W celu umieszczenia repozytorium w woluminie wejściowym **vol-in**, przeniesiono je do odpowiedniego folderu w plikach lokalnych dokera: `var/lib/docker/volumes/vol-in/_data`

![Repozytorium w woluminie](images/2.%20Repozytorium%20w%20woluminie.png)

Następnie kontener został uruchomiony i zamontowano w nim folder, przechowujący pliki z woluminu:
* `docker run --mount type=volume, src=vol-in, dst=/repo -it --name kont ubuntu:latest`
`--mount`: flaga montująca folder
`type=volume`: folder będzie zawierać treść woluminu
`src=vol-in`: źródło to wolumin **vol-in**
`dst=/repo`: pliki zostaną umieszczone w folderze `/repo` w kontenerze

![Uruchomienie kontenera z woluminem](images/3.%20Uruchomienie%20kontenera%20z%20woluminem.png)

Żeby zapisać pliki do woluminu wyjściowego **vol-out** użyte zostało następujące polecenie:
* `docker run --rm --volumes-from kont -v vol-out:/to ubuntu:latest sh -c "cp -r /repo/. /to"`
`docker run --rm`: uruchamia tymczasowy kontener
`--volumes-from kont`: udostępnia woluminy kontenera **kont**
`-v vol-out:/to`: montuje wolumin wyjściowy w kontenerze tymczasowym w folderze `/to`
`sh -c "cp -r /repo/. /to"`: kopiuje pliki do woluminu wyjściowego

![Kopiowanie repo do woluminu wyjściowego](images/4.%20Kopiowanie%20repo%20do%20woluminu%20wyjściowego.png)

Żeby skopiować pliki do woluminu wejściowego wystarczy sklonować repozytorium do folderu `/repo`, ponieważ jest to punkt zamontowania woluminu z powodu wywołanego wcześniej polecenia: `docker run --mount`

![Kopiowanie repo do woluminu wejściowego](images/5.%20Kopiowanie%20repo%20do%20mounted%20katalogu%20woluminu%20wejściowego.png)

## Utylizacja Dockerfile do transferu plików między kontenerami i woluminami

Dockerfile służy do tworzenia obrazów, które następnie są wykorzystywane do tworzenia kontenerów. Kopiowanie plików między woluminami a uruchomionymi kontenerami to akcja dynamiczna w czasie *runtime*, co stoi w kontrze ze statyczną naturą Dockerfile. Do tego zadania najlepiej służą polecenia, możliwe do umieszczenia w skryptach, które będą otwarcie odwoływać się do woluminów i zamontowanych folderów, które mogą ulegać nagłym zmianom.

Natomiast, jeżeli pliki nie zmieniają się często (np. podlegają kontroli wersji git), Dockerfile jest solidnym rozwiązaniem. Kopiowanie tych samych plików jest na tyle powtarzalne, że może zostać wplecione w obraz.

# 2. IPERF

## Test kontener - kontener (IP)

Żeby móc skorzystać z usługi iperf w kontenerze, należy ją najpierw zainstalować: `apt update && apt-get install iperf3`

Ustanawiając połączenie między kontenerami, należy odczytać ich adresy za pomocą polecenia: `docker inspect (nazwa kontenera) | grep IPAddress`

![Adresy IP kontenerów](images/6.%20Adresy%20IP%20kontenerów.png)

Żeby przetestować przepustowość połączenia, jeden kontener musi pełnić rolę serwera, a drugi klienta. Odpowiadają temu odpowiednie polecenia:

* `iperf3 -s`: uruchomienie nasłuchującego serwera iperf3

![Serwer iperf](images/7.%20Serwer%20iperf.png)

* `iperf3 -c (adres kontenera)`: rozpoczęcie testu między klientem a serwerem pod podanym adresem

![Klient iperf](images/8.%20Klient%20iperf.png)

Przepustowość wyniosła 44.6 Gb/s.

## Test kontener - kontener (docker network)

Zamiast wyszukiwać adresy kontenerów, można do połączenia wykorzystać ich nazwę, dzięki wbudowanemu w Docker narzędzie do tworzenia własnych sieci: `docker network`.

Najpierw należy stworzyć sieć: `docker network create -d bridge (nazwa sieci)`
`-d bridge`: określenie, że typ sieci to most

Następny krok to dodanie kontenerów do nowo utworzonej sieci: `docker network connect (nazwa sieci) (nazwa kontenera)`

Kiedy oba kontenery znajdują się w nowej sieci, można przeprowadzić kolejny test przepustowości:

![Serwer iperf + most](images/9.%20Serwer%20iperf%20+%20most.png)

![Klient iperf + most](images/10.%20Klient%20iperf%20+%20most.png)

Przepustowość wyniosła 45.5 Gb/s. Wynik jest bardzo podobny do poprzedniego, ponieważ wszystkie kontenery domyślnie należą do wspólnej sieci Dockera.

## Test host - kontener

Test iperf wygląda identycznie jak w przypadku połączenia międzykontenerowego. Bez dodatkowej konfiguracji możliwe jest połączenie się z serwerem w kontenerze - wystarczy znać jego adres IP.

![Serwer iperf z hosta](images/11.%20Serwer%20iperf%20z%20hosta.png)

![Klient iperf z hosta](images/12.%20Klient%20iperf%20z%20hosta.png)

Przepustowość wyniosła ok. 44.3 Gb/s. Transfer jest przeprowadzany lokalnie na urządzeniu, więc wynik nie ulega dużej zmianie.

## Test nie-host - kontener

Połączenie się urządzenia z poza maszyny wirtualnej do serwera na kontenerze w VM-ie jest jak najbardziej możliwe, tylko wymaga odpowiedniej konfiguracji środowiska:
* Sieć VM musi być ustawiona na `bridged`. NAT też jest możliwą opcją, ale należy dodatkowo ustalić port forwarding;
* Uruchomić VM ponownie;
* Zweryfikować czy adres VM jest poprawny. W przypadku sieci mostkowanej powinien mieć postać: **192.168.XX.XX**;
* Uruchomić kontener w następujący sposób: `docker run -it -p 5201:5201 --name (nazwa kontenera) (obraz)`.
`-it`: zapewnienie TTY
`-p 5201:5201`: otwarcie portu na nadchodzące połączenie (5201 dla iperf)

Polecenie `docker ps` wyświetla pracujące kontenery i ich otwarte porty:

![Otwarty port iperf](images/15.%20Otwarty%20port%20iperf.png)

Jeżeli wszystko działa poprawnie, możliwe jest rozpoczęcie testu:

![Serwer iperf z poza hosta](images/13.%20Serwer%20iperf%20z%20poza%20hosta.png)

Polecenie ze strony klienta (nie-hosta) różni się nieco od pozostałych. Żeby połączyć się do serwera w kontenerze, należy podać adres maszyny wirtualnej: `iperf3 -c (adres VM-a)`. Otwarcie portu na poziomie kontenera umożliwia połączenie się z nim z zewnątrz maszyny wirtualnej przez jej adres.

![Klient iperf z poza hosta](images/14.%20Klient%20iperf%20z%20poza%20hosta.png)

Tym razem przepustowość spadła do 1.56 Gb/s. Jest to spowodowane wydłużeniem ścieżki łączącej klienta z serwerem. Oprócz Dockera, sygnał musi przejść także przez VM, który jest bardzo ograniczony zasobowo.

# 3. SSH

Żeby użyć SSH w kontenerze, należy pobrać usługę: `apt update && apt-get install openssh-server`
Polecenie pobierze demona SSH, który zostanie umieszczony na ścieżce `/usr/sbin/sshd`

Następnie:
* Stworzyć folder `/run/sshd` w kontenerze. Jest on potrzebny do uruchomienia demona;
* Ustalić hasło **root-a** przy pomocy `passwd root`;
* Skonfigurować opcje protokołu w pliku `etc/ssh/sshd_config`:
`PermitRootLogin yes`: umożliwienie połączenia się przez SSH jako root;
`PasswordAuthentication yes`: umożliwienie połączenia się za pomocą hasła;
* Stworzyć kontener w następujący sposób: `docker run -it -p 22222:22 --name (nazwa kontenera) (nazwa obrazu)`.
`-p 22222:22`: otwarcie portu 22222 dla protokołu SSH

*Numer portu jest dowolny; w tym przypadku wybrano 22222*

Po wykonaniu powyższych kroków, kontener będzie gotowy do nawiązania połączenia SSH. Żeby się połączyć, należy uruchomić demona w kontenerze: `/usr/sbin/sshd`; po czym nawiązać połączenie ze strony klienta: `ssh (nazwa użytkownika kontenera)@(adres VM-a) -p (otwarty port)`. Nazwa użytkownika odwołuje się do wnętrza kontenera, a adres do maszyny wirtualnej. Z tego powodu potrzebna jest konfiguracja nasłuchującego portu kontenera.

Po podaniu hasła ustalonego w kontenerze, połączenie zostaje nawiązane:

![Połączenie SSH do kontenera](images/16.%20Połączenie%20SSH%20do%20kontenera.png)

# 4. Jenkins

Żeby skorzystać z serwisu Jenkins należy najpierw zainstalować obraz `jenkins/jenkins:latest`:

![Pobranie obrazu Jenkins](images/17.%20Pobranie%20obrazu%20Jenkins.png)

Do konfiguracji serwera potrzebny jest również obraz `docker` (dind), do wykonywania poleceń dokera wewnątrz węzłów Jenkins:

![Pobranie obrazu dind](images/18.%20Pobranie%20obrazu%20dind.png)

Następnie, zgodnie z dokumentacją, należy wywołać polecenie:
```
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
  ```

Uruchomi to pierwszy kontener, nasłuchujący na porcie 2376. Żeby sprawdzić czy działa poprawnie, można wejść w przeglądarkę pod adres `http://localhost:2376`:

![Przeglądarka](images/19.%20Przeglądarka.png)

Ta akcja jest odnotowana w konsoli:

![Konsola](images/20.%20Konsola.png)


Kolejnym krokiem jest konfiguracja drugiego kontenera. Najpierw należy stworzyć plik Dockerfile o następującej treści:

```
FROM jenkins/jenkins:2.541.3-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"
```

Następnie na jego podstawie zbudować obraz: `docker build -t myjenkins-blueocean:2.541.3-1 .`

Na końcu uruchomić drugi kontener, bazując na stworzonym obrazie:
```
docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.541.3-1
```

Jeżeli wszystko przebiegło prawidłowo, powinny działać dwa kontenery:

![Urzuchomione kontenery Jenkins](images/21.%20Uruchomione%20kontenery%20Jenkins.png)

Żeby przejść do serwisu Jenkins, należy przejść pod adres `http://localhost:8080`.
Hasło znajduje się na ścieżce `/var/jenkins_home/secrets/initialAdminPassword` kontenera `entrypoint` (udostępniającego port 2376). Po podaniu hasła na stronie, otwiera się ekran powitalny:

![Zalogowanie do Jenkins](images/22.%20Zalogowanie%20do%20Jenkins.png)

Serwer jest gotowy do konfiguracji z poziomu przeglądarki.