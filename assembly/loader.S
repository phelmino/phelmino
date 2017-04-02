.global _start

_start:
    li      x1, 10
    li      x2, 2000
    sw      x1, 0(x2)
    nop
    lw      x1, 0(x1)
    lw      x1, 0(x1)
