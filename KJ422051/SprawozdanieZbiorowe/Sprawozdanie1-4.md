Sprawozdanie 1 – 4

Lab1:
Połączenie z maszyną wirtualna:
Na uruchomionej maszynie wirtualnej ustawiono regułę – próba wejścia na głównym komputerze na port 2222 skutkuje połączeniem się z portem 22 na maszynie wirtualnej. 
 
Port 22 to domyślny port do obsługi SSH (zdalnego i bezpiecznego dostępu do konsoli).
Na podstawie ustawionej reguły za pomocą komendy - ssh jakarekk@127.0.0.1 -p 2222 zalogowano się poprzez protokół SSH z danym użytkownikiem na adresie 127.0.0.1 (adres, który zawsze wskazuje obecnie używany komputer), używając portu 2222.
 
Instalacja narzędzi:
Poprzez zastosowanie sudo apt update przed instalacją można upewnić, się że pobrana zostanie najnowsza wersja oprogramowania. Polecenie sudo apt install git openssh-client -y (-y pozwala na automatyczne rozpoczęcie instalacji) zainstalowało dwa programy – Git, do zarządzania kodem oraz openssh-client – program pozwalający generować klucze szyfrujące do bezpiecznego łączenia się z serwerami.
Przy obu komendach zastosowane zostało sudo – pozwoliło ono wykonać komendy apt bez wyrzucania błędu. Stosuje się go zawsze przy modyfikacji plików systemowych.
Poprzez Github stworzony został klucz – Personal Access Token, aby później użyć go do połączenia terminala z kontem Github i wykonywania na nim operacji.
	
Konfiguracja kluczy SSH:
Aby nie podawać hasła, przy każdej operacji na repozytorium, wygenerowane zostały klucze SSH – publiczny oraz prywatny.
 
ssh-keygen -t ed25519 -C "Userv" -f ~/.ssh/id_1 -N "" – tworzy klucz typu ed25519 o nazwie id_1, -N ‘’’’ oznacza, że plik nie będzie chroniony dodatkowym hasłem.
Następnie za pomocą cat ~/.ssh/id_1.pub wypisana została zawartość klucza publicznego – ten ciąg znaków należało wkleić na Githubie w zakładce Add new SSH key.
Przy klonowaniu repozytorium za pomocą kluczy SSH zamiast https://... Teraz jest git@.... - git clone git@github.com:..

 

Praca na gałęziach:
W celu ułatwienia współpracy podczas pracowania na jednym kodzie korzysta się z gałęzi – tworzona jest kopia głównego kodu na której każdy może pracować osobno aby później ewentualnie zmiany te wprowadzić na główną gałąź.
Za pomocą cd repo – zmieniono katalog na folder pobranego wcześniej repozytorium. 
- git checkout grupa2 – pobrało i przełączyło gałąź na grupa2,
- git checkout -b .. - -b – oznacza stworzenie nowej gałęzi i od razu wejście na nią

Ustawienia dla commitów:
Za pomocą skryptu napisanego w języku Bash ustawiono zasadę – przy próbie stworzenia commitu jeżeli jego opis nie zaczyna się od podanego inicjału i numeru indeksu to skrypt nie pozwoli wysłać commita i zwróci błąd.
Aby go aktywować należało przenieść skrypt do .git/hooks – jest to ukryty folder gita, pliki tam umieszczone działają automatycznie. Aby plik działał automatycznie należało mu jeszcze nadać uprawnienie do wykonywania się za pomocą chmod +x ….


Lab2:

Instalacja dockera:
Zastosowanie komendy sudo systemctl enable –now docker skutkuje natychmiastowe uruchomienie silnika Docker oraz ustawienie go tak, aby startował automatycznie wraz z systemem.
 

Następnie pobrano i przetestowano następujące obrazy:
Docker run hello-world – standardowy test poprawności instalacji,
Docker run busybox echo „busyboc” – uruchomienie systemu busybox i uruchomienie polecenie echo w celu sprawdzenia poprawności działania
Docker run -it ubuntu bash -c “exit” – pobiera obraz ubuntu i uruchamia powłkę bash, która od razu zostaje zamknięta.

Inspekcja obrazów i plików:
Za pomocą komendy docker images wyświetlono listę pobranych obrazów,
Za pomocą echo $? Sprawdzono kod wyjścia – czy ostatnie polecenie zakończyło się sukcesem
Komenda sudo docker run busybox ls -l uruchomiła kontener Busybox aby wyświetlić listę plików w jego głównym katalogu.

Praca wewnątrz kontenera: 
Polecenie sudo docker run -it busybox pozwala wejść do wnętrza kontenera i pracować w nim jak na osobnym komputerze
 

Zarządzanie kontenerem Ubutnu:
Za pomocą –name została nadana własna nazwa kontenerowi.
 
Aby sprawdzić aktualne procesy na dockerze użyto ps aux.
 

Budowanie Dockerfile:

 
Jest to napisanie skryptu konfiguracyjnego.
FROM ubuntu:22.04 – ustalenie bazy – konkretnej wersji Ubuntu
RUN apt-get install git – instaluje  Git to wewnętrznego obrazu
WORKDIR /app – tworzy I przechodzi do folderu roboczego
RUN git clone .. – pobiera kod z repozytorium do wnętrza obrazu

Za pomocą sudo docker build -t obraz . stowrzono nowy obraz o nazwie obraz na podstawie powyższego pliku.
Weryfikacja za pomocą ls -l /app – czy pliki z githuba znajdują się w folderze roboczym.


Lab3:

Przygotowanie lokalne: 
Przed przejściem do Dockera, na hoście wykonano następujące kroki:
-Sklonowanie repozytorium,
-Instalacja i testy – npm install.

Praca wewnątrz kontenera:
Ręczna konfiguracja środowiska:
	Uruchomienie kontenera za pomocą – docker run -it –name kontener node:18 /bin/bash. -it uruchamia interaktywny terminal, node:18 to gotowy obraz z środowiskiem Node.js.
	Następnie należało zaktualizować system – apt-get update i doinstalować narzędzia, których brakuje w czystym obrazie np. git.
	Wewnątrz kontenera ponownie sklonowano repozytorium i wykonano npm install. Po zakończonych sukcesem testów zatrzymano kontener za pomocą exit. 

Metoda automatyczna:
Zamiast robić powyższe kroki ręcznie stworzono dwa pliki Dockerfile – bazowy i testowy.
Dockerfile.build:
 
FROM node:18 – obraz bazowy
WORKDIR /usr/src/app – ustawienie katalogu roboczego
RUN apt-get update && apt-get install -y git – automatyczna instalacja narzędzi,
RUN git clone – pobranie kodu obrazu
RUN npm install – instalacja bibliotek

Dockerfile.test
 
FROM express-base -  bazuje na poprzednim obrazie
CMD [„npm”, „test”] – definiuje zadanie kontenera – po uruchomieniu ma wykonać testy.

Budowanie i uruchomienie:

Budowanie obrazów:

 


 

Flaga -f wskazuje konkretny plik, a -t nadaje mu nazwę
Uruchomienie testów za pomocą docker run –rm express-tests. Flaga -rm sprawia, że kontener zostanie usunięty po zakończeniu testów.


Lab4:

Zachowanie stanu między kontenerami – Woluminy:
Dwa „magazyny” danych – src – na kod źródłowy i out – na wynik budowania.
 
 

Użyty został obraz alpine/git aby sklonować repozytorium Express.js bezpośrednio do woluminy src. Kontener ten usuwa się zaraz po wykonaniu zadania (--rm) ale dane na wolumnie zostają. 

 
Uruchamiany został kontener node:18-alpine, który zamoontował wolumin src jako wejście i out jako wyjście. Komenda npm install zainstalowała biblioteki, a wynik (folder node_modules) został skopiowany do woluminu out.
 
 
 
 

Za pomocą komendy ls -l zaprezentowany został sukces – na liście zainstalowanych biblotek widać takie jak eslint lub babel.
Za pomocą użycia funkcji RUN –mount=type=bind w Dockerfile można zbudować czystszy i lżejszy obraz końcowy, bo nie zawiera tymczasowych plików instalatora npm, a proces jest szybszy niż tradycyjne copy.
 

Łączność między kontenerami i sieci:

Testowanie wydajności sieci za pomocą iperf3 – uruchomienie z flaga -d ustawia działanie w tle. Za pomocą docker inspect pozwoliło poznać wewnętrzny adres IP kontenera. 
 
Z poziomu klienta kontener połączył się z adresem IP pierwszego, mierząc przepustowość sieci między nimi.
 
Własna sieć mostkowa
Komenda docker network create sieci stowrzyła dedykowaną sieć. Kontenery uruchomione w tej samej się mogą się odnajdywać łatwiej i są odizolowane od innych procesów w systemie.
 
 
Mapowanie portów – za pomocą -p 5201:5201 pozwoliło hostowi komunikować się z kontenerem poprzez adres 127.0.0.1.
 Aby sprawdzić historię połączeń i sprawdzić czy klient z zewnątrz pomyślnie się połączył użyto polecenie docker logs serwer-iperf.

Usługi w kontenerze SSHD:
 
Instalacja za pomocą openssh-server, ustawienie hasła i ustawienie expose 22 – insormacja że kontener nasłuchuje na standardowym porcie SSH.
Zazwyczaj nie powinno się używać ssh w kontenerze, narusza to zasadę Dockera – kontener powinien uruchamiać jedną aplikację. Ale tak jak w moim przypadku użycie VS code remote ssh pozwoliło na pracę bezpośrednio wewnątrz kontenera tak, jakby był to zdalny serwer.


Jenkins:
Uruchomienie kontenera docker:dind – architektura DIND – Docker in Docker z  flagą -privileged. Pozwala to Jenkinsowi na uruchamianie własnych kontenerów podczas budowania projektów.
 
Inicjalizacja poprzez mapowanie portu 8080:8080 umożliwia dostęp do panelu Jenkinsa poprzez przeglądarkę pod adresem localhost:8080.
 
 
