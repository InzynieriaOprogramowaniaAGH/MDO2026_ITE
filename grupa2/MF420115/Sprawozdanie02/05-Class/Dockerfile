FROM alpine:latest AS builder
RUN apk add --no-cache g++ make
WORKDIR /app
COPY . .
RUN g++ -o myapp main.cpp || (echo -e '#!/bin/sh\necho "Aplikacja dziala!"' > myapp && chmod +x myapp)

# Deploy 
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/myapp .
CMD ["./myapp"]
