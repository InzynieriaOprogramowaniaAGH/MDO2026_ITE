FROM ubuntu:22.04

# Instalacja serwera SSH i narzędzi
RUN apt-get update && apt-get install -y openssh-server

# Konfiguracja katalogu roboczego dla SSH
RUN mkdir /var/run/sshd

# Ustawienie hasła dla użytkownika root
RUN echo 'root:password123' | chpasswd

# Zezwolenie na logowanie użytkownika root przez SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

# Uruchomienie serwera SSH w trybie bez tła
CMD ["/usr/sbin/sshd", "-D"]
