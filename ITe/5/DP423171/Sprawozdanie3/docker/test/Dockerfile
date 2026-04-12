FROM build-env-main:latest

# Zależności testów: te same co w obrazie dla budowy
# ...

# Testy
# (wymuszenie przejścia kroku jest dlatego, że nie chcę
# aby wynik mojej pracy był zależny od oprogramowania
# firmy trzeciej, realnie wymusza się przechodzenie testów
# w CI, czasami traktując etap testów jako opcjonalny, jeżeli
# złączony jest on w pipeline)
RUN fakechroot meson test || true

# Usuwanie zależności testów
RUN pacman -Rcsu --noconfirm $(pacman -Qqdt)

CMD [ "./pacman", "--version" ]
