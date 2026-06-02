# Zajęcia 09

Celem zajęć jest przygotowanie źródła instalacyjnego dla maszyny wirtualnej oraz przeprowadzenie instalacji systemu operacyjnego.

## Przygotowanie servera HTTP

Poniższe polecenia wykonujemy na maszynie wirtualnej z systemem Linux server, która będzie maszyną pomocniczą do przygotowania źródła instalacyjnego.

```bash
sudo apt update
sudo apt install apache2 -y
systemctl status apache2
```

![apache2](</img/Screenshot 2026-05-28 at 15.57.49.png>)

## Przygotowanie źródła instalacyjnego

### Utworzenie katalogu i pliku dla kickstartera

```bash
sudo mkdir -p /var/www/html/kickstart
sudo nano ks.cfg
```

Zawartość pliku `ks.cfg`, który będzie wystawiony przez serwer HTTP i użyty podczas instalacji systemu operacyjnego na maszynie wirtualnej.

```bash
##version=DEVEL
text
reboot

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=aarch64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=aarch64

keyboard us
lang en_US.UTF-8
timezone Europe/Warsaw --utc

network --bootproto=dhcp --hostname=fedora-auto

rootpw root
firewall --disabled
selinux --disabled

zerombr
clearpart --all --initlabel
autopart

bootloader

%packages
@core
docker
curl
wget
git
%end

%post --log=/root/ks-post.log

systemctl enable --now docker

cat > /etc/systemd/system/nginx-container.service << 'EOF'
[Unit]
Description=Nginx container
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --rm -p 80:80 --name nginx nginx
ExecStop=/usr/bin/docker stop nginx

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nginx-container.service

echo "POST SCRIPT FINISHED" > /root/post-done.txt

%end
```

Sprawdzenie poprawności za pomocą polecenia `curl http://localhost/kickstart/ks.cfg`

![ks](</img/Screenshot 2026-05-28 at 16.08.32.png>)

## Instalacja systemu operacyjnego na maszynie wirtualnej z wykorzystaniem przygotowanego źródła instalacyjnego

### Tworzenie maszyny wirtualnej

Tworzymy nową maszynę wirtualną z systemem Fedora 44, przeklikujemy wszystko. Aby było możliwe pobranie pliku `ks.cfg` z serwera HTTP, musimy zmienić kartę sieciową na `Bridged Adapter`.

### Uruchomienie instalacji z wykorzystaniem kickstartera

Po zobaczeniu menu startowego GRUB, naciskamy klawisz `e` w elu edycji. Odszukujemy linię, która zaczyna się od linux i na jej końcu po spacji dodajemy: `inst.ks=http://192.168.1.129/kickstart/ks.cfg`

![grub](</img/Screenshot 2026-05-28 at 16.37.18.png>)

### Sprawdzenie poprawności instalacji

- hostname

```bash
hostname
```

![hostname](</img/Screenshot 2026-05-28 at 17.17.31.png>)

---

- docker

```bash
docker ps
```

![docker](</img/Screenshot 2026-05-28 at 17.17.59.png>)

---

- systemctl

```bash
systemctl status nginx-container
```

![nginx](</img/Screenshot 2026-05-28 at 17.18.31.png>)

## Wnioski

Dzięki automatyzacji możemy zaoszczędzić mnóstwo czasu, zwłaszcze jeżeli musimy wdrożyć dużą liczbę maszyn. Kickstarter eliminuje potrzebę ręcznego przeklikiwania instalatora, a także pozwala na natychmiastową konfigurację systemu po instalacji

Kluczowe jest dobre skonfigurowanie sieci, ustawienie karty sieciowej na tryb Bridge Adapter jest niezbędne, aby maszyna mogła pobrać plik konfiguracyjny z serwera HTTP.

Skrypty %post dają ogromne możliwości, dzięki narzędzią takim jak Kickstart pozwala nie tylko na samą instalację OS-a, ale też na jego natychmiastową konfigurację. Dzięki temu maszyna od razu po pierwszym uruchomieniu jest gotowa do pracy i ma podniesione wymagane usługi (Docker + Nginx), bez konieczności ręcznego logowania się i instalowania czegokolwiek przez administratora.
