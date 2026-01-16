; Fast hash function for token validation
; x86-64 Assembly (NASM syntax)
; Purpose: Demonstrate low-level optimization for hot-path operations

section .text
global fast_hash

; Function: fast_hash
; Input: rdi = pointer to data
;        rsi = length of data
; Output: rax = hash value (64-bit)
fast_hash:
    push rbp
    mov rbp, rsp
    
    ; Initialize hash to FNV offset basis
    mov rax, 0xcbf29ce484222325
    
    ; Check if length is zero
    test rsi, rsi
    jz .done
    
    ; Load multiplier (FNV prime)
    mov r8, 0x100000001b3
    
.loop:
    ; XOR with byte
    movzx r9, byte [rdi]
    xor rax, r9
    
    ; Multiply by FNV prime
    imul rax, r8
    
    ; Advance pointer and decrement counter
    inc rdi
    dec rsi
    jnz .loop
    
.done:
    pop rbp
    ret

; Function: validate_token
; Input: rdi = token pointer
;        rsi = token length
;        rdx = expected hash
; Output: rax = 1 if valid, 0 if invalid
global validate_token
validate_token:
    push rbp
    mov rbp, rsp
    push rdx              ; Save expected hash
    
    ; Calculate hash
    call fast_hash
    
    ; Compare with expected
    pop rdx
    cmp rax, rdx
    sete al               ; Set AL to 1 if equal, 0 otherwise
    movzx rax, al         ; Zero-extend to 64 bits
    
    pop rbp
    ret

; Function: const_time_compare
; Purpose: Constant-time string comparison (security-critical)
; Input: rdi = string1 pointer
;        rsi = string2 pointer
;        rdx = length
; Output: rax = 1 if equal, 0 if not equal
global const_time_compare
const_time_compare:
    push rbp
    mov rbp, rsp
    
    xor rax, rax          ; result = 0
    test rdx, rdx
    jz .done
    
.loop:
    movzx r8, byte [rdi]
    movzx r9, byte [rsi]
    xor r8, r9            ; XOR the bytes
    or rax, r8            ; Accumulate differences
    
    inc rdi
    inc rsi
    dec rdx
    jnz .loop
    
.done:
    ; If rax is 0, strings are equal
    test rax, rax
    setz al
    movzx rax, al
    
    pop rbp
    ret
