#include <stdint.h>

#include "../dronet_v3/generated/cutie_dronet_assets.h"

#define MMIO_BASE                  0x1A100000u
#define MMIO_SCRATCH0              (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1              (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO                  (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX               (*(volatile uint32_t *)(MMIO_BASE + 0x0C))
#define MMIO_CUTIE_STATUS          (*(volatile uint32_t *)(MMIO_BASE + 0x30))
#define MMIO_DMA_DESC_PTR          (*(volatile uint32_t *)(MMIO_BASE + 0x4C))
#define MMIO_DMA_STATUS            (*(volatile uint32_t *)(MMIO_BASE + 0x50))
#define MMIO_DMA_REMAINING         (*(volatile uint32_t *)(MMIO_BASE + 0x54))
#define MMIO_DMA_CUR_SRC           (*(volatile uint32_t *)(MMIO_BASE + 0x58))
#define MMIO_DMA_CUR_DST           (*(volatile uint32_t *)(MMIO_BASE + 0x5C))
#define MMIO_DMA_DONE_COUNT        (*(volatile uint32_t *)(MMIO_BASE + 0x60))
#define MMIO_DMA_ERROR_COUNT       (*(volatile uint32_t *)(MMIO_BASE + 0x64))

#define CUTIE_CFG_BASE             0x1A110000u
#define CUTIE_REG_START            (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x000))
#define CUTIE_REG_DISABLE          (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x004))
#define CUTIE_REG_TESTMODE         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x008))
#define CUTIE_REG_IMG_W            (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x040))
#define CUTIE_REG_IMG_H            (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x044))
#define CUTIE_REG_K                (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x048))
#define CUTIE_REG_NI               (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x04C))
#define CUTIE_REG_NO               (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x050))
#define CUTIE_REG_STRIDE_W         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x054))
#define CUTIE_REG_STRIDE_H         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x058))
#define CUTIE_REG_PADDING          (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x05C))
#define CUTIE_REG_POOL_EN          (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x080))
#define CUTIE_REG_POOL_TYPE        (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x084))
#define CUTIE_REG_POOL_K           (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x088))
#define CUTIE_REG_POOL_PAD         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x08C))
#define CUTIE_REG_LINEAR_MODE      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x0A8))
#define CUTIE_REG_LINEAR_WORDS     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x0AC))
#define CUTIE_REG_RESULT_SIGNATURE (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x15C))
#define CUTIE_REG_LINEAR_OUT0      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x160))
#define CUTIE_REG_LINEAR_OUT1      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x164))

#define DMA_TARGET_ACT             0u
#define DMA_TARGET_WGT             1u
#define DMA_TARGET_LINEAR_ACT      2u
#define DMA_TARGET_LINEAR_WGT      3u

typedef struct {
  uint32_t src_addr;
  uint32_t dst_addr;
  uint32_t bank;
  uint32_t word_count;
  uint32_t control;
  uint32_t next_desc_ptr;
} cutie_dma_desc_t;

static uint32_t stage14_act_local[CUTIE_DRONET_STAGE14_ACT_WORD_COUNT];
static uint32_t stage14_wgt_local[CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT];
static volatile cutie_dma_desc_t dma_desc;

static void delay_cycles(volatile uint32_t cycles) {
  while (cycles-- != 0u) {
    __asm__ volatile("nop");
  }
}

static void copy_stage14_payloads(void) {
  for (uint32_t i = 0; i < CUTIE_DRONET_STAGE14_ACT_WORD_COUNT; ++i) {
    stage14_act_local[i] = g_dronet_stage14_act_words[i];
  }
  for (uint32_t i = 0; i < CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT; ++i) {
    stage14_wgt_local[i] = g_dronet_stage14_weight_words[i];
  }
}

static uint32_t dma_run(const volatile cutie_dma_desc_t *desc) {
  MMIO_DMA_DESC_PTR = (uint32_t)desc;
  MMIO_DMA_STATUS = 0x2u;
  MMIO_DMA_STATUS = 0x1u;

  for (uint32_t timeout = 0; timeout < 200000u; ++timeout) {
    uint32_t status = MMIO_DMA_STATUS;
    if ((status & 0x1u) == 0u) {
      return status;
    }
  }
  return MMIO_DMA_STATUS;
}

static void configure_stage14(void) {
  CUTIE_REG_DISABLE = 0u;
  CUTIE_REG_TESTMODE = 0u;
  CUTIE_REG_IMG_W = 1u;
  CUTIE_REG_IMG_H = 1u;
  CUTIE_REG_K = 1u;
  CUTIE_REG_NI = 1u;
  CUTIE_REG_NO = 2u;
  CUTIE_REG_STRIDE_W = 1u;
  CUTIE_REG_STRIDE_H = 1u;
  CUTIE_REG_PADDING = 0u;
  CUTIE_REG_POOL_EN = 0u;
  CUTIE_REG_POOL_TYPE = 0u;
  CUTIE_REG_POOL_K = 1u;
  CUTIE_REG_POOL_PAD = 0u;
  CUTIE_REG_LINEAR_MODE = 1u;
  CUTIE_REG_LINEAR_WORDS = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT;
}

static uint32_t cutie_wait_done(uint32_t timeout_cycles) {
  while (timeout_cycles-- != 0u) {
    uint32_t status = MMIO_CUTIE_STATUS;
    if ((status & 0x6u) != 0u) {
      return status;
    }
  }
  return MMIO_CUTIE_STATUS;
}

int main(void) {
  uint32_t act_dma_status;
  uint32_t wgt_dma_status;
  uint32_t cutie_status;
  uint32_t result_signature;
  uint32_t out0;
  uint32_t out1;
  uint32_t dma_ok;
  uint32_t cutie_ok;

  MMIO_SCRATCH0 = 0x43440001u;
  MMIO_SCRATCH1 = 0u;
  MMIO_GPIO = 0u;
  MMIO_UART_TX = (uint32_t)'C';

  copy_stage14_payloads();

  dma_desc.src_addr = (uint32_t)stage14_act_local;
  dma_desc.dst_addr = 0u;
  dma_desc.bank = 0u;
  dma_desc.word_count = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT;
  dma_desc.control = DMA_TARGET_LINEAR_ACT;
  dma_desc.next_desc_ptr = 0u;
  act_dma_status = dma_run(&dma_desc);

  dma_desc.src_addr = (uint32_t)stage14_wgt_local;
  dma_desc.dst_addr = 0u;
  dma_desc.bank = 0u;
  dma_desc.word_count = CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT;
  dma_desc.control = DMA_TARGET_LINEAR_WGT;
  dma_desc.next_desc_ptr = 0u;
  wgt_dma_status = dma_run(&dma_desc);

  configure_stage14();
  CUTIE_REG_START = 1u;
  cutie_status = cutie_wait_done(200000u);
  result_signature = CUTIE_REG_RESULT_SIGNATURE;
  out0 = CUTIE_REG_LINEAR_OUT0;
  out1 = CUTIE_REG_LINEAR_OUT1;

  dma_ok = ((act_dma_status & 0x4u) == 0u) &&
           ((wgt_dma_status & 0x4u) == 0u) &&
           (MMIO_DMA_ERROR_COUNT == 0u) &&
           (MMIO_DMA_DONE_COUNT >= 2u) &&
           (MMIO_DMA_REMAINING == 0u);

  cutie_ok = ((cutie_status & 0x2u) != 0u) &&
             ((cutie_status & 0x4u) == 0u) &&
             (result_signature == CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE) &&
             (out0 == CUTIE_DRONET_STAGE14_EXPECT_OUT0) &&
             (out1 == CUTIE_DRONET_STAGE14_EXPECT_OUT1);

  MMIO_SCRATCH0 = result_signature;
  MMIO_SCRATCH1 = 0xCD140102u;
  MMIO_GPIO = (MMIO_DMA_DONE_COUNT << 16) | (MMIO_DMA_ERROR_COUNT & 0xFFFFu);

  if (dma_ok && cutie_ok) {
    MMIO_UART_TX = (uint32_t)'P';
  } else {
    MMIO_UART_TX = (uint32_t)'F';
  }

  for (;;) {
    delay_cycles(1024u);
  }
}
