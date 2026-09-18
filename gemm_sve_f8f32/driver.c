/**
 * using fp8 as E4M3
 **/

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <arm_neon.h>

void gemm_ref(int64_t i_m,
              int64_t i_n,
              int64_t i_k,
              int64_t i_lda,
              int64_t i_ldb,
              int64_t i_ldc,
              char i_trans_a,
              char i_trans_b,
              int8_t* i_a,
              int8_t* i_b,
              int32_t* i_c) {
  for (int64_t l_m = 0; l_m < i_m; l_m++) {
    for (int64_t l_n = 0; l_n < i_n; l_n++) {
      int32_t l_sum = 0;
      for (int64_t l_k = 0; l_k < i_k; l_k++) {
        int32_t l_a = (i_trans_a == 'N') ? i_a[l_k * i_lda + l_m] : i_a[l_m * i_lda + l_k];
        int32_t l_b = (i_trans_b == 'N') ? i_b[l_n * i_ldb + l_k] : i_b[l_k * i_ldb + l_n];
        l_sum += l_a * l_b;
      }
      i_c[l_n * i_ldc + l_m] += l_sum;
    }
  }
}

extern void test_fdot_asm(uint8_t* i_a,
                          uint8_t* i_b,
                          float* io_c);

void test_fdot(){
  printf("Testing FDOT FP8 -> FP32 \n");

  uint8_t * in0  = (uint8_t*)malloc(16 * sizeof(int8_t));
  uint8_t * in1  = (uint8_t*)malloc(16 * sizeof(int8_t));
  float * out = (float*)malloc(4 * sizeof(float));

  // value_fp8 = (-1)^sign × 2^(exponent - 7) × (1 + mantissa / 8)
  // setting all values with 2.0
  for(int i = 0; i < 16; i++){
    in0[i] = 0x40;
    in1[i] = 0x40;
    if(i < 4) 
      out[i] = 0.0;
  }

  test_fdot_asm(in0, in1, out);

  // result per value: 2*2*4 * 2^(-2) ((LSCALE)) = 4.0
  for(int i = 0; i < 4; i++){
    printf("out[%d]: %f\n", i, out[i]);
  }
}


int main() {
  test_fdot();
  
  return 0;
}