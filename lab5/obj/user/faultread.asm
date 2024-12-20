
obj/__user_faultread.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b2000ef          	jal	8000d2 <umain>
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
  80002e:	088000ef          	jal	8000b6 <sys_putc>
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
  800068:	0e4000ef          	jal	80014c <vprintfmt>
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

00000000008000b6 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b6:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b8:	4579                	li	a0,30
  8000ba:	bf6d                	j	800074 <syscall>

00000000008000bc <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000bc:	1141                	addi	sp,sp,-16
  8000be:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c0:	ff1ff0ef          	jal	8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c4:	00000517          	auipc	a0,0x0
  8000c8:	41450513          	addi	a0,a0,1044 # 8004d8 <main+0x8>
  8000cc:	f75ff0ef          	jal	800040 <cprintf>
    while (1);
  8000d0:	a001                	j	8000d0 <exit+0x14>

00000000008000d2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d2:	1141                	addi	sp,sp,-16
  8000d4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d6:	3fa000ef          	jal	8004d0 <main>
    exit(ret);
  8000da:	fe3ff0ef          	jal	8000bc <exit>

00000000008000de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	f022                	sd	s0,32(sp)
  8000f0:	ec26                	sd	s1,24(sp)
  8000f2:	e84a                	sd	s2,16(sp)
  8000f4:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000f6:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	84aa                	mv	s1,a0
  8000fc:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  8000fe:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800100:	05067063          	bgeu	a2,a6,800140 <printnum+0x62>
  800104:	e44e                	sd	s3,8(sp)
  800106:	89be                	mv	s3,a5
        while (-- width > 0)
  800108:	4785                	li	a5,1
  80010a:	00e7d763          	bge	a5,a4,800118 <printnum+0x3a>
            putch(padc, putdat);
  80010e:	85ca                	mv	a1,s2
  800110:	854e                	mv	a0,s3
        while (-- width > 0)
  800112:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800114:	9482                	jalr	s1
        while (-- width > 0)
  800116:	fc65                	bnez	s0,80010e <printnum+0x30>
  800118:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80011a:	1a02                	slli	s4,s4,0x20
  80011c:	020a5a13          	srli	s4,s4,0x20
  800120:	00000797          	auipc	a5,0x0
  800124:	3d078793          	addi	a5,a5,976 # 8004f0 <main+0x20>
  800128:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80012a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012c:	0007c503          	lbu	a0,0(a5)
}
  800130:	70a2                	ld	ra,40(sp)
  800132:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800134:	85ca                	mv	a1,s2
  800136:	87a6                	mv	a5,s1
}
  800138:	6942                	ld	s2,16(sp)
  80013a:	64e2                	ld	s1,24(sp)
  80013c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800140:	03065633          	divu	a2,a2,a6
  800144:	8722                	mv	a4,s0
  800146:	f99ff0ef          	jal	8000de <printnum>
  80014a:	bfc1                	j	80011a <printnum+0x3c>

000000000080014c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014c:	7119                	addi	sp,sp,-128
  80014e:	f4a6                	sd	s1,104(sp)
  800150:	f0ca                	sd	s2,96(sp)
  800152:	ecce                	sd	s3,88(sp)
  800154:	e8d2                	sd	s4,80(sp)
  800156:	e4d6                	sd	s5,72(sp)
  800158:	e0da                	sd	s6,64(sp)
  80015a:	f862                	sd	s8,48(sp)
  80015c:	fc86                	sd	ra,120(sp)
  80015e:	f8a2                	sd	s0,112(sp)
  800160:	fc5e                	sd	s7,56(sp)
  800162:	f466                	sd	s9,40(sp)
  800164:	f06a                	sd	s10,32(sp)
  800166:	ec6e                	sd	s11,24(sp)
  800168:	892a                	mv	s2,a0
  80016a:	84ae                	mv	s1,a1
  80016c:	8c32                	mv	s8,a2
  80016e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800170:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800174:	05500b13          	li	s6,85
  800178:	00000a97          	auipc	s5,0x0
  80017c:	478a8a93          	addi	s5,s5,1144 # 8005f0 <main+0x120>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800180:	000c4503          	lbu	a0,0(s8)
  800184:	001c0413          	addi	s0,s8,1
  800188:	01350a63          	beq	a0,s3,80019c <vprintfmt+0x50>
            if (ch == '\0') {
  80018c:	cd0d                	beqz	a0,8001c6 <vprintfmt+0x7a>
            putch(ch, putdat);
  80018e:	85a6                	mv	a1,s1
  800190:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800192:	00044503          	lbu	a0,0(s0)
  800196:	0405                	addi	s0,s0,1
  800198:	ff351ae3          	bne	a0,s3,80018c <vprintfmt+0x40>
        width = precision = -1;
  80019c:	5cfd                	li	s9,-1
  80019e:	8d66                	mv	s10,s9
        char padc = ' ';
  8001a0:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001a4:	4b81                	li	s7,0
  8001a6:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001a8:	00044683          	lbu	a3,0(s0)
  8001ac:	00140c13          	addi	s8,s0,1
  8001b0:	fdd6859b          	addiw	a1,a3,-35
  8001b4:	0ff5f593          	zext.b	a1,a1
  8001b8:	02bb6663          	bltu	s6,a1,8001e4 <vprintfmt+0x98>
  8001bc:	058a                	slli	a1,a1,0x2
  8001be:	95d6                	add	a1,a1,s5
  8001c0:	4198                	lw	a4,0(a1)
  8001c2:	9756                	add	a4,a4,s5
  8001c4:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001c6:	70e6                	ld	ra,120(sp)
  8001c8:	7446                	ld	s0,112(sp)
  8001ca:	74a6                	ld	s1,104(sp)
  8001cc:	7906                	ld	s2,96(sp)
  8001ce:	69e6                	ld	s3,88(sp)
  8001d0:	6a46                	ld	s4,80(sp)
  8001d2:	6aa6                	ld	s5,72(sp)
  8001d4:	6b06                	ld	s6,64(sp)
  8001d6:	7be2                	ld	s7,56(sp)
  8001d8:	7c42                	ld	s8,48(sp)
  8001da:	7ca2                	ld	s9,40(sp)
  8001dc:	7d02                	ld	s10,32(sp)
  8001de:	6de2                	ld	s11,24(sp)
  8001e0:	6109                	addi	sp,sp,128
  8001e2:	8082                	ret
            putch('%', putdat);
  8001e4:	85a6                	mv	a1,s1
  8001e6:	02500513          	li	a0,37
  8001ea:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001ec:	fff44783          	lbu	a5,-1(s0)
  8001f0:	02500713          	li	a4,37
  8001f4:	8c22                	mv	s8,s0
  8001f6:	f8e785e3          	beq	a5,a4,800180 <vprintfmt+0x34>
  8001fa:	ffec4783          	lbu	a5,-2(s8)
  8001fe:	1c7d                	addi	s8,s8,-1
  800200:	fee79de3          	bne	a5,a4,8001fa <vprintfmt+0xae>
  800204:	bfb5                	j	800180 <vprintfmt+0x34>
                ch = *fmt;
  800206:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80020a:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80020c:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800210:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800214:	8462                	mv	s0,s8
                ch = *fmt;
  800216:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800218:	02e56463          	bltu	a0,a4,800240 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  80021c:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800220:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800224:	0197073b          	addw	a4,a4,s9
  800228:	0017171b          	slliw	a4,a4,0x1
  80022c:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  80022e:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800232:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800234:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800238:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  80023c:	feb570e3          	bgeu	a0,a1,80021c <vprintfmt+0xd0>
            if (width < 0)
  800240:	f60d54e3          	bgez	s10,8001a8 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800244:	8d66                	mv	s10,s9
  800246:	5cfd                	li	s9,-1
  800248:	b785                	j	8001a8 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80024a:	8db6                	mv	s11,a3
  80024c:	8462                	mv	s0,s8
  80024e:	bfa9                	j	8001a8 <vprintfmt+0x5c>
  800250:	8462                	mv	s0,s8
            altflag = 1;
  800252:	4b85                	li	s7,1
            goto reswitch;
  800254:	bf91                	j	8001a8 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800256:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800258:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80025c:	00c7c463          	blt	a5,a2,800264 <vprintfmt+0x118>
    else if (lflag) {
  800260:	18060763          	beqz	a2,8003ee <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  800264:	000a3603          	ld	a2,0(s4)
  800268:	46c1                	li	a3,16
  80026a:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  80026c:	000d879b          	sext.w	a5,s11
  800270:	876a                	mv	a4,s10
  800272:	85a6                	mv	a1,s1
  800274:	854a                	mv	a0,s2
  800276:	e69ff0ef          	jal	8000de <printnum>
            break;
  80027a:	b719                	j	800180 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80027c:	000a2503          	lw	a0,0(s4)
  800280:	85a6                	mv	a1,s1
  800282:	0a21                	addi	s4,s4,8
  800284:	9902                	jalr	s2
            break;
  800286:	bded                	j	800180 <vprintfmt+0x34>
    if (lflag >= 2) {
  800288:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80028a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80028e:	00c7c463          	blt	a5,a2,800296 <vprintfmt+0x14a>
    else if (lflag) {
  800292:	14060963          	beqz	a2,8003e4 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  800296:	000a3603          	ld	a2,0(s4)
  80029a:	46a9                	li	a3,10
  80029c:	8a3a                	mv	s4,a4
  80029e:	b7f9                	j	80026c <vprintfmt+0x120>
            putch('0', putdat);
  8002a0:	85a6                	mv	a1,s1
  8002a2:	03000513          	li	a0,48
  8002a6:	9902                	jalr	s2
            putch('x', putdat);
  8002a8:	85a6                	mv	a1,s1
  8002aa:	07800513          	li	a0,120
  8002ae:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b0:	000a3603          	ld	a2,0(s4)
            goto number;
  8002b4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b6:	0a21                	addi	s4,s4,8
            goto number;
  8002b8:	bf55                	j	80026c <vprintfmt+0x120>
            putch(ch, putdat);
  8002ba:	85a6                	mv	a1,s1
  8002bc:	02500513          	li	a0,37
  8002c0:	9902                	jalr	s2
            break;
  8002c2:	bd7d                	j	800180 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002c4:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c8:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002ca:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002cc:	bf95                	j	800240 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002ce:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002d0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002d4:	00c7c463          	blt	a5,a2,8002dc <vprintfmt+0x190>
    else if (lflag) {
  8002d8:	10060163          	beqz	a2,8003da <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  8002dc:	000a3603          	ld	a2,0(s4)
  8002e0:	46a1                	li	a3,8
  8002e2:	8a3a                	mv	s4,a4
  8002e4:	b761                	j	80026c <vprintfmt+0x120>
            if (width < 0)
  8002e6:	87ea                	mv	a5,s10
  8002e8:	000d5363          	bgez	s10,8002ee <vprintfmt+0x1a2>
  8002ec:	4781                	li	a5,0
  8002ee:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  8002f2:	8462                	mv	s0,s8
            goto reswitch;
  8002f4:	bd55                	j	8001a8 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002f6:	000a3703          	ld	a4,0(s4)
  8002fa:	12070b63          	beqz	a4,800430 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  8002fe:	0da05563          	blez	s10,8003c8 <vprintfmt+0x27c>
  800302:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800306:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  80030a:	14fd9a63          	bne	s11,a5,80045e <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80030e:	00074783          	lbu	a5,0(a4)
  800312:	0007851b          	sext.w	a0,a5
  800316:	c785                	beqz	a5,80033e <vprintfmt+0x1f2>
  800318:	5dfd                	li	s11,-1
  80031a:	000cc563          	bltz	s9,800324 <vprintfmt+0x1d8>
  80031e:	3cfd                	addiw	s9,s9,-1
  800320:	01bc8d63          	beq	s9,s11,80033a <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  800324:	0c0b9a63          	bnez	s7,8003f8 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  800328:	85a6                	mv	a1,s1
  80032a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032c:	00044783          	lbu	a5,0(s0)
  800330:	0405                	addi	s0,s0,1
  800332:	3d7d                	addiw	s10,s10,-1
  800334:	0007851b          	sext.w	a0,a5
  800338:	f3ed                	bnez	a5,80031a <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  80033a:	01a05963          	blez	s10,80034c <vprintfmt+0x200>
                putch(' ', putdat);
  80033e:	85a6                	mv	a1,s1
  800340:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800344:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800346:	9902                	jalr	s2
            for (; width > 0; width --) {
  800348:	fe0d1be3          	bnez	s10,80033e <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  80034c:	0a21                	addi	s4,s4,8
  80034e:	bd0d                	j	800180 <vprintfmt+0x34>
    if (lflag >= 2) {
  800350:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800352:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800356:	00c7c363          	blt	a5,a2,80035c <vprintfmt+0x210>
    else if (lflag) {
  80035a:	c625                	beqz	a2,8003c2 <vprintfmt+0x276>
        return va_arg(*ap, long);
  80035c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800360:	0a044f63          	bltz	s0,80041e <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  800364:	8622                	mv	a2,s0
  800366:	8a5e                	mv	s4,s7
  800368:	46a9                	li	a3,10
  80036a:	b709                	j	80026c <vprintfmt+0x120>
            if (err < 0) {
  80036c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800370:	4661                	li	a2,24
            if (err < 0) {
  800372:	41f7d71b          	sraiw	a4,a5,0x1f
  800376:	8fb9                	xor	a5,a5,a4
  800378:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80037c:	02d64663          	blt	a2,a3,8003a8 <vprintfmt+0x25c>
  800380:	00000797          	auipc	a5,0x0
  800384:	3c878793          	addi	a5,a5,968 # 800748 <error_string>
  800388:	00369713          	slli	a4,a3,0x3
  80038c:	97ba                	add	a5,a5,a4
  80038e:	639c                	ld	a5,0(a5)
  800390:	cf81                	beqz	a5,8003a8 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  800392:	86be                	mv	a3,a5
  800394:	00000617          	auipc	a2,0x0
  800398:	19460613          	addi	a2,a2,404 # 800528 <main+0x58>
  80039c:	85a6                	mv	a1,s1
  80039e:	854a                	mv	a0,s2
  8003a0:	0f4000ef          	jal	800494 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003a4:	0a21                	addi	s4,s4,8
  8003a6:	bbe9                	j	800180 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003a8:	00000617          	auipc	a2,0x0
  8003ac:	17060613          	addi	a2,a2,368 # 800518 <main+0x48>
  8003b0:	85a6                	mv	a1,s1
  8003b2:	854a                	mv	a0,s2
  8003b4:	0e0000ef          	jal	800494 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b8:	0a21                	addi	s4,s4,8
  8003ba:	b3d9                	j	800180 <vprintfmt+0x34>
            lflag ++;
  8003bc:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003be:	8462                	mv	s0,s8
            goto reswitch;
  8003c0:	b3e5                	j	8001a8 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003c2:	000a2403          	lw	s0,0(s4)
  8003c6:	bf69                	j	800360 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c8:	00074783          	lbu	a5,0(a4)
  8003cc:	0007851b          	sext.w	a0,a5
  8003d0:	dfb5                	beqz	a5,80034c <vprintfmt+0x200>
  8003d2:	00170413          	addi	s0,a4,1
  8003d6:	5dfd                	li	s11,-1
  8003d8:	b789                	j	80031a <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  8003da:	000a6603          	lwu	a2,0(s4)
  8003de:	46a1                	li	a3,8
  8003e0:	8a3a                	mv	s4,a4
  8003e2:	b569                	j	80026c <vprintfmt+0x120>
  8003e4:	000a6603          	lwu	a2,0(s4)
  8003e8:	46a9                	li	a3,10
  8003ea:	8a3a                	mv	s4,a4
  8003ec:	b541                	j	80026c <vprintfmt+0x120>
  8003ee:	000a6603          	lwu	a2,0(s4)
  8003f2:	46c1                	li	a3,16
  8003f4:	8a3a                	mv	s4,a4
  8003f6:	bd9d                	j	80026c <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003f8:	3781                	addiw	a5,a5,-32
  8003fa:	05e00713          	li	a4,94
  8003fe:	f2f775e3          	bgeu	a4,a5,800328 <vprintfmt+0x1dc>
                    putch('?', putdat);
  800402:	03f00513          	li	a0,63
  800406:	85a6                	mv	a1,s1
  800408:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80040a:	00044783          	lbu	a5,0(s0)
  80040e:	0405                	addi	s0,s0,1
  800410:	3d7d                	addiw	s10,s10,-1
  800412:	0007851b          	sext.w	a0,a5
  800416:	d395                	beqz	a5,80033a <vprintfmt+0x1ee>
  800418:	f00cd3e3          	bgez	s9,80031e <vprintfmt+0x1d2>
  80041c:	bff1                	j	8003f8 <vprintfmt+0x2ac>
                putch('-', putdat);
  80041e:	85a6                	mv	a1,s1
  800420:	02d00513          	li	a0,45
  800424:	9902                	jalr	s2
                num = -(long long)num;
  800426:	40800633          	neg	a2,s0
  80042a:	8a5e                	mv	s4,s7
  80042c:	46a9                	li	a3,10
  80042e:	bd3d                	j	80026c <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800430:	01a05663          	blez	s10,80043c <vprintfmt+0x2f0>
  800434:	02d00793          	li	a5,45
  800438:	00fd9b63          	bne	s11,a5,80044e <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043c:	02800793          	li	a5,40
  800440:	853e                	mv	a0,a5
  800442:	00000417          	auipc	s0,0x0
  800446:	0c740413          	addi	s0,s0,199 # 800509 <main+0x39>
  80044a:	5dfd                	li	s11,-1
  80044c:	b5f9                	j	80031a <vprintfmt+0x1ce>
  80044e:	00000417          	auipc	s0,0x0
  800452:	0bb40413          	addi	s0,s0,187 # 800509 <main+0x39>
                p = "(null)";
  800456:	00000717          	auipc	a4,0x0
  80045a:	0b270713          	addi	a4,a4,178 # 800508 <main+0x38>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045e:	853a                	mv	a0,a4
  800460:	85e6                	mv	a1,s9
  800462:	e43a                	sd	a4,8(sp)
  800464:	050000ef          	jal	8004b4 <strnlen>
  800468:	40ad0d3b          	subw	s10,s10,a0
  80046c:	6722                	ld	a4,8(sp)
  80046e:	01a05b63          	blez	s10,800484 <vprintfmt+0x338>
                    putch(padc, putdat);
  800472:	2d81                	sext.w	s11,s11
  800474:	85a6                	mv	a1,s1
  800476:	856e                	mv	a0,s11
  800478:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047a:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  80047c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	6722                	ld	a4,8(sp)
  800480:	fe0d1ae3          	bnez	s10,800474 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	00074783          	lbu	a5,0(a4)
  800488:	0007851b          	sext.w	a0,a5
  80048c:	ec0780e3          	beqz	a5,80034c <vprintfmt+0x200>
  800490:	5dfd                	li	s11,-1
  800492:	b561                	j	80031a <vprintfmt+0x1ce>

0000000000800494 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800494:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800496:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80049a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80049c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80049e:	ec06                	sd	ra,24(sp)
  8004a0:	f83a                	sd	a4,48(sp)
  8004a2:	fc3e                	sd	a5,56(sp)
  8004a4:	e0c2                	sd	a6,64(sp)
  8004a6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004a8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004aa:	ca3ff0ef          	jal	80014c <vprintfmt>
}
  8004ae:	60e2                	ld	ra,24(sp)
  8004b0:	6161                	addi	sp,sp,80
  8004b2:	8082                	ret

00000000008004b4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004b4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004b6:	e589                	bnez	a1,8004c0 <strnlen+0xc>
  8004b8:	a811                	j	8004cc <strnlen+0x18>
        cnt ++;
  8004ba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004bc:	00f58863          	beq	a1,a5,8004cc <strnlen+0x18>
  8004c0:	00f50733          	add	a4,a0,a5
  8004c4:	00074703          	lbu	a4,0(a4)
  8004c8:	fb6d                	bnez	a4,8004ba <strnlen+0x6>
  8004ca:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004cc:	852e                	mv	a0,a1
  8004ce:	8082                	ret

00000000008004d0 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004d0:	4781                	li	a5,0
  8004d2:	439c                	lw	a5,0(a5)
  8004d4:	9002                	ebreak
