FROM ubuntu:24.04

RUN apt-get -y update && apt-get install -y --no-install-recommends git ca-certificates 

WORKDIR /repo

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git

CMD ["/bin/bash"]

