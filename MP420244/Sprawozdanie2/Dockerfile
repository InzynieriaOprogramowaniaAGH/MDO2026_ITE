FROM ubuntu:latest

ENV DEBIAN_FRONTEND=nointeractive

RUN apt-get update && \
apt-get install -y git

WORKDIR /repo

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git .

CMD ["bash"]
