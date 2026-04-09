FROM ubuntu:24.04

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y --no-install-recommends ca-certificates wget dpkg-dev gcc g++ libc6-dev libssl-dev make tcl cmake python3 python3-pip python3-venv python3-dev unzip rsync clang automake autoconf libtool

WORKDIR /scripts
COPY buildscript.sh /scripts
RUN chmod +x buildscript.sh
WORKDIR /code
CMD cp /scripts/buildscript.sh /code && /code/buildscript.sh
