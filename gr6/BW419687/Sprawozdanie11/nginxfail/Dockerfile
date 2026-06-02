FROM nginx:alpine
# Poprawna konfiguracja (kopiujemy jak poprzednio)
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
# Celowo błędne polecenie startowe – Nginx nie wystartuje
CMD ["/nie/ma/takiej"]