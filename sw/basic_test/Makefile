RISCV_PREFIX ?= riscv32-unknown-elf
CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=basic_test.map

all: basic_test.mem

basic_test.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

basic_test.bin: basic_test.elf
	$(OBJCOPY) -O binary $< $@

basic_test.mem: basic_test.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py basic_test.bin basic_test.mem

basic_test.dis: basic_test.elf
	$(OBJDUMP) -d basic_test.elf > basic_test.dis

clean:
	rm -f basic_test.elf basic_test.bin basic_test.mem basic_test.dis basic_test.map

.PHONY: all clean
