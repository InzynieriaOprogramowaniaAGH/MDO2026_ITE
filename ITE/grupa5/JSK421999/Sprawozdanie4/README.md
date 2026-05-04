# Sprawozdanie z laboratorium 4

- **Imię:** Jakub
- **Nazwisko:** Stanula-Kaczka
- **Numer indeksu:** 421999
- **Grupa:** 5

---

## 1. Zachowywanie stanu między kontenerami (Woluminy)

Utworzono woluminy wejściowy i wyjściowy. Sklonowano repozytorium `TypeScript-Node-Starter` na wolumin wejściowy przy pomocy kontenera pomocniczego z Gitem (żeby nie instalować Gita na systemie hosta ani w kontenerze docelowym).

![Tworzenie volume i clone repo](img/tworzenie%20volume%20i%20clone%20repo.jpg)

### Build w kontenerze docelowym
Uruchomiono bazowy kontener `node:20` (bez Gita), podpięto do niego kod z woluminu wejściowego oraz wolumin wyjściowy. Zbudowano kod (`npm run build`) i pliki wynikowe zrzucono na dysk wyjściowy.

![Budowanie operacyjne w docelowym kontenerze](img/budowanie%20w%20temp%20kontenerze.jpg)

### Build z wnętrza jednego kontenera (z Gitem)
Ponowiono proces używając jednego kontenera z zainstalowanym pakietem `git`. Wewnątrz niego sklonowano kod i zbudowano aplikację.

![Skrócona alternatywa podziału na clone z gitem i build](img/alternatywa%20clone%20i%20build%20w%20jednym%20kontenerze.jpg)

### RUN --mount (Dyskusja)
Opcja `RUN --mount=type=bind` w `Dockerfile` ułatwia proces: pozwala zamontować kod tylko na chwilę z hosta podczas budowania kontenera. Zapewnia to oszczędność miejsca – unikamy budowania historii repozytorium i narzędzi gita w docelowym obrazie uruchomieniowym.

---

## 2. Eksponowanie portów z IPerf i sieć nazwana 

Uruchomiono serwer iperf3 w domyślnej sieci bridge i sprawdzono jego IP.

![Serwer iperf w kontenerze](img/uruchomienie%20iperf3.jpg)
![Adresacja domyślna dla bridge](img/znalezienie%20ip%20kontenera%20iperf3.jpg)
![Benchmark na numer ip dla iperf3](img/benchmark%20iperf3%20za%20pomoca%20ip.jpg)

### Własna sieć i rozwiązywanie nazw
Utworzono dedykowaną sieć `docker network create`. Dzięki wbudowanemu w Dockera serwerowi DNS sprawdzono obciążenie bez znajomości IP (wpisując nazwę kontenera).

![Zapięcie sieci i hosta do custom net](img/uruchomienie%20iperf3%20serwer%20na%20nazwanej%20sieci%20docker.jpg)
![Wejście po nazwie w iperf3](img/benchmark%20iperf3%20dla%20nazwanej%20sieci.jpg)

### Łączność spoza hosta
Wystawiono port (`-p`) i przeprowadzono test iperf3 z zewnętrznego komputera niezwiązanego z klastrem Dockera.

![Transmisja z zewnątrz](img/iperf3%20z%20innego%20komputera%20do%20otwartego%20portu%20dockera.jpg)

---

## 3. SSH usługą w kontenerze

Uruchomiono kontener z Ubuntu który posiada ssh. Połączono się z nim z zewnątrz podając hasło:

![Instalowanie ssh](img/ssh%20w%20dockerze.jpg)
![Udane wejście ssh na dockera z innej sieci](img/polaczenie%20sie%20do%20ssh%20w%20dockerze%20z%20zewnetrzego%20komputera.jpg)

### Zalety i wady SSH w Dockerze:
- **Zalety:** Pozwala używać starszych narządzi do skryptowania/wgrywania plików (np. przez SCP) które polegają na portach protokołu SSH do zarządzania wdrożeniami.
- **Wady:** Przeczy architekturze Dockera (1 proces na kontener), powiększa kontener o paczki wielkości przypominającej chmurę pełnowymiarowych systemów OS i poszerza obszar potencjalnego wektora ataku.

---

## 4. Instalacja Jenkins 

Zgodnie z instrukcją, skonfigurowano środowisko dind (Docker in Docker) i zainicjalizowano węzeł CI serwera Jenkins w tej samej sieci dockera. Wykazano uruchomiony instalator oraz główną platformę po logowaniu.

![Deploy Jenkins node](img/jenkins%20docker%20containers%20setup.jpg)
![Panel Jenkins po zalogowaniu](img/working%20jenkins%20dashboard%20(after%20login).jpg)
