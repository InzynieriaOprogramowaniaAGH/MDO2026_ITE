FROM ubuntu:latest
RUN apt update && apt install -y git && apt clean all
WORKDIR /app
RUN git clone --depth 1 https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE.git
CMD ["/bin/bash"]