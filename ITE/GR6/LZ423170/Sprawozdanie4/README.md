# Przygotuj woluminy wejściowy i wyjściowy
![alt text](image.png)
# Uruchom kontener, zainstaluj niezbędne wymagania wstępne
![alt text](image-1.png)
![alt text](image-2.png)
# Sklonuj repozytorium na wolumin wejściowy
1. Sklonowanie repozytorium na hoście
![alt text](image-5.png)
2. Skopiowanie zawartości do woluminu
![alt text](image-6.png)
Metoda - Bind mount w lokalnym katalogu - w kontenerze nie ma zainstalowanego gita więc należy obejść ten problem
# Uruchom build w kontenerze (potrzebny jest dostęp do kodu)
![alt text](image-3.png)
![alt text](image-4.png)
# Zapisz powstałe/zbudowane pliki na woluminie "wyjściowym"
![alt text](image-7.png)
# Ponów operację, ale klonowanie na wolumin "wejściowy
1. 
![alt text](image-8.png)
2. 
![alt text](image-9.png)
3. 
![alt text](image-10.png)
4. 
![alt text](image-11.png)
5. 
![alt text](image-12.png)
Te same operacje tylko z wykorzystaniem gita
Jest możliwość realizacji tych kroków za pomocą docker build i RUN --mount
FROM ubuntu
RUN apt update && apt install -y build-essential
RUN --mount=type=bind,source=/tmp,target=/repo cp -r /repo/* /input/

# Eksponowanie portu i łączność między kontenerami
# Uruchom wewnątrz kontenera serwer iperf
![alt text](image-13.png)
![alt text](image-14.png) 
# Połącz się z nim z drugiego kontenera, zbadaj ruch
![alt text](image-15.png)
![alt text](image-16.png)
![alt text](image-17.png)
# Ponów ten krok, ale wykorzystaj własną dedykowaną sieć mostkową
![alt text](image-18.png)
![alt text](image-19.png)
![alt text](image-20.png)
![alt text](image-21.png)
![alt text](image-22.png)
![alt text](image-23.png)
![alt text](image-24.png)
![alt text](image-25.png)
# Połącz się spoza kontenera
![alt text](image-26.png)
# Przeprowadź instalację skonteneryzowanej instancji Jenkinsa z pomocnikiem DIND
![alt text](image-27.png)
![alt text](image-28.png)
![alt text](image-29.png)
# Ekran logowania
![alt text](image-30.png)
![alt text](image-31.png)