FROM ubuntu:24.04

RUN apt update && apt install -y git ca-certificates

WORKDIR /opt
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]
