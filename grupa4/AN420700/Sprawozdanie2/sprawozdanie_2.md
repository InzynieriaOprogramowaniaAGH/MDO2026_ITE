## 1. Zestawienie środowiska skonteneryzowanego
# 1.1. Pobrano Docker uzywajac `sudo apt install docker.io`
# 1.2. Utworzono konto na Docker Hub i zalogowano sie w terminalu

![Docker_login](docker_login.png)

# 1.3. Dodano uzytkownika do grupy `sudo usermod -aG docker mrntex`

# 1.4. Docker hello-world

![Docker_hello_world](docker_hello.png)

![Busybox](busybox.png)

# 1.5. Pobrane obrazy i ich rozmiary (kolumna SIZE)

![Docker_images](Docker_images.png)

# 1.6. Kody wyjscia (kolumna STATUS)

![Docker_status](Docker_status.png)

# 1.7. busybox

![Busybox](busybox.png)

Polaczenie interaktywne
`-i` oznacza tryb interaktywny
`-t` oznacza terminal, laczy terminal z stdin/stdout contenera, dzieki czemu mozna wspolpracowac z powloka

![Busybox_it](busybox_it.png)

aby wyjsc z kontenera, nalezy wpisac `exit` lub uzyc CTRL+D

# 1.8. ubuntu

![ubuntu](ubuntu.png)

Aby przejsc terminal hosta, zrobiono detach uzywajac `Ctrl + P` i `Ctrl + Q`

![root](root.png)

# 1.9. Wlasny dockerfile

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y git

WORKDIR /app

RUN git clone -b AN420700 https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
```

Wywolano: `docker build -t lab-2-img .`

![docker_build](docker_build.png)

![git_docker](git_docker.png)

![uruchomione](running_docker.png)

![container_prune](container_prune.png)

wylaczono dzialajacy kontener

![exited_container](exit_container.png)

![removed](removed_container.png)

wyczyszczono obrazy
`docker image prune -a -f`