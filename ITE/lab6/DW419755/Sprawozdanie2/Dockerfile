FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .
CMD ["/bin/bash"]
