FROM ubuntu:22.04

# Pobieranie zależności
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    automake \
    libtool-bin \
    pkg-config \
    git \
    libogg-dev \
    gettext

# Przygotowanie użytkownika
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

# Klonowanie
RUN git clone https://gitlab.xiph.org/xiph/flac.git flac

# Build
WORKDIR /home/builder/flac
RUN ./autogen.sh && \
    ./configure && \
    make -j$(nproc)