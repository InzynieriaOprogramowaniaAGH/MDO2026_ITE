FROM ubuntu:22.04

RUN apt update && apt install -y openssh-server sudo
RUN useradd -m ansible && echo "ansible:ansible" | chpasswd
RUN adduser ansible sudo
RUN mkdir /var/run/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

