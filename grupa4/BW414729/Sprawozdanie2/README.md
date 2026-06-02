Sprawozdanie 2

## 1. Instalacja Docker w systemie linuksowym
Zainstalowałem Dockera za pomocą komendy `sudo apt install docker.io`, a nastepnie zgodnie z wymaganiami zadania dotyczącymi unikania pracy na koncie root, skonfigurowałem uprawnienia tak, aby móc zarządzać Dockerem jako zwykły użytkownik.
za pomocą `sudo usermod -aG docker $USER`
![instalacja_docker](instalacja_docker.png)

## 2. Docker Hub

![udana_rejestracja_Dockerhub](udana_rejestracja_Dockerhub.png)
![DockerHub_sugerowane](DockerHub_sugerowane.png)


## 3. Zapoznanie sie z obrazami hello-world. busybox, ubuntu

![hello_world_run](hello_world_run.png)
![busybox_run](busybox_run.png)
![ubuntu_run](ubuntu_run.png)

Z 3 uruchomionych obrazów jedynie Helloworld, gdyż BusyBox i Ubuntu po uruchomieniu bez dodatkowych parametrów natychmiast zakończyły pracę, ponieważ nie miały przypisanego żadnego domyślnego zadania. 

![images_sizes](images_sizes.png)
![docker_kod_wyjscia](docker_kod_wyjscia.png)

Wszystkie kontenery zakończyły prace kodem 0 czyli uruchomiły się i zakończyły swoją prace poprawnmie.

## 4. Uruchomienie busybox

![uruchomienie_busybox](uruchomienie_busybox.png)

W efekcie uruchomienia busyboxa nic sie nie wydażyło, lecz po podłączeniu sie interaktywnie mozemy pracowaćw tym kontenerze. Numer wersji to 1.37.0

![interaktywny_busybox](interaktywny_busybox.png)

## 5. Uruchomienia "systemu w kontenerze"

Jako system wybrałem ubuntu do uruchomienia. Uruchomiłem i wszedłem do kontenera za pomocą `docker run -it ubuntu bash`, po czym zaktualizowałem pakiety.

![ubuntu_w_kontenerze_i_aktualizacja_pakietow](ubuntu_w_kontenerze_i_aktualizacja_pakietow.png)

![ubuntu_ps_aux](ubuntu_ps_aux.png)

Na powyższyym screenie widać że procesem o PID1 jest bash, co jest charakterystyczne dla kontenerów. Pierwszy proces to  powłoka uruchamiająca a nie system jak w tradycyjnym OS.

![procesy_dockera_host](procesy_dockera_host.png)

Procesy dockera na hoscie moga być inne z założeniami, gdyż na koniec o tym doczytałem że trzeba zrobici zrobiłe mjuz po czyszczeniu.

## 6. Moj Dockerfile

Korzystajac z dobrych praktyk napisałem Dockerfile:
```
FROM ubuntu:22.04

# aktualizacja , pobranie certyfiaktu do gita, i czyszczenie po apt
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Klonowanie repozytorium
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

CMD ["bash"]
```

Następnei uruchomiłem Dockerfile i wykazalem, że jest na nim nasze repozytorium.
![Dockerfile_udany](Dockerfile_udany.png)
![sciagniety_git](sciagniety_git.png)

## 7. Pokazanie uruchomionych kontenerów, i ich czyszczenie

![uruchomione_kontenery_&_czyszczenie](uruchomione_kontenery_&_czyszczenie.png)

## 8. Czyszczenie obrazów z lokalnego magazynu

![czyszczenie_obrazów_z_lokalnego_magazynu](czyszczenie_obrazów_z_lokalnego_magazynu.png)