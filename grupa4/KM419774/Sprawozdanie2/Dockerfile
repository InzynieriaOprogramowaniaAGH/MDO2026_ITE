FROM ubuntu:22.04

# Instalacja git
RUN apt update && apt install -y git && rm -rf /var/lib/apt/lists/*

# Klonowanie repozytorium
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git /home/devops/MDO2026_ITE

WORKDIR /home/devops/MDO2026_ITE
CMD ["/bin/bash"]
