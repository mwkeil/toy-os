; boot-32.asm
[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; BIOS interrupts don't work in protected mode
    ; disable now before the CPU tries to handle
    ; a BIOS interrupt using the old interrupt table
    cli

    ; Load Global Descriptor Table at the address
    ; gdt_descriptor
    lgdt [gdt_descriptor]

    ; Switch to Protected Mode
    mov eax, cr0                ; eax is the 32-bit version of the ax register
    or eax, 0x1                 ; Flip bit 0 which is the "Protected Mode Enable" bit
    mov cr0, eax

    ; Switch cs to segment selector 0x08 (8 byte offset 
    ; because the null descriptor is at 0x00 and is 8 
    ; bytes wide) and jump to the address start_protected_mode
    ; Without this cs would still hold the Real Mode value 
    ; and cs can only be updated with special cases like jmp
    jmp 0x08:start_protected_mode

; Define GDT
; https://wiki.osdev.org/Global_Descriptor_Table
; Each entry is 8 bytes
; Null - 8 bytes
; Code - 8 bytes
; Data - 8 bytes
gdt_start:
; GDT base + 0x00
; Required by the CPU and used as a safety net in cases
; where code tries to use 0x00 the CPU will raise a fault
gdt_null:                       ; Null descriptor
    dd 0x0                      ; 4 bytes of zeros
    dd 0x0                      ; 4 bytes of zeros

; GDT base + 0x08
; Limit should equal 20 bits
; Base should equal 32 bits
gdt_code:                       ; Code segment descriptor
    ; Limit is the size of the segment minus 1
    dw 0xFFFF                   ; Limit (bits 0-15)

    ; Base is where in memory the segment starts
    dw 0x0                      ; Base (bits 0-15)
    db 0x0                      ; Base (bits 16-23)
    
    ; Write these in binary "--------b" format to easily verify each bit
    ; Bit 7: Exists: If this is 0, the CPU will throw a General 
    ;   Protection Fault and crash
    ; Bits 6-5: Privilege level: x86 has 4 rings numbered 0-3
    ;   00: ring 0 (kernel level, can do anything)
    ;   11: ring 3 (user, restricted privilege)
    ;   1 and 2 are almost never used. For our use, everything will be
    ;   ring 0, but normally if a ring 3 tries to access a ring 0
    ;   segment, a fault is thrown
    ; Bit 4: Descriptor: this is a code/data segment (0 would be a system segment)
    ; Bit 3: Executable: this segment contains code that can and should be executed
    ;   Setting this to 0 would mark this as a data segment (see Conforming/Direction)
    ; Bit 2: Conforming/Direction: code in this segment can only run at ring 0
    ;   Conforming for code segments
    ;   Direction for data segments
    ; Bit 1: Readable; the code segment can be read as well as executed
    ;   For code segments, setting this to 0 would disallow constants and literals from being read
    ;   For data segmenets, setting this to 0 would make it read-only, while 1 makes it writable
    ; Bit 0: Accessed: the CPU sets this when it uses the segment - initialize it to 0
    db 10011010b                ; Access byte

    ; Bit 7: Granularity: when 1, measured in 4KB blocks rather than bytes. 
    ;   So our limit means 0xFFFFF * 4096 bytes = 4GB
    ; Bit 6: Size flag: 0 is 16-bit, while 1 is 32-bit 
    ; Bit 5: Long mode flag: mutually exclusive with size,
    ;   never set both to 1. 1 means 64-bit mode
    ; Bit 4: Reserved for Intel, undefined use
    ; Bits 3-0: The high nibble of the limit (bits 16-19)
    db 11001111b                ; Flags & limit
    db 0x0                      ; Base (bits 24-31)

; GDT base + 0x10
; The only difference between this and code is that we mark bit 3 (Executable)
; as 0 and bit 1 (Readable) as 1 to make it writable
gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size in bytes minus 1. Calculated at assembly time
    dd gdt_start                ; GDT address

; 32-bit Protected Mode
[BITS 32]
start_protected_mode:
    ; Update all data ssegment registers to point to the gdt_data segment (0x10)
    ; Since these registers are only 16-bit, we stick with ax here instead of eax
    ; ax   =                  [ lower 16 bits  ]
    ; ah   =                  [bits8-15]
    ; al   =                          [bits 0-7]
    ; eax  =  [          full 32 bits          ]
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; New stack in memory
    ; 32-bit version of sp
    mov esp, 0x90000

    mov byte [0xB8000], 'H'     ; Character
    mov byte [0xB8001], 0x0F    ; Color: White (F) on Black (0)

    mov byte [0xB8002], 'I'
    mov byte [0xB8003], 0xF0    ; Color: Black (0) on White (F)

    cli
    hlt

times 510 - ($ - $$) db 0
dw 0xAA55