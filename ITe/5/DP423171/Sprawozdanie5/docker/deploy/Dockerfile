FROM build-env-main:latest

# Minimalne środowisko dla deployment'u
RUN pacman -Rcsu --noconfirm base-devel $(pacman -Qqdt)

# Zależności deployment: meson
RUN pacman -Syu --noconfirm --asdeps meson

# Wrzuć binarkę na kontener jako prosty tarball
# FIXME: `makepkg` jako pakowanie w pakiet
# jest realną opcją dla kontenerów produkcyjnych,
# choć instalatory zwykle wykorzystują sztuczkę z
# /usr/local, co też pozwala na łatwą identyfikację
# pozostałości, jak lokalnych instalacji jest mało.
RUN meson install
WORKDIR /

# Spore oczyszczanie środowiska
RUN pacman -Rcsu --noconfirm $(pacman -Qqdt)
RUN pacman -Scc --noconfirm
RUN rm -R /var/lib/pacman/sync /var/cache/pacman/pkg /repo

# Na tym etapie korzystaj tylko z zbudowanego pacman'a
# do zarządzania pakietami. Domyślnie wyświetlaj pomoc.
ENTRYPOINT [ "/usr/local/pacman" ]
CMD [ "--help" ]
