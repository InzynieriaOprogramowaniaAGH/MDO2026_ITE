#obraz bazowy
FROM ubuntu:24.04

#instalacja gita 
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

#ustawienie katalogu roboczego
WORKDIR /app

#klonowanie repo 
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

#uruchomienie basha
CMD ["/bin/bash"]