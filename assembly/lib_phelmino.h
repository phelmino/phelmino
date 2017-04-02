#define HEX_ADDR 0x3406c
#define IO_ADDR  0x34070
#define NUMBER_OF_HEX_DISPLAYS 4

int *hex = (int*) HEX_ADDR;
int *io  = (int*) IO_ADDR;

void print(int n) {
    int c = 0;
    int result = 0;
    int offset = 1;
    
    for (c = 0; c < NUMBER_OF_HEX_DISPLAYS; ++c) {
        result += (n % 10) * offset;
        n /= 10;
        offset *= 16;
    }
    
    *hex = result;
}

void put(int n) {
    *io = n;
}

int get(void) {
    return *io;
}
