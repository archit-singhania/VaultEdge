#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

// Assembly function declarations
extern uint64_t fast_hash(const char* data, size_t length);
extern int validate_token(const char* token, size_t length, uint64_t expected_hash);
extern int const_time_compare(const char* str1, const char* str2, size_t length);

// Pure C implementation for comparison
uint64_t c_fnv1a_hash(const char* data, size_t length) {
    uint64_t hash = 0xcbf29ce484222325ULL;
    const uint64_t prime = 0x100000001b3ULL;
    
    for (size_t i = 0; i < length; i++) {
        hash ^= (uint8_t)data[i];
        hash *= prime;
    }
    
    return hash;
}

void print_test_result(const char* test_name, int passed) {
    printf("[%s] %s\n", passed ? "PASS" : "FAIL", test_name);
}

int main(int argc, char** argv) {
    printf("=== VaultEdge Assembly Primitives Test Suite ===\n\n");
    
    // Test 1: Basic hashing
    const char* test_data = "transaction_token_12345";
    size_t test_len = strlen(test_data);
    uint64_t asm_hash = fast_hash(test_data, test_len);
    uint64_t c_hash = c_fnv1a_hash(test_data, test_len);
    
    printf("Test Data: \"%s\"\n", test_data);
    printf("ASM Hash: 0x%016lx\n", asm_hash);
    printf("C Hash:   0x%016lx\n", c_hash);
    print_test_result("Hash correctness", asm_hash == c_hash);
    printf("\n");
    
    // Test 2: Token validation
    int valid = validate_token(test_data, test_len, asm_hash);
    print_test_result("Token validation (valid)", valid == 1);
    
    int invalid = validate_token(test_data, test_len, asm_hash + 1);
    print_test_result("Token validation (invalid)", invalid == 0);
    printf("\n");
    
    // Test 3: Constant-time comparison
    const char* str1 = "secure_token_abc123";
    const char* str2 = "secure_token_abc123";
    const char* str3 = "secure_token_abc124";
    
    int cmp_equal = const_time_compare(str1, str2, strlen(str1));
    print_test_result("Constant-time compare (equal)", cmp_equal == 1);
    
    int cmp_diff = const_time_compare(str1, str3, strlen(str1));
    print_test_result("Constant-time compare (different)", cmp_diff == 0);
    printf("\n");
    
    // Benchmark
    if (argc > 1 && strcmp(argv[1], "benchmark") == 0) {
        printf("=== Performance Benchmark ===\n");
        const int iterations = 1000000;
        
        // Benchmark ASM implementation
        clock_t start = clock();
        for (int i = 0; i < iterations; i++) {
            fast_hash(test_data, test_len);
        }
        clock_t end = clock();
        double asm_time = ((double)(end - start)) / CLOCKS_PER_SEC;
        
        // Benchmark C implementation
        start = clock();
        for (int i = 0; i < iterations; i++) {
            c_fnv1a_hash(test_data, test_len);
        }
        end = clock();
        double c_time = ((double)(end - start)) / CLOCKS_PER_SEC;
        
        printf("Iterations: %d\n", iterations);
        printf("ASM time: %.4f seconds (%.2f M ops/sec)\n", 
               asm_time, iterations / asm_time / 1000000.0);
        printf("C time:   %.4f seconds (%.2f M ops/sec)\n", 
               c_time, iterations / c_time / 1000000.0);
        printf("Speedup:  %.2fx\n", c_time / asm_time);
    }
    
    printf("\n=== All Tests Complete ===\n");
    return 0;
}
