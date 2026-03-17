#include "terminal.h"
#include "idt.h"

// Entry point for the kernel
// Standard library functions can't be used (printf, malloc)

// LEARNING!!
// REPLACED WITH TERMINAL.C
// // VGA text buffer address (compare to assembly)
// #define VGA_BUFFER 0xB8000

// // Color constants (compare to assembly)
// #define COLOR_WHITE_ON_BLACK 0x0F
// #define COLOR_BLACK_ON_WHITE 0xF0

// // 2-byte pointer for character & color
// unsigned short *vga = (unsigned short *)VGA_BUFFER;

// // Write to VGA starting at the given position [row:col]
// void print(const char *str, int row, int col) {
//     int i = 0;
//     // Loop until null-terminator
//     while (str[i] != '\0') {
//         // We move left to right starting in the top left
//         // Each VGA screen in 80 columns wide with i being
//         // the current string character
//         int index = row * 80 + col + i;
//         // Shift the color left by 8 bits to move it into
//         // the high byte of the 16-bit value, then OR that
//         // with the character to put the character into the
//         // low byte
//         vga[index] = (COLOR_WHITE_ON_BLACK << 8) | str[i];
//         i++;
//     }
// }

// // Start the kernel, needs to match the linker
// void kernel_begin() {
//     // Clear the screen
//     for (int i = 0; i < 80 * 25; i++) {
//         vga[i] = (COLOR_WHITE_ON_BLACK << 8) | ' ';
//     }

//     print("ToyOS 32-bit Protected Mode.", 0, 0);
//     print("Hello there!", 1, 0);

//     // End with an infinite loop so that the CPU doesn't
//     // start executing garbage from memory
//     while (1) {}
// }

void kernel_begin() {
    tinit();
    idt_init();

    tprint("ToyOS\n");
    tprint("32-bit Protected Mode.\n");
    tprint("\n");
    tprint("Interrupts enabled.\n");
    
    // tprint("Hex Test: ");
    // tprinthex(0xDEADBEEF);
    // tputchar('\n');
    
    // tprint("Int Test: ");
    // tprintint(12345);
    // tputchar('\n');

    // Test exception handler with division by zero
    int x = 1 / 0;

    while (1) {}
}