
##Lab1:
###Połączenie z maszyną wirtualna:
Na uruchomionej maszynie wirtualnej ustawiono regułę – próba wejścia na głównym komputerze na port 2222 skutkuje połączeniem się z portem 22 na maszynie wirtualnej. 

<img width="647" height="48" alt="image" src="https://github.com/user-attachments/assets/23eb6c44-714c-4438-a413-0d32a7fe0e4b" />

 
Port 22 to domyślny port do obsługi SSH (zdalnego i bezpiecznego dostępu do konsoli).
Na podstawie ustawionej reguły za pomocą komendy - ssh jakarekk@127.0.0.1 -p 2222 zalogowano się poprzez protokół SSH z danym użytkownikiem na adresie 127.0.0.1 (adres, który zawsze wskazuje obecnie używany komputer), używając portu 2222.

<img width="589" height="38" alt="image" src="https://github.com/user-attachments/assets/d45ebe79-0b3e-4b08-a33d-a10ad8e27dff" />

 
###Instalacja narzędzi:
Poprzez zastosowanie sudo apt update przed instalacją można upewnić, się że pobrana zostanie najnowsza wersja oprogramowania. Polecenie sudo apt install git openssh-client -y (-y pozwala na automatyczne rozpoczęcie instalacji) zainstalowało dwa programy – Git, do zarządzania kodem oraz openssh-client – program pozwalający generować klucze szyfrujące do bezpiecznego łączenia się z serwerami.
Przy obu komendach zastosowane zostało sudo – pozwoliło ono wykonać komendy apt bez wyrzucania błędu. Stosuje się go zawsze przy modyfikacji plików systemowych.
Poprzez Github stworzony został klucz – Personal Access Token, aby później użyć go do połączenia terminala z kontem Github i wykonywania na nim operacji.
	
###Konfiguracja kluczy SSH:
Aby nie podawać hasła, przy każdej operacji na repozytorium, wygenerowane zostały klucze SSH – publiczny oraz prywatny.

<img width="831" height="591" alt="image" src="https://github.com/user-attachments/assets/80beb35d-248b-4df8-8a57-32a72eaf4e40" />

 
ssh-keygen -t ed25519 -C "Userv" -f ~/.ssh/id_1 -N "" – tworzy klucz typu ed25519 o nazwie id_1, -N ‘’’’ oznacza, że plik nie będzie chroniony dodatkowym hasłem.
Następnie za pomocą cat ~/.ssh/id_1.pub wypisana została zawartość klucza publicznego – ten ciąg znaków należało wkleić na Githubie w zakładce Add new SSH key.
Przy klonowaniu repozytorium za pomocą kluczy SSH zamiast https://... Teraz jest git@.... - git clone git@github.com:..

 <img width="933" height="42" alt="image" src="https://github.com/user-attachments/assets/e6b7bfa2-d046-41ee-9499-9dceeea534f5" />


###Praca na gałęziach:
W celu ułatwienia współpracy podczas pracowania na jednym kodzie korzysta się z gałęzi – tworzona jest kopia głównego kodu na której każdy może pracować osobno aby później ewentualnie zmiany te wprowadzić na główną gałąź.
Za pomocą cd repo – zmieniono katalog na folder pobranego wcześniej repozytorium. 
- git checkout grupa2 – pobrało i przełączyło gałąź na grupa2,
- git checkout -b .. - -b – oznacza stworzenie nowej gałęzi i od razu wejście na nią

###Ustawienia dla commitów:
Za pomocą skryptu napisanego w języku Bash ustawiono zasadę – przy próbie stworzenia commitu jeżeli jego opis nie zaczyna się od podanego inicjału i numeru indeksu to skrypt nie pozwoli wysłać commita i zwróci błąd.
Aby go aktywować należało przenieść skrypt do .git/hooks – jest to ukryty folder gita, pliki tam umieszczone działają automatycznie. Aby plik działał automatycznie należało mu jeszcze nadać uprawnienie do wykonywania się za pomocą chmod +x ….


##Lab2:

###Instalacja dockera:
Zastosowanie komendy sudo systemctl enable –now docker skutkuje natychmiastowe uruchomienie silnika Docker oraz ustawienie go tak, aby startował automatycznie wraz z systemem.

<img width="670" height="42" alt="image" src="https://github.com/user-attachments/assets/a675627e-8268-4edb-95e1-5e8cb029c493" />

 

Następnie pobrano i przetestowano następujące obrazy:
Docker run hello-world – standardowy test poprawności instalacji,
Docker run busybox echo „busyboc” – uruchomienie systemu busybox i uruchomienie polecenie echo w celu sprawdzenia poprawności działania
Docker run -it ubuntu bash -c “exit” – pobiera obraz ubuntu i uruchamia powłkę bash, która od razu zostaje zamknięta.

Inspekcja obrazów i plików:
Za pomocą komendy docker images wyświetlono listę pobranych obrazów,
Za pomocą echo $? Sprawdzono kod wyjścia – czy ostatnie polecenie zakończyło się sukcesem
Komenda sudo docker run busybox ls -l uruchomiła kontener Busybox aby wyświetlić listę plików w jego głównym katalogu.

###Praca wewnątrz kontenera: 
Polecenie sudo docker run -it busybox pozwala wejść do wnętrza kontenera i pracować w nim jak na osobnym komputerze
 
<img width="833" height="614" alt="image" src="https://github.com/user-attachments/assets/667ff6d3-746a-4e1b-8e13-7421c401541e" />


Zarządzanie kontenerem Ubutnu:
Za pomocą –name została nadana własna nazwa kontenerowi.

<img width="945" height="276" alt="image" src="https://github.com/user-attachments/assets/f28fce18-5d95-4923-82c0-e4e2061361dc" />

 
Aby sprawdzić aktualne procesy na dockerze użyto ps aux.
 

###Budowanie Dockerfile:

<img width="864" height="289" alt="image" src="https://github.com/user-attachments/assets/d02c78b9-4cea-46d0-8ca6-7244490388dc" />

 
Jest to napisanie skryptu konfiguracyjnego.
FROM ubuntu:22.04 – ustalenie bazy – konkretnej wersji Ubuntu
RUN apt-get install git – instaluje  Git to wewnętrznego obrazu
WORKDIR /app – tworzy I przechodzi do folderu roboczego
RUN git clone .. – pobiera kod z repozytorium do wnętrza obrazu

Za pomocą sudo docker build -t obraz . stowrzono nowy obraz o nazwie obraz na podstawie powyższego pliku.
Weryfikacja za pomocą ls -l /app – czy pliki z githuba znajdują się w folderze roboczym.


##Lab3:

###Przygotowanie lokalne: 
Przed przejściem do Dockera, na hoście wykonano następujące kroki:
-Sklonowanie repozytorium,
-Instalacja i testy – npm install.

###Praca wewnątrz kontenera:
Ręczna konfiguracja środowiska:
	Uruchomienie kontenera za pomocą – docker run -it –name kontener node:18 /bin/bash. -it uruchamia interaktywny terminal, node:18 to gotowy obraz z środowiskiem Node.js.
	Następnie należało zaktualizować system – apt-get update i doinstalować narzędzia, których brakuje w czystym obrazie np. git.
	Wewnątrz kontenera ponownie sklonowano repozytorium i wykonano npm install. Po zakończonych sukcesem testów zatrzymano kontener za pomocą exit. 

###Metoda automatyczna:
Zamiast robić powyższe kroki ręcznie stworzono dwa pliki Dockerfile – bazowy i testowy.
Dockerfile.build:

<img width="638" height="311" alt="image" src="https://github.com/user-attachments/assets/fc8c30bc-8ddd-4713-9053-ded560498091" />

 
FROM node:18 – obraz bazowy
WORKDIR /usr/src/app – ustawienie katalogu roboczego
RUN apt-get update && apt-get install -y git – automatyczna instalacja narzędzi,
RUN git clone – pobranie kodu obrazu
RUN npm install – instalacja bibliotek

Dockerfile.test

<img width="300" height="147" alt="image" src="https://github.com/user-attachments/assets/222afb8c-df6d-4b97-98e0-9ff8edad4751" />

 
FROM express-base -  bazuje na poprzednim obrazie
CMD [„npm”, „test”] – definiuje zadanie kontenera – po uruchomieniu ma wykonać testy.

###Budowanie i uruchomienie:

Budowanie obrazów:

 <img width="930" height="30" alt="image" src="https://github.com/user-attachments/assets/2b90ab8f-1769-4216-8d35-9f9967a2d9c7" />

<img width="934" height="30" alt="image" src="https://github.com/user-attachments/assets/712e7743-0b3e-4713-a92c-a4f405b7c21d" />


 

Flaga -f wskazuje konkretny plik, a -t nadaje mu nazwę
Uruchomienie testów za pomocą docker run –rm express-tests. Flaga -rm sprawia, że kontener zostanie usunięty po zakończeniu testów.


##Lab4:

###Zachowanie stanu między kontenerami – Woluminy:
Dwa „magazyny” danych - umożliwiają one wydajną obsługę operacji wejścia-wyjścia oraz bezpieczne współdzielenie zasobów pomiędzy wyizolowanymi instancjami, eliminując ryzyko utraty informacji po terminacji kontenera. 
– src – na kod źródłowy i out – na wynik budowania.

 <img width="847" height="70" alt="image" src="https://github.com/user-attachments/assets/5aa1f30e-4453-4385-84ec-8d5fedcb498b" />

<img width="822" height="69" alt="image" src="https://github.com/user-attachments/assets/3015e448-80aa-4776-8291-dd2ef2b58899" />

 

Użyty został obraz alpine/git aby sklonować repozytorium Express.js bezpośrednio do woluminy src. Kontener ten usuwa się zaraz po wykonaniu zadania (--rm) ale dane na wolumnie zostają. 

<img width="925" height="33" alt="image" src="https://github.com/user-attachments/assets/4c3210e0-c2f3-4f74-a4bc-e832eeb634f6" />

 
Uruchamiany został kontener node:18-alpine, który zamoontował wolumin src jako wejście i out jako wyjście. Komenda npm install zainstalowała biblioteki, a wynik (folder node_modules) został skopiowany do woluminu out.
 
 <img width="839" height="119" alt="image" src="https://github.com/user-attachments/assets/357a513f-cbaa-4f66-b467-819b9b266d48" />


 <img width="945" height="147" alt="image" src="https://github.com/user-attachments/assets/ff63579e-d42b-45cd-b251-9d9ac92cafbc" />

<img width="945" height="147" alt="image" src="https://github.com/user-attachments/assets/dc2f163b-1d03-47f8-a7a2-df5ea43e866d" />

<img width="945" height="43" alt="image" src="https://github.com/user-attachments/assets/68908849-c401-4f41-b7d7-fc82c2f7eb52" />

 

Za pomocą komendy ls -l zaprezentowany został sukces – na liście zainstalowanych biblotek widać takie jak eslint lub babel.
Za pomocą użycia funkcji RUN –mount=type=bind w Dockerfile można zbudować czystszy i lżejszy obraz końcowy, bo nie zawiera tymczasowych plików instalatora npm, a proces jest szybszy niż tradycyjne copy.

 <img width="791" height="223" alt="image" src="https://github.com/user-attachments/assets/1a5f2e30-ff1c-4595-9671-8e32ab3f702a" />


###Łączność między kontenerami i sieci:

Testowanie wydajności sieci za pomocą iperf3 – uruchomienie z flaga -d ustawia działanie w tle. Za pomocą docker inspect pozwoliło poznać wewnętrzny adres IP kontenera. 

<img width="945" height="41" alt="image" src="https://github.com/user-attachments/assets/a9816dc4-3645-48d8-9a0b-ca26b2cc2ac9" />

 
Z poziomu klienta kontener połączył się z adresem IP pierwszego, mierząc przepustowość sieci między nimi.

<img width="945" height="54" alt="image" src="https://github.com/user-attachments/assets/e3206b3b-e2c1-4e29-bdff-dfe32265b2af" />

 
###Własna sieć mostkowa
Komenda docker network create sieci stowrzyła dedykowaną sieć. Kontenery uruchomione w tej samej się mogą się odnajdywać łatwiej i są odizolowane od innych procesów w systemie.

 <img width="945" height="45" alt="image" src="https://github.com/user-attachments/assets/26449d50-20c0-4775-bca1-f814d0ee3fd5" />

<img width="892" height="547" alt="image" src="https://github.com/user-attachments/assets/3c1bdbc0-1fcf-4c2d-9eac-81b8c5003106" />

 
Mapowanie portów – za pomocą -p 5201:5201 pozwoliło hostowi komunikować się z kontenerem poprzez adres 127.0.0.1.
 Aby sprawdzić historię połączeń i sprawdzić czy klient z zewnątrz pomyślnie się połączył użyto polecenie docker logs serwer-iperf.

 <img width="924" height="208" alt="image" src="https://github.com/user-attachments/assets/3526edff-23dd-4599-ac66-af4b6f860a07" />


###Usługi w kontenerze SSHD:

<img width="945" height="352" alt="image" src="https://github.com/user-attachments/assets/3f11a201-add1-4f8d-a478-f56d99bd2aef" />

 
Instalacja za pomocą openssh-server, ustawienie hasła i ustawienie expose 22 – insormacja że kontener nasłuchuje na standardowym porcie SSH.
Zazwyczaj nie powinno się używać ssh w kontenerze, narusza to zasadę Dockera – kontener powinien uruchamiać jedną aplikację. Ale tak jak w moim przypadku użycie VS code remote ssh pozwoliło na pracę bezpośrednio wewnątrz kontenera tak, jakby był to zdalny serwer.


###Jenkins:
Uruchomienie kontenera docker:dind – architektura DIND – Docker in Docker z  flagą -privileged. Pozwala to Jenkinsowi na uruchamianie własnych kontenerów podczas budowania projektów.

<img width="945" height="214" alt="image" src="https://github.com/user-attachments/assets/6f29190f-88b9-40a7-a212-3e7afbc7a558" />

 
Inicjalizacja poprzez mapowanie portu 8080:8080 umożliwia dostęp do panelu Jenkinsa poprzez przeglądarkę pod adresem localhost:8080.

<img width="945" height="242" alt="image" src="https://github.com/user-attachments/assets/ad4a3818-7ac6-4d76-b5cc-01a9c1a5dbb8" />


<img width="945" height="473" alt="image" src="https://github.com/user-attachments/assets/30af56b2-6e9f-43b2-9bc2-c63d13fd1aea" />

 
 
