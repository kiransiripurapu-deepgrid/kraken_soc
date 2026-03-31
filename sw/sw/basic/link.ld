ENTRY(_start)

MEMORY
{
  L2_RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 256K
}

SECTIONS
{
  .text : {
    KEEP(*(.init))
    *(.text*)
    *(.rodata*)
  } > L2_RAM

  .data : {
    *(.data*)
  } > L2_RAM

  .bss (NOLOAD) : {
    *(.bss*)
    *(COMMON)
  } > L2_RAM

  . = ALIGN(16);
  _end = .;
  _stack_top = ORIGIN(L2_RAM) + LENGTH(L2_RAM);
}
