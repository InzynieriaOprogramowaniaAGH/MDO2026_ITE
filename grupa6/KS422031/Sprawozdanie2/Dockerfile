FROM ubuntu:latest

RUN apt update && apt install -y git ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE repo

WORKDIR /opt/repo
CMD ["/bin/bash"]