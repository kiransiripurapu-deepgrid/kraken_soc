#include <stdint.h>

#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))

#define SNE_CFG_BASE          0x1A120000u
#define SNE_MAIN_CTRL1        (*(volatile uint32_t *)(SNE_CFG_BASE + 0x004))
#define SNE_TEST_EVT_CTRL     (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF00))
#define SNE_TEST_TCDM_DATA    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF04))
#define SNE_TEST_STATUS       (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF08))
#define SNE_TEST_TCDM_REQ     (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF0C))
#define SNE_TEST_IRQ_COUNT    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF10))
#define SNE_TEST_EVT_COUNT    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF14))
#define SNE_TEST_APB_WR_COUNT (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF18))
#define SNE_TEST_APB_RD_COUNT (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF1C))
#define SNE_TEST_APB_LAST_ADDR (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF20))

static void delay_cycles(volatile uint32_t cycles) {
  while (cycles--) {
    __asm__ volatile ("nop");
  }
}

int main(void) {
  uint32_t test_status;
  uint32_t evt_count;
  uint32_t apb_wr_count;
  uint32_t apb_last_addr;

  MMIO_SCRATCH0 = 0x534E4501u; /* "SNE" + step marker */
  MMIO_UART_TX  = (uint32_t)'S';

  /* Clear wrapper-local counters and program deterministic stub data. */
  SNE_TEST_TCDM_REQ  = 0u;
  SNE_TEST_IRQ_COUNT = 0u;
  SNE_TEST_EVT_COUNT = 0u;
  SNE_TEST_APB_WR_COUNT = 0u;
  SNE_TEST_APB_RD_COUNT = 0u;
  SNE_TEST_APB_LAST_ADDR = 0u;
  SNE_TEST_TCDM_DATA = 0xE0A5A5A5u;

  if (SNE_TEST_TCDM_DATA != 0xE0A5A5A5u) {
    MMIO_SCRATCH0 = 0x534E45F0u;
    MMIO_UART_TX  = (uint32_t)'F';
    for (;;)
      ;
  }

  /*
   * First-pass SNE bring-up:
   * - use the wrapper-local event injector for deterministic activity
   * - exercise one real APB write into sne_complex and confirm the wrapper
   *   sees that transaction complete
   *
   * This keeps the test in the stable control/configuration domain while still
   * proving something beyond wrapper-local registers only.
   */
  SNE_MAIN_CTRL1 = 0u;
  SNE_TEST_EVT_CTRL = 0x00000001u;

  delay_cycles(128u);

  test_status = SNE_TEST_STATUS;
  evt_count   = SNE_TEST_EVT_COUNT;
  apb_wr_count = SNE_TEST_APB_WR_COUNT;
  apb_last_addr = SNE_TEST_APB_LAST_ADDR;

  MMIO_SCRATCH0 = 0x534E4502u;
  MMIO_SCRATCH1 = test_status;
  MMIO_GPIO     = (evt_count & 0xFFu) |
                  ((apb_wr_count & 0xFFu) << 8) |
                  ((apb_last_addr & 0xFFu) << 24);

  /*
   * Pass criteria for the first SNE bring-up model:
   * - wrapper-local event injection worked
   * - wrapper-local status register was readable
   * - one real SNE APB write completed
   */
  if (evt_count >= 1u &&
      apb_wr_count >= 1u &&
      ((apb_last_addr & 0xFFFu) == 0x004u) &&
      (test_status != 0xDEADBEEFu)) {
    MMIO_UART_TX = (uint32_t)'P';
  } else {
    MMIO_SCRATCH0 = 0x534E45F1u;
    MMIO_SCRATCH1 = test_status;
    MMIO_GPIO     = (evt_count & 0xFFu) |
                    ((apb_wr_count & 0xFFu) << 8) |
                    ((apb_last_addr & 0xFFu) << 24);
    MMIO_UART_TX  = (uint32_t)'F';
  }

  for (;;)
    ;
}
