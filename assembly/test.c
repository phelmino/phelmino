#define HEX_ADDR 0x3406c
#define IO_ADDR  0x34070

int *hex = (int*) HEX_ADDR;
int *io  = (int*) IO_ADDR;

void print(int n) { *hex = n; }
void put(int n) { *io = n; }
int get(void) { return *io; }

int main(void) {
    int a = 5;
    int b = 8;

    put(a << b);

    return 0;
}
