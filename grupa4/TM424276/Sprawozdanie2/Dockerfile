# Wybieramy system bazowy
FROM ubuntu:latest

# Instalujemy git-a (automatycznie potwierdzając -y)
RUN apt-get update && apt-get install -y git

# Ustawiamy folder roboczy
WORKDIR /app

# Klonujemy repozytorium 
RUN git clone https://github.com/zni4ka/MDO2026_ITE.git .

# Komenda, która wykona się po starcie kontenera
CMD ["/bin/bash"]
