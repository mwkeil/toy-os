[BITS 32]

extern isr_handler
extern irq_handler

; Macro for exceptions with no error code
%macro ISR_NOERRCODE 1
global isr%1
isr%1:
    push byte 0 ; Dummy error code
    push byte %1 ; Interrupt number
    jmp common_isr
%endmacro

; Macro for exceptions that push an error code automatically
%macro ISR_ERRCODE 1
global isr%1
isr%1:
    push byte %1 ; Only push the interrupt number since the CPU already pushed the error code
    jmp common_isr
%endmacro

; Macro for hardware IRQs
%macro IRQ 2
global irq%1
irq%1:
    push byte 0
    push byte %2
    jmp common_irq
%endmacro

; CPU exceptions
ISR_NOERRCODE 0 ; Divide by zero
ISR_NOERRCODE 1 ; Debug
ISR_NOERRCODE 2 ; Nonmaskable interrupt
ISR_NOERRCODE 3 ; Breakpoint
ISR_NOERRCODE 4 ; Overflow
ISR_NOERRCODE 5 ; Bound range exceeded
ISR_NOERRCODE 6 ; Invalid opcode
ISR_NOERRCODE 7 ; Device not available
ISR_ERRCODE 8 ; Double fault
ISR_NOERRCODE 9 ; Coprocessor segment overrun
ISR_ERRCODE 10 ; Invalid TSS
ISR_ERRCODE 11 ; Segment not present
ISR_ERRCODE 12 ; Stack segment fault
ISR_ERRCODE 13 ; General protection fualt
ISR_ERRCODE 14 ; Page fault
ISR_NOERRCODE 15 ; Reserved
ISR_NOERRCODE 16 ; x87 floating point exception
ISR_ERRCODE 17 ; Alignment check
ISR_NOERRCODE 18 ; Machine check
ISR_NOERRCODE 19 ; SIMD floating point exception
ISR_NOERRCODE 20 ; Virtualization exception
ISR_NOERRCODE 21 ; Reserved
ISR_NOERRCODE 22 ; Reserved
ISR_NOERRCODE 23 ; Reserved
ISR_NOERRCODE 24 ; Reserved
ISR_NOERRCODE 25 ; Reserved
ISR_NOERRCODE 26 ; Reserved
ISR_NOERRCODE 27 ; Reserved
ISR_NOERRCODE 28 ; Reserved
ISR_NOERRCODE 29 ; Reserved
ISR_ERRCODE 30 ; Security exception
ISR_NOERRCODE 31 ; Reserved

; Hardware IRQs
; IRQ, interrupt
IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46
IRQ 15, 47

common_isr:
    pusha
    mov ax, ds
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call isr_handler

    pop eax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    popa
    add esp, 8
    iret

common_irq:
    pusha
    mov ax, ds
    push eax

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call irq_handler

    pop eax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    popa
    add esp, 8
    iret