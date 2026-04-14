FROM build-env-main:latest AS devenv
RUN DESTDIR=/tarball meson install
WORKDIR /

# Bazuj na czystym obrazie Arch Linux (nie-deweloperskim)
# + porzucenie warstw przez multistage Dockerfile
FROM archlinux:base
COPY --from=devenv /tarball /

# Na tym etapie korzystaj tylko z zbudowanego pacman'a
# do zarządzania pakietami. Domyślnie wyświetlaj pomoc.
# Skonfiguruj pod opcję "-v [mount]:/sysroot" dla zarządzania
# pakietami w dystrybucji [mount] (funkcją obrazu jest recovery
# i działania sysadmin na środowiskach ALPM):
ENTRYPOINT [ "/usr/local/bin/pacman", "--sysroot", "/sysroot" ]
CMD [ "--help" ]
