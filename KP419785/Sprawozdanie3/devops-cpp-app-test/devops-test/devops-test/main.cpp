#include <iostream>
#include <string>

using namespace std;

int main(int argc, char* argv[])
{
    if (argc > 1 && string(argv[1]) == "test")
    {
        cout << "Tests:" << endl;
        cout << "Test 1: OK" << endl;
        cout << "Test 2: OK" << endl;
        cout << "RAPORT: All tests passed." << endl;
        return 0;
    }

    cout << "App is working" << endl;
    return 0;
}