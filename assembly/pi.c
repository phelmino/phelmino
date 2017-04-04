
#include "lib_phelmino.h"

#define SCALE 10000  
#define ARRINIT 2000  
#define DIGITS  20

int main(int argc, char** argv) {  
    int carry = 0;  
    int arr[DIGITS + 1];  
    for (int i = 0; i <= DIGITS; ++i)  
        arr[i] = ARRINIT;  
    for (int i = DIGITS; i > 0; i-= 14) {  
        int sum = 0;  
        for (int j = i; j > 0; --j) {  
            sum = sum * j + SCALE * arr[j];  
            arr[j] = sum % (j * 2 - 1);  
            sum /= j * 2 - 1;  
        }  
        print(carry + sum / SCALE);  
        carry = sum % SCALE;  
    }
    return 0;
}
