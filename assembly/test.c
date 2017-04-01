#define HEX_ADDR 0x3406C
#define IO_ADDR  0x34070

int *hex = (int*) HEX_ADDR;
int *io  = (int*) IO_ADDR;

void print(int n) {
    *hex = n;
}

void put(int n) {
    *io = n;
}

int main(void) {
    int a = 17;
    int b = 41;

    print(a+b);
    put(a+b);

    return 0;
}
