#include <assert.h>
#include <stdio.h>
#include <string.h>

extern int hello(const char* name);

void test_hello_valid() {
    assert(hello("Test") == 0);
    printf("✓ Test valid passed\n");
}

void test_hello_null() {
    assert(hello(NULL) == -1);
    printf("✓ Test null passed\n");
}

int main() {
    test_hello_valid();
    test_hello_null();
    printf("All tests passed!\n");
    return 0;
}
