RISCV_PREFIX ?= riscv64-unknown-elf
CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=sne_smoke.map

all: sne_smoke.mem

sne_smoke.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

sne_smoke.bin: sne_smoke.elf
	$(OBJCOPY) -O binary $< $@

sne_smoke.mem: sne_smoke.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py sne_smoke.bin sne_smoke.mem

sne_smoke.dis: sne_smoke.elf
	$(OBJDUMP) -d sne_smoke.elf > sne_smoke.dis

clean:
	rm -f sne_smoke.elf sne_smoke.bin sne_smoke.mem sne_smoke.dis sne_smoke.map

.PHONY: all clean
