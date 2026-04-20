FROM archlinux:base-devel

# Zależności
RUN pacman -Syu --asdeps --noconfirm git gpgme libarchive curl python fakechroot fakeroot meson
# Klon repo
ARG PACMAN_TAG
RUN git clone -b v$PACMAN_TAG https://gitlab.archlinux.org/pacman/pacman.git /repo
WORKDIR /repo

# Konfiguracja dla budowy
RUN meson setup build --prefix=/usr/local

# Budowa
WORKDIR /repo/build
RUN meson compile

# Oczyszczanie pakietów obrazu
#RUN pacman -Rcsu --noconfirm $(pacman -Qqdt)
# --- wyłączone

CMD [ "./pacman", "--version" ]
