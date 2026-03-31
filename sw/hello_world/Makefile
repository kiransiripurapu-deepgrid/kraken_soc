RISCV_PREFIX ?= riscv64-unknown-elf
CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=hello_world.map

all: hello_world.mem

hello_world.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

hello_world.bin: hello_world.elf
	$(OBJCOPY) -O binary $< $@

hello_world.mem: hello_world.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py hello_world.bin hello_world.mem

hello_world.dis: hello_world.elf
	$(OBJDUMP) -d hello_world.elf > hello_world.dis

clean:
	rm -f hello_world.elf hello_world.bin hello_world.mem hello_world.dis hello_world.map

.PHONY: all clean
