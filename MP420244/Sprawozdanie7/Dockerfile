# ---------- BUILD STAGE ----------
FROM gcc:latest AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y git make && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example.git

WORKDIR /app/C-and-Cpp-Tests-with-CI-CD-Example

RUN make


# ---------- DEPLOY STAGE ----------
FROM debian:stable-slim AS deploy

WORKDIR /app

COPY --from=builder /app/C-and-Cpp-Tests-with-CI-CD-Example /app

CMD ["echo", "(Dockerfile: CMD [\"echo\"]) Application ready for deployment."]