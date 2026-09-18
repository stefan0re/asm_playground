/**
 * Testing fdot instruction (FEAT_FP8DOT4)
 */
    .text
    .global test_fdot_asm
    .align 4
test_fdot_asm:

    // https://arm.jonpalmisc.com/latest_sysreg/AArch64-fpmr
    // set fp8 register type (E4M3 / E5M2) and LSCALE 
    mov  x3, #0x0009
    movk x3, #0x0002, lsl #16      // -> 0x00020009
    msr    fpmr, x3

    ptrue p0.b
    ld1b { z0.b }, p0/z, [x0]
    ld1b { z1.b }, p0/z, [x1]

    fmov z2.s, p0/m, #0.0
    fdot z2.s, z0.b, z1.b

    st1w { z2.s } , p0, [x2]

    ret