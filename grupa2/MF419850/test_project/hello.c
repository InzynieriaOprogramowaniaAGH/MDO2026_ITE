#include <stdio.h>
#include <string.h>

int hello(const char* name) {
    if (name == NULL) return -1;
    printf("Hello, %s!\n", name);
    return 0;
}
