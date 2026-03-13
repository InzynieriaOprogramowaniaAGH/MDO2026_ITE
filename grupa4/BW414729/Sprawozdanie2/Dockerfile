FROM ubuntu:22.04

# aktualizacja , pobranie certyfiaktu do gita, i czyszczenie po apt
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Klonowanie repozytorium
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

CMD ["bash"]