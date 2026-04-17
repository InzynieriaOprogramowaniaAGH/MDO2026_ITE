CC = gcc
CFLAGS = -Wall -Wextra -O2
SOURCES = hello.c
HEADERS = hello.h
TEST_SOURCES = test_hello.c
MAIN_SOURCES = main.c

all: hello test_runner

hello: $(SOURCES) $(HEADERS) $(MAIN_SOURCES)
	$(CC) $(CFLAGS) -static -o hello $(SOURCES) $(MAIN_SOURCES)

test_runner: $(SOURCES) $(HEADERS) $(TEST_SOURCES)
	$(CC) $(CFLAGS) -o test_runner $(SOURCES) $(TEST_SOURCES)

test: test_runner
	./test_runner

clean:
	rm -f hello test_runner

.PHONY: all test clean
