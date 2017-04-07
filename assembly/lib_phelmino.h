#define IO_ADDR 0x80000
#define NUMBER_OF_HEX_DISPLAYS 8

int *io  = (int*) IO_ADDR;

unsigned convert_to_hex(int);
unsigned get(void);
void print(int n);
void put(int n);

unsigned convert_to_hex(int n) {
    unsigned c = 0;
    unsigned offset = 1;
    unsigned h = 0;
    
    for (c = 0; c < NUMBER_OF_HEX_DISPLAYS; ++c) {
        h += (n % 10) * offset;
        n /= 10;
        offset *= 16;
    }

    return h;
}

unsigned get(void) {
    return *io;
}

void print(int n) {
    *io = convert_to_hex(n);
}

void put(int n) {
    *io = n;
}
