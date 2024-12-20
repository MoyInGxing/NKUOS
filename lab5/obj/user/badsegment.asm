
obj/__user_badsegment.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	116000ef          	jal	800136 <umain>
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
  800034:	52050513          	addi	a0,a0,1312 # 800550 <main+0x1c>
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
  80005c:	51850513          	addi	a0,a0,1304 # 800570 <main+0x3c>
  800060:	044000ef          	jal	8000a4 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	5559                	li	a0,-10
  800066:	0ba000ef          	jal	800120 <exit>

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
  800072:	0a8000ef          	jal	80011a <sys_putc>
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
  800098:	118000ef          	jal	8001b0 <vprintfmt>
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
  8000cc:	0e4000ef          	jal	8001b0 <vprintfmt>
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

000000000080011a <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  80011a:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80011c:	4579                	li	a0,30
  80011e:	bf6d                	j	8000d8 <syscall>

0000000000800120 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800120:	1141                	addi	sp,sp,-16
  800122:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800124:	ff1ff0ef          	jal	800114 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800128:	00000517          	auipc	a0,0x0
  80012c:	45050513          	addi	a0,a0,1104 # 800578 <main+0x44>
  800130:	f75ff0ef          	jal	8000a4 <cprintf>
    while (1);
  800134:	a001                	j	800134 <exit+0x14>

0000000000800136 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800136:	1141                	addi	sp,sp,-16
  800138:	e406                	sd	ra,8(sp)
    int ret = main();
  80013a:	3fa000ef          	jal	800534 <main>
    exit(ret);
  80013e:	fe3ff0ef          	jal	800120 <exit>

0000000000800142 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800142:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800146:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800148:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80014c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800152:	f022                	sd	s0,32(sp)
  800154:	ec26                	sd	s1,24(sp)
  800156:	e84a                	sd	s2,16(sp)
  800158:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80015a:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80015e:	84aa                	mv	s1,a0
  800160:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800162:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800164:	05067063          	bgeu	a2,a6,8001a4 <printnum+0x62>
  800168:	e44e                	sd	s3,8(sp)
  80016a:	89be                	mv	s3,a5
        while (-- width > 0)
  80016c:	4785                	li	a5,1
  80016e:	00e7d763          	bge	a5,a4,80017c <printnum+0x3a>
            putch(padc, putdat);
  800172:	85ca                	mv	a1,s2
  800174:	854e                	mv	a0,s3
        while (-- width > 0)
  800176:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800178:	9482                	jalr	s1
        while (-- width > 0)
  80017a:	fc65                	bnez	s0,800172 <printnum+0x30>
  80017c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80017e:	1a02                	slli	s4,s4,0x20
  800180:	020a5a13          	srli	s4,s4,0x20
  800184:	00000797          	auipc	a5,0x0
  800188:	40c78793          	addi	a5,a5,1036 # 800590 <main+0x5c>
  80018c:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80018e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800190:	0007c503          	lbu	a0,0(a5)
}
  800194:	70a2                	ld	ra,40(sp)
  800196:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800198:	85ca                	mv	a1,s2
  80019a:	87a6                	mv	a5,s1
}
  80019c:	6942                	ld	s2,16(sp)
  80019e:	64e2                	ld	s1,24(sp)
  8001a0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001a2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001a4:	03065633          	divu	a2,a2,a6
  8001a8:	8722                	mv	a4,s0
  8001aa:	f99ff0ef          	jal	800142 <printnum>
  8001ae:	bfc1                	j	80017e <printnum+0x3c>

00000000008001b0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001b0:	7119                	addi	sp,sp,-128
  8001b2:	f4a6                	sd	s1,104(sp)
  8001b4:	f0ca                	sd	s2,96(sp)
  8001b6:	ecce                	sd	s3,88(sp)
  8001b8:	e8d2                	sd	s4,80(sp)
  8001ba:	e4d6                	sd	s5,72(sp)
  8001bc:	e0da                	sd	s6,64(sp)
  8001be:	f862                	sd	s8,48(sp)
  8001c0:	fc86                	sd	ra,120(sp)
  8001c2:	f8a2                	sd	s0,112(sp)
  8001c4:	fc5e                	sd	s7,56(sp)
  8001c6:	f466                	sd	s9,40(sp)
  8001c8:	f06a                	sd	s10,32(sp)
  8001ca:	ec6e                	sd	s11,24(sp)
  8001cc:	892a                	mv	s2,a0
  8001ce:	84ae                	mv	s1,a1
  8001d0:	8c32                	mv	s8,a2
  8001d2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d4:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001d8:	05500b13          	li	s6,85
  8001dc:	00000a97          	auipc	s5,0x0
  8001e0:	4d0a8a93          	addi	s5,s5,1232 # 8006ac <main+0x178>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e4:	000c4503          	lbu	a0,0(s8)
  8001e8:	001c0413          	addi	s0,s8,1
  8001ec:	01350a63          	beq	a0,s3,800200 <vprintfmt+0x50>
            if (ch == '\0') {
  8001f0:	cd0d                	beqz	a0,80022a <vprintfmt+0x7a>
            putch(ch, putdat);
  8001f2:	85a6                	mv	a1,s1
  8001f4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	00044503          	lbu	a0,0(s0)
  8001fa:	0405                	addi	s0,s0,1
  8001fc:	ff351ae3          	bne	a0,s3,8001f0 <vprintfmt+0x40>
        width = precision = -1;
  800200:	5cfd                	li	s9,-1
  800202:	8d66                	mv	s10,s9
        char padc = ' ';
  800204:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800208:	4b81                	li	s7,0
  80020a:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  80020c:	00044683          	lbu	a3,0(s0)
  800210:	00140c13          	addi	s8,s0,1
  800214:	fdd6859b          	addiw	a1,a3,-35
  800218:	0ff5f593          	zext.b	a1,a1
  80021c:	02bb6663          	bltu	s6,a1,800248 <vprintfmt+0x98>
  800220:	058a                	slli	a1,a1,0x2
  800222:	95d6                	add	a1,a1,s5
  800224:	4198                	lw	a4,0(a1)
  800226:	9756                	add	a4,a4,s5
  800228:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80022a:	70e6                	ld	ra,120(sp)
  80022c:	7446                	ld	s0,112(sp)
  80022e:	74a6                	ld	s1,104(sp)
  800230:	7906                	ld	s2,96(sp)
  800232:	69e6                	ld	s3,88(sp)
  800234:	6a46                	ld	s4,80(sp)
  800236:	6aa6                	ld	s5,72(sp)
  800238:	6b06                	ld	s6,64(sp)
  80023a:	7be2                	ld	s7,56(sp)
  80023c:	7c42                	ld	s8,48(sp)
  80023e:	7ca2                	ld	s9,40(sp)
  800240:	7d02                	ld	s10,32(sp)
  800242:	6de2                	ld	s11,24(sp)
  800244:	6109                	addi	sp,sp,128
  800246:	8082                	ret
            putch('%', putdat);
  800248:	85a6                	mv	a1,s1
  80024a:	02500513          	li	a0,37
  80024e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800250:	fff44783          	lbu	a5,-1(s0)
  800254:	02500713          	li	a4,37
  800258:	8c22                	mv	s8,s0
  80025a:	f8e785e3          	beq	a5,a4,8001e4 <vprintfmt+0x34>
  80025e:	ffec4783          	lbu	a5,-2(s8)
  800262:	1c7d                	addi	s8,s8,-1
  800264:	fee79de3          	bne	a5,a4,80025e <vprintfmt+0xae>
  800268:	bfb5                	j	8001e4 <vprintfmt+0x34>
                ch = *fmt;
  80026a:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80026e:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800270:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800274:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	8462                	mv	s0,s8
                ch = *fmt;
  80027a:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  80027c:	02e56463          	bltu	a0,a4,8002a4 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  800280:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800284:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800288:	0197073b          	addw	a4,a4,s9
  80028c:	0017171b          	slliw	a4,a4,0x1
  800290:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  800292:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800296:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800298:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80029c:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  8002a0:	feb570e3          	bgeu	a0,a1,800280 <vprintfmt+0xd0>
            if (width < 0)
  8002a4:	f60d54e3          	bgez	s10,80020c <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002a8:	8d66                	mv	s10,s9
  8002aa:	5cfd                	li	s9,-1
  8002ac:	b785                	j	80020c <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002ae:	8db6                	mv	s11,a3
  8002b0:	8462                	mv	s0,s8
  8002b2:	bfa9                	j	80020c <vprintfmt+0x5c>
  8002b4:	8462                	mv	s0,s8
            altflag = 1;
  8002b6:	4b85                	li	s7,1
            goto reswitch;
  8002b8:	bf91                	j	80020c <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ba:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002bc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002c0:	00c7c463          	blt	a5,a2,8002c8 <vprintfmt+0x118>
    else if (lflag) {
  8002c4:	18060763          	beqz	a2,800452 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  8002c8:	000a3603          	ld	a2,0(s4)
  8002cc:	46c1                	li	a3,16
  8002ce:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002d0:	000d879b          	sext.w	a5,s11
  8002d4:	876a                	mv	a4,s10
  8002d6:	85a6                	mv	a1,s1
  8002d8:	854a                	mv	a0,s2
  8002da:	e69ff0ef          	jal	800142 <printnum>
            break;
  8002de:	b719                	j	8001e4 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002e0:	000a2503          	lw	a0,0(s4)
  8002e4:	85a6                	mv	a1,s1
  8002e6:	0a21                	addi	s4,s4,8
  8002e8:	9902                	jalr	s2
            break;
  8002ea:	bded                	j	8001e4 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002ec:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002ee:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002f2:	00c7c463          	blt	a5,a2,8002fa <vprintfmt+0x14a>
    else if (lflag) {
  8002f6:	14060963          	beqz	a2,800448 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  8002fa:	000a3603          	ld	a2,0(s4)
  8002fe:	46a9                	li	a3,10
  800300:	8a3a                	mv	s4,a4
  800302:	b7f9                	j	8002d0 <vprintfmt+0x120>
            putch('0', putdat);
  800304:	85a6                	mv	a1,s1
  800306:	03000513          	li	a0,48
  80030a:	9902                	jalr	s2
            putch('x', putdat);
  80030c:	85a6                	mv	a1,s1
  80030e:	07800513          	li	a0,120
  800312:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800314:	000a3603          	ld	a2,0(s4)
            goto number;
  800318:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80031a:	0a21                	addi	s4,s4,8
            goto number;
  80031c:	bf55                	j	8002d0 <vprintfmt+0x120>
            putch(ch, putdat);
  80031e:	85a6                	mv	a1,s1
  800320:	02500513          	li	a0,37
  800324:	9902                	jalr	s2
            break;
  800326:	bd7d                	j	8001e4 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800328:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80032c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80032e:	0a21                	addi	s4,s4,8
            goto process_precision;
  800330:	bf95                	j	8002a4 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800332:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800334:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800338:	00c7c463          	blt	a5,a2,800340 <vprintfmt+0x190>
    else if (lflag) {
  80033c:	10060163          	beqz	a2,80043e <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  800340:	000a3603          	ld	a2,0(s4)
  800344:	46a1                	li	a3,8
  800346:	8a3a                	mv	s4,a4
  800348:	b761                	j	8002d0 <vprintfmt+0x120>
            if (width < 0)
  80034a:	87ea                	mv	a5,s10
  80034c:	000d5363          	bgez	s10,800352 <vprintfmt+0x1a2>
  800350:	4781                	li	a5,0
  800352:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800356:	8462                	mv	s0,s8
            goto reswitch;
  800358:	bd55                	j	80020c <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80035a:	000a3703          	ld	a4,0(s4)
  80035e:	12070b63          	beqz	a4,800494 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  800362:	0da05563          	blez	s10,80042c <vprintfmt+0x27c>
  800366:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036a:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  80036e:	14fd9a63          	bne	s11,a5,8004c2 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800372:	00074783          	lbu	a5,0(a4)
  800376:	0007851b          	sext.w	a0,a5
  80037a:	c785                	beqz	a5,8003a2 <vprintfmt+0x1f2>
  80037c:	5dfd                	li	s11,-1
  80037e:	000cc563          	bltz	s9,800388 <vprintfmt+0x1d8>
  800382:	3cfd                	addiw	s9,s9,-1
  800384:	01bc8d63          	beq	s9,s11,80039e <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  800388:	0c0b9a63          	bnez	s7,80045c <vprintfmt+0x2ac>
                    putch(ch, putdat);
  80038c:	85a6                	mv	a1,s1
  80038e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800390:	00044783          	lbu	a5,0(s0)
  800394:	0405                	addi	s0,s0,1
  800396:	3d7d                	addiw	s10,s10,-1
  800398:	0007851b          	sext.w	a0,a5
  80039c:	f3ed                	bnez	a5,80037e <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  80039e:	01a05963          	blez	s10,8003b0 <vprintfmt+0x200>
                putch(' ', putdat);
  8003a2:	85a6                	mv	a1,s1
  8003a4:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003a8:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003aa:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ac:	fe0d1be3          	bnez	s10,8003a2 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b0:	0a21                	addi	s4,s4,8
  8003b2:	bd0d                	j	8001e4 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003b4:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003b6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003ba:	00c7c363          	blt	a5,a2,8003c0 <vprintfmt+0x210>
    else if (lflag) {
  8003be:	c625                	beqz	a2,800426 <vprintfmt+0x276>
        return va_arg(*ap, long);
  8003c0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003c4:	0a044f63          	bltz	s0,800482 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  8003c8:	8622                	mv	a2,s0
  8003ca:	8a5e                	mv	s4,s7
  8003cc:	46a9                	li	a3,10
  8003ce:	b709                	j	8002d0 <vprintfmt+0x120>
            if (err < 0) {
  8003d0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003d4:	4661                	li	a2,24
            if (err < 0) {
  8003d6:	41f7d71b          	sraiw	a4,a5,0x1f
  8003da:	8fb9                	xor	a5,a5,a4
  8003dc:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e0:	02d64663          	blt	a2,a3,80040c <vprintfmt+0x25c>
  8003e4:	00000797          	auipc	a5,0x0
  8003e8:	42478793          	addi	a5,a5,1060 # 800808 <error_string>
  8003ec:	00369713          	slli	a4,a3,0x3
  8003f0:	97ba                	add	a5,a5,a4
  8003f2:	639c                	ld	a5,0(a5)
  8003f4:	cf81                	beqz	a5,80040c <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  8003f6:	86be                	mv	a3,a5
  8003f8:	00000617          	auipc	a2,0x0
  8003fc:	1c860613          	addi	a2,a2,456 # 8005c0 <main+0x8c>
  800400:	85a6                	mv	a1,s1
  800402:	854a                	mv	a0,s2
  800404:	0f4000ef          	jal	8004f8 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800408:	0a21                	addi	s4,s4,8
  80040a:	bbe9                	j	8001e4 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80040c:	00000617          	auipc	a2,0x0
  800410:	1a460613          	addi	a2,a2,420 # 8005b0 <main+0x7c>
  800414:	85a6                	mv	a1,s1
  800416:	854a                	mv	a0,s2
  800418:	0e0000ef          	jal	8004f8 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  80041c:	0a21                	addi	s4,s4,8
  80041e:	b3d9                	j	8001e4 <vprintfmt+0x34>
            lflag ++;
  800420:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800422:	8462                	mv	s0,s8
            goto reswitch;
  800424:	b3e5                	j	80020c <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800426:	000a2403          	lw	s0,0(s4)
  80042a:	bf69                	j	8003c4 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80042c:	00074783          	lbu	a5,0(a4)
  800430:	0007851b          	sext.w	a0,a5
  800434:	dfb5                	beqz	a5,8003b0 <vprintfmt+0x200>
  800436:	00170413          	addi	s0,a4,1
  80043a:	5dfd                	li	s11,-1
  80043c:	b789                	j	80037e <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  80043e:	000a6603          	lwu	a2,0(s4)
  800442:	46a1                	li	a3,8
  800444:	8a3a                	mv	s4,a4
  800446:	b569                	j	8002d0 <vprintfmt+0x120>
  800448:	000a6603          	lwu	a2,0(s4)
  80044c:	46a9                	li	a3,10
  80044e:	8a3a                	mv	s4,a4
  800450:	b541                	j	8002d0 <vprintfmt+0x120>
  800452:	000a6603          	lwu	a2,0(s4)
  800456:	46c1                	li	a3,16
  800458:	8a3a                	mv	s4,a4
  80045a:	bd9d                	j	8002d0 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  80045c:	3781                	addiw	a5,a5,-32
  80045e:	05e00713          	li	a4,94
  800462:	f2f775e3          	bgeu	a4,a5,80038c <vprintfmt+0x1dc>
                    putch('?', putdat);
  800466:	03f00513          	li	a0,63
  80046a:	85a6                	mv	a1,s1
  80046c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80046e:	00044783          	lbu	a5,0(s0)
  800472:	0405                	addi	s0,s0,1
  800474:	3d7d                	addiw	s10,s10,-1
  800476:	0007851b          	sext.w	a0,a5
  80047a:	d395                	beqz	a5,80039e <vprintfmt+0x1ee>
  80047c:	f00cd3e3          	bgez	s9,800382 <vprintfmt+0x1d2>
  800480:	bff1                	j	80045c <vprintfmt+0x2ac>
                putch('-', putdat);
  800482:	85a6                	mv	a1,s1
  800484:	02d00513          	li	a0,45
  800488:	9902                	jalr	s2
                num = -(long long)num;
  80048a:	40800633          	neg	a2,s0
  80048e:	8a5e                	mv	s4,s7
  800490:	46a9                	li	a3,10
  800492:	bd3d                	j	8002d0 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800494:	01a05663          	blez	s10,8004a0 <vprintfmt+0x2f0>
  800498:	02d00793          	li	a5,45
  80049c:	00fd9b63          	bne	s11,a5,8004b2 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a0:	02800793          	li	a5,40
  8004a4:	853e                	mv	a0,a5
  8004a6:	00000417          	auipc	s0,0x0
  8004aa:	10340413          	addi	s0,s0,259 # 8005a9 <main+0x75>
  8004ae:	5dfd                	li	s11,-1
  8004b0:	b5f9                	j	80037e <vprintfmt+0x1ce>
  8004b2:	00000417          	auipc	s0,0x0
  8004b6:	0f740413          	addi	s0,s0,247 # 8005a9 <main+0x75>
                p = "(null)";
  8004ba:	00000717          	auipc	a4,0x0
  8004be:	0ee70713          	addi	a4,a4,238 # 8005a8 <main+0x74>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	853a                	mv	a0,a4
  8004c4:	85e6                	mv	a1,s9
  8004c6:	e43a                	sd	a4,8(sp)
  8004c8:	050000ef          	jal	800518 <strnlen>
  8004cc:	40ad0d3b          	subw	s10,s10,a0
  8004d0:	6722                	ld	a4,8(sp)
  8004d2:	01a05b63          	blez	s10,8004e8 <vprintfmt+0x338>
                    putch(padc, putdat);
  8004d6:	2d81                	sext.w	s11,s11
  8004d8:	85a6                	mv	a1,s1
  8004da:	856e                	mv	a0,s11
  8004dc:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004de:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004e0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	6722                	ld	a4,8(sp)
  8004e4:	fe0d1ae3          	bnez	s10,8004d8 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e8:	00074783          	lbu	a5,0(a4)
  8004ec:	0007851b          	sext.w	a0,a5
  8004f0:	ec0780e3          	beqz	a5,8003b0 <vprintfmt+0x200>
  8004f4:	5dfd                	li	s11,-1
  8004f6:	b561                	j	80037e <vprintfmt+0x1ce>

00000000008004f8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004fa:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004fe:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800500:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800502:	ec06                	sd	ra,24(sp)
  800504:	f83a                	sd	a4,48(sp)
  800506:	fc3e                	sd	a5,56(sp)
  800508:	e0c2                	sd	a6,64(sp)
  80050a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80050c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80050e:	ca3ff0ef          	jal	8001b0 <vprintfmt>
}
  800512:	60e2                	ld	ra,24(sp)
  800514:	6161                	addi	sp,sp,80
  800516:	8082                	ret

0000000000800518 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800518:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80051a:	e589                	bnez	a1,800524 <strnlen+0xc>
  80051c:	a811                	j	800530 <strnlen+0x18>
        cnt ++;
  80051e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800520:	00f58863          	beq	a1,a5,800530 <strnlen+0x18>
  800524:	00f50733          	add	a4,a0,a5
  800528:	00074703          	lbu	a4,0(a4)
  80052c:	fb6d                	bnez	a4,80051e <strnlen+0x6>
  80052e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800530:	852e                	mv	a0,a1
  800532:	8082                	ret

0000000000800534 <main>:
#include <ulib.h>

/* try to load the kernel's TSS selector into the DS register */

int
main(void) {
  800534:	1141                	addi	sp,sp,-16
	// There is no such thing as TSS in RISC-V
    // asm volatile("movw $0x28,%ax; movw %ax,%ds");
    panic("FAIL: T.T\n");
  800536:	00000617          	auipc	a2,0x0
  80053a:	15260613          	addi	a2,a2,338 # 800688 <main+0x154>
  80053e:	45a9                	li	a1,10
  800540:	00000517          	auipc	a0,0x0
  800544:	15850513          	addi	a0,a0,344 # 800698 <main+0x164>
main(void) {
  800548:	e406                	sd	ra,8(sp)
    panic("FAIL: T.T\n");
  80054a:	addff0ef          	jal	800026 <__panic>
