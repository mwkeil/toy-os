#include "io.h"
#include "idt.h"
#include "isr.h"

#define IDT_ENTRIES 256

static idt_entry_t idt[IDT_ENTRIES];
static idt_descriptor_t idt_desc;

// PIC ports
#define PIC1_COMMAND 0x20
#define PIC1_DATA 0x21
#define PIC2_COMMAND 0xA0
#define PIC2_DATA 0xA1

// Add delay between PIC initialization commands
// PIC is old hardware that is slow by today's standards
// Sending a write to an unused diagnostic port 
// adds a deliberate CPU cycle delay
static void io_wait() {
    outb(0x80, 0);
}

static void pic_remap() {
    // Save masks
    uint8_t mask1 = inb(PIC1_DATA);
    uint8_t mask2 = inb(PIC2_DATA);

    // Initialize
    outb(PIC1_COMMAND, 0x11); io_wait();
    outb(PIC2_COMMAND, 0x11); io_wait();

    // New interrupt vector offsets
    // Remap IRQ0-7 to interrupts 32-39
    // Remap IRQ8-15 to interrupts 40-47
    outb(PIC1_DATA, 0x20); io_wait();
    outb(PIC2_DATA, 0x28); io_wait();

    // Master and slave PIC connection
    // Master IRQ2 pin is attached to the slave
    outb(PIC1_DATA, 0x04); io_wait();
    outb(PIC2_DATA, 0x02); io_wait();

    // 8083 mode
    outb(PIC1_DATA, 0x01); io_wait();
    outb(PIC2_DATA, 0x01); io_wait();

    // Restore the masks
    outb(PIC1_DATA, mask1);
    outb(PIC2_DATA, mask2);
}

static void idt_set_entry(int n, uint32_t handler) {
    idt[n].base_low = handler & 0xFFFF;
    idt[n].base_high = (handler >> 16) & 0xFFFF;
    idt[n].selector = 0x08;
    idt[n].zero = 0;
    idt[n].flags = 0x8E; // Present, ring 0, 32-bit interrupt gate
}

void idt_init() {
    idt_desc.limit = sizeof(idt) - 1;
    idt_desc.base = (uint32_t)idt;

    // CPU exceptions (0-31)
    idt_set_entry(0, (uint32_t)isr0);
    idt_set_entry(1, (uint32_t)isr1);
    idt_set_entry(2, (uint32_t)isr2);
    idt_set_entry(3, (uint32_t)isr3);
    idt_set_entry(4, (uint32_t)isr4);
    idt_set_entry(5, (uint32_t)isr5);
    idt_set_entry(6, (uint32_t)isr6);
    idt_set_entry(7, (uint32_t)isr7);
    idt_set_entry(8, (uint32_t)isr8);
    idt_set_entry(9, (uint32_t)isr9);
    idt_set_entry(10, (uint32_t)isr10);
    idt_set_entry(11, (uint32_t)isr11);
    idt_set_entry(12, (uint32_t)isr12);
    idt_set_entry(13, (uint32_t)isr13);
    idt_set_entry(14, (uint32_t)isr14);
    idt_set_entry(15, (uint32_t)isr15);
    idt_set_entry(16, (uint32_t)isr16);
    idt_set_entry(17, (uint32_t)isr17);
    idt_set_entry(18, (uint32_t)isr18);
    idt_set_entry(19, (uint32_t)isr19);
    idt_set_entry(20, (uint32_t)isr20);
    idt_set_entry(21, (uint32_t)isr21);
    idt_set_entry(22, (uint32_t)isr22);
    idt_set_entry(23, (uint32_t)isr23);
    idt_set_entry(24, (uint32_t)isr24);
    idt_set_entry(25, (uint32_t)isr25);
    idt_set_entry(26, (uint32_t)isr26);
    idt_set_entry(27, (uint32_t)isr27);
    idt_set_entry(28, (uint32_t)isr28);
    idt_set_entry(29, (uint32_t)isr29);
    idt_set_entry(30, (uint32_t)isr30);
    idt_set_entry(31, (uint32_t)isr31);

    // Hardware IRQs (32-47)
    idt_set_entry(32, (uint32_t)isr0);
    idt_set_entry(33, (uint32_t)isr1);
    idt_set_entry(34, (uint32_t)isr2);
    idt_set_entry(35, (uint32_t)isr3);
    idt_set_entry(36, (uint32_t)isr4);
    idt_set_entry(37, (uint32_t)isr5);
    idt_set_entry(38, (uint32_t)isr6);
    idt_set_entry(39, (uint32_t)isr7);
    idt_set_entry(40, (uint32_t)isr8);
    idt_set_entry(41, (uint32_t)isr9);
    idt_set_entry(42, (uint32_t)isr10);
    idt_set_entry(43, (uint32_t)isr11);
    idt_set_entry(44, (uint32_t)isr12);
    idt_set_entry(45, (uint32_t)isr13);
    idt_set_entry(46, (uint32_t)isr14);
    idt_set_entry(47, (uint32_t)isr15);

    pic_remap();

    // Load IDT
    __asm__ volatile ("lidt %0" : : "m"(idt_desc));

    // Re-enable interrupts
    __asm__ volatile ("sti");
}