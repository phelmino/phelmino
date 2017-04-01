.global _start

_start:
    li      x30, 20
    li      x31, 512                # base address of ram
    li      x1, 1                   # first fibonacci number
    sw      x1, 0(x31)
    addi    x31, x31, 4
    li      x2, 1                   # second fibonacci number
    sw      x2, 0(x31)
    addi    x31, x31, 4

loop:
    lw      x1, -8(x31)             # loads k-2 fibonacci number
    lw      x2, -4(x31)             # loads k-1 fibonacci number
    add     x2, x1, x2              # calculates k fibonacci number
    sw      x2, 0(x31)
    addi    x31, x31, 4             # updates base address
    addi    x30, x30, -1            # decrements number of iterations
    bne     x30, x0, loop           # back to the loop
    sw      x2, 1016(x0)            # result in hex display
