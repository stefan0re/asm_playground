asm_playground
==============

Small AArch64 assembly experiments for low-precision GEMM microkernels

  gemm_neon_i8i32/   int8 -> int32 with NEON SMMLA / SDOT (runs on Apple M-series)
  gemm_sme_i8i32/    int8 -> int32 with SME SMOPA (Apple M4 / SME2 capable CPU)
  gemm_sve_f8f32/    fp8 (E4M3) -> fp32 with SVE FDOT (FEAT_FP8DOT4), runs in QEMU

