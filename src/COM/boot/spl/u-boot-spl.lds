 MEMORY { .sram : ORIGIN = 0xFFFF0000, LENGTH = (64 * 1024) }
OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS
{
 .text :
 {
  arch/arm/cpu/armv7/start.o (.text)
  *(.text*)
 } >.sram
 __text_end = .;
 . = ALIGN(0x1000) + 0x1000;
 __ecc_padding_end = .;
 . = __text_end;
 . = ALIGN(4);
 .rodata : { *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*))) } >.sram
 . = ALIGN(4);
 .data : { *(SORT_BY_ALIGNMENT(.data*)) } >.sram
 __ecc_padding_start = .;
 . = ALIGN(4);
 __image_copy_end = .;
 _end = .;
 .bss : {
  . = ALIGN(4);
  __bss_start = .;
  *(.bss*)
  . = ALIGN(4);
  __bss_end__ = .;
 } >.sram
 . = ALIGN(8);
 .malloc :
 {
  __malloc_start = .;
  . = . + (5 * 1024);
  __malloc_end = .;
 } >.sram
 .stack :
 {
  . = . + (4 * 1024);
  . = ALIGN(8);
  __stack_start = .;
 } >.sram
 .spl_irq_stack :
 {
  . = . + (4 << 10);
  . = ALIGN(8);
  __irq_stack_start = .;
 } >.sram
}
