#include <stdint.h>

#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))

int main(void) {
  uint32_t counter = 0u;

  MMIO_SCRATCH0 = 0xB451C001u;
  MMIO_SCRATCH1 = 0x00000001u;
  MMIO_UART_TX  = 'B';

  for (;;) {
    counter++;
    MMIO_GPIO = counter;

    if ((counter & 0x3fU) == 0u) {
      MMIO_SCRATCH0 = counter;
      MMIO_SCRATCH1 = counter ^ 0x55AA55AAu;
      MMIO_UART_TX = '.';
    }
  }

  return 0;
}
