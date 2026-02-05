/* GUESS WHAT, I UNDERSTAND SOMETHING */

/* This assembly LEVEL File is the System startup code */ 
.syntax unified

/* .syntax unified tells the assembler to use the modern ARM/Thumb-2 syntax */
/* Else, if not mentioned, the assembler might reject and cause exceptions */

.cpu cortex-m4
.thumb

/* Forces the compiler to generate 16/32 bit thumb-2 instructions for the Cortex M-4 */

//If .thumb is omitted, it might raise a UsageFault on boot
.extern _estack
.extern _sidata
.extern _sdata
.extern _edata
.extern _sbss
.extern _ebss

/* The above symbols are used to import symbols from the linker script or the .ld script
 Exceptions could arise if those symbols are not defined in the linker script */

.global g_pfnVectors

/* g_pfnVectors is the label which marks the start of the table */

.global Reset_Handler
.global NMI_Handler
.global HardFault_Handler
.global MemManage_Handler
.global BusFault_Handler
.global UsageFault_Handler

.global Default_Exception_Handler

.align 8
.section .isr_vector,"a",%progbits



g_pfnVectors:

/* Also each of these are kind of called vectors because these interrupts and stored values force the CPU into a new execution path . It is kind of a mathematical analogy. Thats what i understood */



  .word _estack
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  .word MemManage_Handler
  .word BusFault_Handler
  .word UsageFault_Handler
  .word 0

/* All the interrupts are vectored interrupts , that is , the processor does not need to find what type of interrupt happened everytime. for handling each interrupt, a seperate address or value is already defined which will lead to the specific handler for that specific interrupt */

  .word 0
  .word 0
  .word 0
  .word Default_Exception_Handler
  .word Default_Exception_Handler
  .word 0
  .word Default_Exception_Handler
  .word Default_Exception_Handler  
  
/*  _estack is the first word in memory, .word Reset_Handler is the second word and so on.. */
.section .text.Reset_Handler,"ax",%progbits





.type Reset_Handler, %function
.thumb_func

/* the above piece of code tells the tools (Assembler and Linker) to handle the mode
It tells the Reset_Handler is a code entry point and not just a random pice of data or a variables

The linker will treat the symbol as executable and it will be used by the Linker when it builds the symbol table in the .elf file */


/* thumb_func instructs the Assembler to set the address of Reset_Handler stored in the Vector atABLE HAS THE LSB set to 1. The cortex- M processors determine the execution mode based on the address it is jumping to :

Address ends in 0 : CPU tries to switch to ARM Mode (32 bit mode) which could cause issues

If the address ends in 1: CPU switches to Thumb mode (16/32 bit mixed mode) 

when the hardware reads the reset vector from memory at boot, it sees the 1 at the end of the address. This sets the T-bit int the cortex status register (xPSR) 

*/

Reset_Handler:

	
  /* skeleton copy .data */
  
  ldr r0, =_sidata
  ldr r1, =_sdata
  ldr r2, =_edata
  
1: cmp r1, r2
   bcc 2f   /* bcc is branch if carry flag is clear or c is set to 0 . 2f gives the signal to look forward for the next LOCAL label named 2. if it is b instead of f, then the instruction is to look backward */
   b 3f

2: ldr r3, [r0], #4
   str r3, [r1], #4
   b 1b

3:
   /* zero .bss */
   ldr r1, =_sbss
   ldr r2, =_ebss
   movs r3, #0

4: cmp r1, r2
   bcc 5f            /* branch to local label 5 if carry flag is 0 */
   b 6f            /* look for local label 6 forward */
   
5: str r3, [r1], #4
   b 4b
     
6:
   bl main
/*bl main is used to branch back into main */
7: b 7b  

.section .text.Default_Exception_Handler,"ax",%progbits  /* this ends the previous section */


/* in the above code , ax means a - allocatable , that is the linker has to see that the code must be stored in the device FLASH memory , x indicates that the bytes of the section is instruction and not data */
/* progbuts tell the Linker the section contain "Program Bits " , that is, the specific hex code for the program instructions will be converted to hex code and stored as such in the memory */

.type Default_Exception_Handler, %function
.thumb_func

/* Exception or Interrupt Number :

The xPSR or the status program register (0 - 8 ) tells what the CPU is currently doing

0 - the cpu is doing normal execution

2 - Non Maskable Interrupt

4 - MemManage INTERRUPT - Illegal memory access is detected

5 - BusFault 

3 - the CPU is handling a HardFault

B - SVCall - Handling a system call
 
15 - The CPU is handling a SysTick interrupt
*/

Default_Exception_Handler:

	b Default_Exception_Handler


.thumb_set NMI_Handler, Default_Exception_Handler
.thumb_set HardFault_Handler, Default_Exception_Handler
.thumb_set MemManage_Handler, Default_Exception_Handler
.thumb_set BusFault_Handler, Default_Exception_Handler
.thumb_set UsageFault_Handler, Default_Exception_Handler
/*	
NMI_Handler:
	b Default_Exception_Handler
HardFault_Handler:
	b Default_Exception_Handler
MemManage_Handler:
	b Default_Exception_Handler
BusFault_Handler:
	b Default_Exception_Handler
UsageFault_Handler:
	b Default_Exception_Handler
*/
