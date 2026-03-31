RISCV_PREFIX ?= riscv64-unknown-elf
CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=sne_dma_smoke.map

all: sne_dma_smoke.mem

sne_dma_smoke.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

sne_dma_smoke.bin: sne_dma_smoke.elf
	$(OBJCOPY) -O binary $< $@

sne_dma_smoke.mem: sne_dma_smoke.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py sne_dma_smoke.bin sne_dma_smoke.mem

sne_dma_smoke.dis: sne_dma_smoke.elf
	$(OBJDUMP) -d sne_dma_smoke.elf > sne_dma_smoke.dis

clean:
	rm -f sne_dma_smoke.elf sne_dma_smoke.bin sne_dma_smoke.mem sne_dma_smoke.dis sne_dma_smoke.map

.PHONY: all clean
