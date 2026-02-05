/* GUESS WHAT. NOW I HAVE A SOMEWHAT OK IDEA OF WHAT THIS FILE DOES */

/* THIS FILE IS THE LINKER SCRIPT

IT DESCRIBES THE PHYSICAL MEMORY , AKA THE FLASH MEMORY AND RAM 

DEFINES THE LOCATION OF SECTIONS GOING INTO THE MEMORY

DEFINE SYMBOLS THAT ASSEMBLY CODE USES AT RUNTIME 

*/

/* THIS FILE IS USED ONLY ONCE AT LINK TIME */

/* IF THIS SCRIPT IS WRONG, THE PROGRAM WILL STILL GET COMPILED BUT WILL IMMEDIATELY CRASH ON RUNTIME

*/



MEMORY
{
	flash(rx):ORIGIN = 0x08000000, LENGTH = 1024K
        ram (rwx):ORIGIN = 0x20000000, LENGTH = 128K
}

/*THE ABOVE SECTION IS THE MEMORY BLOCK , WE DEFINE THE STARTING POINT AND SIZE OF THE FLASH AND RAM, WHAT PERMISSIONS THEY HAVE USING rw and rwx 
*/

/* IF the memory section is defined wrong, then the ram or flash may be overwritten completely */

/* Startup file collects info from this linker script to know about the flash and ram addresses. As for cortex-M hardware, IVT is expected at the start of flash, and stack pointer must be in ram */ 


__flash_memory_start__	= ORIGIN(flash);
__flash_memory_size__	= LENGTH(flash);

__RAM_START__ = ORIGIN(ram);
__RAM_SIZE__   = LENGTH(ram);

__RAM_ENDING__ = __RAM_START__ + __RAM_SIZE__;

/*These variables related to memory_start and memory_size and ending are used to compute the boundaries of each sub sections of the memory(flash and memory) .ANY wrong allotment will result in undesirable overwrites. so be careful */ 




//_estack = 0x00000000;
_estack = __RAM_ENDING__;    

/* the above variable _estack denotes the initial stack pointer, also it is the first word in the vector table . this file is used in the startup.s file . Wrong sp initialization could lead to corruption of memory while performing push and pop operations for data */



/* The above _estack variable is imported in the startup file to find the stack pointer */




/* START OF SECTIONS BLOCK */
	
SECTIONS {
	. = __flash_memory_start__;

        
        /* ABOVE LINE SETS LOCATION COUNTER AND THE DEFAULT LOCATION COUNTER IS SET TO FLASH BASE . PART OF THE TASK1 IS PLACE THE VECTOR TABLE AT THE START OF FLASH EMORY */
        
        .isr_vector : {
              . = ALIGN(4);
              KEEP(*(.isr_vector))
              . = ALIGN(4);
        } > flash
        

/* THE above defintion creates a named output section in the final .elffile called .isr_vector . It tells the linker to physically place this section at the very beginning of the flash memory. KEEP (*..)  is a "dont delete order . If the linker piece of code is not used, it is thrown to away to save space . ALIGN ensures the data is aligned to a 4-byte boundary. The Linker uses this to decide the memory of interrupt handler. */
        
 /* ABOVE PIECE OF CODE ensures that the ivt is the first thing in the binary, and if the total size of the vectors exceeds the allocated memory for FLASH, an error will be thrown       
        */
 
 /* Exceptions that can occur : If the table is not 4-byte aligned, a HardFault exception might be triggered before the code even starts running */       
        
 
 
        .text :
        {
          . = ALIGN(4);
          *(.text*)
          *(.rodata*)
          . = ALIGN(4);
        
        } > flash
        
 //THE .text section defines where the instructions and constants (read only data) exist in the hardware
 //.text section creates a .text section in embedded systems
 
 // *(.text*) 
 
 //*(.rodata*) - 
 
 
 // .text and .rodata are grouped together, this creates a "Read-only large block that the CPU can directly execute from FLash( also called execute in place)       
        
        
        
/* rodata refers to read only data. It is placed in Flash becuase it is read-only at runtime */
        
         data_loc = ADDR(.text) + SIZEOF(.text);

        .data : 
        {
          . = ALIGN(4);
          _sdata = .;
          *(.data*)
          . = ALIGN(4);
          _edata = .;
        } > ram AT > flash
        
        _sidata = LOADADDR(.data);
        
/* _sidata defines where .data lives in flash        */


/*   . (the dot) REPRESENTS THE LOCATION COUNTER. when the linker puts code into a section, the cursor moves forward automatically.   


Within the linker itself, the section placement engine or the storage allocation logic makes sure that every time the linker pulls a "chunk" of code from the o. files, an addition operation is performed. The result is then checked against the Memory Region boundaries to ensure that there is still space left

*/

        
        .bss : {
              . = ALIGN(4);
              _sbss = .;
              *(.bss*)
              *(COMMON)
              . = ALIGN(4);
              _ebss = .;
        } > ram	
 /* the .bss section defines zero-initialized memory. if uninitialized global are non-zero, it could cause other problems */

} 
