
#include <stdint.h>

#include "generated/cutie_dronet_assets.h"

#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))
#define MMIO_CUTIE_STATUS   (*(volatile uint32_t *)(MMIO_BASE + 0x30))
#define MMIO_CUTIE_READBACK (*(volatile uint32_t *)(MMIO_BASE + 0x34))

#define CUTIE_CFG_BASE             0x1A110000u
#define CUTIE_REG_START            (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x000))
#define CUTIE_REG_DISABLE          (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x004))
#define CUTIE_REG_TESTMODE         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x008))
#define CUTIE_REG_STORE_TO_FIFO    (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x00C))

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

#define CUTIE_REG_ACT_WR           (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x100))
#define CUTIE_REG_ACT_BANKSET      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x104))
#define CUTIE_REG_ACT_ADDR         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x108))
#define CUTIE_REG_ACT_WDATA_LO     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x10C))
#define CUTIE_REG_ACT_WDATA_HI     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x110))

#define CUTIE_REG_WGT_WR           (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x120))
#define CUTIE_REG_WGT_BANK         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x124))
#define CUTIE_REG_WGT_ADDR         (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x128))
#define CUTIE_REG_WGT_WDATA_LO     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x12C))
#define CUTIE_REG_WGT_WDATA_HI     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x130))
#define CUTIE_REG_RESULT_SIGNATURE (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x15C))
#define CUTIE_REG_LINEAR_MODE      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x0A8))
#define CUTIE_REG_LINEAR_WORDS     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x0AC))
#define CUTIE_REG_LINEAR_OUT0      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x160))
#define CUTIE_REG_LINEAR_OUT1      (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x164))

typedef struct {
  const uint32_t *act_words;
  uint32_t act_word_count;
  const uint32_t *weight_words;
  uint32_t weight_word_count;
  uint32_t img_w;
  uint32_t img_h;
  uint32_t ni;
  uint32_t no;
  uint32_t stride;
  uint32_t kernel;
  uint32_t scratch1_marker;
} dronet_payload_t;

typedef struct {
  dronet_payload_t payload;
  uint32_t timeout_cycles;
  uint32_t linear_mode;
  uint32_t linear_words;
  uint32_t expect_signature;
  uint32_t expect_out0;
  uint32_t expect_out1;
  uint32_t validate_signature;
  uint32_t validate_linear;
} dronet_stage_desc_t;

typedef enum {
  DRONET_EXEC_SOFTWARE_FALLBACK = 0,
  DRONET_EXEC_CUTIE = 1
} dronet_exec_kind_t;

typedef struct {
  uint32_t stage_id;
  uint32_t marker;
  uint32_t uart_tag;
  uint32_t input_slot;
  uint32_t output_slot;
  dronet_exec_kind_t exec_kind;
  const dronet_stage_desc_t *cutie_stage;
  const dronet_payload_t *fallback_payload;
} dronet_stage_plan_t;

static void stage14_run(const uint32_t *act_words, const uint32_t *weight_words, uint32_t *out0, uint32_t *out1);

static void cutie_write_act_word(uint32_t bankset, uint32_t addr, uint32_t lo, uint32_t hi) {
  CUTIE_REG_ACT_BANKSET = bankset;
  CUTIE_REG_ACT_ADDR = addr;
  CUTIE_REG_ACT_WDATA_LO = lo;
  CUTIE_REG_ACT_WDATA_HI = hi;
  CUTIE_REG_ACT_WR = 1u;
}

static void cutie_write_weight_word(uint32_t bank, uint32_t addr, uint32_t lo, uint32_t hi) {
  CUTIE_REG_WGT_BANK = bank;
  CUTIE_REG_WGT_ADDR = addr;
  CUTIE_REG_WGT_WDATA_LO = lo;
  CUTIE_REG_WGT_WDATA_HI = hi;
  CUTIE_REG_WGT_WR = 1u;
}

static void cutie_begin_act_stream(uint32_t bankset, uint32_t start_addr) {
  CUTIE_REG_ACT_BANKSET = bankset;
  CUTIE_REG_ACT_ADDR = start_addr;
}

static void cutie_stream_act_word(uint32_t lo, uint32_t hi) {
  CUTIE_REG_ACT_WDATA_LO = lo;
  CUTIE_REG_ACT_WDATA_HI = hi;
  CUTIE_REG_ACT_WR = 1u;
}

static void cutie_begin_weight_stream(uint32_t bank, uint32_t start_addr) {
  CUTIE_REG_WGT_BANK = bank;
  CUTIE_REG_WGT_ADDR = start_addr;
}

static void cutie_stream_weight_word(uint32_t lo, uint32_t hi) {
  CUTIE_REG_WGT_WDATA_LO = lo;
  CUTIE_REG_WGT_WDATA_HI = hi;
  CUTIE_REG_WGT_WR = 1u;
}

static const dronet_payload_t *cutie_select_payload(void) {
#if defined(CUTIE_DRONET_USE_STAGE0_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
    .act_words = g_dronet_full_act_words,
    .act_word_count = CUTIE_DRONET_STAGE0_ACT_WORD_COUNT,
    .weight_words = g_dronet_full_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE0_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE0_IMG_W,
    .img_h = CUTIE_DRONET_STAGE0_IMG_H,
    .ni = CUTIE_DRONET_STAGE0_NI,
    .no = CUTIE_DRONET_STAGE0_NO,
    .stride = CUTIE_DRONET_STAGE0_STRIDE,
    .kernel = CUTIE_DRONET_STAGE0_KERNEL,
    .scratch1_marker = (CUTIE_DRONET_STAGE0_IMG_W << 16) | ((CUTIE_DRONET_STAGE0_KERNEL & 0xFFu) << 8) | (CUTIE_DRONET_STAGE0_NO & 0xFFu)
  };
#elif defined(CUTIE_DRONET_USE_STAGE2_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE2_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage2_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE2_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE2_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage2_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE2_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE2_IMG_W,
    .img_h = CUTIE_DRONET_STAGE2_IMG_H,
    .ni = CUTIE_DRONET_STAGE2_NI,
    .no = CUTIE_DRONET_STAGE2_NO,
    .stride = CUTIE_DRONET_STAGE2_STRIDE,
    .kernel = CUTIE_DRONET_STAGE2_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE2_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE3_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE3_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage3_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE3_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE3_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage3_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE3_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE3_IMG_W,
    .img_h = CUTIE_DRONET_STAGE3_IMG_H,
    .ni = CUTIE_DRONET_STAGE3_NI,
    .no = CUTIE_DRONET_STAGE3_NO,
    .stride = CUTIE_DRONET_STAGE3_STRIDE,
    .kernel = CUTIE_DRONET_STAGE3_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE3_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE4_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE4_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage4_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE4_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE4_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage4_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE4_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE4_IMG_W,
    .img_h = CUTIE_DRONET_STAGE4_IMG_H,
    .ni = CUTIE_DRONET_STAGE4_NI,
    .no = CUTIE_DRONET_STAGE4_NO,
    .stride = CUTIE_DRONET_STAGE4_STRIDE,
    .kernel = CUTIE_DRONET_STAGE4_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE4_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE5_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE5_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage5_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE5_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE5_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage5_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE5_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE5_IMG_W,
    .img_h = CUTIE_DRONET_STAGE5_IMG_H,
    .ni = CUTIE_DRONET_STAGE5_NI,
    .no = CUTIE_DRONET_STAGE5_NO,
    .stride = CUTIE_DRONET_STAGE5_STRIDE,
    .kernel = CUTIE_DRONET_STAGE5_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE5_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE6_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE6_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage6_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE6_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE6_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage6_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE6_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE6_IMG_W,
    .img_h = CUTIE_DRONET_STAGE6_IMG_H,
    .ni = CUTIE_DRONET_STAGE6_NI,
    .no = CUTIE_DRONET_STAGE6_NO,
    .stride = CUTIE_DRONET_STAGE6_STRIDE,
    .kernel = CUTIE_DRONET_STAGE6_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE6_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE7_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE7_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage7_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE7_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE7_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage7_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE7_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE7_IMG_W,
    .img_h = CUTIE_DRONET_STAGE7_IMG_H,
    .ni = CUTIE_DRONET_STAGE7_NI,
    .no = CUTIE_DRONET_STAGE7_NO,
    .stride = CUTIE_DRONET_STAGE7_STRIDE,
    .kernel = CUTIE_DRONET_STAGE7_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE7_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE8_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE8_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage8_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE8_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE8_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage8_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE8_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE8_IMG_W,
    .img_h = CUTIE_DRONET_STAGE8_IMG_H,
    .ni = CUTIE_DRONET_STAGE8_NI,
    .no = CUTIE_DRONET_STAGE8_NO,
    .stride = CUTIE_DRONET_STAGE8_STRIDE,
    .kernel = CUTIE_DRONET_STAGE8_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE8_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE9_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE9_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage9_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE9_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE9_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage9_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE9_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE9_IMG_W,
    .img_h = CUTIE_DRONET_STAGE9_IMG_H,
    .ni = CUTIE_DRONET_STAGE9_NI,
    .no = CUTIE_DRONET_STAGE9_NO,
    .stride = CUTIE_DRONET_STAGE9_STRIDE,
    .kernel = CUTIE_DRONET_STAGE9_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE9_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE10_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE10_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage10_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE10_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE10_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage10_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE10_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE10_IMG_W,
    .img_h = CUTIE_DRONET_STAGE10_IMG_H,
    .ni = CUTIE_DRONET_STAGE10_NI,
    .no = CUTIE_DRONET_STAGE10_NO,
    .stride = CUTIE_DRONET_STAGE10_STRIDE,
    .kernel = CUTIE_DRONET_STAGE10_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE10_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE11_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE11_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage11_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE11_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE11_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage11_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE11_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE11_IMG_W,
    .img_h = CUTIE_DRONET_STAGE11_IMG_H,
    .ni = CUTIE_DRONET_STAGE11_NI,
    .no = CUTIE_DRONET_STAGE11_NO,
    .stride = CUTIE_DRONET_STAGE11_STRIDE,
    .kernel = CUTIE_DRONET_STAGE11_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE11_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE12_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE12_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage12_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE12_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE12_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage12_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE12_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE12_IMG_W,
    .img_h = CUTIE_DRONET_STAGE12_IMG_H,
    .ni = CUTIE_DRONET_STAGE12_NI,
    .no = CUTIE_DRONET_STAGE12_NO,
    .stride = CUTIE_DRONET_STAGE12_STRIDE,
    .kernel = CUTIE_DRONET_STAGE12_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE12_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE13_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE13_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage13_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE13_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE13_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage13_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE13_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE13_IMG_W,
    .img_h = CUTIE_DRONET_STAGE13_IMG_H,
    .ni = CUTIE_DRONET_STAGE13_NI,
    .no = CUTIE_DRONET_STAGE13_NO,
    .stride = CUTIE_DRONET_STAGE13_STRIDE,
    .kernel = CUTIE_DRONET_STAGE13_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE13_MARKER
  };
#elif defined(CUTIE_DRONET_USE_STAGE14_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
#if CUTIE_DRONET_STAGE14_ACT_WORD_COUNT > 0
    .act_words = g_dronet_stage14_act_words,
#else
    .act_words = 0,
#endif
    .act_word_count = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT,
#if CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT > 0
    .weight_words = g_dronet_stage14_weight_words,
#else
    .weight_words = 0,
#endif
    .weight_word_count = CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT,
    .img_w = 1u,
    .img_h = 1u,
    .ni = 1u,
    .no = 2u,
    .stride = 1u,
    .kernel = 1u,
    .scratch1_marker = CUTIE_DRONET_STAGE14_MARKER
  };
#elif defined(CUTIE_DRONET_USE_FULL_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  static const dronet_payload_t payload = {
    .act_words = g_dronet_full_act_words,
    .act_word_count = CUTIE_DRONET_FULL_ACT_WORD_COUNT,
    .weight_words = g_dronet_full_weight_words,
    .weight_word_count = CUTIE_DRONET_FULL_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_EXPORT_IMG_W,
    .img_h = CUTIE_DRONET_EXPORT_IMG_H,
    .ni = CUTIE_DRONET_EXPORT_NI,
    .no = CUTIE_DRONET_EXPORT_NO,
    .stride = CUTIE_DRONET_EXPORT_STRIDE,
    .kernel = CUTIE_DRONET_COMPAT_K,
    .scratch1_marker = (CUTIE_DRONET_EXPORT_IMG_W << 16) | (CUTIE_DRONET_EXPORT_NO & 0xFFFFu)
  };
#elif defined(CUTIE_DRONET_USE_PARTIAL_PAYLOAD)
  static const dronet_payload_t payload = {
    .act_words = g_dronet_partial_act_words,
    .act_word_count = CUTIE_DRONET_PARTIAL_ACT_WORD_COUNT,
    .weight_words = g_dronet_partial_weight_words,
    .weight_word_count = CUTIE_DRONET_PARTIAL_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_PARTIAL_IMG_W,
    .img_h = CUTIE_DRONET_PARTIAL_IMG_H,
    .ni = CUTIE_DRONET_PARTIAL_NI,
    .no = CUTIE_DRONET_PARTIAL_NO,
    .stride = CUTIE_DRONET_PARTIAL_STRIDE,
    .kernel = CUTIE_DRONET_COMPAT_K,
    .scratch1_marker = (CUTIE_DRONET_PARTIAL_IMG_W << 16) | (CUTIE_DRONET_PARTIAL_NO & 0xFFFFu)
  };
#else
  static const dronet_payload_t payload = {
    .act_words = g_dronet_act_words,
    .act_word_count = CUTIE_DRONET_SMOKE_ACT_WORD_COUNT,
    .weight_words = g_dronet_weight_words,
    .weight_word_count = CUTIE_DRONET_SMOKE_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_SMOKE_IMG_W,
    .img_h = CUTIE_DRONET_SMOKE_IMG_H,
    .ni = CUTIE_DRONET_SMOKE_NI,
    .no = CUTIE_DRONET_SMOKE_NO,
    .stride = CUTIE_DRONET_SMOKE_STRIDE,
    .kernel = CUTIE_DRONET_COMPAT_K,
    .scratch1_marker = (CUTIE_DRONET_SMOKE_IMG_W << 16) | (CUTIE_DRONET_SMOKE_NO & 0xFFFFu)
  };
#endif
  return &payload;
}

static void cutie_config_asset_layer(const dronet_payload_t *payload) {
  CUTIE_REG_DISABLE = 0u;
  CUTIE_REG_TESTMODE = 0u;
  CUTIE_REG_IMG_W = payload->img_w;
  CUTIE_REG_IMG_H = payload->img_h;
  CUTIE_REG_K = payload->kernel;
  CUTIE_REG_NI = payload->ni;
  CUTIE_REG_NO = payload->no;
  CUTIE_REG_STRIDE_W = payload->stride;
  CUTIE_REG_STRIDE_H = payload->stride;
  CUTIE_REG_PADDING = 0u;
  CUTIE_REG_POOL_EN = CUTIE_DRONET_COMPAT_POOL_EN;
  CUTIE_REG_POOL_TYPE = 0u;
  CUTIE_REG_POOL_K = CUTIE_DRONET_COMPAT_POOL_K;
  CUTIE_REG_POOL_PAD = 0u;
}

static void cutie_load_asset_payload(const dronet_payload_t *payload) {
#if defined(CUTIE_DRONET_ASSUME_PRELOADED)
  (void)payload;
#else
#if defined(CUTIE_DRONET_USE_STAGE0_PAYLOAD) || defined(CUTIE_DRONET_USE_FULL_PAYLOAD)
  cutie_begin_act_stream(0u, 0u);
  for (uint32_t i = 0; i < payload->act_word_count; i += 2u) {
    uint32_t hi = (i + 1u < payload->act_word_count) ? payload->act_words[i + 1u] : 0u;
    cutie_stream_act_word(payload->act_words[i], hi);
  }

  cutie_begin_weight_stream(0u, 0u);
  for (uint32_t i = 0; i < payload->weight_word_count; i += 2u) {
    uint32_t hi = (i + 1u < payload->weight_word_count) ? payload->weight_words[i + 1u] : 0u;
    cutie_stream_weight_word(payload->weight_words[i], hi);
  }
#else
  for (uint32_t i = 0; i < payload->act_word_count; i += 2u) {
    uint32_t hi = (i + 1u < payload->act_word_count) ? payload->act_words[i + 1u] : 0u;
    cutie_write_act_word(0u, i >> 1, payload->act_words[i], hi);
  }

  for (uint32_t i = 0; i < payload->weight_word_count; i += 2u) {
    uint32_t hi = (i + 1u < payload->weight_word_count) ? payload->weight_words[i + 1u] : 0u;
    cutie_write_weight_word(0u, i >> 1, payload->weight_words[i], hi);
  }
#endif
#endif
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

static uint32_t run_cutie_stage(const dronet_stage_desc_t *stage, uint32_t *status_out) {
  uint32_t status;
  uint32_t signature;
  uint32_t linear_out0;
  uint32_t linear_out1;
  uint32_t pass = 1u;

  MMIO_SCRATCH1 = stage->payload.scratch1_marker;
  cutie_load_asset_payload(&stage->payload);
  cutie_config_asset_layer(&stage->payload);

  CUTIE_REG_LINEAR_MODE = stage->linear_mode;
  if (stage->linear_mode != 0u) {
    CUTIE_REG_LINEAR_WORDS = stage->linear_words;
  } else {
    CUTIE_REG_STORE_TO_FIFO = 1u;
  }
  CUTIE_REG_START = 1u;

  status = cutie_wait_done(stage->timeout_cycles);
  signature = CUTIE_REG_RESULT_SIGNATURE;
  linear_out0 = CUTIE_REG_LINEAR_OUT0;
  linear_out1 = CUTIE_REG_LINEAR_OUT1;

  if ((status & 0x4u) != 0u) {
    pass = 0u;
  }
  if (stage->validate_signature != 0u && signature != stage->expect_signature) {
    pass = 0u;
  }
  if (stage->validate_linear != 0u) {
    if (linear_out0 != stage->expect_out0 || linear_out1 != stage->expect_out1) {
      pass = 0u;
    }
  }

  MMIO_SCRATCH0 = signature;
  MMIO_GPIO = (status << 16) ^ signature ^ linear_out1;
  if (status_out != 0) {
    *status_out = status;
  }
  return pass;
}

static void run_software_stage_placeholder(uint32_t marker, uint32_t tag) {
  MMIO_SCRATCH1 = marker;
  MMIO_UART_TX = tag;
}

static uint32_t software_fallback_signature(const dronet_payload_t *payload, uint32_t marker) {
  uint32_t sig = 0x9E3779B9u ^ marker;
  uint32_t i;

  if (payload == 0) {
    return sig ^ 0xA5A5A5A5u;
  }

  for (i = 0u; i < payload->act_word_count; ++i) {
    sig ^= payload->act_words[i] + (i * 0x45D9F3Bu);
    sig = (sig << 5) | (sig >> 27);
  }
  for (i = 0u; i < payload->weight_word_count; ++i) {
    sig ^= payload->weight_words[i] + (i * 0x27D4EB2Du);
    sig = (sig << 3) | (sig >> 29);
  }

  sig ^= (payload->act_word_count << 16) ^ payload->weight_word_count;
  return sig;
}

static uint32_t run_stage_plan(const dronet_stage_plan_t *plan, uint32_t *status_out) {
  MMIO_SCRATCH0 = (plan->stage_id << 24) | ((plan->input_slot & 0xFFu) << 8) | (plan->output_slot & 0xFFu);

  if (plan->exec_kind == DRONET_EXEC_CUTIE) {
    return run_cutie_stage(plan->cutie_stage, status_out);
  }

  run_software_stage_placeholder(plan->marker, plan->uart_tag);
  MMIO_SCRATCH0 = software_fallback_signature(plan->fallback_payload, plan->marker);
  if (status_out != 0) {
    *status_out = 0u;
  }
  return 1u;
}

static uint32_t dronet_run_all_stages(void) {
  uint32_t status = 0u;
  uint32_t pass = 1u;
  uint32_t stage14_soft_out0 = 0u;
  uint32_t stage14_soft_out1 = 0u;
  uint32_t stage14_soft_sig = 0u;

  static const dronet_stage_desc_t stage2 = {
    .payload = {
      .act_words = g_dronet_stage2_act_words,
      .act_word_count = CUTIE_DRONET_STAGE2_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage2_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE2_WEIGHT_WORD_COUNT,
      .img_w = CUTIE_DRONET_STAGE2_IMG_W,
      .img_h = CUTIE_DRONET_STAGE2_IMG_H,
      .ni = CUTIE_DRONET_STAGE2_NI,
      .no = CUTIE_DRONET_STAGE2_NO,
      .stride = CUTIE_DRONET_STAGE2_STRIDE,
      .kernel = CUTIE_DRONET_STAGE2_KERNEL,
      .scratch1_marker = CUTIE_DRONET_STAGE2_MARKER
    },
    .timeout_cycles = 300000u
  };
  static const dronet_stage_desc_t stage4 = {
    .payload = {
      .act_words = g_dronet_stage4_act_words,
      .act_word_count = CUTIE_DRONET_STAGE4_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage4_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE4_WEIGHT_WORD_COUNT,
      .img_w = CUTIE_DRONET_STAGE4_IMG_W,
      .img_h = CUTIE_DRONET_STAGE4_IMG_H,
      .ni = CUTIE_DRONET_STAGE4_NI,
      .no = CUTIE_DRONET_STAGE4_NO,
      .stride = CUTIE_DRONET_STAGE4_STRIDE,
      .kernel = CUTIE_DRONET_STAGE4_KERNEL,
      .scratch1_marker = CUTIE_DRONET_STAGE4_MARKER
    },
    .timeout_cycles = 200000u
  };
  static const dronet_stage_desc_t stage6 = {
    .payload = {
      .act_words = g_dronet_stage6_act_words,
      .act_word_count = CUTIE_DRONET_STAGE6_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage6_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE6_WEIGHT_WORD_COUNT,
      .img_w = CUTIE_DRONET_STAGE6_IMG_W,
      .img_h = CUTIE_DRONET_STAGE6_IMG_H,
      .ni = CUTIE_DRONET_STAGE6_NI,
      .no = CUTIE_DRONET_STAGE6_NO,
      .stride = CUTIE_DRONET_STAGE6_STRIDE,
      .kernel = CUTIE_DRONET_STAGE6_KERNEL,
      .scratch1_marker = CUTIE_DRONET_STAGE6_MARKER
    },
    .timeout_cycles = 200000u
  };
  static const dronet_stage_desc_t stage8 = {
    .payload = {
      .act_words = g_dronet_stage8_act_words,
      .act_word_count = CUTIE_DRONET_STAGE8_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage8_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE8_WEIGHT_WORD_COUNT,
      .img_w = CUTIE_DRONET_STAGE8_IMG_W,
      .img_h = CUTIE_DRONET_STAGE8_IMG_H,
      .ni = CUTIE_DRONET_STAGE8_NI,
      .no = CUTIE_DRONET_STAGE8_NO,
      .stride = CUTIE_DRONET_STAGE8_STRIDE,
      .kernel = CUTIE_DRONET_STAGE8_KERNEL,
      .scratch1_marker = CUTIE_DRONET_STAGE8_MARKER
    },
    .timeout_cycles = 200000u
  };
  static const dronet_stage_desc_t stage10 = {
    .payload = {
      .act_words = g_dronet_stage10_act_words,
      .act_word_count = CUTIE_DRONET_STAGE10_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage10_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE10_WEIGHT_WORD_COUNT,
      .img_w = CUTIE_DRONET_STAGE10_IMG_W,
      .img_h = CUTIE_DRONET_STAGE10_IMG_H,
      .ni = CUTIE_DRONET_STAGE10_NI,
      .no = CUTIE_DRONET_STAGE10_NO,
      .stride = CUTIE_DRONET_STAGE10_STRIDE,
      .kernel = CUTIE_DRONET_STAGE10_KERNEL,
      .scratch1_marker = CUTIE_DRONET_STAGE10_MARKER
    },
    .timeout_cycles = 200000u
  };
  static const dronet_stage_desc_t stage12 = {
    .payload = {
      .act_words = g_dronet_stage12_act_words,
      .act_word_count = CUTIE_DRONET_STAGE12_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage12_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE12_WEIGHT_WORD_COUNT,
      .img_w = CUTIE_DRONET_STAGE12_IMG_W,
      .img_h = CUTIE_DRONET_STAGE12_IMG_H,
      .ni = CUTIE_DRONET_STAGE12_NI,
      .no = CUTIE_DRONET_STAGE12_NO,
      .stride = CUTIE_DRONET_STAGE12_STRIDE,
      .kernel = CUTIE_DRONET_STAGE12_KERNEL,
      .scratch1_marker = CUTIE_DRONET_STAGE12_MARKER
    },
    .timeout_cycles = 200000u
  };
  static const dronet_stage_desc_t stage14 = {
    .payload = {
      .act_words = g_dronet_stage14_act_words,
      .act_word_count = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT,
      .weight_words = g_dronet_stage14_weight_words,
      .weight_word_count = CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT,
      .img_w = 1u,
      .img_h = 1u,
      .ni = CUTIE_DRONET_STAGE14_INPUT_DIM,
      .no = CUTIE_DRONET_STAGE14_OUT_DIM,
      .stride = 1u,
      .kernel = 1u,
      .scratch1_marker = CUTIE_DRONET_STAGE14_MARKER
    },
    .timeout_cycles = 200000u,
    .linear_mode = 1u,
    .linear_words = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT,
    .expect_signature = CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE,
    .expect_out0 = CUTIE_DRONET_STAGE14_EXPECT_OUT0,
    .expect_out1 = CUTIE_DRONET_STAGE14_EXPECT_OUT1,
    .validate_signature = 1u,
    .validate_linear = 1u
  };
  static const dronet_payload_t fallback_stage0 = {
    .act_words = g_dronet_full_act_words,
    .act_word_count = CUTIE_DRONET_STAGE0_ACT_WORD_COUNT,
    .weight_words = g_dronet_full_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE0_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE0_IMG_W,
    .img_h = CUTIE_DRONET_STAGE0_IMG_H,
    .ni = CUTIE_DRONET_STAGE0_NI,
    .no = CUTIE_DRONET_STAGE0_NO,
    .stride = CUTIE_DRONET_STAGE0_STRIDE,
    .kernel = CUTIE_DRONET_STAGE0_KERNEL,
    .scratch1_marker = (CUTIE_DRONET_STAGE0_IMG_W << 16) | ((CUTIE_DRONET_STAGE0_KERNEL & 0xFFu) << 8) | (CUTIE_DRONET_STAGE0_NO & 0xFFu)
  };
  static const dronet_payload_t fallback_stage3 = {
    .act_words = g_dronet_stage3_act_words,
    .act_word_count = CUTIE_DRONET_STAGE3_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage3_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE3_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE3_IMG_W,
    .img_h = CUTIE_DRONET_STAGE3_IMG_H,
    .ni = CUTIE_DRONET_STAGE3_NI,
    .no = CUTIE_DRONET_STAGE3_NO,
    .stride = CUTIE_DRONET_STAGE3_STRIDE,
    .kernel = CUTIE_DRONET_STAGE3_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE3_MARKER
  };
  static const dronet_payload_t fallback_stage5 = {
    .act_words = g_dronet_stage5_act_words,
    .act_word_count = CUTIE_DRONET_STAGE5_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage5_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE5_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE5_IMG_W,
    .img_h = CUTIE_DRONET_STAGE5_IMG_H,
    .ni = CUTIE_DRONET_STAGE5_NI,
    .no = CUTIE_DRONET_STAGE5_NO,
    .stride = CUTIE_DRONET_STAGE5_STRIDE,
    .kernel = CUTIE_DRONET_STAGE5_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE5_MARKER
  };
  static const dronet_payload_t fallback_stage7 = {
    .act_words = g_dronet_stage7_act_words,
    .act_word_count = CUTIE_DRONET_STAGE7_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage7_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE7_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE7_IMG_W,
    .img_h = CUTIE_DRONET_STAGE7_IMG_H,
    .ni = CUTIE_DRONET_STAGE7_NI,
    .no = CUTIE_DRONET_STAGE7_NO,
    .stride = CUTIE_DRONET_STAGE7_STRIDE,
    .kernel = CUTIE_DRONET_STAGE7_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE7_MARKER
  };
  static const dronet_payload_t fallback_stage9 = {
    .act_words = g_dronet_stage9_act_words,
    .act_word_count = CUTIE_DRONET_STAGE9_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage9_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE9_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE9_IMG_W,
    .img_h = CUTIE_DRONET_STAGE9_IMG_H,
    .ni = CUTIE_DRONET_STAGE9_NI,
    .no = CUTIE_DRONET_STAGE9_NO,
    .stride = CUTIE_DRONET_STAGE9_STRIDE,
    .kernel = CUTIE_DRONET_STAGE9_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE9_MARKER
  };
  static const dronet_payload_t fallback_stage11 = {
    .act_words = g_dronet_stage11_act_words,
    .act_word_count = CUTIE_DRONET_STAGE11_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage11_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE11_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE11_IMG_W,
    .img_h = CUTIE_DRONET_STAGE11_IMG_H,
    .ni = CUTIE_DRONET_STAGE11_NI,
    .no = CUTIE_DRONET_STAGE11_NO,
    .stride = CUTIE_DRONET_STAGE11_STRIDE,
    .kernel = CUTIE_DRONET_STAGE11_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE11_MARKER
  };
  static const dronet_payload_t fallback_stage13 = {
    .act_words = g_dronet_stage13_act_words,
    .act_word_count = CUTIE_DRONET_STAGE13_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage13_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE13_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE13_IMG_W,
    .img_h = CUTIE_DRONET_STAGE13_IMG_H,
    .ni = CUTIE_DRONET_STAGE13_NI,
    .no = CUTIE_DRONET_STAGE13_NO,
    .stride = CUTIE_DRONET_STAGE13_STRIDE,
    .kernel = CUTIE_DRONET_STAGE13_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE13_MARKER
  };
  static const dronet_payload_t fallback_stage2 = {
    .act_words = g_dronet_stage2_act_words,
    .act_word_count = CUTIE_DRONET_STAGE2_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage2_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE2_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE2_IMG_W,
    .img_h = CUTIE_DRONET_STAGE2_IMG_H,
    .ni = CUTIE_DRONET_STAGE2_NI,
    .no = CUTIE_DRONET_STAGE2_NO,
    .stride = CUTIE_DRONET_STAGE2_STRIDE,
    .kernel = CUTIE_DRONET_STAGE2_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE2_MARKER
  };
  static const dronet_payload_t fallback_stage4 = {
    .act_words = g_dronet_stage4_act_words,
    .act_word_count = CUTIE_DRONET_STAGE4_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage4_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE4_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE4_IMG_W,
    .img_h = CUTIE_DRONET_STAGE4_IMG_H,
    .ni = CUTIE_DRONET_STAGE4_NI,
    .no = CUTIE_DRONET_STAGE4_NO,
    .stride = CUTIE_DRONET_STAGE4_STRIDE,
    .kernel = CUTIE_DRONET_STAGE4_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE4_MARKER
  };
  static const dronet_payload_t fallback_stage6 = {
    .act_words = g_dronet_stage6_act_words,
    .act_word_count = CUTIE_DRONET_STAGE6_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage6_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE6_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE6_IMG_W,
    .img_h = CUTIE_DRONET_STAGE6_IMG_H,
    .ni = CUTIE_DRONET_STAGE6_NI,
    .no = CUTIE_DRONET_STAGE6_NO,
    .stride = CUTIE_DRONET_STAGE6_STRIDE,
    .kernel = CUTIE_DRONET_STAGE6_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE6_MARKER
  };
  static const dronet_payload_t fallback_stage8 = {
    .act_words = g_dronet_stage8_act_words,
    .act_word_count = CUTIE_DRONET_STAGE8_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage8_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE8_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE8_IMG_W,
    .img_h = CUTIE_DRONET_STAGE8_IMG_H,
    .ni = CUTIE_DRONET_STAGE8_NI,
    .no = CUTIE_DRONET_STAGE8_NO,
    .stride = CUTIE_DRONET_STAGE8_STRIDE,
    .kernel = CUTIE_DRONET_STAGE8_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE8_MARKER
  };
  static const dronet_payload_t fallback_stage10 = {
    .act_words = g_dronet_stage10_act_words,
    .act_word_count = CUTIE_DRONET_STAGE10_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage10_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE10_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE10_IMG_W,
    .img_h = CUTIE_DRONET_STAGE10_IMG_H,
    .ni = CUTIE_DRONET_STAGE10_NI,
    .no = CUTIE_DRONET_STAGE10_NO,
    .stride = CUTIE_DRONET_STAGE10_STRIDE,
    .kernel = CUTIE_DRONET_STAGE10_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE10_MARKER
  };
  static const dronet_payload_t fallback_stage12 = {
    .act_words = g_dronet_stage12_act_words,
    .act_word_count = CUTIE_DRONET_STAGE12_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage12_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE12_WEIGHT_WORD_COUNT,
    .img_w = CUTIE_DRONET_STAGE12_IMG_W,
    .img_h = CUTIE_DRONET_STAGE12_IMG_H,
    .ni = CUTIE_DRONET_STAGE12_NI,
    .no = CUTIE_DRONET_STAGE12_NO,
    .stride = CUTIE_DRONET_STAGE12_STRIDE,
    .kernel = CUTIE_DRONET_STAGE12_KERNEL,
    .scratch1_marker = CUTIE_DRONET_STAGE12_MARKER
  };
  static const dronet_payload_t fallback_stage14 = {
    .act_words = g_dronet_stage14_act_words,
    .act_word_count = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT,
    .weight_words = g_dronet_stage14_weight_words,
    .weight_word_count = CUTIE_DRONET_STAGE14_WEIGHT_WORD_COUNT,
    .img_w = 1u,
    .img_h = 1u,
    .ni = CUTIE_DRONET_STAGE14_INPUT_DIM,
    .no = CUTIE_DRONET_STAGE14_OUT_DIM,
    .stride = 1u,
    .kernel = 1u,
    .scratch1_marker = CUTIE_DRONET_STAGE14_MARKER
  };
  static const dronet_stage_plan_t stage_plans[] = {
    {0u, (CUTIE_DRONET_STAGE0_IMG_W << 16) | 0x0005u, 0x00000030u, 0u, 1u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage0},
    {1u, (CUTIE_DRONET_STAGE0_IMG_W << 16) | 0x0102u, 0x00000031u, 1u, 2u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, 0},
    {2u, CUTIE_DRONET_STAGE2_MARKER, 0x00000032u, 2u, 3u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage2},
    {3u, CUTIE_DRONET_STAGE3_MARKER, 0x00000033u, 3u, 4u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage3},
    {4u, CUTIE_DRONET_STAGE4_MARKER, 0x00000034u, 4u, 5u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage4},
    {5u, CUTIE_DRONET_STAGE5_MARKER, 0x00000035u, 5u, 6u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage5},
    {6u, CUTIE_DRONET_STAGE6_MARKER, 0x00000036u, 6u, 7u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage6},
    {7u, CUTIE_DRONET_STAGE7_MARKER, 0x00000037u, 7u, 8u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage7},
    {8u, CUTIE_DRONET_STAGE8_MARKER, 0x00000038u, 8u, 9u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage8},
    {9u, CUTIE_DRONET_STAGE9_MARKER, 0x00000039u, 9u, 10u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage9},
    {10u, CUTIE_DRONET_STAGE10_MARKER, 0x00000041u, 10u, 11u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage10},
    {11u, CUTIE_DRONET_STAGE11_MARKER, 0x00000042u, 11u, 12u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage11},
    {12u, CUTIE_DRONET_STAGE12_MARKER, 0x00000043u, 12u, 13u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage12},
    {13u, CUTIE_DRONET_STAGE13_MARKER, 0x00000044u, 13u, 14u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage13},
    {14u, CUTIE_DRONET_STAGE14_MARKER, 0x00000045u, 14u, 15u, DRONET_EXEC_SOFTWARE_FALLBACK, 0, &fallback_stage14}
  };

  MMIO_SCRATCH0 = 0xD203A1F0u;
  MMIO_UART_TX = 0x00000053u; /* 'S' */

  /* These slot ids document the intended activation handoff chain while software
     fallbacks are still placeholders. */
  for (uint32_t i = 0u; i < (sizeof(stage_plans) / sizeof(stage_plans[0])); ++i) {
    pass &= run_stage_plan(&stage_plans[i], &status);
  }

  stage14_run(g_dronet_stage14_act_words, g_dronet_stage14_weight_words, &stage14_soft_out0, &stage14_soft_out1);
  stage14_soft_sig = stage14_soft_out0 ^ (stage14_soft_out1 << 1);
  if (stage14_soft_out0 != CUTIE_DRONET_STAGE14_EXPECT_OUT0 ||
      stage14_soft_out1 != CUTIE_DRONET_STAGE14_EXPECT_OUT1 ||
      stage14_soft_sig != CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE) {
    pass = 0u;
  }

  MMIO_SCRATCH0 = stage14_soft_sig;
  MMIO_SCRATCH1 = stage14_soft_out0;
  MMIO_GPIO = stage14_soft_out1;
  return pass;
}

static void stage14_run(const uint32_t *act_words, const uint32_t *weight_words, uint32_t *out0, uint32_t *out1) {
  const uint32_t words_per_output = (CUTIE_DRONET_STAGE14_INPUT_DIM >> 2);
  int32_t acc0 = 0;
  int32_t acc1 = 0;

  for (uint32_t i = 0; i < words_per_output; ++i) {
    uint32_t act_word = act_words[i];
    uint32_t weight0 = weight_words[i];
    uint32_t weight1 = weight_words[words_per_output + i];
    int32_t a0 = (int32_t)((act_word << 24) >> 24);
    int32_t a1 = (int32_t)((act_word << 16) >> 24);
    int32_t a2 = (int32_t)((act_word << 8) >> 24);
    int32_t a3 = (int32_t)(act_word >> 24);
    int32_t w00 = (int32_t)((weight0 << 24) >> 24);
    int32_t w01 = (int32_t)((weight0 << 16) >> 24);
    int32_t w02 = (int32_t)((weight0 << 8) >> 24);
    int32_t w03 = (int32_t)(weight0 >> 24);
    int32_t w10 = (int32_t)((weight1 << 24) >> 24);
    int32_t w11 = (int32_t)((weight1 << 16) >> 24);
    int32_t w12 = (int32_t)((weight1 << 8) >> 24);
    int32_t w13 = (int32_t)(weight1 >> 24);

    acc0 += a0 * w00;
    acc0 += a1 * w01;
    acc0 += a2 * w02;
    acc0 += a3 * w03;

    acc1 += a0 * w10;
    acc1 += a1 * w11;
    acc1 += a2 * w12;
    acc1 += a3 * w13;
  }

  *out0 = (uint32_t)acc0;
  *out1 = (uint32_t)acc1;
}

int main(void) {
#if defined(CUTIE_DRONET_USE_STAGE14_SOFTWARE) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  uint32_t out0;
  uint32_t out1;
  uint32_t signature;
  uint32_t signature_ok;

  MMIO_SCRATCH0 = 0xD203A10Eu;
  MMIO_SCRATCH1 = CUTIE_DRONET_STAGE14_MARKER;
  MMIO_UART_TX = 0x00000044u; /* 'D' */

  stage14_run(g_dronet_stage14_act_words, g_dronet_stage14_weight_words, &out0, &out1);
  signature = out0 ^ (out1 << 1);
  signature_ok = (out0 == CUTIE_DRONET_STAGE14_EXPECT_OUT0) &&
                 (out1 == CUTIE_DRONET_STAGE14_EXPECT_OUT1) &&
                 (signature == CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE);

  MMIO_SCRATCH0 = signature;
  MMIO_SCRATCH1 = out0;
  MMIO_GPIO = out1;
  MMIO_UART_TX = signature_ok ? 0x00000050u : 0x00000046u; /* 'P' or 'F' */

  for (;;) {
    __asm__ volatile("" : : "r"(out0), "r"(out1), "r"(signature), "r"(signature_ok));
  }
#elif defined(CUTIE_DRONET_USE_SEQUENTIAL_CHAIN) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  uint32_t pass = dronet_run_all_stages();
  MMIO_UART_TX = pass ? 0x00000050u : 0x00000046u; /* 'P' / 'F' */
  for (;;) {
    __asm__ volatile("" : : "r"(pass));
  }
#else
  const dronet_payload_t *payload = cutie_select_payload();
  uint32_t status;
  uint32_t readback;
  uint32_t result_signature;
  uint32_t linear_out0 = 0u;
  uint32_t linear_out1 = 0u;
  uint32_t signature_ok = 1u;

  MMIO_SCRATCH0 = 0xD203A100u | (payload->ni & 0xFFu);
  MMIO_SCRATCH1 = payload->scratch1_marker;
  MMIO_UART_TX = 0x00000044u; /* 'D' */

  cutie_load_asset_payload(payload);
  cutie_config_asset_layer(payload);
  CUTIE_REG_LINEAR_MODE = 0u;
#if defined(CUTIE_DRONET_USE_STAGE14_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  CUTIE_REG_LINEAR_MODE = 1u;
  CUTIE_REG_LINEAR_WORDS = CUTIE_DRONET_STAGE14_ACT_WORD_COUNT;
#else
  CUTIE_REG_STORE_TO_FIFO = 1u;
#endif
  CUTIE_REG_START = 1u;

  status = cutie_wait_done(
#if defined(CUTIE_DRONET_USE_STAGE0_PAYLOAD)
    500000u
#elif defined(CUTIE_DRONET_USE_STAGE2_PAYLOAD)
    300000u
#elif defined(CUTIE_DRONET_USE_STAGE3_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE4_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE5_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE6_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE7_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE8_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE9_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE10_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE11_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE12_PAYLOAD)
    200000u
#elif defined(CUTIE_DRONET_USE_STAGE13_PAYLOAD)
    200000u
#else
    50000u
#endif
  );
  readback = MMIO_CUTIE_READBACK;
  result_signature = CUTIE_REG_RESULT_SIGNATURE;
  linear_out0 = CUTIE_REG_LINEAR_OUT0;
  linear_out1 = CUTIE_REG_LINEAR_OUT1;

#if defined(CUTIE_DRONET_USE_STAGE0_PAYLOAD)
  if (result_signature != CUTIE_DRONET_STAGE0_EXPECTED_SIGNATURE) {
    signature_ok = 0u;
  }
#elif defined(CUTIE_DRONET_USE_STAGE14_PAYLOAD) && defined(CUTIE_DRONET_INCLUDE_FULL_PAYLOAD)
  signature_ok = (linear_out0 == CUTIE_DRONET_STAGE14_EXPECT_OUT0) &&
                 (linear_out1 == CUTIE_DRONET_STAGE14_EXPECT_OUT1) &&
                 (result_signature == CUTIE_DRONET_STAGE14_EXPECT_SIGNATURE);
#endif

  MMIO_SCRATCH0 = result_signature;
  MMIO_SCRATCH1 = payload->scratch1_marker;
  MMIO_GPIO = (status << 16) ^ result_signature ^ linear_out1;

  if ((status & 0x4u) != 0u) {
    MMIO_UART_TX = 0x00000054u; /* 'T' timeout */
  } else if (((status & 0x2u) != 0u) && (signature_ok != 0u)) {
    MMIO_UART_TX = 0x00000050u; /* 'P' pass */
  } else {
    MMIO_UART_TX = 0x00000046u; /* 'F' fail */
  }

  for (;;) {
    __asm__ volatile("" : : "r"(status), "r"(readback), "r"(result_signature), "r"(signature_ok), "r"(linear_out0), "r"(linear_out1));
  }
#endif
}
