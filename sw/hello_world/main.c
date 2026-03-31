#include <stdint.h>

#define MMIO_BASE      0x1A100000u
#define MMIO_SCRATCH0  (*(volatile uint32_t *)(MMIO_BASE + 0x00))
#define MMIO_SCRATCH1  (*(volatile uint32_t *)(MMIO_BASE + 0x04))
#define MMIO_GPIO      (*(volatile uint32_t *)(MMIO_BASE + 0x08))
#define MMIO_UART_TX   (*(volatile uint32_t *)(MMIO_BASE + 0x0C))

static void uart_putc(char c) {
  MMIO_UART_TX = (uint32_t)(uint8_t)c;
}

int main(void) {
  uint32_t heartbeat = 0u;

  MMIO_SCRATCH0 = 0x48454C4Fu; /* "HELO" marker */
  MMIO_SCRATCH1 = 0x00000001u;
  MMIO_GPIO = 0x00000001u;

  uart_putc('H');
  uart_putc('E');
  uart_putc('L');
  uart_putc('L');
  uart_putc('O');
  uart_putc(' ');
  uart_putc('W');
  uart_putc('O');
  uart_putc('R');
  uart_putc('L');
  uart_putc('D');
  uart_putc('\r');
  uart_putc('\n');

  for (;;) {
    heartbeat++;
    MMIO_GPIO = heartbeat;
    if ((heartbeat & 0x3FFu) == 0u) {
      uart_putc('.');
    }
  }

  return 0;
}
