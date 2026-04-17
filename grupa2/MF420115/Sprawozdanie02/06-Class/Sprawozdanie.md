# Sprawozdanie: Pipeline: lista kontrolna
Autor: Maciej Fraś 

Data: 17 kwietnia 2026 r.

Środowisko: Ubuntu 24.04.4 LTS (Virtual Machine / Hyper-V), Visual Studio Code (VSC)

1. Cel zajęć
Celem zajęć jest zcharektyryzowanie planu na pipeline i przedstawienie postępu prac. 
2. Zadania typu Freestyle

Zadanie 1: uname
Utworzono projekt wykonujący komendę `uname -a`. Build zakończył się sukcesem, wyświetlając informacje o kernelu Linuxa, na którym działa kontener.

![Zadanie_01_Uname](SS/project_uname.png)

Zadanie 2: Błąd warunkowy z godziną
Przygotowano skrypt bashowy sprawdzający godzinę systemową. Skrypt zwraca błąd , gdy godzina jest nieparzysta.

![Zadanie_02_HourError](SS/project_02_hour.png)


Zadanie 3: Docker Pull
Zweryfikowano możliwość komunikacji Jenkinsa z Dockerem poprzez wykonanie `docker pull ubuntu:24.04`.
Wymagane było nadanie uprawnień do gniazda Dockera na hoście (`chmod 666 /var/run/docker.sock`).

![Zadanie_02_DockerPull](SS/project3.png)

3. Pipeline CI/CD
Utworzono zaawansowany obiekt typu Pipeline, który automatyzuje proces pobierania kodu i budowania obrazu.

![Pipeline](SS/project_Pipeline.png)