FROM ubuntu:22.04 
#konkretny tag a nie latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates git && \
    rm -rf /var/lib/apt/lists/*
#apt-get i install w jednym RUN

WORKDIR /opt/app

CMD ["bash"]