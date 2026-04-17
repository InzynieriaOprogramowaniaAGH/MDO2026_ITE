#Build
FROM ubuntu:24.04 AS build
RUN apt-get update \
    && apt-get install -y gcc make cmake lcov libncurses-dev git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone https://github.com/deftio/C-and-Cpp-Tests-with-CI-CD-Example.git
WORKDIR /app/C-and-Cpp-Tests-with-CI-CD-Example
RUN make
CMD ["bash"]

#Test
FROM build AS test
WORKDIR /app/C-and-Cpp-Tests-with-CI-CD-Example
CMD ["./run_coverage_test.sh"]

#Deploy
FROM ubuntu:24.04 AS deploy
RUN apt-get update \
    && apt-get install -y libncurses-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build-image /app/C-and-Cpp-Tests-with-CI-CD-Example /app
CMD ["./test-library.out"]