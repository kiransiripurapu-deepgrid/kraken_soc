#include <stdint.h>

#include "../dronet_v3/generated/cutie_dronet_assets.h"

#define MMIO_BASE                  0x1A100000u
#define MMIO_SCRATCH0              (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1              (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO                  (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX               (*(volatile uint32_t *)(MMIO_BASE + 0x0C))
#define MMIO_CYCLE_COUNT           (*(volatile uint32_t *)(MMIO_BASE + 0x18))
#define MMIO_CUTIE_STATUS          (*(volatile uint32_t *)(MMIO_BASE + 0x30))
#define MMIO_DMA_DESC_PTR          (*(volatile uint32_t *)(MMIO_BASE + 0x4C))
#define MMIO_DMA_STATUS            (*(volatile uint32_t *)(MMIO_BASE + 0x50))
#define MMIO_DMA_REMAINING         (*(volatile uint32_t *)(MMIO_BASE + 0x54))
#define MMIO_DMA_DONE_COUNT        (*(volatile uint32_t *)(MMIO_BASE + 0x60))
#define MMIO_DMA_ERROR_COUNT       (*(volatile uint32_t *)(MMIO_BASE + 0x64))
#define MMIO_DEMO_STATUS           (*(volatile uint32_t *)(MMIO_BASE + 0x68))
#define MMIO_DEMO_RESULT           (*(volatile uint32_t *)(MMIO_BASE + 0x6C))
#define MMIO_DEMO_CUTIE_SIG        (*(volatile uint32_t *)(MMIO_BASE + 0x70))
#define MMIO_DEMO_CUTIE_OUT0       (*(volatile uint32_t *)(MMIO_BASE + 0x74))
#define MMIO_DEMO_CUTIE_OUT1       (*(volatile uint32_t *)(MMIO_BASE + 0x78))
#define MMIO_DEMO_CYCLE0           (*(volatile uint32_t *)(MMIO_BASE + 0x7C))
#define MMIO_DEMO_CYCLE1           (*(volatile uint32_t *)(MMIO_BASE + 0x80))
#define MMIO_DEMO_CYCLE2           (*(volatile uint32_t *)(MMIO_BASE + 0x84))

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

#define SNE_CFG_BASE               0x1A120000u
#define SNE_MAIN_CTRL1             (*(volatile uint32_t *)(SNE_CFG_BASE + 0x004))
#define SNE_TEST_EVT_CTRL          (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF00))
#define SNE_TEST_TCDM_DATA         (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF04))
#define SNE_TEST_STATUS            (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF08))
#define SNE_TEST_TCDM_REQ          (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF0C))
#define SNE_TEST_IRQ_COUNT         (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF10))
#define SNE_TEST_EVT_COUNT         (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF14))
#define SNE_TEST_APB_WR_COUNT      (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF18))
#define SNE_TEST_APB_RD_COUNT      (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF1C))
#define SNE_TEST_APB_LAST_ADDR     (*(volatile uint32_t *)(SNE_CFG_BASE + 0xF20))

#define DEMO_BOOT_OK_BIT   (1u << 0)
#define DEMO_MMIO_OK_BIT   (1u << 1)
#define DEMO_CUTIE_OK_BIT  (1u << 2)
#define DEMO_SNE_OK_BIT    (1u << 3)
#define DEMO_DMA_OK_BIT    (1u << 4)
#define DEMO_PASS_BIT      (1u << 0)
#define DEMO_FAIL_BIT      (1u << 31)

#define DMA_TARGET_LINEAR_ACT  2u
#define DMA_TARGET_LINEAR_WGT  3u

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

static void uart_putc(char ch) {
  MMIO_UART_TX = (uint32_t)(uint8_t)ch;
}

static void delay_cycles(volatile uint32_t cycles) {
  while (cycles-- != 0u) {
    __asm__ volatile("nop");
  }
}

static void copy_stage14_payloads(void) {
  uint32_t i;
  for (i = 0; i < CUTIE_DRONET_STAGE14_ACT_WORD_COUNT; ++i)
    stage14_act_local[i] = g_dronet_stage14_act_words[i];
  for (i = 0; i < CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT; ++i)
    stage14_wgt_local[i] = g_dronet_stage14_weight_words[i];
}

static uint32_t dma_run(const volatile cutie_dma_desc_t *desc) {
  uint32_t timeout;
  MMIO_DMA_DESC_PTR = (uint32_t)desc;
  MMIO_DMA_STATUS = 0x2u;
  MMIO_DMA_STATUS = 0x1u;
  for (timeout = 0; timeout < 200000u; ++timeout) {
    uint32_t status = MMIO_DMA_STATUS;
    if ((status & 0x1u) == 0u)
      return status;
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
    if ((status & 0x6u) != 0u)
      return status;
  }
  return MMIO_CUTIE_STATUS;
}

static uint32_t run_cutie_demo(uint32_t *sig_o, uint32_t *out0_o, uint32_t *out1_o) {
  uint32_t act_dma_status;
  uint32_t wgt_dma_status;
  uint32_t cutie_status;
  uint32_t dma_ok;
  uint32_t cutie_ok;

  uart_putc('C');
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

  *sig_o = CUTIE_REG_RESULT_SIGNATURE;
  *out0_o = CUTIE_REG_LINEAR_OUT0;
  *out1_o = CUTIE_REG_LINEAR_OUT1;

  MMIO_DEMO_CUTIE_SIG = *sig_o;
  MMIO_DEMO_CUTIE_OUT0 = *out0_o;
  MMIO_DEMO_CUTIE_OUT1 = *out1_o;

  dma_ok = ((act_dma_status & 0x4u) == 0u) &&
           ((wgt_dma_status & 0x4u) == 0u) &&
           (MMIO_DMA_ERROR_COUNT == 0u) &&
           (MMIO_DMA_DONE_COUNT >= 2u) &&
           (MMIO_DMA_REMAINING == 0u);

  cutie_ok = ((cutie_status & 0x2u) != 0u) &&
             ((cutie_status & 0x4u) == 0u) &&
             (*sig_o == CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE) &&
             (*out0_o == CUTIE_DRONET_STAGE14_EXPECT_OUT0) &&
             (*out1_o == CUTIE_DRONET_STAGE14_EXPECT_OUT1);

  if (dma_ok)
    MMIO_DEMO_STATUS |= DEMO_DMA_OK_BIT;
  if (cutie_ok)
    MMIO_DEMO_STATUS |= DEMO_CUTIE_OK_BIT;

  return dma_ok && cutie_ok;
}

static uint32_t run_sne_demo(void) {
  uint32_t test_status;
  uint32_t evt_count;
  uint32_t apb_wr_count;
  uint32_t apb_last_addr;

  uart_putc('S');

  SNE_TEST_TCDM_REQ = 0u;
  SNE_TEST_IRQ_COUNT = 0u;
  SNE_TEST_EVT_COUNT = 0u;
  SNE_TEST_APB_WR_COUNT = 0u;
  SNE_TEST_APB_RD_COUNT = 0u;
  SNE_TEST_APB_LAST_ADDR = 0u;
  SNE_TEST_TCDM_DATA = 0xE0A5A5A5u;

  if (SNE_TEST_TCDM_DATA != 0xE0A5A5A5u)
    return 0u;

  SNE_MAIN_CTRL1 = 0u;
  SNE_TEST_EVT_CTRL = 0x00000001u;
  delay_cycles(128u);

  test_status = SNE_TEST_STATUS;
  evt_count = SNE_TEST_EVT_COUNT;
  apb_wr_count = SNE_TEST_APB_WR_COUNT;
  apb_last_addr = SNE_TEST_APB_LAST_ADDR;

  MMIO_SCRATCH1 = test_status;
  MMIO_GPIO = (evt_count & 0xFFu) |
              ((apb_wr_count & 0xFFu) << 8) |
              ((apb_last_addr & 0xFFu) << 24);

  if ((evt_count >= 1u) &&
      (apb_wr_count >= 1u) &&
      ((apb_last_addr & 0xFFFu) == 0x004u) &&
      (test_status != 0xDEADBEEFu)) {
    MMIO_DEMO_STATUS |= DEMO_SNE_OK_BIT;
    return 1u;
  }

  return 0u;
}

int main(void) {
  uint32_t cycle_start;
  uint32_t total_start;
  uint32_t cutie_sig;
  uint32_t cutie_out0;
  uint32_t cutie_out1;
  uint32_t cutie_ok;
  uint32_t sne_ok;

  MMIO_DEMO_STATUS = 0u;
  MMIO_DEMO_RESULT = 0u;
  MMIO_DEMO_CUTIE_SIG = 0u;
  MMIO_DEMO_CUTIE_OUT0 = 0u;
  MMIO_DEMO_CUTIE_OUT1 = 0u;
  MMIO_DEMO_CYCLE0 = 0u;
  MMIO_DEMO_CYCLE1 = 0u;
  MMIO_DEMO_CYCLE2 = 0u;

  MMIO_SCRATCH0 = 0x44454D4Fu;
  uart_putc('B');
  total_start = MMIO_CYCLE_COUNT;
  MMIO_DEMO_STATUS |= DEMO_BOOT_OK_BIT;

  MMIO_SCRATCH0 = 0x4D4D494Fu;
  MMIO_SCRATCH1 = 0x1234ABCDu;
  MMIO_GPIO = 0x55AA00FFu;
  uart_putc('M');
  if ((MMIO_SCRATCH1 == 0x1234ABCDu) && (MMIO_GPIO == 0x55AA00FFu))
    MMIO_DEMO_STATUS |= DEMO_MMIO_OK_BIT;

  cycle_start = MMIO_CYCLE_COUNT;
  cutie_ok = run_cutie_demo(&cutie_sig, &cutie_out0, &cutie_out1);
  MMIO_DEMO_CYCLE0 = MMIO_CYCLE_COUNT - cycle_start;

  cycle_start = MMIO_CYCLE_COUNT;
  sne_ok = run_sne_demo();
  MMIO_DEMO_CYCLE1 = MMIO_CYCLE_COUNT - cycle_start;
  MMIO_DEMO_CYCLE2 = MMIO_CYCLE_COUNT - total_start;

  MMIO_SCRATCH0 = cutie_sig;
  MMIO_SCRATCH1 = MMIO_DEMO_STATUS;

  if (cutie_ok && sne_ok &&
      ((MMIO_DEMO_STATUS & (DEMO_BOOT_OK_BIT | DEMO_MMIO_OK_BIT |
                            DEMO_CUTIE_OK_BIT | DEMO_SNE_OK_BIT |
                            DEMO_DMA_OK_BIT)) ==
       (DEMO_BOOT_OK_BIT | DEMO_MMIO_OK_BIT |
        DEMO_CUTIE_OK_BIT | DEMO_SNE_OK_BIT |
        DEMO_DMA_OK_BIT))) {
    MMIO_DEMO_RESULT = DEMO_PASS_BIT | MMIO_DEMO_STATUS;
    uart_putc('P');
  } else {
    MMIO_DEMO_RESULT = DEMO_FAIL_BIT | MMIO_DEMO_STATUS;
    uart_putc('F');
  }

  for (;;)
    delay_cycles(1024u);
}
