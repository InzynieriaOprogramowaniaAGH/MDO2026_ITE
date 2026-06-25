FROM ubuntu:24.04
RUN apt-get -y update && apt-get install -y \
    git
WORKDIR /app
RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE
CMD ["/bin/bash"]