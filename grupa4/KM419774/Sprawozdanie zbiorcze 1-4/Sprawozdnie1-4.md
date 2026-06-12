# Sprawozdanie zbiorcze – DevOps
## Krzysztof Mazur KM419774

---

# Ćwiczenie 1 – Git, SSH, gałęzie

## Środowisko

- System hosta: Windows 11  
- Maszyna wirtualna: Ubuntu Server 24.04  
- Hypervisor: VirtualBox  
- Dostęp: SSH  
- Edytor: Windows PowerShell  
- Git: 2.43.0  

---

## Git i konfiguracja

![...](img/Git_init.png)

    git --version
    git config --global user.name "PrMKM"
    git config --global user.email "krzysztof_mazur-nr.18@wp.pl"

Klonowanie repozytorium HTTPS:

![...](img/Klonowanie_repozytorium_git.png)

    git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
    cd MDO2026_ITE

---

## SSH

![...](img/Klucze_SSH.png)

    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_pass -C "krzysztof_mazur-nr.18@wp.pl"
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_no_pass -C "krzysztof_mazur-nr.18@wp.pl"
    cat ~/.ssh/id_ed25519_pass.pub
    ssh -T git@github.com

![...](img/Połączenie_SSH.png)
![...](img/SSH_Github.png)

Klonowanie przez SSH:

![...](img/Klonowanie_repozytorium_git_ssh.png)

    git clone git@github.com:InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

---

## Narzędzia

![...](img/VB_SSH.png)
![...](img/FileZilla-transfer-plikow.png)

---

## Gałęzie

    git checkout main
    git pull origin main
    git checkout <branch_grupowy>
    git pull origin <branch_grupowy>
    git checkout -b KM419774
    mkdir -p grupa4/KM419774
    cd grupa4/KM419774
    touch Sprawozdanie_1.md
    mkdir img

---

## Git Hook

![...](img/git_hook.png)

    nano commit-msg
    cp commit-msg ../../.git/hooks/commit-msg
    chmod +x ../../.git/hooks/commit-msg

![...](img/Prezentacja_git_hook.png)

---

# Ćwiczenie 2 – Docker

## Instalacja

    sudo apt update
    sudo apt install docker.io -y
    sudo systemctl enable --now docker
    docker --version

![...](img/L2_1.png)

    sudo systemctl status docker

![...](img/L2_2.png)

---

## Kontenery testowe

    sudo docker run hello-world
    sudo docker run busybox echo "Hello BusyBox"
    sudo docker run ubuntu uname -a

![...](img/L2_3.png)

---

## Tryb interaktywny

    sudo docker run -it busybox
    ps
    ls
    exit

    sudo docker run -it ubuntu
    ps
    ls
    exit

![...](img/L2_3,5.png)

---

## Obrazy i kontenery

    sudo docker images
    sudo docker ps -a
    echo $?

![...](img/L2_4.png)

---

## PID

    sudo docker run -it busybox
    echo $BASHPID
    echo $$
    exit

![...](img/L2_5.png)

---

## Ubuntu container

    sudo docker run -it ubuntu
    ps -ef
    apt update && apt upgrade -y
    exit

![...](img/L2_6.png)

    ps aux | grep docker

![...](img/L2_7.png)

---

## Dockerfile

![...](img/L2_8.png)

---

## Build i run

    sudo docker build -t km419774_image Lab2/
    sudo docker run -it km419774_image
    ls /home/devops/MDO2026_ITE

![...](img/L2_9.png)
![...](img/L2_10.png)

---

## Czyszczenie

    sudo docker ps
    sudo docker ps -a
    sudo docker rm $(docker ps -a -q)
    sudo docker rmi km419774_image
    sudo docker image prune -a

![...](img/L2_11.png)
![...](img/L2_12.png)
![...](img/L2_13.png)
![...](img/L2_14.png)

---

# Ćwiczenie 3 – Docker CI

Repozytorium: https://github.com/expressjs/express.git

---

## Lokalny build

    git clone https://github.com/expressjs/express.git
    cd express

![...](img/L3_1.png)

    sudo apt install -y nodejs npm

    node -v
    npm -v

![...](img/L3_2.png)

    npm install
    npm test

![...](img/L3_3.png)
![...](img/L3_4.png)

---

## Kontener

    docker run -it node:20 bash

![...](img/L3_5.png)

    apt install -y git
    git clone https://github.com/expressjs/express.git
    cd express
    npm install
    npm test

![...](img/L3_6.png)
![...](img/L3_7.png)

---

## Dockerfile

![...](img/L3_8.png)

    docker build -f Dockerfile.build -t express-build .

![...](img/L3_9.png)
![...](img/L3_9_success.png)

---

## Test

![...](img/L3_10.png)

    docker build -f Dockerfile.test -t express-test .
    docker run --rm express-test

![...](img/L3_11.png)
![...](img/L3_12.png)

---

## Compose

![...](img/L3_13.png)

    docker compose build
    docker compose run test

![...](img/L3_14.png)
![...](img/L3_15.png)

---

# Ćwiczenie 4 – Woluminy i Jenkins

## Woluminy

    docker volume create express_input
    docker volume create express_output

![...](img/L4_1.png)

    docker run --rm -v express_input:/data alpine sh -c "apk add git && git clone https://github.com/expressjs/express.git /data/express"

![...](img/L4_2.png)

---

## Builder

    docker run -it -v express_input:/input -v express_output:/output node:20 bash

    apt install -y git
    cd /input
    git clone https://github.com/expressjs/express.git
    cd express
    npm install
    cp -r node_modules /output/

![...](img/L4_4.png)
![...](img/L4_7.png)
![...](img/L4_8.png)

---

## Sieci

    docker network create labnet

![...](img/L4_9.png)

    docker run -it --name iperf_server --network labnet ubuntu

![...](img/L4_10.png)

    docker run -it --name iperf_client --network labnet ubuntu

![...](img/L4_11.png)
![...](img/L4_12.png)

---

## SSH

    docker run -it --name ssh_lab -p 2222:22 ubuntu

    apt install -y openssh-server
    service ssh start

    ssh root@localhost -p 2222

![...](img/L4_18.png)

---

## Jenkins

    docker volume create jenkins_home
    docker network create jenkins

    docker run -d --name jenkins-dind --network jenkins --privileged docker:24-dind

![...](img/L4_19.png)
![...](img/L4_20.png)

    docker run -d --name jenkins --network jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -e DOCKER_HOST=tcp://jenkins-dind:2375 jenkins/jenkins:lts

![...](img/L4_21.png)
![...](img/L4_22.png)

http://192.168.1.104:8080

![...](img/L4_23.png)