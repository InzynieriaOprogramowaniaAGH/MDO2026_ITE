# SPRAWOZDANIE 4

Środowisko uruchomieniowe
System operacyjny: Ubuntu 24.04 LTS (Maszyna wirtualna)
Metoda dostępu: Zdalna sesja przez SSH (użytkownik: karro)
Silnik kontenerów: Docker 27.x
Projekt testowy: portfinder (język Go)

1. Zachowywanie stanu między kontenerami

    Celem zadania jest zbudowanie projektu Go w izolowanym środowisku kontenerowym, w którym kod źródłowy i artefakty budowania są przechowywane niezależnie od cyklu życia kontenera.
    Zgodnie z dokumentacją Dockera, do przechowywania stanu aplikacji wybrano zarządzane woluminy (Named Volumes) zamiast montowania katalogów z hosta (Bind mounts). Woluminy są w pełni zarządzane przez silnik Dockera, niezależne od struktury plików na maszynie wirtualnej hosta i bezpieczniejsze.
    Aby spełnić wymóg zbudowania projektu w środowisku niezawierającym narzędzia Git, wykorzystano podejście z "Kontenerem Pomocniczym" (Helper Container).
    Dzięki temu:
    -kontener budujący nigdy nie ma dostępu do narzędzia Git
    -odpowiedzialności są rozdzielone zgodnie z zasadą single-responsibility
    -środowisko budowania pozostaje czyste i powtarzalne
    Alternatywne podejścia (bind mount z lokalnym katalogiem, kopiowanie do `/var/lib/docker`) odrzucono ze względu na silne powiązanie ze strukturą hosta lub konieczność uprawnień roota na hoście.

Utworzone woluminy vol_in (kod źródłowy) oraz vol_out (wyniki budowania):
![1](<img/Zrzut ekranu 2026-03-23 153954.png>)
Sklonowanie repozytorium na wolumin vol_in przy użyciu kontenera pomocniczego alpine/git (pozwala to na pełną izolacje i czystość środowiska budującego)
![2](<img/Zrzut ekranu 2026-03-23 155553.png>)
Uruchomienie buildu (bez git)
![3](<img/Zrzut ekranu 2026-03-23 155756.png>)
![4](<img/Zrzut ekranu 2026-03-23 155846.png>)
![5](<img/Zrzut ekranu 2026-03-23 160540.png>)
![6](<img/Zrzut ekranu 2026-03-23 160607.png>)
Po usunięciu kontenera budującego, dane na woluminie vol_out są nadal dostępne.
![7](<img/Zrzut ekranu 2026-03-23 160650.png>)
Powtórzenie operacji (Git wewnątrz kontenera)
![8](<img/Zrzut ekranu 2026-03-23 190707.png>)
![9](<img/Zrzut ekranu 2026-03-23 190729.png>)
    ```
    docker volume create vol_in
    docker volume create vol_out 
    docker run --rm -v vol_in:/workspace alpine/git clone https://github.com/doganarif/portfinder.git /workspace/projekt
    docker run -it --rm -v vol_in:/src -v vol_out:/build golang:1.24-alpine sh
    apk add make
    cd /src/projekt
    make build
    cp bin/pf /build/
    docker run --rm -v vol_out:/check alpine ls -la /check
    apk add make git
    git clone https://github.com/doganarif/portfinder.git projekt2
    cd projekt2
    make build
    cp bin/pf /build/
    exit
    ```

    Powyższe kroki z woluminami można zautomatyzować podczas budowania obrazu: zastosowanie RUN --mount=type=bind w pliku Dockerfile pozwala na zamontowanie kodu źródłowego tylko na czas budowania, bez kopiowania go do warstw obrazu. Jest to rozwiązanie optymalne, ponieważ finalny obraz zawiera tylko plik binarny, co drastycznie zmniejsza jego rozmiar i poprawia bezpieczeństwo. 
    Rozwiązanie to wymaga włączonego silnika BuildKit, co jest obecnie standardem w nowoczesnych wersjach Dockera.

2. Eksponowanie portu i łączność między kontenerami
Celem zadania jest zbadanie komunikacji sieciowej między kontenerami przy użyciu narzędzia `iperf3`.
Uruchomiono serwer iperf3, sprawdzono jego IP (172.17.0.3) i połączono się z drugiego kontenera.
![10](<img/Zrzut ekranu 2026-03-23 191055.png>)
Utworzono sieć my-net. Uruchomiono kontenery z flagą --network. Dzięki temu możliwa była komunikacja po nazwie kontenera iperf-server.
![11](<img/Zrzut ekranu 2026-03-23 191113.png>)
![12](<img/Zrzut ekranu 2026-03-23 191538.png>)
![13](<img/Zrzut ekranu 2026-03-23 191552.png>)
![14](<img/Zrzut ekranu 2026-03-23 191954.png>)
![15](<img/Zrzut ekranu 2026-03-23 192008.png>)
![16](<img/Zrzut ekranu 2026-03-23 192209.png>)
![17](<img/Zrzut ekranu 2026-03-23 192237.png>)
Wyeksponowano port 5201 na hosta. Test wykonano komendą iperf3 -c 127.0.0.1.
![18](<img/Zrzut ekranu 2026-03-23 192252.png>)
    ```
    docker run -it --rm --name iperf-server alpine sh -c "apk add iperf3 && iperf3 -s"
    docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' iperf-server
    docker run -it --rm alpine sh -c "apk add iperf3 && iperf3 -c 172.17.0.3"
    docker network create my-net
    docker run -it --rm --name iperf-server --network my-net -p 5201:5201 alpine sh -c "apk add iperf3 && iperf3 -s"
    docker run -it --rm --network my-net alpine sh -c "apk add iperf3 && iperf3 -c iperf-server"
    ```

    Aby uniezależnić komunikację od adresów IP, utworzono dedykowaną sieć my-net. W odróżnieniu od domyślnej sieci bridge, sieci użytkownika w Dockerze mają wbudowany serwer DNS, który umożliwia odwoływanie się do kontenerów po nazwie. Jest to rozwiązanie zalecane w produkcji, ponieważ jest odporne na zmiany adresów IP.

    Wyniki testu iperf3 między kontenerami w sieci my-net pokazały przepustowość na poziomie ok. 6.65 Gbit/s (w domyślnej sieci było to ok. 6.50 Gbit/s). Tak wysoki wynik wynika z tego, że komunikacja odbywa się wewnątrz jednego hosta przez wirtualny interfejs sieciowy (bez fizycznej karty sieciowej). Jest to typowy wynik dla kontenerów na tej samej maszynie.
    Wyeksponowano port 5201 na hosta (-p 5201:5201) i przetestowano połączenie z poziomu hosta komendą iperf3 -c 127.0.0.1. Przepustowość wyniosła ok. 4.18 Gbit/s. Była ona zauważalnie niższa w porównaniu z komunikacją między samymi kontenerami, co w praktyce potwierdza i doskonale obrazuje narzut wydajnościowy (overhead) wprowadzany przez warstwę NAT i mechanizm mapowania portów w Dockerze.

3. Usługi SSH w kontenerze
Zestawiono usługę SSHD w kontenerze bazującym na systemie Ubuntu i udostępniono ją na porcie 2222.
![19](<img/Zrzut ekranu 2026-03-23 194728.png>)
![20](<img/Zrzut ekranu 2026-03-23 200726.png>)
Pomyślnie połączono się z usługą korzystając z hosta:
![21](<img/Zrzut ekranu 2026-03-23 200735.png>)
    ```
    docker run -it --rm --name ssh-server -p 2222:22 ubuntu:24.04 bash
    apt update && apt install -y openssh-server
    echo 'root:testpass' | chpasswd
    /usr/sbin/sshd
    ssh root@127.0.0.1 -p 2222
    ```

    Z punktu widzenia dobrych praktyk konteneryzacji, uruchamianie demona SSH wewnątrz kontenera jest uznawane za anty-wzorzec. Łamie zasadę jednej odpowiedzialności kontenera, zwiększa wagę obrazu oraz otwiera nową powierzchnię ataku dla potencjalnych intruzów. Do debugowania służy natywna komenda docker exec.
    Zaletą i przypadkiem użycia dla SSH w kontenerze może być natomiast stworzenie tzw. "Bastion Host" (bezpiecznego punktu wejściowego do podsieci), środowisk typu Honeypot do łapania ataków, lub utrzymywanie kompatybilności ze starymi agentami systemów CI/CD.
    Uzasadnione przypadki użycia SSH w kontenerze to:
    -Bastion Host - bezpieczny, jednopunktowy punkt wejściowy do izolowanej podsieci kontenerów
    -Honeypot - środowisko pułapkowe do wykrywania i analizowania ataków
    -Legacy CI/CD - kompatybilność ze starymi agentami systemów CI/CD, które komunikują się wyłącznie przez SSH

4. Instancja Jenkins
Zestawiono Jenkinsa z pomocnikiem Docker-in-Docker (DIND), co pozwala agentom Jenkinsa na swobodne budowanie własnych kontenerów.
Uruchomiono kontener docker:dind
![22](<img/Zrzut ekranu 2026-03-23 203609.png>)
Zbudowano własny obraz Jenkinsa (Dockerfile.jenkins) z zainstalowanym klientem Dockera.
![23](<img/Zrzut ekranu 2026-03-23 203738.png>)
![24](<img/Zrzut ekranu 2026-03-23 215048.png>)
![25](<img/Zrzut ekranu 2026-03-23 215104.png>)
![26](<img/Zrzut ekranu 2026-03-23 215148.png>)
![27](<img/Zrzut ekranu 2026-03-23 215219.png>)
![28](<img/Zrzut ekranu 2026-03-23 215243.png>)
Odczytano hasło inicjalizacyjne z logów i pomyślnie zalogowano się do panelu.
![29](<img/Zrzut ekranu 2026-03-23 220002.png>)
![30](<img/Zrzut ekranu 2026-03-23 220039.png>)
![31](<img/Zrzut ekranu 2026-03-23 221103.png>)
![32](<img/Zrzut ekranu 2026-03-23 221124.png>)
![33](<img/Zrzut ekranu 2026-03-24 091411.png>)
Plik `Dockerfile.jenkins` rozszerza oficjalny obraz Jenkinsa o klienta Docker.

    ```
    docker network create jenkins
    docker run --name jenkins-docker --rm --detach --privileged --network jenkins --network-alias docker --env DOCKER_TLS_CERTDIR=/certs --volume jenkins-docker-certs:/certs/client --volume jenkins-data:/var/jenkins_home --publish 2376:2376 docker:dind --storage-driver overlay2
    docker build -t myjenkins-blueocean:2.492.2-1 --file Dockerfile.jenkins .
    docker run --name jenkins-blueocean --restart=on-failure --detach --network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --publish 8080:8080 --publish 50000:50000 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro myjenkins-blueocean:2.492.2-1
    docker ps
    ```

Główne zapytania do LLM: 
"Jak przygotować woluminy i sklonować repozytorium bez Gita w kontenerze budującym?"
"Wyjaśnij różnice w przepustowości iperf3 między kontenerami w tej samej sieci Dockera a komunikacją na linii host kontener."
"Jak poprawnie zestawić usługę SSH w kontenerze z Ubuntu i jakie są wady oraz zalety takiego podejścia?"
Weryfikacja nastąpiła przez uruchamianie i testowanie na maszynie, analizie logów, porównywanie z oficjalną dokumentacją. 


Listing historii zawarty w pliku history.txt