# Sprawozdanie 2

Autor: Jan Pawelec

---

## Instalacja Dockera
Wpierw pobrano curlem oficjalne repo.
![alt text](0_install_docker.png)

## Róznorodne obrazy
Pobrano pełną listę obrazów. Poniżej pobrano przykładowy obraz. Uruchomiono i sprawdzono rozmiar.
![alt text](1_obrazy_i_size.png)
Sprawdzono też Microsoftowy aspnet.
![alt text](1_obrazy_asp.png)
Siegnięto do znanego z baz danych mariadb.
![alt text](1_obrazy_maria.png)
Pełna lista obrazów i ich rozmiarów prezentuje sie następująco.
![alt text](1_obrazy_size_all.png)
Następnie spojrzano na kod wyjścia.
![alt text](1_obrazy_kod_wyjscia.png)
Sprawdzono także wersję.
![alt text](2_busybox_wersja.png)

## System w kontenerze
Pobrano i uruchomiono obraz Ubuntu, pobrano PID1.
![alt text](3_ubuntu_pid.png)
Sprawdzono procesy Dockera w hoście.
![alt text](3_uprocesy_dockera.png)
Przeprowadzono update na obrazie.
![alt text](3_ubuntu_update.png)

## Dockerfile
Treść Dockerfile jest załączona w folderze. Dokonano build i następnie uruchomiono skrypt. Można zobaczyć aktywny obraz z pobranym repo.
![alt text](6_Dockerfile_build.png)

## Obrazy - ostatni rozdział
Sprawdzono listę uruchomionych obrazów.
![alt text](7_obrazy.png)
Następnie przeprowadzono czyszczenie całej listy.
![alt text](8_obrazy_prune.png)