# Laboratoria 9
## 1. Przygotowanie bazy i obrazu ISO

Utworzenie nowej maszyny z fedora

![](1_fedora_start.png)

![](2_anaconda.png)

## 2. Plik `anaconda-ks.cfg`

![](anaconda1.png)

![](anaconda2.png)

![](anaconda3.png)

## 3. Dodatkowa maszyna z fedorą 
Przy uruchamianiu się maszyny wciśnięto przycisk `e` w celu edytowania lini bootowania

Została instrukcja:

`inst.ks=http://192.168.100.1/anaconda-ks.cfg ip=192.168.100.2:::255.255.255.0::enp0s8:none`

![](fedoraautomat.png)

Po skończeniu odłączone zostało ISO:

![](iso.png)

Sprawdzono czy połączyło się z główną maszyną:

![](fedora1logi.png)

Serwer 
![](fedorafinal.png)