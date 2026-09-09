/**
 * GEMM implementation for int8_t and int32_t using NEON
 */

    .text
    .global _i8i32_neon_test
    .align 4
_i8i32_neon_test:

    // store callee-saved registers
    stp  d8,  d9, [sp, #-16]!
    stp d10, d11, [sp, #-16]!
    stp d12, d13, [sp, #-16]!
    stp d14, d15, [sp, #-16]!


    // load A
    ld1 {v0.16b, v1.16b, v2.16b, v3.16b}, [x0]
    add x0, x0, #64
    ld1 {v4.16b, v5.16b, v6.16b, v7.16b}, [x0]

    // load B
    ld1 {v8.16b, v9.16b, v10.16b, v11.16b}, [x1]
    add x1, x1, #64
    ld1 {v12.16b, v13.16b, v14.16b, v15.16b}, [x1]


    /**
     * Transform A to SMMLA layout
     */
    zip1 v16.16b, v0.16b, v1.16b
    zip1 v17.16b, v2.16b, v3.16b
    zip1 v18.16b, v4.16b, v5.16b
    zip1 v19.16b, v6.16b, v7.16b

    zip1 v20.16b, v16.16b, v17.16b
    zip1 v21.16b, v18.16b, v19.16b
    zip2 v22.16b, v16.16b, v17.16b
    zip2 v23.16b, v18.16b, v19.16b
    
    zip1 v16.16b, v20.16b, v21.16b
    zip2 v17.16b, v20.16b, v21.16b
    zip1 v18.16b, v22.16b, v23.16b
    zip2 v19.16b, v22.16b, v23.16b

    // st1 {v16.16b, v17.16b, v18.16b, v19.16b}, [x2]
    
    add x2, x2, #64

    // ===========================

    zip2 v16.16b, v0.16b, v1.16b
    zip2 v17.16b, v2.16b, v3.16b
    zip2 v18.16b, v4.16b, v5.16b
    zip2 v19.16b, v6.16b, v7.16b

    zip1 v20.16b, v16.16b, v17.16b
    zip1 v21.16b, v18.16b, v19.16b
    zip2 v22.16b, v16.16b, v17.16b
    zip2 v23.16b, v18.16b, v19.16b
    
    zip1 v16.16b, v20.16b, v21.16b
    zip2 v17.16b, v20.16b, v21.16b
    zip1 v18.16b, v22.16b, v23.16b
    zip2 v19.16b, v22.16b, v23.16b

    // st1 {v16.16b, v17.16b, v18.16b, v19.16b}, [x2]

    /**
     * Transform A to SMMLA layout
     */

    // restore callee-saved registers
    ldp d14, d15, [sp], #16
    ldp d12, d13, [sp], #16
    ldp d10, d11, [sp], #16
    ldp  d8,  d9, [sp], #16

    ret