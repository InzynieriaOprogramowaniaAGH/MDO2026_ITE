I. Zachowanie stanu między kontenrami:
  1.Wolumin bez gita
    a. Tworzenie woluminów
    
   <img width="847" height="70" alt="image" src="https://github.com/user-attachments/assets/3ede4037-c8ae-4643-89dd-0ec374cfcc08" />

  <img width="822" height="69" alt="image" src="https://github.com/user-attachments/assets/8e94f1e9-cfbd-42de-a12e-ca779b4f5e53" />

   b. Klonowanie za pomocą kontenera pomocniczego

   <img width="809" height="113" alt="image" src="https://github.com/user-attachments/assets/163aa6cd-0158-4670-bd7d-798d12247a73" />

  c.Budowanie  w kontenerze bazowym

  <img width="803" height="322" alt="image" src="https://github.com/user-attachments/assets/80b1bb70-9d73-47ae-99b3-5ef29809a60b" />

  d.	Sprawdzenie, czy na woluminie wyjściowym jest folder node_modules – dowód, że build się udał

  <img width="945" height="462" alt="image" src="https://github.com/user-attachments/assets/934c1520-8a75-4e79-84d9-79784e65183b" />

2. Wolumin z gitem

   a.Czyszczenie i stworzenie nowego wolumina

    <img width="841" height="130" alt="image" src="https://github.com/user-attachments/assets/0e1ad40f-2422-46bd-bff0-53c55c972176" />

  b. Uruchomienie

  <img width="839" height="119" alt="image" src="https://github.com/user-attachments/assets/3e9a1bd6-069f-46e8-902d-9cafef12f52f" />

  c. Operacje wewnątrz kontenera

  <img width="945" height="147" alt="image" src="https://github.com/user-attachments/assets/2b1dfa77-7e14-4f1e-9ae1-8f317461bf44" />

  Instalacja gita

  <img width="800" height="136" alt="image" src="https://github.com/user-attachments/assets/437a2406-eba8-4824-900a-24d59fe452f3" />

  Sklonowanie express

  <img width="945" height="43" alt="image" src="https://github.com/user-attachments/assets/21e7e932-5558-4bc1-aadf-dc321474963d" />

  Instalacja zależności

  <img width="330" height="91" alt="image" src="https://github.com/user-attachments/assets/3b7c4064-0c0d-457b-90a0-a66d5701c4fb" />

  Sklonowanie wyniku na wolumin wyjściowy i wyjście


3. Aby zautomatyzować można użyć funkcji mount w Dockerfile

   <img width="791" height="223" alt="image" src="https://github.com/user-attachments/assets/cc273d05-aa9f-418e-9b1f-618474b05073" />

    Wolumin jest budowany tylko na czas budowania. Wynik w formie obrazu będzie miał zainstalowaną aplikację w built_app.
    Zastosowanie RUN –mount jest lepszym wyborem – po odpowiednim skonfigurowaniu nie będzie śladu po plikach tymczasowych instalatora     npm, bind mount wewnątrz docker build jest zazwyczaj szybszy niż tradycyjne COPY.


II. Eksponowanie portu łączności między kontenerami

1. Uruchomienie serwera

  <img width="945" height="41" alt="image" src="https://github.com/user-attachments/assets/f48adeb2-ff41-407a-9c3c-e91577b0e7c2" />

  -d - działa w tle
  -sh – c – instaluje iperf i uruchamia go w trybie serwera 

  b. Uruchomienie serwera klienta

  <img width="945" height="54" alt="image" src="https://github.com/user-attachments/assets/95a70d6f-45a5-473d-9a24-d00c37979261" />

  2. Znalezienie adresów IP i pomiar
     
  <img width="945" height="34" alt="image" src="https://github.com/user-attachments/assets/9c79e902-257c-42bc-baa6-3e60bed59b7a" />

  <img width="919" height="536" alt="image" src="https://github.com/user-attachments/assets/56e8126b-e8b8-4621-a2bc-52cb007aa5bc" />


3. Własna sieć mostkowa
   a.Stworzenie sieci

    <img width="866" height="58" alt="image" src="https://github.com/user-attachments/assets/e11ef529-cb0e-4b48-b896-b04927e5f443" />


   b. Uruchomienie serwera w nowej sieci

   <img width="945" height="41" alt="image" src="https://github.com/user-attachments/assets/c323c4cc-a781-4908-a381-d9f007ae3f5c" />


   c. Uruchomienie klienta w nowej sieci i połączenie

   <img width="945" height="375" alt="image" src="https://github.com/user-attachments/assets/35b1e30b-1ba2-4023-a155-c1fe865cbdc9" />


4. Połączenie spoza kontenera

   a.Uruchomienie serwera z mapowaniem portu

  <img width="945" height="45" alt="image" src="https://github.com/user-attachments/assets/0636ea93-e142-41f2-aa27-d4397379640f" />
   
   b. Połączenie z hosta

  <img width="892" height="547" alt="image" src="https://github.com/user-attachments/assets/ac0f877f-fcfc-4fff-b90a-8b143c5bae5f" />
   
   c. Połączenie spoza hosta

   <img width="924" height="208" alt="image" src="https://github.com/user-attachments/assets/467edc76-aaa5-491a-9edc-53daa6297ab9" />


5. Wyniki

   a. Odczytanie logów z serwera

    <img width="945" height="799" alt="image" src="https://github.com/user-attachments/assets/d41198df-2b68-4064-9d69-4be52f21e5f3" />

   b. Zapisanie wyniku kliena do pliku na woluminie

   <img width="945" height="86" alt="image" src="https://github.com/user-attachments/assets/63b9b2d5-8f90-4a76-a4f7-16ee0ef36084" />

  <img width="945" height="52" alt="image" src="https://github.com/user-attachments/assets/444f1bf6-b68d-4e2c-9578-6f8b0080f219" />

III. Usługi w rozumieniu systemu, kontenera i klastra

1. Kontener SSHD - plik Dockerfile

<img width="945" height="352" alt="image" src="https://github.com/user-attachments/assets/16ba6020-20db-4465-9d4f-e9abac5463b6" />
   
2. Zbudowanie kontenera i uruchomienie

<img width="945" height="222" alt="image" src="https://github.com/user-attachments/assets/9784634a-940a-48da-bac3-abbcc74d7e9e" />

  
3. Połączenie z usługa SSHD

 <img width="945" height="48" alt="image" src="https://github.com/user-attachments/assets/2d53d066-c0c3-4345-aa92-9f55e4cf66dc" />

<img width="945" height="581" alt="image" src="https://github.com/user-attachments/assets/bc09f560-89db-4b5e-aae4-ae9171064589" />


Zazwyczaj nie powinno się używać ssh w kontenerze, narusza to zasadę Dockera – kontener powinien uruchamiać jedną aplikację. Ale tak jak w moim przypadku użycie VS code remote ssh pozwoliło na praće bezpośrednio wewnątrz kontenera tak, jakby był to zdalny serwer.


IV. Przygotowanie do uruchomienia serwera Jenkins

1. Stworzenie sieci serwera Jenkins

  <img width="875" height="55" alt="image" src="https://github.com/user-attachments/assets/9e1725a0-6207-45f9-9ae7-4668f3a3a005" />

   
2. Uruchomienie pomocnika DIND

<img width="945" height="214" alt="image" src="https://github.com/user-attachments/assets/53922786-6378-4768-b152-187e24b5d149" />

   
3. Uruchomienie Jenkinsa

<img width="945" height="193" alt="image" src="https://github.com/user-attachments/assets/248f5ecd-4ea0-4d7c-8302-4e7279ee17db" />

   
4. Inicjalizacja
  a. Działające kontenery

<img width="945" height="115" alt="image" src="https://github.com/user-attachments/assets/6d0ec866-535f-4995-bf86-1aeb7a3d4cd0" />


  b. Ekran logowania
  
  <img width="945" height="242" alt="image" src="https://github.com/user-attachments/assets/cb412712-3f24-402e-aa4e-f844e42b3a8f" />
  
  <img width="945" height="473" alt="image" src="https://github.com/user-attachments/assets/ff5c83b0-d1aa-41b5-8044-9c61a4eedf75" />

  <img width="733" height="328" alt="image" src="https://github.com/user-attachments/assets/a8b60dcb-4f11-4d39-9213-90065ae5e43b" />


     
