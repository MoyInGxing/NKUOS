
obj/__user_badarg.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	12c000ef          	jal	80014c <umain>
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
  800034:	60850513          	addi	a0,a0,1544 # 800638 <main+0xee>
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
  80005c:	60050513          	addi	a0,a0,1536 # 800658 <main+0x10e>
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
  800098:	12e000ef          	jal	8001c6 <vprintfmt>
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
  8000cc:	0fa000ef          	jal	8001c6 <vprintfmt>
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
  80013c:	52850513          	addi	a0,a0,1320 # 800660 <main+0x116>
  800140:	f65ff0ef          	jal	8000a4 <cprintf>
    while (1);
  800144:	a001                	j	800144 <exit+0x14>

0000000000800146 <fork>:
}

int
fork(void) {
    return sys_fork();
  800146:	bfd1                	j	80011a <sys_fork>

0000000000800148 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800148:	bfd9                	j	80011e <sys_wait>

000000000080014a <yield>:
}

void
yield(void) {
    sys_yield();
  80014a:	bff1                	j	800126 <sys_yield>

000000000080014c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014c:	1141                	addi	sp,sp,-16
  80014e:	e406                	sd	ra,8(sp)
    int ret = main();
  800150:	3fa000ef          	jal	80054a <main>
    exit(ret);
  800154:	fddff0ef          	jal	800130 <exit>

0000000000800158 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800158:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80015e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800164:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	f022                	sd	s0,32(sp)
  80016a:	ec26                	sd	s1,24(sp)
  80016c:	e84a                	sd	s2,16(sp)
  80016e:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800170:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	84aa                	mv	s1,a0
  800176:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800178:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80017a:	05067063          	bgeu	a2,a6,8001ba <printnum+0x62>
  80017e:	e44e                	sd	s3,8(sp)
  800180:	89be                	mv	s3,a5
        while (-- width > 0)
  800182:	4785                	li	a5,1
  800184:	00e7d763          	bge	a5,a4,800192 <printnum+0x3a>
            putch(padc, putdat);
  800188:	85ca                	mv	a1,s2
  80018a:	854e                	mv	a0,s3
        while (-- width > 0)
  80018c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018e:	9482                	jalr	s1
        while (-- width > 0)
  800190:	fc65                	bnez	s0,800188 <printnum+0x30>
  800192:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800194:	1a02                	slli	s4,s4,0x20
  800196:	020a5a13          	srli	s4,s4,0x20
  80019a:	00000797          	auipc	a5,0x0
  80019e:	4de78793          	addi	a5,a5,1246 # 800678 <main+0x12e>
  8001a2:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	0007c503          	lbu	a0,0(a5)
}
  8001aa:	70a2                	ld	ra,40(sp)
  8001ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	87a6                	mv	a5,s1
}
  8001b2:	6942                	ld	s2,16(sp)
  8001b4:	64e2                	ld	s1,24(sp)
  8001b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ba:	03065633          	divu	a2,a2,a6
  8001be:	8722                	mv	a4,s0
  8001c0:	f99ff0ef          	jal	800158 <printnum>
  8001c4:	bfc1                	j	800194 <printnum+0x3c>

00000000008001c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c6:	7119                	addi	sp,sp,-128
  8001c8:	f4a6                	sd	s1,104(sp)
  8001ca:	f0ca                	sd	s2,96(sp)
  8001cc:	ecce                	sd	s3,88(sp)
  8001ce:	e8d2                	sd	s4,80(sp)
  8001d0:	e4d6                	sd	s5,72(sp)
  8001d2:	e0da                	sd	s6,64(sp)
  8001d4:	f862                	sd	s8,48(sp)
  8001d6:	fc86                	sd	ra,120(sp)
  8001d8:	f8a2                	sd	s0,112(sp)
  8001da:	fc5e                	sd	s7,56(sp)
  8001dc:	f466                	sd	s9,40(sp)
  8001de:	f06a                	sd	s10,32(sp)
  8001e0:	ec6e                	sd	s11,24(sp)
  8001e2:	892a                	mv	s2,a0
  8001e4:	84ae                	mv	s1,a1
  8001e6:	8c32                	mv	s8,a2
  8001e8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ea:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ee:	05500b13          	li	s6,85
  8001f2:	00000a97          	auipc	s5,0x0
  8001f6:	646a8a93          	addi	s5,s5,1606 # 800838 <main+0x2ee>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fa:	000c4503          	lbu	a0,0(s8)
  8001fe:	001c0413          	addi	s0,s8,1
  800202:	01350a63          	beq	a0,s3,800216 <vprintfmt+0x50>
            if (ch == '\0') {
  800206:	cd0d                	beqz	a0,800240 <vprintfmt+0x7a>
            putch(ch, putdat);
  800208:	85a6                	mv	a1,s1
  80020a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020c:	00044503          	lbu	a0,0(s0)
  800210:	0405                	addi	s0,s0,1
  800212:	ff351ae3          	bne	a0,s3,800206 <vprintfmt+0x40>
        width = precision = -1;
  800216:	5cfd                	li	s9,-1
  800218:	8d66                	mv	s10,s9
        char padc = ' ';
  80021a:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80021e:	4b81                	li	s7,0
  800220:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  800222:	00044683          	lbu	a3,0(s0)
  800226:	00140c13          	addi	s8,s0,1
  80022a:	fdd6859b          	addiw	a1,a3,-35
  80022e:	0ff5f593          	zext.b	a1,a1
  800232:	02bb6663          	bltu	s6,a1,80025e <vprintfmt+0x98>
  800236:	058a                	slli	a1,a1,0x2
  800238:	95d6                	add	a1,a1,s5
  80023a:	4198                	lw	a4,0(a1)
  80023c:	9756                	add	a4,a4,s5
  80023e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800240:	70e6                	ld	ra,120(sp)
  800242:	7446                	ld	s0,112(sp)
  800244:	74a6                	ld	s1,104(sp)
  800246:	7906                	ld	s2,96(sp)
  800248:	69e6                	ld	s3,88(sp)
  80024a:	6a46                	ld	s4,80(sp)
  80024c:	6aa6                	ld	s5,72(sp)
  80024e:	6b06                	ld	s6,64(sp)
  800250:	7be2                	ld	s7,56(sp)
  800252:	7c42                	ld	s8,48(sp)
  800254:	7ca2                	ld	s9,40(sp)
  800256:	7d02                	ld	s10,32(sp)
  800258:	6de2                	ld	s11,24(sp)
  80025a:	6109                	addi	sp,sp,128
  80025c:	8082                	ret
            putch('%', putdat);
  80025e:	85a6                	mv	a1,s1
  800260:	02500513          	li	a0,37
  800264:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800266:	fff44783          	lbu	a5,-1(s0)
  80026a:	02500713          	li	a4,37
  80026e:	8c22                	mv	s8,s0
  800270:	f8e785e3          	beq	a5,a4,8001fa <vprintfmt+0x34>
  800274:	ffec4783          	lbu	a5,-2(s8)
  800278:	1c7d                	addi	s8,s8,-1
  80027a:	fee79de3          	bne	a5,a4,800274 <vprintfmt+0xae>
  80027e:	bfb5                	j	8001fa <vprintfmt+0x34>
                ch = *fmt;
  800280:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800284:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800286:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80028a:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  80028e:	8462                	mv	s0,s8
                ch = *fmt;
  800290:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  800292:	02e56463          	bltu	a0,a4,8002ba <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  800296:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80029a:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80029e:	0197073b          	addw	a4,a4,s9
  8002a2:	0017171b          	slliw	a4,a4,0x1
  8002a6:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  8002a8:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002ac:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002ae:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002b2:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  8002b6:	feb570e3          	bgeu	a0,a1,800296 <vprintfmt+0xd0>
            if (width < 0)
  8002ba:	f60d54e3          	bgez	s10,800222 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002be:	8d66                	mv	s10,s9
  8002c0:	5cfd                	li	s9,-1
  8002c2:	b785                	j	800222 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002c4:	8db6                	mv	s11,a3
  8002c6:	8462                	mv	s0,s8
  8002c8:	bfa9                	j	800222 <vprintfmt+0x5c>
  8002ca:	8462                	mv	s0,s8
            altflag = 1;
  8002cc:	4b85                	li	s7,1
            goto reswitch;
  8002ce:	bf91                	j	800222 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002d0:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002d2:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002d6:	00c7c463          	blt	a5,a2,8002de <vprintfmt+0x118>
    else if (lflag) {
  8002da:	18060763          	beqz	a2,800468 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  8002de:	000a3603          	ld	a2,0(s4)
  8002e2:	46c1                	li	a3,16
  8002e4:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002e6:	000d879b          	sext.w	a5,s11
  8002ea:	876a                	mv	a4,s10
  8002ec:	85a6                	mv	a1,s1
  8002ee:	854a                	mv	a0,s2
  8002f0:	e69ff0ef          	jal	800158 <printnum>
            break;
  8002f4:	b719                	j	8001fa <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002f6:	000a2503          	lw	a0,0(s4)
  8002fa:	85a6                	mv	a1,s1
  8002fc:	0a21                	addi	s4,s4,8
  8002fe:	9902                	jalr	s2
            break;
  800300:	bded                	j	8001fa <vprintfmt+0x34>
    if (lflag >= 2) {
  800302:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800304:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800308:	00c7c463          	blt	a5,a2,800310 <vprintfmt+0x14a>
    else if (lflag) {
  80030c:	14060963          	beqz	a2,80045e <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  800310:	000a3603          	ld	a2,0(s4)
  800314:	46a9                	li	a3,10
  800316:	8a3a                	mv	s4,a4
  800318:	b7f9                	j	8002e6 <vprintfmt+0x120>
            putch('0', putdat);
  80031a:	85a6                	mv	a1,s1
  80031c:	03000513          	li	a0,48
  800320:	9902                	jalr	s2
            putch('x', putdat);
  800322:	85a6                	mv	a1,s1
  800324:	07800513          	li	a0,120
  800328:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032a:	000a3603          	ld	a2,0(s4)
            goto number;
  80032e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800330:	0a21                	addi	s4,s4,8
            goto number;
  800332:	bf55                	j	8002e6 <vprintfmt+0x120>
            putch(ch, putdat);
  800334:	85a6                	mv	a1,s1
  800336:	02500513          	li	a0,37
  80033a:	9902                	jalr	s2
            break;
  80033c:	bd7d                	j	8001fa <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80033e:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800342:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800344:	0a21                	addi	s4,s4,8
            goto process_precision;
  800346:	bf95                	j	8002ba <vprintfmt+0xf4>
    if (lflag >= 2) {
  800348:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80034a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80034e:	00c7c463          	blt	a5,a2,800356 <vprintfmt+0x190>
    else if (lflag) {
  800352:	10060163          	beqz	a2,800454 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  800356:	000a3603          	ld	a2,0(s4)
  80035a:	46a1                	li	a3,8
  80035c:	8a3a                	mv	s4,a4
  80035e:	b761                	j	8002e6 <vprintfmt+0x120>
            if (width < 0)
  800360:	87ea                	mv	a5,s10
  800362:	000d5363          	bgez	s10,800368 <vprintfmt+0x1a2>
  800366:	4781                	li	a5,0
  800368:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80036c:	8462                	mv	s0,s8
            goto reswitch;
  80036e:	bd55                	j	800222 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800370:	000a3703          	ld	a4,0(s4)
  800374:	12070b63          	beqz	a4,8004aa <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  800378:	0da05563          	blez	s10,800442 <vprintfmt+0x27c>
  80037c:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800380:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  800384:	14fd9a63          	bne	s11,a5,8004d8 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800388:	00074783          	lbu	a5,0(a4)
  80038c:	0007851b          	sext.w	a0,a5
  800390:	c785                	beqz	a5,8003b8 <vprintfmt+0x1f2>
  800392:	5dfd                	li	s11,-1
  800394:	000cc563          	bltz	s9,80039e <vprintfmt+0x1d8>
  800398:	3cfd                	addiw	s9,s9,-1
  80039a:	01bc8d63          	beq	s9,s11,8003b4 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  80039e:	0c0b9a63          	bnez	s7,800472 <vprintfmt+0x2ac>
                    putch(ch, putdat);
  8003a2:	85a6                	mv	a1,s1
  8003a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a6:	00044783          	lbu	a5,0(s0)
  8003aa:	0405                	addi	s0,s0,1
  8003ac:	3d7d                	addiw	s10,s10,-1
  8003ae:	0007851b          	sext.w	a0,a5
  8003b2:	f3ed                	bnez	a5,800394 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  8003b4:	01a05963          	blez	s10,8003c6 <vprintfmt+0x200>
                putch(' ', putdat);
  8003b8:	85a6                	mv	a1,s1
  8003ba:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003be:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003c0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c2:	fe0d1be3          	bnez	s10,8003b8 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c6:	0a21                	addi	s4,s4,8
  8003c8:	bd0d                	j	8001fa <vprintfmt+0x34>
    if (lflag >= 2) {
  8003ca:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003cc:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003d0:	00c7c363          	blt	a5,a2,8003d6 <vprintfmt+0x210>
    else if (lflag) {
  8003d4:	c625                	beqz	a2,80043c <vprintfmt+0x276>
        return va_arg(*ap, long);
  8003d6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003da:	0a044f63          	bltz	s0,800498 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  8003de:	8622                	mv	a2,s0
  8003e0:	8a5e                	mv	s4,s7
  8003e2:	46a9                	li	a3,10
  8003e4:	b709                	j	8002e6 <vprintfmt+0x120>
            if (err < 0) {
  8003e6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ea:	4661                	li	a2,24
            if (err < 0) {
  8003ec:	41f7d71b          	sraiw	a4,a5,0x1f
  8003f0:	8fb9                	xor	a5,a5,a4
  8003f2:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f6:	02d64663          	blt	a2,a3,800422 <vprintfmt+0x25c>
  8003fa:	00000797          	auipc	a5,0x0
  8003fe:	59678793          	addi	a5,a5,1430 # 800990 <error_string>
  800402:	00369713          	slli	a4,a3,0x3
  800406:	97ba                	add	a5,a5,a4
  800408:	639c                	ld	a5,0(a5)
  80040a:	cf81                	beqz	a5,800422 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  80040c:	86be                	mv	a3,a5
  80040e:	00000617          	auipc	a2,0x0
  800412:	29a60613          	addi	a2,a2,666 # 8006a8 <main+0x15e>
  800416:	85a6                	mv	a1,s1
  800418:	854a                	mv	a0,s2
  80041a:	0f4000ef          	jal	80050e <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  80041e:	0a21                	addi	s4,s4,8
  800420:	bbe9                	j	8001fa <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800422:	00000617          	auipc	a2,0x0
  800426:	27660613          	addi	a2,a2,630 # 800698 <main+0x14e>
  80042a:	85a6                	mv	a1,s1
  80042c:	854a                	mv	a0,s2
  80042e:	0e0000ef          	jal	80050e <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800432:	0a21                	addi	s4,s4,8
  800434:	b3d9                	j	8001fa <vprintfmt+0x34>
            lflag ++;
  800436:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800438:	8462                	mv	s0,s8
            goto reswitch;
  80043a:	b3e5                	j	800222 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80043c:	000a2403          	lw	s0,0(s4)
  800440:	bf69                	j	8003da <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800442:	00074783          	lbu	a5,0(a4)
  800446:	0007851b          	sext.w	a0,a5
  80044a:	dfb5                	beqz	a5,8003c6 <vprintfmt+0x200>
  80044c:	00170413          	addi	s0,a4,1
  800450:	5dfd                	li	s11,-1
  800452:	b789                	j	800394 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  800454:	000a6603          	lwu	a2,0(s4)
  800458:	46a1                	li	a3,8
  80045a:	8a3a                	mv	s4,a4
  80045c:	b569                	j	8002e6 <vprintfmt+0x120>
  80045e:	000a6603          	lwu	a2,0(s4)
  800462:	46a9                	li	a3,10
  800464:	8a3a                	mv	s4,a4
  800466:	b541                	j	8002e6 <vprintfmt+0x120>
  800468:	000a6603          	lwu	a2,0(s4)
  80046c:	46c1                	li	a3,16
  80046e:	8a3a                	mv	s4,a4
  800470:	bd9d                	j	8002e6 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  800472:	3781                	addiw	a5,a5,-32
  800474:	05e00713          	li	a4,94
  800478:	f2f775e3          	bgeu	a4,a5,8003a2 <vprintfmt+0x1dc>
                    putch('?', putdat);
  80047c:	03f00513          	li	a0,63
  800480:	85a6                	mv	a1,s1
  800482:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	00044783          	lbu	a5,0(s0)
  800488:	0405                	addi	s0,s0,1
  80048a:	3d7d                	addiw	s10,s10,-1
  80048c:	0007851b          	sext.w	a0,a5
  800490:	d395                	beqz	a5,8003b4 <vprintfmt+0x1ee>
  800492:	f00cd3e3          	bgez	s9,800398 <vprintfmt+0x1d2>
  800496:	bff1                	j	800472 <vprintfmt+0x2ac>
                putch('-', putdat);
  800498:	85a6                	mv	a1,s1
  80049a:	02d00513          	li	a0,45
  80049e:	9902                	jalr	s2
                num = -(long long)num;
  8004a0:	40800633          	neg	a2,s0
  8004a4:	8a5e                	mv	s4,s7
  8004a6:	46a9                	li	a3,10
  8004a8:	bd3d                	j	8002e6 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004aa:	01a05663          	blez	s10,8004b6 <vprintfmt+0x2f0>
  8004ae:	02d00793          	li	a5,45
  8004b2:	00fd9b63          	bne	s11,a5,8004c8 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b6:	02800793          	li	a5,40
  8004ba:	853e                	mv	a0,a5
  8004bc:	00000417          	auipc	s0,0x0
  8004c0:	1d540413          	addi	s0,s0,469 # 800691 <main+0x147>
  8004c4:	5dfd                	li	s11,-1
  8004c6:	b5f9                	j	800394 <vprintfmt+0x1ce>
  8004c8:	00000417          	auipc	s0,0x0
  8004cc:	1c940413          	addi	s0,s0,457 # 800691 <main+0x147>
                p = "(null)";
  8004d0:	00000717          	auipc	a4,0x0
  8004d4:	1c070713          	addi	a4,a4,448 # 800690 <main+0x146>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d8:	853a                	mv	a0,a4
  8004da:	85e6                	mv	a1,s9
  8004dc:	e43a                	sd	a4,8(sp)
  8004de:	050000ef          	jal	80052e <strnlen>
  8004e2:	40ad0d3b          	subw	s10,s10,a0
  8004e6:	6722                	ld	a4,8(sp)
  8004e8:	01a05b63          	blez	s10,8004fe <vprintfmt+0x338>
                    putch(padc, putdat);
  8004ec:	2d81                	sext.w	s11,s11
  8004ee:	85a6                	mv	a1,s1
  8004f0:	856e                	mv	a0,s11
  8004f2:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f4:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004f6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f8:	6722                	ld	a4,8(sp)
  8004fa:	fe0d1ae3          	bnez	s10,8004ee <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fe:	00074783          	lbu	a5,0(a4)
  800502:	0007851b          	sext.w	a0,a5
  800506:	ec0780e3          	beqz	a5,8003c6 <vprintfmt+0x200>
  80050a:	5dfd                	li	s11,-1
  80050c:	b561                	j	800394 <vprintfmt+0x1ce>

000000000080050e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800510:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800514:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800516:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	ec06                	sd	ra,24(sp)
  80051a:	f83a                	sd	a4,48(sp)
  80051c:	fc3e                	sd	a5,56(sp)
  80051e:	e0c2                	sd	a6,64(sp)
  800520:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800522:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800524:	ca3ff0ef          	jal	8001c6 <vprintfmt>
}
  800528:	60e2                	ld	ra,24(sp)
  80052a:	6161                	addi	sp,sp,80
  80052c:	8082                	ret

000000000080052e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80052e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800530:	e589                	bnez	a1,80053a <strnlen+0xc>
  800532:	a811                	j	800546 <strnlen+0x18>
        cnt ++;
  800534:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800536:	00f58863          	beq	a1,a5,800546 <strnlen+0x18>
  80053a:	00f50733          	add	a4,a0,a5
  80053e:	00074703          	lbu	a4,0(a4)
  800542:	fb6d                	bnez	a4,800534 <strnlen+0x6>
  800544:	85be                	mv	a1,a5
    }
    return cnt;
}
  800546:	852e                	mv	a0,a1
  800548:	8082                	ret

000000000080054a <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80054a:	1101                	addi	sp,sp,-32
  80054c:	ec06                	sd	ra,24(sp)
  80054e:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800550:	bf7ff0ef          	jal	800146 <fork>
  800554:	c169                	beqz	a0,800616 <main+0xcc>
  800556:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  800558:	0aa05063          	blez	a0,8005f8 <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  80055c:	4581                	li	a1,0
  80055e:	557d                	li	a0,-1
  800560:	be9ff0ef          	jal	800148 <waitpid>
  800564:	c93d                	beqz	a0,8005da <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  800566:	458d                	li	a1,3
  800568:	05fa                	slli	a1,a1,0x1e
  80056a:	8522                	mv	a0,s0
  80056c:	bddff0ef          	jal	800148 <waitpid>
  800570:	c531                	beqz	a0,8005bc <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  800572:	8522                	mv	a0,s0
  800574:	006c                	addi	a1,sp,12
  800576:	bd3ff0ef          	jal	800148 <waitpid>
  80057a:	e115                	bnez	a0,80059e <main+0x54>
  80057c:	4732                	lw	a4,12(sp)
  80057e:	67b1                	lui	a5,0xc
  800580:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  800584:	00f71d63          	bne	a4,a5,80059e <main+0x54>
    cprintf("badarg pass.\n");
  800588:	00000517          	auipc	a0,0x0
  80058c:	2a050513          	addi	a0,a0,672 # 800828 <main+0x2de>
  800590:	b15ff0ef          	jal	8000a4 <cprintf>
    return 0;
}
  800594:	60e2                	ld	ra,24(sp)
  800596:	6442                	ld	s0,16(sp)
  800598:	4501                	li	a0,0
  80059a:	6105                	addi	sp,sp,32
  80059c:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  80059e:	00000697          	auipc	a3,0x0
  8005a2:	25268693          	addi	a3,a3,594 # 8007f0 <main+0x2a6>
  8005a6:	00000617          	auipc	a2,0x0
  8005aa:	1e260613          	addi	a2,a2,482 # 800788 <main+0x23e>
  8005ae:	45c9                	li	a1,18
  8005b0:	00000517          	auipc	a0,0x0
  8005b4:	1f050513          	addi	a0,a0,496 # 8007a0 <main+0x256>
  8005b8:	a6fff0ef          	jal	800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005bc:	00000697          	auipc	a3,0x0
  8005c0:	20c68693          	addi	a3,a3,524 # 8007c8 <main+0x27e>
  8005c4:	00000617          	auipc	a2,0x0
  8005c8:	1c460613          	addi	a2,a2,452 # 800788 <main+0x23e>
  8005cc:	45c5                	li	a1,17
  8005ce:	00000517          	auipc	a0,0x0
  8005d2:	1d250513          	addi	a0,a0,466 # 8007a0 <main+0x256>
  8005d6:	a51ff0ef          	jal	800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8005da:	00000697          	auipc	a3,0x0
  8005de:	1d668693          	addi	a3,a3,470 # 8007b0 <main+0x266>
  8005e2:	00000617          	auipc	a2,0x0
  8005e6:	1a660613          	addi	a2,a2,422 # 800788 <main+0x23e>
  8005ea:	45c1                	li	a1,16
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	1b450513          	addi	a0,a0,436 # 8007a0 <main+0x256>
  8005f4:	a33ff0ef          	jal	800026 <__panic>
    assert(pid > 0);
  8005f8:	00000697          	auipc	a3,0x0
  8005fc:	18868693          	addi	a3,a3,392 # 800780 <main+0x236>
  800600:	00000617          	auipc	a2,0x0
  800604:	18860613          	addi	a2,a2,392 # 800788 <main+0x23e>
  800608:	45bd                	li	a1,15
  80060a:	00000517          	auipc	a0,0x0
  80060e:	19650513          	addi	a0,a0,406 # 8007a0 <main+0x256>
  800612:	a15ff0ef          	jal	800026 <__panic>
        cprintf("fork ok.\n");
  800616:	00000517          	auipc	a0,0x0
  80061a:	15a50513          	addi	a0,a0,346 # 800770 <main+0x226>
  80061e:	a87ff0ef          	jal	8000a4 <cprintf>
  800622:	4429                	li	s0,10
        for (i = 0; i < 10; i ++) {
  800624:	347d                	addiw	s0,s0,-1
            yield();
  800626:	b25ff0ef          	jal	80014a <yield>
        for (i = 0; i < 10; i ++) {
  80062a:	fc6d                	bnez	s0,800624 <main+0xda>
        exit(0xbeaf);
  80062c:	6531                	lui	a0,0xc
  80062e:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  800632:	affff0ef          	jal	800130 <exit>
