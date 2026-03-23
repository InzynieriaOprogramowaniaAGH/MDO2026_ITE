#obraz bazowy - ubuntu
FROM ubuntu:22.04

# instalacja git-a
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

#argument na token
ARG TOKEN

#ustawienie katalogu roboczego
WORKDIR /app

#klonowanie repo z https
RUN git clone https://${GITHUB_TOKEN}@github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

#komenda po starcie
CMD ["/bin/bash"]

