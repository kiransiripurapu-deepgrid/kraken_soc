RISCV_PREFIX ?= riscv32-unknown-elf

CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
CFLAGS  += -I../dronet_v3/generated
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=multimodal_smoke.map
DRONET_PAYLOAD_CFLAGS := -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE14_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
DRONET_CFLAGS := $(CFLAGS) $(DRONET_PAYLOAD_CFLAGS) -Dmain=dronet_cutie_entry

all: multimodal_smoke.mem

../dronet_v3/generated/cutie_dronet_assets.h:
	$(MAKE) -C ../dronet_v3 generated/cutie_dronet_assets.h RISCV_PREFIX=$(RISCV_PREFIX)

multimodal_main.o: main.c ../dronet_v3/generated/cutie_dronet_assets.h
	$(CC) $(CFLAGS) -c -o $@ main.c

dronet_cutie_entry.o: ../dronet_v3/dronet_v3_driver.c ../dronet_v3/generated/cutie_dronet_assets.h
	$(CC) $(DRONET_CFLAGS) -c -o $@ ../dronet_v3/dronet_v3_driver.c

multimodal_smoke.elf: ../basic/crt0.S multimodal_main.o dronet_cutie_entry.o ../basic/link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S multimodal_main.o dronet_cutie_entry.o

multimodal_smoke.bin: multimodal_smoke.elf
	$(OBJCOPY) -O binary $< $@

multimodal_smoke.mem: multimodal_smoke.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py multimodal_smoke.bin multimodal_smoke.mem

multimodal_smoke.dis: multimodal_smoke.elf
	$(OBJDUMP) -d multimodal_smoke.elf > multimodal_smoke.dis

clean:
	rm -f multimodal_smoke.elf multimodal_smoke.bin multimodal_smoke.mem multimodal_smoke.dis multimodal_smoke.map multimodal_main.o dronet_cutie_entry.o

.PHONY: all clean
