# STM32F4-EMBEDDED_SYSTEM_ASSIGNMENT-1
Bare-Metal Boot-Up of STM32F4 on QEMU


Steps for execution :

In one terminal :

run the following command : 


make

This should create the compile the source code into object code, create the firmware.elf, firmware.bin ,firmware.map 

To remove these files , run :

make clean

After make step, run :

qemu-system-arm -M olimex-stm32-h405 -kernel firmware.elf -nographic -S -gdb tcp::1234 -semihosting

Open another terminal and run :

gdb-multiarch firmware.elf

If the command is not found, then run :

sudo apt update
sudo apt install gdb-multiarch

Once the command is successfully running 
Type :

target remote:1234 

Once connected, type :

info registers

break main
continue


