Instalacja zarządcy Ansible:

Ten sam system opracyjny, nazwa ansible-target:

![alt text](image.png)

Zainstalowane tar, openssh, utowrzone hostname i nazwe użytkownika:

![alt text](image-1.png)

Łączenie z głównej maaszyny na ansible-target:

![alt text](image-2.png)

Inwentaryzacja:
Ustalenie nazwy komputerów:
Host:

![](image-3.png)

Docelowa:

![alt text](image-4.png)

Weryfikacja łączności:

![alt text](image-5.png)

Plik inwentaryzacji:

![alt text](image-6.png)

Zapytanie o ping:

![alt text](image-7.png)

tasks.yaml:
![alt text](image-8.png)

Uruchamianie aplikacji redis:
Dockerfile:
![alt text](image-9.png)
Werfyfikowanie czy działa:
![alt text](image-10.png)
![alt text](image-11.png)

plik tasks.yaml:

![alt text](image-12.png)

deploy.yaml:

![alt text](image-13.png)

ansible-galaxy:

![alt text](image-14.png)