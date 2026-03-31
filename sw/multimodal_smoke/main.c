#include <stdint.h>

#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))

#define SNE_CFG_BASE          0x1A120000u
#define SNE_TEST_EVT_CTRL     (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF00))
#define SNE_TEST_TCDM_DATA    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF04))
#define SNE_TEST_STATUS       (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF08))
#define SNE_TEST_TCDM_REQ     (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF0C))
#define SNE_TEST_IRQ_COUNT    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF10))
#define SNE_TEST_EVT_COUNT    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF14))
#define SNE_TEST_APB_WR_COUNT (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF18))
#define SNE_TEST_APB_RD_COUNT (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF1C))
#define SNE_TEST_APB_LAST_ADDR (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF20))

int dronet_cutie_entry(void);

static void delay_cycles(volatile uint32_t cycles) {
  while (cycles--) {
    __asm__ volatile("nop");
  }
}

static uint32_t run_sne_smoke(void) {
  uint32_t test_status;

  SNE_TEST_TCDM_DATA = 0xE0A5A5A5u;
  SNE_TEST_STATUS = 0xCAFE1000u;
  SNE_TEST_TCDM_REQ = 0x00000000u;
  SNE_TEST_IRQ_COUNT = 0x00000000u;
  SNE_TEST_EVT_COUNT = 0x00000000u;
  SNE_TEST_APB_WR_COUNT = 0x00000000u;
  SNE_TEST_APB_RD_COUNT = 0x00000000u;
  SNE_TEST_APB_LAST_ADDR = 0x00000000u;

  if (SNE_TEST_TCDM_DATA != 0xE0A5A5A5u) {
    return 0u;
  }

  // Keep the combined flow non-intrusive: validate the SNE wrapper/MMIO path
  // without kicking the deeper sne_complex control machinery.
  SNE_TEST_EVT_CTRL = 0x000000A5u;
  delay_cycles(128u);

  test_status = SNE_TEST_STATUS;

  MMIO_SCRATCH1 = test_status;

  return (SNE_TEST_TCDM_DATA == 0xE0A5A5A5u) &&
         (SNE_TEST_STATUS == 0xCAFE1000u) &&
         (SNE_TEST_EVT_CTRL == 0x000000A5u) &&
         (SNE_TEST_APB_WR_COUNT == 0u) &&
         (test_status != 0xDEADBEEFu);
}

int main(void) {
  uint32_t sne_ok;

  MMIO_SCRATCH0 = 0x4D4D0001u; /* MM + step marker */
  MMIO_SCRATCH1 = 0u;
  MMIO_GPIO = 0u;
  MMIO_UART_TX = (uint32_t)'M';

  sne_ok = run_sne_smoke();
  MMIO_GPIO = (MMIO_GPIO & ~0x1u) | (sne_ok & 0x1u);
  if (!sne_ok) {
    MMIO_SCRATCH0 = 0x4D4DF001u;
    MMIO_UART_TX = (uint32_t)'F';
    for (;;)
      ;
  }

  MMIO_SCRATCH0 = 0x4D4D0002u;
  MMIO_GPIO = (MMIO_GPIO & ~0x2u) | 0x2u;
  return dronet_cutie_entry();
}
