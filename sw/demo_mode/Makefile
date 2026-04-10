RISCV_PREFIX ?= riscv64-unknown-elf

CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
CFLAGS  += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD
CFLAGS  += -I../dronet_v3/generated
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=demo_mode.map

all: demo_mode.mem

demo_mode.elf: ../basic/crt0.S main.c ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S main.c

demo_mode.bin: demo_mode.elf
	$(OBJCOPY) -O binary $< $@

demo_mode.mem: demo_mode.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py demo_mode.bin demo_mode.mem

demo_mode.dis: demo_mode.elf
	$(OBJDUMP) -d demo_mode.elf > demo_mode.dis

clean:
	rm -f demo_mode.elf demo_mode.bin demo_mode.mem demo_mode.dis demo_mode.map

.PHONY: all clean
