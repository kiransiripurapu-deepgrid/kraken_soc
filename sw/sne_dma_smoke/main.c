#include <stdint.h>

// ── SoC MMIO ───────────────────────────────────────────────────────────────
#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))

// ── SNE wrapper-local registers ────────────────────────────────────────────
#define SNE_CFG_BASE              0x1A120000u
#define SNE_TEST_EVT_CTRL         (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF00))
#define SNE_TEST_STATUS           (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF08))
#define SNE_EVT_FIFO_PUSH         (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF24))
#define SNE_EVT_FIFO_STATUS       (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF28))
#define SNE_EVT_FIFO_PUSH_COUNT   (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF2C))
#define SNE_EVT_FIFO_POP_COUNT    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF30))
#define SNE_EVT_POP_STROBE        (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF34))
#define SNE_EVT_BATCH_DONE_COUNT  (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF38))
#define SNE_EVT_ERROR_FLAGS       (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF3C))
#define SNE_EVT_FIFO_WATERMARK    (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF40))

// Status register bit positions (read from 0xF28)
#define STATUS_COUNT_MASK   0x1Fu
#define STATUS_IRQ_BIT      (1u << 3)
#define STATUS_FULL_BIT     (1u << 4)
#define STATUS_EMPTY_BIT    (1u << 5)
#define STATUS_AUTORUN_BIT  (1u << 6)
#define STATUS_OVERFLOW_BIT (1u << 7)

// Control register bits (write to 0xF28)
#define CTRL_AUTORUN_EN     (1u << 0)
#define CTRL_FLUSH          (1u << 1)
#define CTRL_CLEAR_OVERFLOW (1u << 2)

static void delay_cycles(volatile uint32_t cycles) {
  while (cycles--) {
    __asm__ volatile ("nop");
  }
}

#define FAIL(step) do { \
    MMIO_SCRATCH0 = 0x534ED0F0u | ((step) & 0xFu); \
    MMIO_SCRATCH1 = status; \
    MMIO_UART_TX  = (uint32_t)'F'; \
    for (;;) ; \
  } while (0)

int main(void) {
  uint32_t status;
  uint32_t val;

  // ── Step 1: Boot marker ──────────────────────────────────────────────────
  MMIO_SCRATCH0 = 0x534ED001u;
  MMIO_UART_TX  = (uint32_t)'D';

  // ── Step 2: Flush FIFO, verify empty ─────────────────────────────────────
  SNE_EVT_FIFO_STATUS = CTRL_FLUSH;
  delay_cycles(8u);

  status = SNE_EVT_FIFO_STATUS;
  if (!(status & STATUS_EMPTY_BIT))
    FAIL(2);
  if ((status & STATUS_COUNT_MASK) != 0u)
    FAIL(2);

  // ── Step 3: Push 4 events, verify count ──────────────────────────────────
  SNE_EVT_FIFO_PUSH = 0x00000001u;
  SNE_EVT_FIFO_PUSH = 0x00000002u;
  SNE_EVT_FIFO_PUSH = 0x00000003u;
  SNE_EVT_FIFO_PUSH = 0x00000004u;
  delay_cycles(4u);

  status = SNE_EVT_FIFO_STATUS;
  if ((status & STATUS_COUNT_MASK) != 4u)
    FAIL(3);
  if (status & STATUS_EMPTY_BIT)
    FAIL(3);
  if (status & STATUS_FULL_BIT)
    FAIL(3);

  // ── Step 4: Check watermark ──────────────────────────────────────────────
  val = SNE_EVT_FIFO_WATERMARK;
  if (val < 4u)
    FAIL(4);

  // ── Step 5: Fill to 16 (full), verify full ───────────────────────────────
  for (uint32_t i = 5; i <= 16; i++)
    SNE_EVT_FIFO_PUSH = i;
  delay_cycles(4u);

  status = SNE_EVT_FIFO_STATUS;
  if (!(status & STATUS_FULL_BIT))
    FAIL(5);
  if ((status & STATUS_COUNT_MASK) != 16u)
    FAIL(5);

  // ── Step 6: Overflow test — push one more ────────────────────────────────
  SNE_EVT_FIFO_PUSH = 0xDEADu;
  delay_cycles(4u);

  status = SNE_EVT_FIFO_STATUS;
  if (!(status & STATUS_OVERFLOW_BIT))
    FAIL(6);

  // Verify error_flags[0] (overflow) is set
  val = SNE_EVT_ERROR_FLAGS;
  if (!(val & 1u))
    FAIL(6);

  // ── Step 7: Clear overflow, verify cleared ───────────────────────────────
  SNE_EVT_FIFO_STATUS = CTRL_CLEAR_OVERFLOW;
  delay_cycles(4u);

  status = SNE_EVT_FIFO_STATUS;
  if (status & STATUS_OVERFLOW_BIT)
    FAIL(7);

  // Clear error flags too
  SNE_EVT_ERROR_FLAGS = 0x7u;
  delay_cycles(4u);
  val = SNE_EVT_ERROR_FLAGS;
  if (val & 1u)
    FAIL(7);

  // ── Step 8: Enable auto-run, wait for FIFO drain ────────────────────────
  SNE_EVT_BATCH_DONE_COUNT = 0u;  // reset batch counter
  SNE_EVT_FIFO_STATUS = CTRL_AUTORUN_EN;
  delay_cycles(256u);

  status = SNE_EVT_FIFO_STATUS;
  if (!(status & STATUS_EMPTY_BIT))
    FAIL(8);

  // ── Step 9: Verify batch-done count ──────────────────────────────────────
  val = SNE_EVT_BATCH_DONE_COUNT;
  if (val < 1u)
    FAIL(9);

  // Disable auto-run
  SNE_EVT_FIFO_STATUS = 0u;
  delay_cycles(4u);

  // ── Step 10: Manual pop test ─────────────────────────────────────────────
  // Flush first
  SNE_EVT_FIFO_STATUS = CTRL_FLUSH;
  delay_cycles(4u);

  // Push 2 entries
  SNE_EVT_FIFO_PUSH = 0xAAAA0001u;
  SNE_EVT_FIFO_PUSH = 0xBBBB0002u;
  delay_cycles(4u);

  status = SNE_EVT_FIFO_STATUS;
  if ((status & STATUS_COUNT_MASK) != 2u)
    FAIL(10);

  // Manual pop via strobe (auto-run is off)
  SNE_EVT_POP_STROBE = 1u;
  delay_cycles(4u);

  // Check that pop strobe data captured the first entry
  val = SNE_EVT_POP_STROBE;  // read returns last popped data
  if (val != 0xAAAA0001u)
    FAIL(10);

  status = SNE_EVT_FIFO_STATUS;
  if ((status & STATUS_COUNT_MASK) != 1u)
    FAIL(10);

  // Pop the second
  SNE_EVT_POP_STROBE = 1u;
  delay_cycles(4u);

  val = SNE_EVT_POP_STROBE;
  if (val != 0xBBBB0002u)
    FAIL(10);

  status = SNE_EVT_FIFO_STATUS;
  if (!(status & STATUS_EMPTY_BIT))
    FAIL(10);

  // ── Step 11: Pop-empty error flag test ───────────────────────────────────
  SNE_EVT_ERROR_FLAGS = 0x7u;  // clear all
  delay_cycles(4u);

  SNE_EVT_POP_STROBE = 1u;  // pop from empty FIFO
  delay_cycles(4u);

  val = SNE_EVT_ERROR_FLAGS;
  if (!(val & 2u))  // bit[1] = pop-while-empty
    FAIL(11);

  // Clear it
  SNE_EVT_ERROR_FLAGS = 0x7u;

  // ── Step 12: Watermark check after full sequence ─────────────────────────
  val = SNE_EVT_FIFO_WATERMARK;
  // We had 16 entries at peak earlier, watermark should reflect that
  // (watermark was reset by flush, but we pushed 2 after, so >= 2)
  if (val < 2u)
    FAIL(12);

  // ── PASS ─────────────────────────────────────────────────────────────────
  MMIO_SCRATCH0 = 0x534ED002u;
  MMIO_SCRATCH1 = SNE_EVT_FIFO_STATUS;
  MMIO_GPIO     = (SNE_EVT_FIFO_PUSH_COUNT & 0xFFu) |
                  ((SNE_EVT_FIFO_POP_COUNT & 0xFFu) << 8) |
                  ((SNE_EVT_BATCH_DONE_COUNT & 0xFFu) << 16);
  MMIO_UART_TX  = (uint32_t)'P';

  for (;;)
    ;
}
