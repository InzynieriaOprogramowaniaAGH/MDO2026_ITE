#Kontener build
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

#Kontener test
FROM builder AS tester
RUN npm test

#Kontener deploy
FROM node:20-slim AS deploy
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app .
EXPOSE 3000
CMD ["npm", "start"]
