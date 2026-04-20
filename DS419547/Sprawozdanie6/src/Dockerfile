# Build
FROM node:20-bookworm AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Test
FROM build AS test
RUN npm test

# Runtime
FROM node:20-bookworm-slim AS runtime
WORKDIR /app
# Kopiujemy tylko co potrzebne z etapu build
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --only=production
EXPOSE 3000
# Komenda startowa
CMD ["node", "dist/main"]