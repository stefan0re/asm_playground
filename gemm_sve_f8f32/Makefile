CFLAGS = -O2 -Wall -Wextra -march=armv9.4-a+fp8dot4
BUILD_DIR = build

all: ${BUILD_DIR}/fdot_test
	
${BUILD_DIR}/fdot_test: driver.c asm.s | ${BUILD_DIR}
	clang ${CFLAGS} driver.c asm.s -o $@

clean:
	rm -rf ${BUILD_DIR}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}