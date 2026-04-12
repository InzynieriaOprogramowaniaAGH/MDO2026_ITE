FROM archlinux:base-devel

# Zależności
RUN pacman -Syu --needed --noconfirm git gpgme libarchive curl python fakechroot fakeroot meson
# Klon repo
RUN git clone -b v7.1.0 https://gitlab.archlinux.org/pacman/pacman.git /repo
WORKDIR /repo

# Konfiguracja dla budowy
RUN meson setup build

# Budowa
WORKDIR /repo/build
RUN meson compile

# Oczyszczanie pakietów obrazu
#RUN pacman -Rcsu --noconfirm $(pacman -Qqdt)
# --- wyłączone

CMD [ "./pacman", "--version" ]
