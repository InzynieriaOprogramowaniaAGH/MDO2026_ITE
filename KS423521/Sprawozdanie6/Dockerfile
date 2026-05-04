# BUILD
FROM node:20-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# TEST
FROM build AS test
RUN npm test

# DEPLOY
FROM node:20-alpine AS deploy
WORKDIR /app
COPY --from=build /app/dist ./dist 
COPY --from=build /app/package*.json ./
ENTRYPOINT ["node", "bin/markdown-it.js"]