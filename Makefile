#  The below three lines are for choosing the compiler that will execute the code. Normally the # system will generate instructions for x86 but since we need it for stm, we have to choose arm 



# Also the objcopy is used for converting the "firmware.elf" file into firmware.bin

# size reads section sizes from the ELF file and tells us how much Flash our program uses and  
# how much RAM is also used

CC      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE    = arm-none-eabi-size

TARGET = firmware

C_SRCS = src/main.c
S_SRCS = startup/startup_stm32f4.s
LD_SCRIPT = ld/linker.ld


# During linking , the linker needs .o files and not .c files 

OBJS = $(C_SRCS:.c=.o) $(S_SRCS:.s=.o)


# CFLAGS is the list of compiler options used whenever GCC compiles our code

# CFLAGS will contain data on CPU TYPE, INSTRUCTION_SET, OPTIMIZATION, DEBUG INFO, FLOATING
# POINT, BARE-METAL RULES 


#  -mcpu= cortex-m4 tells gcc to generate machine code specifically for Cortex M4

# -mthumb forces thumb instruction encoding because Cortex-M cores only support Thumb. Not 
#  possibe without Thumb

# -O0 disables optimization . if optimization is enabled, the code and variables might get 
#  reordered

# The -g symbol indicates to show the debug symbols in the ELF file. With this, GDB will ashow 
# function names, source lines, variables

# -Wall enables most compiler warnings since bare-metal code is fragile

# -ffreestanding means that main() is the entry point and that startup is provided which is 
# essential for bare-metal

# -nostdlib prevents linking against libc, libgcc startup files, default runtime


# -mfpu enables the hardware floating point

# -mfloat-abi = hard means that hardware floating point convention is followed. and float 
# arguments are passed only in fp registers and not in integer registers

CFLAGS = -mcpu=cortex-m4 -mthumb -O0 -g \
         -Wall -ffreestanding -nostdlib \
         -mfpu=fpv4-sp-d16 -mfloat-abi=hard
         
ASFLAGS = $(CFLAGS)

# LDFLAGS are the flags passed to the linker . Linking is the stage where all .o files are 
# combined , memory addresses are assigned and firmware elf file is created

#-Map=firmware.map tells the linker to generate a map file showing the memory layout

LDFLAGS = -T $(LD_SCRIPT) -nostdlib -Wl,-Map=$(TARGET).map

#A target is something Make builds



all: $(TARGET).bin

# COMMANDS UNDER A TARGET MUST USE A TAB, NOT SPACES

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
	
#The ABOVE LINE COMPILES THE .c file (in this assignment , it is main.c) into .o file or object code


%.o: %.s
	$(CC) $(ASFLAGS) -c $< -o $@
	
#This above line compiles the (.s or startup file) into the object file
        
$(TARGET).elf: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@
	$(SIZE) $@

#THE ABOVE PIECE OF CODE IS USED TO MAKE THE .elf file from .o file

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

#The above piece of code makes .bin file from .elf file. The firmware.bin file is used to place into the hardware memory

# i guess firmware.elf is the most important file of it all

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).map
        
        
