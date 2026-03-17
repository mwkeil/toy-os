#include "io.h"

// Write a byte to a hardware IO port
// Compiles to assembly
// mov al, value
// mov dx, port
// outb al, dx
void outb(uint16_t port, uint8_t value) {
    __asm__ volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

// Read a byte from a hardware IO port
// Compiles to assembly
// mov dx, port
// inb al, dx
uint8_t inb(uint16_t port) {
    uint8_t value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}