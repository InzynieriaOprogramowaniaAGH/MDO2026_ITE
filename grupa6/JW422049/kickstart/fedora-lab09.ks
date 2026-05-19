#version=Fedora
text
reboot

keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone Europe/Warsaw --utc

url --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-44&arch=x86_64
repo --name=updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f44&arch=x86_64

network --bootproto=dhcp --device=link --activate --hostname=fedora-jw422049

rootpw --plaintext fedora
user --name=janek --groups=wheel --password=fedora --plaintext

firewall --enabled --service=ssh --port=8080:tcp
selinux --enforcing
services --enabled=sshd,NetworkManager,docker

ignoredisk --only-use=sda
zerombr
clearpart --all --initlabel
autopart

bootloader --location=mbr
firstboot --disable

%packages
curl
wget
tar
openssh-server
docker
%end

%post --log=/root/ks-post.log
echo "=== LAB09 POST START ==="

cat > /usr/local/bin/start-lab09-container.sh <<'EOF'
#!/bin/bash
/usr/bin/docker rm -f lab09-nginx >/dev/null 2>&1 || true
/usr/bin/docker pull nginx:stable-alpine
/usr/bin/docker run -d --name lab09-nginx -p 8080:80 nginx:stable-alpine
EOF

chmod +x /usr/local/bin/start-lab09-container.sh

cat > /etc/systemd/system/lab09-nginx.service <<'EOF'
[Unit]
Description=Run lab09 nginx container
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/start-lab09-container.sh
ExecStop=/usr/bin/docker rm -f lab09-nginx
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable docker
systemctl enable lab09-nginx.service

echo "=== LAB09 POST END ==="
%end
