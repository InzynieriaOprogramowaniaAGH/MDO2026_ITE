#lekki obraz bazowy
FROM alpine:latest

#instalacja gita i czyszczenie cache
RUN apk update && apk add --no-cache git

#ustalenie folderu roboczego
WORKDIR /app

#sklonowanie repozytorium do bieżącego folderu
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

#domyślne polecenie po startcie kontenera - odpalanie shella, bez tego kontener by się wyłączył
CMD ["/bin/sh"]