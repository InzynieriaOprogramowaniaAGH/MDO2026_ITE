# ETAP 1: Instalacja paczek
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# ETAP 2: Uruchomienie testów (Zatrzymie się, jeśli testy nie przejdą)
FROM build AS test
RUN npm test > test_results.txt || (cat test_results.txt && exit 1)

# ETAP 3: Obraz finalny (Deploy - czysty, bez narzędzi deweloperskich)
FROM node:20-alpine AS deploy
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY src ./src
COPY .env.sample .env
EXPOSE 5000
CMD ["npm", "start"]
