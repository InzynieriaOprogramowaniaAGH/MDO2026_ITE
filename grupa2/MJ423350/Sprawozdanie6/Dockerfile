#Build
FROM ubuntu:24.04 AS build
RUN apt-get update \
    && apt-get install -y gcc make cmake lcov libncurses-dev git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . /app
RUN make

#Test
FROM build AS test
CMD ["./run_coverage_test.sh"]

#Deploy
FROM ubuntu:24.04 AS deploy
RUN apt-get update \
    && apt-get install -y libncurses-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app /app
CMD ["./test-library.out"]