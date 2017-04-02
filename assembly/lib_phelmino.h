#define IO_ADDR 0x80000
#define NUMBER_OF_HEX_DISPLAYS 4

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
    
    *io = result;
}

void put(int n) {
    *io = n;
}

int get(void) {
    return *io;
}
