# ToyOS

# Tools
ASM		= nasm			# Assembler
CC		= i686-elf-gcc	# Cross-compiler
LD		= i686-elf-ld	# GNU Linker

# Compiler Flags
CFLAGS	= -ffreestanding -O2 -Wall -Wextra -fno-exceptions

# Output
OS_IMAGE = os.img

all: $(OS_IMAGE)

# ISR Assembly
kernel/isr.o: kernel/isr.asm
	$(ASM) -f elf32 $< -o $@

# Bootlader Assembly
boot/boot.bin: boot/boot-32.asm
	$(ASM) -f bin $< -o $@

# Entry Assembly
kernel/entry.o: kernel/entry.asm
	$(ASM) -f elf32 $< -o $@

# Compile the IDT
kernel/idt.o: kernel/idt.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile the ISR
kernel/isr_c.o: kernel/isr.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile the IO
kernel/io.o: kernel/io.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile the kernel
kernel/kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile the terminal
kernel/terminal.o: kernel/terminal.c
	$(CC) $(CFLAGS) -c $< -o $@

# Link the kernel file into a flat binary
kernel/kernel.bin: kernel/entry.o kernel/kernel.o kernel/terminal.o kernel/idt.o kernel/isr.o kernel/isr_c.o kernel/io.o
	$(LD) -T linker.ld -o $@ --oformat binary kernel/entry.o kernel/kernel.o kernel/terminal.o kernel/idt.o kernel/isr.o kernel/isr_c.o kernel/io.o

# Combine bootloader and kernel
# We must pad the image to 1.44MB (floppy disk) for QEMU to recognize it
$(OS_IMAGE): boot/boot.bin kernel/kernel.bin
	dd if=/dev/zero of=$(OS_IMAGE) bs=512 count=2880
	dd if=boot/boot.bin of=$(OS_IMAGE) conv=notrunc bs=512 seek=0
	dd if=kernel/kernel.bin of=$(OS_IMAGE) conv=notrunc bs=512 seek=1

# QEMU
run: $(OS_IMAGE)
	qemu-system-i386 -drive format=raw,file=$(OS_IMAGE),index=0,media=disk

# Clean artifacts
clean:
	rm -f boot/boot.bin kernel/kernel.o kernel/kernel.bin $(OS_IMAGE)