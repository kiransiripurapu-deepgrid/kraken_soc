RISCV_PREFIX ?= riscv32-unknown-elf

CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
CFLAGS  += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD
CFLAGS  += -I../dronet_v3/generated
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=cutie_dma_smoke.map

all: cutie_dma_smoke.mem

cutie_dma_smoke.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

cutie_dma_smoke.bin: cutie_dma_smoke.elf
	$(OBJCOPY) -O binary $< $@

cutie_dma_smoke.mem: cutie_dma_smoke.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py cutie_dma_smoke.bin cutie_dma_smoke.mem

cutie_dma_smoke.dis: cutie_dma_smoke.elf
	$(OBJDUMP) -d cutie_dma_smoke.elf > cutie_dma_smoke.dis

clean:
	rm -f cutie_dma_smoke.elf cutie_dma_smoke.bin cutie_dma_smoke.mem cutie_dma_smoke.dis cutie_dma_smoke.map

.PHONY: all clean
