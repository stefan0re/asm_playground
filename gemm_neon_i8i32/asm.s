/**
 * 8x8x8 GEMM microkernel, int8 inputs / int32 accumulators, NEON SMMLA.
 */
#ifdef __APPLE__
    .text
    .global _i8i32_neon_test
    .align 4
_i8i32_neon_test:
#else
    .text
    .global i8i32_neon_test
    .align 4
i8i32_neon_test:
#endif

    // storing callee-saved registers
    stp  d8,  d9, [sp, #-16]!
    stp d10, d11, [sp, #-16]!
    stp d12, d13, [sp, #-16]!
    stp d14, d15, [sp, #-16]!

    // load A
    ld1 {v0.8b, v1.8b, v2.8b, v3.8b}, [x0], #32
    ld1 {v4.8b, v5.8b, v6.8b, v7.8b}, [x0]

    /**
     * Transpose A
     */
    zip1 v16.16b, v0.16b, v1.16b     // rows 0..7, k 0-1
    zip1 v17.16b, v2.16b, v3.16b     // rows 0..7, k 2-3
    zip1 v18.16b, v4.16b, v5.16b     // rows 0..7, k 4-5
    zip1 v19.16b, v6.16b, v7.16b     // rows 0..7, k 6-7

    zip1 v20.8h, v16.8h, v17.8h      // rows 0..3, k 0-3
    zip2 v21.8h, v16.8h, v17.8h      // rows 4..7, k 0-3
    zip1 v22.8h, v18.8h, v19.8h      // rows 0..3, k 4-7
    zip2 v23.8h, v18.8h, v19.8h      // rows 4..7, k 4-7

    zip1 v0.4s, v20.4s, v22.4s       // rows 0,1
    zip2 v1.4s, v20.4s, v22.4s       // rows 2,3
    zip1 v2.4s, v21.4s, v23.4s       // rows 4,5
    zip2 v3.4s, v21.4s, v23.4s       // rows 6,7

    // load B
    ld1 {v4.16b, v5.16b, v6.16b, v7.16b}, [x1]

    movi v16.4s, #0
    movi v17.4s, #0
    movi v18.4s, #0
    movi v19.4s, #0
    movi v20.4s, #0
    movi v21.4s, #0
    movi v22.4s, #0
    movi v23.4s, #0
    movi v24.4s, #0
    movi v25.4s, #0
    movi v26.4s, #0
    movi v27.4s, #0
    movi v28.4s, #0
    movi v29.4s, #0
    movi v30.4s, #0
    movi v31.4s, #0

    smmla v16.4s, v4.16b, v0.16b
    smmla v17.4s, v4.16b, v1.16b
    smmla v18.4s, v4.16b, v2.16b
    smmla v19.4s, v4.16b, v3.16b
    smmla v20.4s, v5.16b, v0.16b
    smmla v21.4s, v5.16b, v1.16b
    smmla v22.4s, v5.16b, v2.16b
    smmla v23.4s, v5.16b, v3.16b
    smmla v24.4s, v6.16b, v0.16b
    smmla v25.4s, v6.16b, v1.16b
    smmla v26.4s, v6.16b, v2.16b
    smmla v27.4s, v6.16b, v3.16b
    smmla v28.4s, v7.16b, v0.16b
    smmla v29.4s, v7.16b, v1.16b
    smmla v30.4s, v7.16b, v2.16b
    smmla v31.4s, v7.16b, v3.16b

    // columns 0,1
    ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2]
    uzp1 v4.2d, v16.2d, v17.2d       // col 0, rows 0-3
    uzp1 v5.2d, v18.2d, v19.2d       // col 0, rows 4-7
    uzp2 v6.2d, v16.2d, v17.2d       // col 1, rows 0-3
    uzp2 v7.2d, v18.2d, v19.2d       // col 1, rows 4-7
    add v0.4s, v0.4s, v4.4s
    add v1.4s, v1.4s, v5.4s
    add v2.4s, v2.4s, v6.4s
    add v3.4s, v3.4s, v7.4s
    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    // columns 2,3
    ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2]
    uzp1 v4.2d, v20.2d, v21.2d
    uzp1 v5.2d, v22.2d, v23.2d
    uzp2 v6.2d, v20.2d, v21.2d
    uzp2 v7.2d, v22.2d, v23.2d
    add v0.4s, v0.4s, v4.4s
    add v1.4s, v1.4s, v5.4s
    add v2.4s, v2.4s, v6.4s
    add v3.4s, v3.4s, v7.4s
    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    // columns 4,5
    ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2]
    uzp1 v4.2d, v24.2d, v25.2d
    uzp1 v5.2d, v26.2d, v27.2d
    uzp2 v6.2d, v24.2d, v25.2d
    uzp2 v7.2d, v26.2d, v27.2d
    add v0.4s, v0.4s, v4.4s
    add v1.4s, v1.4s, v5.4s
    add v2.4s, v2.4s, v6.4s
    add v3.4s, v3.4s, v7.4s
    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2], #64

    // columns 6,7
    ld1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2]
    uzp1 v4.2d, v28.2d, v29.2d
    uzp1 v5.2d, v30.2d, v31.2d
    uzp2 v6.2d, v28.2d, v29.2d
    uzp2 v7.2d, v30.2d, v31.2d
    add v0.4s, v0.4s, v4.4s
    add v1.4s, v1.4s, v5.4s
    add v2.4s, v2.4s, v6.4s
    add v3.4s, v3.4s, v7.4s
    st1 {v0.4s, v1.4s, v2.4s, v3.4s}, [x2]

    // restoring callee-saved registers
    ldp  d14, d15, [sp], #16
    ldp  d12, d13, [sp], #16
    ldp  d10, d11, [sp], #16
    ldp   d8,  d9, [sp], #16

    ret

#ifdef __APPLE__
    .global _smmla_bench
    .align 4
_smmla_bench:
#else
    .text
    .global smmla_bench
    .align 4
smmla_bench:
#endif

    // storing callee-saved registers
    stp  d8,  d9, [sp, #-16]!
    stp d10, d11, [sp, #-16]!
    stp d12, d13, [sp, #-16]!
    stp d14, d15, [sp, #-16]!


    eor v0.16b, v0.16b, v0.16b
    eor v1.16b, v1.16b, v1.16b
    eor v2.16b, v2.16b, v2.16b
    eor v3.16b, v3.16b, v3.16b
    eor v4.16b, v4.16b, v4.16b
    eor v5.16b, v5.16b, v5.16b
    eor v6.16b, v6.16b, v6.16b
    eor v7.16b, v7.16b, v7.16b
    eor v8.16b, v8.16b, v8.16b
    eor v9.16b, v9.16b, v9.16b
    eor v10.16b, v10.16b, v10.16b
    eor v11.16b, v11.16b, v11.16b
    eor v12.16b, v12.16b, v12.16b
    eor v13.16b, v13.16b, v13.16b
    eor v14.16b, v14.16b, v14.16b
    eor v15.16b, v15.16b, v15.16b
    eor v16.16b, v16.16b, v16.16b
    eor v17.16b, v17.16b, v17.16b
    eor v18.16b, v18.16b, v18.16b
    eor v19.16b, v19.16b, v19.16b
    eor v20.16b, v20.16b, v20.16b
    eor v21.16b, v21.16b, v21.16b
    eor v22.16b, v22.16b, v22.16b
    eor v23.16b, v23.16b, v23.16b
    eor v24.16b, v24.16b, v24.16b
    eor v25.16b, v25.16b, v25.16b
    eor v26.16b, v26.16b, v26.16b
    eor v27.16b, v27.16b, v27.16b
    eor v28.16b, v28.16b, v28.16b
    eor v29.16b, v29.16b, v29.16b
    eor v30.16b, v30.16b, v30.16b
    eor v31.16b, v31.16b, v31.16b

loop_bench:
    sub x0, x0, #1

    smmla v0.4s, v30.16b, v31.16b
    smmla v1.4s, v30.16b, v31.16b
    smmla v2.4s, v30.16b, v31.16b
    smmla v3.4s, v30.16b, v31.16b
    smmla v4.4s, v30.16b, v31.16b
    smmla v5.4s, v30.16b, v31.16b
    smmla v6.4s, v30.16b, v31.16b
    smmla v7.4s, v30.16b, v31.16b
    smmla v8.4s, v30.16b, v31.16b
    smmla v9.4s, v30.16b, v31.16b

    smmla v10.4s, v30.16b, v31.16b
    smmla v11.4s, v30.16b, v31.16b
    smmla v12.4s, v30.16b, v31.16b
    smmla v13.4s, v30.16b, v31.16b
    smmla v14.4s, v30.16b, v31.16b
    smmla v15.4s, v30.16b, v31.16b
    smmla v16.4s, v30.16b, v31.16b
    smmla v17.4s, v30.16b, v31.16b
    smmla v18.4s, v30.16b, v31.16b
    smmla v19.4s, v30.16b, v31.16b

    smmla v20.4s, v30.16b, v31.16b
    smmla v21.4s, v30.16b, v31.16b
    smmla v22.4s, v30.16b, v31.16b
    smmla v23.4s, v30.16b, v31.16b
    smmla v24.4s, v30.16b, v31.16b
    smmla v25.4s, v30.16b, v31.16b
    smmla v26.4s, v30.16b, v31.16b
    smmla v27.4s, v30.16b, v31.16b
    smmla v28.4s, v30.16b, v31.16b
    smmla v29.4s, v30.16b, v31.16b


    cbnz x0, loop_bench



    // restoring callee-saved registers
    ldp  d14, d15, [sp], #16
    ldp  d12, d13, [sp], #16
    ldp  d10, d11, [sp], #16
    ldp   d8,  d9, [sp], #16

    ret