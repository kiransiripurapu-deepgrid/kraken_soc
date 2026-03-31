RISCV_PREFIX ?= riscv32-unknown-elf
CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T link.ld -nostdlib -nostartfiles -Wl,-Map=hello.map

all: hello.mem

hello.elf: crt0.S hello.c link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ crt0.S hello.c

hello.bin: hello.elf
	$(OBJCOPY) -O binary $< $@

hello.mem: hello.bin elf_to_mem.py
	python3 elf_to_mem.py hello.bin hello.mem

hello.dis: hello.elf
	$(OBJDUMP) -d hello.elf > hello.dis

clean:
	rm -f hello.elf hello.bin hello.mem hello.dis hello.map

.PHONY: all clean
