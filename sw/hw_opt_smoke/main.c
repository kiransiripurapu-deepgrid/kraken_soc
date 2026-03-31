#include <stdint.h>

#define MMIO_BASE                  0x1A100000u
#define MMIO_SCRATCH0              (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1              (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO                  (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX               (*(volatile uint32_t *)(MMIO_BASE + 0x0C))
#define MMIO_ACCEL_IRQ_STATUS      (*(volatile uint32_t *)(MMIO_BASE + 0x38))
#define MMIO_ACCEL_IRQ_MASK        (*(volatile uint32_t *)(MMIO_BASE + 0x3C))
#define MMIO_ACCEL_BUSY            (*(volatile uint32_t *)(MMIO_BASE + 0x40))
#define MMIO_SNE_DONE_COUNT        (*(volatile uint32_t *)(MMIO_BASE + 0x44))
#define MMIO_SNE_ERROR_COUNT       (*(volatile uint32_t *)(MMIO_BASE + 0x48))

#define CUTIE_CFG_BASE             0x1A110000u
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
#define CUTIE_REG_BURST_TARGET     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1C0))
#define CUTIE_REG_BURST_BANK       (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1C4))
#define CUTIE_REG_BURST_ADDR       (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1C8))
#define CUTIE_REG_BURST_COUNT      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1CC))
#define CUTIE_REG_BURST_DATA_LO    (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1D0))
#define CUTIE_REG_BURST_DATA_HI    (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1D4))
#define CUTIE_REG_BURST_CTRL       (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1D8))
#define CUTIE_REG_BURST_REMAINING  (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x1DC))
#define CUTIE_REG_DESC_BANK        (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x200))
#define CUTIE_REG_DESC_STATUS      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x204))
#define CUTIE_REG_DESC_CMD         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x208))

#define SNE_CFG_BASE               0x1A120000u
#define SNE_TEST_EVT_CTRL          (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF00))
#define SNE_FIFO_LAST              (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF24))
#define SNE_FIFO_STATUS            (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF28))
#define SNE_FIFO_PUSH_COUNT        (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF2C))
#define SNE_FIFO_POP_COUNT         (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF30))

static void delay_cycles(volatile uint32_t cycles) {
  while (cycles-- != 0u) {
    __asm__ volatile("nop");
  }
}

static uint32_t poll_until_eq(volatile uint32_t *reg, uint32_t mask, uint32_t expected, uint32_t timeout) {
  while (timeout-- != 0u) {
    uint32_t value = *reg;
    if ((value & mask) == expected) {
      return value;
    }
  }
  return *reg;
}

static uint32_t run_cutie_descriptor_test(void) {
  uint32_t pass = 1u;

  CUTIE_REG_IMG_W = 7u;
  CUTIE_REG_IMG_H = 9u;
  CUTIE_REG_K = 3u;
  CUTIE_REG_NI = 5u;
  CUTIE_REG_NO = 6u;
  CUTIE_REG_STRIDE_W = 2u;
  CUTIE_REG_STRIDE_H = 2u;
  CUTIE_REG_PADDING = 1u;
  CUTIE_REG_POOL_EN = 1u;
  CUTIE_REG_POOL_TYPE = 0u;
  CUTIE_REG_POOL_K = 2u;
  CUTIE_REG_POOL_PAD = 1u;

  CUTIE_REG_DESC_BANK = 1u;
  CUTIE_REG_DESC_STATUS = 1u;
  CUTIE_REG_DESC_CMD = 1u;

  CUTIE_REG_IMG_W = 1u;
  CUTIE_REG_IMG_H = 1u;
  CUTIE_REG_K = 1u;
  CUTIE_REG_NI = 1u;
  CUTIE_REG_NO = 1u;
  CUTIE_REG_STRIDE_W = 1u;
  CUTIE_REG_STRIDE_H = 1u;
  CUTIE_REG_PADDING = 0u;
  CUTIE_REG_POOL_EN = 0u;
  CUTIE_REG_POOL_K = 1u;
  CUTIE_REG_POOL_PAD = 0u;

  CUTIE_REG_DESC_CMD = 2u;

  pass &= (CUTIE_REG_IMG_W == 7u);
  pass &= (CUTIE_REG_IMG_H == 9u);
  pass &= (CUTIE_REG_K == 3u);
  pass &= (CUTIE_REG_NI == 5u);
  pass &= (CUTIE_REG_NO == 6u);
  pass &= (CUTIE_REG_STRIDE_W == 2u);
  pass &= (CUTIE_REG_STRIDE_H == 2u);
  pass &= (CUTIE_REG_PADDING == 1u);
  pass &= (CUTIE_REG_POOL_EN == 1u);
  pass &= (CUTIE_REG_POOL_K == 2u);
  pass &= (CUTIE_REG_POOL_PAD == 1u);
  pass &= ((CUTIE_REG_DESC_STATUS & 0x3u) == 0x2u);

  CUTIE_REG_DESC_CMD = 8u;
  pass &= ((CUTIE_REG_DESC_BANK & 0x1u) == 0u);

  return pass;
}

static uint32_t run_cutie_burst_test(void) {
  uint32_t status;

  CUTIE_REG_BURST_TARGET = 2u;
  CUTIE_REG_BURST_BANK = 0u;
  CUTIE_REG_BURST_ADDR = 0u;
  CUTIE_REG_BURST_COUNT = 2u;
  CUTIE_REG_BURST_DATA_LO = 0x11223344u;
  CUTIE_REG_BURST_DATA_HI = 0x55667788u;
  CUTIE_REG_BURST_CTRL = 1u;

  status = poll_until_eq((volatile uint32_t *)&CUTIE_REG_BURST_CTRL, 0x2u, 0x0u, 256u);
  status = CUTIE_REG_BURST_CTRL;
  return (((status & 0x2u) == 0u) &&
          ((status & 0x1u) == 0u) &&
          (CUTIE_REG_BURST_REMAINING == 0u) &&
          (CUTIE_REG_BURST_ADDR == 2u));
}

static uint32_t run_sne_fifo_test(void) {
  uint32_t irq_status;
  uint32_t fifo_status;

  MMIO_ACCEL_IRQ_MASK = 0x0000000Fu;
  MMIO_ACCEL_IRQ_STATUS = 0xFFFFFFFFu;

  SNE_TEST_EVT_CTRL = 0u;
  SNE_FIFO_STATUS = 0x00000002u;
  SNE_FIFO_PUSH_COUNT = 0u;
  SNE_FIFO_POP_COUNT = 0u;
  SNE_FIFO_LAST = 0x00000001u;
  SNE_FIFO_LAST = 0x00000002u;
  SNE_FIFO_STATUS = 0x00000001u;

  irq_status = poll_until_eq((volatile uint32_t *)&MMIO_ACCEL_IRQ_STATUS, 0x4u, 0x4u, 128u);
  fifo_status = SNE_FIFO_STATUS;

  MMIO_ACCEL_IRQ_STATUS = 0x00000004u;

  return ((irq_status & 0x4u) != 0u) &&
         ((fifo_status & 0x1Fu) == 0u) &&
         (SNE_FIFO_PUSH_COUNT == 2u) &&
         (SNE_FIFO_POP_COUNT == 2u) &&
         (MMIO_SNE_DONE_COUNT != 0u) &&
         (MMIO_SNE_ERROR_COUNT == 0u) &&
         ((MMIO_ACCEL_IRQ_STATUS & 0x4u) == 0u) &&
         ((MMIO_ACCEL_BUSY & 0x2u) == 0u);
}

int main(void) {
  uint32_t desc_ok;
  uint32_t burst_ok;
  uint32_t sne_ok;
  uint32_t all_ok;

  MMIO_SCRATCH0 = 0x484F0001u;
  MMIO_SCRATCH1 = 0u;
  MMIO_GPIO = 0u;
  MMIO_UART_TX = (uint32_t)'H';

  desc_ok = run_cutie_descriptor_test();
  burst_ok = run_cutie_burst_test();
  sne_ok = run_sne_fifo_test();
  all_ok = desc_ok & burst_ok & sne_ok;

  MMIO_SCRATCH0 = all_ok ? 0x484F0002u : 0x484F00F0u;
  MMIO_SCRATCH1 = (desc_ok << 16) | (burst_ok << 8) | sne_ok;
  MMIO_GPIO = (MMIO_SNE_DONE_COUNT << 16) | (SNE_FIFO_POP_COUNT & 0xFFFFu);
  MMIO_UART_TX = all_ok ? (uint32_t)'P' : (uint32_t)'F';

  for (;;) {
    delay_cycles(1024u);
  }
}
