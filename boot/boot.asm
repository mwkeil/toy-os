; boot.asm - minimal x86 bootloader
; Assembled with NASM

; These instructions are for the NASM Assembler only
[BITS 16]                   ; 16-bit real mode
[ORG 0x7C00]                ; Origin starts at 0x7C00

; Label the start of the bootloader
start:
    ; Segment registers

    ; Zero the general purpose register "ax" 
    ; to use it to setup the segment registers
    ; x86 doesn't allow loading immediate values 
    ; directly into a segment register
    ; and you cannot do direct arithmetic or 
    ; logic operations on segment registers
    xor ax, ax              ; One-byte shorter in machine code than "mov ax, 0"

    mov ds, ax              ; Data Segment
    mov es, ax              ; Extra Segment
    mov ss, ax              ; Stack Segment

    ; Move the Stack Pointer to the start of 
    ; our Bootloader, so that it can freely
    ; grow downward into Free Memory
    mov sp, 0x7C00          ; Stack pointer

    ; ah and al make up the full 16-bit ax register
    ; 0x0E is the BIOS interrupt teletype function
    mov ah, 0x0E            ; ah = high byte (function selector)
    ; NASM will convert 'H' to the ASCII value of 72
    mov al, 'H'             ; al = low byte (the charater)

    ; The CPU will look up what 0x10 is in the BIOS
    ; interrupt table, jump to the video handling
    ; code, read ah and al as "teletype output 72"
    ; and print to the screen
    ; BIOS video interrupt
    int 0x10

    mov al, 'e'
    int 0x10

    mov al, 'l'
    int 0x10
    int 0x10

    mov al, 'o'
    int 0x10

    cli                     ; Disable interrupts
    hlt                     ; CPU halt

; Repeat defining bytes with 0 from our current address
; until we reach 510 bytes 
times 510 - ($ - $$) db 0   ; Pad for 510 bytes with zeros 
dw 0xAA55                  ; define the "magic number" 