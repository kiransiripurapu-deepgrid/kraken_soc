#include <stdint.h>

#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))
#define CUTIE_CFG_BASE        0x1A110000u
#define CUTIE_REG_START       (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x000))
#define CUTIE_REG_DISABLE     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x004))
#define CUTIE_REG_STORE_TO_FIFO (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x00C))
#define CUTIE_REG_IMG_W       (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x040))
#define CUTIE_REG_IMG_H       (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x044))
#define CUTIE_REG_POOL_EN     (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x050))
#define CUTIE_REG_POOL_TYPE   (*(volatile uint32_t *)(CUTIE_CFG_BASE + 0x054))

int main(void) {
  uint32_t x = 0x12345678u;
  uint32_t heartbeat = 0u;

  MMIO_SCRATCH0 = 0xCAFEBABEu;
  MMIO_SCRATCH1 = 0x0BADF00Du;
  MMIO_UART_TX = 0x00000041u;

  CUTIE_REG_DISABLE = 0x00000000u;
  CUTIE_REG_IMG_W = 64u;
  CUTIE_REG_IMG_H = 64u;
  CUTIE_REG_POOL_EN = 1u;
  CUTIE_REG_POOL_TYPE = 0u;
  CUTIE_REG_STORE_TO_FIFO = 1u;
  CUTIE_REG_START = 1u;

  for (;;) {
    x = (x << 1) ^ (x >> 3) ^ 0x1d872b41u;
    heartbeat++;
    MMIO_GPIO = x ^ heartbeat;
    MMIO_SCRATCH0 = x;
    MMIO_SCRATCH1 = heartbeat;
    if ((heartbeat & 0x0fu) == 0u) {
      MMIO_UART_TX = 0x0000002eu;
    }
    __asm__ volatile("" : : "r"(x));
  }
}
