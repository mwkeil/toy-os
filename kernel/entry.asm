[BITS 32]

global kernel_start         ; Symbol used in the linker
extern kernel_begin         ; Symbol defined in C for NASM

kernel_start:
    call kernel_begin       ; Jump to C
    cli
    hlt