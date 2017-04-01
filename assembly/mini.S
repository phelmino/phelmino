.global _start

_start:
    li      x1, 100
    sw      x1, 512(x0)
    nop
    nop
    nop
    nop
    lw      x2, 512(x0)
