
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00e50513          	addi	a0,a0,14 # 80204018 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16 # 80203ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	27b000ef          	jal	80200a9c <memset>

    cons_init();  // init the console
    80200026:	146000ef          	jal	8020016c <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a8658593          	addi	a1,a1,-1402 # 80200ab0 <etext+0x2>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a9e50513          	addi	a0,a0,-1378 # 80200ad0 <etext+0x22>
    8020003a:	030000ef          	jal	8020006a <cprintf>

    print_kerninfo();
    8020003e:	060000ef          	jal	8020009e <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13a000ef          	jal	8020017c <idt_init>
    //invalid_function();
    /*__asm__ volatile (
        "EBREAK\n"
    );*/
    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e4000ef          	jal	8020012a <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	12c000ef          	jal	80200176 <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	116000ef          	jal	8020016e <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40
int cprintf(const char *fmt, ...) {
    80200070:	f42e                	sd	a1,40(sp)
    80200072:	f832                	sd	a2,48(sp)
    80200074:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200076:	862a                	mv	a2,a0
    80200078:	004c                	addi	a1,sp,4
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd650513          	addi	a0,a0,-42 # 80200050 <cputch>
    80200082:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200084:	ec06                	sd	ra,24(sp)
    80200086:	e0ba                	sd	a4,64(sp)
    80200088:	e4be                	sd	a5,72(sp)
    8020008a:	e8c2                	sd	a6,80(sp)
    8020008c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020008e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200090:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200092:	626000ef          	jal	802006b8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200096:	60e2                	ld	ra,24(sp)
    80200098:	4512                	lw	a0,4(sp)
    8020009a:	6125                	addi	sp,sp,96
    8020009c:	8082                	ret

000000008020009e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    8020009e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a0:	00001517          	auipc	a0,0x1
    802000a4:	a3850513          	addi	a0,a0,-1480 # 80200ad8 <etext+0x2a>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	a4250513          	addi	a0,a0,-1470 # 80200af8 <etext+0x4a>
    802000be:	fadff0ef          	jal	8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	9ec58593          	addi	a1,a1,-1556 # 80200aae <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	a4e50513          	addi	a0,a0,-1458 # 80200b18 <etext+0x6a>
    802000d2:	f99ff0ef          	jal	8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f4258593          	addi	a1,a1,-190 # 80204018 <ticks>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	a5a50513          	addi	a0,a0,-1446 # 80200b38 <etext+0x8a>
    802000e6:	f85ff0ef          	jal	8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	a6650513          	addi	a0,a0,-1434 # 80200b58 <etext+0xaa>
    802000fa:	f71ff0ef          	jal	8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    802000fe:	00004797          	auipc	a5,0x4
    80200102:	32978793          	addi	a5,a5,809 # 80204427 <end+0x3ff>
    80200106:	00000717          	auipc	a4,0x0
    8020010a:	f0470713          	addi	a4,a4,-252 # 8020000a <kern_init>
    8020010e:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200110:	43f7d593          	srai	a1,a5,0x3f
}
    80200114:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200116:	3ff5f593          	andi	a1,a1,1023
    8020011a:	95be                	add	a1,a1,a5
    8020011c:	85a9                	srai	a1,a1,0xa
    8020011e:	00001517          	auipc	a0,0x1
    80200122:	a5a50513          	addi	a0,a0,-1446 # 80200b78 <etext+0xca>
}
    80200126:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200128:	b789                	j	8020006a <cprintf>

000000008020012a <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012a:	1141                	addi	sp,sp,-16
    8020012c:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020012e:	02000793          	li	a5,32
    80200132:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200136:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013a:	67e1                	lui	a5,0x18
    8020013c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200140:	953e                	add	a0,a0,a5
    80200142:	10b000ef          	jal	80200a4c <sbi_set_timer>
}
    80200146:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200148:	00004797          	auipc	a5,0x4
    8020014c:	ec07b823          	sd	zero,-304(a5) # 80204018 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200150:	00001517          	auipc	a0,0x1
    80200154:	a5850513          	addi	a0,a0,-1448 # 80200ba8 <etext+0xfa>
}
    80200158:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015a:	bf01                	j	8020006a <cprintf>

000000008020015c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020015c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200160:	67e1                	lui	a5,0x18
    80200162:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200166:	953e                	add	a0,a0,a5
    80200168:	0e50006f          	j	80200a4c <sbi_set_timer>

000000008020016c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016c:	8082                	ret

000000008020016e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020016e:	0ff57513          	zext.b	a0,a0
    80200172:	0c10006f          	j	80200a32 <sbi_console_putchar>

0000000080200176 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200176:	100167f3          	csrrsi	a5,sstatus,2
    8020017a:	8082                	ret

000000008020017c <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200180:	00000797          	auipc	a5,0x0
    80200184:	41478793          	addi	a5,a5,1044 # 80200594 <__alltraps>
    80200188:	10579073          	csrw	stvec,a5
}
    8020018c:	8082                	ret

000000008020018e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200190:	1141                	addi	sp,sp,-16
    80200192:	e022                	sd	s0,0(sp)
    80200194:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	00001517          	auipc	a0,0x1
    8020019a:	a3250513          	addi	a0,a0,-1486 # 80200bc8 <etext+0x11a>
void print_regs(struct pushregs *gpr) {
    8020019e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	ecbff0ef          	jal	8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a4:	640c                	ld	a1,8(s0)
    802001a6:	00001517          	auipc	a0,0x1
    802001aa:	a3a50513          	addi	a0,a0,-1478 # 80200be0 <etext+0x132>
    802001ae:	ebdff0ef          	jal	8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b2:	680c                	ld	a1,16(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	a4450513          	addi	a0,a0,-1468 # 80200bf8 <etext+0x14a>
    802001bc:	eafff0ef          	jal	8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c0:	6c0c                	ld	a1,24(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	a4e50513          	addi	a0,a0,-1458 # 80200c10 <etext+0x162>
    802001ca:	ea1ff0ef          	jal	8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001ce:	700c                	ld	a1,32(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	a5850513          	addi	a0,a0,-1448 # 80200c28 <etext+0x17a>
    802001d8:	e93ff0ef          	jal	8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001dc:	740c                	ld	a1,40(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	a6250513          	addi	a0,a0,-1438 # 80200c40 <etext+0x192>
    802001e6:	e85ff0ef          	jal	8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ea:	780c                	ld	a1,48(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	a6c50513          	addi	a0,a0,-1428 # 80200c58 <etext+0x1aa>
    802001f4:	e77ff0ef          	jal	8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f8:	7c0c                	ld	a1,56(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	a7650513          	addi	a0,a0,-1418 # 80200c70 <etext+0x1c2>
    80200202:	e69ff0ef          	jal	8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200206:	602c                	ld	a1,64(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	a8050513          	addi	a0,a0,-1408 # 80200c88 <etext+0x1da>
    80200210:	e5bff0ef          	jal	8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200214:	642c                	ld	a1,72(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	a8a50513          	addi	a0,a0,-1398 # 80200ca0 <etext+0x1f2>
    8020021e:	e4dff0ef          	jal	8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200222:	682c                	ld	a1,80(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	a9450513          	addi	a0,a0,-1388 # 80200cb8 <etext+0x20a>
    8020022c:	e3fff0ef          	jal	8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200230:	6c2c                	ld	a1,88(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	a9e50513          	addi	a0,a0,-1378 # 80200cd0 <etext+0x222>
    8020023a:	e31ff0ef          	jal	8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020023e:	702c                	ld	a1,96(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	aa850513          	addi	a0,a0,-1368 # 80200ce8 <etext+0x23a>
    80200248:	e23ff0ef          	jal	8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024c:	742c                	ld	a1,104(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	ab250513          	addi	a0,a0,-1358 # 80200d00 <etext+0x252>
    80200256:	e15ff0ef          	jal	8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025a:	782c                	ld	a1,112(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	abc50513          	addi	a0,a0,-1348 # 80200d18 <etext+0x26a>
    80200264:	e07ff0ef          	jal	8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200268:	7c2c                	ld	a1,120(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	ac650513          	addi	a0,a0,-1338 # 80200d30 <etext+0x282>
    80200272:	df9ff0ef          	jal	8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200276:	604c                	ld	a1,128(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	ad050513          	addi	a0,a0,-1328 # 80200d48 <etext+0x29a>
    80200280:	debff0ef          	jal	8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200284:	644c                	ld	a1,136(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	ada50513          	addi	a0,a0,-1318 # 80200d60 <etext+0x2b2>
    8020028e:	dddff0ef          	jal	8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200292:	684c                	ld	a1,144(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	ae450513          	addi	a0,a0,-1308 # 80200d78 <etext+0x2ca>
    8020029c:	dcfff0ef          	jal	8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a0:	6c4c                	ld	a1,152(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	aee50513          	addi	a0,a0,-1298 # 80200d90 <etext+0x2e2>
    802002aa:	dc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ae:	704c                	ld	a1,160(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	af850513          	addi	a0,a0,-1288 # 80200da8 <etext+0x2fa>
    802002b8:	db3ff0ef          	jal	8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002bc:	744c                	ld	a1,168(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	b0250513          	addi	a0,a0,-1278 # 80200dc0 <etext+0x312>
    802002c6:	da5ff0ef          	jal	8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ca:	784c                	ld	a1,176(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	b0c50513          	addi	a0,a0,-1268 # 80200dd8 <etext+0x32a>
    802002d4:	d97ff0ef          	jal	8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d8:	7c4c                	ld	a1,184(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	b1650513          	addi	a0,a0,-1258 # 80200df0 <etext+0x342>
    802002e2:	d89ff0ef          	jal	8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e6:	606c                	ld	a1,192(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	b2050513          	addi	a0,a0,-1248 # 80200e08 <etext+0x35a>
    802002f0:	d7bff0ef          	jal	8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f4:	646c                	ld	a1,200(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	b2a50513          	addi	a0,a0,-1238 # 80200e20 <etext+0x372>
    802002fe:	d6dff0ef          	jal	8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200302:	686c                	ld	a1,208(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	b3450513          	addi	a0,a0,-1228 # 80200e38 <etext+0x38a>
    8020030c:	d5fff0ef          	jal	8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200310:	6c6c                	ld	a1,216(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	b3e50513          	addi	a0,a0,-1218 # 80200e50 <etext+0x3a2>
    8020031a:	d51ff0ef          	jal	8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020031e:	706c                	ld	a1,224(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	b4850513          	addi	a0,a0,-1208 # 80200e68 <etext+0x3ba>
    80200328:	d43ff0ef          	jal	8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032c:	746c                	ld	a1,232(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	b5250513          	addi	a0,a0,-1198 # 80200e80 <etext+0x3d2>
    80200336:	d35ff0ef          	jal	8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033a:	786c                	ld	a1,240(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	b5c50513          	addi	a0,a0,-1188 # 80200e98 <etext+0x3ea>
    80200344:	d27ff0ef          	jal	8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200348:	7c6c                	ld	a1,248(s0)
}
    8020034a:	6402                	ld	s0,0(sp)
    8020034c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034e:	00001517          	auipc	a0,0x1
    80200352:	b6250513          	addi	a0,a0,-1182 # 80200eb0 <etext+0x402>
}
    80200356:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	bb09                	j	8020006a <cprintf>

000000008020035a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035a:	1141                	addi	sp,sp,-16
    8020035c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020035e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200360:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200362:	00001517          	auipc	a0,0x1
    80200366:	b6650513          	addi	a0,a0,-1178 # 80200ec8 <etext+0x41a>
void print_trapframe(struct trapframe *tf) {
    8020036a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036c:	cffff0ef          	jal	8020006a <cprintf>
    print_regs(&tf->gpr);
    80200370:	8522                	mv	a0,s0
    80200372:	e1dff0ef          	jal	8020018e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200376:	10043583          	ld	a1,256(s0)
    8020037a:	00001517          	auipc	a0,0x1
    8020037e:	b6650513          	addi	a0,a0,-1178 # 80200ee0 <etext+0x432>
    80200382:	ce9ff0ef          	jal	8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200386:	10843583          	ld	a1,264(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	b6e50513          	addi	a0,a0,-1170 # 80200ef8 <etext+0x44a>
    80200392:	cd9ff0ef          	jal	8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200396:	11043583          	ld	a1,272(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	b7650513          	addi	a0,a0,-1162 # 80200f10 <etext+0x462>
    802003a2:	cc9ff0ef          	jal	8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a6:	11843583          	ld	a1,280(s0)
}
    802003aa:	6402                	ld	s0,0(sp)
    802003ac:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ae:	00001517          	auipc	a0,0x1
    802003b2:	b7a50513          	addi	a0,a0,-1158 # 80200f28 <etext+0x47a>
}
    802003b6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	b94d                	j	8020006a <cprintf>

00000000802003ba <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    //sbi_shutdown();
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
    802003ba:	11853783          	ld	a5,280(a0)
    802003be:	472d                	li	a4,11
    802003c0:	0786                	slli	a5,a5,0x1
    802003c2:	8385                	srli	a5,a5,0x1
    802003c4:	06f76f63          	bltu	a4,a5,80200442 <interrupt_handler+0x88>
    802003c8:	00001717          	auipc	a4,0x1
    802003cc:	d5c70713          	addi	a4,a4,-676 # 80201124 <etext+0x676>
    802003d0:	078a                	slli	a5,a5,0x2
    802003d2:	97ba                	add	a5,a5,a4
    802003d4:	439c                	lw	a5,0(a5)
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003da:	00001517          	auipc	a0,0x1
    802003de:	bc650513          	addi	a0,a0,-1082 # 80200fa0 <etext+0x4f2>
    802003e2:	b161                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	b9c50513          	addi	a0,a0,-1124 # 80200f80 <etext+0x4d2>
    802003ec:	b9bd                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	b5250513          	addi	a0,a0,-1198 # 80200f40 <etext+0x492>
    802003f6:	b995                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	b6850513          	addi	a0,a0,-1176 # 80200f60 <etext+0x4b2>
    80200400:	b1ad                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200402:	1141                	addi	sp,sp,-16
    80200404:	e022                	sd	s0,0(sp)
    80200406:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
           clock_set_next_event();
           ticks++;
    80200408:	00004417          	auipc	s0,0x4
    8020040c:	c1040413          	addi	s0,s0,-1008 # 80204018 <ticks>
           clock_set_next_event();
    80200410:	d4dff0ef          	jal	8020015c <clock_set_next_event>
           ticks++;
    80200414:	601c                	ld	a5,0(s0)
           if(ticks%100==0){
    80200416:	06400713          	li	a4,100
           ticks++;
    8020041a:	0785                	addi	a5,a5,1
    8020041c:	e01c                	sd	a5,0(s0)
           if(ticks%100==0){
    8020041e:	601c                	ld	a5,0(s0)
    80200420:	02e7f7b3          	remu	a5,a5,a4
    80200424:	c385                	beqz	a5,80200444 <interrupt_handler+0x8a>
            print_ticks();
           }
            if(ticks == 1000){
    80200426:	6018                	ld	a4,0(s0)
    80200428:	3e800793          	li	a5,1000
    8020042c:	02f70563          	beq	a4,a5,80200456 <interrupt_handler+0x9c>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200430:	60a2                	ld	ra,8(sp)
    80200432:	6402                	ld	s0,0(sp)
    80200434:	0141                	addi	sp,sp,16
    80200436:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200438:	00001517          	auipc	a0,0x1
    8020043c:	bb050513          	addi	a0,a0,-1104 # 80200fe8 <etext+0x53a>
    80200440:	b12d                	j	8020006a <cprintf>
            print_trapframe(tf);
    80200442:	bf21                	j	8020035a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200444:	06400593          	li	a1,100
    80200448:	00001517          	auipc	a0,0x1
    8020044c:	b7850513          	addi	a0,a0,-1160 # 80200fc0 <etext+0x512>
    80200450:	c1bff0ef          	jal	8020006a <cprintf>
}
    80200454:	bfc9                	j	80200426 <interrupt_handler+0x6c>
                cprintf("%d timer interrupt\n", ticks/10);
    80200456:	600c                	ld	a1,0(s0)
    80200458:	47a9                	li	a5,10
    8020045a:	00001517          	auipc	a0,0x1
    8020045e:	b7650513          	addi	a0,a0,-1162 # 80200fd0 <etext+0x522>
    80200462:	02f5d5b3          	divu	a1,a1,a5
    80200466:	c05ff0ef          	jal	8020006a <cprintf>
}
    8020046a:	6402                	ld	s0,0(sp)
    8020046c:	60a2                	ld	ra,8(sp)
    8020046e:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200470:	abdd                	j	80200a66 <sbi_shutdown>

0000000080200472 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    //print_trapframe(tf);
    cprintf("%d fault\n", tf->cause);
    80200472:	11853583          	ld	a1,280(a0)
void exception_handler(struct trapframe *tf) {
    80200476:	1141                	addi	sp,sp,-16
    80200478:	e022                	sd	s0,0(sp)
    8020047a:	842a                	mv	s0,a0
    cprintf("%d fault\n", tf->cause);
    8020047c:	00001517          	auipc	a0,0x1
    80200480:	b8c50513          	addi	a0,a0,-1140 # 80201008 <etext+0x55a>
void exception_handler(struct trapframe *tf) {
    80200484:	e406                	sd	ra,8(sp)
    cprintf("%d fault\n", tf->cause);
    80200486:	be5ff0ef          	jal	8020006a <cprintf>
    
    //sbi_shutdown();
    switch (tf->cause) {
    8020048a:	11843783          	ld	a5,280(s0)
    8020048e:	472d                	li	a4,11
    80200490:	0ef76763          	bltu	a4,a5,8020057e <exception_handler+0x10c>
    80200494:	00001717          	auipc	a4,0x1
    80200498:	cc070713          	addi	a4,a4,-832 # 80201154 <etext+0x6a6>
    8020049c:	078a                	slli	a5,a5,0x2
    8020049e:	97ba                	add	a5,a5,a4
    802004a0:	439c                	lw	a5,0(a5)
    802004a2:	97ba                	add	a5,a5,a4
    802004a4:	8782                	jr	a5
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a6:	60a2                	ld	ra,8(sp)
    802004a8:	6402                	ld	s0,0(sp)
    802004aa:	0141                	addi	sp,sp,16
    802004ac:	8082                	ret
            cprintf("fetch");
    802004ae:	00001517          	auipc	a0,0x1
    802004b2:	b6a50513          	addi	a0,a0,-1174 # 80201018 <etext+0x56a>
    802004b6:	bb5ff0ef          	jal	8020006a <cprintf>
            tf->epc = tf->epc % 4 + 4; 
    802004ba:	10843783          	ld	a5,264(s0)
}
    802004be:	60a2                	ld	ra,8(sp)
            tf->epc = tf->epc % 4 + 4; 
    802004c0:	8b8d                	andi	a5,a5,3
    802004c2:	0791                	addi	a5,a5,4
    802004c4:	10f43423          	sd	a5,264(s0)
}
    802004c8:	6402                	ld	s0,0(sp)
    802004ca:	0141                	addi	sp,sp,16
            sbi_shutdown();
    802004cc:	ab69                	j	80200a66 <sbi_shutdown>
            cprintf("Illegal instruction\n");
    802004ce:	00001517          	auipc	a0,0x1
    802004d2:	b5250513          	addi	a0,a0,-1198 # 80201020 <etext+0x572>
    802004d6:	b95ff0ef          	jal	8020006a <cprintf>
            cprintf("%p \n", tf->epc);
    802004da:	10843583          	ld	a1,264(s0)
    802004de:	00001517          	auipc	a0,0x1
    802004e2:	b5a50513          	addi	a0,a0,-1190 # 80201038 <etext+0x58a>
    802004e6:	b85ff0ef          	jal	8020006a <cprintf>
            tf->epc = (uintptr_t)recover;
    802004ea:	00004597          	auipc	a1,0x4
    802004ee:	b165b583          	ld	a1,-1258(a1) # 80204000 <recover>
    802004f2:	10b43423          	sd	a1,264(s0)
}
    802004f6:	6402                	ld	s0,0(sp)
    802004f8:	60a2                	ld	ra,8(sp)
            cprintf("%p \n", tf->epc); 
    802004fa:	00001517          	auipc	a0,0x1
    802004fe:	b3e50513          	addi	a0,a0,-1218 # 80201038 <etext+0x58a>
}
    80200502:	0141                	addi	sp,sp,16
            cprintf("%p \n", tf->epc); 
    80200504:	b69d                	j	8020006a <cprintf>
            cprintf("Breakpoint instruction\n");
    80200506:	00001517          	auipc	a0,0x1
    8020050a:	b3a50513          	addi	a0,a0,-1222 # 80201040 <etext+0x592>
    8020050e:	b5dff0ef          	jal	8020006a <cprintf>
            cprintf("%p \n", tf->epc);
    80200512:	10843583          	ld	a1,264(s0)
    80200516:	00001517          	auipc	a0,0x1
    8020051a:	b2250513          	addi	a0,a0,-1246 # 80201038 <etext+0x58a>
    8020051e:	b4dff0ef          	jal	8020006a <cprintf>
            tf->epc = (uintptr_t)recover;
    80200522:	00004597          	auipc	a1,0x4
    80200526:	ade5b583          	ld	a1,-1314(a1) # 80204000 <recover>
    8020052a:	10b43423          	sd	a1,264(s0)
            cprintf("%p \n", tf->epc); 
    8020052e:	00001517          	auipc	a0,0x1
    80200532:	b0a50513          	addi	a0,a0,-1270 # 80201038 <etext+0x58a>
    80200536:	b35ff0ef          	jal	8020006a <cprintf>
            cprintf("%p \n", tf->epc); 
    8020053a:	10843583          	ld	a1,264(s0)
}
    8020053e:	6402                	ld	s0,0(sp)
    80200540:	60a2                	ld	ra,8(sp)
            cprintf("%p \n", tf->epc); 
    80200542:	00001517          	auipc	a0,0x1
    80200546:	af650513          	addi	a0,a0,-1290 # 80201038 <etext+0x58a>
}
    8020054a:	0141                	addi	sp,sp,16
            cprintf("%p \n", tf->epc); 
    8020054c:	be39                	j	8020006a <cprintf>
}
    8020054e:	6402                	ld	s0,0(sp)
    80200550:	60a2                	ld	ra,8(sp)
            cprintf("3");
    80200552:	00001517          	auipc	a0,0x1
    80200556:	b0650513          	addi	a0,a0,-1274 # 80201058 <etext+0x5aa>
}
    8020055a:	0141                	addi	sp,sp,16
            cprintf("4");
    8020055c:	b639                	j	8020006a <cprintf>
}
    8020055e:	6402                	ld	s0,0(sp)
    80200560:	60a2                	ld	ra,8(sp)
            cprintf("4");
    80200562:	00001517          	auipc	a0,0x1
    80200566:	afe50513          	addi	a0,a0,-1282 # 80201060 <etext+0x5b2>
}
    8020056a:	0141                	addi	sp,sp,16
            cprintf("4");
    8020056c:	bcfd                	j	8020006a <cprintf>
}
    8020056e:	6402                	ld	s0,0(sp)
    80200570:	60a2                	ld	ra,8(sp)
            cprintf("5");
    80200572:	00001517          	auipc	a0,0x1
    80200576:	af650513          	addi	a0,a0,-1290 # 80201068 <etext+0x5ba>
}
    8020057a:	0141                	addi	sp,sp,16
            cprintf("4");
    8020057c:	b4fd                	j	8020006a <cprintf>
            print_trapframe(tf);
    8020057e:	8522                	mv	a0,s0
}
    80200580:	6402                	ld	s0,0(sp)
    80200582:	60a2                	ld	ra,8(sp)
    80200584:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    80200586:	bbd1                	j	8020035a <print_trapframe>

0000000080200588 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200588:	11853783          	ld	a5,280(a0)
    8020058c:	0007c363          	bltz	a5,80200592 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200590:	b5cd                	j	80200472 <exception_handler>
        interrupt_handler(tf);
    80200592:	b525                	j	802003ba <interrupt_handler>

0000000080200594 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200594:	14011073          	csrw	sscratch,sp
    80200598:	712d                	addi	sp,sp,-288
    8020059a:	e002                	sd	zero,0(sp)
    8020059c:	e406                	sd	ra,8(sp)
    8020059e:	ec0e                	sd	gp,24(sp)
    802005a0:	f012                	sd	tp,32(sp)
    802005a2:	f416                	sd	t0,40(sp)
    802005a4:	f81a                	sd	t1,48(sp)
    802005a6:	fc1e                	sd	t2,56(sp)
    802005a8:	e0a2                	sd	s0,64(sp)
    802005aa:	e4a6                	sd	s1,72(sp)
    802005ac:	e8aa                	sd	a0,80(sp)
    802005ae:	ecae                	sd	a1,88(sp)
    802005b0:	f0b2                	sd	a2,96(sp)
    802005b2:	f4b6                	sd	a3,104(sp)
    802005b4:	f8ba                	sd	a4,112(sp)
    802005b6:	fcbe                	sd	a5,120(sp)
    802005b8:	e142                	sd	a6,128(sp)
    802005ba:	e546                	sd	a7,136(sp)
    802005bc:	e94a                	sd	s2,144(sp)
    802005be:	ed4e                	sd	s3,152(sp)
    802005c0:	f152                	sd	s4,160(sp)
    802005c2:	f556                	sd	s5,168(sp)
    802005c4:	f95a                	sd	s6,176(sp)
    802005c6:	fd5e                	sd	s7,184(sp)
    802005c8:	e1e2                	sd	s8,192(sp)
    802005ca:	e5e6                	sd	s9,200(sp)
    802005cc:	e9ea                	sd	s10,208(sp)
    802005ce:	edee                	sd	s11,216(sp)
    802005d0:	f1f2                	sd	t3,224(sp)
    802005d2:	f5f6                	sd	t4,232(sp)
    802005d4:	f9fa                	sd	t5,240(sp)
    802005d6:	fdfe                	sd	t6,248(sp)
    802005d8:	14001473          	csrrw	s0,sscratch,zero
    802005dc:	100024f3          	csrr	s1,sstatus
    802005e0:	14102973          	csrr	s2,sepc
    802005e4:	143029f3          	csrr	s3,stval
    802005e8:	14202a73          	csrr	s4,scause
    802005ec:	e822                	sd	s0,16(sp)
    802005ee:	e226                	sd	s1,256(sp)
    802005f0:	e64a                	sd	s2,264(sp)
    802005f2:	ea4e                	sd	s3,272(sp)
    802005f4:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802005f6:	850a                	mv	a0,sp
    jal trap
    802005f8:	f91ff0ef          	jal	80200588 <trap>

00000000802005fc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802005fc:	6492                	ld	s1,256(sp)
    802005fe:	6932                	ld	s2,264(sp)
    80200600:	10049073          	csrw	sstatus,s1
    80200604:	14191073          	csrw	sepc,s2
    80200608:	60a2                	ld	ra,8(sp)
    8020060a:	61e2                	ld	gp,24(sp)
    8020060c:	7202                	ld	tp,32(sp)
    8020060e:	72a2                	ld	t0,40(sp)
    80200610:	7342                	ld	t1,48(sp)
    80200612:	73e2                	ld	t2,56(sp)
    80200614:	6406                	ld	s0,64(sp)
    80200616:	64a6                	ld	s1,72(sp)
    80200618:	6546                	ld	a0,80(sp)
    8020061a:	65e6                	ld	a1,88(sp)
    8020061c:	7606                	ld	a2,96(sp)
    8020061e:	76a6                	ld	a3,104(sp)
    80200620:	7746                	ld	a4,112(sp)
    80200622:	77e6                	ld	a5,120(sp)
    80200624:	680a                	ld	a6,128(sp)
    80200626:	68aa                	ld	a7,136(sp)
    80200628:	694a                	ld	s2,144(sp)
    8020062a:	69ea                	ld	s3,152(sp)
    8020062c:	7a0a                	ld	s4,160(sp)
    8020062e:	7aaa                	ld	s5,168(sp)
    80200630:	7b4a                	ld	s6,176(sp)
    80200632:	7bea                	ld	s7,184(sp)
    80200634:	6c0e                	ld	s8,192(sp)
    80200636:	6cae                	ld	s9,200(sp)
    80200638:	6d4e                	ld	s10,208(sp)
    8020063a:	6dee                	ld	s11,216(sp)
    8020063c:	7e0e                	ld	t3,224(sp)
    8020063e:	7eae                	ld	t4,232(sp)
    80200640:	7f4e                	ld	t5,240(sp)
    80200642:	7fee                	ld	t6,248(sp)
    80200644:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    80200646:	10200073          	sret

000000008020064a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    8020064a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020064e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200650:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200654:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200656:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    8020065a:	f022                	sd	s0,32(sp)
    8020065c:	ec26                	sd	s1,24(sp)
    8020065e:	e84a                	sd	s2,16(sp)
    80200660:	f406                	sd	ra,40(sp)
    80200662:	84aa                	mv	s1,a0
    80200664:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200666:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020066a:	2a01                	sext.w	s4,s4
    if (num >= base) {
    8020066c:	05067063          	bgeu	a2,a6,802006ac <printnum+0x62>
    80200670:	e44e                	sd	s3,8(sp)
    80200672:	89be                	mv	s3,a5
        while (-- width > 0)
    80200674:	4785                	li	a5,1
    80200676:	00e7d763          	bge	a5,a4,80200684 <printnum+0x3a>
            putch(padc, putdat);
    8020067a:	85ca                	mv	a1,s2
    8020067c:	854e                	mv	a0,s3
        while (-- width > 0)
    8020067e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200680:	9482                	jalr	s1
        while (-- width > 0)
    80200682:	fc65                	bnez	s0,8020067a <printnum+0x30>
    80200684:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200686:	1a02                	slli	s4,s4,0x20
    80200688:	020a5a13          	srli	s4,s4,0x20
    8020068c:	00001797          	auipc	a5,0x1
    80200690:	9e478793          	addi	a5,a5,-1564 # 80201070 <etext+0x5c2>
    80200694:	97d2                	add	a5,a5,s4
}
    80200696:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200698:	0007c503          	lbu	a0,0(a5)
}
    8020069c:	70a2                	ld	ra,40(sp)
    8020069e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006a0:	85ca                	mv	a1,s2
    802006a2:	87a6                	mv	a5,s1
}
    802006a4:	6942                	ld	s2,16(sp)
    802006a6:	64e2                	ld	s1,24(sp)
    802006a8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802006aa:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    802006ac:	03065633          	divu	a2,a2,a6
    802006b0:	8722                	mv	a4,s0
    802006b2:	f99ff0ef          	jal	8020064a <printnum>
    802006b6:	bfc1                	j	80200686 <printnum+0x3c>

00000000802006b8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802006b8:	7119                	addi	sp,sp,-128
    802006ba:	f4a6                	sd	s1,104(sp)
    802006bc:	f0ca                	sd	s2,96(sp)
    802006be:	ecce                	sd	s3,88(sp)
    802006c0:	e8d2                	sd	s4,80(sp)
    802006c2:	e4d6                	sd	s5,72(sp)
    802006c4:	e0da                	sd	s6,64(sp)
    802006c6:	f862                	sd	s8,48(sp)
    802006c8:	fc86                	sd	ra,120(sp)
    802006ca:	f8a2                	sd	s0,112(sp)
    802006cc:	fc5e                	sd	s7,56(sp)
    802006ce:	f466                	sd	s9,40(sp)
    802006d0:	f06a                	sd	s10,32(sp)
    802006d2:	ec6e                	sd	s11,24(sp)
    802006d4:	892a                	mv	s2,a0
    802006d6:	84ae                	mv	s1,a1
    802006d8:	8c32                	mv	s8,a2
    802006da:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006dc:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    802006e0:	05500b13          	li	s6,85
    802006e4:	00001a97          	auipc	s5,0x1
    802006e8:	aa0a8a93          	addi	s5,s5,-1376 # 80201184 <etext+0x6d6>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ec:	000c4503          	lbu	a0,0(s8)
    802006f0:	001c0413          	addi	s0,s8,1
    802006f4:	01350a63          	beq	a0,s3,80200708 <vprintfmt+0x50>
            if (ch == '\0') {
    802006f8:	cd0d                	beqz	a0,80200732 <vprintfmt+0x7a>
            putch(ch, putdat);
    802006fa:	85a6                	mv	a1,s1
    802006fc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006fe:	00044503          	lbu	a0,0(s0)
    80200702:	0405                	addi	s0,s0,1
    80200704:	ff351ae3          	bne	a0,s3,802006f8 <vprintfmt+0x40>
        char padc = ' ';
    80200708:	02000d93          	li	s11,32
        lflag = altflag = 0;
    8020070c:	4b81                	li	s7,0
    8020070e:	4601                	li	a2,0
        width = precision = -1;
    80200710:	5d7d                	li	s10,-1
    80200712:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200714:	00044683          	lbu	a3,0(s0)
    80200718:	00140c13          	addi	s8,s0,1
    8020071c:	fdd6859b          	addiw	a1,a3,-35
    80200720:	0ff5f593          	zext.b	a1,a1
    80200724:	02bb6663          	bltu	s6,a1,80200750 <vprintfmt+0x98>
    80200728:	058a                	slli	a1,a1,0x2
    8020072a:	95d6                	add	a1,a1,s5
    8020072c:	4198                	lw	a4,0(a1)
    8020072e:	9756                	add	a4,a4,s5
    80200730:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200732:	70e6                	ld	ra,120(sp)
    80200734:	7446                	ld	s0,112(sp)
    80200736:	74a6                	ld	s1,104(sp)
    80200738:	7906                	ld	s2,96(sp)
    8020073a:	69e6                	ld	s3,88(sp)
    8020073c:	6a46                	ld	s4,80(sp)
    8020073e:	6aa6                	ld	s5,72(sp)
    80200740:	6b06                	ld	s6,64(sp)
    80200742:	7be2                	ld	s7,56(sp)
    80200744:	7c42                	ld	s8,48(sp)
    80200746:	7ca2                	ld	s9,40(sp)
    80200748:	7d02                	ld	s10,32(sp)
    8020074a:	6de2                	ld	s11,24(sp)
    8020074c:	6109                	addi	sp,sp,128
    8020074e:	8082                	ret
            putch('%', putdat);
    80200750:	85a6                	mv	a1,s1
    80200752:	02500513          	li	a0,37
    80200756:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200758:	fff44703          	lbu	a4,-1(s0)
    8020075c:	02500793          	li	a5,37
    80200760:	8c22                	mv	s8,s0
    80200762:	f8f705e3          	beq	a4,a5,802006ec <vprintfmt+0x34>
    80200766:	02500713          	li	a4,37
    8020076a:	ffec4783          	lbu	a5,-2(s8)
    8020076e:	1c7d                	addi	s8,s8,-1
    80200770:	fee79de3          	bne	a5,a4,8020076a <vprintfmt+0xb2>
    80200774:	bfa5                	j	802006ec <vprintfmt+0x34>
                ch = *fmt;
    80200776:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
    8020077a:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
    8020077c:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
    80200780:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
    80200784:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
    80200788:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
    8020078a:	02b76563          	bltu	a4,a1,802007b4 <vprintfmt+0xfc>
    8020078e:	4525                	li	a0,9
                ch = *fmt;
    80200790:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
    80200794:	002d171b          	slliw	a4,s10,0x2
    80200798:	01a7073b          	addw	a4,a4,s10
    8020079c:	0017171b          	slliw	a4,a4,0x1
    802007a0:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
    802007a2:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
    802007a6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802007a8:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
    802007ac:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
    802007b0:	feb570e3          	bgeu	a0,a1,80200790 <vprintfmt+0xd8>
            if (width < 0)
    802007b4:	f60cd0e3          	bgez	s9,80200714 <vprintfmt+0x5c>
                width = precision, precision = -1;
    802007b8:	8cea                	mv	s9,s10
    802007ba:	5d7d                	li	s10,-1
    802007bc:	bfa1                	j	80200714 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
    802007be:	8db6                	mv	s11,a3
    802007c0:	8462                	mv	s0,s8
    802007c2:	bf89                	j	80200714 <vprintfmt+0x5c>
    802007c4:	8462                	mv	s0,s8
            altflag = 1;
    802007c6:	4b85                	li	s7,1
            goto reswitch;
    802007c8:	b7b1                	j	80200714 <vprintfmt+0x5c>
    if (lflag >= 2) {
    802007ca:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802007cc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    802007d0:	00c7c463          	blt	a5,a2,802007d8 <vprintfmt+0x120>
    else if (lflag) {
    802007d4:	1a060163          	beqz	a2,80200976 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
    802007d8:	000a3603          	ld	a2,0(s4)
    802007dc:	46c1                	li	a3,16
    802007de:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
    802007e0:	000d879b          	sext.w	a5,s11
    802007e4:	8766                	mv	a4,s9
    802007e6:	85a6                	mv	a1,s1
    802007e8:	854a                	mv	a0,s2
    802007ea:	e61ff0ef          	jal	8020064a <printnum>
            break;
    802007ee:	bdfd                	j	802006ec <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
    802007f0:	000a2503          	lw	a0,0(s4)
    802007f4:	85a6                	mv	a1,s1
    802007f6:	0a21                	addi	s4,s4,8
    802007f8:	9902                	jalr	s2
            break;
    802007fa:	bdcd                	j	802006ec <vprintfmt+0x34>
    if (lflag >= 2) {
    802007fc:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802007fe:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200802:	00c7c463          	blt	a5,a2,8020080a <vprintfmt+0x152>
    else if (lflag) {
    80200806:	16060363          	beqz	a2,8020096c <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
    8020080a:	000a3603          	ld	a2,0(s4)
    8020080e:	46a9                	li	a3,10
    80200810:	8a3a                	mv	s4,a4
    80200812:	b7f9                	j	802007e0 <vprintfmt+0x128>
            putch('0', putdat);
    80200814:	85a6                	mv	a1,s1
    80200816:	03000513          	li	a0,48
    8020081a:	9902                	jalr	s2
            putch('x', putdat);
    8020081c:	85a6                	mv	a1,s1
    8020081e:	07800513          	li	a0,120
    80200822:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200824:	000a3603          	ld	a2,0(s4)
            goto number;
    80200828:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020082a:	0a21                	addi	s4,s4,8
            goto number;
    8020082c:	bf55                	j	802007e0 <vprintfmt+0x128>
            putch(ch, putdat);
    8020082e:	85a6                	mv	a1,s1
    80200830:	02500513          	li	a0,37
    80200834:	9902                	jalr	s2
            break;
    80200836:	bd5d                	j	802006ec <vprintfmt+0x34>
            precision = va_arg(ap, int);
    80200838:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020083c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
    8020083e:	0a21                	addi	s4,s4,8
            goto process_precision;
    80200840:	bf95                	j	802007b4 <vprintfmt+0xfc>
    if (lflag >= 2) {
    80200842:	4785                	li	a5,1
            precision = va_arg(ap, int);
    80200844:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200848:	00c7c463          	blt	a5,a2,80200850 <vprintfmt+0x198>
    else if (lflag) {
    8020084c:	10060b63          	beqz	a2,80200962 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
    80200850:	000a3603          	ld	a2,0(s4)
    80200854:	46a1                	li	a3,8
    80200856:	8a3a                	mv	s4,a4
    80200858:	b761                	j	802007e0 <vprintfmt+0x128>
            if (width < 0)
    8020085a:	fffcc793          	not	a5,s9
    8020085e:	97fd                	srai	a5,a5,0x3f
    80200860:	00fcf7b3          	and	a5,s9,a5
    80200864:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
    80200868:	8462                	mv	s0,s8
            goto reswitch;
    8020086a:	b56d                	j	80200714 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020086c:	000a3403          	ld	s0,0(s4)
    80200870:	008a0793          	addi	a5,s4,8
    80200874:	e43e                	sd	a5,8(sp)
    80200876:	12040063          	beqz	s0,80200996 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
    8020087a:	0d905963          	blez	s9,8020094c <vprintfmt+0x294>
    8020087e:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200882:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
    80200886:	12fd9763          	bne	s11,a5,802009b4 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020088a:	00044783          	lbu	a5,0(s0)
    8020088e:	0007851b          	sext.w	a0,a5
    80200892:	cb9d                	beqz	a5,802008c8 <vprintfmt+0x210>
    80200894:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200896:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020089a:	000d4563          	bltz	s10,802008a4 <vprintfmt+0x1ec>
    8020089e:	3d7d                	addiw	s10,s10,-1
    802008a0:	028d0263          	beq	s10,s0,802008c4 <vprintfmt+0x20c>
                    putch('?', putdat);
    802008a4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802008a6:	0c0b8d63          	beqz	s7,80200980 <vprintfmt+0x2c8>
    802008aa:	3781                	addiw	a5,a5,-32
    802008ac:	0cfdfa63          	bgeu	s11,a5,80200980 <vprintfmt+0x2c8>
                    putch('?', putdat);
    802008b0:	03f00513          	li	a0,63
    802008b4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008b6:	000a4783          	lbu	a5,0(s4)
    802008ba:	3cfd                	addiw	s9,s9,-1
    802008bc:	0a05                	addi	s4,s4,1
    802008be:	0007851b          	sext.w	a0,a5
    802008c2:	ffe1                	bnez	a5,8020089a <vprintfmt+0x1e2>
            for (; width > 0; width --) {
    802008c4:	01905963          	blez	s9,802008d6 <vprintfmt+0x21e>
                putch(' ', putdat);
    802008c8:	85a6                	mv	a1,s1
    802008ca:	02000513          	li	a0,32
            for (; width > 0; width --) {
    802008ce:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
    802008d0:	9902                	jalr	s2
            for (; width > 0; width --) {
    802008d2:	fe0c9be3          	bnez	s9,802008c8 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008d6:	6a22                	ld	s4,8(sp)
    802008d8:	bd11                	j	802006ec <vprintfmt+0x34>
    if (lflag >= 2) {
    802008da:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802008dc:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
    802008e0:	00c7c363          	blt	a5,a2,802008e6 <vprintfmt+0x22e>
    else if (lflag) {
    802008e4:	ce25                	beqz	a2,8020095c <vprintfmt+0x2a4>
        return va_arg(*ap, long);
    802008e6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802008ea:	08044d63          	bltz	s0,80200984 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
    802008ee:	8622                	mv	a2,s0
    802008f0:	8a5e                	mv	s4,s7
    802008f2:	46a9                	li	a3,10
    802008f4:	b5f5                	j	802007e0 <vprintfmt+0x128>
            if (err < 0) {
    802008f6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008fa:	4619                	li	a2,6
            if (err < 0) {
    802008fc:	41f7d71b          	sraiw	a4,a5,0x1f
    80200900:	8fb9                	xor	a5,a5,a4
    80200902:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200906:	02d64663          	blt	a2,a3,80200932 <vprintfmt+0x27a>
    8020090a:	00369713          	slli	a4,a3,0x3
    8020090e:	00001797          	auipc	a5,0x1
    80200912:	9d278793          	addi	a5,a5,-1582 # 802012e0 <error_string>
    80200916:	97ba                	add	a5,a5,a4
    80200918:	639c                	ld	a5,0(a5)
    8020091a:	cf81                	beqz	a5,80200932 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
    8020091c:	86be                	mv	a3,a5
    8020091e:	00000617          	auipc	a2,0x0
    80200922:	78260613          	addi	a2,a2,1922 # 802010a0 <etext+0x5f2>
    80200926:	85a6                	mv	a1,s1
    80200928:	854a                	mv	a0,s2
    8020092a:	0e8000ef          	jal	80200a12 <printfmt>
            err = va_arg(ap, int);
    8020092e:	0a21                	addi	s4,s4,8
    80200930:	bb75                	j	802006ec <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
    80200932:	00000617          	auipc	a2,0x0
    80200936:	75e60613          	addi	a2,a2,1886 # 80201090 <etext+0x5e2>
    8020093a:	85a6                	mv	a1,s1
    8020093c:	854a                	mv	a0,s2
    8020093e:	0d4000ef          	jal	80200a12 <printfmt>
            err = va_arg(ap, int);
    80200942:	0a21                	addi	s4,s4,8
    80200944:	b365                	j	802006ec <vprintfmt+0x34>
            lflag ++;
    80200946:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200948:	8462                	mv	s0,s8
            goto reswitch;
    8020094a:	b3e9                	j	80200714 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020094c:	00044783          	lbu	a5,0(s0)
    80200950:	0007851b          	sext.w	a0,a5
    80200954:	d3c9                	beqz	a5,802008d6 <vprintfmt+0x21e>
    80200956:	00140a13          	addi	s4,s0,1
    8020095a:	bf2d                	j	80200894 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
    8020095c:	000a2403          	lw	s0,0(s4)
    80200960:	b769                	j	802008ea <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
    80200962:	000a6603          	lwu	a2,0(s4)
    80200966:	46a1                	li	a3,8
    80200968:	8a3a                	mv	s4,a4
    8020096a:	bd9d                	j	802007e0 <vprintfmt+0x128>
    8020096c:	000a6603          	lwu	a2,0(s4)
    80200970:	46a9                	li	a3,10
    80200972:	8a3a                	mv	s4,a4
    80200974:	b5b5                	j	802007e0 <vprintfmt+0x128>
    80200976:	000a6603          	lwu	a2,0(s4)
    8020097a:	46c1                	li	a3,16
    8020097c:	8a3a                	mv	s4,a4
    8020097e:	b58d                	j	802007e0 <vprintfmt+0x128>
                    putch(ch, putdat);
    80200980:	9902                	jalr	s2
    80200982:	bf15                	j	802008b6 <vprintfmt+0x1fe>
                putch('-', putdat);
    80200984:	85a6                	mv	a1,s1
    80200986:	02d00513          	li	a0,45
    8020098a:	9902                	jalr	s2
                num = -(long long)num;
    8020098c:	40800633          	neg	a2,s0
    80200990:	8a5e                	mv	s4,s7
    80200992:	46a9                	li	a3,10
    80200994:	b5b1                	j	802007e0 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
    80200996:	01905663          	blez	s9,802009a2 <vprintfmt+0x2ea>
    8020099a:	02d00793          	li	a5,45
    8020099e:	04fd9263          	bne	s11,a5,802009e2 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009a2:	02800793          	li	a5,40
    802009a6:	00000a17          	auipc	s4,0x0
    802009aa:	6e3a0a13          	addi	s4,s4,1763 # 80201089 <etext+0x5db>
    802009ae:	02800513          	li	a0,40
    802009b2:	b5cd                	j	80200894 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009b4:	85ea                	mv	a1,s10
    802009b6:	8522                	mv	a0,s0
    802009b8:	0c8000ef          	jal	80200a80 <strnlen>
    802009bc:	40ac8cbb          	subw	s9,s9,a0
    802009c0:	01905963          	blez	s9,802009d2 <vprintfmt+0x31a>
                    putch(padc, putdat);
    802009c4:	2d81                	sext.w	s11,s11
    802009c6:	85a6                	mv	a1,s1
    802009c8:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009ca:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
    802009cc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009ce:	fe0c9ce3          	bnez	s9,802009c6 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009d2:	00044783          	lbu	a5,0(s0)
    802009d6:	0007851b          	sext.w	a0,a5
    802009da:	ea079de3          	bnez	a5,80200894 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
    802009de:	6a22                	ld	s4,8(sp)
    802009e0:	b331                	j	802006ec <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009e2:	85ea                	mv	a1,s10
    802009e4:	00000517          	auipc	a0,0x0
    802009e8:	6a450513          	addi	a0,a0,1700 # 80201088 <etext+0x5da>
    802009ec:	094000ef          	jal	80200a80 <strnlen>
    802009f0:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
    802009f4:	00000417          	auipc	s0,0x0
    802009f8:	69440413          	addi	s0,s0,1684 # 80201088 <etext+0x5da>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009fc:	00000a17          	auipc	s4,0x0
    80200a00:	68da0a13          	addi	s4,s4,1677 # 80201089 <etext+0x5db>
    80200a04:	02800793          	li	a5,40
    80200a08:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200a0c:	fb904ce3          	bgtz	s9,802009c4 <vprintfmt+0x30c>
    80200a10:	b551                	j	80200894 <vprintfmt+0x1dc>

0000000080200a12 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a12:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200a14:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a18:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a1a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a1c:	ec06                	sd	ra,24(sp)
    80200a1e:	f83a                	sd	a4,48(sp)
    80200a20:	fc3e                	sd	a5,56(sp)
    80200a22:	e0c2                	sd	a6,64(sp)
    80200a24:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a26:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a28:	c91ff0ef          	jal	802006b8 <vprintfmt>
}
    80200a2c:	60e2                	ld	ra,24(sp)
    80200a2e:	6161                	addi	sp,sp,80
    80200a30:	8082                	ret

0000000080200a32 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200a32:	4781                	li	a5,0
    80200a34:	00003717          	auipc	a4,0x3
    80200a38:	5dc73703          	ld	a4,1500(a4) # 80204010 <SBI_CONSOLE_PUTCHAR>
    80200a3c:	88ba                	mv	a7,a4
    80200a3e:	852a                	mv	a0,a0
    80200a40:	85be                	mv	a1,a5
    80200a42:	863e                	mv	a2,a5
    80200a44:	00000073          	ecall
    80200a48:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200a4a:	8082                	ret

0000000080200a4c <sbi_set_timer>:
    __asm__ volatile (
    80200a4c:	4781                	li	a5,0
    80200a4e:	00003717          	auipc	a4,0x3
    80200a52:	5d273703          	ld	a4,1490(a4) # 80204020 <SBI_SET_TIMER>
    80200a56:	88ba                	mv	a7,a4
    80200a58:	852a                	mv	a0,a0
    80200a5a:	85be                	mv	a1,a5
    80200a5c:	863e                	mv	a2,a5
    80200a5e:	00000073          	ecall
    80200a62:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200a64:	8082                	ret

0000000080200a66 <sbi_shutdown>:
    __asm__ volatile (
    80200a66:	4781                	li	a5,0
    80200a68:	00003717          	auipc	a4,0x3
    80200a6c:	5a073703          	ld	a4,1440(a4) # 80204008 <SBI_SHUTDOWN>
    80200a70:	88ba                	mv	a7,a4
    80200a72:	853e                	mv	a0,a5
    80200a74:	85be                	mv	a1,a5
    80200a76:	863e                	mv	a2,a5
    80200a78:	00000073          	ecall
    80200a7c:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a7e:	8082                	ret

0000000080200a80 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200a80:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200a82:	e589                	bnez	a1,80200a8c <strnlen+0xc>
    80200a84:	a811                	j	80200a98 <strnlen+0x18>
        cnt ++;
    80200a86:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a88:	00f58863          	beq	a1,a5,80200a98 <strnlen+0x18>
    80200a8c:	00f50733          	add	a4,a0,a5
    80200a90:	00074703          	lbu	a4,0(a4)
    80200a94:	fb6d                	bnez	a4,80200a86 <strnlen+0x6>
    80200a96:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200a98:	852e                	mv	a0,a1
    80200a9a:	8082                	ret

0000000080200a9c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a9c:	ca01                	beqz	a2,80200aac <memset+0x10>
    80200a9e:	962a                	add	a2,a2,a0
    char *p = s;
    80200aa0:	87aa                	mv	a5,a0
        *p ++ = c;
    80200aa2:	0785                	addi	a5,a5,1
    80200aa4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200aa8:	fef61de3          	bne	a2,a5,80200aa2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200aac:	8082                	ret
