
/*

This is header file 

*/


# define SEMIHOSTING_SYS_WRITE0 0x04

/* 0x04 means that the host debugger has to write a null-terminated string to the console" */

static inline int semihosting_call(int reason, void *arg)
{

	int value;
	__asm volatile (
		"mov r0, %1\n"
		"mov r1, %2\n"
		"bkpt 0xAB\n"
		"mov %0, r0\n"
		: "=r"(value)
		: "r"(reason), "r"(arg)
		: "r0", "r1", "memory"
	);
	return value;
}

/* int value stores the return value from the host after the semihosting request completes */

/* __asm volatile is telling the GCC to insert the ARM instructions directly and not to optimize it , that is , it musr execute immediately*

mov r0, %1  - put reason into r0
mov r1, %2 - put argument pointer into r1

*/



/* bkpt 0xAB tells the debugger/emulator to pause execution and handle a request

when executed , CPU stops , qemu detects it and host perform syscall r0 with argument r1

*/
static inline void sh_puts(const char *s)
{
	semihosting_call(SEMIHOSTING_SYS_WRITE0, (void*)s);
}
