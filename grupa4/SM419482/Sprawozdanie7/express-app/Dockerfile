#build
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm install

#runtime
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app /app

EXPOSE 3000
CMD ["node", "examples/hello-world/index.js"]
