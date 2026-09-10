// Compile with: gcc driver.c asm.s -o test -march=armv8.6-a+i8mm ; ./test

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
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
                        int32_t* io_c);

extern void smmla_bench(int64_t reps);

extern void sdot_simple( int8_t* i_a,
                        int8_t* i_b,
                        int32_t* io_c);

extern void sdot_bench(int reps);

// Potential GEMV performance (decode phase)
void benchmark_sdot(){
  int64_t l_reps = 200000000;
  struct timeval l_start, l_end;
  gettimeofday(&l_start, NULL);
  smmla_bench(l_reps);
  gettimeofday(&l_end, NULL);
  double l_time = (l_end.tv_sec - l_start.tv_sec) + (l_end.tv_usec - l_start.tv_usec) / 1000000.0;
  double flops = 4*8*30*l_reps;
  double l_gflops = flops / (l_time * 1e9);
  printf("Theoretical SDOT peak:\n");
  printf("  Time: %f s, GFLOPS: %f\n", l_time, l_gflops);
}

void benchmark_smmla(){
  int64_t l_reps = 200000000;
  struct timeval l_start, l_end;
  gettimeofday(&l_start, NULL);
  smmla_bench(l_reps);
  gettimeofday(&l_end, NULL);
  double l_time = (l_end.tv_sec - l_start.tv_sec) + (l_end.tv_usec - l_start.tv_usec) / 1000000.0;
  double flops = 2*2*2*8*30*l_reps;
  double l_gflops = flops / (l_time * 1e9);
  printf("Theoretical SMMLA peak:\n");
  printf("  Time: %f s, GFLOPS: %f\n", l_time, l_gflops);
}

void run_gemv_sdot(){
  int8_t*  l_a = (int8_t*)malloc(16 * sizeof(int8_t));
  int8_t*  l_b = (int8_t*)malloc(16 * sizeof(int8_t));
  int32_t* l_c = (int32_t*)malloc(4 * sizeof(int32_t));

  for (int i = 0; i < 16; i++) {
    l_a[i] = (int8_t)i;
  }
  for (int i = 0; i < 16; i++) {
    l_b[i] = (int8_t) (i < 4) ? 1 : 0;
  }

  sdot_simple(l_a, l_b, l_c);

  for(int i = 0; i < 4; i++){
    printf("[%d]: %d\n", i, l_c[i]);
  }

}

void run_gemm_smmla(){
  int M = 8;
  int N = 8;
  int K = 8;

  int8_t* l_a = (int8_t*)malloc(M * K * sizeof(int8_t));
  int8_t* l_b = (int8_t*)malloc(N * K * sizeof(int8_t));
  int32_t* l_c = (int32_t*)malloc(M * N * sizeof(int32_t));
  int32_t* l_c_ref = (int32_t*)malloc(M * N * sizeof(int32_t));

  for (int i = 0; i < M * K; i++) {
    l_a[i] = (int8_t)(rand() % 128) - 64;
  }
  for (int i = 0; i < N * K; i++) {
    l_b[i] = (int8_t)(rand() % 128) - 64;
  }
  for (int i = 0; i < N * M; i++) {
    l_c[i] = (rand() % 200) - 100;
    l_c_ref[i] = l_c[i];
  }

  gemm_ref(M, N, K,
           M, K, M,
           'N', 'N',
           l_a, l_b, l_c_ref);

  i8i32_neon_test(l_a, l_b, l_c);

  int32_t error = 0;
  for (int i = 0; i < M * N; i++) {
    int tmp = abs(l_c[i] - l_c_ref[i]);
    if (tmp) {
      error += tmp;
      printf("%d: %d <-> %d\n", i, l_c[i], l_c_ref[i]);
    }
  }
  printf("Matmul 8x8x8:\n");
  printf("  Error: %d\n", error);

  double l_time = 0.0;
  struct timeval l_start, l_end;
  gettimeofday(&l_start, NULL);
  int64_t l_iter = 200000000;
  for(int64_t iter = 0; iter < l_iter; iter++) {
    i8i32_neon_test(l_a, l_b, l_c);
  }
  gettimeofday(&l_end, NULL);
  l_time = (l_end.tv_sec - l_start.tv_sec) + (l_end.tv_usec - l_start.tv_usec) / 1000000.0;
  double l_gflops = 2.0 * M * N * K * l_iter / (l_time * 1e9);
  printf("  Time: %f s, GFLOPS: %f\n", l_time, l_gflops);

  free(l_a);
  free(l_b);
  free(l_c);
  free(l_c_ref);
}

int main() {
  
  // benchmark_sdot();
  run_gemv_sdot();
  // benchmark_smmla();
  // run_gemm_smmla();

  return 0;
}