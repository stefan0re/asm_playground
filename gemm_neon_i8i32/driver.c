// Compile with: gcc -march=v9-a+sme2 driver.c asm.s -o test

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

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

extern void i8i32_neon_test(int8_t* i_a,
                        int8_t* i_b,
                        int8_t* io_c);

int main() {
  int M = 16;
  int N = 16;
  int K = 8;

  int8_t* l_a = (int8_t*)malloc(M * K * sizeof(int8_t));
  int8_t* l_b = (int8_t*)malloc(N * K * sizeof(int8_t));
  int8_t* l_c = (int8_t*)malloc(M * N * sizeof(int8_t));
  int32_t* l_c_ref = (int32_t*)malloc(M * N * sizeof(int32_t));

  for (int i = 0; i < M * K; i++) {
    l_a[i] = (int8_t) i % 16;
    // l_a[i] = (int8_t)(rand() % 128) - 64;
  }
  for (int i = 0; i < N * K; i++) {
    l_b[i] = (int8_t)(rand() % 128) - 64;
  }
  for (int i = 0; i < N * M; i++) {
    l_c[i] = 0;
    l_c_ref[i] = 0;
  }

  gemm_ref(M, N, K,
           M, N, M,
           'N', 'T',
           l_a, l_b, l_c_ref);

  i8i32_neon_test(l_a, l_b, l_c);

  printf("C:\n");
  for (int j = 0; j < N; j++) {
    for (int i = 0; i < M; i++) {
      printf("%d ", l_c[i * N + j]);
    }
    printf("\n");
  }

  return 0;

  int32_t error = 0;
  for (int i = 0; i < 16 * 16; i++) {
    int tmp = abs(l_c[i] - l_c_ref[i]);
    if (tmp) {
      error += tmp;
      printf("%d: %d <-> %d\n", i, l_c[i], l_c_ref[i]);
    }
  }

  printf("Error: %d\n", error);

  return 0;
}