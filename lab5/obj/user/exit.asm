
obj/__user_exit.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	132000ef          	jal	800152 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	832e                	mv	t1,a1
  80002a:	e822                	sd	s0,16(sp)
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	85aa                	mv	a1,a0
__panic(const char *file, int line, const char *fmt, ...) {
  80002e:	8432                	mv	s0,a2
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	00000517          	auipc	a0,0x0
  800034:	63850513          	addi	a0,a0,1592 # 800668 <main+0x118>
  800038:	861a                	mv	a2,t1
    va_start(ap, fmt);
  80003a:	02810313          	addi	t1,sp,40
__panic(const char *file, int line, const char *fmt, ...) {
  80003e:	ec06                	sd	ra,24(sp)
  800040:	f436                	sd	a3,40(sp)
  800042:	f83a                	sd	a4,48(sp)
  800044:	fc3e                	sd	a5,56(sp)
  800046:	e0c2                	sd	a6,64(sp)
  800048:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80004a:	e41a                	sd	t1,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80004c:	058000ef          	jal	8000a4 <cprintf>
    vcprintf(fmt, ap);
  800050:	65a2                	ld	a1,8(sp)
  800052:	8522                	mv	a0,s0
  800054:	030000ef          	jal	800084 <vcprintf>
    cprintf("\n");
  800058:	00000517          	auipc	a0,0x0
  80005c:	63050513          	addi	a0,a0,1584 # 800688 <main+0x138>
  800060:	044000ef          	jal	8000a4 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	5559                	li	a0,-10
  800066:	0ca000ef          	jal	800130 <exit>

000000000080006a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  80006a:	1141                	addi	sp,sp,-16
  80006c:	e022                	sd	s0,0(sp)
  80006e:	e406                	sd	ra,8(sp)
  800070:	842e                	mv	s0,a1
    sys_putc(c);
  800072:	0b8000ef          	jal	80012a <sys_putc>
    (*cnt) ++;
  800076:	401c                	lw	a5,0(s0)
}
  800078:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  80007a:	2785                	addiw	a5,a5,1
  80007c:	c01c                	sw	a5,0(s0)
}
  80007e:	6402                	ld	s0,0(sp)
  800080:	0141                	addi	sp,sp,16
  800082:	8082                	ret

0000000000800084 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800084:	1101                	addi	sp,sp,-32
  800086:	862a                	mv	a2,a0
  800088:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80008a:	00000517          	auipc	a0,0x0
  80008e:	fe050513          	addi	a0,a0,-32 # 80006a <cputch>
  800092:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800094:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800096:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800098:	134000ef          	jal	8001cc <vprintfmt>
    return cnt;
}
  80009c:	60e2                	ld	ra,24(sp)
  80009e:	4532                	lw	a0,12(sp)
  8000a0:	6105                	addi	sp,sp,32
  8000a2:	8082                	ret

00000000008000a4 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a4:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a6:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000aa:	f42e                	sd	a1,40(sp)
  8000ac:	f832                	sd	a2,48(sp)
  8000ae:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000b0:	862a                	mv	a2,a0
  8000b2:	004c                	addi	a1,sp,4
  8000b4:	00000517          	auipc	a0,0x0
  8000b8:	fb650513          	addi	a0,a0,-74 # 80006a <cputch>
  8000bc:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000be:	ec06                	sd	ra,24(sp)
  8000c0:	e0ba                	sd	a4,64(sp)
  8000c2:	e4be                	sd	a5,72(sp)
  8000c4:	e8c2                	sd	a6,80(sp)
  8000c6:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000c8:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000ca:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000cc:	100000ef          	jal	8001cc <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000d0:	60e2                	ld	ra,24(sp)
  8000d2:	4512                	lw	a0,4(sp)
  8000d4:	6125                	addi	sp,sp,96
  8000d6:	8082                	ret

00000000008000d8 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d8:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000da:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  8000de:	e42a                	sd	a0,8(sp)
  8000e0:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  8000e2:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  8000e4:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  8000e6:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  8000e8:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ea:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  8000ec:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ee:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  8000f0:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  8000f2:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  8000f4:	e142                	sd	a6,128(sp)
  8000f6:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000f8:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);

    asm volatile (
  8000fa:	6522                	ld	a0,8(sp)
  8000fc:	75a2                	ld	a1,40(sp)
  8000fe:	7642                	ld	a2,48(sp)
  800100:	76e2                	ld	a3,56(sp)
  800102:	6706                	ld	a4,64(sp)
  800104:	67a6                	ld	a5,72(sp)
  800106:	00000073          	ecall
  80010a:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  80010e:	4572                	lw	a0,28(sp)
  800110:	6149                	addi	sp,sp,144
  800112:	8082                	ret

0000000000800114 <sys_exit>:

int
sys_exit(int64_t error_code) {
  800114:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  800116:	4505                	li	a0,1
  800118:	b7c1                	j	8000d8 <syscall>

000000000080011a <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  80011a:	4509                	li	a0,2
  80011c:	bf75                	j	8000d8 <syscall>

000000000080011e <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  80011e:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  800120:	85aa                	mv	a1,a0
  800122:	450d                	li	a0,3
  800124:	bf55                	j	8000d8 <syscall>

0000000000800126 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800126:	4529                	li	a0,10
  800128:	bf45                	j	8000d8 <syscall>

000000000080012a <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  80012a:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80012c:	4579                	li	a0,30
  80012e:	b76d                	j	8000d8 <syscall>

0000000000800130 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800134:	fe1ff0ef          	jal	800114 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800138:	00000517          	auipc	a0,0x0
  80013c:	55850513          	addi	a0,a0,1368 # 800690 <main+0x140>
  800140:	f65ff0ef          	jal	8000a4 <cprintf>
    while (1);
  800144:	a001                	j	800144 <exit+0x14>

0000000000800146 <fork>:
}

int
fork(void) {
    return sys_fork();
  800146:	bfd1                	j	80011a <sys_fork>

0000000000800148 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800148:	4581                	li	a1,0
  80014a:	4501                	li	a0,0
  80014c:	bfc9                	j	80011e <sys_wait>

000000000080014e <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014e:	bfc1                	j	80011e <sys_wait>

0000000000800150 <yield>:
}

void
yield(void) {
    sys_yield();
  800150:	bfd9                	j	800126 <sys_yield>

0000000000800152 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800152:	1141                	addi	sp,sp,-16
  800154:	e406                	sd	ra,8(sp)
    int ret = main();
  800156:	3fa000ef          	jal	800550 <main>
    exit(ret);
  80015a:	fd7ff0ef          	jal	800130 <exit>

000000000080015e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800164:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	f022                	sd	s0,32(sp)
  800170:	ec26                	sd	s1,24(sp)
  800172:	e84a                	sd	s2,16(sp)
  800174:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800176:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80017a:	84aa                	mv	s1,a0
  80017c:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  80017e:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800180:	05067063          	bgeu	a2,a6,8001c0 <printnum+0x62>
  800184:	e44e                	sd	s3,8(sp)
  800186:	89be                	mv	s3,a5
        while (-- width > 0)
  800188:	4785                	li	a5,1
  80018a:	00e7d763          	bge	a5,a4,800198 <printnum+0x3a>
            putch(padc, putdat);
  80018e:	85ca                	mv	a1,s2
  800190:	854e                	mv	a0,s3
        while (-- width > 0)
  800192:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800194:	9482                	jalr	s1
        while (-- width > 0)
  800196:	fc65                	bnez	s0,80018e <printnum+0x30>
  800198:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019a:	1a02                	slli	s4,s4,0x20
  80019c:	020a5a13          	srli	s4,s4,0x20
  8001a0:	00000797          	auipc	a5,0x0
  8001a4:	50878793          	addi	a5,a5,1288 # 8006a8 <main+0x158>
  8001a8:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001aa:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ac:	0007c503          	lbu	a0,0(a5)
}
  8001b0:	70a2                	ld	ra,40(sp)
  8001b2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	85ca                	mv	a1,s2
  8001b6:	87a6                	mv	a5,s1
}
  8001b8:	6942                	ld	s2,16(sp)
  8001ba:	64e2                	ld	s1,24(sp)
  8001bc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001be:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c0:	03065633          	divu	a2,a2,a6
  8001c4:	8722                	mv	a4,s0
  8001c6:	f99ff0ef          	jal	80015e <printnum>
  8001ca:	bfc1                	j	80019a <printnum+0x3c>

00000000008001cc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001cc:	7119                	addi	sp,sp,-128
  8001ce:	f4a6                	sd	s1,104(sp)
  8001d0:	f0ca                	sd	s2,96(sp)
  8001d2:	ecce                	sd	s3,88(sp)
  8001d4:	e8d2                	sd	s4,80(sp)
  8001d6:	e4d6                	sd	s5,72(sp)
  8001d8:	e0da                	sd	s6,64(sp)
  8001da:	f862                	sd	s8,48(sp)
  8001dc:	fc86                	sd	ra,120(sp)
  8001de:	f8a2                	sd	s0,112(sp)
  8001e0:	fc5e                	sd	s7,56(sp)
  8001e2:	f466                	sd	s9,40(sp)
  8001e4:	f06a                	sd	s10,32(sp)
  8001e6:	ec6e                	sd	s11,24(sp)
  8001e8:	892a                	mv	s2,a0
  8001ea:	84ae                	mv	s1,a1
  8001ec:	8c32                	mv	s8,a2
  8001ee:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f0:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f4:	05500b13          	li	s6,85
  8001f8:	00000a97          	auipc	s5,0x0
  8001fc:	6d4a8a93          	addi	s5,s5,1748 # 8008cc <main+0x37c>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	000c4503          	lbu	a0,0(s8)
  800204:	001c0413          	addi	s0,s8,1
  800208:	01350a63          	beq	a0,s3,80021c <vprintfmt+0x50>
            if (ch == '\0') {
  80020c:	cd0d                	beqz	a0,800246 <vprintfmt+0x7a>
            putch(ch, putdat);
  80020e:	85a6                	mv	a1,s1
  800210:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	00044503          	lbu	a0,0(s0)
  800216:	0405                	addi	s0,s0,1
  800218:	ff351ae3          	bne	a0,s3,80020c <vprintfmt+0x40>
        width = precision = -1;
  80021c:	5cfd                	li	s9,-1
  80021e:	8d66                	mv	s10,s9
        char padc = ' ';
  800220:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800224:	4b81                	li	s7,0
  800226:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  800228:	00044683          	lbu	a3,0(s0)
  80022c:	00140c13          	addi	s8,s0,1
  800230:	fdd6859b          	addiw	a1,a3,-35
  800234:	0ff5f593          	zext.b	a1,a1
  800238:	02bb6663          	bltu	s6,a1,800264 <vprintfmt+0x98>
  80023c:	058a                	slli	a1,a1,0x2
  80023e:	95d6                	add	a1,a1,s5
  800240:	4198                	lw	a4,0(a1)
  800242:	9756                	add	a4,a4,s5
  800244:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800246:	70e6                	ld	ra,120(sp)
  800248:	7446                	ld	s0,112(sp)
  80024a:	74a6                	ld	s1,104(sp)
  80024c:	7906                	ld	s2,96(sp)
  80024e:	69e6                	ld	s3,88(sp)
  800250:	6a46                	ld	s4,80(sp)
  800252:	6aa6                	ld	s5,72(sp)
  800254:	6b06                	ld	s6,64(sp)
  800256:	7be2                	ld	s7,56(sp)
  800258:	7c42                	ld	s8,48(sp)
  80025a:	7ca2                	ld	s9,40(sp)
  80025c:	7d02                	ld	s10,32(sp)
  80025e:	6de2                	ld	s11,24(sp)
  800260:	6109                	addi	sp,sp,128
  800262:	8082                	ret
            putch('%', putdat);
  800264:	85a6                	mv	a1,s1
  800266:	02500513          	li	a0,37
  80026a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80026c:	fff44783          	lbu	a5,-1(s0)
  800270:	02500713          	li	a4,37
  800274:	8c22                	mv	s8,s0
  800276:	f8e785e3          	beq	a5,a4,800200 <vprintfmt+0x34>
  80027a:	ffec4783          	lbu	a5,-2(s8)
  80027e:	1c7d                	addi	s8,s8,-1
  800280:	fee79de3          	bne	a5,a4,80027a <vprintfmt+0xae>
  800284:	bfb5                	j	800200 <vprintfmt+0x34>
                ch = *fmt;
  800286:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80028a:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80028c:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800290:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800294:	8462                	mv	s0,s8
                ch = *fmt;
  800296:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800298:	02e56463          	bltu	a0,a4,8002c0 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  80029c:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002a0:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002a4:	0197073b          	addw	a4,a4,s9
  8002a8:	0017171b          	slliw	a4,a4,0x1
  8002ac:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  8002ae:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002b2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002b8:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  8002bc:	feb570e3          	bgeu	a0,a1,80029c <vprintfmt+0xd0>
            if (width < 0)
  8002c0:	f60d54e3          	bgez	s10,800228 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002c4:	8d66                	mv	s10,s9
  8002c6:	5cfd                	li	s9,-1
  8002c8:	b785                	j	800228 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002ca:	8db6                	mv	s11,a3
  8002cc:	8462                	mv	s0,s8
  8002ce:	bfa9                	j	800228 <vprintfmt+0x5c>
  8002d0:	8462                	mv	s0,s8
            altflag = 1;
  8002d2:	4b85                	li	s7,1
            goto reswitch;
  8002d4:	bf91                	j	800228 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002d6:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002d8:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002dc:	00c7c463          	blt	a5,a2,8002e4 <vprintfmt+0x118>
    else if (lflag) {
  8002e0:	18060763          	beqz	a2,80046e <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  8002e4:	000a3603          	ld	a2,0(s4)
  8002e8:	46c1                	li	a3,16
  8002ea:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002ec:	000d879b          	sext.w	a5,s11
  8002f0:	876a                	mv	a4,s10
  8002f2:	85a6                	mv	a1,s1
  8002f4:	854a                	mv	a0,s2
  8002f6:	e69ff0ef          	jal	80015e <printnum>
            break;
  8002fa:	b719                	j	800200 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002fc:	000a2503          	lw	a0,0(s4)
  800300:	85a6                	mv	a1,s1
  800302:	0a21                	addi	s4,s4,8
  800304:	9902                	jalr	s2
            break;
  800306:	bded                	j	800200 <vprintfmt+0x34>
    if (lflag >= 2) {
  800308:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80030a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80030e:	00c7c463          	blt	a5,a2,800316 <vprintfmt+0x14a>
    else if (lflag) {
  800312:	14060963          	beqz	a2,800464 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  800316:	000a3603          	ld	a2,0(s4)
  80031a:	46a9                	li	a3,10
  80031c:	8a3a                	mv	s4,a4
  80031e:	b7f9                	j	8002ec <vprintfmt+0x120>
            putch('0', putdat);
  800320:	85a6                	mv	a1,s1
  800322:	03000513          	li	a0,48
  800326:	9902                	jalr	s2
            putch('x', putdat);
  800328:	85a6                	mv	a1,s1
  80032a:	07800513          	li	a0,120
  80032e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800330:	000a3603          	ld	a2,0(s4)
            goto number;
  800334:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800336:	0a21                	addi	s4,s4,8
            goto number;
  800338:	bf55                	j	8002ec <vprintfmt+0x120>
            putch(ch, putdat);
  80033a:	85a6                	mv	a1,s1
  80033c:	02500513          	li	a0,37
  800340:	9902                	jalr	s2
            break;
  800342:	bd7d                	j	800200 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800344:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800348:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80034a:	0a21                	addi	s4,s4,8
            goto process_precision;
  80034c:	bf95                	j	8002c0 <vprintfmt+0xf4>
    if (lflag >= 2) {
  80034e:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800350:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800354:	00c7c463          	blt	a5,a2,80035c <vprintfmt+0x190>
    else if (lflag) {
  800358:	10060163          	beqz	a2,80045a <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  80035c:	000a3603          	ld	a2,0(s4)
  800360:	46a1                	li	a3,8
  800362:	8a3a                	mv	s4,a4
  800364:	b761                	j	8002ec <vprintfmt+0x120>
            if (width < 0)
  800366:	87ea                	mv	a5,s10
  800368:	000d5363          	bgez	s10,80036e <vprintfmt+0x1a2>
  80036c:	4781                	li	a5,0
  80036e:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800372:	8462                	mv	s0,s8
            goto reswitch;
  800374:	bd55                	j	800228 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800376:	000a3703          	ld	a4,0(s4)
  80037a:	12070b63          	beqz	a4,8004b0 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  80037e:	0da05563          	blez	s10,800448 <vprintfmt+0x27c>
  800382:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800386:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  80038a:	14fd9a63          	bne	s11,a5,8004de <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038e:	00074783          	lbu	a5,0(a4)
  800392:	0007851b          	sext.w	a0,a5
  800396:	c785                	beqz	a5,8003be <vprintfmt+0x1f2>
  800398:	5dfd                	li	s11,-1
  80039a:	000cc563          	bltz	s9,8003a4 <vprintfmt+0x1d8>
  80039e:	3cfd                	addiw	s9,s9,-1
  8003a0:	01bc8d63          	beq	s9,s11,8003ba <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a4:	0c0b9a63          	bnez	s7,800478 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  8003a8:	85a6                	mv	a1,s1
  8003aa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ac:	00044783          	lbu	a5,0(s0)
  8003b0:	0405                	addi	s0,s0,1
  8003b2:	3d7d                	addiw	s10,s10,-1
  8003b4:	0007851b          	sext.w	a0,a5
  8003b8:	f3ed                	bnez	a5,80039a <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  8003ba:	01a05963          	blez	s10,8003cc <vprintfmt+0x200>
                putch(' ', putdat);
  8003be:	85a6                	mv	a1,s1
  8003c0:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003c6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c8:	fe0d1be3          	bnez	s10,8003be <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003cc:	0a21                	addi	s4,s4,8
  8003ce:	bd0d                	j	800200 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003d0:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003d2:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003d6:	00c7c363          	blt	a5,a2,8003dc <vprintfmt+0x210>
    else if (lflag) {
  8003da:	c625                	beqz	a2,800442 <vprintfmt+0x276>
        return va_arg(*ap, long);
  8003dc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003e0:	0a044f63          	bltz	s0,80049e <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  8003e4:	8622                	mv	a2,s0
  8003e6:	8a5e                	mv	s4,s7
  8003e8:	46a9                	li	a3,10
  8003ea:	b709                	j	8002ec <vprintfmt+0x120>
            if (err < 0) {
  8003ec:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f0:	4661                	li	a2,24
            if (err < 0) {
  8003f2:	41f7d71b          	sraiw	a4,a5,0x1f
  8003f6:	8fb9                	xor	a5,a5,a4
  8003f8:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003fc:	02d64663          	blt	a2,a3,800428 <vprintfmt+0x25c>
  800400:	00000797          	auipc	a5,0x0
  800404:	62878793          	addi	a5,a5,1576 # 800a28 <error_string>
  800408:	00369713          	slli	a4,a3,0x3
  80040c:	97ba                	add	a5,a5,a4
  80040e:	639c                	ld	a5,0(a5)
  800410:	cf81                	beqz	a5,800428 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  800412:	86be                	mv	a3,a5
  800414:	00000617          	auipc	a2,0x0
  800418:	2c460613          	addi	a2,a2,708 # 8006d8 <main+0x188>
  80041c:	85a6                	mv	a1,s1
  80041e:	854a                	mv	a0,s2
  800420:	0f4000ef          	jal	800514 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800424:	0a21                	addi	s4,s4,8
  800426:	bbe9                	j	800200 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800428:	00000617          	auipc	a2,0x0
  80042c:	2a060613          	addi	a2,a2,672 # 8006c8 <main+0x178>
  800430:	85a6                	mv	a1,s1
  800432:	854a                	mv	a0,s2
  800434:	0e0000ef          	jal	800514 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800438:	0a21                	addi	s4,s4,8
  80043a:	b3d9                	j	800200 <vprintfmt+0x34>
            lflag ++;
  80043c:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  80043e:	8462                	mv	s0,s8
            goto reswitch;
  800440:	b3e5                	j	800228 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800442:	000a2403          	lw	s0,0(s4)
  800446:	bf69                	j	8003e0 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800448:	00074783          	lbu	a5,0(a4)
  80044c:	0007851b          	sext.w	a0,a5
  800450:	dfb5                	beqz	a5,8003cc <vprintfmt+0x200>
  800452:	00170413          	addi	s0,a4,1
  800456:	5dfd                	li	s11,-1
  800458:	b789                	j	80039a <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  80045a:	000a6603          	lwu	a2,0(s4)
  80045e:	46a1                	li	a3,8
  800460:	8a3a                	mv	s4,a4
  800462:	b569                	j	8002ec <vprintfmt+0x120>
  800464:	000a6603          	lwu	a2,0(s4)
  800468:	46a9                	li	a3,10
  80046a:	8a3a                	mv	s4,a4
  80046c:	b541                	j	8002ec <vprintfmt+0x120>
  80046e:	000a6603          	lwu	a2,0(s4)
  800472:	46c1                	li	a3,16
  800474:	8a3a                	mv	s4,a4
  800476:	bd9d                	j	8002ec <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800478:	3781                	addiw	a5,a5,-32
  80047a:	05e00713          	li	a4,94
  80047e:	f2f775e3          	bgeu	a4,a5,8003a8 <vprintfmt+0x1dc>
                    putch('?', putdat);
  800482:	03f00513          	li	a0,63
  800486:	85a6                	mv	a1,s1
  800488:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048a:	00044783          	lbu	a5,0(s0)
  80048e:	0405                	addi	s0,s0,1
  800490:	3d7d                	addiw	s10,s10,-1
  800492:	0007851b          	sext.w	a0,a5
  800496:	d395                	beqz	a5,8003ba <vprintfmt+0x1ee>
  800498:	f00cd3e3          	bgez	s9,80039e <vprintfmt+0x1d2>
  80049c:	bff1                	j	800478 <vprintfmt+0x2ac>
                putch('-', putdat);
  80049e:	85a6                	mv	a1,s1
  8004a0:	02d00513          	li	a0,45
  8004a4:	9902                	jalr	s2
                num = -(long long)num;
  8004a6:	40800633          	neg	a2,s0
  8004aa:	8a5e                	mv	s4,s7
  8004ac:	46a9                	li	a3,10
  8004ae:	bd3d                	j	8002ec <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004b0:	01a05663          	blez	s10,8004bc <vprintfmt+0x2f0>
  8004b4:	02d00793          	li	a5,45
  8004b8:	00fd9b63          	bne	s11,a5,8004ce <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004bc:	02800793          	li	a5,40
  8004c0:	853e                	mv	a0,a5
  8004c2:	00000417          	auipc	s0,0x0
  8004c6:	1ff40413          	addi	s0,s0,511 # 8006c1 <main+0x171>
  8004ca:	5dfd                	li	s11,-1
  8004cc:	b5f9                	j	80039a <vprintfmt+0x1ce>
  8004ce:	00000417          	auipc	s0,0x0
  8004d2:	1f340413          	addi	s0,s0,499 # 8006c1 <main+0x171>
                p = "(null)";
  8004d6:	00000717          	auipc	a4,0x0
  8004da:	1ea70713          	addi	a4,a4,490 # 8006c0 <main+0x170>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	853a                	mv	a0,a4
  8004e0:	85e6                	mv	a1,s9
  8004e2:	e43a                	sd	a4,8(sp)
  8004e4:	050000ef          	jal	800534 <strnlen>
  8004e8:	40ad0d3b          	subw	s10,s10,a0
  8004ec:	6722                	ld	a4,8(sp)
  8004ee:	01a05b63          	blez	s10,800504 <vprintfmt+0x338>
                    putch(padc, putdat);
  8004f2:	2d81                	sext.w	s11,s11
  8004f4:	85a6                	mv	a1,s1
  8004f6:	856e                	mv	a0,s11
  8004f8:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fa:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004fc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fe:	6722                	ld	a4,8(sp)
  800500:	fe0d1ae3          	bnez	s10,8004f4 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800504:	00074783          	lbu	a5,0(a4)
  800508:	0007851b          	sext.w	a0,a5
  80050c:	ec0780e3          	beqz	a5,8003cc <vprintfmt+0x200>
  800510:	5dfd                	li	s11,-1
  800512:	b561                	j	80039a <vprintfmt+0x1ce>

0000000000800514 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800514:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800516:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051e:	ec06                	sd	ra,24(sp)
  800520:	f83a                	sd	a4,48(sp)
  800522:	fc3e                	sd	a5,56(sp)
  800524:	e0c2                	sd	a6,64(sp)
  800526:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800528:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052a:	ca3ff0ef          	jal	8001cc <vprintfmt>
}
  80052e:	60e2                	ld	ra,24(sp)
  800530:	6161                	addi	sp,sp,80
  800532:	8082                	ret

0000000000800534 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800534:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800536:	e589                	bnez	a1,800540 <strnlen+0xc>
  800538:	a811                	j	80054c <strnlen+0x18>
        cnt ++;
  80053a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80053c:	00f58863          	beq	a1,a5,80054c <strnlen+0x18>
  800540:	00f50733          	add	a4,a0,a5
  800544:	00074703          	lbu	a4,0(a4)
  800548:	fb6d                	bnez	a4,80053a <strnlen+0x6>
  80054a:	85be                	mv	a1,a5
    }
    return cnt;
}
  80054c:	852e                	mv	a0,a1
  80054e:	8082                	ret

0000000000800550 <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  800550:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  800552:	00000517          	auipc	a0,0x0
  800556:	24e50513          	addi	a0,a0,590 # 8007a0 <main+0x250>
main(void) {
  80055a:	ec06                	sd	ra,24(sp)
  80055c:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  80055e:	b47ff0ef          	jal	8000a4 <cprintf>
    if ((pid = fork()) == 0) {
  800562:	be5ff0ef          	jal	800146 <fork>
  800566:	c561                	beqz	a0,80062e <main+0xde>
  800568:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  80056a:	85aa                	mv	a1,a0
  80056c:	00000517          	auipc	a0,0x0
  800570:	27450513          	addi	a0,a0,628 # 8007e0 <main+0x290>
  800574:	b31ff0ef          	jal	8000a4 <cprintf>
    }
    assert(pid > 0);
  800578:	08805c63          	blez	s0,800610 <main+0xc0>
    cprintf("I am the parent, waiting now..\n");
  80057c:	00000517          	auipc	a0,0x0
  800580:	2bc50513          	addi	a0,a0,700 # 800838 <main+0x2e8>
  800584:	b21ff0ef          	jal	8000a4 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  800588:	006c                	addi	a1,sp,12
  80058a:	8522                	mv	a0,s0
  80058c:	bc3ff0ef          	jal	80014e <waitpid>
  800590:	e131                	bnez	a0,8005d4 <main+0x84>
  800592:	4732                	lw	a4,12(sp)
  800594:	00001797          	auipc	a5,0x1
  800598:	a6c7a783          	lw	a5,-1428(a5) # 801000 <magic>
  80059c:	02f71c63          	bne	a4,a5,8005d4 <main+0x84>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005a0:	006c                	addi	a1,sp,12
  8005a2:	8522                	mv	a0,s0
  8005a4:	babff0ef          	jal	80014e <waitpid>
  8005a8:	c529                	beqz	a0,8005f2 <main+0xa2>
  8005aa:	b9fff0ef          	jal	800148 <wait>
  8005ae:	c131                	beqz	a0,8005f2 <main+0xa2>
    cprintf("waitpid %d ok.\n", pid);
  8005b0:	85a2                	mv	a1,s0
  8005b2:	00000517          	auipc	a0,0x0
  8005b6:	2fe50513          	addi	a0,a0,766 # 8008b0 <main+0x360>
  8005ba:	aebff0ef          	jal	8000a4 <cprintf>

    cprintf("exit pass.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	30250513          	addi	a0,a0,770 # 8008c0 <main+0x370>
  8005c6:	adfff0ef          	jal	8000a4 <cprintf>
    return 0;
}
  8005ca:	60e2                	ld	ra,24(sp)
  8005cc:	6442                	ld	s0,16(sp)
  8005ce:	4501                	li	a0,0
  8005d0:	6105                	addi	sp,sp,32
  8005d2:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005d4:	00000697          	auipc	a3,0x0
  8005d8:	28468693          	addi	a3,a3,644 # 800858 <main+0x308>
  8005dc:	00000617          	auipc	a2,0x0
  8005e0:	23460613          	addi	a2,a2,564 # 800810 <main+0x2c0>
  8005e4:	45ed                	li	a1,27
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	24250513          	addi	a0,a0,578 # 800828 <main+0x2d8>
  8005ee:	a39ff0ef          	jal	800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005f2:	00000697          	auipc	a3,0x0
  8005f6:	29668693          	addi	a3,a3,662 # 800888 <main+0x338>
  8005fa:	00000617          	auipc	a2,0x0
  8005fe:	21660613          	addi	a2,a2,534 # 800810 <main+0x2c0>
  800602:	45f1                	li	a1,28
  800604:	00000517          	auipc	a0,0x0
  800608:	22450513          	addi	a0,a0,548 # 800828 <main+0x2d8>
  80060c:	a1bff0ef          	jal	800026 <__panic>
    assert(pid > 0);
  800610:	00000697          	auipc	a3,0x0
  800614:	1f868693          	addi	a3,a3,504 # 800808 <main+0x2b8>
  800618:	00000617          	auipc	a2,0x0
  80061c:	1f860613          	addi	a2,a2,504 # 800810 <main+0x2c0>
  800620:	45e1                	li	a1,24
  800622:	00000517          	auipc	a0,0x0
  800626:	20650513          	addi	a0,a0,518 # 800828 <main+0x2d8>
  80062a:	9fdff0ef          	jal	800026 <__panic>
        cprintf("I am the child.\n");
  80062e:	00000517          	auipc	a0,0x0
  800632:	19a50513          	addi	a0,a0,410 # 8007c8 <main+0x278>
  800636:	a6fff0ef          	jal	8000a4 <cprintf>
        yield();
  80063a:	b17ff0ef          	jal	800150 <yield>
        yield();
  80063e:	b13ff0ef          	jal	800150 <yield>
        yield();
  800642:	b0fff0ef          	jal	800150 <yield>
        yield();
  800646:	b0bff0ef          	jal	800150 <yield>
        yield();
  80064a:	b07ff0ef          	jal	800150 <yield>
        yield();
  80064e:	b03ff0ef          	jal	800150 <yield>
        yield();
  800652:	affff0ef          	jal	800150 <yield>
        exit(magic);
  800656:	00001517          	auipc	a0,0x1
  80065a:	9aa52503          	lw	a0,-1622(a0) # 801000 <magic>
  80065e:	ad3ff0ef          	jal	800130 <exit>
