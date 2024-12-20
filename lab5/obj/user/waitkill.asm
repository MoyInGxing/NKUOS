
obj/__user_waitkill.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	13a000ef          	jal	80015a <umain>
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
  800034:	67050513          	addi	a0,a0,1648 # 8006a0 <main+0xc0>
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
  80005c:	78050513          	addi	a0,a0,1920 # 8007d8 <main+0x1f8>
  800060:	044000ef          	jal	8000a4 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	5559                	li	a0,-10
  800066:	0d4000ef          	jal	80013a <exit>

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
  800072:	0c2000ef          	jal	800134 <sys_putc>
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
  800098:	13c000ef          	jal	8001d4 <vprintfmt>
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
  8000cc:	108000ef          	jal	8001d4 <vprintfmt>
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

000000000080012a <sys_kill>:
}

int
sys_kill(int64_t pid) {
  80012a:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  80012c:	4531                	li	a0,12
  80012e:	b76d                	j	8000d8 <syscall>

0000000000800130 <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  800130:	4549                	li	a0,18
  800132:	b75d                	j	8000d8 <syscall>

0000000000800134 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800134:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800136:	4579                	li	a0,30
  800138:	b745                	j	8000d8 <syscall>

000000000080013a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80013a:	1141                	addi	sp,sp,-16
  80013c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80013e:	fd7ff0ef          	jal	800114 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800142:	00000517          	auipc	a0,0x0
  800146:	57e50513          	addi	a0,a0,1406 # 8006c0 <main+0xe0>
  80014a:	f5bff0ef          	jal	8000a4 <cprintf>
    while (1);
  80014e:	a001                	j	80014e <exit+0x14>

0000000000800150 <fork>:
}

int
fork(void) {
    return sys_fork();
  800150:	b7e9                	j	80011a <sys_fork>

0000000000800152 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800152:	b7f1                	j	80011e <sys_wait>

0000000000800154 <yield>:
}

void
yield(void) {
    sys_yield();
  800154:	bfc9                	j	800126 <sys_yield>

0000000000800156 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800156:	bfd1                	j	80012a <sys_kill>

0000000000800158 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  800158:	bfe1                	j	800130 <sys_getpid>

000000000080015a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80015a:	1141                	addi	sp,sp,-16
  80015c:	e406                	sd	ra,8(sp)
    int ret = main();
  80015e:	482000ef          	jal	8005e0 <main>
    exit(ret);
  800162:	fd9ff0ef          	jal	80013a <exit>

0000000000800166 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800166:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80016c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800172:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800176:	f022                	sd	s0,32(sp)
  800178:	ec26                	sd	s1,24(sp)
  80017a:	e84a                	sd	s2,16(sp)
  80017c:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80017e:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800182:	84aa                	mv	s1,a0
  800184:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800186:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800188:	05067063          	bgeu	a2,a6,8001c8 <printnum+0x62>
  80018c:	e44e                	sd	s3,8(sp)
  80018e:	89be                	mv	s3,a5
        while (-- width > 0)
  800190:	4785                	li	a5,1
  800192:	00e7d763          	bge	a5,a4,8001a0 <printnum+0x3a>
            putch(padc, putdat);
  800196:	85ca                	mv	a1,s2
  800198:	854e                	mv	a0,s3
        while (-- width > 0)
  80019a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80019c:	9482                	jalr	s1
        while (-- width > 0)
  80019e:	fc65                	bnez	s0,800196 <printnum+0x30>
  8001a0:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  8001a2:	1a02                	slli	s4,s4,0x20
  8001a4:	020a5a13          	srli	s4,s4,0x20
  8001a8:	00000797          	auipc	a5,0x0
  8001ac:	53078793          	addi	a5,a5,1328 # 8006d8 <main+0xf8>
  8001b0:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001b2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	0007c503          	lbu	a0,0(a5)
}
  8001b8:	70a2                	ld	ra,40(sp)
  8001ba:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001bc:	85ca                	mv	a1,s2
  8001be:	87a6                	mv	a5,s1
}
  8001c0:	6942                	ld	s2,16(sp)
  8001c2:	64e2                	ld	s1,24(sp)
  8001c4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c8:	03065633          	divu	a2,a2,a6
  8001cc:	8722                	mv	a4,s0
  8001ce:	f99ff0ef          	jal	800166 <printnum>
  8001d2:	bfc1                	j	8001a2 <printnum+0x3c>

00000000008001d4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001d4:	7119                	addi	sp,sp,-128
  8001d6:	f4a6                	sd	s1,104(sp)
  8001d8:	f0ca                	sd	s2,96(sp)
  8001da:	ecce                	sd	s3,88(sp)
  8001dc:	e8d2                	sd	s4,80(sp)
  8001de:	e4d6                	sd	s5,72(sp)
  8001e0:	e0da                	sd	s6,64(sp)
  8001e2:	f862                	sd	s8,48(sp)
  8001e4:	fc86                	sd	ra,120(sp)
  8001e6:	f8a2                	sd	s0,112(sp)
  8001e8:	fc5e                	sd	s7,56(sp)
  8001ea:	f466                	sd	s9,40(sp)
  8001ec:	f06a                	sd	s10,32(sp)
  8001ee:	ec6e                	sd	s11,24(sp)
  8001f0:	892a                	mv	s2,a0
  8001f2:	84ae                	mv	s1,a1
  8001f4:	8c32                	mv	s8,a2
  8001f6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f8:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001fc:	05500b13          	li	s6,85
  800200:	00000a97          	auipc	s5,0x0
  800204:	68ca8a93          	addi	s5,s5,1676 # 80088c <main+0x2ac>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800208:	000c4503          	lbu	a0,0(s8)
  80020c:	001c0413          	addi	s0,s8,1
  800210:	01350a63          	beq	a0,s3,800224 <vprintfmt+0x50>
            if (ch == '\0') {
  800214:	cd0d                	beqz	a0,80024e <vprintfmt+0x7a>
            putch(ch, putdat);
  800216:	85a6                	mv	a1,s1
  800218:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021a:	00044503          	lbu	a0,0(s0)
  80021e:	0405                	addi	s0,s0,1
  800220:	ff351ae3          	bne	a0,s3,800214 <vprintfmt+0x40>
        width = precision = -1;
  800224:	5cfd                	li	s9,-1
  800226:	8d66                	mv	s10,s9
        char padc = ' ';
  800228:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80022c:	4b81                	li	s7,0
  80022e:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  800230:	00044683          	lbu	a3,0(s0)
  800234:	00140c13          	addi	s8,s0,1
  800238:	fdd6859b          	addiw	a1,a3,-35
  80023c:	0ff5f593          	zext.b	a1,a1
  800240:	02bb6663          	bltu	s6,a1,80026c <vprintfmt+0x98>
  800244:	058a                	slli	a1,a1,0x2
  800246:	95d6                	add	a1,a1,s5
  800248:	4198                	lw	a4,0(a1)
  80024a:	9756                	add	a4,a4,s5
  80024c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80024e:	70e6                	ld	ra,120(sp)
  800250:	7446                	ld	s0,112(sp)
  800252:	74a6                	ld	s1,104(sp)
  800254:	7906                	ld	s2,96(sp)
  800256:	69e6                	ld	s3,88(sp)
  800258:	6a46                	ld	s4,80(sp)
  80025a:	6aa6                	ld	s5,72(sp)
  80025c:	6b06                	ld	s6,64(sp)
  80025e:	7be2                	ld	s7,56(sp)
  800260:	7c42                	ld	s8,48(sp)
  800262:	7ca2                	ld	s9,40(sp)
  800264:	7d02                	ld	s10,32(sp)
  800266:	6de2                	ld	s11,24(sp)
  800268:	6109                	addi	sp,sp,128
  80026a:	8082                	ret
            putch('%', putdat);
  80026c:	85a6                	mv	a1,s1
  80026e:	02500513          	li	a0,37
  800272:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800274:	fff44783          	lbu	a5,-1(s0)
  800278:	02500713          	li	a4,37
  80027c:	8c22                	mv	s8,s0
  80027e:	f8e785e3          	beq	a5,a4,800208 <vprintfmt+0x34>
  800282:	ffec4783          	lbu	a5,-2(s8)
  800286:	1c7d                	addi	s8,s8,-1
  800288:	fee79de3          	bne	a5,a4,800282 <vprintfmt+0xae>
  80028c:	bfb5                	j	800208 <vprintfmt+0x34>
                ch = *fmt;
  80028e:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800292:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800294:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800298:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  80029c:	8462                	mv	s0,s8
                ch = *fmt;
  80029e:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  8002a0:	02e56463          	bltu	a0,a4,8002c8 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  8002a4:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002a8:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002ac:	0197073b          	addw	a4,a4,s9
  8002b0:	0017171b          	slliw	a4,a4,0x1
  8002b4:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  8002b6:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002ba:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002bc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002c0:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  8002c4:	feb570e3          	bgeu	a0,a1,8002a4 <vprintfmt+0xd0>
            if (width < 0)
  8002c8:	f60d54e3          	bgez	s10,800230 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002cc:	8d66                	mv	s10,s9
  8002ce:	5cfd                	li	s9,-1
  8002d0:	b785                	j	800230 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002d2:	8db6                	mv	s11,a3
  8002d4:	8462                	mv	s0,s8
  8002d6:	bfa9                	j	800230 <vprintfmt+0x5c>
  8002d8:	8462                	mv	s0,s8
            altflag = 1;
  8002da:	4b85                	li	s7,1
            goto reswitch;
  8002dc:	bf91                	j	800230 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002de:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002e0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002e4:	00c7c463          	blt	a5,a2,8002ec <vprintfmt+0x118>
    else if (lflag) {
  8002e8:	18060763          	beqz	a2,800476 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  8002ec:	000a3603          	ld	a2,0(s4)
  8002f0:	46c1                	li	a3,16
  8002f2:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002f4:	000d879b          	sext.w	a5,s11
  8002f8:	876a                	mv	a4,s10
  8002fa:	85a6                	mv	a1,s1
  8002fc:	854a                	mv	a0,s2
  8002fe:	e69ff0ef          	jal	800166 <printnum>
            break;
  800302:	b719                	j	800208 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800304:	000a2503          	lw	a0,0(s4)
  800308:	85a6                	mv	a1,s1
  80030a:	0a21                	addi	s4,s4,8
  80030c:	9902                	jalr	s2
            break;
  80030e:	bded                	j	800208 <vprintfmt+0x34>
    if (lflag >= 2) {
  800310:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800312:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800316:	00c7c463          	blt	a5,a2,80031e <vprintfmt+0x14a>
    else if (lflag) {
  80031a:	14060963          	beqz	a2,80046c <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  80031e:	000a3603          	ld	a2,0(s4)
  800322:	46a9                	li	a3,10
  800324:	8a3a                	mv	s4,a4
  800326:	b7f9                	j	8002f4 <vprintfmt+0x120>
            putch('0', putdat);
  800328:	85a6                	mv	a1,s1
  80032a:	03000513          	li	a0,48
  80032e:	9902                	jalr	s2
            putch('x', putdat);
  800330:	85a6                	mv	a1,s1
  800332:	07800513          	li	a0,120
  800336:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800338:	000a3603          	ld	a2,0(s4)
            goto number;
  80033c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80033e:	0a21                	addi	s4,s4,8
            goto number;
  800340:	bf55                	j	8002f4 <vprintfmt+0x120>
            putch(ch, putdat);
  800342:	85a6                	mv	a1,s1
  800344:	02500513          	li	a0,37
  800348:	9902                	jalr	s2
            break;
  80034a:	bd7d                	j	800208 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80034c:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800350:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800352:	0a21                	addi	s4,s4,8
            goto process_precision;
  800354:	bf95                	j	8002c8 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800356:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800358:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80035c:	00c7c463          	blt	a5,a2,800364 <vprintfmt+0x190>
    else if (lflag) {
  800360:	10060163          	beqz	a2,800462 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  800364:	000a3603          	ld	a2,0(s4)
  800368:	46a1                	li	a3,8
  80036a:	8a3a                	mv	s4,a4
  80036c:	b761                	j	8002f4 <vprintfmt+0x120>
            if (width < 0)
  80036e:	87ea                	mv	a5,s10
  800370:	000d5363          	bgez	s10,800376 <vprintfmt+0x1a2>
  800374:	4781                	li	a5,0
  800376:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80037a:	8462                	mv	s0,s8
            goto reswitch;
  80037c:	bd55                	j	800230 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80037e:	000a3703          	ld	a4,0(s4)
  800382:	12070b63          	beqz	a4,8004b8 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  800386:	0da05563          	blez	s10,800450 <vprintfmt+0x27c>
  80038a:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038e:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  800392:	14fd9a63          	bne	s11,a5,8004e6 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	00074783          	lbu	a5,0(a4)
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	c785                	beqz	a5,8003c6 <vprintfmt+0x1f2>
  8003a0:	5dfd                	li	s11,-1
  8003a2:	000cc563          	bltz	s9,8003ac <vprintfmt+0x1d8>
  8003a6:	3cfd                	addiw	s9,s9,-1
  8003a8:	01bc8d63          	beq	s9,s11,8003c2 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ac:	0c0b9a63          	bnez	s7,800480 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  8003b0:	85a6                	mv	a1,s1
  8003b2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b4:	00044783          	lbu	a5,0(s0)
  8003b8:	0405                	addi	s0,s0,1
  8003ba:	3d7d                	addiw	s10,s10,-1
  8003bc:	0007851b          	sext.w	a0,a5
  8003c0:	f3ed                	bnez	a5,8003a2 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  8003c2:	01a05963          	blez	s10,8003d4 <vprintfmt+0x200>
                putch(' ', putdat);
  8003c6:	85a6                	mv	a1,s1
  8003c8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003cc:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ce:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003d0:	fe0d1be3          	bnez	s10,8003c6 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003d4:	0a21                	addi	s4,s4,8
  8003d6:	bd0d                	j	800208 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003d8:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003da:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003de:	00c7c363          	blt	a5,a2,8003e4 <vprintfmt+0x210>
    else if (lflag) {
  8003e2:	c625                	beqz	a2,80044a <vprintfmt+0x276>
        return va_arg(*ap, long);
  8003e4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003e8:	0a044f63          	bltz	s0,8004a6 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  8003ec:	8622                	mv	a2,s0
  8003ee:	8a5e                	mv	s4,s7
  8003f0:	46a9                	li	a3,10
  8003f2:	b709                	j	8002f4 <vprintfmt+0x120>
            if (err < 0) {
  8003f4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f8:	4661                	li	a2,24
            if (err < 0) {
  8003fa:	41f7d71b          	sraiw	a4,a5,0x1f
  8003fe:	8fb9                	xor	a5,a5,a4
  800400:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800404:	02d64663          	blt	a2,a3,800430 <vprintfmt+0x25c>
  800408:	00000797          	auipc	a5,0x0
  80040c:	5e078793          	addi	a5,a5,1504 # 8009e8 <error_string>
  800410:	00369713          	slli	a4,a3,0x3
  800414:	97ba                	add	a5,a5,a4
  800416:	639c                	ld	a5,0(a5)
  800418:	cf81                	beqz	a5,800430 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  80041a:	86be                	mv	a3,a5
  80041c:	00000617          	auipc	a2,0x0
  800420:	2ec60613          	addi	a2,a2,748 # 800708 <main+0x128>
  800424:	85a6                	mv	a1,s1
  800426:	854a                	mv	a0,s2
  800428:	0f4000ef          	jal	80051c <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  80042c:	0a21                	addi	s4,s4,8
  80042e:	bbe9                	j	800208 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800430:	00000617          	auipc	a2,0x0
  800434:	2c860613          	addi	a2,a2,712 # 8006f8 <main+0x118>
  800438:	85a6                	mv	a1,s1
  80043a:	854a                	mv	a0,s2
  80043c:	0e0000ef          	jal	80051c <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800440:	0a21                	addi	s4,s4,8
  800442:	b3d9                	j	800208 <vprintfmt+0x34>
            lflag ++;
  800444:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800446:	8462                	mv	s0,s8
            goto reswitch;
  800448:	b3e5                	j	800230 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80044a:	000a2403          	lw	s0,0(s4)
  80044e:	bf69                	j	8003e8 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800450:	00074783          	lbu	a5,0(a4)
  800454:	0007851b          	sext.w	a0,a5
  800458:	dfb5                	beqz	a5,8003d4 <vprintfmt+0x200>
  80045a:	00170413          	addi	s0,a4,1
  80045e:	5dfd                	li	s11,-1
  800460:	b789                	j	8003a2 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  800462:	000a6603          	lwu	a2,0(s4)
  800466:	46a1                	li	a3,8
  800468:	8a3a                	mv	s4,a4
  80046a:	b569                	j	8002f4 <vprintfmt+0x120>
  80046c:	000a6603          	lwu	a2,0(s4)
  800470:	46a9                	li	a3,10
  800472:	8a3a                	mv	s4,a4
  800474:	b541                	j	8002f4 <vprintfmt+0x120>
  800476:	000a6603          	lwu	a2,0(s4)
  80047a:	46c1                	li	a3,16
  80047c:	8a3a                	mv	s4,a4
  80047e:	bd9d                	j	8002f4 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800480:	3781                	addiw	a5,a5,-32
  800482:	05e00713          	li	a4,94
  800486:	f2f775e3          	bgeu	a4,a5,8003b0 <vprintfmt+0x1dc>
                    putch('?', putdat);
  80048a:	03f00513          	li	a0,63
  80048e:	85a6                	mv	a1,s1
  800490:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800492:	00044783          	lbu	a5,0(s0)
  800496:	0405                	addi	s0,s0,1
  800498:	3d7d                	addiw	s10,s10,-1
  80049a:	0007851b          	sext.w	a0,a5
  80049e:	d395                	beqz	a5,8003c2 <vprintfmt+0x1ee>
  8004a0:	f00cd3e3          	bgez	s9,8003a6 <vprintfmt+0x1d2>
  8004a4:	bff1                	j	800480 <vprintfmt+0x2ac>
                putch('-', putdat);
  8004a6:	85a6                	mv	a1,s1
  8004a8:	02d00513          	li	a0,45
  8004ac:	9902                	jalr	s2
                num = -(long long)num;
  8004ae:	40800633          	neg	a2,s0
  8004b2:	8a5e                	mv	s4,s7
  8004b4:	46a9                	li	a3,10
  8004b6:	bd3d                	j	8002f4 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004b8:	01a05663          	blez	s10,8004c4 <vprintfmt+0x2f0>
  8004bc:	02d00793          	li	a5,45
  8004c0:	00fd9b63          	bne	s11,a5,8004d6 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	02800793          	li	a5,40
  8004c8:	853e                	mv	a0,a5
  8004ca:	00000417          	auipc	s0,0x0
  8004ce:	22740413          	addi	s0,s0,551 # 8006f1 <main+0x111>
  8004d2:	5dfd                	li	s11,-1
  8004d4:	b5f9                	j	8003a2 <vprintfmt+0x1ce>
  8004d6:	00000417          	auipc	s0,0x0
  8004da:	21b40413          	addi	s0,s0,539 # 8006f1 <main+0x111>
                p = "(null)";
  8004de:	00000717          	auipc	a4,0x0
  8004e2:	21270713          	addi	a4,a4,530 # 8006f0 <main+0x110>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e6:	853a                	mv	a0,a4
  8004e8:	85e6                	mv	a1,s9
  8004ea:	e43a                	sd	a4,8(sp)
  8004ec:	050000ef          	jal	80053c <strnlen>
  8004f0:	40ad0d3b          	subw	s10,s10,a0
  8004f4:	6722                	ld	a4,8(sp)
  8004f6:	01a05b63          	blez	s10,80050c <vprintfmt+0x338>
                    putch(padc, putdat);
  8004fa:	2d81                	sext.w	s11,s11
  8004fc:	85a6                	mv	a1,s1
  8004fe:	856e                	mv	a0,s11
  800500:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800502:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800504:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800506:	6722                	ld	a4,8(sp)
  800508:	fe0d1ae3          	bnez	s10,8004fc <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050c:	00074783          	lbu	a5,0(a4)
  800510:	0007851b          	sext.w	a0,a5
  800514:	ec0780e3          	beqz	a5,8003d4 <vprintfmt+0x200>
  800518:	5dfd                	li	s11,-1
  80051a:	b561                	j	8003a2 <vprintfmt+0x1ce>

000000000080051c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80051e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800522:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800524:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800526:	ec06                	sd	ra,24(sp)
  800528:	f83a                	sd	a4,48(sp)
  80052a:	fc3e                	sd	a5,56(sp)
  80052c:	e0c2                	sd	a6,64(sp)
  80052e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800530:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800532:	ca3ff0ef          	jal	8001d4 <vprintfmt>
}
  800536:	60e2                	ld	ra,24(sp)
  800538:	6161                	addi	sp,sp,80
  80053a:	8082                	ret

000000000080053c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80053c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80053e:	e589                	bnez	a1,800548 <strnlen+0xc>
  800540:	a811                	j	800554 <strnlen+0x18>
        cnt ++;
  800542:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800544:	00f58863          	beq	a1,a5,800554 <strnlen+0x18>
  800548:	00f50733          	add	a4,a0,a5
  80054c:	00074703          	lbu	a4,0(a4)
  800550:	fb6d                	bnez	a4,800542 <strnlen+0x6>
  800552:	85be                	mv	a1,a5
    }
    return cnt;
}
  800554:	852e                	mv	a0,a1
  800556:	8082                	ret

0000000000800558 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800558:	1141                	addi	sp,sp,-16
  80055a:	e406                	sd	ra,8(sp)
    yield();
  80055c:	bf9ff0ef          	jal	800154 <yield>
    yield();
  800560:	bf5ff0ef          	jal	800154 <yield>
    yield();
  800564:	bf1ff0ef          	jal	800154 <yield>
    yield();
  800568:	bedff0ef          	jal	800154 <yield>
    yield();
  80056c:	be9ff0ef          	jal	800154 <yield>
    yield();
}
  800570:	60a2                	ld	ra,8(sp)
  800572:	0141                	addi	sp,sp,16
    yield();
  800574:	b6c5                	j	800154 <yield>

0000000000800576 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  800576:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  800578:	00000517          	auipc	a0,0x0
  80057c:	25850513          	addi	a0,a0,600 # 8007d0 <main+0x1f0>
loop(void) {
  800580:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800582:	b23ff0ef          	jal	8000a4 <cprintf>
    while (1);
  800586:	a001                	j	800586 <loop+0x10>

0000000000800588 <work>:
}

void
work(void) {
  800588:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  80058a:	00000517          	auipc	a0,0x0
  80058e:	25650513          	addi	a0,a0,598 # 8007e0 <main+0x200>
work(void) {
  800592:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  800594:	b11ff0ef          	jal	8000a4 <cprintf>
    do_yield();
  800598:	fc1ff0ef          	jal	800558 <do_yield>
    if (kill(parent) == 0) {
  80059c:	00001517          	auipc	a0,0x1
  8005a0:	a6c52503          	lw	a0,-1428(a0) # 801008 <parent>
  8005a4:	bb3ff0ef          	jal	800156 <kill>
  8005a8:	e105                	bnez	a0,8005c8 <work+0x40>
        cprintf("kill parent ok.\n");
  8005aa:	00000517          	auipc	a0,0x0
  8005ae:	24650513          	addi	a0,a0,582 # 8007f0 <main+0x210>
  8005b2:	af3ff0ef          	jal	8000a4 <cprintf>
        do_yield();
  8005b6:	fa3ff0ef          	jal	800558 <do_yield>
        if (kill(pid1) == 0) {
  8005ba:	00001517          	auipc	a0,0x1
  8005be:	a4a52503          	lw	a0,-1462(a0) # 801004 <pid1>
  8005c2:	b95ff0ef          	jal	800156 <kill>
  8005c6:	c501                	beqz	a0,8005ce <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005c8:	557d                	li	a0,-1
  8005ca:	b71ff0ef          	jal	80013a <exit>
            cprintf("kill child1 ok.\n");
  8005ce:	00000517          	auipc	a0,0x0
  8005d2:	23a50513          	addi	a0,a0,570 # 800808 <main+0x228>
  8005d6:	acfff0ef          	jal	8000a4 <cprintf>
            exit(0);
  8005da:	4501                	li	a0,0
  8005dc:	b5fff0ef          	jal	80013a <exit>

00000000008005e0 <main>:
}

int
main(void) {
  8005e0:	1141                	addi	sp,sp,-16
  8005e2:	e406                	sd	ra,8(sp)
    parent = getpid();
  8005e4:	b75ff0ef          	jal	800158 <getpid>
  8005e8:	00001797          	auipc	a5,0x1
  8005ec:	a2a7a023          	sw	a0,-1504(a5) # 801008 <parent>
    if ((pid1 = fork()) == 0) {
  8005f0:	b61ff0ef          	jal	800150 <fork>
  8005f4:	00001797          	auipc	a5,0x1
  8005f8:	a0a7a823          	sw	a0,-1520(a5) # 801004 <pid1>
  8005fc:	c92d                	beqz	a0,80066e <main+0x8e>
        loop();
    }

    assert(pid1 > 0);
  8005fe:	04a05863          	blez	a0,80064e <main+0x6e>

    if ((pid2 = fork()) == 0) {
  800602:	b4fff0ef          	jal	800150 <fork>
  800606:	00001797          	auipc	a5,0x1
  80060a:	9ea7ad23          	sw	a0,-1542(a5) # 801000 <pid2>
  80060e:	c541                	beqz	a0,800696 <main+0xb6>
        work();
    }
    if (pid2 > 0) {
  800610:	06a05163          	blez	a0,800672 <main+0x92>
        cprintf("wait child 1.\n");
  800614:	00000517          	auipc	a0,0x0
  800618:	24450513          	addi	a0,a0,580 # 800858 <main+0x278>
  80061c:	a89ff0ef          	jal	8000a4 <cprintf>
        waitpid(pid1, NULL);
  800620:	00001517          	auipc	a0,0x1
  800624:	9e452503          	lw	a0,-1564(a0) # 801004 <pid1>
  800628:	4581                	li	a1,0
  80062a:	b29ff0ef          	jal	800152 <waitpid>
        panic("waitpid %d returns\n", pid1);
  80062e:	00001697          	auipc	a3,0x1
  800632:	9d66a683          	lw	a3,-1578(a3) # 801004 <pid1>
  800636:	00000617          	auipc	a2,0x0
  80063a:	23260613          	addi	a2,a2,562 # 800868 <main+0x288>
  80063e:	03400593          	li	a1,52
  800642:	00000517          	auipc	a0,0x0
  800646:	20650513          	addi	a0,a0,518 # 800848 <main+0x268>
  80064a:	9ddff0ef          	jal	800026 <__panic>
    assert(pid1 > 0);
  80064e:	00000697          	auipc	a3,0x0
  800652:	1d268693          	addi	a3,a3,466 # 800820 <main+0x240>
  800656:	00000617          	auipc	a2,0x0
  80065a:	1da60613          	addi	a2,a2,474 # 800830 <main+0x250>
  80065e:	02c00593          	li	a1,44
  800662:	00000517          	auipc	a0,0x0
  800666:	1e650513          	addi	a0,a0,486 # 800848 <main+0x268>
  80066a:	9bdff0ef          	jal	800026 <__panic>
        loop();
  80066e:	f09ff0ef          	jal	800576 <loop>
    }
    else {
        kill(pid1);
  800672:	00001517          	auipc	a0,0x1
  800676:	99252503          	lw	a0,-1646(a0) # 801004 <pid1>
  80067a:	addff0ef          	jal	800156 <kill>
    }
    panic("FAIL: T.T\n");
  80067e:	00000617          	auipc	a2,0x0
  800682:	20260613          	addi	a2,a2,514 # 800880 <main+0x2a0>
  800686:	03900593          	li	a1,57
  80068a:	00000517          	auipc	a0,0x0
  80068e:	1be50513          	addi	a0,a0,446 # 800848 <main+0x268>
  800692:	995ff0ef          	jal	800026 <__panic>
        work();
  800696:	ef3ff0ef          	jal	800588 <work>
