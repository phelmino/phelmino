.global _start

_start:
    li      x3, 0                   # 0th fibonacci number
    li      x30, 20
    #lw      x30, 1020(x0)           # number of fibonacci iterations
    beq     x30, x0, end
    li      x31, 0                  # base address of ram
    li      x3, 1                   # first fibonacci number
    sw      x3, 0(x31)
    addi    x30, x30, -1            # decrements number of iterations
    beq     x30, x0, end
    addi    x31, x31, 4
    li      x3, 1                   # second fibonacci number
    sw      x3, 0(x31)
    addi    x30, x30, -1            # decrements number of iterations
    beq     x30, x0, end
    addi    x31, x31, 4

loop:
    lw      x1, -8(x31)             # loads k-2 fibonacci number
    lw      x2, -4(x31)             # loads k-1 fibonacci number
    add     x3, x1, x2              # calculates k fibonacci number
    sw      x3, 0(x31)
    addi    x31, x31, 4             # updates base address
    addi    x30, x30, -1            # decrements number of iterations
    bne     x30, x0, loop           # back to the loop

end:    
    sw      x3, 1016(x0)            # result in hex display
