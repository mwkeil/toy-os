#ifndef IDT_H
#define IDT_H

#include <stdint.h>

// IDT entry - 8 bytes
// Compare to GDT entry
typedef struct {
    uint16_t base_low; // Lower 16 bits of address
    uint16_t selector; // Code segment selector (0x08 compare to GDT)
    uint8_t zero;
    uint8_t flags; // Type and attributes
    uint16_t base_high; // Upper 16 bits of address
} __attribute__((packed)) idt_entry_t; // Don't pad the structs!

// 6 byte structure for lidt
// Compare to gdt_descriptor
typedef struct {
    uint16_t limit;
    uint16_t base;
} __attribute__((packed)) idt_descriptor_t;

void idt_init();

#endif