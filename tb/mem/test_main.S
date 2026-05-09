# =============================================================
# test_main.S  —  RV32I Bare-metal Test Program
# 메모리 맵:
#   IMEM base : 0x0000_0000
#   DMEM base : 0x0001_0000  (스택: 0x0001_4000 top)
#   GPIO_OUT  : 0x1000_0000
# =============================================================

    .section .text
    .global _start

_start:
    lui     sp, 0x14
    lui     gp, 0x10
    jal     x0, main

delay:
    beq     a0, x0, delay_done
delay_loop:
    addi    a0, a0, -1
    bne     a0, x0, delay_loop
delay_done:
    jalr    x0, ra, 0

main:
    addi    sp, sp, -48
    sw      ra,  44(sp)
    sw      s0,  40(sp)
    sw      s1,  36(sp)
    sw      s2,  32(sp)
    sw      s3,  28(sp)
    sw      s4,  24(sp)
    sw      s5,  20(sp)
    sw      s6,  16(sp)
    sw      s7,  12(sp)
    sw      s8,   8(sp)
    sw      s9,   4(sp)
    sw      s10,  0(sp)
    addi    s0, x0, 0
    lui     s1, 0x10000
    nop

while_top:
    addi    s2, s0, 0
    addi    s3, s0, 1
    add     s4, s2, s3
    sub     s5, s2, s3
    and     s6, s2, s3
    or      s7, s2, s3
    xor     s8, s2, s3
    slli    s9, s2, 2
    srli    s10, s2, 2

    sw      s4, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    sw      s5, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    sw      s6, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    sw      s7, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    sw      s8, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    sw      s9, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    sw      s10, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay

    addi    sp, sp, -16
    addi    s11, sp, 0
    sw      s0,  0(s11)
    slli    t0, s0, 1
    sw      t0,  4(s11)
    slli    t1, s0, 2
    sw      t1,  8(s11)
    lw      t2,  0(s11)
    lw      t3,  4(s11)
    lw      t4,  8(s11)
    add     t2, t2, t3
    add     t2, t2, t4
    sw      t2, 12(s11)
    sw      t2, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    addi    sp, sp, 16

    andi    t0, s0, 1
    bne     t0, x0, branch_odd
branch_even:
    lui     t1, 0xAAAAB
    addi    t1, t1, -1366
    sw      t1, 0(s1)
    jal     x0, branch_done
branch_odd:
    lui     t1, 0x55555
    addi    t1, t1, 0x555
    sw      t1, 0(s1)
branch_done:
    addi    a0, x0, 10
    jal     ra, delay

    addi    s0, s0, 1
    addi    t0, x0, 256
    bltu    s0, t0, while_top

    addi    s0, x0, 0
    lui     t1, 0xDEADC
    addi    t1, t1, -273
    sw      t1, 0(s1)
    addi    a0, x0, 10
    jal     ra, delay
    jal     x0, while_top
