FROM archlinux:latest

# Zależności
RUN pacman -Syu --noconfirm --asdeps base-devel meson git doxygen asciidoc
# Klon repo
RUN git clone -b v7.1.0 https://gitlab.archlinux.org/pacman/pacman.git /repo
WORKDIR /repo

# Konfiguracja dla budowy
RUN meson --prefix=/usr \
    --buildtype=plain \
    -Ddoc=enabled \
    -Ddoxygen=enabled \
    -Dscriptlet-shell=/usr/bin/bash \
    -Dldconfig=/usr/bin/ldconfig \
    build

# Budowa
WORKDIR /repo/build
RUN meson compile

# Oczyszczanie pakietów obrazu
RUN pacman -Rcsu --noconfirm $(pacman -Qqdt)

CMD [ "./pacman", "--version" ]
