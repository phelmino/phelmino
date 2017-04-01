.global _start

_start:
    li      x1, 1
    lw      x1, 512(x0)
    addi    x2, x1, 10
