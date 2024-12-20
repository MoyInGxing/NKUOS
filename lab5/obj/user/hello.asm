
obj/__user_hello.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b8000ef          	jal	8000d8 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);
  80002e:	08c000ef          	jal	8000ba <sys_putc>
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	f42e                	sd	a1,40(sp)
  800048:	f832                	sd	a2,48(sp)
  80004a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004c:	862a                	mv	a2,a0
  80004e:	004c                	addi	a1,sp,4
  800050:	00000517          	auipc	a0,0x0
  800054:	fd650513          	addi	a0,a0,-42 # 800026 <cputch>
  800058:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80005a:	ec06                	sd	ra,24(sp)
  80005c:	e0ba                	sd	a4,64(sp)
  80005e:	e4be                	sd	a5,72(sp)
  800060:	e8c2                	sd	a6,80(sp)
  800062:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800064:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800066:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800068:	0ea000ef          	jal	800152 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006c:	60e2                	ld	ra,24(sp)
  80006e:	4512                	lw	a0,4(sp)
  800070:	6125                	addi	sp,sp,96
  800072:	8082                	ret

0000000000800074 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800074:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800076:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  80007a:	e42a                	sd	a0,8(sp)
  80007c:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  80007e:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  800080:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  800082:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  800084:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  800086:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  800088:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  80008a:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  80008c:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  80008e:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  800090:	e142                	sd	a6,128(sp)
  800092:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800094:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);

    asm volatile (
  800096:	6522                	ld	a0,8(sp)
  800098:	75a2                	ld	a1,40(sp)
  80009a:	7642                	ld	a2,48(sp)
  80009c:	76e2                	ld	a3,56(sp)
  80009e:	6706                	ld	a4,64(sp)
  8000a0:	67a6                	ld	a5,72(sp)
  8000a2:	00000073          	ecall
  8000a6:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000aa:	4572                	lw	a0,28(sp)
  8000ac:	6149                	addi	sp,sp,144
  8000ae:	8082                	ret

00000000008000b0 <sys_exit>:

int
sys_exit(int64_t error_code) {
  8000b0:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  8000b2:	4505                	li	a0,1
  8000b4:	b7c1                	j	800074 <syscall>

00000000008000b6 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b6:	4549                	li	a0,18
  8000b8:	bf75                	j	800074 <syscall>

00000000008000ba <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000ba:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000bc:	4579                	li	a0,30
  8000be:	bf5d                	j	800074 <syscall>

00000000008000c0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c4:	fedff0ef          	jal	8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c8:	00000517          	auipc	a0,0x0
  8000cc:	44850513          	addi	a0,a0,1096 # 800510 <main+0x3a>
  8000d0:	f71ff0ef          	jal	800040 <cprintf>
    while (1);
  8000d4:	a001                	j	8000d4 <exit+0x14>

00000000008000d6 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d6:	b7c5                	j	8000b6 <sys_getpid>

00000000008000d8 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d8:	1141                	addi	sp,sp,-16
  8000da:	e406                	sd	ra,8(sp)
    int ret = main();
  8000dc:	3fa000ef          	jal	8004d6 <main>
    exit(ret);
  8000e0:	fe1ff0ef          	jal	8000c0 <exit>

00000000008000e4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000ea:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	f022                	sd	s0,32(sp)
  8000f6:	ec26                	sd	s1,24(sp)
  8000f8:	e84a                	sd	s2,16(sp)
  8000fa:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000fc:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800100:	84aa                	mv	s1,a0
  800102:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800104:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800106:	05067063          	bgeu	a2,a6,800146 <printnum+0x62>
  80010a:	e44e                	sd	s3,8(sp)
  80010c:	89be                	mv	s3,a5
        while (-- width > 0)
  80010e:	4785                	li	a5,1
  800110:	00e7d763          	bge	a5,a4,80011e <printnum+0x3a>
            putch(padc, putdat);
  800114:	85ca                	mv	a1,s2
  800116:	854e                	mv	a0,s3
        while (-- width > 0)
  800118:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80011a:	9482                	jalr	s1
        while (-- width > 0)
  80011c:	fc65                	bnez	s0,800114 <printnum+0x30>
  80011e:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800120:	1a02                	slli	s4,s4,0x20
  800122:	020a5a13          	srli	s4,s4,0x20
  800126:	00000797          	auipc	a5,0x0
  80012a:	40278793          	addi	a5,a5,1026 # 800528 <main+0x52>
  80012e:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800130:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800132:	0007c503          	lbu	a0,0(a5)
}
  800136:	70a2                	ld	ra,40(sp)
  800138:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013a:	85ca                	mv	a1,s2
  80013c:	87a6                	mv	a5,s1
}
  80013e:	6942                	ld	s2,16(sp)
  800140:	64e2                	ld	s1,24(sp)
  800142:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800144:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800146:	03065633          	divu	a2,a2,a6
  80014a:	8722                	mv	a4,s0
  80014c:	f99ff0ef          	jal	8000e4 <printnum>
  800150:	bfc1                	j	800120 <printnum+0x3c>

0000000000800152 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800152:	7119                	addi	sp,sp,-128
  800154:	f4a6                	sd	s1,104(sp)
  800156:	f0ca                	sd	s2,96(sp)
  800158:	ecce                	sd	s3,88(sp)
  80015a:	e8d2                	sd	s4,80(sp)
  80015c:	e4d6                	sd	s5,72(sp)
  80015e:	e0da                	sd	s6,64(sp)
  800160:	f862                	sd	s8,48(sp)
  800162:	fc86                	sd	ra,120(sp)
  800164:	f8a2                	sd	s0,112(sp)
  800166:	fc5e                	sd	s7,56(sp)
  800168:	f466                	sd	s9,40(sp)
  80016a:	f06a                	sd	s10,32(sp)
  80016c:	ec6e                	sd	s11,24(sp)
  80016e:	892a                	mv	s2,a0
  800170:	84ae                	mv	s1,a1
  800172:	8c32                	mv	s8,a2
  800174:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800176:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80017a:	05500b13          	li	s6,85
  80017e:	00000a97          	auipc	s5,0x0
  800182:	4e2a8a93          	addi	s5,s5,1250 # 800660 <main+0x18a>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800186:	000c4503          	lbu	a0,0(s8)
  80018a:	001c0413          	addi	s0,s8,1
  80018e:	01350a63          	beq	a0,s3,8001a2 <vprintfmt+0x50>
            if (ch == '\0') {
  800192:	cd0d                	beqz	a0,8001cc <vprintfmt+0x7a>
            putch(ch, putdat);
  800194:	85a6                	mv	a1,s1
  800196:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800198:	00044503          	lbu	a0,0(s0)
  80019c:	0405                	addi	s0,s0,1
  80019e:	ff351ae3          	bne	a0,s3,800192 <vprintfmt+0x40>
        width = precision = -1;
  8001a2:	5cfd                	li	s9,-1
  8001a4:	8d66                	mv	s10,s9
        char padc = ' ';
  8001a6:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001aa:	4b81                	li	s7,0
  8001ac:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001ae:	00044683          	lbu	a3,0(s0)
  8001b2:	00140c13          	addi	s8,s0,1
  8001b6:	fdd6859b          	addiw	a1,a3,-35
  8001ba:	0ff5f593          	zext.b	a1,a1
  8001be:	02bb6663          	bltu	s6,a1,8001ea <vprintfmt+0x98>
  8001c2:	058a                	slli	a1,a1,0x2
  8001c4:	95d6                	add	a1,a1,s5
  8001c6:	4198                	lw	a4,0(a1)
  8001c8:	9756                	add	a4,a4,s5
  8001ca:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001cc:	70e6                	ld	ra,120(sp)
  8001ce:	7446                	ld	s0,112(sp)
  8001d0:	74a6                	ld	s1,104(sp)
  8001d2:	7906                	ld	s2,96(sp)
  8001d4:	69e6                	ld	s3,88(sp)
  8001d6:	6a46                	ld	s4,80(sp)
  8001d8:	6aa6                	ld	s5,72(sp)
  8001da:	6b06                	ld	s6,64(sp)
  8001dc:	7be2                	ld	s7,56(sp)
  8001de:	7c42                	ld	s8,48(sp)
  8001e0:	7ca2                	ld	s9,40(sp)
  8001e2:	7d02                	ld	s10,32(sp)
  8001e4:	6de2                	ld	s11,24(sp)
  8001e6:	6109                	addi	sp,sp,128
  8001e8:	8082                	ret
            putch('%', putdat);
  8001ea:	85a6                	mv	a1,s1
  8001ec:	02500513          	li	a0,37
  8001f0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001f2:	fff44783          	lbu	a5,-1(s0)
  8001f6:	02500713          	li	a4,37
  8001fa:	8c22                	mv	s8,s0
  8001fc:	f8e785e3          	beq	a5,a4,800186 <vprintfmt+0x34>
  800200:	ffec4783          	lbu	a5,-2(s8)
  800204:	1c7d                	addi	s8,s8,-1
  800206:	fee79de3          	bne	a5,a4,800200 <vprintfmt+0xae>
  80020a:	bfb5                	j	800186 <vprintfmt+0x34>
                ch = *fmt;
  80020c:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800210:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800212:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800216:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	8462                	mv	s0,s8
                ch = *fmt;
  80021c:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  80021e:	02e56463          	bltu	a0,a4,800246 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  800222:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800226:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80022a:	0197073b          	addw	a4,a4,s9
  80022e:	0017171b          	slliw	a4,a4,0x1
  800232:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  800234:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800238:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80023a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80023e:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  800242:	feb570e3          	bgeu	a0,a1,800222 <vprintfmt+0xd0>
            if (width < 0)
  800246:	f60d54e3          	bgez	s10,8001ae <vprintfmt+0x5c>
                width = precision, precision = -1;
  80024a:	8d66                	mv	s10,s9
  80024c:	5cfd                	li	s9,-1
  80024e:	b785                	j	8001ae <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800250:	8db6                	mv	s11,a3
  800252:	8462                	mv	s0,s8
  800254:	bfa9                	j	8001ae <vprintfmt+0x5c>
  800256:	8462                	mv	s0,s8
            altflag = 1;
  800258:	4b85                	li	s7,1
            goto reswitch;
  80025a:	bf91                	j	8001ae <vprintfmt+0x5c>
    if (lflag >= 2) {
  80025c:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80025e:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800262:	00c7c463          	blt	a5,a2,80026a <vprintfmt+0x118>
    else if (lflag) {
  800266:	18060763          	beqz	a2,8003f4 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  80026a:	000a3603          	ld	a2,0(s4)
  80026e:	46c1                	li	a3,16
  800270:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  800272:	000d879b          	sext.w	a5,s11
  800276:	876a                	mv	a4,s10
  800278:	85a6                	mv	a1,s1
  80027a:	854a                	mv	a0,s2
  80027c:	e69ff0ef          	jal	8000e4 <printnum>
            break;
  800280:	b719                	j	800186 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800282:	000a2503          	lw	a0,0(s4)
  800286:	85a6                	mv	a1,s1
  800288:	0a21                	addi	s4,s4,8
  80028a:	9902                	jalr	s2
            break;
  80028c:	bded                	j	800186 <vprintfmt+0x34>
    if (lflag >= 2) {
  80028e:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800290:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800294:	00c7c463          	blt	a5,a2,80029c <vprintfmt+0x14a>
    else if (lflag) {
  800298:	14060963          	beqz	a2,8003ea <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  80029c:	000a3603          	ld	a2,0(s4)
  8002a0:	46a9                	li	a3,10
  8002a2:	8a3a                	mv	s4,a4
  8002a4:	b7f9                	j	800272 <vprintfmt+0x120>
            putch('0', putdat);
  8002a6:	85a6                	mv	a1,s1
  8002a8:	03000513          	li	a0,48
  8002ac:	9902                	jalr	s2
            putch('x', putdat);
  8002ae:	85a6                	mv	a1,s1
  8002b0:	07800513          	li	a0,120
  8002b4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b6:	000a3603          	ld	a2,0(s4)
            goto number;
  8002ba:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002bc:	0a21                	addi	s4,s4,8
            goto number;
  8002be:	bf55                	j	800272 <vprintfmt+0x120>
            putch(ch, putdat);
  8002c0:	85a6                	mv	a1,s1
  8002c2:	02500513          	li	a0,37
  8002c6:	9902                	jalr	s2
            break;
  8002c8:	bd7d                	j	800186 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002ca:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ce:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002d0:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002d2:	bf95                	j	800246 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002d4:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002d6:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002da:	00c7c463          	blt	a5,a2,8002e2 <vprintfmt+0x190>
    else if (lflag) {
  8002de:	10060163          	beqz	a2,8003e0 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  8002e2:	000a3603          	ld	a2,0(s4)
  8002e6:	46a1                	li	a3,8
  8002e8:	8a3a                	mv	s4,a4
  8002ea:	b761                	j	800272 <vprintfmt+0x120>
            if (width < 0)
  8002ec:	87ea                	mv	a5,s10
  8002ee:	000d5363          	bgez	s10,8002f4 <vprintfmt+0x1a2>
  8002f2:	4781                	li	a5,0
  8002f4:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  8002f8:	8462                	mv	s0,s8
            goto reswitch;
  8002fa:	bd55                	j	8001ae <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002fc:	000a3703          	ld	a4,0(s4)
  800300:	12070b63          	beqz	a4,800436 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  800304:	0da05563          	blez	s10,8003ce <vprintfmt+0x27c>
  800308:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80030c:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  800310:	14fd9a63          	bne	s11,a5,800464 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800314:	00074783          	lbu	a5,0(a4)
  800318:	0007851b          	sext.w	a0,a5
  80031c:	c785                	beqz	a5,800344 <vprintfmt+0x1f2>
  80031e:	5dfd                	li	s11,-1
  800320:	000cc563          	bltz	s9,80032a <vprintfmt+0x1d8>
  800324:	3cfd                	addiw	s9,s9,-1
  800326:	01bc8d63          	beq	s9,s11,800340 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  80032a:	0c0b9a63          	bnez	s7,8003fe <vprintfmt+0x2ac>
                    putch(ch, putdat);
  80032e:	85a6                	mv	a1,s1
  800330:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800332:	00044783          	lbu	a5,0(s0)
  800336:	0405                	addi	s0,s0,1
  800338:	3d7d                	addiw	s10,s10,-1
  80033a:	0007851b          	sext.w	a0,a5
  80033e:	f3ed                	bnez	a5,800320 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  800340:	01a05963          	blez	s10,800352 <vprintfmt+0x200>
                putch(' ', putdat);
  800344:	85a6                	mv	a1,s1
  800346:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80034a:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80034c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80034e:	fe0d1be3          	bnez	s10,800344 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  800352:	0a21                	addi	s4,s4,8
  800354:	bd0d                	j	800186 <vprintfmt+0x34>
    if (lflag >= 2) {
  800356:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800358:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80035c:	00c7c363          	blt	a5,a2,800362 <vprintfmt+0x210>
    else if (lflag) {
  800360:	c625                	beqz	a2,8003c8 <vprintfmt+0x276>
        return va_arg(*ap, long);
  800362:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800366:	0a044f63          	bltz	s0,800424 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  80036a:	8622                	mv	a2,s0
  80036c:	8a5e                	mv	s4,s7
  80036e:	46a9                	li	a3,10
  800370:	b709                	j	800272 <vprintfmt+0x120>
            if (err < 0) {
  800372:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800376:	4661                	li	a2,24
            if (err < 0) {
  800378:	41f7d71b          	sraiw	a4,a5,0x1f
  80037c:	8fb9                	xor	a5,a5,a4
  80037e:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800382:	02d64663          	blt	a2,a3,8003ae <vprintfmt+0x25c>
  800386:	00000797          	auipc	a5,0x0
  80038a:	43278793          	addi	a5,a5,1074 # 8007b8 <error_string>
  80038e:	00369713          	slli	a4,a3,0x3
  800392:	97ba                	add	a5,a5,a4
  800394:	639c                	ld	a5,0(a5)
  800396:	cf81                	beqz	a5,8003ae <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  800398:	86be                	mv	a3,a5
  80039a:	00000617          	auipc	a2,0x0
  80039e:	1c660613          	addi	a2,a2,454 # 800560 <main+0x8a>
  8003a2:	85a6                	mv	a1,s1
  8003a4:	854a                	mv	a0,s2
  8003a6:	0f4000ef          	jal	80049a <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003aa:	0a21                	addi	s4,s4,8
  8003ac:	bbe9                	j	800186 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003ae:	00000617          	auipc	a2,0x0
  8003b2:	1a260613          	addi	a2,a2,418 # 800550 <main+0x7a>
  8003b6:	85a6                	mv	a1,s1
  8003b8:	854a                	mv	a0,s2
  8003ba:	0e0000ef          	jal	80049a <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003be:	0a21                	addi	s4,s4,8
  8003c0:	b3d9                	j	800186 <vprintfmt+0x34>
            lflag ++;
  8003c2:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003c4:	8462                	mv	s0,s8
            goto reswitch;
  8003c6:	b3e5                	j	8001ae <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003c8:	000a2403          	lw	s0,0(s4)
  8003cc:	bf69                	j	800366 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ce:	00074783          	lbu	a5,0(a4)
  8003d2:	0007851b          	sext.w	a0,a5
  8003d6:	dfb5                	beqz	a5,800352 <vprintfmt+0x200>
  8003d8:	00170413          	addi	s0,a4,1
  8003dc:	5dfd                	li	s11,-1
  8003de:	b789                	j	800320 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  8003e0:	000a6603          	lwu	a2,0(s4)
  8003e4:	46a1                	li	a3,8
  8003e6:	8a3a                	mv	s4,a4
  8003e8:	b569                	j	800272 <vprintfmt+0x120>
  8003ea:	000a6603          	lwu	a2,0(s4)
  8003ee:	46a9                	li	a3,10
  8003f0:	8a3a                	mv	s4,a4
  8003f2:	b541                	j	800272 <vprintfmt+0x120>
  8003f4:	000a6603          	lwu	a2,0(s4)
  8003f8:	46c1                	li	a3,16
  8003fa:	8a3a                	mv	s4,a4
  8003fc:	bd9d                	j	800272 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003fe:	3781                	addiw	a5,a5,-32
  800400:	05e00713          	li	a4,94
  800404:	f2f775e3          	bgeu	a4,a5,80032e <vprintfmt+0x1dc>
                    putch('?', putdat);
  800408:	03f00513          	li	a0,63
  80040c:	85a6                	mv	a1,s1
  80040e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800410:	00044783          	lbu	a5,0(s0)
  800414:	0405                	addi	s0,s0,1
  800416:	3d7d                	addiw	s10,s10,-1
  800418:	0007851b          	sext.w	a0,a5
  80041c:	d395                	beqz	a5,800340 <vprintfmt+0x1ee>
  80041e:	f00cd3e3          	bgez	s9,800324 <vprintfmt+0x1d2>
  800422:	bff1                	j	8003fe <vprintfmt+0x2ac>
                putch('-', putdat);
  800424:	85a6                	mv	a1,s1
  800426:	02d00513          	li	a0,45
  80042a:	9902                	jalr	s2
                num = -(long long)num;
  80042c:	40800633          	neg	a2,s0
  800430:	8a5e                	mv	s4,s7
  800432:	46a9                	li	a3,10
  800434:	bd3d                	j	800272 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800436:	01a05663          	blez	s10,800442 <vprintfmt+0x2f0>
  80043a:	02d00793          	li	a5,45
  80043e:	00fd9b63          	bne	s11,a5,800454 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800442:	02800793          	li	a5,40
  800446:	853e                	mv	a0,a5
  800448:	00000417          	auipc	s0,0x0
  80044c:	0f940413          	addi	s0,s0,249 # 800541 <main+0x6b>
  800450:	5dfd                	li	s11,-1
  800452:	b5f9                	j	800320 <vprintfmt+0x1ce>
  800454:	00000417          	auipc	s0,0x0
  800458:	0ed40413          	addi	s0,s0,237 # 800541 <main+0x6b>
                p = "(null)";
  80045c:	00000717          	auipc	a4,0x0
  800460:	0e470713          	addi	a4,a4,228 # 800540 <main+0x6a>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800464:	853a                	mv	a0,a4
  800466:	85e6                	mv	a1,s9
  800468:	e43a                	sd	a4,8(sp)
  80046a:	050000ef          	jal	8004ba <strnlen>
  80046e:	40ad0d3b          	subw	s10,s10,a0
  800472:	6722                	ld	a4,8(sp)
  800474:	01a05b63          	blez	s10,80048a <vprintfmt+0x338>
                    putch(padc, putdat);
  800478:	2d81                	sext.w	s11,s11
  80047a:	85a6                	mv	a1,s1
  80047c:	856e                	mv	a0,s11
  80047e:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800480:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800482:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800484:	6722                	ld	a4,8(sp)
  800486:	fe0d1ae3          	bnez	s10,80047a <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048a:	00074783          	lbu	a5,0(a4)
  80048e:	0007851b          	sext.w	a0,a5
  800492:	ec0780e3          	beqz	a5,800352 <vprintfmt+0x200>
  800496:	5dfd                	li	s11,-1
  800498:	b561                	j	800320 <vprintfmt+0x1ce>

000000000080049a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80049a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80049c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004a2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a4:	ec06                	sd	ra,24(sp)
  8004a6:	f83a                	sd	a4,48(sp)
  8004a8:	fc3e                	sd	a5,56(sp)
  8004aa:	e0c2                	sd	a6,64(sp)
  8004ac:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004ae:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b0:	ca3ff0ef          	jal	800152 <vprintfmt>
}
  8004b4:	60e2                	ld	ra,24(sp)
  8004b6:	6161                	addi	sp,sp,80
  8004b8:	8082                	ret

00000000008004ba <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004ba:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004bc:	e589                	bnez	a1,8004c6 <strnlen+0xc>
  8004be:	a811                	j	8004d2 <strnlen+0x18>
        cnt ++;
  8004c0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004c2:	00f58863          	beq	a1,a5,8004d2 <strnlen+0x18>
  8004c6:	00f50733          	add	a4,a0,a5
  8004ca:	00074703          	lbu	a4,0(a4)
  8004ce:	fb6d                	bnez	a4,8004c0 <strnlen+0x6>
  8004d0:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004d2:	852e                	mv	a0,a1
  8004d4:	8082                	ret

00000000008004d6 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004d6:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004d8:	00000517          	auipc	a0,0x0
  8004dc:	15050513          	addi	a0,a0,336 # 800628 <main+0x152>
main(void) {
  8004e0:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  8004e2:	b5fff0ef          	jal	800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  8004e6:	bf1ff0ef          	jal	8000d6 <getpid>
  8004ea:	85aa                	mv	a1,a0
  8004ec:	00000517          	auipc	a0,0x0
  8004f0:	14c50513          	addi	a0,a0,332 # 800638 <main+0x162>
  8004f4:	b4dff0ef          	jal	800040 <cprintf>
    cprintf("hello pass.\n");
  8004f8:	00000517          	auipc	a0,0x0
  8004fc:	15850513          	addi	a0,a0,344 # 800650 <main+0x17a>
  800500:	b41ff0ef          	jal	800040 <cprintf>
    return 0;
}
  800504:	60a2                	ld	ra,8(sp)
  800506:	4501                	li	a0,0
  800508:	0141                	addi	sp,sp,16
  80050a:	8082                	ret
