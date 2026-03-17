#include "io.h"
#include "isr.h"
#include "terminal.h"

#define PIC1_COMMAND 0x20
#define PIC2_COMMAND 0xA0
#define PIC_EOI 0x20 // End of interrupt

static const char *exception_messages[] = {
    "Division by Zero",
    "Debug",
    "Non Maskable Interrupt",
    "Breakpoint",
    "Into Detected Overflow",
    "Out of Bounds",
    "Invalid Opcode",
    "No Coprocessor",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Bad TSS",
    "Segment Not Present",
    "Stack Fault",
    "General Protection Fault",
    "Page Fault",
    "Unknown Interrupt",
    "Coprocessor Fault",
    "Alignment Check",
    "Machine Check",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved"
};

void isr_handler(registers_t regs) {
    tprint("\n*** CPU EXCEPTION: ");
    tprint(exception_messages[regs.int_no]);
    tprint(" (interrupt ");
    tprintint(regs.int_no);
    tprint(") ***\n");

    // Hang
    // Exceptions are unrecoverable for now
    __asm__ volatile ("cli; hlt");
}

void irq_handler(registers_t regs) {
    if (regs.int_no >= 40) {
        outb(PIC2_COMMAND, PIC_EOI);
    }
    outb(PIC1_COMMAND, PIC_EOI);
}