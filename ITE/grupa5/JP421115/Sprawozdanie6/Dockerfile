# BUILD
FROM alpine:latest AS builder
RUN apk add --no-cache gcc make musl-dev
WORKDIR /app
COPY . .
RUN make all

# TEST 
FROM builder AS tester
RUN make test

# DEPLOY 
FROM alpine:latest AS deploy
WORKDIR /app
COPY --from=builder /app/libcjson.so /usr/lib/
CMD ["ls", "-l", "/usr/lib/libcjson.so"]
