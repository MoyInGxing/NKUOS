
obj/__user_pgdir.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0be000ef          	jal	8000de <umain>
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
  800068:	0f0000ef          	jal	800158 <vprintfmt>
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

00000000008000c0 <sys_pgdir>:
}

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
  8000c0:	457d                	li	a0,31
  8000c2:	bf4d                	j	800074 <syscall>

00000000008000c4 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c4:	1141                	addi	sp,sp,-16
  8000c6:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c8:	fe9ff0ef          	jal	8000b0 <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000cc:	00000517          	auipc	a0,0x0
  8000d0:	44450513          	addi	a0,a0,1092 # 800510 <main+0x34>
  8000d4:	f6dff0ef          	jal	800040 <cprintf>
    while (1);
  8000d8:	a001                	j	8000d8 <exit+0x14>

00000000008000da <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000da:	bff1                	j	8000b6 <sys_getpid>

00000000008000dc <print_pgdir>:
}

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    sys_pgdir();
  8000dc:	b7d5                	j	8000c0 <sys_pgdir>

00000000008000de <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000de:	1141                	addi	sp,sp,-16
  8000e0:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e2:	3fa000ef          	jal	8004dc <main>
    exit(ret);
  8000e6:	fdfff0ef          	jal	8000c4 <exit>

00000000008000ea <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	f022                	sd	s0,32(sp)
  8000fc:	ec26                	sd	s1,24(sp)
  8000fe:	e84a                	sd	s2,16(sp)
  800100:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800102:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800106:	84aa                	mv	s1,a0
  800108:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  80010a:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80010c:	05067063          	bgeu	a2,a6,80014c <printnum+0x62>
  800110:	e44e                	sd	s3,8(sp)
  800112:	89be                	mv	s3,a5
        while (-- width > 0)
  800114:	4785                	li	a5,1
  800116:	00e7d763          	bge	a5,a4,800124 <printnum+0x3a>
            putch(padc, putdat);
  80011a:	85ca                	mv	a1,s2
  80011c:	854e                	mv	a0,s3
        while (-- width > 0)
  80011e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800120:	9482                	jalr	s1
        while (-- width > 0)
  800122:	fc65                	bnez	s0,80011a <printnum+0x30>
  800124:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800126:	1a02                	slli	s4,s4,0x20
  800128:	020a5a13          	srli	s4,s4,0x20
  80012c:	00000797          	auipc	a5,0x0
  800130:	3fc78793          	addi	a5,a5,1020 # 800528 <main+0x4c>
  800134:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800136:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800138:	0007c503          	lbu	a0,0(a5)
}
  80013c:	70a2                	ld	ra,40(sp)
  80013e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800140:	85ca                	mv	a1,s2
  800142:	87a6                	mv	a5,s1
}
  800144:	6942                	ld	s2,16(sp)
  800146:	64e2                	ld	s1,24(sp)
  800148:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80014a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80014c:	03065633          	divu	a2,a2,a6
  800150:	8722                	mv	a4,s0
  800152:	f99ff0ef          	jal	8000ea <printnum>
  800156:	bfc1                	j	800126 <printnum+0x3c>

0000000000800158 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800158:	7119                	addi	sp,sp,-128
  80015a:	f4a6                	sd	s1,104(sp)
  80015c:	f0ca                	sd	s2,96(sp)
  80015e:	ecce                	sd	s3,88(sp)
  800160:	e8d2                	sd	s4,80(sp)
  800162:	e4d6                	sd	s5,72(sp)
  800164:	e0da                	sd	s6,64(sp)
  800166:	f862                	sd	s8,48(sp)
  800168:	fc86                	sd	ra,120(sp)
  80016a:	f8a2                	sd	s0,112(sp)
  80016c:	fc5e                	sd	s7,56(sp)
  80016e:	f466                	sd	s9,40(sp)
  800170:	f06a                	sd	s10,32(sp)
  800172:	ec6e                	sd	s11,24(sp)
  800174:	892a                	mv	s2,a0
  800176:	84ae                	mv	s1,a1
  800178:	8c32                	mv	s8,a2
  80017a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80017c:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800180:	05500b13          	li	s6,85
  800184:	00000a97          	auipc	s5,0x0
  800188:	4cca8a93          	addi	s5,s5,1228 # 800650 <main+0x174>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018c:	000c4503          	lbu	a0,0(s8)
  800190:	001c0413          	addi	s0,s8,1
  800194:	01350a63          	beq	a0,s3,8001a8 <vprintfmt+0x50>
            if (ch == '\0') {
  800198:	cd0d                	beqz	a0,8001d2 <vprintfmt+0x7a>
            putch(ch, putdat);
  80019a:	85a6                	mv	a1,s1
  80019c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019e:	00044503          	lbu	a0,0(s0)
  8001a2:	0405                	addi	s0,s0,1
  8001a4:	ff351ae3          	bne	a0,s3,800198 <vprintfmt+0x40>
        width = precision = -1;
  8001a8:	5cfd                	li	s9,-1
  8001aa:	8d66                	mv	s10,s9
        char padc = ' ';
  8001ac:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001b0:	4b81                	li	s7,0
  8001b2:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001b4:	00044683          	lbu	a3,0(s0)
  8001b8:	00140c13          	addi	s8,s0,1
  8001bc:	fdd6859b          	addiw	a1,a3,-35
  8001c0:	0ff5f593          	zext.b	a1,a1
  8001c4:	02bb6663          	bltu	s6,a1,8001f0 <vprintfmt+0x98>
  8001c8:	058a                	slli	a1,a1,0x2
  8001ca:	95d6                	add	a1,a1,s5
  8001cc:	4198                	lw	a4,0(a1)
  8001ce:	9756                	add	a4,a4,s5
  8001d0:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001d2:	70e6                	ld	ra,120(sp)
  8001d4:	7446                	ld	s0,112(sp)
  8001d6:	74a6                	ld	s1,104(sp)
  8001d8:	7906                	ld	s2,96(sp)
  8001da:	69e6                	ld	s3,88(sp)
  8001dc:	6a46                	ld	s4,80(sp)
  8001de:	6aa6                	ld	s5,72(sp)
  8001e0:	6b06                	ld	s6,64(sp)
  8001e2:	7be2                	ld	s7,56(sp)
  8001e4:	7c42                	ld	s8,48(sp)
  8001e6:	7ca2                	ld	s9,40(sp)
  8001e8:	7d02                	ld	s10,32(sp)
  8001ea:	6de2                	ld	s11,24(sp)
  8001ec:	6109                	addi	sp,sp,128
  8001ee:	8082                	ret
            putch('%', putdat);
  8001f0:	85a6                	mv	a1,s1
  8001f2:	02500513          	li	a0,37
  8001f6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001f8:	fff44783          	lbu	a5,-1(s0)
  8001fc:	02500713          	li	a4,37
  800200:	8c22                	mv	s8,s0
  800202:	f8e785e3          	beq	a5,a4,80018c <vprintfmt+0x34>
  800206:	ffec4783          	lbu	a5,-2(s8)
  80020a:	1c7d                	addi	s8,s8,-1
  80020c:	fee79de3          	bne	a5,a4,800206 <vprintfmt+0xae>
  800210:	bfb5                	j	80018c <vprintfmt+0x34>
                ch = *fmt;
  800212:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800216:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800218:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80021c:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	8462                	mv	s0,s8
                ch = *fmt;
  800222:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800224:	02e56463          	bltu	a0,a4,80024c <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  800228:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80022c:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800230:	0197073b          	addw	a4,a4,s9
  800234:	0017171b          	slliw	a4,a4,0x1
  800238:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  80023a:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80023e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800240:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800244:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  800248:	feb570e3          	bgeu	a0,a1,800228 <vprintfmt+0xd0>
            if (width < 0)
  80024c:	f60d54e3          	bgez	s10,8001b4 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800250:	8d66                	mv	s10,s9
  800252:	5cfd                	li	s9,-1
  800254:	b785                	j	8001b4 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	8db6                	mv	s11,a3
  800258:	8462                	mv	s0,s8
  80025a:	bfa9                	j	8001b4 <vprintfmt+0x5c>
  80025c:	8462                	mv	s0,s8
            altflag = 1;
  80025e:	4b85                	li	s7,1
            goto reswitch;
  800260:	bf91                	j	8001b4 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800262:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800264:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800268:	00c7c463          	blt	a5,a2,800270 <vprintfmt+0x118>
    else if (lflag) {
  80026c:	18060763          	beqz	a2,8003fa <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  800270:	000a3603          	ld	a2,0(s4)
  800274:	46c1                	li	a3,16
  800276:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  800278:	000d879b          	sext.w	a5,s11
  80027c:	876a                	mv	a4,s10
  80027e:	85a6                	mv	a1,s1
  800280:	854a                	mv	a0,s2
  800282:	e69ff0ef          	jal	8000ea <printnum>
            break;
  800286:	b719                	j	80018c <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800288:	000a2503          	lw	a0,0(s4)
  80028c:	85a6                	mv	a1,s1
  80028e:	0a21                	addi	s4,s4,8
  800290:	9902                	jalr	s2
            break;
  800292:	bded                	j	80018c <vprintfmt+0x34>
    if (lflag >= 2) {
  800294:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800296:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80029a:	00c7c463          	blt	a5,a2,8002a2 <vprintfmt+0x14a>
    else if (lflag) {
  80029e:	14060963          	beqz	a2,8003f0 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  8002a2:	000a3603          	ld	a2,0(s4)
  8002a6:	46a9                	li	a3,10
  8002a8:	8a3a                	mv	s4,a4
  8002aa:	b7f9                	j	800278 <vprintfmt+0x120>
            putch('0', putdat);
  8002ac:	85a6                	mv	a1,s1
  8002ae:	03000513          	li	a0,48
  8002b2:	9902                	jalr	s2
            putch('x', putdat);
  8002b4:	85a6                	mv	a1,s1
  8002b6:	07800513          	li	a0,120
  8002ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002bc:	000a3603          	ld	a2,0(s4)
            goto number;
  8002c0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c2:	0a21                	addi	s4,s4,8
            goto number;
  8002c4:	bf55                	j	800278 <vprintfmt+0x120>
            putch(ch, putdat);
  8002c6:	85a6                	mv	a1,s1
  8002c8:	02500513          	li	a0,37
  8002cc:	9902                	jalr	s2
            break;
  8002ce:	bd7d                	j	80018c <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002d0:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002d4:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002d6:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002d8:	bf95                	j	80024c <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002da:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002dc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002e0:	00c7c463          	blt	a5,a2,8002e8 <vprintfmt+0x190>
    else if (lflag) {
  8002e4:	10060163          	beqz	a2,8003e6 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  8002e8:	000a3603          	ld	a2,0(s4)
  8002ec:	46a1                	li	a3,8
  8002ee:	8a3a                	mv	s4,a4
  8002f0:	b761                	j	800278 <vprintfmt+0x120>
            if (width < 0)
  8002f2:	87ea                	mv	a5,s10
  8002f4:	000d5363          	bgez	s10,8002fa <vprintfmt+0x1a2>
  8002f8:	4781                	li	a5,0
  8002fa:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  8002fe:	8462                	mv	s0,s8
            goto reswitch;
  800300:	bd55                	j	8001b4 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800302:	000a3703          	ld	a4,0(s4)
  800306:	12070b63          	beqz	a4,80043c <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  80030a:	0da05563          	blez	s10,8003d4 <vprintfmt+0x27c>
  80030e:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800312:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  800316:	14fd9a63          	bne	s11,a5,80046a <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031a:	00074783          	lbu	a5,0(a4)
  80031e:	0007851b          	sext.w	a0,a5
  800322:	c785                	beqz	a5,80034a <vprintfmt+0x1f2>
  800324:	5dfd                	li	s11,-1
  800326:	000cc563          	bltz	s9,800330 <vprintfmt+0x1d8>
  80032a:	3cfd                	addiw	s9,s9,-1
  80032c:	01bc8d63          	beq	s9,s11,800346 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  800330:	0c0b9a63          	bnez	s7,800404 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  800334:	85a6                	mv	a1,s1
  800336:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800338:	00044783          	lbu	a5,0(s0)
  80033c:	0405                	addi	s0,s0,1
  80033e:	3d7d                	addiw	s10,s10,-1
  800340:	0007851b          	sext.w	a0,a5
  800344:	f3ed                	bnez	a5,800326 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  800346:	01a05963          	blez	s10,800358 <vprintfmt+0x200>
                putch(' ', putdat);
  80034a:	85a6                	mv	a1,s1
  80034c:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800350:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800352:	9902                	jalr	s2
            for (; width > 0; width --) {
  800354:	fe0d1be3          	bnez	s10,80034a <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  800358:	0a21                	addi	s4,s4,8
  80035a:	bd0d                	j	80018c <vprintfmt+0x34>
    if (lflag >= 2) {
  80035c:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80035e:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800362:	00c7c363          	blt	a5,a2,800368 <vprintfmt+0x210>
    else if (lflag) {
  800366:	c625                	beqz	a2,8003ce <vprintfmt+0x276>
        return va_arg(*ap, long);
  800368:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80036c:	0a044f63          	bltz	s0,80042a <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  800370:	8622                	mv	a2,s0
  800372:	8a5e                	mv	s4,s7
  800374:	46a9                	li	a3,10
  800376:	b709                	j	800278 <vprintfmt+0x120>
            if (err < 0) {
  800378:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80037c:	4661                	li	a2,24
            if (err < 0) {
  80037e:	41f7d71b          	sraiw	a4,a5,0x1f
  800382:	8fb9                	xor	a5,a5,a4
  800384:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800388:	02d64663          	blt	a2,a3,8003b4 <vprintfmt+0x25c>
  80038c:	00000797          	auipc	a5,0x0
  800390:	41c78793          	addi	a5,a5,1052 # 8007a8 <error_string>
  800394:	00369713          	slli	a4,a3,0x3
  800398:	97ba                	add	a5,a5,a4
  80039a:	639c                	ld	a5,0(a5)
  80039c:	cf81                	beqz	a5,8003b4 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  80039e:	86be                	mv	a3,a5
  8003a0:	00000617          	auipc	a2,0x0
  8003a4:	1c060613          	addi	a2,a2,448 # 800560 <main+0x84>
  8003a8:	85a6                	mv	a1,s1
  8003aa:	854a                	mv	a0,s2
  8003ac:	0f4000ef          	jal	8004a0 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b0:	0a21                	addi	s4,s4,8
  8003b2:	bbe9                	j	80018c <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003b4:	00000617          	auipc	a2,0x0
  8003b8:	19c60613          	addi	a2,a2,412 # 800550 <main+0x74>
  8003bc:	85a6                	mv	a1,s1
  8003be:	854a                	mv	a0,s2
  8003c0:	0e0000ef          	jal	8004a0 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c4:	0a21                	addi	s4,s4,8
  8003c6:	b3d9                	j	80018c <vprintfmt+0x34>
            lflag ++;
  8003c8:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003ca:	8462                	mv	s0,s8
            goto reswitch;
  8003cc:	b3e5                	j	8001b4 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003ce:	000a2403          	lw	s0,0(s4)
  8003d2:	bf69                	j	80036c <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003d4:	00074783          	lbu	a5,0(a4)
  8003d8:	0007851b          	sext.w	a0,a5
  8003dc:	dfb5                	beqz	a5,800358 <vprintfmt+0x200>
  8003de:	00170413          	addi	s0,a4,1
  8003e2:	5dfd                	li	s11,-1
  8003e4:	b789                	j	800326 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  8003e6:	000a6603          	lwu	a2,0(s4)
  8003ea:	46a1                	li	a3,8
  8003ec:	8a3a                	mv	s4,a4
  8003ee:	b569                	j	800278 <vprintfmt+0x120>
  8003f0:	000a6603          	lwu	a2,0(s4)
  8003f4:	46a9                	li	a3,10
  8003f6:	8a3a                	mv	s4,a4
  8003f8:	b541                	j	800278 <vprintfmt+0x120>
  8003fa:	000a6603          	lwu	a2,0(s4)
  8003fe:	46c1                	li	a3,16
  800400:	8a3a                	mv	s4,a4
  800402:	bd9d                	j	800278 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800404:	3781                	addiw	a5,a5,-32
  800406:	05e00713          	li	a4,94
  80040a:	f2f775e3          	bgeu	a4,a5,800334 <vprintfmt+0x1dc>
                    putch('?', putdat);
  80040e:	03f00513          	li	a0,63
  800412:	85a6                	mv	a1,s1
  800414:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800416:	00044783          	lbu	a5,0(s0)
  80041a:	0405                	addi	s0,s0,1
  80041c:	3d7d                	addiw	s10,s10,-1
  80041e:	0007851b          	sext.w	a0,a5
  800422:	d395                	beqz	a5,800346 <vprintfmt+0x1ee>
  800424:	f00cd3e3          	bgez	s9,80032a <vprintfmt+0x1d2>
  800428:	bff1                	j	800404 <vprintfmt+0x2ac>
                putch('-', putdat);
  80042a:	85a6                	mv	a1,s1
  80042c:	02d00513          	li	a0,45
  800430:	9902                	jalr	s2
                num = -(long long)num;
  800432:	40800633          	neg	a2,s0
  800436:	8a5e                	mv	s4,s7
  800438:	46a9                	li	a3,10
  80043a:	bd3d                	j	800278 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80043c:	01a05663          	blez	s10,800448 <vprintfmt+0x2f0>
  800440:	02d00793          	li	a5,45
  800444:	00fd9b63          	bne	s11,a5,80045a <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800448:	02800793          	li	a5,40
  80044c:	853e                	mv	a0,a5
  80044e:	00000417          	auipc	s0,0x0
  800452:	0f340413          	addi	s0,s0,243 # 800541 <main+0x65>
  800456:	5dfd                	li	s11,-1
  800458:	b5f9                	j	800326 <vprintfmt+0x1ce>
  80045a:	00000417          	auipc	s0,0x0
  80045e:	0e740413          	addi	s0,s0,231 # 800541 <main+0x65>
                p = "(null)";
  800462:	00000717          	auipc	a4,0x0
  800466:	0de70713          	addi	a4,a4,222 # 800540 <main+0x64>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046a:	853a                	mv	a0,a4
  80046c:	85e6                	mv	a1,s9
  80046e:	e43a                	sd	a4,8(sp)
  800470:	050000ef          	jal	8004c0 <strnlen>
  800474:	40ad0d3b          	subw	s10,s10,a0
  800478:	6722                	ld	a4,8(sp)
  80047a:	01a05b63          	blez	s10,800490 <vprintfmt+0x338>
                    putch(padc, putdat);
  80047e:	2d81                	sext.w	s11,s11
  800480:	85a6                	mv	a1,s1
  800482:	856e                	mv	a0,s11
  800484:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800486:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800488:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048a:	6722                	ld	a4,8(sp)
  80048c:	fe0d1ae3          	bnez	s10,800480 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800490:	00074783          	lbu	a5,0(a4)
  800494:	0007851b          	sext.w	a0,a5
  800498:	ec0780e3          	beqz	a5,800358 <vprintfmt+0x200>
  80049c:	5dfd                	li	s11,-1
  80049e:	b561                	j	800326 <vprintfmt+0x1ce>

00000000008004a0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004a2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004a8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004aa:	ec06                	sd	ra,24(sp)
  8004ac:	f83a                	sd	a4,48(sp)
  8004ae:	fc3e                	sd	a5,56(sp)
  8004b0:	e0c2                	sd	a6,64(sp)
  8004b2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004b4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b6:	ca3ff0ef          	jal	800158 <vprintfmt>
}
  8004ba:	60e2                	ld	ra,24(sp)
  8004bc:	6161                	addi	sp,sp,80
  8004be:	8082                	ret

00000000008004c0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004c0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004c2:	e589                	bnez	a1,8004cc <strnlen+0xc>
  8004c4:	a811                	j	8004d8 <strnlen+0x18>
        cnt ++;
  8004c6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004c8:	00f58863          	beq	a1,a5,8004d8 <strnlen+0x18>
  8004cc:	00f50733          	add	a4,a0,a5
  8004d0:	00074703          	lbu	a4,0(a4)
  8004d4:	fb6d                	bnez	a4,8004c6 <strnlen+0x6>
  8004d6:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004d8:	852e                	mv	a0,a1
  8004da:	8082                	ret

00000000008004dc <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004dc:	1141                	addi	sp,sp,-16
  8004de:	e406                	sd	ra,8(sp)
    cprintf("I am %d, print pgdir.\n", getpid());
  8004e0:	bfbff0ef          	jal	8000da <getpid>
  8004e4:	85aa                	mv	a1,a0
  8004e6:	00000517          	auipc	a0,0x0
  8004ea:	14250513          	addi	a0,a0,322 # 800628 <main+0x14c>
  8004ee:	b53ff0ef          	jal	800040 <cprintf>
    print_pgdir();
  8004f2:	bebff0ef          	jal	8000dc <print_pgdir>
    cprintf("pgdir pass.\n");
  8004f6:	00000517          	auipc	a0,0x0
  8004fa:	14a50513          	addi	a0,a0,330 # 800640 <main+0x164>
  8004fe:	b43ff0ef          	jal	800040 <cprintf>
    return 0;
}
  800502:	60a2                	ld	ra,8(sp)
  800504:	4501                	li	a0,0
  800506:	0141                	addi	sp,sp,16
  800508:	8082                	ret
