    .text
    .global _i8_i32_test
    .align 4
_i8_i32_test:

    // start Streaming mode
    smstart
    zero {za}

    // set predication for 16 byte load (16/64)
    mov x8, #0
    mov x9, #16
    whilelt p0.b, x8, x9

    // load A
    ld1b {z0.b}, p0/z, [x0]
    add x0, x0, #16
    ld1b {z1.b}, p0/z, [x0]
    add x0, x0, #16
    ld1b {z2.b}, p0/z, [x0]
    add x0, x0, #16
    ld1b {z3.b}, p0/z, [x0]

    // load B
    ld1b {z4.b}, p0/z, [x1]
    add x1, x1, #16
    ld1b {z5.b}, p0/z, [x1]
    add x1, x1, #16
    ld1b {z6.b}, p0/z, [x1]
    add x1, x1, #16
    ld1b {z7.b}, p0/z, [x1]

    // shuffle data for SMOPA (z0[0],z1[0],z2[0],z3[0],z0[1],...) into z8
    zip {z8.b - z11.b}, {z0.b - z3.b}
    zip {z12.b - z15.b}, {z4.b - z7.b}

    // compute 16x4 X 4x16 = 16x16
    ptrue p1.b
    smopa za0.s, p1/m, p1/m, z8.b, z12.b

    // move ZA accumulator to vector
    mov w12, #0
    mova    {z0.s-z3.s}, za0v.s[w12, 0:3]
    add     w12, w12, #4
    mova    {z4.s-z7.s}, za0v.s[w12, 0:3]
    add     w12, w12, #4
    mova    {z8.s-z11.s}, za0v.s[w12, 0:3]
    add     w12, w12, #4
    mova    {z12.s-z15.s}, za0v.s[w12, 0:3]

    // store C to memory
    ptrue pn8.s
    st1w    {z0.s-z3.s}, pn8, [x2]
    addvl   x2, x2, #4
    st1w    {z4.s-z7.s}, pn8, [x2]
    addvl   x2, x2, #4
    st1w    {z8.s-z11.s}, pn8, [x2]
    addvl   x2, x2, #4
    st1w    {z12.s-z15.s}, pn8, [x2]


    smstop
    ret
