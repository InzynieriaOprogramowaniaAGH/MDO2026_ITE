# Sprawozdanie Zajęcia 04

Mateusz Malaga Gr.2

MM416540

## 1. Zachowywanie stanu między kontenerami

### 1.1 Tworzenie woluminów

![alt text](image.png)

### 1.2 Sklonowanie repozytorium na wolumin wejściowy

![alt text](image-1.png)

**Dlaczego ta metoda?**

| Metoda | Zalety | Wady |
|--------|--------|------|
|Kontener pomocniczy z git | Nie wymaga gita na hoście ani w kontenerze docelowym; w pełni przenośne | Dodatkowy krok |
| Bind mount z lokalnym katalogiem | Proste | Zależy od stanu hosta; niereprodukowalne |
| Kopiowanie do `/var/lib/docker` | Brak dodatkowych kontenerów | Wymaga `sudo`; niebezpieczne; zależne od implementacji |
| Git wewnątrz kontenera bazowego | Wszystko w jednym kontenerze | Kontener musi mieć gita – narusza wymaganie |

Kontener pomocniczy (`alpine/git`) jest efemeryczny (`--rm`) i służy wyłącznie do sklonowania kodu na współdzielony wolumin. Kontener docelowy (budujący) nigdy nie potrzebuje Gita.

### 1.3 Uruchomienie buildu z woluminami

![alt text](image-2.png)
![alt text](image-3.png)
![alt text](image-4.png)
![alt text](image-5.png)

Wynik na woluminie wyjściowym:
![alt text](image-6.png)

Plik `.tgz` jest dostępny na woluminie `vol-output` **po wyłączeniu kontenera** – wolumin persystuje niezależnie od cyklu życia kontenera.


### 1.4 Wariant z Gitem wewnątrz kontenera

Tutaj kontener bazowy ma gita i sam klonuje repo na wolumin:
![alt text](image-7.png)
![alt text](image-8.png)

### 1.5 Dyskusja: `RUN --mount` w Dockerfile

`RUN --mount` (BuildKit) pozwala montować zasoby **wyłącznie podczas budowania obrazu** – nie są one częścią finalnego obrazu

**Różnica wobec woluminów runtime:**
- `RUN --mount` działa **tylko podczas `docker build`** – nie jest dostępne przy `docker run`
- Woluminy (`-v`) działają **podczas `docker run`** – przechowują dane między uruchomieniami kontenera
- `--mount=type=cache` przyspiesza buildy (cache warstw npm/pip bez wbudowywania ich w obraz)

---

## 2. Eksponowanie portów i łączność między kontenerami

### 2.1 Uruchomienie serwera iperf3

![alt text](image-9.png)
![alt text](image-10.png)
![alt text](image-11.png)
![alt text](image-12.png)


Sprawdzenie adresów IP kontenerów.
![alt text](image-13.png)

Uruchomienie testu iperf3 -c 
![alt text](image-14.png)

### 2.3 Dedykowana sieć mostkowa z rozwiązywaniem nazw

Utworzenie własnej sieci poprzez docker network create i uruchomnienie nowych kontenerów z tą siecią.

![alt text](image-15.png)
![alt text](image-17.png)
![alt text](image-19.png)

test z wykorzystaniem nazwy

![alt text](image-18.png)

Rozwiązywanie nazw działa dzięki wbudowanemu DNS Dockera dostępnemu w sieciach użytkownika.

### 2.4 Połączenie spoza kontenera (z hosta)

![alt text](image-20.png)
![alt text](image-21.png)
localhost, ponieważ z punktu widzenia hosta usługa jest dostępna lokalnie na jego własnym porcie 5201.

### 2.5 Połączenie spoza hosta
![alt text](image-36.png)

**Problem z pomiarem przepustowości:**
Komunikacja między kontenerami na tym samym hoście przebiega przez wirtualny interfejs sieciowy (veth), nie przez fizyczną sieć – wyniki rzędu 15-30 Gbits/sec są artefaktem pętli zwrotnej i nie odzwierciedlają rzeczywistej przepustowości sieci.

---

## 3. Usługa SSHD w kontenerze

### 3.1 Uruchomienie SSHD w kontenerze Ubuntu

![alt text](image-22.png)
![alt text](image-23.png)

### 3.2 Połączenie SSH
![alt text](image-24.png)

### 3.3 Zalety i wady SSH w kontenerze

**Zalety:**
- Znany, uniwersalny protokół – działa z każdym klientem SSH
- Możliwość tunelowania portów i przekazywania plików (`scp`, `sftp`)
- Przydatny do debugowania i inspekcji działającego kontenera
- Umożliwia dostęp do kontenera bez Dockera (np. przez Kubernetes exec alternative)

**Wady i zastrzeżenia:**
- **Sprzeczne z filozofią kontenerów** – kontener powinien uruchamiać jeden proces; SSHD to drugi
- Zarządzanie kluczami/hasłami w kontenerze jest problematyczne
- `docker exec` zastępuje SSH w większości przypadków deweloperskich
- Ryzyko bezpieczeństwa – dodatkowa powierzchnia ataku
- Zwiększa rozmiar obrazu i złożoność

**Kiedy SSH w kontenerze ma sens:**
- Środowiska deweloperskie (np. Dev Containers w VS Code)
- Systemy legacy wymagające SSH jako interfejsu
- Gdy brak dostępu do Docker API (np. zdalne środowiska bez `docker exec`)

---

## 4. Jenkins w kontenerze (DIND)

### 4.1 Instalacja Jenkins

utworzenie sieci i woluminów

![alt text](image-25.png)

uruchomienie docker-in-docker **(DIND)**

![alt text](image-26.png)
![alt text](image-27.png)

budowa obrazu jenkis z blue ocean

![alt text](image-28.png)

uruchomienie jenkis

![alt text](image-30.png)

pobranie hasla 
![alt text](image-29.png)

Weryfikacja działających kontenerów
![alt text](image-31.png)

Dostęp do interfejsu
http://10.120.130.27:8080/

![alt text](image-32.png)

insgtalacja sugerowanych wtyczek
![alt text](image-33.png)

tworzenie konta administratora
![alt text](image-34.png)

gotowy jenkins
![alt text](image-35.png)