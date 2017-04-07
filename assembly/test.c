#include <math.h>
#include "lib_phelmino.h"

int main(void) {
    int a = 3;
    int b = 7;

    print(a + b);
    print(a * b);
    print(a - b);
    print(b - a);
    print(a % b);
    print(b % a);
    
    return 0;
}
