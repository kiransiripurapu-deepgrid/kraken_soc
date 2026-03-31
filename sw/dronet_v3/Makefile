RISCV_PREFIX ?= riscv32-unknown-elf
PAYLOAD_MODE ?= smoke
VALIDATE_READBACK ?= 0
CC      := $(RISCV_PREFIX)-gcc
OBJCOPY := $(RISCV_PREFIX)-objcopy
OBJDUMP := $(RISCV_PREFIX)-objdump

CFLAGS  := -march=rv32imc -mabi=ilp32 -mcmodel=medlow -ffreestanding -nostdlib -nostartfiles -Os
LDFLAGS := -T ../basic/link.ld -nostdlib -nostartfiles -Wl,-Map=dronet_v3_driver.map

ifeq ($(PAYLOAD_MODE),full)
CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_FULL_PAYLOAD
else ifeq ($(PAYLOAD_MODE),stage0)
CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE0_PAYLOAD
else ifeq ($(PAYLOAD_MODE),stage0_preload)
CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE0_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage2_preload)
CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE2_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage3_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE3_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage4_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE4_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage5_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE5_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage6_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE6_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage7_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE7_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage8_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE8_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage9_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE9_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage10_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE10_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage11_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE11_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage12_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE12_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage13_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE13_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage14_hardware_preload)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE14_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
else ifeq ($(PAYLOAD_MODE),stage14_software)
	CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_STAGE14_SOFTWARE
else ifeq ($(PAYLOAD_MODE),partial)
	CFLAGS += -DCUTIE_DRONET_USE_PARTIAL_PAYLOAD
else ifeq ($(PAYLOAD_MODE),full_preload)
CFLAGS += -DCUTIE_DRONET_INCLUDE_FULL_PAYLOAD -DCUTIE_DRONET_USE_FULL_PAYLOAD -DCUTIE_DRONET_ASSUME_PRELOADED
endif

ifeq ($(VALIDATE_READBACK),1)
CFLAGS += -DCUTIE_DRONET_VALIDATE_READBACK
endif

all: dronet_v3_driver.mem

manifest:
	python3 ../../scripts/export_dronet_v3_manifest.py

compat_audit:
	python3 ../../scripts/check_dronet_v3_compat.py

layer_payloads:
	python3 ../../scripts/export_dronet_v3_layer_payloads.py

stage0_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py

stage2_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage2

stage3_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage3

stage4_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage4

stage5_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage5

stage6_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage6

stage7_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage7

stage8_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage8

stage9_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage9

stage10_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage10

stage11_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage11

stage12_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage12

stage13_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage13

stage14_output_artifacts:
	python3 ../../scripts/select_stage0_output_bank.py stage14

stage1_pool_artifacts:
	python3 ../../scripts/derive_dronet_stage1_maxpool.py

generated/cutie_dronet_assets.h: gen_cutie_dronet_header.py assets/tiny_pulp_dronet_v3_dory/inputs.hex assets/tiny_pulp_dronet_v3_dory/ConvBNRelu0_weights.hex
	python3 gen_cutie_dronet_header.py

dronet_v3_driver.elf: ../basic/crt0.S dronet_v3_driver.c ../basic/link.ld generated/cutie_dronet_assets.h
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ ../basic/crt0.S dronet_v3_driver.c

dronet_v3_driver.bin: dronet_v3_driver.elf
	$(OBJCOPY) -O binary $< $@

dronet_v3_driver.mem: dronet_v3_driver.bin ../basic/elf_to_mem.py
	python3 ../basic/elf_to_mem.py dronet_v3_driver.bin dronet_v3_driver.mem

dronet_v3_smoke.mem:
	$(MAKE) clean all PAYLOAD_MODE=smoke RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage0.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage0 RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage0_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage0_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage2_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage2_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage3_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage3_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage4_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage4_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage5_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage5_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage6_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage6_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage7_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage7_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage8_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage8_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage9_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage9_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage10_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage10_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage11_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage11_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage12_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage12_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage13_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage13_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage14_software.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage14_software RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_stage14_hardware_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=stage14_hardware_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_full_hardware.mem:
	$(MAKE) dronet_v3_stage14_hardware_preload.mem RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_stage14_hardware_preload.mem $@

dronet_v3_partial.mem:
	$(MAKE) clean all PAYLOAD_MODE=partial RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_full.mem:
	$(MAKE) clean all PAYLOAD_MODE=full RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_full_preload.mem:
	$(MAKE) clean all PAYLOAD_MODE=full_preload RISCV_PREFIX=$(RISCV_PREFIX)
	cp dronet_v3_driver.mem $@

dronet_v3_driver.dis: dronet_v3_driver.elf
	$(OBJDUMP) -d dronet_v3_driver.elf > dronet_v3_driver.dis

clean:
	rm -f dronet_v3_driver.elf dronet_v3_driver.bin dronet_v3_driver.mem dronet_v3_driver.dis dronet_v3_driver.map generated/cutie_dronet_assets.h

.PHONY: all clean manifest compat_audit layer_payloads stage0_output_artifacts stage2_output_artifacts stage3_output_artifacts stage4_output_artifacts stage5_output_artifacts stage6_output_artifacts stage7_output_artifacts stage8_output_artifacts stage9_output_artifacts stage10_output_artifacts stage11_output_artifacts stage12_output_artifacts stage13_output_artifacts stage14_output_artifacts stage1_pool_artifacts
