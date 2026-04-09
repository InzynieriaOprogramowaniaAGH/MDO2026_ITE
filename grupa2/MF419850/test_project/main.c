#include <stdio.h>
#include "hello.h"

int main(int argc, char* argv[]) {
    const char* name = (argc > 1) ? argv[1] : "World";
    return hello(name);
}
