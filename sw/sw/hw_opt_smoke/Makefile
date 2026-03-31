RISCV_PREFIX ?= riscv32-unknown-elf

CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=hw_opt_smoke.map

all: hw_opt_smoke.mem

hw_opt_smoke.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

hw_opt_smoke.bin: hw_opt_smoke.elf
	$(OBJCOPY) -O binary $< $@

hw_opt_smoke.mem: hw_opt_smoke.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py hw_opt_smoke.bin hw_opt_smoke.mem

hw_opt_smoke.dis: hw_opt_smoke.elf
	$(OBJDUMP) -d hw_opt_smoke.elf > hw_opt_smoke.dis

clean:
	rm -f hw_opt_smoke.elf hw_opt_smoke.bin hw_opt_smoke.mem hw_opt_smoke.dis hw_opt_smoke.map

.PHONY: all clean
