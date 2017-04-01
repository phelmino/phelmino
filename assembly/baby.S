.global _start

_start:
    li      x31, 128
    li      ra, 1
    sw      ra, 384(t6)
