# Sprawozdanie 4

Autor: Jan Pawelec

---

# Zachowywanie stanu między kontenerami

## Tworzenie woluminów
Woluminy pozwalają na zapis danych z kontenerów.

![alt text](1_vol_create.png)

## Klonowanie repozytorium na wolumin wejściowy
Użyty został kontnener pomocniczy. Takowy klonuje kod, wysyła go do woluminu i następnie sam się usuwa. Dzięki temu Git nie jest obecny poza tymczasowym kontenerem i nie zaśmieca właściwego rozwiązania.

![alt text](1_volu_clone.png)

## Uruchomienie buildu w kontenerze
Uruchomiono build w tymczasowym kontenerze. Pliki zapisano na folderze /dest w kontenerze wyjściowym.

![alt text](1_vv_build.png)

## Ręczne klonowanie wewnątrz kontenera

![alt text](1_w_clone.png)
![alt text](1_w_clone_wynik.png)

Za pomocą Dockerfile możnaby powyższe działanie uzyskane w kilku komendach streścić. Efekt ten sam, a proces spisany w formie pliku. 

--- 

# Eksponowanie portu i łączność między kontenerami

## Iperf

### Serwer iperf
Wyeksponowano kontener jako serwer iperfa. Następnie sprawdzono jego adres IP.

![alt text](2_iperf_start.png)

![alt text](2_iperf_addr.png)

### Serwer kliencki
Uruchomiono kliencki obraz Ubuntu. 

![alt text](2_iperf_klient.png)

Rozpoczęto test iperf. Uzyskano pokaźne wyniki. Szybkość połączenia na poziomie gigabajtowym.

![alt text](2_iperf_miedzy_serwerami.png)

## Network Create

### Tworzenie sieci
Utworzono sieć mostkową.

![alt text](2_network_create.png)

### Test połączenia z kontenera
Testowano połączenie między kontenerami, ponownie uzyskując przepływ bardzo szybki.

![alt text](2_network_iperf.png)

### Test połączenia z serwera
Test z serwera także dał podobne wyniki. Transfer następował w ramach jednej fizycznej maszyny.

![alt text](2_network_iperf_zewn.png)

Log umieszczono w pliku log_iperf.txt.

---

# Usługi w rozumieniu systemu, kontenera i klastra
Uruchomiono obraz z serwerem ssh.

![alt text](3_ssh_start.png)

Następnie połączono się po ssh.

![alt text](3_polaczenie_po_ssh.png)

Komunikacja ssh to bezpieczny sposób na wymianę danych i pracę na serwerze, jednak w przypadku kontnera istnieją inne narzędzie zaprojektowane specyficznie dla tej technologii. Zdecydowanie łatwiej jest odpalić docker exec -it container bash.

---

# Przygotowanie do uruchomienia serwera Jenkins
Zestawiono sieć pomocniczą. Uruchomiono serwer DinD (Docker in Docker).

![alt text](4_start_dind.png)

Uruchomiono serwer jenkins.

![alt text](4_start_jenkins.png)

Oba kontenery działają poprawnie.

![alt text](4_docker_ps.png)

Uruchomiono przeglądarke i zalogowano się wyłuskanym kluczem do usługi jenkins.

![alt text](4_jenkins_web.png)