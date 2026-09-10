CFLAGS = -O3 -Wall -Wextra -march=armv8.6-a+i8mm
BUILD_DIR = build

all: ${BUILD_DIR}/smmla_test
	
${BUILD_DIR}/smmla_test: driver.c asm.s | ${BUILD_DIR}
	gcc ${CFLAGS} driver.c asm.s -o $@

clean:
	rm -rf ${BUILD_DIR}

${BUILD_DIR}:
	mkdir -p ${BUILD_DIR}