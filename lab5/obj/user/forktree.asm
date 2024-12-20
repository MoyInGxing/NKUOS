
obj/__user_forktree.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c4000ef          	jal	8000e4 <umain>
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
  80002e:	094000ef          	jal	8000c2 <sys_putc>
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
  800068:	110000ef          	jal	800178 <vprintfmt>
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

00000000008000b6 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b6:	4509                	li	a0,2
  8000b8:	bf75                	j	800074 <syscall>

00000000008000ba <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000ba:	4529                	li	a0,10
  8000bc:	bf65                	j	800074 <syscall>

00000000008000be <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000be:	4549                	li	a0,18
  8000c0:	bf55                	j	800074 <syscall>

00000000008000c2 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000c2:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c4:	4579                	li	a0,30
  8000c6:	b77d                	j	800074 <syscall>

00000000008000c8 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c8:	1141                	addi	sp,sp,-16
  8000ca:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000cc:	fe5ff0ef          	jal	8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d0:	00000517          	auipc	a0,0x0
  8000d4:	55050513          	addi	a0,a0,1360 # 800620 <main+0x18>
  8000d8:	f69ff0ef          	jal	800040 <cprintf>
    while (1);
  8000dc:	a001                	j	8000dc <exit+0x14>

00000000008000de <fork>:
}

int
fork(void) {
    return sys_fork();
  8000de:	bfe1                	j	8000b6 <sys_fork>

00000000008000e0 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000e0:	bfe9                	j	8000ba <sys_yield>

00000000008000e2 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e2:	bff1                	j	8000be <sys_getpid>

00000000008000e4 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e4:	1141                	addi	sp,sp,-16
  8000e6:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e8:	520000ef          	jal	800608 <main>
    exit(ret);
  8000ec:	fddff0ef          	jal	8000c8 <exit>

00000000008000f0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800100:	f022                	sd	s0,32(sp)
  800102:	ec26                	sd	s1,24(sp)
  800104:	e84a                	sd	s2,16(sp)
  800106:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800108:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80010c:	84aa                	mv	s1,a0
  80010e:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800110:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800112:	05067063          	bgeu	a2,a6,800152 <printnum+0x62>
  800116:	e44e                	sd	s3,8(sp)
  800118:	89be                	mv	s3,a5
        while (-- width > 0)
  80011a:	4785                	li	a5,1
  80011c:	00e7d763          	bge	a5,a4,80012a <printnum+0x3a>
            putch(padc, putdat);
  800120:	85ca                	mv	a1,s2
  800122:	854e                	mv	a0,s3
        while (-- width > 0)
  800124:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800126:	9482                	jalr	s1
        while (-- width > 0)
  800128:	fc65                	bnez	s0,800120 <printnum+0x30>
  80012a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80012c:	1a02                	slli	s4,s4,0x20
  80012e:	020a5a13          	srli	s4,s4,0x20
  800132:	00000797          	auipc	a5,0x0
  800136:	50678793          	addi	a5,a5,1286 # 800638 <main+0x30>
  80013a:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013e:	0007c503          	lbu	a0,0(a5)
}
  800142:	70a2                	ld	ra,40(sp)
  800144:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800146:	85ca                	mv	a1,s2
  800148:	87a6                	mv	a5,s1
}
  80014a:	6942                	ld	s2,16(sp)
  80014c:	64e2                	ld	s1,24(sp)
  80014e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800150:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800152:	03065633          	divu	a2,a2,a6
  800156:	8722                	mv	a4,s0
  800158:	f99ff0ef          	jal	8000f0 <printnum>
  80015c:	bfc1                	j	80012c <printnum+0x3c>

000000000080015e <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  80015e:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800160:	6198                	ld	a4,0(a1)
  800162:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800164:	2785                	addiw	a5,a5,1
  800166:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800168:	00d77763          	bgeu	a4,a3,800176 <sprintputch+0x18>
        *b->buf ++ = ch;
  80016c:	00170793          	addi	a5,a4,1
  800170:	e19c                	sd	a5,0(a1)
  800172:	00a70023          	sb	a0,0(a4)
    }
}
  800176:	8082                	ret

0000000000800178 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800178:	7119                	addi	sp,sp,-128
  80017a:	f4a6                	sd	s1,104(sp)
  80017c:	f0ca                	sd	s2,96(sp)
  80017e:	ecce                	sd	s3,88(sp)
  800180:	e8d2                	sd	s4,80(sp)
  800182:	e4d6                	sd	s5,72(sp)
  800184:	e0da                	sd	s6,64(sp)
  800186:	f862                	sd	s8,48(sp)
  800188:	fc86                	sd	ra,120(sp)
  80018a:	f8a2                	sd	s0,112(sp)
  80018c:	fc5e                	sd	s7,56(sp)
  80018e:	f466                	sd	s9,40(sp)
  800190:	f06a                	sd	s10,32(sp)
  800192:	ec6e                	sd	s11,24(sp)
  800194:	892a                	mv	s2,a0
  800196:	84ae                	mv	s1,a1
  800198:	8c32                	mv	s8,a2
  80019a:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019c:	02500993          	li	s3,37
        switch (ch = *(unsigned char *)fmt ++) {
  8001a0:	05500b13          	li	s6,85
  8001a4:	00000a97          	auipc	s5,0x0
  8001a8:	5aca8a93          	addi	s5,s5,1452 # 800750 <main+0x148>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ac:	000c4503          	lbu	a0,0(s8)
  8001b0:	001c0413          	addi	s0,s8,1
  8001b4:	01350a63          	beq	a0,s3,8001c8 <vprintfmt+0x50>
            if (ch == '\0') {
  8001b8:	cd0d                	beqz	a0,8001f2 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001ba:	85a6                	mv	a1,s1
  8001bc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001be:	00044503          	lbu	a0,0(s0)
  8001c2:	0405                	addi	s0,s0,1
  8001c4:	ff351ae3          	bne	a0,s3,8001b8 <vprintfmt+0x40>
        width = precision = -1;
  8001c8:	5cfd                	li	s9,-1
  8001ca:	8d66                	mv	s10,s9
        char padc = ' ';
  8001cc:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001d0:	4b81                	li	s7,0
  8001d2:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001d4:	00044683          	lbu	a3,0(s0)
  8001d8:	00140c13          	addi	s8,s0,1
  8001dc:	fdd6859b          	addiw	a1,a3,-35
  8001e0:	0ff5f593          	zext.b	a1,a1
  8001e4:	02bb6663          	bltu	s6,a1,800210 <vprintfmt+0x98>
  8001e8:	058a                	slli	a1,a1,0x2
  8001ea:	95d6                	add	a1,a1,s5
  8001ec:	4198                	lw	a4,0(a1)
  8001ee:	9756                	add	a4,a4,s5
  8001f0:	8702                	jr	a4
}
  8001f2:	70e6                	ld	ra,120(sp)
  8001f4:	7446                	ld	s0,112(sp)
  8001f6:	74a6                	ld	s1,104(sp)
  8001f8:	7906                	ld	s2,96(sp)
  8001fa:	69e6                	ld	s3,88(sp)
  8001fc:	6a46                	ld	s4,80(sp)
  8001fe:	6aa6                	ld	s5,72(sp)
  800200:	6b06                	ld	s6,64(sp)
  800202:	7be2                	ld	s7,56(sp)
  800204:	7c42                	ld	s8,48(sp)
  800206:	7ca2                	ld	s9,40(sp)
  800208:	7d02                	ld	s10,32(sp)
  80020a:	6de2                	ld	s11,24(sp)
  80020c:	6109                	addi	sp,sp,128
  80020e:	8082                	ret
            putch('%', putdat);
  800210:	85a6                	mv	a1,s1
  800212:	02500513          	li	a0,37
  800216:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800218:	fff44783          	lbu	a5,-1(s0)
  80021c:	02500713          	li	a4,37
  800220:	8c22                	mv	s8,s0
  800222:	f8e785e3          	beq	a5,a4,8001ac <vprintfmt+0x34>
  800226:	ffec4783          	lbu	a5,-2(s8)
  80022a:	1c7d                	addi	s8,s8,-1
  80022c:	fee79de3          	bne	a5,a4,800226 <vprintfmt+0xae>
  800230:	bfb5                	j	8001ac <vprintfmt+0x34>
                ch = *fmt;
  800232:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800236:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800238:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80023c:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	8462                	mv	s0,s8
                ch = *fmt;
  800242:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800244:	02e56463          	bltu	a0,a4,80026c <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  800248:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80024c:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800250:	0197073b          	addw	a4,a4,s9
  800254:	0017171b          	slliw	a4,a4,0x1
  800258:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  80025a:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80025e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800260:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800264:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  800268:	feb570e3          	bgeu	a0,a1,800248 <vprintfmt+0xd0>
            if (width < 0)
  80026c:	f60d54e3          	bgez	s10,8001d4 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800270:	8d66                	mv	s10,s9
  800272:	5cfd                	li	s9,-1
  800274:	b785                	j	8001d4 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800276:	8db6                	mv	s11,a3
  800278:	8462                	mv	s0,s8
  80027a:	bfa9                	j	8001d4 <vprintfmt+0x5c>
  80027c:	8462                	mv	s0,s8
            altflag = 1;
  80027e:	4b85                	li	s7,1
            goto reswitch;
  800280:	bf91                	j	8001d4 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800282:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800284:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800288:	00c7c463          	blt	a5,a2,800290 <vprintfmt+0x118>
    else if (lflag) {
  80028c:	18060763          	beqz	a2,80041a <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  800290:	000a3603          	ld	a2,0(s4)
  800294:	46c1                	li	a3,16
  800296:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  800298:	000d879b          	sext.w	a5,s11
  80029c:	876a                	mv	a4,s10
  80029e:	85a6                	mv	a1,s1
  8002a0:	854a                	mv	a0,s2
  8002a2:	e4fff0ef          	jal	8000f0 <printnum>
            break;
  8002a6:	b719                	j	8001ac <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002a8:	000a2503          	lw	a0,0(s4)
  8002ac:	85a6                	mv	a1,s1
  8002ae:	0a21                	addi	s4,s4,8
  8002b0:	9902                	jalr	s2
            break;
  8002b2:	bded                	j	8001ac <vprintfmt+0x34>
    if (lflag >= 2) {
  8002b4:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002b6:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002ba:	00c7c463          	blt	a5,a2,8002c2 <vprintfmt+0x14a>
    else if (lflag) {
  8002be:	14060963          	beqz	a2,800410 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  8002c2:	000a3603          	ld	a2,0(s4)
  8002c6:	46a9                	li	a3,10
  8002c8:	8a3a                	mv	s4,a4
  8002ca:	b7f9                	j	800298 <vprintfmt+0x120>
            putch('0', putdat);
  8002cc:	85a6                	mv	a1,s1
  8002ce:	03000513          	li	a0,48
  8002d2:	9902                	jalr	s2
            putch('x', putdat);
  8002d4:	85a6                	mv	a1,s1
  8002d6:	07800513          	li	a0,120
  8002da:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002dc:	000a3603          	ld	a2,0(s4)
            goto number;
  8002e0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002e2:	0a21                	addi	s4,s4,8
            goto number;
  8002e4:	bf55                	j	800298 <vprintfmt+0x120>
            putch(ch, putdat);
  8002e6:	85a6                	mv	a1,s1
  8002e8:	02500513          	li	a0,37
  8002ec:	9902                	jalr	s2
            break;
  8002ee:	bd7d                	j	8001ac <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002f0:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002f4:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002f6:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002f8:	bf95                	j	80026c <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002fa:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002fc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800300:	00c7c463          	blt	a5,a2,800308 <vprintfmt+0x190>
    else if (lflag) {
  800304:	10060163          	beqz	a2,800406 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  800308:	000a3603          	ld	a2,0(s4)
  80030c:	46a1                	li	a3,8
  80030e:	8a3a                	mv	s4,a4
  800310:	b761                	j	800298 <vprintfmt+0x120>
            if (width < 0)
  800312:	87ea                	mv	a5,s10
  800314:	000d5363          	bgez	s10,80031a <vprintfmt+0x1a2>
  800318:	4781                	li	a5,0
  80031a:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80031e:	8462                	mv	s0,s8
            goto reswitch;
  800320:	bd55                	j	8001d4 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800322:	000a3703          	ld	a4,0(s4)
  800326:	12070b63          	beqz	a4,80045c <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  80032a:	0da05563          	blez	s10,8003f4 <vprintfmt+0x27c>
  80032e:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800332:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  800336:	14fd9a63          	bne	s11,a5,80048a <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80033a:	00074783          	lbu	a5,0(a4)
  80033e:	0007851b          	sext.w	a0,a5
  800342:	c785                	beqz	a5,80036a <vprintfmt+0x1f2>
  800344:	5dfd                	li	s11,-1
  800346:	000cc563          	bltz	s9,800350 <vprintfmt+0x1d8>
  80034a:	3cfd                	addiw	s9,s9,-1
  80034c:	01bc8d63          	beq	s9,s11,800366 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  800350:	0c0b9a63          	bnez	s7,800424 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  800354:	85a6                	mv	a1,s1
  800356:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800358:	00044783          	lbu	a5,0(s0)
  80035c:	0405                	addi	s0,s0,1
  80035e:	3d7d                	addiw	s10,s10,-1
  800360:	0007851b          	sext.w	a0,a5
  800364:	f3ed                	bnez	a5,800346 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  800366:	01a05963          	blez	s10,800378 <vprintfmt+0x200>
                putch(' ', putdat);
  80036a:	85a6                	mv	a1,s1
  80036c:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800370:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800372:	9902                	jalr	s2
            for (; width > 0; width --) {
  800374:	fe0d1be3          	bnez	s10,80036a <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  800378:	0a21                	addi	s4,s4,8
  80037a:	bd0d                	j	8001ac <vprintfmt+0x34>
    if (lflag >= 2) {
  80037c:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80037e:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800382:	00c7c363          	blt	a5,a2,800388 <vprintfmt+0x210>
    else if (lflag) {
  800386:	c625                	beqz	a2,8003ee <vprintfmt+0x276>
        return va_arg(*ap, long);
  800388:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80038c:	0a044f63          	bltz	s0,80044a <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  800390:	8622                	mv	a2,s0
  800392:	8a5e                	mv	s4,s7
  800394:	46a9                	li	a3,10
  800396:	b709                	j	800298 <vprintfmt+0x120>
            if (err < 0) {
  800398:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80039c:	4661                	li	a2,24
            if (err < 0) {
  80039e:	41f7d71b          	sraiw	a4,a5,0x1f
  8003a2:	8fb9                	xor	a5,a5,a4
  8003a4:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a8:	02d64663          	blt	a2,a3,8003d4 <vprintfmt+0x25c>
  8003ac:	00000797          	auipc	a5,0x0
  8003b0:	4fc78793          	addi	a5,a5,1276 # 8008a8 <error_string>
  8003b4:	00369713          	slli	a4,a3,0x3
  8003b8:	97ba                	add	a5,a5,a4
  8003ba:	639c                	ld	a5,0(a5)
  8003bc:	cf81                	beqz	a5,8003d4 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  8003be:	86be                	mv	a3,a5
  8003c0:	00000617          	auipc	a2,0x0
  8003c4:	2a860613          	addi	a2,a2,680 # 800668 <main+0x60>
  8003c8:	85a6                	mv	a1,s1
  8003ca:	854a                	mv	a0,s2
  8003cc:	0f4000ef          	jal	8004c0 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003d0:	0a21                	addi	s4,s4,8
  8003d2:	bbe9                	j	8001ac <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003d4:	00000617          	auipc	a2,0x0
  8003d8:	28460613          	addi	a2,a2,644 # 800658 <main+0x50>
  8003dc:	85a6                	mv	a1,s1
  8003de:	854a                	mv	a0,s2
  8003e0:	0e0000ef          	jal	8004c0 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003e4:	0a21                	addi	s4,s4,8
  8003e6:	b3d9                	j	8001ac <vprintfmt+0x34>
            lflag ++;
  8003e8:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003ea:	8462                	mv	s0,s8
            goto reswitch;
  8003ec:	b3e5                	j	8001d4 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003ee:	000a2403          	lw	s0,0(s4)
  8003f2:	bf69                	j	80038c <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003f4:	00074783          	lbu	a5,0(a4)
  8003f8:	0007851b          	sext.w	a0,a5
  8003fc:	dfb5                	beqz	a5,800378 <vprintfmt+0x200>
  8003fe:	00170413          	addi	s0,a4,1
  800402:	5dfd                	li	s11,-1
  800404:	b789                	j	800346 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  800406:	000a6603          	lwu	a2,0(s4)
  80040a:	46a1                	li	a3,8
  80040c:	8a3a                	mv	s4,a4
  80040e:	b569                	j	800298 <vprintfmt+0x120>
  800410:	000a6603          	lwu	a2,0(s4)
  800414:	46a9                	li	a3,10
  800416:	8a3a                	mv	s4,a4
  800418:	b541                	j	800298 <vprintfmt+0x120>
  80041a:	000a6603          	lwu	a2,0(s4)
  80041e:	46c1                	li	a3,16
  800420:	8a3a                	mv	s4,a4
  800422:	bd9d                	j	800298 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800424:	3781                	addiw	a5,a5,-32
  800426:	05e00713          	li	a4,94
  80042a:	f2f775e3          	bgeu	a4,a5,800354 <vprintfmt+0x1dc>
                    putch('?', putdat);
  80042e:	03f00513          	li	a0,63
  800432:	85a6                	mv	a1,s1
  800434:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800436:	00044783          	lbu	a5,0(s0)
  80043a:	0405                	addi	s0,s0,1
  80043c:	3d7d                	addiw	s10,s10,-1
  80043e:	0007851b          	sext.w	a0,a5
  800442:	d395                	beqz	a5,800366 <vprintfmt+0x1ee>
  800444:	f00cd3e3          	bgez	s9,80034a <vprintfmt+0x1d2>
  800448:	bff1                	j	800424 <vprintfmt+0x2ac>
                putch('-', putdat);
  80044a:	85a6                	mv	a1,s1
  80044c:	02d00513          	li	a0,45
  800450:	9902                	jalr	s2
                num = -(long long)num;
  800452:	40800633          	neg	a2,s0
  800456:	8a5e                	mv	s4,s7
  800458:	46a9                	li	a3,10
  80045a:	bd3d                	j	800298 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80045c:	01a05663          	blez	s10,800468 <vprintfmt+0x2f0>
  800460:	02d00793          	li	a5,45
  800464:	00fd9b63          	bne	s11,a5,80047a <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800468:	02800793          	li	a5,40
  80046c:	853e                	mv	a0,a5
  80046e:	00000417          	auipc	s0,0x0
  800472:	1e340413          	addi	s0,s0,483 # 800651 <main+0x49>
  800476:	5dfd                	li	s11,-1
  800478:	b5f9                	j	800346 <vprintfmt+0x1ce>
  80047a:	00000417          	auipc	s0,0x0
  80047e:	1d740413          	addi	s0,s0,471 # 800651 <main+0x49>
                p = "(null)";
  800482:	00000717          	auipc	a4,0x0
  800486:	1ce70713          	addi	a4,a4,462 # 800650 <main+0x48>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048a:	853a                	mv	a0,a4
  80048c:	85e6                	mv	a1,s9
  80048e:	e43a                	sd	a4,8(sp)
  800490:	0b0000ef          	jal	800540 <strnlen>
  800494:	40ad0d3b          	subw	s10,s10,a0
  800498:	6722                	ld	a4,8(sp)
  80049a:	01a05b63          	blez	s10,8004b0 <vprintfmt+0x338>
                    putch(padc, putdat);
  80049e:	2d81                	sext.w	s11,s11
  8004a0:	85a6                	mv	a1,s1
  8004a2:	856e                	mv	a0,s11
  8004a4:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a6:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004a8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	6722                	ld	a4,8(sp)
  8004ac:	fe0d1ae3          	bnez	s10,8004a0 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b0:	00074783          	lbu	a5,0(a4)
  8004b4:	0007851b          	sext.w	a0,a5
  8004b8:	ec0780e3          	beqz	a5,800378 <vprintfmt+0x200>
  8004bc:	5dfd                	li	s11,-1
  8004be:	b561                	j	800346 <vprintfmt+0x1ce>

00000000008004c0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004c2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004c6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ca:	ec06                	sd	ra,24(sp)
  8004cc:	f83a                	sd	a4,48(sp)
  8004ce:	fc3e                	sd	a5,56(sp)
  8004d0:	e0c2                	sd	a6,64(sp)
  8004d2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004d4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d6:	ca3ff0ef          	jal	800178 <vprintfmt>
}
  8004da:	60e2                	ld	ra,24(sp)
  8004dc:	6161                	addi	sp,sp,80
  8004de:	8082                	ret

00000000008004e0 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004e0:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  8004e2:	15fd                	addi	a1,a1,-1
  8004e4:	95aa                	add	a1,a1,a0
    va_start(ap, fmt);
  8004e6:	03810313          	addi	t1,sp,56
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004ea:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  8004ec:	e82e                	sd	a1,16(sp)
  8004ee:	e42a                	sd	a0,8(sp)
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004f0:	fc36                	sd	a3,56(sp)
  8004f2:	e0ba                	sd	a4,64(sp)
  8004f4:	e4be                	sd	a5,72(sp)
  8004f6:	e8c2                	sd	a6,80(sp)
  8004f8:	ecc6                	sd	a7,88(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  8004fa:	cc02                	sw	zero,24(sp)
    va_start(ap, fmt);
  8004fc:	e01a                	sd	t1,0(sp)
    if (str == NULL || b.buf > b.ebuf) {
  8004fe:	c115                	beqz	a0,800522 <snprintf+0x42>
  800500:	02a5e163          	bltu	a1,a0,800522 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800504:	00000517          	auipc	a0,0x0
  800508:	c5a50513          	addi	a0,a0,-934 # 80015e <sprintputch>
  80050c:	869a                	mv	a3,t1
  80050e:	002c                	addi	a1,sp,8
  800510:	c69ff0ef          	jal	800178 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800514:	67a2                	ld	a5,8(sp)
  800516:	00078023          	sb	zero,0(a5)
    return b.cnt;
  80051a:	4562                	lw	a0,24(sp)
}
  80051c:	70a2                	ld	ra,40(sp)
  80051e:	6125                	addi	sp,sp,96
  800520:	8082                	ret
        return -E_INVAL;
  800522:	5575                	li	a0,-3
  800524:	bfe5                	j	80051c <snprintf+0x3c>

0000000000800526 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  800526:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
  80052a:	872a                	mv	a4,a0
    size_t cnt = 0;
  80052c:	4501                	li	a0,0
    while (*s ++ != '\0') {
  80052e:	cb81                	beqz	a5,80053e <strlen+0x18>
        cnt ++;
  800530:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
  800532:	00a707b3          	add	a5,a4,a0
  800536:	0007c783          	lbu	a5,0(a5)
  80053a:	fbfd                	bnez	a5,800530 <strlen+0xa>
  80053c:	8082                	ret
    }
    return cnt;
}
  80053e:	8082                	ret

0000000000800540 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800540:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800542:	e589                	bnez	a1,80054c <strnlen+0xc>
  800544:	a811                	j	800558 <strnlen+0x18>
        cnt ++;
  800546:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800548:	00f58863          	beq	a1,a5,800558 <strnlen+0x18>
  80054c:	00f50733          	add	a4,a0,a5
  800550:	00074703          	lbu	a4,0(a4)
  800554:	fb6d                	bnez	a4,800546 <strnlen+0x6>
  800556:	85be                	mv	a1,a5
    }
    return cnt;
}
  800558:	852e                	mv	a0,a1
  80055a:	8082                	ret

000000000080055c <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80055c:	1101                	addi	sp,sp,-32
  80055e:	ec06                	sd	ra,24(sp)
  800560:	e822                	sd	s0,16(sp)
  800562:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800564:	b7fff0ef          	jal	8000e2 <getpid>
  800568:	85aa                	mv	a1,a0
  80056a:	8622                	mv	a2,s0
  80056c:	00000517          	auipc	a0,0x0
  800570:	1c450513          	addi	a0,a0,452 # 800730 <main+0x128>
  800574:	acdff0ef          	jal	800040 <cprintf>
    if (strlen(cur) >= DEPTH)
  800578:	8522                	mv	a0,s0
  80057a:	fadff0ef          	jal	800526 <strlen>
  80057e:	478d                	li	a5,3
  800580:	00a7f963          	bgeu	a5,a0,800592 <forktree+0x36>

    forkchild(cur, '0');
    forkchild(cur, '1');
  800584:	8522                	mv	a0,s0
}
  800586:	6442                	ld	s0,16(sp)
  800588:	60e2                	ld	ra,24(sp)
    forkchild(cur, '1');
  80058a:	03100593          	li	a1,49
}
  80058e:	6105                	addi	sp,sp,32
    forkchild(cur, '1');
  800590:	a03d                	j	8005be <forkchild>
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800592:	03000713          	li	a4,48
  800596:	86a2                	mv	a3,s0
  800598:	00000617          	auipc	a2,0x0
  80059c:	1b060613          	addi	a2,a2,432 # 800748 <main+0x140>
  8005a0:	4595                	li	a1,5
  8005a2:	0028                	addi	a0,sp,8
  8005a4:	f3dff0ef          	jal	8004e0 <snprintf>
    if (fork() == 0) {
  8005a8:	b37ff0ef          	jal	8000de <fork>
  8005ac:	fd61                	bnez	a0,800584 <forktree+0x28>
        forktree(nxt);
  8005ae:	0028                	addi	a0,sp,8
  8005b0:	fadff0ef          	jal	80055c <forktree>
        yield();
  8005b4:	b2dff0ef          	jal	8000e0 <yield>
        exit(0);
  8005b8:	4501                	li	a0,0
  8005ba:	b0fff0ef          	jal	8000c8 <exit>

00000000008005be <forkchild>:
forkchild(const char *cur, char branch) {
  8005be:	7179                	addi	sp,sp,-48
  8005c0:	f022                	sd	s0,32(sp)
  8005c2:	ec26                	sd	s1,24(sp)
  8005c4:	f406                	sd	ra,40(sp)
  8005c6:	84ae                	mv	s1,a1
  8005c8:	842a                	mv	s0,a0
    if (strlen(cur) >= DEPTH)
  8005ca:	f5dff0ef          	jal	800526 <strlen>
  8005ce:	478d                	li	a5,3
  8005d0:	00a7f763          	bgeu	a5,a0,8005de <forkchild+0x20>
}
  8005d4:	70a2                	ld	ra,40(sp)
  8005d6:	7402                	ld	s0,32(sp)
  8005d8:	64e2                	ld	s1,24(sp)
  8005da:	6145                	addi	sp,sp,48
  8005dc:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005de:	8726                	mv	a4,s1
  8005e0:	86a2                	mv	a3,s0
  8005e2:	00000617          	auipc	a2,0x0
  8005e6:	16660613          	addi	a2,a2,358 # 800748 <main+0x140>
  8005ea:	4595                	li	a1,5
  8005ec:	0028                	addi	a0,sp,8
  8005ee:	ef3ff0ef          	jal	8004e0 <snprintf>
    if (fork() == 0) {
  8005f2:	aedff0ef          	jal	8000de <fork>
  8005f6:	fd79                	bnez	a0,8005d4 <forkchild+0x16>
        forktree(nxt);
  8005f8:	0028                	addi	a0,sp,8
  8005fa:	f63ff0ef          	jal	80055c <forktree>
        yield();
  8005fe:	ae3ff0ef          	jal	8000e0 <yield>
        exit(0);
  800602:	4501                	li	a0,0
  800604:	ac5ff0ef          	jal	8000c8 <exit>

0000000000800608 <main>:

int
main(void) {
  800608:	1141                	addi	sp,sp,-16
    forktree("");
  80060a:	00000517          	auipc	a0,0x0
  80060e:	13650513          	addi	a0,a0,310 # 800740 <main+0x138>
main(void) {
  800612:	e406                	sd	ra,8(sp)
    forktree("");
  800614:	f49ff0ef          	jal	80055c <forktree>
    return 0;
}
  800618:	60a2                	ld	ra,8(sp)
  80061a:	4501                	li	a0,0
  80061c:	0141                	addi	sp,sp,16
  80061e:	8082                	ret
