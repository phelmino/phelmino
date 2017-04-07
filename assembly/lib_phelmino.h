#define IO_ADDR 0x80000
#define NUMBER_OF_HEX_DISPLAYS 8

int *io  = (int*) IO_ADDR;

int convert_to_hex(int);
int get(void);
void print(int n);
void put(int n);

int convert_to_hex(int n) {
    int c = 0;
    int offset = 1;
    int h = 0;
    
    for (c = 0; c < NUMBER_OF_HEX_DISPLAYS; ++c) {
        h += (n % 10) * offset;
        n /= 10;
        offset *= 16;
    }

    return h;
}

int get(void) {
    return *io;
}

void print(int n) {
    *io = convert_to_hex(n);
}

void put(int n) {
    *io = n;
}
