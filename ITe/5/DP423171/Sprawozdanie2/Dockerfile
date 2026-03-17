# ArchLinux my beloved <3
FROM archlinux:latest

# Najlepsze combo: update + install
RUN pacman -Syu --noconfirm git

RUN git clone https://github.com/InzynieriaOprogramowaniaAGH/MDO2026_ITE /repo

# katalog roboczy
WORKDIR /repo

# domyślna powłoka
CMD ["bash"]
