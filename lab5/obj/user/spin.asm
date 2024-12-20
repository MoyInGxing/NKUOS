
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	134000ef          	jal	800154 <umain>
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
  800034:	5f050513          	addi	a0,a0,1520 # 800620 <main+0xce>
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
  80005c:	5e850513          	addi	a0,a0,1512 # 800640 <main+0xee>
  800060:	044000ef          	jal	8000a4 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	5559                	li	a0,-10
  800066:	0d0000ef          	jal	800136 <exit>

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
  800072:	0be000ef          	jal	800130 <sys_putc>
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
  800098:	136000ef          	jal	8001ce <vprintfmt>
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
  8000cc:	102000ef          	jal	8001ce <vprintfmt>
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

0000000000800130 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800130:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800132:	4579                	li	a0,30
  800134:	b755                	j	8000d8 <syscall>

0000000000800136 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800136:	1141                	addi	sp,sp,-16
  800138:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80013a:	fdbff0ef          	jal	800114 <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013e:	00000517          	auipc	a0,0x0
  800142:	50a50513          	addi	a0,a0,1290 # 800648 <main+0xf6>
  800146:	f5fff0ef          	jal	8000a4 <cprintf>
    while (1);
  80014a:	a001                	j	80014a <exit+0x14>

000000000080014c <fork>:
}

int
fork(void) {
    return sys_fork();
  80014c:	b7f9                	j	80011a <sys_fork>

000000000080014e <waitpid>:
    return sys_wait(0, NULL);
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

0000000000800152 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800152:	bfe1                	j	80012a <sys_kill>

0000000000800154 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800154:	1141                	addi	sp,sp,-16
  800156:	e406                	sd	ra,8(sp)
    int ret = main();
  800158:	3fa000ef          	jal	800552 <main>
    exit(ret);
  80015c:	fdbff0ef          	jal	800136 <exit>

0000000000800160 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800160:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800166:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	f022                	sd	s0,32(sp)
  800172:	ec26                	sd	s1,24(sp)
  800174:	e84a                	sd	s2,16(sp)
  800176:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800178:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80017c:	84aa                	mv	s1,a0
  80017e:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
  800180:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800182:	05067063          	bgeu	a2,a6,8001c2 <printnum+0x62>
  800186:	e44e                	sd	s3,8(sp)
  800188:	89be                	mv	s3,a5
        while (-- width > 0)
  80018a:	4785                	li	a5,1
  80018c:	00e7d763          	bge	a5,a4,80019a <printnum+0x3a>
            putch(padc, putdat);
  800190:	85ca                	mv	a1,s2
  800192:	854e                	mv	a0,s3
        while (-- width > 0)
  800194:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800196:	9482                	jalr	s1
        while (-- width > 0)
  800198:	fc65                	bnez	s0,800190 <printnum+0x30>
  80019a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019c:	1a02                	slli	s4,s4,0x20
  80019e:	020a5a13          	srli	s4,s4,0x20
  8001a2:	00000797          	auipc	a5,0x0
  8001a6:	4be78793          	addi	a5,a5,1214 # 800660 <main+0x10e>
  8001aa:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001ac:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	0007c503          	lbu	a0,0(a5)
}
  8001b2:	70a2                	ld	ra,40(sp)
  8001b4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	85ca                	mv	a1,s2
  8001b8:	87a6                	mv	a5,s1
}
  8001ba:	6942                	ld	s2,16(sp)
  8001bc:	64e2                	ld	s1,24(sp)
  8001be:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001c0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c2:	03065633          	divu	a2,a2,a6
  8001c6:	8722                	mv	a4,s0
  8001c8:	f99ff0ef          	jal	800160 <printnum>
  8001cc:	bfc1                	j	80019c <printnum+0x3c>

00000000008001ce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ce:	7119                	addi	sp,sp,-128
  8001d0:	f4a6                	sd	s1,104(sp)
  8001d2:	f0ca                	sd	s2,96(sp)
  8001d4:	ecce                	sd	s3,88(sp)
  8001d6:	e8d2                	sd	s4,80(sp)
  8001d8:	e4d6                	sd	s5,72(sp)
  8001da:	e0da                	sd	s6,64(sp)
  8001dc:	f862                	sd	s8,48(sp)
  8001de:	fc86                	sd	ra,120(sp)
  8001e0:	f8a2                	sd	s0,112(sp)
  8001e2:	fc5e                	sd	s7,56(sp)
  8001e4:	f466                	sd	s9,40(sp)
  8001e6:	f06a                	sd	s10,32(sp)
  8001e8:	ec6e                	sd	s11,24(sp)
  8001ea:	892a                	mv	s2,a0
  8001ec:	84ae                	mv	s1,a1
  8001ee:	8c32                	mv	s8,a2
  8001f0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f2:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f6:	05500b13          	li	s6,85
  8001fa:	00000a97          	auipc	s5,0x0
  8001fe:	696a8a93          	addi	s5,s5,1686 # 800890 <main+0x33e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	000c4503          	lbu	a0,0(s8)
  800206:	001c0413          	addi	s0,s8,1
  80020a:	01350a63          	beq	a0,s3,80021e <vprintfmt+0x50>
            if (ch == '\0') {
  80020e:	cd0d                	beqz	a0,800248 <vprintfmt+0x7a>
            putch(ch, putdat);
  800210:	85a6                	mv	a1,s1
  800212:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	00044503          	lbu	a0,0(s0)
  800218:	0405                	addi	s0,s0,1
  80021a:	ff351ae3          	bne	a0,s3,80020e <vprintfmt+0x40>
        width = precision = -1;
  80021e:	5cfd                	li	s9,-1
  800220:	8d66                	mv	s10,s9
        char padc = ' ';
  800222:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800226:	4b81                	li	s7,0
  800228:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
  80022a:	00044683          	lbu	a3,0(s0)
  80022e:	00140c13          	addi	s8,s0,1
  800232:	fdd6859b          	addiw	a1,a3,-35
  800236:	0ff5f593          	zext.b	a1,a1
  80023a:	02bb6663          	bltu	s6,a1,800266 <vprintfmt+0x98>
  80023e:	058a                	slli	a1,a1,0x2
  800240:	95d6                	add	a1,a1,s5
  800242:	4198                	lw	a4,0(a1)
  800244:	9756                	add	a4,a4,s5
  800246:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800248:	70e6                	ld	ra,120(sp)
  80024a:	7446                	ld	s0,112(sp)
  80024c:	74a6                	ld	s1,104(sp)
  80024e:	7906                	ld	s2,96(sp)
  800250:	69e6                	ld	s3,88(sp)
  800252:	6a46                	ld	s4,80(sp)
  800254:	6aa6                	ld	s5,72(sp)
  800256:	6b06                	ld	s6,64(sp)
  800258:	7be2                	ld	s7,56(sp)
  80025a:	7c42                	ld	s8,48(sp)
  80025c:	7ca2                	ld	s9,40(sp)
  80025e:	7d02                	ld	s10,32(sp)
  800260:	6de2                	ld	s11,24(sp)
  800262:	6109                	addi	sp,sp,128
  800264:	8082                	ret
            putch('%', putdat);
  800266:	85a6                	mv	a1,s1
  800268:	02500513          	li	a0,37
  80026c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80026e:	fff44783          	lbu	a5,-1(s0)
  800272:	02500713          	li	a4,37
  800276:	8c22                	mv	s8,s0
  800278:	f8e785e3          	beq	a5,a4,800202 <vprintfmt+0x34>
  80027c:	ffec4783          	lbu	a5,-2(s8)
  800280:	1c7d                	addi	s8,s8,-1
  800282:	fee79de3          	bne	a5,a4,80027c <vprintfmt+0xae>
  800286:	bfb5                	j	800202 <vprintfmt+0x34>
                ch = *fmt;
  800288:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80028c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80028e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800292:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	8462                	mv	s0,s8
                ch = *fmt;
  800298:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
  80029a:	02e56463          	bltu	a0,a4,8002c2 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
  80029e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  8002a2:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002a6:	0197073b          	addw	a4,a4,s9
  8002aa:	0017171b          	slliw	a4,a4,0x1
  8002ae:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
  8002b0:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002b4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ba:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
  8002be:	feb570e3          	bgeu	a0,a1,80029e <vprintfmt+0xd0>
            if (width < 0)
  8002c2:	f60d54e3          	bgez	s10,80022a <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002c6:	8d66                	mv	s10,s9
  8002c8:	5cfd                	li	s9,-1
  8002ca:	b785                	j	80022a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002cc:	8db6                	mv	s11,a3
  8002ce:	8462                	mv	s0,s8
  8002d0:	bfa9                	j	80022a <vprintfmt+0x5c>
  8002d2:	8462                	mv	s0,s8
            altflag = 1;
  8002d4:	4b85                	li	s7,1
            goto reswitch;
  8002d6:	bf91                	j	80022a <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002d8:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002da:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002de:	00c7c463          	blt	a5,a2,8002e6 <vprintfmt+0x118>
    else if (lflag) {
  8002e2:	18060763          	beqz	a2,800470 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
  8002e6:	000a3603          	ld	a2,0(s4)
  8002ea:	46c1                	li	a3,16
  8002ec:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002ee:	000d879b          	sext.w	a5,s11
  8002f2:	876a                	mv	a4,s10
  8002f4:	85a6                	mv	a1,s1
  8002f6:	854a                	mv	a0,s2
  8002f8:	e69ff0ef          	jal	800160 <printnum>
            break;
  8002fc:	b719                	j	800202 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002fe:	000a2503          	lw	a0,0(s4)
  800302:	85a6                	mv	a1,s1
  800304:	0a21                	addi	s4,s4,8
  800306:	9902                	jalr	s2
            break;
  800308:	bded                	j	800202 <vprintfmt+0x34>
    if (lflag >= 2) {
  80030a:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80030c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800310:	00c7c463          	blt	a5,a2,800318 <vprintfmt+0x14a>
    else if (lflag) {
  800314:	14060963          	beqz	a2,800466 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
  800318:	000a3603          	ld	a2,0(s4)
  80031c:	46a9                	li	a3,10
  80031e:	8a3a                	mv	s4,a4
  800320:	b7f9                	j	8002ee <vprintfmt+0x120>
            putch('0', putdat);
  800322:	85a6                	mv	a1,s1
  800324:	03000513          	li	a0,48
  800328:	9902                	jalr	s2
            putch('x', putdat);
  80032a:	85a6                	mv	a1,s1
  80032c:	07800513          	li	a0,120
  800330:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800332:	000a3603          	ld	a2,0(s4)
            goto number;
  800336:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800338:	0a21                	addi	s4,s4,8
            goto number;
  80033a:	bf55                	j	8002ee <vprintfmt+0x120>
            putch(ch, putdat);
  80033c:	85a6                	mv	a1,s1
  80033e:	02500513          	li	a0,37
  800342:	9902                	jalr	s2
            break;
  800344:	bd7d                	j	800202 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800346:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80034c:	0a21                	addi	s4,s4,8
            goto process_precision;
  80034e:	bf95                	j	8002c2 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800350:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800352:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800356:	00c7c463          	blt	a5,a2,80035e <vprintfmt+0x190>
    else if (lflag) {
  80035a:	10060163          	beqz	a2,80045c <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
  80035e:	000a3603          	ld	a2,0(s4)
  800362:	46a1                	li	a3,8
  800364:	8a3a                	mv	s4,a4
  800366:	b761                	j	8002ee <vprintfmt+0x120>
            if (width < 0)
  800368:	87ea                	mv	a5,s10
  80036a:	000d5363          	bgez	s10,800370 <vprintfmt+0x1a2>
  80036e:	4781                	li	a5,0
  800370:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800374:	8462                	mv	s0,s8
            goto reswitch;
  800376:	bd55                	j	80022a <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800378:	000a3703          	ld	a4,0(s4)
  80037c:	12070b63          	beqz	a4,8004b2 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
  800380:	0da05563          	blez	s10,80044a <vprintfmt+0x27c>
  800384:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800388:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
  80038c:	14fd9a63          	bne	s11,a5,8004e0 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800390:	00074783          	lbu	a5,0(a4)
  800394:	0007851b          	sext.w	a0,a5
  800398:	c785                	beqz	a5,8003c0 <vprintfmt+0x1f2>
  80039a:	5dfd                	li	s11,-1
  80039c:	000cc563          	bltz	s9,8003a6 <vprintfmt+0x1d8>
  8003a0:	3cfd                	addiw	s9,s9,-1
  8003a2:	01bc8d63          	beq	s9,s11,8003bc <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a6:	0c0b9a63          	bnez	s7,80047a <vprintfmt+0x2ac>
                    putch(ch, putdat);
  8003aa:	85a6                	mv	a1,s1
  8003ac:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ae:	00044783          	lbu	a5,0(s0)
  8003b2:	0405                	addi	s0,s0,1
  8003b4:	3d7d                	addiw	s10,s10,-1
  8003b6:	0007851b          	sext.w	a0,a5
  8003ba:	f3ed                	bnez	a5,80039c <vprintfmt+0x1ce>
            for (; width > 0; width --) {
  8003bc:	01a05963          	blez	s10,8003ce <vprintfmt+0x200>
                putch(' ', putdat);
  8003c0:	85a6                	mv	a1,s1
  8003c2:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c6:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003c8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ca:	fe0d1be3          	bnez	s10,8003c0 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ce:	0a21                	addi	s4,s4,8
  8003d0:	bd0d                	j	800202 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003d2:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003d4:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003d8:	00c7c363          	blt	a5,a2,8003de <vprintfmt+0x210>
    else if (lflag) {
  8003dc:	c625                	beqz	a2,800444 <vprintfmt+0x276>
        return va_arg(*ap, long);
  8003de:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003e2:	0a044f63          	bltz	s0,8004a0 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
  8003e6:	8622                	mv	a2,s0
  8003e8:	8a5e                	mv	s4,s7
  8003ea:	46a9                	li	a3,10
  8003ec:	b709                	j	8002ee <vprintfmt+0x120>
            if (err < 0) {
  8003ee:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f2:	4661                	li	a2,24
            if (err < 0) {
  8003f4:	41f7d71b          	sraiw	a4,a5,0x1f
  8003f8:	8fb9                	xor	a5,a5,a4
  8003fa:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003fe:	02d64663          	blt	a2,a3,80042a <vprintfmt+0x25c>
  800402:	00000797          	auipc	a5,0x0
  800406:	5e678793          	addi	a5,a5,1510 # 8009e8 <error_string>
  80040a:	00369713          	slli	a4,a3,0x3
  80040e:	97ba                	add	a5,a5,a4
  800410:	639c                	ld	a5,0(a5)
  800412:	cf81                	beqz	a5,80042a <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
  800414:	86be                	mv	a3,a5
  800416:	00000617          	auipc	a2,0x0
  80041a:	27a60613          	addi	a2,a2,634 # 800690 <main+0x13e>
  80041e:	85a6                	mv	a1,s1
  800420:	854a                	mv	a0,s2
  800422:	0f4000ef          	jal	800516 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  800426:	0a21                	addi	s4,s4,8
  800428:	bbe9                	j	800202 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80042a:	00000617          	auipc	a2,0x0
  80042e:	25660613          	addi	a2,a2,598 # 800680 <main+0x12e>
  800432:	85a6                	mv	a1,s1
  800434:	854a                	mv	a0,s2
  800436:	0e0000ef          	jal	800516 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
  80043a:	0a21                	addi	s4,s4,8
  80043c:	b3d9                	j	800202 <vprintfmt+0x34>
            lflag ++;
  80043e:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800440:	8462                	mv	s0,s8
            goto reswitch;
  800442:	b3e5                	j	80022a <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800444:	000a2403          	lw	s0,0(s4)
  800448:	bf69                	j	8003e2 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044a:	00074783          	lbu	a5,0(a4)
  80044e:	0007851b          	sext.w	a0,a5
  800452:	dfb5                	beqz	a5,8003ce <vprintfmt+0x200>
  800454:	00170413          	addi	s0,a4,1
  800458:	5dfd                	li	s11,-1
  80045a:	b789                	j	80039c <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
  80045c:	000a6603          	lwu	a2,0(s4)
  800460:	46a1                	li	a3,8
  800462:	8a3a                	mv	s4,a4
  800464:	b569                	j	8002ee <vprintfmt+0x120>
  800466:	000a6603          	lwu	a2,0(s4)
  80046a:	46a9                	li	a3,10
  80046c:	8a3a                	mv	s4,a4
  80046e:	b541                	j	8002ee <vprintfmt+0x120>
  800470:	000a6603          	lwu	a2,0(s4)
  800474:	46c1                	li	a3,16
  800476:	8a3a                	mv	s4,a4
  800478:	bd9d                	j	8002ee <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
  80047a:	3781                	addiw	a5,a5,-32
  80047c:	05e00713          	li	a4,94
  800480:	f2f775e3          	bgeu	a4,a5,8003aa <vprintfmt+0x1dc>
                    putch('?', putdat);
  800484:	03f00513          	li	a0,63
  800488:	85a6                	mv	a1,s1
  80048a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048c:	00044783          	lbu	a5,0(s0)
  800490:	0405                	addi	s0,s0,1
  800492:	3d7d                	addiw	s10,s10,-1
  800494:	0007851b          	sext.w	a0,a5
  800498:	d395                	beqz	a5,8003bc <vprintfmt+0x1ee>
  80049a:	f00cd3e3          	bgez	s9,8003a0 <vprintfmt+0x1d2>
  80049e:	bff1                	j	80047a <vprintfmt+0x2ac>
                putch('-', putdat);
  8004a0:	85a6                	mv	a1,s1
  8004a2:	02d00513          	li	a0,45
  8004a6:	9902                	jalr	s2
                num = -(long long)num;
  8004a8:	40800633          	neg	a2,s0
  8004ac:	8a5e                	mv	s4,s7
  8004ae:	46a9                	li	a3,10
  8004b0:	bd3d                	j	8002ee <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004b2:	01a05663          	blez	s10,8004be <vprintfmt+0x2f0>
  8004b6:	02d00793          	li	a5,45
  8004ba:	00fd9b63          	bne	s11,a5,8004d0 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004be:	02800793          	li	a5,40
  8004c2:	853e                	mv	a0,a5
  8004c4:	00000417          	auipc	s0,0x0
  8004c8:	1b540413          	addi	s0,s0,437 # 800679 <main+0x127>
  8004cc:	5dfd                	li	s11,-1
  8004ce:	b5f9                	j	80039c <vprintfmt+0x1ce>
  8004d0:	00000417          	auipc	s0,0x0
  8004d4:	1a940413          	addi	s0,s0,425 # 800679 <main+0x127>
                p = "(null)";
  8004d8:	00000717          	auipc	a4,0x0
  8004dc:	1a070713          	addi	a4,a4,416 # 800678 <main+0x126>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e0:	853a                	mv	a0,a4
  8004e2:	85e6                	mv	a1,s9
  8004e4:	e43a                	sd	a4,8(sp)
  8004e6:	050000ef          	jal	800536 <strnlen>
  8004ea:	40ad0d3b          	subw	s10,s10,a0
  8004ee:	6722                	ld	a4,8(sp)
  8004f0:	01a05b63          	blez	s10,800506 <vprintfmt+0x338>
                    putch(padc, putdat);
  8004f4:	2d81                	sext.w	s11,s11
  8004f6:	85a6                	mv	a1,s1
  8004f8:	856e                	mv	a0,s11
  8004fa:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fc:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004fe:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800500:	6722                	ld	a4,8(sp)
  800502:	fe0d1ae3          	bnez	s10,8004f6 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800506:	00074783          	lbu	a5,0(a4)
  80050a:	0007851b          	sext.w	a0,a5
  80050e:	ec0780e3          	beqz	a5,8003ce <vprintfmt+0x200>
  800512:	5dfd                	li	s11,-1
  800514:	b561                	j	80039c <vprintfmt+0x1ce>

0000000000800516 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800516:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800518:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800520:	ec06                	sd	ra,24(sp)
  800522:	f83a                	sd	a4,48(sp)
  800524:	fc3e                	sd	a5,56(sp)
  800526:	e0c2                	sd	a6,64(sp)
  800528:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80052a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052c:	ca3ff0ef          	jal	8001ce <vprintfmt>
}
  800530:	60e2                	ld	ra,24(sp)
  800532:	6161                	addi	sp,sp,80
  800534:	8082                	ret

0000000000800536 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800536:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800538:	e589                	bnez	a1,800542 <strnlen+0xc>
  80053a:	a811                	j	80054e <strnlen+0x18>
        cnt ++;
  80053c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80053e:	00f58863          	beq	a1,a5,80054e <strnlen+0x18>
  800542:	00f50733          	add	a4,a0,a5
  800546:	00074703          	lbu	a4,0(a4)
  80054a:	fb6d                	bnez	a4,80053c <strnlen+0x6>
  80054c:	85be                	mv	a1,a5
    }
    return cnt;
}
  80054e:	852e                	mv	a0,a1
  800550:	8082                	ret

0000000000800552 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800552:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  800554:	00000517          	auipc	a0,0x0
  800558:	20450513          	addi	a0,a0,516 # 800758 <main+0x206>
main(void) {
  80055c:	e406                	sd	ra,8(sp)
  80055e:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800560:	b45ff0ef          	jal	8000a4 <cprintf>
    if ((pid = fork()) == 0) {
  800564:	be9ff0ef          	jal	80014c <fork>
  800568:	e901                	bnez	a0,800578 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  80056a:	00000517          	auipc	a0,0x0
  80056e:	21650513          	addi	a0,a0,534 # 800780 <main+0x22e>
  800572:	b33ff0ef          	jal	8000a4 <cprintf>
        while (1);
  800576:	a001                	j	800576 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  800578:	842a                	mv	s0,a0
  80057a:	00000517          	auipc	a0,0x0
  80057e:	22650513          	addi	a0,a0,550 # 8007a0 <main+0x24e>
  800582:	b23ff0ef          	jal	8000a4 <cprintf>

    yield();
  800586:	bcbff0ef          	jal	800150 <yield>
    yield();
  80058a:	bc7ff0ef          	jal	800150 <yield>
    yield();
  80058e:	bc3ff0ef          	jal	800150 <yield>

    cprintf("I am the parent.  Killing the child...\n");
  800592:	00000517          	auipc	a0,0x0
  800596:	23650513          	addi	a0,a0,566 # 8007c8 <main+0x276>
  80059a:	b0bff0ef          	jal	8000a4 <cprintf>

    assert((ret = kill(pid)) == 0);
  80059e:	8522                	mv	a0,s0
  8005a0:	bb3ff0ef          	jal	800152 <kill>
  8005a4:	ed31                	bnez	a0,800600 <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005a6:	4581                	li	a1,0
  8005a8:	00000517          	auipc	a0,0x0
  8005ac:	28850513          	addi	a0,a0,648 # 800830 <main+0x2de>
  8005b0:	af5ff0ef          	jal	8000a4 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005b4:	8522                	mv	a0,s0
  8005b6:	4581                	li	a1,0
  8005b8:	b97ff0ef          	jal	80014e <waitpid>
  8005bc:	e11d                	bnez	a0,8005e2 <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005be:	4581                	li	a1,0
  8005c0:	00000517          	auipc	a0,0x0
  8005c4:	2a850513          	addi	a0,a0,680 # 800868 <main+0x316>
  8005c8:	addff0ef          	jal	8000a4 <cprintf>

    cprintf("spin may pass.\n");
  8005cc:	00000517          	auipc	a0,0x0
  8005d0:	2b450513          	addi	a0,a0,692 # 800880 <main+0x32e>
  8005d4:	ad1ff0ef          	jal	8000a4 <cprintf>
    return 0;
}
  8005d8:	60a2                	ld	ra,8(sp)
  8005da:	6402                	ld	s0,0(sp)
  8005dc:	4501                	li	a0,0
  8005de:	0141                	addi	sp,sp,16
  8005e0:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005e2:	00000697          	auipc	a3,0x0
  8005e6:	26668693          	addi	a3,a3,614 # 800848 <main+0x2f6>
  8005ea:	00000617          	auipc	a2,0x0
  8005ee:	21e60613          	addi	a2,a2,542 # 800808 <main+0x2b6>
  8005f2:	45dd                	li	a1,23
  8005f4:	00000517          	auipc	a0,0x0
  8005f8:	22c50513          	addi	a0,a0,556 # 800820 <main+0x2ce>
  8005fc:	a2bff0ef          	jal	800026 <__panic>
    assert((ret = kill(pid)) == 0);
  800600:	00000697          	auipc	a3,0x0
  800604:	1f068693          	addi	a3,a3,496 # 8007f0 <main+0x29e>
  800608:	00000617          	auipc	a2,0x0
  80060c:	20060613          	addi	a2,a2,512 # 800808 <main+0x2b6>
  800610:	45d1                	li	a1,20
  800612:	00000517          	auipc	a0,0x0
  800616:	20e50513          	addi	a0,a0,526 # 800820 <main+0x2ce>
  80061a:	a0dff0ef          	jal	800026 <__panic>
