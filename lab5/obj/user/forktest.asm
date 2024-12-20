
obj/__user_forktest.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	12a000ef          	jal	80014a <umain>
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
  800034:	5c050513          	addi	a0,a0,1472 # 8005f0 <main+0xa8>
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
  80005c:	5b850513          	addi	a0,a0,1464 # 800610 <main+0xc8>
  800060:	044000ef          	jal	8000a4 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	5559                	li	a0,-10
  800066:	0c6000ef          	jal	80012c <exit>

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
  800072:	0b4000ef          	jal	800126 <sys_putc>
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
  800098:	12c000ef          	jal	8001c4 <vprintfmt>
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
  8000cc:	0f8000ef          	jal	8001c4 <vprintfmt>
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

0000000000800126 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800126:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800128:	4579                	li	a0,30
  80012a:	b77d                	j	8000d8 <syscall>

000000000080012c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012c:	1141                	addi	sp,sp,-16
  80012e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800130:	fe5ff0ef          	jal	800114 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800134:	00000517          	auipc	a0,0x0
  800138:	4e450513          	addi	a0,a0,1252 # 800618 <main+0xd0>
  80013c:	f69ff0ef          	jal	8000a4 <cprintf>
    while (1);
  800140:	a001                	j	800140 <exit+0x14>

0000000000800142 <fork>:
}

int
fork(void) {
    return sys_fork();
  800142:	bfe1                	j	80011a <sys_fork>

0000000000800144 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800144:	4581                	li	a1,0
  800146:	4501                	li	a0,0
  800148:	bfd9                	j	80011e <sys_wait>

000000000080014a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014a:	1141                	addi	sp,sp,-16
  80014c:	e406                	sd	ra,8(sp)
    int ret = main();
  80014e:	3fa000ef          	jal	800548 <main>
    exit(ret);
  800152:	fdbff0ef          	jal	80012c <exit>

0000000000800156 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800156:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80015c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800160:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800162:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	f022                	sd	s0,32(sp)
  800168:	ec26                	sd	s1,24(sp)
  80016a:	e84a                	sd	s2,16(sp)
  80016c:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80016e:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	84aa                	mv	s1,a0
  800174:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800176:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800178:	05067063          	bgeu	a2,a6,8001b8 <printnum+0x62>
  80017c:	e44e                	sd	s3,8(sp)
  80017e:	89be                	mv	s3,a5
        while (-- width > 0)
  800180:	4785                	li	a5,1
  800182:	00e7d763          	bge	a5,a4,800190 <printnum+0x3a>
            putch(padc, putdat);
  800186:	85ca                	mv	a1,s2
  800188:	854e                	mv	a0,s3
        while (-- width > 0)
  80018a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018c:	9482                	jalr	s1
        while (-- width > 0)
  80018e:	fc65                	bnez	s0,800186 <printnum+0x30>
  800190:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800192:	1a02                	slli	s4,s4,0x20
  800194:	020a5a13          	srli	s4,s4,0x20
  800198:	00000797          	auipc	a5,0x0
  80019c:	49878793          	addi	a5,a5,1176 # 800630 <main+0xe8>
  8001a0:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a4:	0007c503          	lbu	a0,0(a5)
}
  8001a8:	70a2                	ld	ra,40(sp)
  8001aa:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ac:	85ca                	mv	a1,s2
  8001ae:	87a6                	mv	a5,s1
}
  8001b0:	6942                	ld	s2,16(sp)
  8001b2:	64e2                	ld	s1,24(sp)
  8001b4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b8:	03065633          	divu	a2,a2,a6
  8001bc:	8722                	mv	a4,s0
  8001be:	f99ff0ef          	jal	800156 <printnum>
  8001c2:	bfc1                	j	800192 <printnum+0x3c>

00000000008001c4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c4:	7119                	addi	sp,sp,-128
  8001c6:	f4a6                	sd	s1,104(sp)
  8001c8:	f0ca                	sd	s2,96(sp)
  8001ca:	ecce                	sd	s3,88(sp)
  8001cc:	e8d2                	sd	s4,80(sp)
  8001ce:	e4d6                	sd	s5,72(sp)
  8001d0:	e0da                	sd	s6,64(sp)
  8001d2:	f862                	sd	s8,48(sp)
  8001d4:	fc86                	sd	ra,120(sp)
  8001d6:	f8a2                	sd	s0,112(sp)
  8001d8:	fc5e                	sd	s7,56(sp)
  8001da:	f466                	sd	s9,40(sp)
  8001dc:	f06a                	sd	s10,32(sp)
  8001de:	ec6e                	sd	s11,24(sp)
  8001e0:	892a                	mv	s2,a0
  8001e2:	84ae                	mv	s1,a1
  8001e4:	8c32                	mv	s8,a2
  8001e6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e8:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ec:	05500b13          	li	s6,85
  8001f0:	00000a97          	auipc	s5,0x0
  8001f4:	5b8a8a93          	addi	s5,s5,1464 # 8007a8 <main+0x260>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f8:	000c4503          	lbu	a0,0(s8)
  8001fc:	001c0413          	addi	s0,s8,1
  800200:	01350a63          	beq	a0,s3,800214 <vprintfmt+0x50>
            if (ch == '\0') {
  800204:	cd0d                	beqz	a0,80023e <vprintfmt+0x7a>
            putch(ch, putdat);
  800206:	85a6                	mv	a1,s1
  800208:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	00044503          	lbu	a0,0(s0)
  80020e:	0405                	addi	s0,s0,1
  800210:	ff351ae3          	bne	a0,s3,800204 <vprintfmt+0x40>
        width = precision = -1;
  800214:	5cfd                	li	s9,-1
  800216:	8d66                	mv	s10,s9
        char padc = ' ';
  800218:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80021c:	4b81                	li	s7,0
  80021e:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	00044683          	lbu	a3,0(s0)
  800224:	00140c13          	addi	s8,s0,1
  800228:	fdd6859b          	addiw	a1,a3,-35
  80022c:	0ff5f593          	zext.b	a1,a1
  800230:	02bb6663          	bltu	s6,a1,80025c <vprintfmt+0x98>
  800234:	058a                	slli	a1,a1,0x2
  800236:	95d6                	add	a1,a1,s5
  800238:	4198                	lw	a4,0(a1)
  80023a:	9756                	add	a4,a4,s5
  80023c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023e:	70e6                	ld	ra,120(sp)
  800240:	7446                	ld	s0,112(sp)
  800242:	74a6                	ld	s1,104(sp)
  800244:	7906                	ld	s2,96(sp)
  800246:	69e6                	ld	s3,88(sp)
  800248:	6a46                	ld	s4,80(sp)
  80024a:	6aa6                	ld	s5,72(sp)
  80024c:	6b06                	ld	s6,64(sp)
  80024e:	7be2                	ld	s7,56(sp)
  800250:	7c42                	ld	s8,48(sp)
  800252:	7ca2                	ld	s9,40(sp)
  800254:	7d02                	ld	s10,32(sp)
  800256:	6de2                	ld	s11,24(sp)
  800258:	6109                	addi	sp,sp,128
  80025a:	8082                	ret
            putch('%', putdat);
  80025c:	85a6                	mv	a1,s1
  80025e:	02500513          	li	a0,37
  800262:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800264:	fff44783          	lbu	a5,-1(s0)
  800268:	02500713          	li	a4,37
  80026c:	8c22                	mv	s8,s0
  80026e:	f8e785e3          	beq	a5,a4,8001f8 <vprintfmt+0x34>
  800272:	ffec4783          	lbu	a5,-2(s8)
  800276:	1c7d                	addi	s8,s8,-1
  800278:	fee79de3          	bne	a5,a4,800272 <vprintfmt+0xae>
  80027c:	bfb5                	j	8001f8 <vprintfmt+0x34>
                ch = *fmt;
  80027e:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800282:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800284:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800288:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  80028c:	8462                	mv	s0,s8
                ch = *fmt;
  80028e:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800290:	02e56463          	bltu	a0,a4,8002b8 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  800294:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800298:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80029c:	0197073b          	addw	a4,a4,s9
  8002a0:	0017171b          	slliw	a4,a4,0x1
  8002a4:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  8002a6:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002aa:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ac:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002b0:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  8002b4:	feb570e3          	bgeu	a0,a1,800294 <vprintfmt+0xd0>
            if (width < 0)
  8002b8:	f60d54e3          	bgez	s10,800220 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002bc:	8d66                	mv	s10,s9
  8002be:	5cfd                	li	s9,-1
  8002c0:	b785                	j	800220 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002c2:	8db6                	mv	s11,a3
  8002c4:	8462                	mv	s0,s8
  8002c6:	bfa9                	j	800220 <vprintfmt+0x5c>
  8002c8:	8462                	mv	s0,s8
            altflag = 1;
  8002ca:	4b85                	li	s7,1
            goto reswitch;
  8002cc:	bf91                	j	800220 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ce:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002d0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002d4:	00c7c463          	blt	a5,a2,8002dc <vprintfmt+0x118>
    else if (lflag) {
  8002d8:	18060763          	beqz	a2,800466 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  8002dc:	000a3603          	ld	a2,0(s4)
  8002e0:	46c1                	li	a3,16
  8002e2:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002e4:	000d879b          	sext.w	a5,s11
  8002e8:	876a                	mv	a4,s10
  8002ea:	85a6                	mv	a1,s1
  8002ec:	854a                	mv	a0,s2
  8002ee:	e69ff0ef          	jal	800156 <printnum>
            break;
  8002f2:	b719                	j	8001f8 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002f4:	000a2503          	lw	a0,0(s4)
  8002f8:	85a6                	mv	a1,s1
  8002fa:	0a21                	addi	s4,s4,8
  8002fc:	9902                	jalr	s2
            break;
  8002fe:	bded                	j	8001f8 <vprintfmt+0x34>
    if (lflag >= 2) {
  800300:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800302:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800306:	00c7c463          	blt	a5,a2,80030e <vprintfmt+0x14a>
    else if (lflag) {
  80030a:	14060963          	beqz	a2,80045c <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  80030e:	000a3603          	ld	a2,0(s4)
  800312:	46a9                	li	a3,10
  800314:	8a3a                	mv	s4,a4
  800316:	b7f9                	j	8002e4 <vprintfmt+0x120>
            putch('0', putdat);
  800318:	85a6                	mv	a1,s1
  80031a:	03000513          	li	a0,48
  80031e:	9902                	jalr	s2
            putch('x', putdat);
  800320:	85a6                	mv	a1,s1
  800322:	07800513          	li	a0,120
  800326:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800328:	000a3603          	ld	a2,0(s4)
            goto number;
  80032c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032e:	0a21                	addi	s4,s4,8
            goto number;
  800330:	bf55                	j	8002e4 <vprintfmt+0x120>
            putch(ch, putdat);
  800332:	85a6                	mv	a1,s1
  800334:	02500513          	li	a0,37
  800338:	9902                	jalr	s2
            break;
  80033a:	bd7d                	j	8001f8 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80033c:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800340:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800342:	0a21                	addi	s4,s4,8
            goto process_precision;
  800344:	bf95                	j	8002b8 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800346:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800348:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80034c:	00c7c463          	blt	a5,a2,800354 <vprintfmt+0x190>
    else if (lflag) {
  800350:	10060163          	beqz	a2,800452 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  800354:	000a3603          	ld	a2,0(s4)
  800358:	46a1                	li	a3,8
  80035a:	8a3a                	mv	s4,a4
  80035c:	b761                	j	8002e4 <vprintfmt+0x120>
            if (width < 0)
  80035e:	87ea                	mv	a5,s10
  800360:	000d5363          	bgez	s10,800366 <vprintfmt+0x1a2>
  800364:	4781                	li	a5,0
  800366:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80036a:	8462                	mv	s0,s8
            goto reswitch;
  80036c:	bd55                	j	800220 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80036e:	000a3703          	ld	a4,0(s4)
  800372:	12070b63          	beqz	a4,8004a8 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  800376:	0da05563          	blez	s10,800440 <vprintfmt+0x27c>
  80037a:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037e:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  800382:	14fd9a63          	bne	s11,a5,8004d6 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800386:	00074783          	lbu	a5,0(a4)
  80038a:	0007851b          	sext.w	a0,a5
  80038e:	c785                	beqz	a5,8003b6 <vprintfmt+0x1f2>
  800390:	5dfd                	li	s11,-1
  800392:	000cc563          	bltz	s9,80039c <vprintfmt+0x1d8>
  800396:	3cfd                	addiw	s9,s9,-1
  800398:	01bc8d63          	beq	s9,s11,8003b2 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  80039c:	0c0b9a63          	bnez	s7,800470 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  8003a0:	85a6                	mv	a1,s1
  8003a2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a4:	00044783          	lbu	a5,0(s0)
  8003a8:	0405                	addi	s0,s0,1
  8003aa:	3d7d                	addiw	s10,s10,-1
  8003ac:	0007851b          	sext.w	a0,a5
  8003b0:	f3ed                	bnez	a5,800392 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  8003b2:	01a05963          	blez	s10,8003c4 <vprintfmt+0x200>
                putch(' ', putdat);
  8003b6:	85a6                	mv	a1,s1
  8003b8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003bc:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003be:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c0:	fe0d1be3          	bnez	s10,8003b6 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c4:	0a21                	addi	s4,s4,8
  8003c6:	bd0d                	j	8001f8 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003c8:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003ca:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003ce:	00c7c363          	blt	a5,a2,8003d4 <vprintfmt+0x210>
    else if (lflag) {
  8003d2:	c625                	beqz	a2,80043a <vprintfmt+0x276>
        return va_arg(*ap, long);
  8003d4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003d8:	0a044f63          	bltz	s0,800496 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  8003dc:	8622                	mv	a2,s0
  8003de:	8a5e                	mv	s4,s7
  8003e0:	46a9                	li	a3,10
  8003e2:	b709                	j	8002e4 <vprintfmt+0x120>
            if (err < 0) {
  8003e4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e8:	4661                	li	a2,24
            if (err < 0) {
  8003ea:	41f7d71b          	sraiw	a4,a5,0x1f
  8003ee:	8fb9                	xor	a5,a5,a4
  8003f0:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f4:	02d64663          	blt	a2,a3,800420 <vprintfmt+0x25c>
  8003f8:	00000797          	auipc	a5,0x0
  8003fc:	50878793          	addi	a5,a5,1288 # 800900 <error_string>
  800400:	00369713          	slli	a4,a3,0x3
  800404:	97ba                	add	a5,a5,a4
  800406:	639c                	ld	a5,0(a5)
  800408:	cf81                	beqz	a5,800420 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  80040a:	86be                	mv	a3,a5
  80040c:	00000617          	auipc	a2,0x0
  800410:	25460613          	addi	a2,a2,596 # 800660 <main+0x118>
  800414:	85a6                	mv	a1,s1
  800416:	854a                	mv	a0,s2
  800418:	0f4000ef          	jal	80050c <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  80041c:	0a21                	addi	s4,s4,8
  80041e:	bbe9                	j	8001f8 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800420:	00000617          	auipc	a2,0x0
  800424:	23060613          	addi	a2,a2,560 # 800650 <main+0x108>
  800428:	85a6                	mv	a1,s1
  80042a:	854a                	mv	a0,s2
  80042c:	0e0000ef          	jal	80050c <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800430:	0a21                	addi	s4,s4,8
  800432:	b3d9                	j	8001f8 <vprintfmt+0x34>
            lflag ++;
  800434:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800436:	8462                	mv	s0,s8
            goto reswitch;
  800438:	b3e5                	j	800220 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80043a:	000a2403          	lw	s0,0(s4)
  80043e:	bf69                	j	8003d8 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800440:	00074783          	lbu	a5,0(a4)
  800444:	0007851b          	sext.w	a0,a5
  800448:	dfb5                	beqz	a5,8003c4 <vprintfmt+0x200>
  80044a:	00170413          	addi	s0,a4,1
  80044e:	5dfd                	li	s11,-1
  800450:	b789                	j	800392 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  800452:	000a6603          	lwu	a2,0(s4)
  800456:	46a1                	li	a3,8
  800458:	8a3a                	mv	s4,a4
  80045a:	b569                	j	8002e4 <vprintfmt+0x120>
  80045c:	000a6603          	lwu	a2,0(s4)
  800460:	46a9                	li	a3,10
  800462:	8a3a                	mv	s4,a4
  800464:	b541                	j	8002e4 <vprintfmt+0x120>
  800466:	000a6603          	lwu	a2,0(s4)
  80046a:	46c1                	li	a3,16
  80046c:	8a3a                	mv	s4,a4
  80046e:	bd9d                	j	8002e4 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800470:	3781                	addiw	a5,a5,-32
  800472:	05e00713          	li	a4,94
  800476:	f2f775e3          	bgeu	a4,a5,8003a0 <vprintfmt+0x1dc>
                    putch('?', putdat);
  80047a:	03f00513          	li	a0,63
  80047e:	85a6                	mv	a1,s1
  800480:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800482:	00044783          	lbu	a5,0(s0)
  800486:	0405                	addi	s0,s0,1
  800488:	3d7d                	addiw	s10,s10,-1
  80048a:	0007851b          	sext.w	a0,a5
  80048e:	d395                	beqz	a5,8003b2 <vprintfmt+0x1ee>
  800490:	f00cd3e3          	bgez	s9,800396 <vprintfmt+0x1d2>
  800494:	bff1                	j	800470 <vprintfmt+0x2ac>
                putch('-', putdat);
  800496:	85a6                	mv	a1,s1
  800498:	02d00513          	li	a0,45
  80049c:	9902                	jalr	s2
                num = -(long long)num;
  80049e:	40800633          	neg	a2,s0
  8004a2:	8a5e                	mv	s4,s7
  8004a4:	46a9                	li	a3,10
  8004a6:	bd3d                	j	8002e4 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004a8:	01a05663          	blez	s10,8004b4 <vprintfmt+0x2f0>
  8004ac:	02d00793          	li	a5,45
  8004b0:	00fd9b63          	bne	s11,a5,8004c6 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b4:	02800793          	li	a5,40
  8004b8:	853e                	mv	a0,a5
  8004ba:	00000417          	auipc	s0,0x0
  8004be:	18f40413          	addi	s0,s0,399 # 800649 <main+0x101>
  8004c2:	5dfd                	li	s11,-1
  8004c4:	b5f9                	j	800392 <vprintfmt+0x1ce>
  8004c6:	00000417          	auipc	s0,0x0
  8004ca:	18340413          	addi	s0,s0,387 # 800649 <main+0x101>
                p = "(null)";
  8004ce:	00000717          	auipc	a4,0x0
  8004d2:	17a70713          	addi	a4,a4,378 # 800648 <main+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d6:	853a                	mv	a0,a4
  8004d8:	85e6                	mv	a1,s9
  8004da:	e43a                	sd	a4,8(sp)
  8004dc:	050000ef          	jal	80052c <strnlen>
  8004e0:	40ad0d3b          	subw	s10,s10,a0
  8004e4:	6722                	ld	a4,8(sp)
  8004e6:	01a05b63          	blez	s10,8004fc <vprintfmt+0x338>
                    putch(padc, putdat);
  8004ea:	2d81                	sext.w	s11,s11
  8004ec:	85a6                	mv	a1,s1
  8004ee:	856e                	mv	a0,s11
  8004f0:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f2:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004f4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f6:	6722                	ld	a4,8(sp)
  8004f8:	fe0d1ae3          	bnez	s10,8004ec <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fc:	00074783          	lbu	a5,0(a4)
  800500:	0007851b          	sext.w	a0,a5
  800504:	ec0780e3          	beqz	a5,8003c4 <vprintfmt+0x200>
  800508:	5dfd                	li	s11,-1
  80050a:	b561                	j	800392 <vprintfmt+0x1ce>

000000000080050c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80050e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800512:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800514:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800516:	ec06                	sd	ra,24(sp)
  800518:	f83a                	sd	a4,48(sp)
  80051a:	fc3e                	sd	a5,56(sp)
  80051c:	e0c2                	sd	a6,64(sp)
  80051e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800520:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800522:	ca3ff0ef          	jal	8001c4 <vprintfmt>
}
  800526:	60e2                	ld	ra,24(sp)
  800528:	6161                	addi	sp,sp,80
  80052a:	8082                	ret

000000000080052c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80052c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80052e:	e589                	bnez	a1,800538 <strnlen+0xc>
  800530:	a811                	j	800544 <strnlen+0x18>
        cnt ++;
  800532:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800534:	00f58863          	beq	a1,a5,800544 <strnlen+0x18>
  800538:	00f50733          	add	a4,a0,a5
  80053c:	00074703          	lbu	a4,0(a4)
  800540:	fb6d                	bnez	a4,800532 <strnlen+0x6>
  800542:	85be                	mv	a1,a5
    }
    return cnt;
}
  800544:	852e                	mv	a0,a1
  800546:	8082                	ret

0000000000800548 <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  800548:	1101                	addi	sp,sp,-32
  80054a:	e822                	sd	s0,16(sp)
  80054c:	e426                	sd	s1,8(sp)
  80054e:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800550:	4401                	li	s0,0
  800552:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  800556:	bedff0ef          	jal	800142 <fork>
  80055a:	c915                	beqz	a0,80058e <main+0x46>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  80055c:	04a05e63          	blez	a0,8005b8 <main+0x70>
    for (n = 0; n < max_child; n ++) {
  800560:	2405                	addiw	s0,s0,1
  800562:	fe941ae3          	bne	s0,s1,800556 <main+0xe>
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  800566:	bdfff0ef          	jal	800144 <wait>
  80056a:	ed05                	bnez	a0,8005a2 <main+0x5a>
    for (; n > 0; n --) {
  80056c:	347d                	addiw	s0,s0,-1
  80056e:	fc65                	bnez	s0,800566 <main+0x1e>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  800570:	bd5ff0ef          	jal	800144 <wait>
  800574:	c12d                	beqz	a0,8005d6 <main+0x8e>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  800576:	00000517          	auipc	a0,0x0
  80057a:	22250513          	addi	a0,a0,546 # 800798 <main+0x250>
  80057e:	b27ff0ef          	jal	8000a4 <cprintf>
    return 0;
}
  800582:	60e2                	ld	ra,24(sp)
  800584:	6442                	ld	s0,16(sp)
  800586:	64a2                	ld	s1,8(sp)
  800588:	4501                	li	a0,0
  80058a:	6105                	addi	sp,sp,32
  80058c:	8082                	ret
            cprintf("I am child %d\n", n);
  80058e:	85a2                	mv	a1,s0
  800590:	00000517          	auipc	a0,0x0
  800594:	19850513          	addi	a0,a0,408 # 800728 <main+0x1e0>
  800598:	b0dff0ef          	jal	8000a4 <cprintf>
            exit(0);
  80059c:	4501                	li	a0,0
  80059e:	b8fff0ef          	jal	80012c <exit>
            panic("wait stopped early\n");
  8005a2:	00000617          	auipc	a2,0x0
  8005a6:	1c660613          	addi	a2,a2,454 # 800768 <main+0x220>
  8005aa:	45dd                	li	a1,23
  8005ac:	00000517          	auipc	a0,0x0
  8005b0:	1ac50513          	addi	a0,a0,428 # 800758 <main+0x210>
  8005b4:	a73ff0ef          	jal	800026 <__panic>
        assert(pid > 0);
  8005b8:	00000697          	auipc	a3,0x0
  8005bc:	18068693          	addi	a3,a3,384 # 800738 <main+0x1f0>
  8005c0:	00000617          	auipc	a2,0x0
  8005c4:	18060613          	addi	a2,a2,384 # 800740 <main+0x1f8>
  8005c8:	45b9                	li	a1,14
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	18e50513          	addi	a0,a0,398 # 800758 <main+0x210>
  8005d2:	a55ff0ef          	jal	800026 <__panic>
        panic("wait got too many\n");
  8005d6:	00000617          	auipc	a2,0x0
  8005da:	1aa60613          	addi	a2,a2,426 # 800780 <main+0x238>
  8005de:	45f1                	li	a1,28
  8005e0:	00000517          	auipc	a0,0x0
  8005e4:	17850513          	addi	a0,a0,376 # 800758 <main+0x210>
  8005e8:	a3fff0ef          	jal	800026 <__panic>
