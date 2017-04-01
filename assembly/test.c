#define HEX_ADDR 0x8FFE
#define IO_ADDR  0x8FFF

int main(void) {
    int a = 17;
    int b = 41;

    int *c = (int*) HEX_ADDR;
    *c = a + b;

    return 0;
}
