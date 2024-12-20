
obj/__user_cow.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0d2000ef          	jal	8000f2 <umain>
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
  80002e:	09c000ef          	jal	8000ca <sys_putc>
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
  800068:	104000ef          	jal	80016c <vprintfmt>
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

00000000008000ba <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  8000ba:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  8000bc:	85aa                	mv	a1,a0
  8000be:	450d                	li	a0,3
  8000c0:	bf55                	j	800074 <syscall>

00000000008000c2 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000c2:	4529                	li	a0,10
  8000c4:	bf45                	j	800074 <syscall>

00000000008000c6 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000c6:	4549                	li	a0,18
  8000c8:	b775                	j	800074 <syscall>

00000000008000ca <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000ca:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000cc:	4579                	li	a0,30
  8000ce:	b75d                	j	800074 <syscall>

00000000008000d0 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000d4:	fddff0ef          	jal	8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000d8:	00000517          	auipc	a0,0x0
  8000dc:	50850513          	addi	a0,a0,1288 # 8005e0 <main+0xde>
  8000e0:	f61ff0ef          	jal	800040 <cprintf>
    while (1);
  8000e4:	a001                	j	8000e4 <exit+0x14>

00000000008000e6 <fork>:
}

int
fork(void) {
    return sys_fork();
  8000e6:	bfc1                	j	8000b6 <sys_fork>

00000000008000e8 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  8000e8:	4581                	li	a1,0
  8000ea:	4501                	li	a0,0
  8000ec:	b7f9                	j	8000ba <sys_wait>

00000000008000ee <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000ee:	bfd1                	j	8000c2 <sys_yield>

00000000008000f0 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000f0:	bfd9                	j	8000c6 <sys_getpid>

00000000008000f2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000f2:	1141                	addi	sp,sp,-16
  8000f4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000f6:	40c000ef          	jal	800502 <main>
    exit(ret);
  8000fa:	fd7ff0ef          	jal	8000d0 <exit>

00000000008000fe <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000fe:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800102:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800104:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800108:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80010a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80010e:	f022                	sd	s0,32(sp)
  800110:	ec26                	sd	s1,24(sp)
  800112:	e84a                	sd	s2,16(sp)
  800114:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800116:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80011a:	84aa                	mv	s1,a0
  80011c:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  80011e:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800120:	05067063          	bgeu	a2,a6,800160 <printnum+0x62>
  800124:	e44e                	sd	s3,8(sp)
  800126:	89be                	mv	s3,a5
        while (-- width > 0)
  800128:	4785                	li	a5,1
  80012a:	00e7d763          	bge	a5,a4,800138 <printnum+0x3a>
            putch(padc, putdat);
  80012e:	85ca                	mv	a1,s2
  800130:	854e                	mv	a0,s3
        while (-- width > 0)
  800132:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800134:	9482                	jalr	s1
        while (-- width > 0)
  800136:	fc65                	bnez	s0,80012e <printnum+0x30>
  800138:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80013a:	1a02                	slli	s4,s4,0x20
  80013c:	020a5a13          	srli	s4,s4,0x20
  800140:	00000797          	auipc	a5,0x0
  800144:	4b878793          	addi	a5,a5,1208 # 8005f8 <main+0xf6>
  800148:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80014a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80014c:	0007c503          	lbu	a0,0(a5)
}
  800150:	70a2                	ld	ra,40(sp)
  800152:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800154:	85ca                	mv	a1,s2
  800156:	87a6                	mv	a5,s1
}
  800158:	6942                	ld	s2,16(sp)
  80015a:	64e2                	ld	s1,24(sp)
  80015c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80015e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800160:	03065633          	divu	a2,a2,a6
  800164:	8722                	mv	a4,s0
  800166:	f99ff0ef          	jal	8000fe <printnum>
  80016a:	bfc1                	j	80013a <printnum+0x3c>

000000000080016c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80016c:	7119                	addi	sp,sp,-128
  80016e:	f4a6                	sd	s1,104(sp)
  800170:	f0ca                	sd	s2,96(sp)
  800172:	ecce                	sd	s3,88(sp)
  800174:	e8d2                	sd	s4,80(sp)
  800176:	e4d6                	sd	s5,72(sp)
  800178:	e0da                	sd	s6,64(sp)
  80017a:	f862                	sd	s8,48(sp)
  80017c:	fc86                	sd	ra,120(sp)
  80017e:	f8a2                	sd	s0,112(sp)
  800180:	fc5e                	sd	s7,56(sp)
  800182:	f466                	sd	s9,40(sp)
  800184:	f06a                	sd	s10,32(sp)
  800186:	ec6e                	sd	s11,24(sp)
  800188:	892a                	mv	s2,a0
  80018a:	84ae                	mv	s1,a1
  80018c:	8c32                	mv	s8,a2
  80018e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800190:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800194:	05500b13          	li	s6,85
  800198:	00000a97          	auipc	s5,0x0
  80019c:	670a8a93          	addi	s5,s5,1648 # 800808 <main+0x306>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a0:	000c4503          	lbu	a0,0(s8)
  8001a4:	001c0413          	addi	s0,s8,1
  8001a8:	01350a63          	beq	a0,s3,8001bc <vprintfmt+0x50>
            if (ch == '\0') {
  8001ac:	cd0d                	beqz	a0,8001e6 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001ae:	85a6                	mv	a1,s1
  8001b0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b2:	00044503          	lbu	a0,0(s0)
  8001b6:	0405                	addi	s0,s0,1
  8001b8:	ff351ae3          	bne	a0,s3,8001ac <vprintfmt+0x40>
        width = precision = -1;
  8001bc:	5cfd                	li	s9,-1
  8001be:	8d66                	mv	s10,s9
        char padc = ' ';
  8001c0:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001c4:	4b81                	li	s7,0
  8001c6:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001c8:	00044683          	lbu	a3,0(s0)
  8001cc:	00140c13          	addi	s8,s0,1
  8001d0:	fdd6859b          	addiw	a1,a3,-35
  8001d4:	0ff5f593          	zext.b	a1,a1
  8001d8:	02bb6663          	bltu	s6,a1,800204 <vprintfmt+0x98>
  8001dc:	058a                	slli	a1,a1,0x2
  8001de:	95d6                	add	a1,a1,s5
  8001e0:	4198                	lw	a4,0(a1)
  8001e2:	9756                	add	a4,a4,s5
  8001e4:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e6:	70e6                	ld	ra,120(sp)
  8001e8:	7446                	ld	s0,112(sp)
  8001ea:	74a6                	ld	s1,104(sp)
  8001ec:	7906                	ld	s2,96(sp)
  8001ee:	69e6                	ld	s3,88(sp)
  8001f0:	6a46                	ld	s4,80(sp)
  8001f2:	6aa6                	ld	s5,72(sp)
  8001f4:	6b06                	ld	s6,64(sp)
  8001f6:	7be2                	ld	s7,56(sp)
  8001f8:	7c42                	ld	s8,48(sp)
  8001fa:	7ca2                	ld	s9,40(sp)
  8001fc:	7d02                	ld	s10,32(sp)
  8001fe:	6de2                	ld	s11,24(sp)
  800200:	6109                	addi	sp,sp,128
  800202:	8082                	ret
            putch('%', putdat);
  800204:	85a6                	mv	a1,s1
  800206:	02500513          	li	a0,37
  80020a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80020c:	fff44783          	lbu	a5,-1(s0)
  800210:	02500713          	li	a4,37
  800214:	8c22                	mv	s8,s0
  800216:	f8e785e3          	beq	a5,a4,8001a0 <vprintfmt+0x34>
  80021a:	ffec4783          	lbu	a5,-2(s8)
  80021e:	1c7d                	addi	s8,s8,-1
  800220:	fee79de3          	bne	a5,a4,80021a <vprintfmt+0xae>
  800224:	bfb5                	j	8001a0 <vprintfmt+0x34>
                ch = *fmt;
  800226:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80022a:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80022c:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800230:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800234:	8462                	mv	s0,s8
                ch = *fmt;
  800236:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800238:	02e56463          	bltu	a0,a4,800260 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  80023c:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800240:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800244:	0197073b          	addw	a4,a4,s9
  800248:	0017171b          	slliw	a4,a4,0x1
  80024c:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  80024e:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800252:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800254:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800258:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  80025c:	feb570e3          	bgeu	a0,a1,80023c <vprintfmt+0xd0>
            if (width < 0)
  800260:	f60d54e3          	bgez	s10,8001c8 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800264:	8d66                	mv	s10,s9
  800266:	5cfd                	li	s9,-1
  800268:	b785                	j	8001c8 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80026a:	8db6                	mv	s11,a3
  80026c:	8462                	mv	s0,s8
  80026e:	bfa9                	j	8001c8 <vprintfmt+0x5c>
  800270:	8462                	mv	s0,s8
            altflag = 1;
  800272:	4b85                	li	s7,1
            goto reswitch;
  800274:	bf91                	j	8001c8 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800276:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800278:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80027c:	00c7c463          	blt	a5,a2,800284 <vprintfmt+0x118>
    else if (lflag) {
  800280:	18060763          	beqz	a2,80040e <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  800284:	000a3603          	ld	a2,0(s4)
  800288:	46c1                	li	a3,16
  80028a:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  80028c:	000d879b          	sext.w	a5,s11
  800290:	876a                	mv	a4,s10
  800292:	85a6                	mv	a1,s1
  800294:	854a                	mv	a0,s2
  800296:	e69ff0ef          	jal	8000fe <printnum>
            break;
  80029a:	b719                	j	8001a0 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80029c:	000a2503          	lw	a0,0(s4)
  8002a0:	85a6                	mv	a1,s1
  8002a2:	0a21                	addi	s4,s4,8
  8002a4:	9902                	jalr	s2
            break;
  8002a6:	bded                	j	8001a0 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002a8:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002aa:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002ae:	00c7c463          	blt	a5,a2,8002b6 <vprintfmt+0x14a>
    else if (lflag) {
  8002b2:	14060963          	beqz	a2,800404 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  8002b6:	000a3603          	ld	a2,0(s4)
  8002ba:	46a9                	li	a3,10
  8002bc:	8a3a                	mv	s4,a4
  8002be:	b7f9                	j	80028c <vprintfmt+0x120>
            putch('0', putdat);
  8002c0:	85a6                	mv	a1,s1
  8002c2:	03000513          	li	a0,48
  8002c6:	9902                	jalr	s2
            putch('x', putdat);
  8002c8:	85a6                	mv	a1,s1
  8002ca:	07800513          	li	a0,120
  8002ce:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d0:	000a3603          	ld	a2,0(s4)
            goto number;
  8002d4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d6:	0a21                	addi	s4,s4,8
            goto number;
  8002d8:	bf55                	j	80028c <vprintfmt+0x120>
            putch(ch, putdat);
  8002da:	85a6                	mv	a1,s1
  8002dc:	02500513          	li	a0,37
  8002e0:	9902                	jalr	s2
            break;
  8002e2:	bd7d                	j	8001a0 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002e4:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002e8:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002ea:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002ec:	bf95                	j	800260 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002ee:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002f0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002f4:	00c7c463          	blt	a5,a2,8002fc <vprintfmt+0x190>
    else if (lflag) {
  8002f8:	10060163          	beqz	a2,8003fa <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  8002fc:	000a3603          	ld	a2,0(s4)
  800300:	46a1                	li	a3,8
  800302:	8a3a                	mv	s4,a4
  800304:	b761                	j	80028c <vprintfmt+0x120>
            if (width < 0)
  800306:	87ea                	mv	a5,s10
  800308:	000d5363          	bgez	s10,80030e <vprintfmt+0x1a2>
  80030c:	4781                	li	a5,0
  80030e:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800312:	8462                	mv	s0,s8
            goto reswitch;
  800314:	bd55                	j	8001c8 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800316:	000a3703          	ld	a4,0(s4)
  80031a:	12070b63          	beqz	a4,800450 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  80031e:	0da05563          	blez	s10,8003e8 <vprintfmt+0x27c>
  800322:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800326:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  80032a:	14fd9a63          	bne	s11,a5,80047e <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032e:	00074783          	lbu	a5,0(a4)
  800332:	0007851b          	sext.w	a0,a5
  800336:	c785                	beqz	a5,80035e <vprintfmt+0x1f2>
  800338:	5dfd                	li	s11,-1
  80033a:	000cc563          	bltz	s9,800344 <vprintfmt+0x1d8>
  80033e:	3cfd                	addiw	s9,s9,-1
  800340:	01bc8d63          	beq	s9,s11,80035a <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  800344:	0c0b9a63          	bnez	s7,800418 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  800348:	85a6                	mv	a1,s1
  80034a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034c:	00044783          	lbu	a5,0(s0)
  800350:	0405                	addi	s0,s0,1
  800352:	3d7d                	addiw	s10,s10,-1
  800354:	0007851b          	sext.w	a0,a5
  800358:	f3ed                	bnez	a5,80033a <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  80035a:	01a05963          	blez	s10,80036c <vprintfmt+0x200>
                putch(' ', putdat);
  80035e:	85a6                	mv	a1,s1
  800360:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800364:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800366:	9902                	jalr	s2
            for (; width > 0; width --) {
  800368:	fe0d1be3          	bnez	s10,80035e <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  80036c:	0a21                	addi	s4,s4,8
  80036e:	bd0d                	j	8001a0 <vprintfmt+0x34>
    if (lflag >= 2) {
  800370:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800372:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800376:	00c7c363          	blt	a5,a2,80037c <vprintfmt+0x210>
    else if (lflag) {
  80037a:	c625                	beqz	a2,8003e2 <vprintfmt+0x276>
        return va_arg(*ap, long);
  80037c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800380:	0a044f63          	bltz	s0,80043e <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  800384:	8622                	mv	a2,s0
  800386:	8a5e                	mv	s4,s7
  800388:	46a9                	li	a3,10
  80038a:	b709                	j	80028c <vprintfmt+0x120>
            if (err < 0) {
  80038c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800390:	4661                	li	a2,24
            if (err < 0) {
  800392:	41f7d71b          	sraiw	a4,a5,0x1f
  800396:	8fb9                	xor	a5,a5,a4
  800398:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80039c:	02d64663          	blt	a2,a3,8003c8 <vprintfmt+0x25c>
  8003a0:	00000797          	auipc	a5,0x0
  8003a4:	5c078793          	addi	a5,a5,1472 # 800960 <error_string>
  8003a8:	00369713          	slli	a4,a3,0x3
  8003ac:	97ba                	add	a5,a5,a4
  8003ae:	639c                	ld	a5,0(a5)
  8003b0:	cf81                	beqz	a5,8003c8 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  8003b2:	86be                	mv	a3,a5
  8003b4:	00000617          	auipc	a2,0x0
  8003b8:	27460613          	addi	a2,a2,628 # 800628 <main+0x126>
  8003bc:	85a6                	mv	a1,s1
  8003be:	854a                	mv	a0,s2
  8003c0:	0f4000ef          	jal	8004b4 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c4:	0a21                	addi	s4,s4,8
  8003c6:	bbe9                	j	8001a0 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003c8:	00000617          	auipc	a2,0x0
  8003cc:	25060613          	addi	a2,a2,592 # 800618 <main+0x116>
  8003d0:	85a6                	mv	a1,s1
  8003d2:	854a                	mv	a0,s2
  8003d4:	0e0000ef          	jal	8004b4 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003d8:	0a21                	addi	s4,s4,8
  8003da:	b3d9                	j	8001a0 <vprintfmt+0x34>
            lflag ++;
  8003dc:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003de:	8462                	mv	s0,s8
            goto reswitch;
  8003e0:	b3e5                	j	8001c8 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003e2:	000a2403          	lw	s0,0(s4)
  8003e6:	bf69                	j	800380 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e8:	00074783          	lbu	a5,0(a4)
  8003ec:	0007851b          	sext.w	a0,a5
  8003f0:	dfb5                	beqz	a5,80036c <vprintfmt+0x200>
  8003f2:	00170413          	addi	s0,a4,1
  8003f6:	5dfd                	li	s11,-1
  8003f8:	b789                	j	80033a <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  8003fa:	000a6603          	lwu	a2,0(s4)
  8003fe:	46a1                	li	a3,8
  800400:	8a3a                	mv	s4,a4
  800402:	b569                	j	80028c <vprintfmt+0x120>
  800404:	000a6603          	lwu	a2,0(s4)
  800408:	46a9                	li	a3,10
  80040a:	8a3a                	mv	s4,a4
  80040c:	b541                	j	80028c <vprintfmt+0x120>
  80040e:	000a6603          	lwu	a2,0(s4)
  800412:	46c1                	li	a3,16
  800414:	8a3a                	mv	s4,a4
  800416:	bd9d                	j	80028c <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800418:	3781                	addiw	a5,a5,-32
  80041a:	05e00713          	li	a4,94
  80041e:	f2f775e3          	bgeu	a4,a5,800348 <vprintfmt+0x1dc>
                    putch('?', putdat);
  800422:	03f00513          	li	a0,63
  800426:	85a6                	mv	a1,s1
  800428:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80042a:	00044783          	lbu	a5,0(s0)
  80042e:	0405                	addi	s0,s0,1
  800430:	3d7d                	addiw	s10,s10,-1
  800432:	0007851b          	sext.w	a0,a5
  800436:	d395                	beqz	a5,80035a <vprintfmt+0x1ee>
  800438:	f00cd3e3          	bgez	s9,80033e <vprintfmt+0x1d2>
  80043c:	bff1                	j	800418 <vprintfmt+0x2ac>
                putch('-', putdat);
  80043e:	85a6                	mv	a1,s1
  800440:	02d00513          	li	a0,45
  800444:	9902                	jalr	s2
                num = -(long long)num;
  800446:	40800633          	neg	a2,s0
  80044a:	8a5e                	mv	s4,s7
  80044c:	46a9                	li	a3,10
  80044e:	bd3d                	j	80028c <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800450:	01a05663          	blez	s10,80045c <vprintfmt+0x2f0>
  800454:	02d00793          	li	a5,45
  800458:	00fd9b63          	bne	s11,a5,80046e <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80045c:	02800793          	li	a5,40
  800460:	853e                	mv	a0,a5
  800462:	00000417          	auipc	s0,0x0
  800466:	1af40413          	addi	s0,s0,431 # 800611 <main+0x10f>
  80046a:	5dfd                	li	s11,-1
  80046c:	b5f9                	j	80033a <vprintfmt+0x1ce>
  80046e:	00000417          	auipc	s0,0x0
  800472:	1a340413          	addi	s0,s0,419 # 800611 <main+0x10f>
                p = "(null)";
  800476:	00000717          	auipc	a4,0x0
  80047a:	19a70713          	addi	a4,a4,410 # 800610 <main+0x10e>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047e:	853a                	mv	a0,a4
  800480:	85e6                	mv	a1,s9
  800482:	e43a                	sd	a4,8(sp)
  800484:	050000ef          	jal	8004d4 <strnlen>
  800488:	40ad0d3b          	subw	s10,s10,a0
  80048c:	6722                	ld	a4,8(sp)
  80048e:	01a05b63          	blez	s10,8004a4 <vprintfmt+0x338>
                    putch(padc, putdat);
  800492:	2d81                	sext.w	s11,s11
  800494:	85a6                	mv	a1,s1
  800496:	856e                	mv	a0,s11
  800498:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049a:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  80049c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	6722                	ld	a4,8(sp)
  8004a0:	fe0d1ae3          	bnez	s10,800494 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a4:	00074783          	lbu	a5,0(a4)
  8004a8:	0007851b          	sext.w	a0,a5
  8004ac:	ec0780e3          	beqz	a5,80036c <vprintfmt+0x200>
  8004b0:	5dfd                	li	s11,-1
  8004b2:	b561                	j	80033a <vprintfmt+0x1ce>

00000000008004b4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ba:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004bc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004be:	ec06                	sd	ra,24(sp)
  8004c0:	f83a                	sd	a4,48(sp)
  8004c2:	fc3e                	sd	a5,56(sp)
  8004c4:	e0c2                	sd	a6,64(sp)
  8004c6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ca:	ca3ff0ef          	jal	80016c <vprintfmt>
}
  8004ce:	60e2                	ld	ra,24(sp)
  8004d0:	6161                	addi	sp,sp,80
  8004d2:	8082                	ret

00000000008004d4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004d4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004d6:	e589                	bnez	a1,8004e0 <strnlen+0xc>
  8004d8:	a811                	j	8004ec <strnlen+0x18>
        cnt ++;
  8004da:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004dc:	00f58863          	beq	a1,a5,8004ec <strnlen+0x18>
  8004e0:	00f50733          	add	a4,a0,a5
  8004e4:	00074703          	lbu	a4,0(a4)
  8004e8:	fb6d                	bnez	a4,8004da <strnlen+0x6>
  8004ea:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004ec:	852e                	mv	a0,a1
  8004ee:	8082                	ret

00000000008004f0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
  8004f0:	ca01                	beqz	a2,800500 <memset+0x10>
  8004f2:	962a                	add	a2,a2,a0
    char *p = s;
  8004f4:	87aa                	mv	a5,a0
        *p ++ = c;
  8004f6:	0785                	addi	a5,a5,1
  8004f8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
  8004fc:	fef61de3          	bne	a2,a5,8004f6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800500:	8082                	ret

0000000000800502 <main>:
#define TEST_SIZE (4 * PAGE_SIZE)  // 测试4个页面
char buffer[TEST_SIZE]={'A','A'};

//子进程修改，父进程查看
int
main(void) {
  800502:	1141                	addi	sp,sp,-16
    // 1. 分配并初始化测试内存
    memset(buffer, 'A', TEST_SIZE);
  800504:	6611                	lui	a2,0x4
  800506:	04100593          	li	a1,65
  80050a:	00001517          	auipc	a0,0x1
  80050e:	af650513          	addi	a0,a0,-1290 # 801000 <buffer>
main(void) {
  800512:	e406                	sd	ra,8(sp)
    memset(buffer, 'A', TEST_SIZE);
  800514:	fddff0ef          	jal	8004f0 <memset>
    cprintf("Parent %04x: Initialize buffer with 'A'\n", getpid());
  800518:	bd9ff0ef          	jal	8000f0 <getpid>
  80051c:	85aa                	mv	a1,a0
  80051e:	00000517          	auipc	a0,0x0
  800522:	1d250513          	addi	a0,a0,466 # 8006f0 <main+0x1ee>
  800526:	b1bff0ef          	jal	800040 <cprintf>
    
    // 2. 创建子进程
    int pid = fork();
  80052a:	bbdff0ef          	jal	8000e6 <fork>
    if (pid == 0) {
  80052e:	c139                	beqz	a0,800574 <main+0x72>
        
        exit(0);
    }
    else {
        // 父进程
        yield();  // 让子进程先运行
  800530:	bbfff0ef          	jal	8000ee <yield>
        
        // 检查原始内存内容
        cprintf("Parent %04x: My first byte is still: %c\n", 
  800534:	bbdff0ef          	jal	8000f0 <getpid>
  800538:	00001617          	auipc	a2,0x1
  80053c:	ac864603          	lbu	a2,-1336(a2) # 801000 <buffer>
  800540:	85aa                	mv	a1,a0
  800542:	00000517          	auipc	a0,0x0
  800546:	26650513          	addi	a0,a0,614 # 8007a8 <main+0x2a6>
  80054a:	af7ff0ef          	jal	800040 <cprintf>
                getpid(), buffer[0]);
        cprintf("Parent %04x: Page 2 first byte is still: %c\n", 
  80054e:	ba3ff0ef          	jal	8000f0 <getpid>
  800552:	00002617          	auipc	a2,0x2
  800556:	aae64603          	lbu	a2,-1362(a2) # 802000 <buffer+0x1000>
  80055a:	85aa                	mv	a1,a0
  80055c:	00000517          	auipc	a0,0x0
  800560:	27c50513          	addi	a0,a0,636 # 8007d8 <main+0x2d6>
  800564:	addff0ef          	jal	800040 <cprintf>
                getpid(), buffer[PAGE_SIZE]);
        
        wait();
  800568:	b81ff0ef          	jal	8000e8 <wait>
    }
    return 0;
  80056c:	60a2                	ld	ra,8(sp)
  80056e:	4501                	li	a0,0
  800570:	0141                	addi	sp,sp,16
  800572:	8082                	ret
        cprintf("Child  %04x: Original first byte: %c\n", getpid(), buffer[0]);
  800574:	b7dff0ef          	jal	8000f0 <getpid>
  800578:	00001617          	auipc	a2,0x1
  80057c:	a8864603          	lbu	a2,-1400(a2) # 801000 <buffer>
  800580:	85aa                	mv	a1,a0
  800582:	00000517          	auipc	a0,0x0
  800586:	19e50513          	addi	a0,a0,414 # 800720 <main+0x21e>
  80058a:	ab7ff0ef          	jal	800040 <cprintf>
        buffer[0] = 'B';
  80058e:	04200793          	li	a5,66
  800592:	00001717          	auipc	a4,0x1
  800596:	a6f70723          	sb	a5,-1426(a4) # 801000 <buffer>
        cprintf("Child  %04x: Modified first byte to: %c\n", getpid(), buffer[0]);
  80059a:	b57ff0ef          	jal	8000f0 <getpid>
  80059e:	00001617          	auipc	a2,0x1
  8005a2:	a6264603          	lbu	a2,-1438(a2) # 801000 <buffer>
  8005a6:	85aa                	mv	a1,a0
  8005a8:	00000517          	auipc	a0,0x0
  8005ac:	1a050513          	addi	a0,a0,416 # 800748 <main+0x246>
  8005b0:	a91ff0ef          	jal	800040 <cprintf>
        buffer[PAGE_SIZE] = 'C';
  8005b4:	04300793          	li	a5,67
  8005b8:	00002717          	auipc	a4,0x2
  8005bc:	a4f70423          	sb	a5,-1464(a4) # 802000 <buffer+0x1000>
        cprintf("Child  %04x: Modified page 2 first byte to: %c\n", 
  8005c0:	b31ff0ef          	jal	8000f0 <getpid>
  8005c4:	00002617          	auipc	a2,0x2
  8005c8:	a3c64603          	lbu	a2,-1476(a2) # 802000 <buffer+0x1000>
  8005cc:	85aa                	mv	a1,a0
  8005ce:	00000517          	auipc	a0,0x0
  8005d2:	1aa50513          	addi	a0,a0,426 # 800778 <main+0x276>
  8005d6:	a6bff0ef          	jal	800040 <cprintf>
        exit(0);
  8005da:	4501                	li	a0,0
  8005dc:	af5ff0ef          	jal	8000d0 <exit>
