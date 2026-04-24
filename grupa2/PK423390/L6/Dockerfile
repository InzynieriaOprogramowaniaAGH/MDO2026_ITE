# ETAP 1: Build
FROM node:20-bookworm AS build
WORKDIR /app
RUN git clone --branch v5.1.0 --depth 1 https://github.com/expressjs/express.git .
RUN npm install

# ETAP 2: Test
FROM build AS test
CMD ["npm", "test"]

# ETAP 3: Deploy
FROM node:20-bookworm-slim AS deploy
WORKDIR /app
COPY --from=build /app /app
EXPOSE 3000
CMD ["node", "examples/hello-world/index.js"]