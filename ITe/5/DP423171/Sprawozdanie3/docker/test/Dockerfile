FROM build-env-main:latest

# Zależności testów: meson
RUN pacman -Syu --noconfirm --asdeps meson

# Testy
RUN meson test || true

# Usuwanie zależności testów
RUN pacman -Rcsu --noconfirm $(pacman -Qqdt)

CMD [ "./pacman", "--version" ]
