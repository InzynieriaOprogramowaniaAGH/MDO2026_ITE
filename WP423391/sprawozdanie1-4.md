# Sprawozdanie zbiorcze z pierwszych czterech zajęć
## Wojciech Pieńkowski

# Laboratoriun 1: Wprowadzenie, Git, Gałęzie, SSH
## 1. Bezpieczna komunikacja: Protokół SSH i asymetryczna kryptografia
Secure Shell to fundament bezpiecznego zarządzania zdalnymi serwerami. W przeciwieństwie do protokołu HTTPS, który wymaga każdorazowego podawania danych uwierzytelniających, SSH opiera się na kryptografii klucza publicznego.

W ramach zajęć zrezygnowano ze starszego standardu RSA na rzecz nowszych algorytmów, które oferują wyższy poziom bezpieczeństwa przy krótszej długości klucza. Zastosowanie hasła do klucza prywatnego wprowadziło dodatkową warstwę ochrony – mechanizm two-factor, gdzie wymagane jest posiadanie fizycznego pliku klucza oraz znajomość hasła do jego odblokowania.

## 2. Automatyzacja procesów: Git Hooks
Git Hooks to skrypty wyzwalane przez określone zdarzenia w cyklu życia repozytorium (np. przed commitem, po pushu). Jest to mechanizm typu server-side lub client-side automation.

W zadaniu wykorzystano hooka typu commit-msg. Wykorzystanie wyrażeń regularnych do sprawdzenia, czy każda wiadomość zaczyna się od inicjałów i numeru indeksu, automatyzuje dbanie o porządek w historii zmian.

## 3. Integracja środowiska IDE i transferu plików
Efektywność pracy dewelopera zależy od integracji narzędzi. Skonfigurowanie VS Code do pracy zdalnej oraz menedżerów plików pozwala na edycję kodu bezpośrednio na maszynie wirtualnej przy zachowaniu wygody interfejsu graficznego hosta. 

# Laboratorium 2: Git, Docker
## 1. Instalacja i konfiguracja środowiska Docker
Proces instalacji oparto na natywnych repozytoriach dystrybucji Linux, unikając technologii typu Snap czy Flatpak. Pozwala to na lepszą integrację z jądrem systemu hosta i uniknięcie dodatkowych warstw narzutu (overhead), co jest kluczowe dla wydajności operacji wejścia/wyjścia (I/O). Wykorzystano mechanizm Docker Hub jako centralny rejestr obrazów (Registry), skąd pobierane są gotowe szablony systemów i środowisk runtime.

## 2. Eksploracja obrazów bazowych i środowisk uruchomieniowych
Przeprowadzono analizę różnych typów obrazów:
Minimalistyczne: hello-world, busybox.

Systemowe: ubuntu, fedora.

Specjalistyczne (.NET): sdk, aspnet oraz runtime.
Analiza kodów wyjścia pozwoliła zrozumieć, że kontener żyje tylko tak długo, jak długo działa w nim proces główny.

## 3. Interaktywna praca z kontenerem
Wykorzystanie flag -it umożliwiło przejęcie kontroli nad strumieniami wejścia/wyjścia kontenera.

Izolacja procesów: Porównanie PID 1 wewnątrz kontenera z widokiem procesów na hoście gdzie kontener jest widoczny jako zwykły proces systemowy udowodniło działanie mechanizmu Namespaces.

Zarządzanie stanem: Dokonano aktualizacji pakietów wewnątrz działającej instancji, co pokazało, że zmiany zachodzą jedynie w ulotnej warstwie zapisu kontenera.

## 4. Budowanie obrazów: Mechanizm Dockerfile
Zbudowano własny obraz w oparciu o plik Dockerfile. Jest to deklaratywny opis warstw obrazu, który pozwala na automatyzację budowy środowiska.

Dobre praktyki: Zastosowano instrukcje RUN do instalacji klienta git oraz WORKDIR do ustalenia kontekstu pracy.

Warstwowość: Każda komenda w Dockerfile tworzy nową warstwę, co umożliwia późniejsze keszowanie i oszczędność miejsca na dysku.

Weryfikacja: Kontener uruchomiony z tego obrazu posiadał prekonfigurowane narzędzia oraz sklonowane repozytorium przedmiotowe, co potwierdza poprawność zdefiniowanych instrukcji.

# Laboratorium 3: Kontener jako definicja etapu
## 1. Standaryzacja środowiska budowania
Współczesne projekty programistyczne wymagają specyficznych zestawów narzędzi. Tradycyjne instalowanie ich na systemie hosta prowadzi do tzw. "dependency hell". Wykorzystanie kontenera jako środowiska budowania gwarantuje, że proces make build czy dotnet build zawsze przebiega w identycznym, sterylnym ekosystemie, niezależnie od systemu operacyjnego programisty.

## 2. Izolacja procesu: Build i Test w TTY
Przeprowadzono proces kompilacji i testowania w trybie interaktywnym (-it), co pozwoliło na mapowanie kroków niezbędnych do automatyzacji:

Wybór obrazu bazowego: Dobrano obraz zawierający wymagany runtime.

Zależności: Zidentyfikowano pakiety systemowe niezbędne do poprawnego sfinalizowania budowy, które nie są częścią standardowego repozytorium.

Weryfikacja kodów wyjścia: Testy jednostkowe uruchomione wewnątrz kontenera musiały jednoznacznie zwracać status 0 lub non-zero, co jest fundamentem automatyzacji w systemach CI.

## 3. Automatyzacja wieloetapowa (Dockerfiles)
Zaimplementowano strukturę dwóch plików Dockerfile, co symuluje podział na etapy Build i Test:

Dockerfile 1 (Build): Odpowiada za przygotowanie artefaktów (plików binarnych/skompilowanych). Wynikiem pracy tego obrazu jest gotowy do działania program.

Dockerfile 2 (Test): Bazuje na obrazie z pierwszego kroku. Jego zadaniem jest jedynie uruchomienie suite'y testowej. Dzięki temu separujemy logikę budowania od logiki weryfikacji jakości.

To ostatnie laboratorium, które wspólnie „przeklikaliśmy”, jest najbardziej zaawansowane. Łączy ono izolację danych, sieci i procesów w jeden ekosystem CI/CD.

Oto szczegółowy opis do Twojego sprawozdania z Zajęć 04, podzielony na kluczowe sekcje:

# Laboratorium 4: Dodatkowa terminologia w konteneryzacji, instalacja Jenkins
## 1. Zarządzanie stanem: Woluminy 
Woluminy są preferowane w środowiskach produkcyjnych, ponieważ są niezależne od struktury plików hosta i zapewniają lepszą wydajność na systemach macOS/Windows.

Wynik budowania został zapisany na woluminie wyjsciowy. Dzięki temu, po usunięciu kontenera SDK, gotowa aplikacja pozostała dostępna na hoście i mogła zostać zweryfikowana przez inny, lekki kontener Ubuntu.

## 2. Architektura sieciowa i diagnostyka (iperf3)
Standardowa sieć bridge nie pozwala na odnajdywanie kontenerów po nazwach. W zadaniu stworzono dedykowaną sieć mostkową, która aktywuje wewnętrzny DNS Dockera.

Testy przepustowości:
Komunikacja wewnętrzna: Połączono dwa kontenery w tej samej sieci. Użycie nazw zamiast adresów IP wykazało działanie mechanizmu Service Discovery.

Ekspozycja zewnętrzna: Poprzez mapowanie portu 5201:5201, serwer iperf3 stał się dostępny dla procesów spoza silnika Docker. Testy wykazały przepustowość rzędu 45-50 Gb/s, co potwierdza, że narzut sieciowy Dockera na Linuxie jest pomijalny.

## 3. Konteneryzacja usług systemowych (SSH)
Uruchomienie serwera sshd wewnątrz kontenera Ubuntu wymagało obejścia domyślnych ograniczeń obrazów bazowych.

Zalety: Umożliwia pracę ze starszymi narzędziami do deploymentu, które wymagają protokołu SSH, oraz ułatwia zdalne debugowanie w specyficznych architekturach.

Wady: SSH w kontenerze zwiększa rozmiar obrazu i powierzchnię ataku. Zgodnie z filozofią Dockera, do interakcji należy używać docker exec, a kontenery powinny być traktowane jako niezmienne.

## 4. Wdrożenie serwera CI: Jenkins i DIND Helper
Socket Binding: Kluczowym elementem było zamontowanie gniazda /var/run/docker.sock do kontenera Jenkinsa. Dzięki temu Jenkins, wydając komendy docker build, w rzeczywistości instruuje silnik Dockera zainstalowany na Twoim systemie Ubuntu.

Inicjalizacja: Serwer został uruchomiony z woluminem jenkins_data, co chroni konfigurację przed utratą. Pierwsze logowanie odbyło się przy użyciu hasła wygenerowanego w logach kontenera, co potwierdziło poprawność izolacji standardowego wyjścia procesu.
