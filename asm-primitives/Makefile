NASM=nasm
CC=gcc
CFLAGS=-Wall -O3 -fPIC

# Output files
ASM_OBJ=hash.o
SHARED_LIB=libvaultedge_asm.so
TEST_BIN=test_hash

.PHONY: all clean test

all: $(SHARED_LIB) $(TEST_BIN)

# Assemble the .asm file
$(ASM_OBJ): hash.asm
	$(NASM) -f elf64 -o $(ASM_OBJ) hash.asm

# Create shared library
$(SHARED_LIB): $(ASM_OBJ)
	$(CC) -shared -o $(SHARED_LIB) $(ASM_OBJ)

# Build test program
$(TEST_BIN): $(SHARED_LIB) test.c
	$(CC) $(CFLAGS) -o $(TEST_BIN) test.c -L. -lvaultedge_asm -Wl,-rpath,.

test: $(TEST_BIN)
	./$(TEST_BIN)

clean:
	rm -f $(ASM_OBJ) $(SHARED_LIB) $(TEST_BIN)

benchmark: $(TEST_BIN)
	@echo "Running benchmarks..."
	./$(TEST_BIN) benchmark
