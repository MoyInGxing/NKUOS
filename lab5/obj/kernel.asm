
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0009a517          	auipc	a0,0x9a
ffffffffc0200036:	ee650513          	addi	a0,a0,-282 # ffffffffc0299f18 <buf>
ffffffffc020003a:	000a5617          	auipc	a2,0xa5
ffffffffc020003e:	43e60613          	addi	a2,a2,1086 # ffffffffc02a5478 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc020aff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	047060ef          	jal	ffffffffc0206890 <memset>
    cons_init();                // init the console
ffffffffc020004e:	524000ef          	jal	ffffffffc0200572 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00007597          	auipc	a1,0x7
ffffffffc0200056:	86e58593          	addi	a1,a1,-1938 # ffffffffc02068c0 <etext+0x6>
ffffffffc020005a:	00007517          	auipc	a0,0x7
ffffffffc020005e:	88650513          	addi	a0,a0,-1914 # ffffffffc02068e0 <etext+0x26>
ffffffffc0200062:	12e000ef          	jal	ffffffffc0200190 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1be000ef          	jal	ffffffffc0200224 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	522020ef          	jal	ffffffffc020258c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5d8000ef          	jal	ffffffffc0200646 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5d6000ef          	jal	ffffffffc0200648 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	518040ef          	jal	ffffffffc020458e <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	777050ef          	jal	ffffffffc0205ff0 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	566000ef          	jal	ffffffffc02005e4 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	3da030ef          	jal	ffffffffc020345c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	49a000ef          	jal	ffffffffc0200520 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b0000ef          	jal	ffffffffc020063a <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	0fe060ef          	jal	ffffffffc020618c <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a2                	sd	s0,64(sp)
ffffffffc0200098:	fc26                	sd	s1,56(sp)
ffffffffc020009a:	f84a                	sd	s2,48(sp)
ffffffffc020009c:	f44e                	sd	s3,40(sp)
ffffffffc020009e:	f052                	sd	s4,32(sp)
ffffffffc02000a0:	ec56                	sd	s5,24(sp)
ffffffffc02000a2:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00007517          	auipc	a0,0x7
ffffffffc02000ac:	84050513          	addi	a0,a0,-1984 # ffffffffc02068e8 <etext+0x2e>
ffffffffc02000b0:	0e0000ef          	jal	ffffffffc0200190 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000b4:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4a29                	li	s4,10
ffffffffc02000bc:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc02000be:	0009ab17          	auipc	s6,0x9a
ffffffffc02000c2:	e5ab0b13          	addi	s6,s6,-422 # ffffffffc0299f18 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc02000ca:	14a000ef          	jal	ffffffffc0200214 <getchar>
        if (c < 0) {
ffffffffc02000ce:	02054363          	bltz	a0,ffffffffc02000f4 <readline+0x62>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	02a4d363          	bge	s1,a0,ffffffffc02000f8 <readline+0x66>
ffffffffc02000d6:	fe89cae3          	blt	s3,s0,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc02000da:	e42a                	sd	a0,8(sp)
ffffffffc02000dc:	0e8000ef          	jal	ffffffffc02001c4 <cputchar>
            buf[i ++] = c;
ffffffffc02000e0:	6522                	ld	a0,8(sp)
ffffffffc02000e2:	008b07b3          	add	a5,s6,s0
ffffffffc02000e6:	2405                	addiw	s0,s0,1
ffffffffc02000e8:	00a78023          	sb	a0,0(a5)
        c = getchar();
ffffffffc02000ec:	128000ef          	jal	ffffffffc0200214 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0551e3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000f4:	4501                	li	a0,0
ffffffffc02000f6:	a089                	j	ffffffffc0200138 <readline+0xa6>
        else if (c == '\b' && i > 0) {
ffffffffc02000f8:	03251363          	bne	a0,s2,ffffffffc020011e <readline+0x8c>
ffffffffc02000fc:	e821                	bnez	s0,ffffffffc020014c <readline+0xba>
        c = getchar();
ffffffffc02000fe:	116000ef          	jal	ffffffffc0200214 <getchar>
        if (c < 0) {
ffffffffc0200102:	fe0549e3          	bltz	a0,ffffffffc02000f4 <readline+0x62>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200106:	fea4d9e3          	bge	s1,a0,ffffffffc02000f8 <readline+0x66>
            cputchar(c);
ffffffffc020010a:	e42a                	sd	a0,8(sp)
ffffffffc020010c:	0b8000ef          	jal	ffffffffc02001c4 <cputchar>
            buf[i ++] = c;
ffffffffc0200110:	6522                	ld	a0,8(sp)
ffffffffc0200112:	008b07b3          	add	a5,s6,s0
ffffffffc0200116:	2405                	addiw	s0,s0,1
ffffffffc0200118:	00a78023          	sb	a0,0(a5)
ffffffffc020011c:	bfc1                	j	ffffffffc02000ec <readline+0x5a>
        else if (c == '\n' || c == '\r') {
ffffffffc020011e:	01450463          	beq	a0,s4,ffffffffc0200126 <readline+0x94>
ffffffffc0200122:	fb5514e3          	bne	a0,s5,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200126:	09e000ef          	jal	ffffffffc02001c4 <cputchar>
            buf[i] = '\0';
ffffffffc020012a:	0009a517          	auipc	a0,0x9a
ffffffffc020012e:	dee50513          	addi	a0,a0,-530 # ffffffffc0299f18 <buf>
ffffffffc0200132:	942a                	add	s0,s0,a0
ffffffffc0200134:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0200138:	60a6                	ld	ra,72(sp)
ffffffffc020013a:	6406                	ld	s0,64(sp)
ffffffffc020013c:	74e2                	ld	s1,56(sp)
ffffffffc020013e:	7942                	ld	s2,48(sp)
ffffffffc0200140:	79a2                	ld	s3,40(sp)
ffffffffc0200142:	7a02                	ld	s4,32(sp)
ffffffffc0200144:	6ae2                	ld	s5,24(sp)
ffffffffc0200146:	6b42                	ld	s6,16(sp)
ffffffffc0200148:	6161                	addi	sp,sp,80
ffffffffc020014a:	8082                	ret
            cputchar(c);
ffffffffc020014c:	854a                	mv	a0,s2
ffffffffc020014e:	076000ef          	jal	ffffffffc02001c4 <cputchar>
            i --;
ffffffffc0200152:	347d                	addiw	s0,s0,-1
ffffffffc0200154:	bf9d                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200156 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200156:	1141                	addi	sp,sp,-16
ffffffffc0200158:	e022                	sd	s0,0(sp)
ffffffffc020015a:	e406                	sd	ra,8(sp)
ffffffffc020015c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015e:	416000ef          	jal	ffffffffc0200574 <cons_putc>
    (*cnt) ++;
ffffffffc0200162:	401c                	lw	a5,0(s0)
}
ffffffffc0200164:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200166:	2785                	addiw	a5,a5,1
ffffffffc0200168:	c01c                	sw	a5,0(s0)
}
ffffffffc020016a:	6402                	ld	s0,0(sp)
ffffffffc020016c:	0141                	addi	sp,sp,16
ffffffffc020016e:	8082                	ret

ffffffffc0200170 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	1101                	addi	sp,sp,-32
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200156 <cputch>
ffffffffc020017e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200180:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200182:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200184:	312060ef          	jal	ffffffffc0206496 <vprintfmt>
    return cnt;
}
ffffffffc0200188:	60e2                	ld	ra,24(sp)
ffffffffc020018a:	4532                	lw	a0,12(sp)
ffffffffc020018c:	6105                	addi	sp,sp,32
ffffffffc020018e:	8082                	ret

ffffffffc0200190 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200190:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200192:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc0200196:	f42e                	sd	a1,40(sp)
ffffffffc0200198:	f832                	sd	a2,48(sp)
ffffffffc020019a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019c:	862a                	mv	a2,a0
ffffffffc020019e:	004c                	addi	a1,sp,4
ffffffffc02001a0:	00000517          	auipc	a0,0x0
ffffffffc02001a4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200156 <cputch>
ffffffffc02001a8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001aa:	ec06                	sd	ra,24(sp)
ffffffffc02001ac:	e0ba                	sd	a4,64(sp)
ffffffffc02001ae:	e4be                	sd	a5,72(sp)
ffffffffc02001b0:	e8c2                	sd	a6,80(sp)
ffffffffc02001b2:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02001b6:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b8:	2de060ef          	jal	ffffffffc0206496 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001bc:	60e2                	ld	ra,24(sp)
ffffffffc02001be:	4512                	lw	a0,4(sp)
ffffffffc02001c0:	6125                	addi	sp,sp,96
ffffffffc02001c2:	8082                	ret

ffffffffc02001c4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c4:	ae45                	j	ffffffffc0200574 <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	ec06                	sd	ra,24(sp)
ffffffffc02001ca:	e822                	sd	s0,16(sp)
ffffffffc02001cc:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001ce:	00054503          	lbu	a0,0(a0)
ffffffffc02001d2:	c905                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d4:	e426                	sd	s1,8(sp)
ffffffffc02001d6:	00178493          	addi	s1,a5,1
ffffffffc02001da:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc02001dc:	398000ef          	jal	ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001e0:	87a2                	mv	a5,s0
ffffffffc02001e2:	00044503          	lbu	a0,0(s0)
ffffffffc02001e6:	0405                	addi	s0,s0,1
ffffffffc02001e8:	f975                	bnez	a0,ffffffffc02001dc <cputs+0x16>
    (*cnt) ++;
ffffffffc02001ea:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc02001ec:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001ee:	0027841b          	addiw	s0,a5,2
ffffffffc02001f2:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001f4:	380000ef          	jal	ffffffffc0200574 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	8522                	mv	a0,s0
ffffffffc02001fc:	6442                	ld	s0,16(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    cons_putc(c);
ffffffffc0200202:	4529                	li	a0,10
ffffffffc0200204:	370000ef          	jal	ffffffffc0200574 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200208:	4405                	li	s0,1
}
ffffffffc020020a:	60e2                	ld	ra,24(sp)
ffffffffc020020c:	8522                	mv	a0,s0
ffffffffc020020e:	6442                	ld	s0,16(sp)
ffffffffc0200210:	6105                	addi	sp,sp,32
ffffffffc0200212:	8082                	ret

ffffffffc0200214 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200214:	1141                	addi	sp,sp,-16
ffffffffc0200216:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200218:	390000ef          	jal	ffffffffc02005a8 <cons_getc>
ffffffffc020021c:	dd75                	beqz	a0,ffffffffc0200218 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020021e:	60a2                	ld	ra,8(sp)
ffffffffc0200220:	0141                	addi	sp,sp,16
ffffffffc0200222:	8082                	ret

ffffffffc0200224 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	00006517          	auipc	a0,0x6
ffffffffc020022a:	6ca50513          	addi	a0,a0,1738 # ffffffffc02068f0 <etext+0x36>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	f61ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00006517          	auipc	a0,0x6
ffffffffc0200240:	6d450513          	addi	a0,a0,1748 # ffffffffc0206910 <etext+0x56>
ffffffffc0200244:	f4dff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00006597          	auipc	a1,0x6
ffffffffc020024c:	67258593          	addi	a1,a1,1650 # ffffffffc02068ba <etext>
ffffffffc0200250:	00006517          	auipc	a0,0x6
ffffffffc0200254:	6e050513          	addi	a0,a0,1760 # ffffffffc0206930 <etext+0x76>
ffffffffc0200258:	f39ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0009a597          	auipc	a1,0x9a
ffffffffc0200260:	cbc58593          	addi	a1,a1,-836 # ffffffffc0299f18 <buf>
ffffffffc0200264:	00006517          	auipc	a0,0x6
ffffffffc0200268:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206950 <etext+0x96>
ffffffffc020026c:	f25ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	000a5597          	auipc	a1,0xa5
ffffffffc0200274:	20858593          	addi	a1,a1,520 # ffffffffc02a5478 <end>
ffffffffc0200278:	00006517          	auipc	a0,0x6
ffffffffc020027c:	6f850513          	addi	a0,a0,1784 # ffffffffc0206970 <etext+0xb6>
ffffffffc0200280:	f11ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00000717          	auipc	a4,0x0
ffffffffc0200288:	dae70713          	addi	a4,a4,-594 # ffffffffc0200032 <kern_init>
ffffffffc020028c:	000a5797          	auipc	a5,0xa5
ffffffffc0200290:	5eb78793          	addi	a5,a5,1515 # ffffffffc02a5877 <end+0x3ff>
ffffffffc0200294:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200296:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029c:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a0:	95be                	add	a1,a1,a5
ffffffffc02002a2:	85a9                	srai	a1,a1,0xa
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	6ec50513          	addi	a0,a0,1772 # ffffffffc0206990 <etext+0xd6>
}
ffffffffc02002ac:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002ae:	b5cd                	j	ffffffffc0200190 <cprintf>

ffffffffc02002b0 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b0:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b2:	00006617          	auipc	a2,0x6
ffffffffc02002b6:	70e60613          	addi	a2,a2,1806 # ffffffffc02069c0 <etext+0x106>
ffffffffc02002ba:	04d00593          	li	a1,77
ffffffffc02002be:	00006517          	auipc	a0,0x6
ffffffffc02002c2:	71a50513          	addi	a0,a0,1818 # ffffffffc02069d8 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002c6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002c8:	1a8000ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02002cc <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	00006617          	auipc	a2,0x6
ffffffffc02002d2:	72260613          	addi	a2,a2,1826 # ffffffffc02069f0 <etext+0x136>
ffffffffc02002d6:	00006597          	auipc	a1,0x6
ffffffffc02002da:	73a58593          	addi	a1,a1,1850 # ffffffffc0206a10 <etext+0x156>
ffffffffc02002de:	00006517          	auipc	a0,0x6
ffffffffc02002e2:	73a50513          	addi	a0,a0,1850 # ffffffffc0206a18 <etext+0x15e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e8:	ea9ff0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc02002ec:	00006617          	auipc	a2,0x6
ffffffffc02002f0:	73c60613          	addi	a2,a2,1852 # ffffffffc0206a28 <etext+0x16e>
ffffffffc02002f4:	00006597          	auipc	a1,0x6
ffffffffc02002f8:	75c58593          	addi	a1,a1,1884 # ffffffffc0206a50 <etext+0x196>
ffffffffc02002fc:	00006517          	auipc	a0,0x6
ffffffffc0200300:	71c50513          	addi	a0,a0,1820 # ffffffffc0206a18 <etext+0x15e>
ffffffffc0200304:	e8dff0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc0200308:	00006617          	auipc	a2,0x6
ffffffffc020030c:	75860613          	addi	a2,a2,1880 # ffffffffc0206a60 <etext+0x1a6>
ffffffffc0200310:	00006597          	auipc	a1,0x6
ffffffffc0200314:	77058593          	addi	a1,a1,1904 # ffffffffc0206a80 <etext+0x1c6>
ffffffffc0200318:	00006517          	auipc	a0,0x6
ffffffffc020031c:	70050513          	addi	a0,a0,1792 # ffffffffc0206a18 <etext+0x15e>
ffffffffc0200320:	e71ff0ef          	jal	ffffffffc0200190 <cprintf>
    }
    return 0;
}
ffffffffc0200324:	60a2                	ld	ra,8(sp)
ffffffffc0200326:	4501                	li	a0,0
ffffffffc0200328:	0141                	addi	sp,sp,16
ffffffffc020032a:	8082                	ret

ffffffffc020032c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032c:	1141                	addi	sp,sp,-16
ffffffffc020032e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200330:	ef5ff0ef          	jal	ffffffffc0200224 <print_kerninfo>
    return 0;
}
ffffffffc0200334:	60a2                	ld	ra,8(sp)
ffffffffc0200336:	4501                	li	a0,0
ffffffffc0200338:	0141                	addi	sp,sp,16
ffffffffc020033a:	8082                	ret

ffffffffc020033c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033c:	1141                	addi	sp,sp,-16
ffffffffc020033e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200340:	f71ff0ef          	jal	ffffffffc02002b0 <print_stackframe>
    return 0;
}
ffffffffc0200344:	60a2                	ld	ra,8(sp)
ffffffffc0200346:	4501                	li	a0,0
ffffffffc0200348:	0141                	addi	sp,sp,16
ffffffffc020034a:	8082                	ret

ffffffffc020034c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034c:	7131                	addi	sp,sp,-192
ffffffffc020034e:	e952                	sd	s4,144(sp)
ffffffffc0200350:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200352:	00006517          	auipc	a0,0x6
ffffffffc0200356:	73e50513          	addi	a0,a0,1854 # ffffffffc0206a90 <etext+0x1d6>
kmonitor(struct trapframe *tf) {
ffffffffc020035a:	fd06                	sd	ra,184(sp)
ffffffffc020035c:	f922                	sd	s0,176(sp)
ffffffffc020035e:	f526                	sd	s1,168(sp)
ffffffffc0200360:	f14a                	sd	s2,160(sp)
ffffffffc0200362:	ed4e                	sd	s3,152(sp)
ffffffffc0200364:	e556                	sd	s5,136(sp)
ffffffffc0200366:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200368:	e29ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036c:	00006517          	auipc	a0,0x6
ffffffffc0200370:	74c50513          	addi	a0,a0,1868 # ffffffffc0206ab8 <etext+0x1fe>
ffffffffc0200374:	e1dff0ef          	jal	ffffffffc0200190 <cprintf>
    if (tf != NULL) {
ffffffffc0200378:	000a0563          	beqz	s4,ffffffffc0200382 <kmonitor+0x36>
        print_trapframe(tf);
ffffffffc020037c:	8552                	mv	a0,s4
ffffffffc020037e:	4b2000ef          	jal	ffffffffc0200830 <print_trapframe>
ffffffffc0200382:	00009a97          	auipc	s5,0x9
ffffffffc0200386:	816a8a93          	addi	s5,s5,-2026 # ffffffffc0208b98 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	49bd                	li	s3,15
        argv[argc ++] = buf;
ffffffffc020038c:	890a                	mv	s2,sp
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020038e:	00006517          	auipc	a0,0x6
ffffffffc0200392:	75250513          	addi	a0,a0,1874 # ffffffffc0206ae0 <etext+0x226>
ffffffffc0200396:	cfdff0ef          	jal	ffffffffc0200092 <readline>
ffffffffc020039a:	842a                	mv	s0,a0
ffffffffc020039c:	d96d                	beqz	a0,ffffffffc020038e <kmonitor+0x42>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003a2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a4:	e99d                	bnez	a1,ffffffffc02003da <kmonitor+0x8e>
    int argc = 0;
ffffffffc02003a6:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc02003a8:	fe0b03e3          	beqz	s6,ffffffffc020038e <kmonitor+0x42>
ffffffffc02003ac:	00008497          	auipc	s1,0x8
ffffffffc02003b0:	7ec48493          	addi	s1,s1,2028 # ffffffffc0208b98 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b6:	6582                	ld	a1,0(sp)
ffffffffc02003b8:	6088                	ld	a0,0(s1)
ffffffffc02003ba:	48c060ef          	jal	ffffffffc0206846 <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	c149                	beqz	a0,ffffffffc0200442 <kmonitor+0xf6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	2405                	addiw	s0,s0,1
ffffffffc02003c4:	04e1                	addi	s1,s1,24
ffffffffc02003c6:	fef418e3          	bne	s0,a5,ffffffffc02003b6 <kmonitor+0x6a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003ca:	6582                	ld	a1,0(sp)
ffffffffc02003cc:	00006517          	auipc	a0,0x6
ffffffffc02003d0:	74450513          	addi	a0,a0,1860 # ffffffffc0206b10 <etext+0x256>
ffffffffc02003d4:	dbdff0ef          	jal	ffffffffc0200190 <cprintf>
    return 0;
ffffffffc02003d8:	bf5d                	j	ffffffffc020038e <kmonitor+0x42>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003da:	00006517          	auipc	a0,0x6
ffffffffc02003de:	70e50513          	addi	a0,a0,1806 # ffffffffc0206ae8 <etext+0x22e>
ffffffffc02003e2:	49c060ef          	jal	ffffffffc020687e <strchr>
ffffffffc02003e6:	c901                	beqz	a0,ffffffffc02003f6 <kmonitor+0xaa>
ffffffffc02003e8:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003ec:	00040023          	sb	zero,0(s0)
ffffffffc02003f0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f2:	d9d5                	beqz	a1,ffffffffc02003a6 <kmonitor+0x5a>
ffffffffc02003f4:	b7dd                	j	ffffffffc02003da <kmonitor+0x8e>
        if (*buf == '\0') {
ffffffffc02003f6:	00044783          	lbu	a5,0(s0)
ffffffffc02003fa:	d7d5                	beqz	a5,ffffffffc02003a6 <kmonitor+0x5a>
        if (argc == MAXARGS - 1) {
ffffffffc02003fc:	03348b63          	beq	s1,s3,ffffffffc0200432 <kmonitor+0xe6>
        argv[argc ++] = buf;
ffffffffc0200400:	00349793          	slli	a5,s1,0x3
ffffffffc0200404:	97ca                	add	a5,a5,s2
ffffffffc0200406:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200408:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020040c:	2485                	addiw	s1,s1,1
ffffffffc020040e:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0xd0>
ffffffffc0200412:	bf59                	j	ffffffffc02003a8 <kmonitor+0x5c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200418:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041a:	d5d1                	beqz	a1,ffffffffc02003a6 <kmonitor+0x5a>
ffffffffc020041c:	00006517          	auipc	a0,0x6
ffffffffc0200420:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206ae8 <etext+0x22e>
ffffffffc0200424:	45a060ef          	jal	ffffffffc020687e <strchr>
ffffffffc0200428:	d575                	beqz	a0,ffffffffc0200414 <kmonitor+0xc8>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042a:	00044583          	lbu	a1,0(s0)
ffffffffc020042e:	dda5                	beqz	a1,ffffffffc02003a6 <kmonitor+0x5a>
ffffffffc0200430:	b76d                	j	ffffffffc02003da <kmonitor+0x8e>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200432:	45c1                	li	a1,16
ffffffffc0200434:	00006517          	auipc	a0,0x6
ffffffffc0200438:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206af0 <etext+0x236>
ffffffffc020043c:	d55ff0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc0200440:	b7c1                	j	ffffffffc0200400 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200442:	00141793          	slli	a5,s0,0x1
ffffffffc0200446:	97a2                	add	a5,a5,s0
ffffffffc0200448:	078e                	slli	a5,a5,0x3
ffffffffc020044a:	97d6                	add	a5,a5,s5
ffffffffc020044c:	6b9c                	ld	a5,16(a5)
ffffffffc020044e:	fffb051b          	addiw	a0,s6,-1
ffffffffc0200452:	8652                	mv	a2,s4
ffffffffc0200454:	002c                	addi	a1,sp,8
ffffffffc0200456:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200458:	f2055be3          	bgez	a0,ffffffffc020038e <kmonitor+0x42>
}
ffffffffc020045c:	70ea                	ld	ra,184(sp)
ffffffffc020045e:	744a                	ld	s0,176(sp)
ffffffffc0200460:	74aa                	ld	s1,168(sp)
ffffffffc0200462:	790a                	ld	s2,160(sp)
ffffffffc0200464:	69ea                	ld	s3,152(sp)
ffffffffc0200466:	6a4a                	ld	s4,144(sp)
ffffffffc0200468:	6aaa                	ld	s5,136(sp)
ffffffffc020046a:	6b0a                	ld	s6,128(sp)
ffffffffc020046c:	6129                	addi	sp,sp,192
ffffffffc020046e:	8082                	ret

ffffffffc0200470 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200470:	000a5317          	auipc	t1,0xa5
ffffffffc0200474:	f7030313          	addi	t1,t1,-144 # ffffffffc02a53e0 <is_panic>
ffffffffc0200478:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020047c:	715d                	addi	sp,sp,-80
ffffffffc020047e:	ec06                	sd	ra,24(sp)
ffffffffc0200480:	f436                	sd	a3,40(sp)
ffffffffc0200482:	f83a                	sd	a4,48(sp)
ffffffffc0200484:	fc3e                	sd	a5,56(sp)
ffffffffc0200486:	e0c2                	sd	a6,64(sp)
ffffffffc0200488:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020048a:	020e1c63          	bnez	t3,ffffffffc02004c2 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020048e:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200490:	103c                	addi	a5,sp,40
ffffffffc0200492:	e822                	sd	s0,16(sp)
ffffffffc0200494:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200496:	862e                	mv	a2,a1
ffffffffc0200498:	85aa                	mv	a1,a0
ffffffffc020049a:	00006517          	auipc	a0,0x6
ffffffffc020049e:	68e50513          	addi	a0,a0,1678 # ffffffffc0206b28 <etext+0x26e>
    is_panic = 1;
ffffffffc02004a2:	00e33023          	sd	a4,0(t1)
    va_start(ap, fmt);
ffffffffc02004a6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a8:	ce9ff0ef          	jal	ffffffffc0200190 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004ac:	65a2                	ld	a1,8(sp)
ffffffffc02004ae:	8522                	mv	a0,s0
ffffffffc02004b0:	cc1ff0ef          	jal	ffffffffc0200170 <vcprintf>
    cprintf("\n");
ffffffffc02004b4:	00006517          	auipc	a0,0x6
ffffffffc02004b8:	69450513          	addi	a0,a0,1684 # ffffffffc0206b48 <etext+0x28e>
ffffffffc02004bc:	cd5ff0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc02004c0:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004c2:	4501                	li	a0,0
ffffffffc02004c4:	4581                	li	a1,0
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	48a1                	li	a7,8
ffffffffc02004ca:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004ce:	172000ef          	jal	ffffffffc0200640 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004d2:	4501                	li	a0,0
ffffffffc02004d4:	e79ff0ef          	jal	ffffffffc020034c <kmonitor>
    while (1) {
ffffffffc02004d8:	bfed                	j	ffffffffc02004d2 <__panic+0x62>

ffffffffc02004da <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004da:	715d                	addi	sp,sp,-80
ffffffffc02004dc:	832e                	mv	t1,a1
ffffffffc02004de:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e0:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	8432                	mv	s0,a2
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e4:	00006517          	auipc	a0,0x6
ffffffffc02004e8:	66c50513          	addi	a0,a0,1644 # ffffffffc0206b50 <etext+0x296>
ffffffffc02004ec:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004ee:	02810313          	addi	t1,sp,40
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f2:	ec06                	sd	ra,24(sp)
ffffffffc02004f4:	f436                	sd	a3,40(sp)
ffffffffc02004f6:	f83a                	sd	a4,48(sp)
ffffffffc02004f8:	fc3e                	sd	a5,56(sp)
ffffffffc02004fa:	e0c2                	sd	a6,64(sp)
ffffffffc02004fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004fe:	e41a                	sd	t1,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200500:	c91ff0ef          	jal	ffffffffc0200190 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200504:	65a2                	ld	a1,8(sp)
ffffffffc0200506:	8522                	mv	a0,s0
ffffffffc0200508:	c69ff0ef          	jal	ffffffffc0200170 <vcprintf>
    cprintf("\n");
ffffffffc020050c:	00006517          	auipc	a0,0x6
ffffffffc0200510:	63c50513          	addi	a0,a0,1596 # ffffffffc0206b48 <etext+0x28e>
ffffffffc0200514:	c7dff0ef          	jal	ffffffffc0200190 <cprintf>
    va_end(ap);
}
ffffffffc0200518:	60e2                	ld	ra,24(sp)
ffffffffc020051a:	6442                	ld	s0,16(sp)
ffffffffc020051c:	6161                	addi	sp,sp,80
ffffffffc020051e:	8082                	ret

ffffffffc0200520 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200520:	67e1                	lui	a5,0x18
ffffffffc0200522:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_cow_out_size+0xb7f8>
ffffffffc0200526:	000a5717          	auipc	a4,0xa5
ffffffffc020052a:	ecf73123          	sd	a5,-318(a4) # ffffffffc02a53e8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052e:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200532:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200534:	953e                	add	a0,a0,a5
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4881                	li	a7,0
ffffffffc020053a:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020053e:	02000793          	li	a5,32
ffffffffc0200542:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200546:	00006517          	auipc	a0,0x6
ffffffffc020054a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206b70 <etext+0x2b6>
    ticks = 0;
ffffffffc020054e:	000a5797          	auipc	a5,0xa5
ffffffffc0200552:	ea07b123          	sd	zero,-350(a5) # ffffffffc02a53f0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200556:	b92d                	j	ffffffffc0200190 <cprintf>

ffffffffc0200558 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200558:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020055c:	000a5797          	auipc	a5,0xa5
ffffffffc0200560:	e8c7b783          	ld	a5,-372(a5) # ffffffffc02a53e8 <timebase>
ffffffffc0200564:	4581                	li	a1,0
ffffffffc0200566:	4601                	li	a2,0
ffffffffc0200568:	953e                	add	a0,a0,a5
ffffffffc020056a:	4881                	li	a7,0
ffffffffc020056c:	00000073          	ecall
ffffffffc0200570:	8082                	ret

ffffffffc0200572 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200574:	100027f3          	csrr	a5,sstatus
ffffffffc0200578:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020057a:	0ff57513          	zext.b	a0,a0
ffffffffc020057e:	e799                	bnez	a5,ffffffffc020058c <cons_putc+0x18>
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4885                	li	a7,1
ffffffffc0200586:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020058a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020058c:	1101                	addi	sp,sp,-32
ffffffffc020058e:	ec06                	sd	ra,24(sp)
ffffffffc0200590:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200592:	0ae000ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0200596:	6522                	ld	a0,8(sp)
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4885                	li	a7,1
ffffffffc020059e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a2:	60e2                	ld	ra,24(sp)
ffffffffc02005a4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005a6:	a851                	j	ffffffffc020063a <intr_enable>

ffffffffc02005a8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005a8:	100027f3          	csrr	a5,sstatus
ffffffffc02005ac:	8b89                	andi	a5,a5,2
ffffffffc02005ae:	eb89                	bnez	a5,ffffffffc02005c0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b0:	4501                	li	a0,0
ffffffffc02005b2:	4581                	li	a1,0
ffffffffc02005b4:	4601                	li	a2,0
ffffffffc02005b6:	4889                	li	a7,2
ffffffffc02005b8:	00000073          	ecall
ffffffffc02005bc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005be:	8082                	ret
int cons_getc(void) {
ffffffffc02005c0:	1101                	addi	sp,sp,-32
ffffffffc02005c2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005c4:	07c000ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
ffffffffc02005d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005d8:	062000ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc02005dc:	60e2                	ld	ra,24(sp)
ffffffffc02005de:	6522                	ld	a0,8(sp)
ffffffffc02005e0:	6105                	addi	sp,sp,32
ffffffffc02005e2:	8082                	ret

ffffffffc02005e4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005e4:	8082                	ret

ffffffffc02005e6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005e6:	00253513          	sltiu	a0,a0,2
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005ec:	03800513          	li	a0,56
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f2:	0009a797          	auipc	a5,0x9a
ffffffffc02005f6:	d2678793          	addi	a5,a5,-730 # ffffffffc029a318 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02005fa:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02005fe:	1141                	addi	sp,sp,-16
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200600:	8532                	mv	a0,a2
ffffffffc0200602:	95be                	add	a1,a1,a5
ffffffffc0200604:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200608:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	298060ef          	jal	ffffffffc02068a2 <memcpy>
    return 0;
}
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	4501                	li	a0,0
ffffffffc0200612:	0141                	addi	sp,sp,16
ffffffffc0200614:	8082                	ret

ffffffffc0200616 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200616:	0095951b          	slliw	a0,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020061a:	0009a797          	auipc	a5,0x9a
ffffffffc020061e:	cfe78793          	addi	a5,a5,-770 # ffffffffc029a318 <ide>
                   size_t nsecs) {
ffffffffc0200622:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200624:	85b2                	mv	a1,a2
ffffffffc0200626:	953e                	add	a0,a0,a5
ffffffffc0200628:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc020062c:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062e:	274060ef          	jal	ffffffffc02068a2 <memcpy>
    return 0;
}
ffffffffc0200632:	60a2                	ld	ra,8(sp)
ffffffffc0200634:	4501                	li	a0,0
ffffffffc0200636:	0141                	addi	sp,sp,16
ffffffffc0200638:	8082                	ret

ffffffffc020063a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020063a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200648:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020064c:	00000797          	auipc	a5,0x0
ffffffffc0200650:	65c78793          	addi	a5,a5,1628 # ffffffffc0200ca8 <__alltraps>
ffffffffc0200654:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200658:	000407b7          	lui	a5,0x40
ffffffffc020065c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200662:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200664:	1141                	addi	sp,sp,-16
ffffffffc0200666:	e022                	sd	s0,0(sp)
ffffffffc0200668:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066a:	00006517          	auipc	a0,0x6
ffffffffc020066e:	52650513          	addi	a0,a0,1318 # ffffffffc0206b90 <etext+0x2d6>
void print_regs(struct pushregs* gpr) {
ffffffffc0200672:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	b1dff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200678:	640c                	ld	a1,8(s0)
ffffffffc020067a:	00006517          	auipc	a0,0x6
ffffffffc020067e:	52e50513          	addi	a0,a0,1326 # ffffffffc0206ba8 <etext+0x2ee>
ffffffffc0200682:	b0fff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200686:	680c                	ld	a1,16(s0)
ffffffffc0200688:	00006517          	auipc	a0,0x6
ffffffffc020068c:	53850513          	addi	a0,a0,1336 # ffffffffc0206bc0 <etext+0x306>
ffffffffc0200690:	b01ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200694:	6c0c                	ld	a1,24(s0)
ffffffffc0200696:	00006517          	auipc	a0,0x6
ffffffffc020069a:	54250513          	addi	a0,a0,1346 # ffffffffc0206bd8 <etext+0x31e>
ffffffffc020069e:	af3ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a2:	700c                	ld	a1,32(s0)
ffffffffc02006a4:	00006517          	auipc	a0,0x6
ffffffffc02006a8:	54c50513          	addi	a0,a0,1356 # ffffffffc0206bf0 <etext+0x336>
ffffffffc02006ac:	ae5ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b0:	740c                	ld	a1,40(s0)
ffffffffc02006b2:	00006517          	auipc	a0,0x6
ffffffffc02006b6:	55650513          	addi	a0,a0,1366 # ffffffffc0206c08 <etext+0x34e>
ffffffffc02006ba:	ad7ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006be:	780c                	ld	a1,48(s0)
ffffffffc02006c0:	00006517          	auipc	a0,0x6
ffffffffc02006c4:	56050513          	addi	a0,a0,1376 # ffffffffc0206c20 <etext+0x366>
ffffffffc02006c8:	ac9ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006cc:	7c0c                	ld	a1,56(s0)
ffffffffc02006ce:	00006517          	auipc	a0,0x6
ffffffffc02006d2:	56a50513          	addi	a0,a0,1386 # ffffffffc0206c38 <etext+0x37e>
ffffffffc02006d6:	abbff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006da:	602c                	ld	a1,64(s0)
ffffffffc02006dc:	00006517          	auipc	a0,0x6
ffffffffc02006e0:	57450513          	addi	a0,a0,1396 # ffffffffc0206c50 <etext+0x396>
ffffffffc02006e4:	aadff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006e8:	642c                	ld	a1,72(s0)
ffffffffc02006ea:	00006517          	auipc	a0,0x6
ffffffffc02006ee:	57e50513          	addi	a0,a0,1406 # ffffffffc0206c68 <etext+0x3ae>
ffffffffc02006f2:	a9fff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f6:	682c                	ld	a1,80(s0)
ffffffffc02006f8:	00006517          	auipc	a0,0x6
ffffffffc02006fc:	58850513          	addi	a0,a0,1416 # ffffffffc0206c80 <etext+0x3c6>
ffffffffc0200700:	a91ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200704:	6c2c                	ld	a1,88(s0)
ffffffffc0200706:	00006517          	auipc	a0,0x6
ffffffffc020070a:	59250513          	addi	a0,a0,1426 # ffffffffc0206c98 <etext+0x3de>
ffffffffc020070e:	a83ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200712:	702c                	ld	a1,96(s0)
ffffffffc0200714:	00006517          	auipc	a0,0x6
ffffffffc0200718:	59c50513          	addi	a0,a0,1436 # ffffffffc0206cb0 <etext+0x3f6>
ffffffffc020071c:	a75ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200720:	742c                	ld	a1,104(s0)
ffffffffc0200722:	00006517          	auipc	a0,0x6
ffffffffc0200726:	5a650513          	addi	a0,a0,1446 # ffffffffc0206cc8 <etext+0x40e>
ffffffffc020072a:	a67ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020072e:	782c                	ld	a1,112(s0)
ffffffffc0200730:	00006517          	auipc	a0,0x6
ffffffffc0200734:	5b050513          	addi	a0,a0,1456 # ffffffffc0206ce0 <etext+0x426>
ffffffffc0200738:	a59ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073c:	7c2c                	ld	a1,120(s0)
ffffffffc020073e:	00006517          	auipc	a0,0x6
ffffffffc0200742:	5ba50513          	addi	a0,a0,1466 # ffffffffc0206cf8 <etext+0x43e>
ffffffffc0200746:	a4bff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074a:	604c                	ld	a1,128(s0)
ffffffffc020074c:	00006517          	auipc	a0,0x6
ffffffffc0200750:	5c450513          	addi	a0,a0,1476 # ffffffffc0206d10 <etext+0x456>
ffffffffc0200754:	a3dff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200758:	644c                	ld	a1,136(s0)
ffffffffc020075a:	00006517          	auipc	a0,0x6
ffffffffc020075e:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206d28 <etext+0x46e>
ffffffffc0200762:	a2fff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200766:	684c                	ld	a1,144(s0)
ffffffffc0200768:	00006517          	auipc	a0,0x6
ffffffffc020076c:	5d850513          	addi	a0,a0,1496 # ffffffffc0206d40 <etext+0x486>
ffffffffc0200770:	a21ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200774:	6c4c                	ld	a1,152(s0)
ffffffffc0200776:	00006517          	auipc	a0,0x6
ffffffffc020077a:	5e250513          	addi	a0,a0,1506 # ffffffffc0206d58 <etext+0x49e>
ffffffffc020077e:	a13ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200782:	704c                	ld	a1,160(s0)
ffffffffc0200784:	00006517          	auipc	a0,0x6
ffffffffc0200788:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206d70 <etext+0x4b6>
ffffffffc020078c:	a05ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200790:	744c                	ld	a1,168(s0)
ffffffffc0200792:	00006517          	auipc	a0,0x6
ffffffffc0200796:	5f650513          	addi	a0,a0,1526 # ffffffffc0206d88 <etext+0x4ce>
ffffffffc020079a:	9f7ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020079e:	784c                	ld	a1,176(s0)
ffffffffc02007a0:	00006517          	auipc	a0,0x6
ffffffffc02007a4:	60050513          	addi	a0,a0,1536 # ffffffffc0206da0 <etext+0x4e6>
ffffffffc02007a8:	9e9ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ac:	7c4c                	ld	a1,184(s0)
ffffffffc02007ae:	00006517          	auipc	a0,0x6
ffffffffc02007b2:	60a50513          	addi	a0,a0,1546 # ffffffffc0206db8 <etext+0x4fe>
ffffffffc02007b6:	9dbff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007ba:	606c                	ld	a1,192(s0)
ffffffffc02007bc:	00006517          	auipc	a0,0x6
ffffffffc02007c0:	61450513          	addi	a0,a0,1556 # ffffffffc0206dd0 <etext+0x516>
ffffffffc02007c4:	9cdff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007c8:	646c                	ld	a1,200(s0)
ffffffffc02007ca:	00006517          	auipc	a0,0x6
ffffffffc02007ce:	61e50513          	addi	a0,a0,1566 # ffffffffc0206de8 <etext+0x52e>
ffffffffc02007d2:	9bfff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d6:	686c                	ld	a1,208(s0)
ffffffffc02007d8:	00006517          	auipc	a0,0x6
ffffffffc02007dc:	62850513          	addi	a0,a0,1576 # ffffffffc0206e00 <etext+0x546>
ffffffffc02007e0:	9b1ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e4:	6c6c                	ld	a1,216(s0)
ffffffffc02007e6:	00006517          	auipc	a0,0x6
ffffffffc02007ea:	63250513          	addi	a0,a0,1586 # ffffffffc0206e18 <etext+0x55e>
ffffffffc02007ee:	9a3ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f2:	706c                	ld	a1,224(s0)
ffffffffc02007f4:	00006517          	auipc	a0,0x6
ffffffffc02007f8:	63c50513          	addi	a0,a0,1596 # ffffffffc0206e30 <etext+0x576>
ffffffffc02007fc:	995ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200800:	746c                	ld	a1,232(s0)
ffffffffc0200802:	00006517          	auipc	a0,0x6
ffffffffc0200806:	64650513          	addi	a0,a0,1606 # ffffffffc0206e48 <etext+0x58e>
ffffffffc020080a:	987ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020080e:	786c                	ld	a1,240(s0)
ffffffffc0200810:	00006517          	auipc	a0,0x6
ffffffffc0200814:	65050513          	addi	a0,a0,1616 # ffffffffc0206e60 <etext+0x5a6>
ffffffffc0200818:	979ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020081e:	6402                	ld	s0,0(sp)
ffffffffc0200820:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	65650513          	addi	a0,a0,1622 # ffffffffc0206e78 <etext+0x5be>
}
ffffffffc020082a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082c:	965ff06f          	j	ffffffffc0200190 <cprintf>

ffffffffc0200830 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200830:	1141                	addi	sp,sp,-16
ffffffffc0200832:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200834:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	00006517          	auipc	a0,0x6
ffffffffc020083c:	65850513          	addi	a0,a0,1624 # ffffffffc0206e90 <etext+0x5d6>
print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200842:	94fff0ef          	jal	ffffffffc0200190 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200846:	8522                	mv	a0,s0
ffffffffc0200848:	e1bff0ef          	jal	ffffffffc0200662 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084c:	10043583          	ld	a1,256(s0)
ffffffffc0200850:	00006517          	auipc	a0,0x6
ffffffffc0200854:	65850513          	addi	a0,a0,1624 # ffffffffc0206ea8 <etext+0x5ee>
ffffffffc0200858:	939ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085c:	10843583          	ld	a1,264(s0)
ffffffffc0200860:	00006517          	auipc	a0,0x6
ffffffffc0200864:	66050513          	addi	a0,a0,1632 # ffffffffc0206ec0 <etext+0x606>
ffffffffc0200868:	929ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020086c:	11043583          	ld	a1,272(s0)
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	66850513          	addi	a0,a0,1640 # ffffffffc0206ed8 <etext+0x61e>
ffffffffc0200878:	919ff0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200880:	6402                	ld	s0,0(sp)
ffffffffc0200882:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	00006517          	auipc	a0,0x6
ffffffffc0200888:	66450513          	addi	a0,a0,1636 # ffffffffc0206ee8 <etext+0x62e>
}
ffffffffc020088c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	903ff06f          	j	ffffffffc0200190 <cprintf>

ffffffffc0200892 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200892:	1101                	addi	sp,sp,-32
ffffffffc0200894:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200896:	000a5497          	auipc	s1,0xa5
ffffffffc020089a:	bba48493          	addi	s1,s1,-1094 # ffffffffc02a5450 <check_mm_struct>
ffffffffc020089e:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a0:	e822                	sd	s0,16(sp)
ffffffffc02008a2:	ec06                	sd	ra,24(sp)
ffffffffc02008a4:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a6:	c3a5                	beqz	a5,ffffffffc0200906 <pgfault_handler+0x74>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ac:	11053583          	ld	a1,272(a0)
ffffffffc02008b0:	05500613          	li	a2,85
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b4:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b8:	c399                	beqz	a5,ffffffffc02008be <pgfault_handler+0x2c>
ffffffffc02008ba:	04b00613          	li	a2,75
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05200693          	li	a3,82
ffffffffc02008c8:	06f70063          	beq	a4,a5,ffffffffc0200928 <pgfault_handler+0x96>
ffffffffc02008cc:	00006517          	auipc	a0,0x6
ffffffffc02008d0:	63450513          	addi	a0,a0,1588 # ffffffffc0206f00 <etext+0x646>
ffffffffc02008d4:	8bdff0ef          	jal	ffffffffc0200190 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008d8:	6088                	ld	a0,0(s1)
        assert(current == idleproc);
ffffffffc02008da:	000a5797          	auipc	a5,0xa5
ffffffffc02008de:	b8678793          	addi	a5,a5,-1146 # ffffffffc02a5460 <current>
ffffffffc02008e2:	6398                	ld	a4,0(a5)
    if (check_mm_struct != NULL) {
ffffffffc02008e4:	c50d                	beqz	a0,ffffffffc020090e <pgfault_handler+0x7c>
        assert(current == idleproc);
ffffffffc02008e6:	000a5797          	auipc	a5,0xa5
ffffffffc02008ea:	b8a7b783          	ld	a5,-1142(a5) # ffffffffc02a5470 <idleproc>
ffffffffc02008ee:	04e79063          	bne	a5,a4,ffffffffc020092e <pgfault_handler+0x9c>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f2:	11043603          	ld	a2,272(s0)
ffffffffc02008f6:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fa:	6442                	ld	s0,16(sp)
ffffffffc02008fc:	60e2                	ld	ra,24(sp)
ffffffffc02008fe:	64a2                	ld	s1,8(sp)
ffffffffc0200900:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200902:	1b80406f          	j	ffffffffc0204aba <do_pgfault>
ffffffffc0200906:	000a5797          	auipc	a5,0xa5
ffffffffc020090a:	b5a78793          	addi	a5,a5,-1190 # ffffffffc02a5460 <current>
        if (current == NULL) {
ffffffffc020090e:	639c                	ld	a5,0(a5)
ffffffffc0200910:	cf9d                	beqz	a5,ffffffffc020094e <pgfault_handler+0xbc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200912:	11043603          	ld	a2,272(s0)
ffffffffc0200916:	11843583          	ld	a1,280(s0)
}
ffffffffc020091a:	6442                	ld	s0,16(sp)
ffffffffc020091c:	60e2                	ld	ra,24(sp)
ffffffffc020091e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200920:	7788                	ld	a0,40(a5)
}
ffffffffc0200922:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200924:	1960406f          	j	ffffffffc0204aba <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200928:	05700693          	li	a3,87
ffffffffc020092c:	b745                	j	ffffffffc02008cc <pgfault_handler+0x3a>
        assert(current == idleproc);
ffffffffc020092e:	00006697          	auipc	a3,0x6
ffffffffc0200932:	5f268693          	addi	a3,a3,1522 # ffffffffc0206f20 <etext+0x666>
ffffffffc0200936:	00006617          	auipc	a2,0x6
ffffffffc020093a:	60260613          	addi	a2,a2,1538 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020093e:	06b00593          	li	a1,107
ffffffffc0200942:	00006517          	auipc	a0,0x6
ffffffffc0200946:	60e50513          	addi	a0,a0,1550 # ffffffffc0206f50 <etext+0x696>
ffffffffc020094a:	b27ff0ef          	jal	ffffffffc0200470 <__panic>
            print_trapframe(tf);
ffffffffc020094e:	8522                	mv	a0,s0
ffffffffc0200950:	ee1ff0ef          	jal	ffffffffc0200830 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200954:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200958:	11043583          	ld	a1,272(s0)
ffffffffc020095c:	05500613          	li	a2,85
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200960:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200964:	c399                	beqz	a5,ffffffffc020096a <pgfault_handler+0xd8>
ffffffffc0200966:	04b00613          	li	a2,75
ffffffffc020096a:	11843703          	ld	a4,280(s0)
ffffffffc020096e:	47bd                	li	a5,15
ffffffffc0200970:	05200693          	li	a3,82
ffffffffc0200974:	00f71463          	bne	a4,a5,ffffffffc020097c <pgfault_handler+0xea>
ffffffffc0200978:	05700693          	li	a3,87
ffffffffc020097c:	00006517          	auipc	a0,0x6
ffffffffc0200980:	58450513          	addi	a0,a0,1412 # ffffffffc0206f00 <etext+0x646>
ffffffffc0200984:	80dff0ef          	jal	ffffffffc0200190 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200988:	00006617          	auipc	a2,0x6
ffffffffc020098c:	5e060613          	addi	a2,a2,1504 # ffffffffc0206f68 <etext+0x6ae>
ffffffffc0200990:	07200593          	li	a1,114
ffffffffc0200994:	00006517          	auipc	a0,0x6
ffffffffc0200998:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206f50 <etext+0x696>
ffffffffc020099c:	ad5ff0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02009a0 <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc02009a0:	11853783          	ld	a5,280(a0)
ffffffffc02009a4:	472d                	li	a4,11
ffffffffc02009a6:	0786                	slli	a5,a5,0x1
ffffffffc02009a8:	8385                	srli	a5,a5,0x1
ffffffffc02009aa:	0af76363          	bltu	a4,a5,ffffffffc0200a50 <interrupt_handler+0xb0>
ffffffffc02009ae:	00008717          	auipc	a4,0x8
ffffffffc02009b2:	23270713          	addi	a4,a4,562 # ffffffffc0208be0 <commands+0x48>
ffffffffc02009b6:	078a                	slli	a5,a5,0x2
ffffffffc02009b8:	97ba                	add	a5,a5,a4
ffffffffc02009ba:	439c                	lw	a5,0(a5)
ffffffffc02009bc:	97ba                	add	a5,a5,a4
ffffffffc02009be:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009c0:	00006517          	auipc	a0,0x6
ffffffffc02009c4:	62050513          	addi	a0,a0,1568 # ffffffffc0206fe0 <etext+0x726>
ffffffffc02009c8:	fc8ff06f          	j	ffffffffc0200190 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009cc:	00006517          	auipc	a0,0x6
ffffffffc02009d0:	5f450513          	addi	a0,a0,1524 # ffffffffc0206fc0 <etext+0x706>
ffffffffc02009d4:	fbcff06f          	j	ffffffffc0200190 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009d8:	00006517          	auipc	a0,0x6
ffffffffc02009dc:	5a850513          	addi	a0,a0,1448 # ffffffffc0206f80 <etext+0x6c6>
ffffffffc02009e0:	fb0ff06f          	j	ffffffffc0200190 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009e4:	00006517          	auipc	a0,0x6
ffffffffc02009e8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206fa0 <etext+0x6e6>
ffffffffc02009ec:	fa4ff06f          	j	ffffffffc0200190 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009f0:	1141                	addi	sp,sp,-16
ffffffffc02009f2:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009f4:	b65ff0ef          	jal	ffffffffc0200558 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009f8:	000a5597          	auipc	a1,0xa5
ffffffffc02009fc:	9f858593          	addi	a1,a1,-1544 # ffffffffc02a53f0 <ticks>
ffffffffc0200a00:	6194                	ld	a3,0(a1)
ffffffffc0200a02:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200a06:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_cow_out_size+0x28f4f3e7>
ffffffffc0200a0a:	5c28f637          	lui	a2,0x5c28f
ffffffffc0200a0e:	0685                	addi	a3,a3,1
ffffffffc0200a10:	1702                	slli	a4,a4,0x20
ffffffffc0200a12:	5c360613          	addi	a2,a2,1475 # 5c28f5c3 <_binary_obj___user_cow_out_size+0x5c28271b>
ffffffffc0200a16:	9732                	add	a4,a4,a2
ffffffffc0200a18:	0026d793          	srli	a5,a3,0x2
ffffffffc0200a1c:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200a20:	06400713          	li	a4,100
ffffffffc0200a24:	e194                	sd	a3,0(a1)
ffffffffc0200a26:	8389                	srli	a5,a5,0x2
ffffffffc0200a28:	02e787b3          	mul	a5,a5,a4
ffffffffc0200a2c:	00f69963          	bne	a3,a5,ffffffffc0200a3e <interrupt_handler+0x9e>
ffffffffc0200a30:	000a5797          	auipc	a5,0xa5
ffffffffc0200a34:	a307b783          	ld	a5,-1488(a5) # ffffffffc02a5460 <current>
ffffffffc0200a38:	c399                	beqz	a5,ffffffffc0200a3e <interrupt_handler+0x9e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a3a:	4705                	li	a4,1
ffffffffc0200a3c:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a3e:	60a2                	ld	ra,8(sp)
ffffffffc0200a40:	0141                	addi	sp,sp,16
ffffffffc0200a42:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a44:	00006517          	auipc	a0,0x6
ffffffffc0200a48:	5bc50513          	addi	a0,a0,1468 # ffffffffc0207000 <etext+0x746>
ffffffffc0200a4c:	f44ff06f          	j	ffffffffc0200190 <cprintf>
            print_trapframe(tf);
ffffffffc0200a50:	b3c5                	j	ffffffffc0200830 <print_trapframe>

ffffffffc0200a52 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a52:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a56:	1101                	addi	sp,sp,-32
ffffffffc0200a58:	e822                	sd	s0,16(sp)
ffffffffc0200a5a:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200a5c:	473d                	li	a4,15
void exception_handler(struct trapframe *tf) {
ffffffffc0200a5e:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200a60:	18f76063          	bltu	a4,a5,ffffffffc0200be0 <exception_handler+0x18e>
ffffffffc0200a64:	00008717          	auipc	a4,0x8
ffffffffc0200a68:	1ac70713          	addi	a4,a4,428 # ffffffffc0208c10 <commands+0x78>
ffffffffc0200a6c:	078a                	slli	a5,a5,0x2
ffffffffc0200a6e:	97ba                	add	a5,a5,a4
ffffffffc0200a70:	439c                	lw	a5,0(a5)
ffffffffc0200a72:	97ba                	add	a5,a5,a4
ffffffffc0200a74:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a76:	00006517          	auipc	a0,0x6
ffffffffc0200a7a:	69a50513          	addi	a0,a0,1690 # ffffffffc0207110 <etext+0x856>
ffffffffc0200a7e:	f12ff0ef          	jal	ffffffffc0200190 <cprintf>
            tf->epc += 4;
ffffffffc0200a82:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a86:	60e2                	ld	ra,24(sp)
            tf->epc += 4;
ffffffffc0200a88:	0791                	addi	a5,a5,4
ffffffffc0200a8a:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a8e:	6442                	ld	s0,16(sp)
ffffffffc0200a90:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a92:	1050506f          	j	ffffffffc0206396 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a96:	00006517          	auipc	a0,0x6
ffffffffc0200a9a:	69a50513          	addi	a0,a0,1690 # ffffffffc0207130 <etext+0x876>
}
ffffffffc0200a9e:	6442                	ld	s0,16(sp)
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200aa4:	eecff06f          	j	ffffffffc0200190 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa8:	00006517          	auipc	a0,0x6
ffffffffc0200aac:	6a850513          	addi	a0,a0,1704 # ffffffffc0207150 <etext+0x896>
ffffffffc0200ab0:	b7fd                	j	ffffffffc0200a9e <exception_handler+0x4c>
            cprintf("Instruction page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	6be50513          	addi	a0,a0,1726 # ffffffffc0207170 <etext+0x8b6>
ffffffffc0200aba:	b7d5                	j	ffffffffc0200a9e <exception_handler+0x4c>
            cprintf("Load page fault\n");
ffffffffc0200abc:	00006517          	auipc	a0,0x6
ffffffffc0200ac0:	6cc50513          	addi	a0,a0,1740 # ffffffffc0207188 <etext+0x8ce>
ffffffffc0200ac4:	eccff0ef          	jal	ffffffffc0200190 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac8:	8522                	mv	a0,s0
ffffffffc0200aca:	dc9ff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200ace:	12051a63          	bnez	a0,ffffffffc0200c02 <exception_handler+0x1b0>
}
ffffffffc0200ad2:	60e2                	ld	ra,24(sp)
ffffffffc0200ad4:	6442                	ld	s0,16(sp)
ffffffffc0200ad6:	6105                	addi	sp,sp,32
ffffffffc0200ad8:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	6c650513          	addi	a0,a0,1734 # ffffffffc02071a0 <etext+0x8e6>
ffffffffc0200ae2:	eaeff0ef          	jal	ffffffffc0200190 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dabff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200aec:	d17d                	beqz	a0,ffffffffc0200ad2 <exception_handler+0x80>
ffffffffc0200aee:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc0200af0:	8522                	mv	a0,s0
ffffffffc0200af2:	d3fff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af6:	66a2                	ld	a3,8(sp)
ffffffffc0200af8:	00006617          	auipc	a2,0x6
ffffffffc0200afc:	5c860613          	addi	a2,a2,1480 # ffffffffc02070c0 <etext+0x806>
ffffffffc0200b00:	0f800593          	li	a1,248
ffffffffc0200b04:	00006517          	auipc	a0,0x6
ffffffffc0200b08:	44c50513          	addi	a0,a0,1100 # ffffffffc0206f50 <etext+0x696>
ffffffffc0200b0c:	965ff0ef          	jal	ffffffffc0200470 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b10:	00006517          	auipc	a0,0x6
ffffffffc0200b14:	51050513          	addi	a0,a0,1296 # ffffffffc0207020 <etext+0x766>
ffffffffc0200b18:	b759                	j	ffffffffc0200a9e <exception_handler+0x4c>
            cprintf("Instruction access fault\n");
ffffffffc0200b1a:	00006517          	auipc	a0,0x6
ffffffffc0200b1e:	52650513          	addi	a0,a0,1318 # ffffffffc0207040 <etext+0x786>
ffffffffc0200b22:	bfb5                	j	ffffffffc0200a9e <exception_handler+0x4c>
            cprintf("Illegal instruction\n");
ffffffffc0200b24:	00006517          	auipc	a0,0x6
ffffffffc0200b28:	53c50513          	addi	a0,a0,1340 # ffffffffc0207060 <etext+0x7a6>
ffffffffc0200b2c:	bf8d                	j	ffffffffc0200a9e <exception_handler+0x4c>
            cprintf("Breakpoint\n");
ffffffffc0200b2e:	00006517          	auipc	a0,0x6
ffffffffc0200b32:	54a50513          	addi	a0,a0,1354 # ffffffffc0207078 <etext+0x7be>
ffffffffc0200b36:	e5aff0ef          	jal	ffffffffc0200190 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b3a:	6458                	ld	a4,136(s0)
ffffffffc0200b3c:	47a9                	li	a5,10
ffffffffc0200b3e:	f8f71ae3          	bne	a4,a5,ffffffffc0200ad2 <exception_handler+0x80>
                tf->epc += 4;
ffffffffc0200b42:	10843783          	ld	a5,264(s0)
ffffffffc0200b46:	0791                	addi	a5,a5,4
ffffffffc0200b48:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b4c:	04b050ef          	jal	ffffffffc0206396 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b50:	000a5717          	auipc	a4,0xa5
ffffffffc0200b54:	91073703          	ld	a4,-1776(a4) # ffffffffc02a5460 <current>
ffffffffc0200b58:	8522                	mv	a0,s0
}
ffffffffc0200b5a:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6b0c                	ld	a1,16(a4)
}
ffffffffc0200b5e:	60e2                	ld	ra,24(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b60:	6789                	lui	a5,0x2
ffffffffc0200b62:	95be                	add	a1,a1,a5
}
ffffffffc0200b64:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b66:	ac01                	j	ffffffffc0200d76 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b68:	00006517          	auipc	a0,0x6
ffffffffc0200b6c:	52050513          	addi	a0,a0,1312 # ffffffffc0207088 <etext+0x7ce>
ffffffffc0200b70:	b73d                	j	ffffffffc0200a9e <exception_handler+0x4c>
            cprintf("Load access fault\n");
ffffffffc0200b72:	00006517          	auipc	a0,0x6
ffffffffc0200b76:	53650513          	addi	a0,a0,1334 # ffffffffc02070a8 <etext+0x7ee>
ffffffffc0200b7a:	e16ff0ef          	jal	ffffffffc0200190 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7e:	8522                	mv	a0,s0
ffffffffc0200b80:	d13ff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200b84:	d539                	beqz	a0,ffffffffc0200ad2 <exception_handler+0x80>
ffffffffc0200b86:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc0200b88:	8522                	mv	a0,s0
ffffffffc0200b8a:	ca7ff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8e:	66a2                	ld	a3,8(sp)
ffffffffc0200b90:	00006617          	auipc	a2,0x6
ffffffffc0200b94:	53060613          	addi	a2,a2,1328 # ffffffffc02070c0 <etext+0x806>
ffffffffc0200b98:	0cd00593          	li	a1,205
ffffffffc0200b9c:	00006517          	auipc	a0,0x6
ffffffffc0200ba0:	3b450513          	addi	a0,a0,948 # ffffffffc0206f50 <etext+0x696>
ffffffffc0200ba4:	8cdff0ef          	jal	ffffffffc0200470 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba8:	00006517          	auipc	a0,0x6
ffffffffc0200bac:	55050513          	addi	a0,a0,1360 # ffffffffc02070f8 <etext+0x83e>
ffffffffc0200bb0:	de0ff0ef          	jal	ffffffffc0200190 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb4:	8522                	mv	a0,s0
ffffffffc0200bb6:	cddff0ef          	jal	ffffffffc0200892 <pgfault_handler>
ffffffffc0200bba:	f0050ce3          	beqz	a0,ffffffffc0200ad2 <exception_handler+0x80>
ffffffffc0200bbe:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc0200bc0:	8522                	mv	a0,s0
ffffffffc0200bc2:	c6fff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc6:	66a2                	ld	a3,8(sp)
ffffffffc0200bc8:	00006617          	auipc	a2,0x6
ffffffffc0200bcc:	4f860613          	addi	a2,a2,1272 # ffffffffc02070c0 <etext+0x806>
ffffffffc0200bd0:	0d700593          	li	a1,215
ffffffffc0200bd4:	00006517          	auipc	a0,0x6
ffffffffc0200bd8:	37c50513          	addi	a0,a0,892 # ffffffffc0206f50 <etext+0x696>
ffffffffc0200bdc:	895ff0ef          	jal	ffffffffc0200470 <__panic>
            print_trapframe(tf);
ffffffffc0200be0:	8522                	mv	a0,s0
}
ffffffffc0200be2:	6442                	ld	s0,16(sp)
ffffffffc0200be4:	60e2                	ld	ra,24(sp)
ffffffffc0200be6:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be8:	b1a1                	j	ffffffffc0200830 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bea:	00006617          	auipc	a2,0x6
ffffffffc0200bee:	4f660613          	addi	a2,a2,1270 # ffffffffc02070e0 <etext+0x826>
ffffffffc0200bf2:	0d100593          	li	a1,209
ffffffffc0200bf6:	00006517          	auipc	a0,0x6
ffffffffc0200bfa:	35a50513          	addi	a0,a0,858 # ffffffffc0206f50 <etext+0x696>
ffffffffc0200bfe:	873ff0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0200c02:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc0200c04:	8522                	mv	a0,s0
ffffffffc0200c06:	c2bff0ef          	jal	ffffffffc0200830 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c0a:	66a2                	ld	a3,8(sp)
ffffffffc0200c0c:	00006617          	auipc	a2,0x6
ffffffffc0200c10:	4b460613          	addi	a2,a2,1204 # ffffffffc02070c0 <etext+0x806>
ffffffffc0200c14:	0f100593          	li	a1,241
ffffffffc0200c18:	00006517          	auipc	a0,0x6
ffffffffc0200c1c:	33850513          	addi	a0,a0,824 # ffffffffc0206f50 <etext+0x696>
ffffffffc0200c20:	851ff0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0200c24 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c24:	1101                	addi	sp,sp,-32
ffffffffc0200c26:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c28:	000a5417          	auipc	s0,0xa5
ffffffffc0200c2c:	83840413          	addi	s0,s0,-1992 # ffffffffc02a5460 <current>
ffffffffc0200c30:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c32:	ec06                	sd	ra,24(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c38:	c329                	beqz	a4,ffffffffc0200c7a <trap+0x56>
ffffffffc0200c3a:	e426                	sd	s1,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3c:	10053483          	ld	s1,256(a0)
ffffffffc0200c40:	e04a                	sd	s2,0(sp)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c42:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c46:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c48:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c4c:	0206c463          	bltz	a3,ffffffffc0200c74 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c50:	e03ff0ef          	jal	ffffffffc0200a52 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c54:	601c                	ld	a5,0(s0)
ffffffffc0200c56:	0b27b023          	sd	s2,160(a5) # 20a0 <_binary_obj___user_softint_out_size-0x5fd0>
        if (!in_kernel) {
ffffffffc0200c5a:	e499                	bnez	s1,ffffffffc0200c68 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c5c:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c60:	8b05                	andi	a4,a4,1
ffffffffc0200c62:	ef0d                	bnez	a4,ffffffffc0200c9c <trap+0x78>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c64:	6f9c                	ld	a5,24(a5)
ffffffffc0200c66:	e785                	bnez	a5,ffffffffc0200c8e <trap+0x6a>
                schedule();
            }
        }
    }
}
ffffffffc0200c68:	60e2                	ld	ra,24(sp)
ffffffffc0200c6a:	6442                	ld	s0,16(sp)
ffffffffc0200c6c:	64a2                	ld	s1,8(sp)
ffffffffc0200c6e:	6902                	ld	s2,0(sp)
ffffffffc0200c70:	6105                	addi	sp,sp,32
ffffffffc0200c72:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c74:	d2dff0ef          	jal	ffffffffc02009a0 <interrupt_handler>
ffffffffc0200c78:	bff1                	j	ffffffffc0200c54 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c7a:	0006c663          	bltz	a3,ffffffffc0200c86 <trap+0x62>
}
ffffffffc0200c7e:	6442                	ld	s0,16(sp)
ffffffffc0200c80:	60e2                	ld	ra,24(sp)
ffffffffc0200c82:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c84:	b3f9                	j	ffffffffc0200a52 <exception_handler>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c8c:	bb11                	j	ffffffffc02009a0 <interrupt_handler>
}
ffffffffc0200c8e:	6442                	ld	s0,16(sp)
                schedule();
ffffffffc0200c90:	64a2                	ld	s1,8(sp)
ffffffffc0200c92:	6902                	ld	s2,0(sp)
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c98:	6120506f          	j	ffffffffc02062aa <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c9c:	555d                	li	a0,-9
ffffffffc0200c9e:	0c7040ef          	jal	ffffffffc0205564 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca2:	601c                	ld	a5,0(s0)
ffffffffc0200ca4:	b7c1                	j	ffffffffc0200c64 <trap+0x40>
	...

ffffffffc0200ca8 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ca8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cac:	00011463          	bnez	sp,ffffffffc0200cb4 <__alltraps+0xc>
ffffffffc0200cb0:	14002173          	csrr	sp,sscratch
ffffffffc0200cb4:	712d                	addi	sp,sp,-288
ffffffffc0200cb6:	e002                	sd	zero,0(sp)
ffffffffc0200cb8:	e406                	sd	ra,8(sp)
ffffffffc0200cba:	ec0e                	sd	gp,24(sp)
ffffffffc0200cbc:	f012                	sd	tp,32(sp)
ffffffffc0200cbe:	f416                	sd	t0,40(sp)
ffffffffc0200cc0:	f81a                	sd	t1,48(sp)
ffffffffc0200cc2:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc4:	e0a2                	sd	s0,64(sp)
ffffffffc0200cc6:	e4a6                	sd	s1,72(sp)
ffffffffc0200cc8:	e8aa                	sd	a0,80(sp)
ffffffffc0200cca:	ecae                	sd	a1,88(sp)
ffffffffc0200ccc:	f0b2                	sd	a2,96(sp)
ffffffffc0200cce:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd4:	e142                	sd	a6,128(sp)
ffffffffc0200cd6:	e546                	sd	a7,136(sp)
ffffffffc0200cd8:	e94a                	sd	s2,144(sp)
ffffffffc0200cda:	ed4e                	sd	s3,152(sp)
ffffffffc0200cdc:	f152                	sd	s4,160(sp)
ffffffffc0200cde:	f556                	sd	s5,168(sp)
ffffffffc0200ce0:	f95a                	sd	s6,176(sp)
ffffffffc0200ce2:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce4:	e1e2                	sd	s8,192(sp)
ffffffffc0200ce6:	e5e6                	sd	s9,200(sp)
ffffffffc0200ce8:	e9ea                	sd	s10,208(sp)
ffffffffc0200cea:	edee                	sd	s11,216(sp)
ffffffffc0200cec:	f1f2                	sd	t3,224(sp)
ffffffffc0200cee:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf0:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf2:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cf8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cfc:	14102973          	csrr	s2,sepc
ffffffffc0200d00:	143029f3          	csrr	s3,stval
ffffffffc0200d04:	14202a73          	csrr	s4,scause
ffffffffc0200d08:	e822                	sd	s0,16(sp)
ffffffffc0200d0a:	e226                	sd	s1,256(sp)
ffffffffc0200d0c:	e64a                	sd	s2,264(sp)
ffffffffc0200d0e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d10:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d12:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d14:	f11ff0ef          	jal	ffffffffc0200c24 <trap>

ffffffffc0200d18 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d18:	6492                	ld	s1,256(sp)
ffffffffc0200d1a:	6932                	ld	s2,264(sp)
ffffffffc0200d1c:	1004f413          	andi	s0,s1,256
ffffffffc0200d20:	e401                	bnez	s0,ffffffffc0200d28 <__trapret+0x10>
ffffffffc0200d22:	1200                	addi	s0,sp,288
ffffffffc0200d24:	14041073          	csrw	sscratch,s0
ffffffffc0200d28:	10049073          	csrw	sstatus,s1
ffffffffc0200d2c:	14191073          	csrw	sepc,s2
ffffffffc0200d30:	60a2                	ld	ra,8(sp)
ffffffffc0200d32:	61e2                	ld	gp,24(sp)
ffffffffc0200d34:	7202                	ld	tp,32(sp)
ffffffffc0200d36:	72a2                	ld	t0,40(sp)
ffffffffc0200d38:	7342                	ld	t1,48(sp)
ffffffffc0200d3a:	73e2                	ld	t2,56(sp)
ffffffffc0200d3c:	6406                	ld	s0,64(sp)
ffffffffc0200d3e:	64a6                	ld	s1,72(sp)
ffffffffc0200d40:	6546                	ld	a0,80(sp)
ffffffffc0200d42:	65e6                	ld	a1,88(sp)
ffffffffc0200d44:	7606                	ld	a2,96(sp)
ffffffffc0200d46:	76a6                	ld	a3,104(sp)
ffffffffc0200d48:	7746                	ld	a4,112(sp)
ffffffffc0200d4a:	77e6                	ld	a5,120(sp)
ffffffffc0200d4c:	680a                	ld	a6,128(sp)
ffffffffc0200d4e:	68aa                	ld	a7,136(sp)
ffffffffc0200d50:	694a                	ld	s2,144(sp)
ffffffffc0200d52:	69ea                	ld	s3,152(sp)
ffffffffc0200d54:	7a0a                	ld	s4,160(sp)
ffffffffc0200d56:	7aaa                	ld	s5,168(sp)
ffffffffc0200d58:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5a:	7bea                	ld	s7,184(sp)
ffffffffc0200d5c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d5e:	6cae                	ld	s9,200(sp)
ffffffffc0200d60:	6d4e                	ld	s10,208(sp)
ffffffffc0200d62:	6dee                	ld	s11,216(sp)
ffffffffc0200d64:	7e0e                	ld	t3,224(sp)
ffffffffc0200d66:	7eae                	ld	t4,232(sp)
ffffffffc0200d68:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6a:	7fee                	ld	t6,248(sp)
ffffffffc0200d6c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d6e:	10200073          	sret

ffffffffc0200d72 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d72:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d74:	b755                	j	ffffffffc0200d18 <__trapret>

ffffffffc0200d76 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d76:	ee058593          	addi	a1,a1,-288

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d7e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d82:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d86:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d8e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d92:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d96:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d9c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d9e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da0:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da2:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da4:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200da6:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200da8:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200daa:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dac:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dae:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db0:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db2:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db4:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200db6:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200db8:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dba:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dbc:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dbe:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dc6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dc8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dca:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dcc:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dce:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dd6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dd8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dda:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200ddc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dde:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de0:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de2:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de4:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200de6:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200de8:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dea:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200dec:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dee:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200df6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200df8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfa:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200dfc:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dfe:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e00:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e02:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e04:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e06:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e08:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e0c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e0e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e10:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e12:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e14:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e16:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e18:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1a:	812e                	mv	sp,a1
ffffffffc0200e1c:	bdf5                	j	ffffffffc0200d18 <__trapret>

ffffffffc0200e1e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e1e:	000a0797          	auipc	a5,0xa0
ffffffffc0200e22:	4fa78793          	addi	a5,a5,1274 # ffffffffc02a1318 <free_area>
ffffffffc0200e26:	e79c                	sd	a5,8(a5)
ffffffffc0200e28:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e2a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e2e:	8082                	ret

ffffffffc0200e30 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e30:	000a0517          	auipc	a0,0xa0
ffffffffc0200e34:	4f856503          	lwu	a0,1272(a0) # ffffffffc02a1328 <free_area+0x10>
ffffffffc0200e38:	8082                	ret

ffffffffc0200e3a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e3a:	711d                	addi	sp,sp,-96
ffffffffc0200e3c:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e3e:	000a0917          	auipc	s2,0xa0
ffffffffc0200e42:	4da90913          	addi	s2,s2,1242 # ffffffffc02a1318 <free_area>
ffffffffc0200e46:	00893783          	ld	a5,8(s2)
ffffffffc0200e4a:	ec86                	sd	ra,88(sp)
ffffffffc0200e4c:	e8a2                	sd	s0,80(sp)
ffffffffc0200e4e:	e4a6                	sd	s1,72(sp)
ffffffffc0200e50:	fc4e                	sd	s3,56(sp)
ffffffffc0200e52:	f852                	sd	s4,48(sp)
ffffffffc0200e54:	f456                	sd	s5,40(sp)
ffffffffc0200e56:	f05a                	sd	s6,32(sp)
ffffffffc0200e58:	ec5e                	sd	s7,24(sp)
ffffffffc0200e5a:	e862                	sd	s8,16(sp)
ffffffffc0200e5c:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5e:	2d278c63          	beq	a5,s2,ffffffffc0201136 <default_check+0x2fc>
    int count = 0, total = 0;
ffffffffc0200e62:	4401                	li	s0,0
ffffffffc0200e64:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e66:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e6a:	8b09                	andi	a4,a4,2
ffffffffc0200e6c:	2c070963          	beqz	a4,ffffffffc020113e <default_check+0x304>
        count ++, total += p->property;
ffffffffc0200e70:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e74:	679c                	ld	a5,8(a5)
ffffffffc0200e76:	2485                	addiw	s1,s1,1
ffffffffc0200e78:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7a:	ff2796e3          	bne	a5,s2,ffffffffc0200e66 <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200e7e:	89a2                	mv	s3,s0
ffffffffc0200e80:	753000ef          	jal	ffffffffc0201dd2 <nr_free_pages>
ffffffffc0200e84:	71351d63          	bne	a0,s3,ffffffffc020159e <default_check+0x764>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e88:	4505                	li	a0,1
ffffffffc0200e8a:	681000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200e8e:	8aaa                	mv	s5,a0
ffffffffc0200e90:	44050763          	beqz	a0,ffffffffc02012de <default_check+0x4a4>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e94:	4505                	li	a0,1
ffffffffc0200e96:	675000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200e9a:	89aa                	mv	s3,a0
ffffffffc0200e9c:	72050163          	beqz	a0,ffffffffc02015be <default_check+0x784>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ea0:	4505                	li	a0,1
ffffffffc0200ea2:	669000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200ea6:	8a2a                	mv	s4,a0
ffffffffc0200ea8:	4a050b63          	beqz	a0,ffffffffc020135e <default_check+0x524>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200eac:	2b3a8963          	beq	s5,s3,ffffffffc020115e <default_check+0x324>
ffffffffc0200eb0:	2aaa8763          	beq	s5,a0,ffffffffc020115e <default_check+0x324>
ffffffffc0200eb4:	2aa98563          	beq	s3,a0,ffffffffc020115e <default_check+0x324>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb8:	000aa783          	lw	a5,0(s5)
ffffffffc0200ebc:	2c079163          	bnez	a5,ffffffffc020117e <default_check+0x344>
ffffffffc0200ec0:	0009a783          	lw	a5,0(s3)
ffffffffc0200ec4:	2a079d63          	bnez	a5,ffffffffc020117e <default_check+0x344>
ffffffffc0200ec8:	411c                	lw	a5,0(a0)
ffffffffc0200eca:	2a079a63          	bnez	a5,ffffffffc020117e <default_check+0x344>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ece:	000a4797          	auipc	a5,0xa4
ffffffffc0200ed2:	55a7b783          	ld	a5,1370(a5) # ffffffffc02a5428 <pages>
ffffffffc0200ed6:	00008617          	auipc	a2,0x8
ffffffffc0200eda:	0d263603          	ld	a2,210(a2) # ffffffffc0208fa8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ede:	000a4697          	auipc	a3,0xa4
ffffffffc0200ee2:	5426b683          	ld	a3,1346(a3) # ffffffffc02a5420 <npage>
ffffffffc0200ee6:	40fa8733          	sub	a4,s5,a5
ffffffffc0200eea:	8719                	srai	a4,a4,0x6
ffffffffc0200eec:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eee:	0732                	slli	a4,a4,0xc
ffffffffc0200ef0:	06b2                	slli	a3,a3,0xc
ffffffffc0200ef2:	2ad77663          	bgeu	a4,a3,ffffffffc020119e <default_check+0x364>
    return page - pages + nbase;
ffffffffc0200ef6:	40f98733          	sub	a4,s3,a5
ffffffffc0200efa:	8719                	srai	a4,a4,0x6
ffffffffc0200efc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200efe:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f00:	4cd77f63          	bgeu	a4,a3,ffffffffc02013de <default_check+0x5a4>
    return page - pages + nbase;
ffffffffc0200f04:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f08:	8799                	srai	a5,a5,0x6
ffffffffc0200f0a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f0c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f0e:	32d7f863          	bgeu	a5,a3,ffffffffc020123e <default_check+0x404>
    assert(alloc_page() == NULL);
ffffffffc0200f12:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f14:	00093c03          	ld	s8,0(s2)
ffffffffc0200f18:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f1c:	000a0b17          	auipc	s6,0xa0
ffffffffc0200f20:	40cb2b03          	lw	s6,1036(s6) # ffffffffc02a1328 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200f24:	01293023          	sd	s2,0(s2)
ffffffffc0200f28:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200f2c:	000a0797          	auipc	a5,0xa0
ffffffffc0200f30:	3e07ae23          	sw	zero,1020(a5) # ffffffffc02a1328 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f34:	5d7000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200f38:	2e051363          	bnez	a0,ffffffffc020121e <default_check+0x3e4>
    free_page(p0);
ffffffffc0200f3c:	8556                	mv	a0,s5
ffffffffc0200f3e:	4585                	li	a1,1
ffffffffc0200f40:	653000ef          	jal	ffffffffc0201d92 <free_pages>
    free_page(p1);
ffffffffc0200f44:	854e                	mv	a0,s3
ffffffffc0200f46:	4585                	li	a1,1
ffffffffc0200f48:	64b000ef          	jal	ffffffffc0201d92 <free_pages>
    free_page(p2);
ffffffffc0200f4c:	8552                	mv	a0,s4
ffffffffc0200f4e:	4585                	li	a1,1
ffffffffc0200f50:	643000ef          	jal	ffffffffc0201d92 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f54:	000a0717          	auipc	a4,0xa0
ffffffffc0200f58:	3d472703          	lw	a4,980(a4) # ffffffffc02a1328 <free_area+0x10>
ffffffffc0200f5c:	478d                	li	a5,3
ffffffffc0200f5e:	2af71063          	bne	a4,a5,ffffffffc02011fe <default_check+0x3c4>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f62:	4505                	li	a0,1
ffffffffc0200f64:	5a7000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200f68:	89aa                	mv	s3,a0
ffffffffc0200f6a:	26050a63          	beqz	a0,ffffffffc02011de <default_check+0x3a4>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f6e:	4505                	li	a0,1
ffffffffc0200f70:	59b000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200f74:	8aaa                	mv	s5,a0
ffffffffc0200f76:	3c050463          	beqz	a0,ffffffffc020133e <default_check+0x504>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f7a:	4505                	li	a0,1
ffffffffc0200f7c:	58f000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200f80:	8a2a                	mv	s4,a0
ffffffffc0200f82:	38050e63          	beqz	a0,ffffffffc020131e <default_check+0x4e4>
    assert(alloc_page() == NULL);
ffffffffc0200f86:	4505                	li	a0,1
ffffffffc0200f88:	583000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200f8c:	36051963          	bnez	a0,ffffffffc02012fe <default_check+0x4c4>
    free_page(p0);
ffffffffc0200f90:	4585                	li	a1,1
ffffffffc0200f92:	854e                	mv	a0,s3
ffffffffc0200f94:	5ff000ef          	jal	ffffffffc0201d92 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f98:	00893783          	ld	a5,8(s2)
ffffffffc0200f9c:	23278163          	beq	a5,s2,ffffffffc02011be <default_check+0x384>
    assert((p = alloc_page()) == p0);
ffffffffc0200fa0:	4505                	li	a0,1
ffffffffc0200fa2:	569000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200fa6:	30a99c63          	bne	s3,a0,ffffffffc02012be <default_check+0x484>
    assert(alloc_page() == NULL);
ffffffffc0200faa:	4505                	li	a0,1
ffffffffc0200fac:	55f000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200fb0:	2e051763          	bnez	a0,ffffffffc020129e <default_check+0x464>
    assert(nr_free == 0);
ffffffffc0200fb4:	000a0797          	auipc	a5,0xa0
ffffffffc0200fb8:	3747a783          	lw	a5,884(a5) # ffffffffc02a1328 <free_area+0x10>
ffffffffc0200fbc:	2c079163          	bnez	a5,ffffffffc020127e <default_check+0x444>
    free_page(p);
ffffffffc0200fc0:	854e                	mv	a0,s3
ffffffffc0200fc2:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fc4:	01893023          	sd	s8,0(s2)
ffffffffc0200fc8:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0200fcc:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0200fd0:	5c3000ef          	jal	ffffffffc0201d92 <free_pages>
    free_page(p1);
ffffffffc0200fd4:	8556                	mv	a0,s5
ffffffffc0200fd6:	4585                	li	a1,1
ffffffffc0200fd8:	5bb000ef          	jal	ffffffffc0201d92 <free_pages>
    free_page(p2);
ffffffffc0200fdc:	8552                	mv	a0,s4
ffffffffc0200fde:	4585                	li	a1,1
ffffffffc0200fe0:	5b3000ef          	jal	ffffffffc0201d92 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fe4:	4515                	li	a0,5
ffffffffc0200fe6:	525000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0200fea:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fec:	26050963          	beqz	a0,ffffffffc020125e <default_check+0x424>
ffffffffc0200ff0:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc0200ff2:	8b89                	andi	a5,a5,2
ffffffffc0200ff4:	54079563          	bnez	a5,ffffffffc020153e <default_check+0x704>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ff8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ffa:	00093b83          	ld	s7,0(s2)
ffffffffc0200ffe:	00893b03          	ld	s6,8(s2)
ffffffffc0201002:	01293023          	sd	s2,0(s2)
ffffffffc0201006:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc020100a:	501000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc020100e:	50051863          	bnez	a0,ffffffffc020151e <default_check+0x6e4>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201012:	08098a13          	addi	s4,s3,128
ffffffffc0201016:	8552                	mv	a0,s4
ffffffffc0201018:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020101a:	000a0c17          	auipc	s8,0xa0
ffffffffc020101e:	30ec2c03          	lw	s8,782(s8) # ffffffffc02a1328 <free_area+0x10>
    nr_free = 0;
ffffffffc0201022:	000a0797          	auipc	a5,0xa0
ffffffffc0201026:	3007a323          	sw	zero,774(a5) # ffffffffc02a1328 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020102a:	569000ef          	jal	ffffffffc0201d92 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020102e:	4511                	li	a0,4
ffffffffc0201030:	4db000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0201034:	4c051563          	bnez	a0,ffffffffc02014fe <default_check+0x6c4>
ffffffffc0201038:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020103c:	8b89                	andi	a5,a5,2
ffffffffc020103e:	4a078063          	beqz	a5,ffffffffc02014de <default_check+0x6a4>
ffffffffc0201042:	0909a503          	lw	a0,144(s3)
ffffffffc0201046:	478d                	li	a5,3
ffffffffc0201048:	48f51b63          	bne	a0,a5,ffffffffc02014de <default_check+0x6a4>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020104c:	4bf000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0201050:	8aaa                	mv	s5,a0
ffffffffc0201052:	46050663          	beqz	a0,ffffffffc02014be <default_check+0x684>
    assert(alloc_page() == NULL);
ffffffffc0201056:	4505                	li	a0,1
ffffffffc0201058:	4b3000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc020105c:	44051163          	bnez	a0,ffffffffc020149e <default_check+0x664>
    assert(p0 + 2 == p1);
ffffffffc0201060:	415a1f63          	bne	s4,s5,ffffffffc020147e <default_check+0x644>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201064:	4585                	li	a1,1
ffffffffc0201066:	854e                	mv	a0,s3
ffffffffc0201068:	52b000ef          	jal	ffffffffc0201d92 <free_pages>
    free_pages(p1, 3);
ffffffffc020106c:	8552                	mv	a0,s4
ffffffffc020106e:	458d                	li	a1,3
ffffffffc0201070:	523000ef          	jal	ffffffffc0201d92 <free_pages>
ffffffffc0201074:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201078:	04098c93          	addi	s9,s3,64
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020107c:	8b89                	andi	a5,a5,2
ffffffffc020107e:	3e078063          	beqz	a5,ffffffffc020145e <default_check+0x624>
ffffffffc0201082:	0109aa83          	lw	s5,16(s3)
ffffffffc0201086:	4785                	li	a5,1
ffffffffc0201088:	3cfa9b63          	bne	s5,a5,ffffffffc020145e <default_check+0x624>
ffffffffc020108c:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201090:	8b89                	andi	a5,a5,2
ffffffffc0201092:	3a078663          	beqz	a5,ffffffffc020143e <default_check+0x604>
ffffffffc0201096:	010a2703          	lw	a4,16(s4)
ffffffffc020109a:	478d                	li	a5,3
ffffffffc020109c:	3af71163          	bne	a4,a5,ffffffffc020143e <default_check+0x604>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010a0:	8556                	mv	a0,s5
ffffffffc02010a2:	469000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc02010a6:	36a99c63          	bne	s3,a0,ffffffffc020141e <default_check+0x5e4>
    free_page(p0);
ffffffffc02010aa:	85d6                	mv	a1,s5
ffffffffc02010ac:	4e7000ef          	jal	ffffffffc0201d92 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010b0:	4509                	li	a0,2
ffffffffc02010b2:	459000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc02010b6:	34aa1463          	bne	s4,a0,ffffffffc02013fe <default_check+0x5c4>

    free_pages(p0, 2);
ffffffffc02010ba:	4589                	li	a1,2
ffffffffc02010bc:	4d7000ef          	jal	ffffffffc0201d92 <free_pages>
    free_page(p2);
ffffffffc02010c0:	85d6                	mv	a1,s5
ffffffffc02010c2:	8566                	mv	a0,s9
ffffffffc02010c4:	4cf000ef          	jal	ffffffffc0201d92 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010c8:	4515                	li	a0,5
ffffffffc02010ca:	441000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc02010ce:	89aa                	mv	s3,a0
ffffffffc02010d0:	48050763          	beqz	a0,ffffffffc020155e <default_check+0x724>
    assert(alloc_page() == NULL);
ffffffffc02010d4:	8556                	mv	a0,s5
ffffffffc02010d6:	435000ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc02010da:	2e051263          	bnez	a0,ffffffffc02013be <default_check+0x584>

    assert(nr_free == 0);
ffffffffc02010de:	000a0797          	auipc	a5,0xa0
ffffffffc02010e2:	24a7a783          	lw	a5,586(a5) # ffffffffc02a1328 <free_area+0x10>
ffffffffc02010e6:	2a079c63          	bnez	a5,ffffffffc020139e <default_check+0x564>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010ea:	854e                	mv	a0,s3
ffffffffc02010ec:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc02010ee:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc02010f2:	01793023          	sd	s7,0(s2)
ffffffffc02010f6:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc02010fa:	499000ef          	jal	ffffffffc0201d92 <free_pages>
    return listelm->next;
ffffffffc02010fe:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201102:	01278963          	beq	a5,s2,ffffffffc0201114 <default_check+0x2da>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201106:	ff87a703          	lw	a4,-8(a5)
ffffffffc020110a:	679c                	ld	a5,8(a5)
ffffffffc020110c:	34fd                	addiw	s1,s1,-1
ffffffffc020110e:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201110:	ff279be3          	bne	a5,s2,ffffffffc0201106 <default_check+0x2cc>
    }
    assert(count == 0);
ffffffffc0201114:	26049563          	bnez	s1,ffffffffc020137e <default_check+0x544>
    assert(total == 0);
ffffffffc0201118:	46041363          	bnez	s0,ffffffffc020157e <default_check+0x744>
}
ffffffffc020111c:	60e6                	ld	ra,88(sp)
ffffffffc020111e:	6446                	ld	s0,80(sp)
ffffffffc0201120:	64a6                	ld	s1,72(sp)
ffffffffc0201122:	6906                	ld	s2,64(sp)
ffffffffc0201124:	79e2                	ld	s3,56(sp)
ffffffffc0201126:	7a42                	ld	s4,48(sp)
ffffffffc0201128:	7aa2                	ld	s5,40(sp)
ffffffffc020112a:	7b02                	ld	s6,32(sp)
ffffffffc020112c:	6be2                	ld	s7,24(sp)
ffffffffc020112e:	6c42                	ld	s8,16(sp)
ffffffffc0201130:	6ca2                	ld	s9,8(sp)
ffffffffc0201132:	6125                	addi	sp,sp,96
ffffffffc0201134:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201136:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201138:	4401                	li	s0,0
ffffffffc020113a:	4481                	li	s1,0
ffffffffc020113c:	b391                	j	ffffffffc0200e80 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc020113e:	00006697          	auipc	a3,0x6
ffffffffc0201142:	07a68693          	addi	a3,a3,122 # ffffffffc02071b8 <etext+0x8fe>
ffffffffc0201146:	00006617          	auipc	a2,0x6
ffffffffc020114a:	df260613          	addi	a2,a2,-526 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020114e:	0f000593          	li	a1,240
ffffffffc0201152:	00006517          	auipc	a0,0x6
ffffffffc0201156:	07650513          	addi	a0,a0,118 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020115a:	b16ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020115e:	00006697          	auipc	a3,0x6
ffffffffc0201162:	10268693          	addi	a3,a3,258 # ffffffffc0207260 <etext+0x9a6>
ffffffffc0201166:	00006617          	auipc	a2,0x6
ffffffffc020116a:	dd260613          	addi	a2,a2,-558 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020116e:	0bd00593          	li	a1,189
ffffffffc0201172:	00006517          	auipc	a0,0x6
ffffffffc0201176:	05650513          	addi	a0,a0,86 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020117a:	af6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020117e:	00006697          	auipc	a3,0x6
ffffffffc0201182:	10a68693          	addi	a3,a3,266 # ffffffffc0207288 <etext+0x9ce>
ffffffffc0201186:	00006617          	auipc	a2,0x6
ffffffffc020118a:	db260613          	addi	a2,a2,-590 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020118e:	0be00593          	li	a1,190
ffffffffc0201192:	00006517          	auipc	a0,0x6
ffffffffc0201196:	03650513          	addi	a0,a0,54 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020119a:	ad6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020119e:	00006697          	auipc	a3,0x6
ffffffffc02011a2:	12a68693          	addi	a3,a3,298 # ffffffffc02072c8 <etext+0xa0e>
ffffffffc02011a6:	00006617          	auipc	a2,0x6
ffffffffc02011aa:	d9260613          	addi	a2,a2,-622 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02011ae:	0c000593          	li	a1,192
ffffffffc02011b2:	00006517          	auipc	a0,0x6
ffffffffc02011b6:	01650513          	addi	a0,a0,22 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02011ba:	ab6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02011be:	00006697          	auipc	a3,0x6
ffffffffc02011c2:	19268693          	addi	a3,a3,402 # ffffffffc0207350 <etext+0xa96>
ffffffffc02011c6:	00006617          	auipc	a2,0x6
ffffffffc02011ca:	d7260613          	addi	a2,a2,-654 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02011ce:	0d900593          	li	a1,217
ffffffffc02011d2:	00006517          	auipc	a0,0x6
ffffffffc02011d6:	ff650513          	addi	a0,a0,-10 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02011da:	a96ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011de:	00006697          	auipc	a3,0x6
ffffffffc02011e2:	02268693          	addi	a3,a3,34 # ffffffffc0207200 <etext+0x946>
ffffffffc02011e6:	00006617          	auipc	a2,0x6
ffffffffc02011ea:	d5260613          	addi	a2,a2,-686 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02011ee:	0d200593          	li	a1,210
ffffffffc02011f2:	00006517          	auipc	a0,0x6
ffffffffc02011f6:	fd650513          	addi	a0,a0,-42 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02011fa:	a76ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_free == 3);
ffffffffc02011fe:	00006697          	auipc	a3,0x6
ffffffffc0201202:	14268693          	addi	a3,a3,322 # ffffffffc0207340 <etext+0xa86>
ffffffffc0201206:	00006617          	auipc	a2,0x6
ffffffffc020120a:	d3260613          	addi	a2,a2,-718 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020120e:	0d000593          	li	a1,208
ffffffffc0201212:	00006517          	auipc	a0,0x6
ffffffffc0201216:	fb650513          	addi	a0,a0,-74 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020121a:	a56ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020121e:	00006697          	auipc	a3,0x6
ffffffffc0201222:	10a68693          	addi	a3,a3,266 # ffffffffc0207328 <etext+0xa6e>
ffffffffc0201226:	00006617          	auipc	a2,0x6
ffffffffc020122a:	d1260613          	addi	a2,a2,-750 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020122e:	0cb00593          	li	a1,203
ffffffffc0201232:	00006517          	auipc	a0,0x6
ffffffffc0201236:	f9650513          	addi	a0,a0,-106 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020123a:	a36ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020123e:	00006697          	auipc	a3,0x6
ffffffffc0201242:	0ca68693          	addi	a3,a3,202 # ffffffffc0207308 <etext+0xa4e>
ffffffffc0201246:	00006617          	auipc	a2,0x6
ffffffffc020124a:	cf260613          	addi	a2,a2,-782 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020124e:	0c200593          	li	a1,194
ffffffffc0201252:	00006517          	auipc	a0,0x6
ffffffffc0201256:	f7650513          	addi	a0,a0,-138 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020125a:	a16ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(p0 != NULL);
ffffffffc020125e:	00006697          	auipc	a3,0x6
ffffffffc0201262:	13a68693          	addi	a3,a3,314 # ffffffffc0207398 <etext+0xade>
ffffffffc0201266:	00006617          	auipc	a2,0x6
ffffffffc020126a:	cd260613          	addi	a2,a2,-814 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020126e:	0f800593          	li	a1,248
ffffffffc0201272:	00006517          	auipc	a0,0x6
ffffffffc0201276:	f5650513          	addi	a0,a0,-170 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020127a:	9f6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_free == 0);
ffffffffc020127e:	00006697          	auipc	a3,0x6
ffffffffc0201282:	10a68693          	addi	a3,a3,266 # ffffffffc0207388 <etext+0xace>
ffffffffc0201286:	00006617          	auipc	a2,0x6
ffffffffc020128a:	cb260613          	addi	a2,a2,-846 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020128e:	0df00593          	li	a1,223
ffffffffc0201292:	00006517          	auipc	a0,0x6
ffffffffc0201296:	f3650513          	addi	a0,a0,-202 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020129a:	9d6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020129e:	00006697          	auipc	a3,0x6
ffffffffc02012a2:	08a68693          	addi	a3,a3,138 # ffffffffc0207328 <etext+0xa6e>
ffffffffc02012a6:	00006617          	auipc	a2,0x6
ffffffffc02012aa:	c9260613          	addi	a2,a2,-878 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02012ae:	0dd00593          	li	a1,221
ffffffffc02012b2:	00006517          	auipc	a0,0x6
ffffffffc02012b6:	f1650513          	addi	a0,a0,-234 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02012ba:	9b6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02012be:	00006697          	auipc	a3,0x6
ffffffffc02012c2:	0aa68693          	addi	a3,a3,170 # ffffffffc0207368 <etext+0xaae>
ffffffffc02012c6:	00006617          	auipc	a2,0x6
ffffffffc02012ca:	c7260613          	addi	a2,a2,-910 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02012ce:	0dc00593          	li	a1,220
ffffffffc02012d2:	00006517          	auipc	a0,0x6
ffffffffc02012d6:	ef650513          	addi	a0,a0,-266 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02012da:	996ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012de:	00006697          	auipc	a3,0x6
ffffffffc02012e2:	f2268693          	addi	a3,a3,-222 # ffffffffc0207200 <etext+0x946>
ffffffffc02012e6:	00006617          	auipc	a2,0x6
ffffffffc02012ea:	c5260613          	addi	a2,a2,-942 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02012ee:	0b900593          	li	a1,185
ffffffffc02012f2:	00006517          	auipc	a0,0x6
ffffffffc02012f6:	ed650513          	addi	a0,a0,-298 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02012fa:	976ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012fe:	00006697          	auipc	a3,0x6
ffffffffc0201302:	02a68693          	addi	a3,a3,42 # ffffffffc0207328 <etext+0xa6e>
ffffffffc0201306:	00006617          	auipc	a2,0x6
ffffffffc020130a:	c3260613          	addi	a2,a2,-974 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020130e:	0d600593          	li	a1,214
ffffffffc0201312:	00006517          	auipc	a0,0x6
ffffffffc0201316:	eb650513          	addi	a0,a0,-330 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020131a:	956ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020131e:	00006697          	auipc	a3,0x6
ffffffffc0201322:	f2268693          	addi	a3,a3,-222 # ffffffffc0207240 <etext+0x986>
ffffffffc0201326:	00006617          	auipc	a2,0x6
ffffffffc020132a:	c1260613          	addi	a2,a2,-1006 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020132e:	0d400593          	li	a1,212
ffffffffc0201332:	00006517          	auipc	a0,0x6
ffffffffc0201336:	e9650513          	addi	a0,a0,-362 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020133a:	936ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020133e:	00006697          	auipc	a3,0x6
ffffffffc0201342:	ee268693          	addi	a3,a3,-286 # ffffffffc0207220 <etext+0x966>
ffffffffc0201346:	00006617          	auipc	a2,0x6
ffffffffc020134a:	bf260613          	addi	a2,a2,-1038 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020134e:	0d300593          	li	a1,211
ffffffffc0201352:	00006517          	auipc	a0,0x6
ffffffffc0201356:	e7650513          	addi	a0,a0,-394 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020135a:	916ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020135e:	00006697          	auipc	a3,0x6
ffffffffc0201362:	ee268693          	addi	a3,a3,-286 # ffffffffc0207240 <etext+0x986>
ffffffffc0201366:	00006617          	auipc	a2,0x6
ffffffffc020136a:	bd260613          	addi	a2,a2,-1070 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020136e:	0bb00593          	li	a1,187
ffffffffc0201372:	00006517          	auipc	a0,0x6
ffffffffc0201376:	e5650513          	addi	a0,a0,-426 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020137a:	8f6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(count == 0);
ffffffffc020137e:	00006697          	auipc	a3,0x6
ffffffffc0201382:	16a68693          	addi	a3,a3,362 # ffffffffc02074e8 <etext+0xc2e>
ffffffffc0201386:	00006617          	auipc	a2,0x6
ffffffffc020138a:	bb260613          	addi	a2,a2,-1102 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020138e:	12500593          	li	a1,293
ffffffffc0201392:	00006517          	auipc	a0,0x6
ffffffffc0201396:	e3650513          	addi	a0,a0,-458 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020139a:	8d6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_free == 0);
ffffffffc020139e:	00006697          	auipc	a3,0x6
ffffffffc02013a2:	fea68693          	addi	a3,a3,-22 # ffffffffc0207388 <etext+0xace>
ffffffffc02013a6:	00006617          	auipc	a2,0x6
ffffffffc02013aa:	b9260613          	addi	a2,a2,-1134 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02013ae:	11a00593          	li	a1,282
ffffffffc02013b2:	00006517          	auipc	a0,0x6
ffffffffc02013b6:	e1650513          	addi	a0,a0,-490 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02013ba:	8b6ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013be:	00006697          	auipc	a3,0x6
ffffffffc02013c2:	f6a68693          	addi	a3,a3,-150 # ffffffffc0207328 <etext+0xa6e>
ffffffffc02013c6:	00006617          	auipc	a2,0x6
ffffffffc02013ca:	b7260613          	addi	a2,a2,-1166 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02013ce:	11800593          	li	a1,280
ffffffffc02013d2:	00006517          	auipc	a0,0x6
ffffffffc02013d6:	df650513          	addi	a0,a0,-522 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02013da:	896ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02013de:	00006697          	auipc	a3,0x6
ffffffffc02013e2:	f0a68693          	addi	a3,a3,-246 # ffffffffc02072e8 <etext+0xa2e>
ffffffffc02013e6:	00006617          	auipc	a2,0x6
ffffffffc02013ea:	b5260613          	addi	a2,a2,-1198 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02013ee:	0c100593          	li	a1,193
ffffffffc02013f2:	00006517          	auipc	a0,0x6
ffffffffc02013f6:	dd650513          	addi	a0,a0,-554 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02013fa:	876ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013fe:	00006697          	auipc	a3,0x6
ffffffffc0201402:	0aa68693          	addi	a3,a3,170 # ffffffffc02074a8 <etext+0xbee>
ffffffffc0201406:	00006617          	auipc	a2,0x6
ffffffffc020140a:	b3260613          	addi	a2,a2,-1230 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020140e:	11200593          	li	a1,274
ffffffffc0201412:	00006517          	auipc	a0,0x6
ffffffffc0201416:	db650513          	addi	a0,a0,-586 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020141a:	856ff0ef          	jal	ffffffffc0200470 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020141e:	00006697          	auipc	a3,0x6
ffffffffc0201422:	06a68693          	addi	a3,a3,106 # ffffffffc0207488 <etext+0xbce>
ffffffffc0201426:	00006617          	auipc	a2,0x6
ffffffffc020142a:	b1260613          	addi	a2,a2,-1262 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020142e:	11000593          	li	a1,272
ffffffffc0201432:	00006517          	auipc	a0,0x6
ffffffffc0201436:	d9650513          	addi	a0,a0,-618 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020143a:	836ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020143e:	00006697          	auipc	a3,0x6
ffffffffc0201442:	02268693          	addi	a3,a3,34 # ffffffffc0207460 <etext+0xba6>
ffffffffc0201446:	00006617          	auipc	a2,0x6
ffffffffc020144a:	af260613          	addi	a2,a2,-1294 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020144e:	10e00593          	li	a1,270
ffffffffc0201452:	00006517          	auipc	a0,0x6
ffffffffc0201456:	d7650513          	addi	a0,a0,-650 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020145a:	816ff0ef          	jal	ffffffffc0200470 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020145e:	00006697          	auipc	a3,0x6
ffffffffc0201462:	fda68693          	addi	a3,a3,-38 # ffffffffc0207438 <etext+0xb7e>
ffffffffc0201466:	00006617          	auipc	a2,0x6
ffffffffc020146a:	ad260613          	addi	a2,a2,-1326 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020146e:	10d00593          	li	a1,269
ffffffffc0201472:	00006517          	auipc	a0,0x6
ffffffffc0201476:	d5650513          	addi	a0,a0,-682 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020147a:	ff7fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020147e:	00006697          	auipc	a3,0x6
ffffffffc0201482:	faa68693          	addi	a3,a3,-86 # ffffffffc0207428 <etext+0xb6e>
ffffffffc0201486:	00006617          	auipc	a2,0x6
ffffffffc020148a:	ab260613          	addi	a2,a2,-1358 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020148e:	10800593          	li	a1,264
ffffffffc0201492:	00006517          	auipc	a0,0x6
ffffffffc0201496:	d3650513          	addi	a0,a0,-714 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020149a:	fd7fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020149e:	00006697          	auipc	a3,0x6
ffffffffc02014a2:	e8a68693          	addi	a3,a3,-374 # ffffffffc0207328 <etext+0xa6e>
ffffffffc02014a6:	00006617          	auipc	a2,0x6
ffffffffc02014aa:	a9260613          	addi	a2,a2,-1390 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02014ae:	10700593          	li	a1,263
ffffffffc02014b2:	00006517          	auipc	a0,0x6
ffffffffc02014b6:	d1650513          	addi	a0,a0,-746 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02014ba:	fb7fe0ef          	jal	ffffffffc0200470 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02014be:	00006697          	auipc	a3,0x6
ffffffffc02014c2:	f4a68693          	addi	a3,a3,-182 # ffffffffc0207408 <etext+0xb4e>
ffffffffc02014c6:	00006617          	auipc	a2,0x6
ffffffffc02014ca:	a7260613          	addi	a2,a2,-1422 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02014ce:	10600593          	li	a1,262
ffffffffc02014d2:	00006517          	auipc	a0,0x6
ffffffffc02014d6:	cf650513          	addi	a0,a0,-778 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02014da:	f97fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02014de:	00006697          	auipc	a3,0x6
ffffffffc02014e2:	efa68693          	addi	a3,a3,-262 # ffffffffc02073d8 <etext+0xb1e>
ffffffffc02014e6:	00006617          	auipc	a2,0x6
ffffffffc02014ea:	a5260613          	addi	a2,a2,-1454 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02014ee:	10500593          	li	a1,261
ffffffffc02014f2:	00006517          	auipc	a0,0x6
ffffffffc02014f6:	cd650513          	addi	a0,a0,-810 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02014fa:	f77fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014fe:	00006697          	auipc	a3,0x6
ffffffffc0201502:	ec268693          	addi	a3,a3,-318 # ffffffffc02073c0 <etext+0xb06>
ffffffffc0201506:	00006617          	auipc	a2,0x6
ffffffffc020150a:	a3260613          	addi	a2,a2,-1486 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020150e:	10400593          	li	a1,260
ffffffffc0201512:	00006517          	auipc	a0,0x6
ffffffffc0201516:	cb650513          	addi	a0,a0,-842 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020151a:	f57fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020151e:	00006697          	auipc	a3,0x6
ffffffffc0201522:	e0a68693          	addi	a3,a3,-502 # ffffffffc0207328 <etext+0xa6e>
ffffffffc0201526:	00006617          	auipc	a2,0x6
ffffffffc020152a:	a1260613          	addi	a2,a2,-1518 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020152e:	0fe00593          	li	a1,254
ffffffffc0201532:	00006517          	auipc	a0,0x6
ffffffffc0201536:	c9650513          	addi	a0,a0,-874 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020153a:	f37fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(!PageProperty(p0));
ffffffffc020153e:	00006697          	auipc	a3,0x6
ffffffffc0201542:	e6a68693          	addi	a3,a3,-406 # ffffffffc02073a8 <etext+0xaee>
ffffffffc0201546:	00006617          	auipc	a2,0x6
ffffffffc020154a:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020154e:	0f900593          	li	a1,249
ffffffffc0201552:	00006517          	auipc	a0,0x6
ffffffffc0201556:	c7650513          	addi	a0,a0,-906 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020155a:	f17fe0ef          	jal	ffffffffc0200470 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020155e:	00006697          	auipc	a3,0x6
ffffffffc0201562:	f6a68693          	addi	a3,a3,-150 # ffffffffc02074c8 <etext+0xc0e>
ffffffffc0201566:	00006617          	auipc	a2,0x6
ffffffffc020156a:	9d260613          	addi	a2,a2,-1582 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020156e:	11700593          	li	a1,279
ffffffffc0201572:	00006517          	auipc	a0,0x6
ffffffffc0201576:	c5650513          	addi	a0,a0,-938 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020157a:	ef7fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(total == 0);
ffffffffc020157e:	00006697          	auipc	a3,0x6
ffffffffc0201582:	f7a68693          	addi	a3,a3,-134 # ffffffffc02074f8 <etext+0xc3e>
ffffffffc0201586:	00006617          	auipc	a2,0x6
ffffffffc020158a:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020158e:	12600593          	li	a1,294
ffffffffc0201592:	00006517          	auipc	a0,0x6
ffffffffc0201596:	c3650513          	addi	a0,a0,-970 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020159a:	ed7fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(total == nr_free_pages());
ffffffffc020159e:	00006697          	auipc	a3,0x6
ffffffffc02015a2:	c4268693          	addi	a3,a3,-958 # ffffffffc02071e0 <etext+0x926>
ffffffffc02015a6:	00006617          	auipc	a2,0x6
ffffffffc02015aa:	99260613          	addi	a2,a2,-1646 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02015ae:	0f300593          	li	a1,243
ffffffffc02015b2:	00006517          	auipc	a0,0x6
ffffffffc02015b6:	c1650513          	addi	a0,a0,-1002 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02015ba:	eb7fe0ef          	jal	ffffffffc0200470 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015be:	00006697          	auipc	a3,0x6
ffffffffc02015c2:	c6268693          	addi	a3,a3,-926 # ffffffffc0207220 <etext+0x966>
ffffffffc02015c6:	00006617          	auipc	a2,0x6
ffffffffc02015ca:	97260613          	addi	a2,a2,-1678 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02015ce:	0ba00593          	li	a1,186
ffffffffc02015d2:	00006517          	auipc	a0,0x6
ffffffffc02015d6:	bf650513          	addi	a0,a0,-1034 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02015da:	e97fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02015de <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02015de:	1141                	addi	sp,sp,-16
ffffffffc02015e0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015e2:	14058763          	beqz	a1,ffffffffc0201730 <default_free_pages+0x152>
    for (; p != base + n; p ++) {
ffffffffc02015e6:	00659713          	slli	a4,a1,0x6
ffffffffc02015ea:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02015ee:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02015f0:	c30d                	beqz	a4,ffffffffc0201612 <default_free_pages+0x34>
ffffffffc02015f2:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015f4:	8b05                	andi	a4,a4,1
ffffffffc02015f6:	10071d63          	bnez	a4,ffffffffc0201710 <default_free_pages+0x132>
ffffffffc02015fa:	6798                	ld	a4,8(a5)
ffffffffc02015fc:	8b09                	andi	a4,a4,2
ffffffffc02015fe:	10071963          	bnez	a4,ffffffffc0201710 <default_free_pages+0x132>
        p->flags = 0;
ffffffffc0201602:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201606:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020160a:	04078793          	addi	a5,a5,64
ffffffffc020160e:	fed792e3          	bne	a5,a3,ffffffffc02015f2 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201612:	2581                	sext.w	a1,a1
ffffffffc0201614:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201616:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020161a:	4789                	li	a5,2
ffffffffc020161c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201620:	000a0717          	auipc	a4,0xa0
ffffffffc0201624:	d0872703          	lw	a4,-760(a4) # ffffffffc02a1328 <free_area+0x10>
ffffffffc0201628:	000a0697          	auipc	a3,0xa0
ffffffffc020162c:	cf068693          	addi	a3,a3,-784 # ffffffffc02a1318 <free_area>
    return list->next == list;
ffffffffc0201630:	669c                	ld	a5,8(a3)
ffffffffc0201632:	9f2d                	addw	a4,a4,a1
ffffffffc0201634:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201636:	0ad78163          	beq	a5,a3,ffffffffc02016d8 <default_free_pages+0xfa>
            struct Page* page = le2page(le, page_link);
ffffffffc020163a:	fe878713          	addi	a4,a5,-24
ffffffffc020163e:	4581                	li	a1,0
ffffffffc0201640:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201644:	00e56a63          	bltu	a0,a4,ffffffffc0201658 <default_free_pages+0x7a>
    return listelm->next;
ffffffffc0201648:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020164a:	04d70c63          	beq	a4,a3,ffffffffc02016a2 <default_free_pages+0xc4>
    struct Page *p = base;
ffffffffc020164e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201650:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201654:	fee57ae3          	bgeu	a0,a4,ffffffffc0201648 <default_free_pages+0x6a>
ffffffffc0201658:	c199                	beqz	a1,ffffffffc020165e <default_free_pages+0x80>
ffffffffc020165a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020165e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201660:	e390                	sd	a2,0(a5)
ffffffffc0201662:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201664:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201666:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201668:	00d70d63          	beq	a4,a3,ffffffffc0201682 <default_free_pages+0xa4>
        if (p + p->property == base) {
ffffffffc020166c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201670:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201674:	02059813          	slli	a6,a1,0x20
ffffffffc0201678:	01a85793          	srli	a5,a6,0x1a
ffffffffc020167c:	97b2                	add	a5,a5,a2
ffffffffc020167e:	02f50c63          	beq	a0,a5,ffffffffc02016b6 <default_free_pages+0xd8>
    return listelm->next;
ffffffffc0201682:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201684:	00d78c63          	beq	a5,a3,ffffffffc020169c <default_free_pages+0xbe>
        if (base + base->property == p) {
ffffffffc0201688:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020168a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020168e:	02061593          	slli	a1,a2,0x20
ffffffffc0201692:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201696:	972a                	add	a4,a4,a0
ffffffffc0201698:	04e68c63          	beq	a3,a4,ffffffffc02016f0 <default_free_pages+0x112>
}
ffffffffc020169c:	60a2                	ld	ra,8(sp)
ffffffffc020169e:	0141                	addi	sp,sp,16
ffffffffc02016a0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016a2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016a4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02016a6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016a8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016aa:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ac:	02d70f63          	beq	a4,a3,ffffffffc02016ea <default_free_pages+0x10c>
ffffffffc02016b0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02016b2:	87ba                	mv	a5,a4
ffffffffc02016b4:	bf71                	j	ffffffffc0201650 <default_free_pages+0x72>
            p->property += base->property;
ffffffffc02016b6:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016b8:	5875                	li	a6,-3
ffffffffc02016ba:	9fad                	addw	a5,a5,a1
ffffffffc02016bc:	fef72c23          	sw	a5,-8(a4)
ffffffffc02016c0:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016c4:	01853803          	ld	a6,24(a0)
ffffffffc02016c8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02016ca:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016cc:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02016d0:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02016d2:	0105b023          	sd	a6,0(a1)
ffffffffc02016d6:	b77d                	j	ffffffffc0201684 <default_free_pages+0xa6>
}
ffffffffc02016d8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02016da:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc02016de:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016e0:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc02016e2:	e398                	sd	a4,0(a5)
ffffffffc02016e4:	e798                	sd	a4,8(a5)
}
ffffffffc02016e6:	0141                	addi	sp,sp,16
ffffffffc02016e8:	8082                	ret
ffffffffc02016ea:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02016ec:	873e                	mv	a4,a5
ffffffffc02016ee:	bfad                	j	ffffffffc0201668 <default_free_pages+0x8a>
            base->property += p->property;
ffffffffc02016f0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016f4:	56f5                	li	a3,-3
ffffffffc02016f6:	9f31                	addw	a4,a4,a2
ffffffffc02016f8:	c918                	sw	a4,16(a0)
ffffffffc02016fa:	ff078713          	addi	a4,a5,-16
ffffffffc02016fe:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201702:	6398                	ld	a4,0(a5)
ffffffffc0201704:	679c                	ld	a5,8(a5)
}
ffffffffc0201706:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201708:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020170a:	e398                	sd	a4,0(a5)
ffffffffc020170c:	0141                	addi	sp,sp,16
ffffffffc020170e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201710:	00006697          	auipc	a3,0x6
ffffffffc0201714:	e0068693          	addi	a3,a3,-512 # ffffffffc0207510 <etext+0xc56>
ffffffffc0201718:	00006617          	auipc	a2,0x6
ffffffffc020171c:	82060613          	addi	a2,a2,-2016 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0201720:	08300593          	li	a1,131
ffffffffc0201724:	00006517          	auipc	a0,0x6
ffffffffc0201728:	aa450513          	addi	a0,a0,-1372 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020172c:	d45fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(n > 0);
ffffffffc0201730:	00006697          	auipc	a3,0x6
ffffffffc0201734:	dd868693          	addi	a3,a3,-552 # ffffffffc0207508 <etext+0xc4e>
ffffffffc0201738:	00006617          	auipc	a2,0x6
ffffffffc020173c:	80060613          	addi	a2,a2,-2048 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0201740:	08000593          	li	a1,128
ffffffffc0201744:	00006517          	auipc	a0,0x6
ffffffffc0201748:	a8450513          	addi	a0,a0,-1404 # ffffffffc02071c8 <etext+0x90e>
ffffffffc020174c:	d25fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201750 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201750:	c959                	beqz	a0,ffffffffc02017e6 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0201752:	000a0597          	auipc	a1,0xa0
ffffffffc0201756:	bd65a583          	lw	a1,-1066(a1) # ffffffffc02a1328 <free_area+0x10>
ffffffffc020175a:	872a                	mv	a4,a0
ffffffffc020175c:	000a0617          	auipc	a2,0xa0
ffffffffc0201760:	bbc60613          	addi	a2,a2,-1092 # ffffffffc02a1318 <free_area>
ffffffffc0201764:	02059793          	slli	a5,a1,0x20
ffffffffc0201768:	9381                	srli	a5,a5,0x20
ffffffffc020176a:	00a7eb63          	bltu	a5,a0,ffffffffc0201780 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc020176e:	87b2                	mv	a5,a2
ffffffffc0201770:	a029                	j	ffffffffc020177a <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc0201772:	ff87e683          	lwu	a3,-8(a5)
ffffffffc0201776:	00e6f763          	bgeu	a3,a4,ffffffffc0201784 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc020177a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020177c:	fec79be3          	bne	a5,a2,ffffffffc0201772 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201780:	4501                	li	a0,0
}
ffffffffc0201782:	8082                	ret
        if (page->property > n) {
ffffffffc0201784:	ff87a803          	lw	a6,-8(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201788:	0087b883          	ld	a7,8(a5)
    return listelm->prev;
ffffffffc020178c:	6394                	ld	a3,0(a5)
ffffffffc020178e:	02081313          	slli	t1,a6,0x20
ffffffffc0201792:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0201796:	0116b423          	sd	a7,8(a3)
    next->prev = prev;
ffffffffc020179a:	00d8b023          	sd	a3,0(a7)
        struct Page *p = le2page(le, page_link);
ffffffffc020179e:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc02017a2:	0007089b          	sext.w	a7,a4
        if (page->property > n) {
ffffffffc02017a6:	02677863          	bgeu	a4,t1,ffffffffc02017d6 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02017aa:	071a                	slli	a4,a4,0x6
ffffffffc02017ac:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02017ae:	4118083b          	subw	a6,a6,a7
ffffffffc02017b2:	01072823          	sw	a6,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017b6:	00870313          	addi	t1,a4,8
ffffffffc02017ba:	4809                	li	a6,2
ffffffffc02017bc:	4103302f          	amoor.d	zero,a6,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02017c0:	0086b803          	ld	a6,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc02017c4:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc02017c8:	00683023          	sd	t1,0(a6)
ffffffffc02017cc:	0066b423          	sd	t1,8(a3)
    elm->next = next;
ffffffffc02017d0:	03073023          	sd	a6,32(a4)
    elm->prev = prev;
ffffffffc02017d4:	ef14                	sd	a3,24(a4)
        nr_free -= n;
ffffffffc02017d6:	411585bb          	subw	a1,a1,a7
ffffffffc02017da:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017dc:	5775                	li	a4,-3
ffffffffc02017de:	17c1                	addi	a5,a5,-16
ffffffffc02017e0:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02017e4:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02017e6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02017e8:	00006697          	auipc	a3,0x6
ffffffffc02017ec:	d2068693          	addi	a3,a3,-736 # ffffffffc0207508 <etext+0xc4e>
ffffffffc02017f0:	00005617          	auipc	a2,0x5
ffffffffc02017f4:	74860613          	addi	a2,a2,1864 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02017f8:	06200593          	li	a1,98
ffffffffc02017fc:	00006517          	auipc	a0,0x6
ffffffffc0201800:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02071c8 <etext+0x90e>
default_alloc_pages(size_t n) {
ffffffffc0201804:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201806:	c6bfe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc020180a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020180a:	1141                	addi	sp,sp,-16
ffffffffc020180c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020180e:	c9e9                	beqz	a1,ffffffffc02018e0 <default_init_memmap+0xd6>
    for (; p != base + n; p ++) {
ffffffffc0201810:	00659713          	slli	a4,a1,0x6
ffffffffc0201814:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201818:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020181a:	cf11                	beqz	a4,ffffffffc0201836 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020181c:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020181e:	8b05                	andi	a4,a4,1
ffffffffc0201820:	c345                	beqz	a4,ffffffffc02018c0 <default_init_memmap+0xb6>
        p->flags = p->property = 0;
ffffffffc0201822:	0007a823          	sw	zero,16(a5)
ffffffffc0201826:	0007b423          	sd	zero,8(a5)
ffffffffc020182a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020182e:	04078793          	addi	a5,a5,64
ffffffffc0201832:	fed795e3          	bne	a5,a3,ffffffffc020181c <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201836:	2581                	sext.w	a1,a1
ffffffffc0201838:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020183a:	4789                	li	a5,2
ffffffffc020183c:	00850713          	addi	a4,a0,8
ffffffffc0201840:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201844:	000a0717          	auipc	a4,0xa0
ffffffffc0201848:	ae472703          	lw	a4,-1308(a4) # ffffffffc02a1328 <free_area+0x10>
ffffffffc020184c:	000a0697          	auipc	a3,0xa0
ffffffffc0201850:	acc68693          	addi	a3,a3,-1332 # ffffffffc02a1318 <free_area>
    return list->next == list;
ffffffffc0201854:	669c                	ld	a5,8(a3)
ffffffffc0201856:	9f2d                	addw	a4,a4,a1
ffffffffc0201858:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020185a:	04d78663          	beq	a5,a3,ffffffffc02018a6 <default_init_memmap+0x9c>
            struct Page* page = le2page(le, page_link);
ffffffffc020185e:	fe878713          	addi	a4,a5,-24
ffffffffc0201862:	4581                	li	a1,0
ffffffffc0201864:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201868:	00e56a63          	bltu	a0,a4,ffffffffc020187c <default_init_memmap+0x72>
    return listelm->next;
ffffffffc020186c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020186e:	02d70263          	beq	a4,a3,ffffffffc0201892 <default_init_memmap+0x88>
    struct Page *p = base;
ffffffffc0201872:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201874:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201878:	fee57ae3          	bgeu	a0,a4,ffffffffc020186c <default_init_memmap+0x62>
ffffffffc020187c:	c199                	beqz	a1,ffffffffc0201882 <default_init_memmap+0x78>
ffffffffc020187e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201882:	6398                	ld	a4,0(a5)
}
ffffffffc0201884:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201886:	e390                	sd	a2,0(a5)
ffffffffc0201888:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc020188a:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc020188c:	f11c                	sd	a5,32(a0)
ffffffffc020188e:	0141                	addi	sp,sp,16
ffffffffc0201890:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201892:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201894:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201896:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201898:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020189a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020189c:	00d70e63          	beq	a4,a3,ffffffffc02018b8 <default_init_memmap+0xae>
ffffffffc02018a0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02018a2:	87ba                	mv	a5,a4
ffffffffc02018a4:	bfc1                	j	ffffffffc0201874 <default_init_memmap+0x6a>
}
ffffffffc02018a6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02018a8:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc02018ac:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018ae:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc02018b0:	e398                	sd	a4,0(a5)
ffffffffc02018b2:	e798                	sd	a4,8(a5)
}
ffffffffc02018b4:	0141                	addi	sp,sp,16
ffffffffc02018b6:	8082                	ret
ffffffffc02018b8:	60a2                	ld	ra,8(sp)
ffffffffc02018ba:	e290                	sd	a2,0(a3)
ffffffffc02018bc:	0141                	addi	sp,sp,16
ffffffffc02018be:	8082                	ret
        assert(PageReserved(p));
ffffffffc02018c0:	00006697          	auipc	a3,0x6
ffffffffc02018c4:	c7868693          	addi	a3,a3,-904 # ffffffffc0207538 <etext+0xc7e>
ffffffffc02018c8:	00005617          	auipc	a2,0x5
ffffffffc02018cc:	67060613          	addi	a2,a2,1648 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02018d0:	04900593          	li	a1,73
ffffffffc02018d4:	00006517          	auipc	a0,0x6
ffffffffc02018d8:	8f450513          	addi	a0,a0,-1804 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02018dc:	b95fe0ef          	jal	ffffffffc0200470 <__panic>
    assert(n > 0);
ffffffffc02018e0:	00006697          	auipc	a3,0x6
ffffffffc02018e4:	c2868693          	addi	a3,a3,-984 # ffffffffc0207508 <etext+0xc4e>
ffffffffc02018e8:	00005617          	auipc	a2,0x5
ffffffffc02018ec:	65060613          	addi	a2,a2,1616 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02018f0:	04600593          	li	a1,70
ffffffffc02018f4:	00006517          	auipc	a0,0x6
ffffffffc02018f8:	8d450513          	addi	a0,a0,-1836 # ffffffffc02071c8 <etext+0x90e>
ffffffffc02018fc:	b75fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201900 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201900:	c955                	beqz	a0,ffffffffc02019b4 <slob_free+0xb4>
{
ffffffffc0201902:	1141                	addi	sp,sp,-16
ffffffffc0201904:	e022                	sd	s0,0(sp)
ffffffffc0201906:	e406                	sd	ra,8(sp)
ffffffffc0201908:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020190a:	e9c9                	bnez	a1,ffffffffc020199c <slob_free+0x9c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020190c:	100027f3          	csrr	a5,sstatus
ffffffffc0201910:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201912:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201914:	efc1                	bnez	a5,ffffffffc02019ac <slob_free+0xac>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201916:	00098617          	auipc	a2,0x98
ffffffffc020191a:	5f260613          	addi	a2,a2,1522 # ffffffffc0299f08 <slobfree>
ffffffffc020191e:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201920:	873e                	mv	a4,a5
ffffffffc0201922:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201924:	02877a63          	bgeu	a4,s0,ffffffffc0201958 <slob_free+0x58>
ffffffffc0201928:	00f46463          	bltu	s0,a5,ffffffffc0201930 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020192c:	fef76ae3          	bltu	a4,a5,ffffffffc0201920 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201930:	400c                	lw	a1,0(s0)
ffffffffc0201932:	00459693          	slli	a3,a1,0x4
ffffffffc0201936:	96a2                	add	a3,a3,s0
ffffffffc0201938:	02d78a63          	beq	a5,a3,ffffffffc020196c <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020193c:	430c                	lw	a1,0(a4)
ffffffffc020193e:	e41c                	sd	a5,8(s0)
ffffffffc0201940:	00459693          	slli	a3,a1,0x4
ffffffffc0201944:	96ba                	add	a3,a3,a4
ffffffffc0201946:	02d40e63          	beq	s0,a3,ffffffffc0201982 <slob_free+0x82>
ffffffffc020194a:	e700                	sd	s0,8(a4)
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;

	slobfree = cur;
ffffffffc020194c:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020194e:	e131                	bnez	a0,ffffffffc0201992 <slob_free+0x92>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201950:	60a2                	ld	ra,8(sp)
ffffffffc0201952:	6402                	ld	s0,0(sp)
ffffffffc0201954:	0141                	addi	sp,sp,16
ffffffffc0201956:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201958:	fcf764e3          	bltu	a4,a5,ffffffffc0201920 <slob_free+0x20>
ffffffffc020195c:	fcf472e3          	bgeu	s0,a5,ffffffffc0201920 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201960:	400c                	lw	a1,0(s0)
ffffffffc0201962:	00459693          	slli	a3,a1,0x4
ffffffffc0201966:	96a2                	add	a3,a3,s0
ffffffffc0201968:	fcd79ae3          	bne	a5,a3,ffffffffc020193c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020196c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020196e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201970:	9ead                	addw	a3,a3,a1
ffffffffc0201972:	c014                	sw	a3,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201974:	430c                	lw	a1,0(a4)
ffffffffc0201976:	e41c                	sd	a5,8(s0)
ffffffffc0201978:	00459693          	slli	a3,a1,0x4
ffffffffc020197c:	96ba                	add	a3,a3,a4
ffffffffc020197e:	fcd416e3          	bne	s0,a3,ffffffffc020194a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201982:	4014                	lw	a3,0(s0)
		cur->next = b->next;
ffffffffc0201984:	843e                	mv	s0,a5
ffffffffc0201986:	e700                	sd	s0,8(a4)
		cur->units += b->units;
ffffffffc0201988:	00b687bb          	addw	a5,a3,a1
ffffffffc020198c:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc020198e:	e218                	sd	a4,0(a2)
ffffffffc0201990:	d161                	beqz	a0,ffffffffc0201950 <slob_free+0x50>
}
ffffffffc0201992:	6402                	ld	s0,0(sp)
ffffffffc0201994:	60a2                	ld	ra,8(sp)
ffffffffc0201996:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201998:	ca3fe06f          	j	ffffffffc020063a <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020199c:	25bd                	addiw	a1,a1,15
ffffffffc020199e:	8191                	srli	a1,a1,0x4
ffffffffc02019a0:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a2:	100027f3          	csrr	a5,sstatus
ffffffffc02019a6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019a8:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019aa:	d7b5                	beqz	a5,ffffffffc0201916 <slob_free+0x16>
        intr_disable();
ffffffffc02019ac:	c95fe0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02019b0:	4505                	li	a0,1
ffffffffc02019b2:	b795                	j	ffffffffc0201916 <slob_free+0x16>
ffffffffc02019b4:	8082                	ret

ffffffffc02019b6 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02019b6:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019b8:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02019ba:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019be:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02019c0:	34a000ef          	jal	ffffffffc0201d0a <alloc_pages>
  if(!page)
ffffffffc02019c4:	c91d                	beqz	a0,ffffffffc02019fa <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02019c6:	000a4697          	auipc	a3,0xa4
ffffffffc02019ca:	a626b683          	ld	a3,-1438(a3) # ffffffffc02a5428 <pages>
ffffffffc02019ce:	00007797          	auipc	a5,0x7
ffffffffc02019d2:	5da7b783          	ld	a5,1498(a5) # ffffffffc0208fa8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02019d6:	000a4717          	auipc	a4,0xa4
ffffffffc02019da:	a4a73703          	ld	a4,-1462(a4) # ffffffffc02a5420 <npage>
    return page - pages + nbase;
ffffffffc02019de:	8d15                	sub	a0,a0,a3
ffffffffc02019e0:	8519                	srai	a0,a0,0x6
ffffffffc02019e2:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc02019e4:	00c51793          	slli	a5,a0,0xc
ffffffffc02019e8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02019ea:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ec:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a00 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019f0:	000a4797          	auipc	a5,0xa4
ffffffffc02019f4:	a287b783          	ld	a5,-1496(a5) # ffffffffc02a5418 <va_pa_offset>
ffffffffc02019f8:	953e                	add	a0,a0,a5
}
ffffffffc02019fa:	60a2                	ld	ra,8(sp)
ffffffffc02019fc:	0141                	addi	sp,sp,16
ffffffffc02019fe:	8082                	ret
ffffffffc0201a00:	86aa                	mv	a3,a0
ffffffffc0201a02:	00006617          	auipc	a2,0x6
ffffffffc0201a06:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0207560 <etext+0xca6>
ffffffffc0201a0a:	06900593          	li	a1,105
ffffffffc0201a0e:	00006517          	auipc	a0,0x6
ffffffffc0201a12:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0207588 <etext+0xcce>
ffffffffc0201a16:	a5bfe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201a1a <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201a1a:	1101                	addi	sp,sp,-32
ffffffffc0201a1c:	ec06                	sd	ra,24(sp)
ffffffffc0201a1e:	e822                	sd	s0,16(sp)
ffffffffc0201a20:	e426                	sd	s1,8(sp)
ffffffffc0201a22:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a24:	01050713          	addi	a4,a0,16
ffffffffc0201a28:	6785                	lui	a5,0x1
ffffffffc0201a2a:	0cf77363          	bgeu	a4,a5,ffffffffc0201af0 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201a2e:	00f50493          	addi	s1,a0,15
ffffffffc0201a32:	8091                	srli	s1,s1,0x4
ffffffffc0201a34:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a36:	10002673          	csrr	a2,sstatus
ffffffffc0201a3a:	8a09                	andi	a2,a2,2
ffffffffc0201a3c:	e25d                	bnez	a2,ffffffffc0201ae2 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a3e:	00098917          	auipc	s2,0x98
ffffffffc0201a42:	4ca90913          	addi	s2,s2,1226 # ffffffffc0299f08 <slobfree>
ffffffffc0201a46:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a4a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a4c:	4398                	lw	a4,0(a5)
ffffffffc0201a4e:	08975e63          	bge	a4,s1,ffffffffc0201aea <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201a52:	00f68b63          	beq	a3,a5,ffffffffc0201a68 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a56:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a58:	4018                	lw	a4,0(s0)
ffffffffc0201a5a:	02975a63          	bge	a4,s1,ffffffffc0201a8e <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a5e:	00093683          	ld	a3,0(s2)
ffffffffc0201a62:	87a2                	mv	a5,s0
ffffffffc0201a64:	fef699e3          	bne	a3,a5,ffffffffc0201a56 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a68:	ee31                	bnez	a2,ffffffffc0201ac4 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a6a:	4501                	li	a0,0
ffffffffc0201a6c:	f4bff0ef          	jal	ffffffffc02019b6 <__slob_get_free_pages.constprop.0>
ffffffffc0201a70:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a72:	cd05                	beqz	a0,ffffffffc0201aaa <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a74:	6585                	lui	a1,0x1
ffffffffc0201a76:	e8bff0ef          	jal	ffffffffc0201900 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a7a:	10002673          	csrr	a2,sstatus
ffffffffc0201a7e:	8a09                	andi	a2,a2,2
ffffffffc0201a80:	ee05                	bnez	a2,ffffffffc0201ab8 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a82:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a86:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a88:	4018                	lw	a4,0(s0)
ffffffffc0201a8a:	fc974ae3          	blt	a4,s1,ffffffffc0201a5e <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a8e:	04e48763          	beq	s1,a4,ffffffffc0201adc <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a92:	00449693          	slli	a3,s1,0x4
ffffffffc0201a96:	96a2                	add	a3,a3,s0
ffffffffc0201a98:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a9a:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a9c:	9f05                	subw	a4,a4,s1
ffffffffc0201a9e:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201aa0:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201aa2:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201aa4:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201aa8:	e20d                	bnez	a2,ffffffffc0201aca <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201aaa:	60e2                	ld	ra,24(sp)
ffffffffc0201aac:	8522                	mv	a0,s0
ffffffffc0201aae:	6442                	ld	s0,16(sp)
ffffffffc0201ab0:	64a2                	ld	s1,8(sp)
ffffffffc0201ab2:	6902                	ld	s2,0(sp)
ffffffffc0201ab4:	6105                	addi	sp,sp,32
ffffffffc0201ab6:	8082                	ret
        intr_disable();
ffffffffc0201ab8:	b89fe0ef          	jal	ffffffffc0200640 <intr_disable>
			cur = slobfree;
ffffffffc0201abc:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201ac0:	4605                	li	a2,1
ffffffffc0201ac2:	b7d1                	j	ffffffffc0201a86 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201ac4:	b77fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201ac8:	b74d                	j	ffffffffc0201a6a <slob_alloc.constprop.0+0x50>
ffffffffc0201aca:	b71fe0ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc0201ace:	60e2                	ld	ra,24(sp)
ffffffffc0201ad0:	8522                	mv	a0,s0
ffffffffc0201ad2:	6442                	ld	s0,16(sp)
ffffffffc0201ad4:	64a2                	ld	s1,8(sp)
ffffffffc0201ad6:	6902                	ld	s2,0(sp)
ffffffffc0201ad8:	6105                	addi	sp,sp,32
ffffffffc0201ada:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201adc:	6418                	ld	a4,8(s0)
ffffffffc0201ade:	e798                	sd	a4,8(a5)
ffffffffc0201ae0:	b7d1                	j	ffffffffc0201aa4 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201ae2:	b5ffe0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0201ae6:	4605                	li	a2,1
ffffffffc0201ae8:	bf99                	j	ffffffffc0201a3e <slob_alloc.constprop.0+0x24>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201aea:	843e                	mv	s0,a5
	prev = slobfree;
ffffffffc0201aec:	87b6                	mv	a5,a3
ffffffffc0201aee:	b745                	j	ffffffffc0201a8e <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201af0:	00006697          	auipc	a3,0x6
ffffffffc0201af4:	aa868693          	addi	a3,a3,-1368 # ffffffffc0207598 <etext+0xcde>
ffffffffc0201af8:	00005617          	auipc	a2,0x5
ffffffffc0201afc:	44060613          	addi	a2,a2,1088 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0201b00:	06400593          	li	a1,100
ffffffffc0201b04:	00006517          	auipc	a0,0x6
ffffffffc0201b08:	ab450513          	addi	a0,a0,-1356 # ffffffffc02075b8 <etext+0xcfe>
ffffffffc0201b0c:	965fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201b10 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201b10:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201b12:	00006517          	auipc	a0,0x6
ffffffffc0201b16:	abe50513          	addi	a0,a0,-1346 # ffffffffc02075d0 <etext+0xd16>
kmalloc_init(void) {
ffffffffc0201b1a:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201b1c:	e74fe0ef          	jal	ffffffffc0200190 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201b20:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b22:	00006517          	auipc	a0,0x6
ffffffffc0201b26:	ac650513          	addi	a0,a0,-1338 # ffffffffc02075e8 <etext+0xd2e>
}
ffffffffc0201b2a:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b2c:	e64fe06f          	j	ffffffffc0200190 <cprintf>

ffffffffc0201b30 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201b30:	4501                	li	a0,0
ffffffffc0201b32:	8082                	ret

ffffffffc0201b34 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b34:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b36:	6785                	lui	a5,0x1
{
ffffffffc0201b38:	e822                	sd	s0,16(sp)
ffffffffc0201b3a:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b3c:	17bd                	addi	a5,a5,-17 # fef <_binary_obj___user_softint_out_size-0x7081>
{
ffffffffc0201b3e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b40:	04a7ff63          	bgeu	a5,a0,ffffffffc0201b9e <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b44:	4561                	li	a0,24
ffffffffc0201b46:	e04a                	sd	s2,0(sp)
ffffffffc0201b48:	ed3ff0ef          	jal	ffffffffc0201a1a <slob_alloc.constprop.0>
ffffffffc0201b4c:	892a                	mv	s2,a0
	if (!bb)
ffffffffc0201b4e:	c155                	beqz	a0,ffffffffc0201bf2 <kmalloc+0xbe>
ffffffffc0201b50:	e426                	sd	s1,8(sp)
	bb->order = find_order(size);
ffffffffc0201b52:	0004079b          	sext.w	a5,s0
ffffffffc0201b56:	6485                	lui	s1,0x1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b58:	08f4db63          	bge	s1,a5,ffffffffc0201bee <kmalloc+0xba>
ffffffffc0201b5c:	8726                	mv	a4,s1
	int order = 0;
ffffffffc0201b5e:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b60:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201b64:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b66:	fef74de3          	blt	a4,a5,ffffffffc0201b60 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b6a:	00a92023          	sw	a0,0(s2)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b6e:	e49ff0ef          	jal	ffffffffc02019b6 <__slob_get_free_pages.constprop.0>
ffffffffc0201b72:	00a93423          	sd	a0,8(s2)
	if (bb->pages) {
ffffffffc0201b76:	c525                	beqz	a0,ffffffffc0201bde <kmalloc+0xaa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b78:	100027f3          	csrr	a5,sstatus
ffffffffc0201b7c:	8b89                	andi	a5,a5,2
ffffffffc0201b7e:	eb9d                	bnez	a5,ffffffffc0201bb4 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b80:	000a4797          	auipc	a5,0xa4
ffffffffc0201b84:	87878793          	addi	a5,a5,-1928 # ffffffffc02a53f8 <bigblocks>
ffffffffc0201b88:	6398                	ld	a4,0(a5)
ffffffffc0201b8a:	64a2                	ld	s1,8(sp)
		bigblocks = bb;
ffffffffc0201b8c:	0127b023          	sd	s2,0(a5)
		bb->next = bigblocks;
ffffffffc0201b90:	00e93823          	sd	a4,16(s2)
    if (flag) {
ffffffffc0201b94:	6902                	ld	s2,0(sp)
  return __kmalloc(size, 0);
}
ffffffffc0201b96:	60e2                	ld	ra,24(sp)
ffffffffc0201b98:	6442                	ld	s0,16(sp)
ffffffffc0201b9a:	6105                	addi	sp,sp,32
ffffffffc0201b9c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b9e:	0541                	addi	a0,a0,16
ffffffffc0201ba0:	e7bff0ef          	jal	ffffffffc0201a1a <slob_alloc.constprop.0>
ffffffffc0201ba4:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201ba6:	0541                	addi	a0,a0,16
ffffffffc0201ba8:	f7fd                	bnez	a5,ffffffffc0201b96 <kmalloc+0x62>
		return 0;
ffffffffc0201baa:	4501                	li	a0,0
}
ffffffffc0201bac:	60e2                	ld	ra,24(sp)
ffffffffc0201bae:	6442                	ld	s0,16(sp)
ffffffffc0201bb0:	6105                	addi	sp,sp,32
ffffffffc0201bb2:	8082                	ret
        intr_disable();
ffffffffc0201bb4:	a8dfe0ef          	jal	ffffffffc0200640 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201bb8:	000a4797          	auipc	a5,0xa4
ffffffffc0201bbc:	84078793          	addi	a5,a5,-1984 # ffffffffc02a53f8 <bigblocks>
ffffffffc0201bc0:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201bc2:	0127b023          	sd	s2,0(a5)
		bb->next = bigblocks;
ffffffffc0201bc6:	00e93823          	sd	a4,16(s2)
        intr_enable();
ffffffffc0201bca:	a71fe0ef          	jal	ffffffffc020063a <intr_enable>
}
ffffffffc0201bce:	60e2                	ld	ra,24(sp)
ffffffffc0201bd0:	6442                	ld	s0,16(sp)
		return bb->pages;
ffffffffc0201bd2:	00893503          	ld	a0,8(s2)
ffffffffc0201bd6:	64a2                	ld	s1,8(sp)
ffffffffc0201bd8:	6902                	ld	s2,0(sp)
}
ffffffffc0201bda:	6105                	addi	sp,sp,32
ffffffffc0201bdc:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bde:	854a                	mv	a0,s2
ffffffffc0201be0:	45e1                	li	a1,24
ffffffffc0201be2:	d1fff0ef          	jal	ffffffffc0201900 <slob_free>
		return 0;
ffffffffc0201be6:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201be8:	64a2                	ld	s1,8(sp)
ffffffffc0201bea:	6902                	ld	s2,0(sp)
ffffffffc0201bec:	b7c1                	j	ffffffffc0201bac <kmalloc+0x78>
	int order = 0;
ffffffffc0201bee:	4501                	li	a0,0
ffffffffc0201bf0:	bfad                	j	ffffffffc0201b6a <kmalloc+0x36>
ffffffffc0201bf2:	6902                	ld	s2,0(sp)
		return 0;
ffffffffc0201bf4:	4501                	li	a0,0
ffffffffc0201bf6:	bf5d                	j	ffffffffc0201bac <kmalloc+0x78>

ffffffffc0201bf8 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bf8:	c169                	beqz	a0,ffffffffc0201cba <kfree+0xc2>
{
ffffffffc0201bfa:	1101                	addi	sp,sp,-32
ffffffffc0201bfc:	e822                	sd	s0,16(sp)
ffffffffc0201bfe:	ec06                	sd	ra,24(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201c00:	03451793          	slli	a5,a0,0x34
ffffffffc0201c04:	842a                	mv	s0,a0
ffffffffc0201c06:	e7c9                	bnez	a5,ffffffffc0201c90 <kfree+0x98>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c08:	100027f3          	csrr	a5,sstatus
ffffffffc0201c0c:	8b89                	andi	a5,a5,2
ffffffffc0201c0e:	ebc1                	bnez	a5,ffffffffc0201c9e <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c10:	000a3797          	auipc	a5,0xa3
ffffffffc0201c14:	7e87b783          	ld	a5,2024(a5) # ffffffffc02a53f8 <bigblocks>
    return 0;
ffffffffc0201c18:	4601                	li	a2,0
ffffffffc0201c1a:	cbbd                	beqz	a5,ffffffffc0201c90 <kfree+0x98>
ffffffffc0201c1c:	e426                	sd	s1,8(sp)
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201c1e:	000a3697          	auipc	a3,0xa3
ffffffffc0201c22:	7da68693          	addi	a3,a3,2010 # ffffffffc02a53f8 <bigblocks>
ffffffffc0201c26:	a021                	j	ffffffffc0201c2e <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c28:	01048693          	addi	a3,s1,16 # 1010 <_binary_obj___user_softint_out_size-0x7060>
ffffffffc0201c2c:	c3a5                	beqz	a5,ffffffffc0201c8c <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201c2e:	6798                	ld	a4,8(a5)
ffffffffc0201c30:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201c32:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201c34:	fe871ae3          	bne	a4,s0,ffffffffc0201c28 <kfree+0x30>
				*last = bb->next;
ffffffffc0201c38:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201c3a:	ee2d                	bnez	a2,ffffffffc0201cb4 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201c3c:	c0200737          	lui	a4,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201c40:	409c                	lw	a5,0(s1)
ffffffffc0201c42:	08e46963          	bltu	s0,a4,ffffffffc0201cd4 <kfree+0xdc>
ffffffffc0201c46:	000a3697          	auipc	a3,0xa3
ffffffffc0201c4a:	7d26b683          	ld	a3,2002(a3) # ffffffffc02a5418 <va_pa_offset>
    if (PPN(pa) >= npage) {
ffffffffc0201c4e:	000a3717          	auipc	a4,0xa3
ffffffffc0201c52:	7d273703          	ld	a4,2002(a4) # ffffffffc02a5420 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201c56:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c58:	8031                	srli	s0,s0,0xc
ffffffffc0201c5a:	06e47163          	bgeu	s0,a4,ffffffffc0201cbc <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c5e:	00007717          	auipc	a4,0x7
ffffffffc0201c62:	34a73703          	ld	a4,842(a4) # ffffffffc0208fa8 <nbase>
ffffffffc0201c66:	000a3517          	auipc	a0,0xa3
ffffffffc0201c6a:	7c253503          	ld	a0,1986(a0) # ffffffffc02a5428 <pages>
  free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201c6e:	4585                	li	a1,1
ffffffffc0201c70:	8c19                	sub	s0,s0,a4
ffffffffc0201c72:	041a                	slli	s0,s0,0x6
ffffffffc0201c74:	9522                	add	a0,a0,s0
ffffffffc0201c76:	00f595bb          	sllw	a1,a1,a5
ffffffffc0201c7a:	118000ef          	jal	ffffffffc0201d92 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c7e:	6442                	ld	s0,16(sp)
ffffffffc0201c80:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c82:	8526                	mv	a0,s1
ffffffffc0201c84:	64a2                	ld	s1,8(sp)
ffffffffc0201c86:	45e1                	li	a1,24
}
ffffffffc0201c88:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c8a:	b99d                	j	ffffffffc0201900 <slob_free>
ffffffffc0201c8c:	64a2                	ld	s1,8(sp)
ffffffffc0201c8e:	e205                	bnez	a2,ffffffffc0201cae <kfree+0xb6>
ffffffffc0201c90:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c94:	6442                	ld	s0,16(sp)
ffffffffc0201c96:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c98:	4581                	li	a1,0
}
ffffffffc0201c9a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c9c:	b195                	j	ffffffffc0201900 <slob_free>
        intr_disable();
ffffffffc0201c9e:	9a3fe0ef          	jal	ffffffffc0200640 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ca2:	000a3797          	auipc	a5,0xa3
ffffffffc0201ca6:	7567b783          	ld	a5,1878(a5) # ffffffffc02a53f8 <bigblocks>
        return 1;
ffffffffc0201caa:	4605                	li	a2,1
ffffffffc0201cac:	fba5                	bnez	a5,ffffffffc0201c1c <kfree+0x24>
        intr_enable();
ffffffffc0201cae:	98dfe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201cb2:	bff9                	j	ffffffffc0201c90 <kfree+0x98>
ffffffffc0201cb4:	987fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0201cb8:	b751                	j	ffffffffc0201c3c <kfree+0x44>
ffffffffc0201cba:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201cbc:	00006617          	auipc	a2,0x6
ffffffffc0201cc0:	97460613          	addi	a2,a2,-1676 # ffffffffc0207630 <etext+0xd76>
ffffffffc0201cc4:	06200593          	li	a1,98
ffffffffc0201cc8:	00006517          	auipc	a0,0x6
ffffffffc0201ccc:	8c050513          	addi	a0,a0,-1856 # ffffffffc0207588 <etext+0xcce>
ffffffffc0201cd0:	fa0fe0ef          	jal	ffffffffc0200470 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201cd4:	86a2                	mv	a3,s0
ffffffffc0201cd6:	00006617          	auipc	a2,0x6
ffffffffc0201cda:	93260613          	addi	a2,a2,-1742 # ffffffffc0207608 <etext+0xd4e>
ffffffffc0201cde:	06e00593          	li	a1,110
ffffffffc0201ce2:	00006517          	auipc	a0,0x6
ffffffffc0201ce6:	8a650513          	addi	a0,a0,-1882 # ffffffffc0207588 <etext+0xcce>
ffffffffc0201cea:	f86fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201cee <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201cee:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201cf0:	00006617          	auipc	a2,0x6
ffffffffc0201cf4:	94060613          	addi	a2,a2,-1728 # ffffffffc0207630 <etext+0xd76>
ffffffffc0201cf8:	06200593          	li	a1,98
ffffffffc0201cfc:	00006517          	auipc	a0,0x6
ffffffffc0201d00:	88c50513          	addi	a0,a0,-1908 # ffffffffc0207588 <etext+0xcce>
pa2page(uintptr_t pa) {
ffffffffc0201d04:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201d06:	f6afe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201d0a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201d0a:	7139                	addi	sp,sp,-64
ffffffffc0201d0c:	f426                	sd	s1,40(sp)
ffffffffc0201d0e:	f04a                	sd	s2,32(sp)
ffffffffc0201d10:	ec4e                	sd	s3,24(sp)
ffffffffc0201d12:	e852                	sd	s4,16(sp)
ffffffffc0201d14:	e456                	sd	s5,8(sp)
ffffffffc0201d16:	fc06                	sd	ra,56(sp)
ffffffffc0201d18:	f822                	sd	s0,48(sp)
ffffffffc0201d1a:	84aa                	mv	s1,a0

        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d1c:	0005099b          	sext.w	s3,a0
ffffffffc0201d20:	000a3917          	auipc	s2,0xa3
ffffffffc0201d24:	6e090913          	addi	s2,s2,1760 # ffffffffc02a5400 <pmm_manager>
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d28:	4a05                	li	s4,1
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d2a:	000a3a97          	auipc	s5,0xa3
ffffffffc0201d2e:	726a8a93          	addi	s5,s5,1830 # ffffffffc02a5450 <check_mm_struct>
ffffffffc0201d32:	a025                	j	ffffffffc0201d5a <alloc_pages+0x50>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d34:	00093783          	ld	a5,0(s2)
ffffffffc0201d38:	6f9c                	ld	a5,24(a5)
ffffffffc0201d3a:	9782                	jalr	a5
ffffffffc0201d3c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d3e:	4601                	li	a2,0
ffffffffc0201d40:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d42:	ec15                	bnez	s0,ffffffffc0201d7e <alloc_pages+0x74>
ffffffffc0201d44:	029a6d63          	bltu	s4,s1,ffffffffc0201d7e <alloc_pages+0x74>
ffffffffc0201d48:	000a3797          	auipc	a5,0xa3
ffffffffc0201d4c:	6e87a783          	lw	a5,1768(a5) # ffffffffc02a5430 <swap_init_ok>
ffffffffc0201d50:	c79d                	beqz	a5,ffffffffc0201d7e <alloc_pages+0x74>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d52:	000ab503          	ld	a0,0(s5)
ffffffffc0201d56:	6b5010ef          	jal	ffffffffc0203c0a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d5a:	100027f3          	csrr	a5,sstatus
ffffffffc0201d5e:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d60:	8526                	mv	a0,s1
ffffffffc0201d62:	dbe9                	beqz	a5,ffffffffc0201d34 <alloc_pages+0x2a>
        intr_disable();
ffffffffc0201d64:	8ddfe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0201d68:	00093783          	ld	a5,0(s2)
ffffffffc0201d6c:	8526                	mv	a0,s1
ffffffffc0201d6e:	6f9c                	ld	a5,24(a5)
ffffffffc0201d70:	9782                	jalr	a5
ffffffffc0201d72:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d74:	8c7fe0ef          	jal	ffffffffc020063a <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d78:	4601                	li	a2,0
ffffffffc0201d7a:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d7c:	d461                	beqz	s0,ffffffffc0201d44 <alloc_pages+0x3a>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d7e:	70e2                	ld	ra,56(sp)
ffffffffc0201d80:	8522                	mv	a0,s0
ffffffffc0201d82:	7442                	ld	s0,48(sp)
ffffffffc0201d84:	74a2                	ld	s1,40(sp)
ffffffffc0201d86:	7902                	ld	s2,32(sp)
ffffffffc0201d88:	69e2                	ld	s3,24(sp)
ffffffffc0201d8a:	6a42                	ld	s4,16(sp)
ffffffffc0201d8c:	6aa2                	ld	s5,8(sp)
ffffffffc0201d8e:	6121                	addi	sp,sp,64
ffffffffc0201d90:	8082                	ret

ffffffffc0201d92 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d92:	100027f3          	csrr	a5,sstatus
ffffffffc0201d96:	8b89                	andi	a5,a5,2
ffffffffc0201d98:	e799                	bnez	a5,ffffffffc0201da6 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d9a:	000a3797          	auipc	a5,0xa3
ffffffffc0201d9e:	6667b783          	ld	a5,1638(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0201da2:	739c                	ld	a5,32(a5)
ffffffffc0201da4:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201da6:	1101                	addi	sp,sp,-32
ffffffffc0201da8:	ec06                	sd	ra,24(sp)
ffffffffc0201daa:	e822                	sd	s0,16(sp)
ffffffffc0201dac:	e426                	sd	s1,8(sp)
ffffffffc0201dae:	842a                	mv	s0,a0
ffffffffc0201db0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201db2:	88ffe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201db6:	000a3797          	auipc	a5,0xa3
ffffffffc0201dba:	64a7b783          	ld	a5,1610(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0201dbe:	85a6                	mv	a1,s1
ffffffffc0201dc0:	8522                	mv	a0,s0
ffffffffc0201dc2:	739c                	ld	a5,32(a5)
ffffffffc0201dc4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201dc6:	6442                	ld	s0,16(sp)
ffffffffc0201dc8:	60e2                	ld	ra,24(sp)
ffffffffc0201dca:	64a2                	ld	s1,8(sp)
ffffffffc0201dcc:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201dce:	86dfe06f          	j	ffffffffc020063a <intr_enable>

ffffffffc0201dd2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201dd2:	100027f3          	csrr	a5,sstatus
ffffffffc0201dd6:	8b89                	andi	a5,a5,2
ffffffffc0201dd8:	e799                	bnez	a5,ffffffffc0201de6 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dda:	000a3797          	auipc	a5,0xa3
ffffffffc0201dde:	6267b783          	ld	a5,1574(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0201de2:	779c                	ld	a5,40(a5)
ffffffffc0201de4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201de6:	1141                	addi	sp,sp,-16
ffffffffc0201de8:	e406                	sd	ra,8(sp)
ffffffffc0201dea:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201dec:	855fe0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201df0:	000a3797          	auipc	a5,0xa3
ffffffffc0201df4:	6107b783          	ld	a5,1552(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0201df8:	779c                	ld	a5,40(a5)
ffffffffc0201dfa:	9782                	jalr	a5
ffffffffc0201dfc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dfe:	83dfe0ef          	jal	ffffffffc020063a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201e02:	60a2                	ld	ra,8(sp)
ffffffffc0201e04:	8522                	mv	a0,s0
ffffffffc0201e06:	6402                	ld	s0,0(sp)
ffffffffc0201e08:	0141                	addi	sp,sp,16
ffffffffc0201e0a:	8082                	ret

ffffffffc0201e0c <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e0c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201e10:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e14:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e16:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e18:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e1a:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e1e:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e20:	f04a                	sd	s2,32(sp)
ffffffffc0201e22:	ec4e                	sd	s3,24(sp)
ffffffffc0201e24:	e852                	sd	s4,16(sp)
ffffffffc0201e26:	fc06                	sd	ra,56(sp)
ffffffffc0201e28:	f822                	sd	s0,48(sp)
ffffffffc0201e2a:	e456                	sd	s5,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e2c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e30:	892e                	mv	s2,a1
ffffffffc0201e32:	89b2                	mv	s3,a2
ffffffffc0201e34:	000a3a17          	auipc	s4,0xa3
ffffffffc0201e38:	5eca0a13          	addi	s4,s4,1516 # ffffffffc02a5420 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e3c:	eba5                	bnez	a5,ffffffffc0201eac <get_pte+0xa0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e3e:	12060e63          	beqz	a2,ffffffffc0201f7a <get_pte+0x16e>
ffffffffc0201e42:	4505                	li	a0,1
ffffffffc0201e44:	ec7ff0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0201e48:	842a                	mv	s0,a0
ffffffffc0201e4a:	12050863          	beqz	a0,ffffffffc0201f7a <get_pte+0x16e>
    page->ref = val;
ffffffffc0201e4e:	e05a                	sd	s6,0(sp)
    return page - pages + nbase;
ffffffffc0201e50:	000a3b17          	auipc	s6,0xa3
ffffffffc0201e54:	5d8b0b13          	addi	s6,s6,1496 # ffffffffc02a5428 <pages>
ffffffffc0201e58:	000b3503          	ld	a0,0(s6)
ffffffffc0201e5c:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e60:	000a3a17          	auipc	s4,0xa3
ffffffffc0201e64:	5c0a0a13          	addi	s4,s4,1472 # ffffffffc02a5420 <npage>
ffffffffc0201e68:	40a40533          	sub	a0,s0,a0
ffffffffc0201e6c:	8519                	srai	a0,a0,0x6
ffffffffc0201e6e:	9556                	add	a0,a0,s5
ffffffffc0201e70:	000a3703          	ld	a4,0(s4)
ffffffffc0201e74:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e78:	4685                	li	a3,1
ffffffffc0201e7a:	83b1                	srli	a5,a5,0xc
ffffffffc0201e7c:	c014                	sw	a3,0(s0)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e7e:	0532                	slli	a0,a0,0xc
ffffffffc0201e80:	14e7f563          	bgeu	a5,a4,ffffffffc0201fca <get_pte+0x1be>
ffffffffc0201e84:	000a3797          	auipc	a5,0xa3
ffffffffc0201e88:	5947b783          	ld	a5,1428(a5) # ffffffffc02a5418 <va_pa_offset>
ffffffffc0201e8c:	6605                	lui	a2,0x1
ffffffffc0201e8e:	4581                	li	a1,0
ffffffffc0201e90:	953e                	add	a0,a0,a5
ffffffffc0201e92:	1ff040ef          	jal	ffffffffc0206890 <memset>
    return page - pages + nbase;
ffffffffc0201e96:	000b3783          	ld	a5,0(s6)
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e9a:	6b02                	ld	s6,0(sp)
ffffffffc0201e9c:	40f406b3          	sub	a3,s0,a5
ffffffffc0201ea0:	8699                	srai	a3,a3,0x6
ffffffffc0201ea2:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ea4:	06aa                	slli	a3,a3,0xa
ffffffffc0201ea6:	0116e693          	ori	a3,a3,17
ffffffffc0201eaa:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201eac:	77fd                	lui	a5,0xfffff
ffffffffc0201eae:	068a                	slli	a3,a3,0x2
ffffffffc0201eb0:	000a3703          	ld	a4,0(s4)
ffffffffc0201eb4:	8efd                	and	a3,a3,a5
ffffffffc0201eb6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201eba:	0ce7f263          	bgeu	a5,a4,ffffffffc0201f7e <get_pte+0x172>
ffffffffc0201ebe:	000a3a97          	auipc	s5,0xa3
ffffffffc0201ec2:	55aa8a93          	addi	s5,s5,1370 # ffffffffc02a5418 <va_pa_offset>
ffffffffc0201ec6:	000ab603          	ld	a2,0(s5)
ffffffffc0201eca:	01595793          	srli	a5,s2,0x15
ffffffffc0201ece:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ed2:	96b2                	add	a3,a3,a2
ffffffffc0201ed4:	078e                	slli	a5,a5,0x3
ffffffffc0201ed6:	00f68433          	add	s0,a3,a5
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201eda:	6014                	ld	a3,0(s0)
ffffffffc0201edc:	0016f793          	andi	a5,a3,1
ffffffffc0201ee0:	e3bd                	bnez	a5,ffffffffc0201f46 <get_pte+0x13a>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201ee2:	08098c63          	beqz	s3,ffffffffc0201f7a <get_pte+0x16e>
ffffffffc0201ee6:	4505                	li	a0,1
ffffffffc0201ee8:	e23ff0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0201eec:	84aa                	mv	s1,a0
ffffffffc0201eee:	c551                	beqz	a0,ffffffffc0201f7a <get_pte+0x16e>
    page->ref = val;
ffffffffc0201ef0:	e05a                	sd	s6,0(sp)
    return page - pages + nbase;
ffffffffc0201ef2:	000a3b17          	auipc	s6,0xa3
ffffffffc0201ef6:	536b0b13          	addi	s6,s6,1334 # ffffffffc02a5428 <pages>
ffffffffc0201efa:	000b3683          	ld	a3,0(s6)
ffffffffc0201efe:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f02:	000a3703          	ld	a4,0(s4)
ffffffffc0201f06:	40d506b3          	sub	a3,a0,a3
ffffffffc0201f0a:	8699                	srai	a3,a3,0x6
ffffffffc0201f0c:	96ce                	add	a3,a3,s3
ffffffffc0201f0e:	00c69793          	slli	a5,a3,0xc
    page->ref = val;
ffffffffc0201f12:	4605                	li	a2,1
ffffffffc0201f14:	83b1                	srli	a5,a5,0xc
ffffffffc0201f16:	c110                	sw	a2,0(a0)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f18:	06b2                	slli	a3,a3,0xc
ffffffffc0201f1a:	08e7fc63          	bgeu	a5,a4,ffffffffc0201fb2 <get_pte+0x1a6>
ffffffffc0201f1e:	000ab503          	ld	a0,0(s5)
ffffffffc0201f22:	6605                	lui	a2,0x1
ffffffffc0201f24:	4581                	li	a1,0
ffffffffc0201f26:	9536                	add	a0,a0,a3
ffffffffc0201f28:	169040ef          	jal	ffffffffc0206890 <memset>
    return page - pages + nbase;
ffffffffc0201f2c:	000b3783          	ld	a5,0(s6)
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f30:	6b02                	ld	s6,0(sp)
ffffffffc0201f32:	40f486b3          	sub	a3,s1,a5
ffffffffc0201f36:	8699                	srai	a3,a3,0x6
ffffffffc0201f38:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f3a:	06aa                	slli	a3,a3,0xa
ffffffffc0201f3c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f40:	e014                	sd	a3,0(s0)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f42:	000a3703          	ld	a4,0(s4)
ffffffffc0201f46:	77fd                	lui	a5,0xfffff
ffffffffc0201f48:	068a                	slli	a3,a3,0x2
ffffffffc0201f4a:	8efd                	and	a3,a3,a5
ffffffffc0201f4c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f50:	04e7f463          	bgeu	a5,a4,ffffffffc0201f98 <get_pte+0x18c>
ffffffffc0201f54:	000ab783          	ld	a5,0(s5)
ffffffffc0201f58:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f5c:	1ff97913          	andi	s2,s2,511
ffffffffc0201f60:	090e                	slli	s2,s2,0x3
ffffffffc0201f62:	96be                	add	a3,a3,a5
ffffffffc0201f64:	01268533          	add	a0,a3,s2
}
ffffffffc0201f68:	70e2                	ld	ra,56(sp)
ffffffffc0201f6a:	7442                	ld	s0,48(sp)
ffffffffc0201f6c:	74a2                	ld	s1,40(sp)
ffffffffc0201f6e:	7902                	ld	s2,32(sp)
ffffffffc0201f70:	69e2                	ld	s3,24(sp)
ffffffffc0201f72:	6a42                	ld	s4,16(sp)
ffffffffc0201f74:	6aa2                	ld	s5,8(sp)
ffffffffc0201f76:	6121                	addi	sp,sp,64
ffffffffc0201f78:	8082                	ret
            return NULL;
ffffffffc0201f7a:	4501                	li	a0,0
ffffffffc0201f7c:	b7f5                	j	ffffffffc0201f68 <get_pte+0x15c>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f7e:	00005617          	auipc	a2,0x5
ffffffffc0201f82:	5e260613          	addi	a2,a2,1506 # ffffffffc0207560 <etext+0xca6>
ffffffffc0201f86:	0e300593          	li	a1,227
ffffffffc0201f8a:	00005517          	auipc	a0,0x5
ffffffffc0201f8e:	6c650513          	addi	a0,a0,1734 # ffffffffc0207650 <etext+0xd96>
ffffffffc0201f92:	e05a                	sd	s6,0(sp)
ffffffffc0201f94:	cdcfe0ef          	jal	ffffffffc0200470 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f98:	00005617          	auipc	a2,0x5
ffffffffc0201f9c:	5c860613          	addi	a2,a2,1480 # ffffffffc0207560 <etext+0xca6>
ffffffffc0201fa0:	0ee00593          	li	a1,238
ffffffffc0201fa4:	00005517          	auipc	a0,0x5
ffffffffc0201fa8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0207650 <etext+0xd96>
ffffffffc0201fac:	e05a                	sd	s6,0(sp)
ffffffffc0201fae:	cc2fe0ef          	jal	ffffffffc0200470 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fb2:	00005617          	auipc	a2,0x5
ffffffffc0201fb6:	5ae60613          	addi	a2,a2,1454 # ffffffffc0207560 <etext+0xca6>
ffffffffc0201fba:	0eb00593          	li	a1,235
ffffffffc0201fbe:	00005517          	auipc	a0,0x5
ffffffffc0201fc2:	69250513          	addi	a0,a0,1682 # ffffffffc0207650 <etext+0xd96>
ffffffffc0201fc6:	caafe0ef          	jal	ffffffffc0200470 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fca:	86aa                	mv	a3,a0
ffffffffc0201fcc:	00005617          	auipc	a2,0x5
ffffffffc0201fd0:	59460613          	addi	a2,a2,1428 # ffffffffc0207560 <etext+0xca6>
ffffffffc0201fd4:	0df00593          	li	a1,223
ffffffffc0201fd8:	00005517          	auipc	a0,0x5
ffffffffc0201fdc:	67850513          	addi	a0,a0,1656 # ffffffffc0207650 <etext+0xd96>
ffffffffc0201fe0:	c90fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0201fe4 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fe4:	1141                	addi	sp,sp,-16
ffffffffc0201fe6:	e022                	sd	s0,0(sp)
ffffffffc0201fe8:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fea:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fec:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fee:	e1fff0ef          	jal	ffffffffc0201e0c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201ff2:	c011                	beqz	s0,ffffffffc0201ff6 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201ff4:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201ff6:	c511                	beqz	a0,ffffffffc0202002 <get_page+0x1e>
ffffffffc0201ff8:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201ffa:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201ffc:	0017f713          	andi	a4,a5,1
ffffffffc0202000:	e709                	bnez	a4,ffffffffc020200a <get_page+0x26>
}
ffffffffc0202002:	60a2                	ld	ra,8(sp)
ffffffffc0202004:	6402                	ld	s0,0(sp)
ffffffffc0202006:	0141                	addi	sp,sp,16
ffffffffc0202008:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020200a:	000a3717          	auipc	a4,0xa3
ffffffffc020200e:	41673703          	ld	a4,1046(a4) # ffffffffc02a5420 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202012:	078a                	slli	a5,a5,0x2
ffffffffc0202014:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202016:	00e7ff63          	bgeu	a5,a4,ffffffffc0202034 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc020201a:	000a3517          	auipc	a0,0xa3
ffffffffc020201e:	40e53503          	ld	a0,1038(a0) # ffffffffc02a5428 <pages>
ffffffffc0202022:	60a2                	ld	ra,8(sp)
ffffffffc0202024:	6402                	ld	s0,0(sp)
ffffffffc0202026:	fff80737          	lui	a4,0xfff80
ffffffffc020202a:	97ba                	add	a5,a5,a4
ffffffffc020202c:	079a                	slli	a5,a5,0x6
ffffffffc020202e:	953e                	add	a0,a0,a5
ffffffffc0202030:	0141                	addi	sp,sp,16
ffffffffc0202032:	8082                	ret
ffffffffc0202034:	cbbff0ef          	jal	ffffffffc0201cee <pa2page.part.0>

ffffffffc0202038 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202038:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020203a:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020203e:	e486                	sd	ra,72(sp)
ffffffffc0202040:	e0a2                	sd	s0,64(sp)
ffffffffc0202042:	fc26                	sd	s1,56(sp)
ffffffffc0202044:	f84a                	sd	s2,48(sp)
ffffffffc0202046:	f44e                	sd	s3,40(sp)
ffffffffc0202048:	f052                	sd	s4,32(sp)
ffffffffc020204a:	ec56                	sd	s5,24(sp)
ffffffffc020204c:	e85a                	sd	s6,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020204e:	03479713          	slli	a4,a5,0x34
ffffffffc0202052:	e761                	bnez	a4,ffffffffc020211a <unmap_range+0xe2>
    assert(USER_ACCESS(start, end));
ffffffffc0202054:	00200ab7          	lui	s5,0x200
ffffffffc0202058:	842e                	mv	s0,a1
ffffffffc020205a:	0f55e063          	bltu	a1,s5,ffffffffc020213a <unmap_range+0x102>
ffffffffc020205e:	8932                	mv	s2,a2
ffffffffc0202060:	0cc5fd63          	bgeu	a1,a2,ffffffffc020213a <unmap_range+0x102>
ffffffffc0202064:	4785                	li	a5,1
ffffffffc0202066:	07fe                	slli	a5,a5,0x1f
ffffffffc0202068:	89aa                	mv	s3,a0
ffffffffc020206a:	6a05                	lui	s4,0x1

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020206c:	ffe00b37          	lui	s6,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc0202070:	0cc7e563          	bltu	a5,a2,ffffffffc020213a <unmap_range+0x102>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202074:	4601                	li	a2,0
ffffffffc0202076:	85a2                	mv	a1,s0
ffffffffc0202078:	854e                	mv	a0,s3
ffffffffc020207a:	d93ff0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc020207e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202080:	cd39                	beqz	a0,ffffffffc02020de <unmap_range+0xa6>
            continue;
        }
        if (*ptep != 0) {
ffffffffc0202082:	611c                	ld	a5,0(a0)
ffffffffc0202084:	ef99                	bnez	a5,ffffffffc02020a2 <unmap_range+0x6a>
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202086:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202088:	c019                	beqz	s0,ffffffffc020208e <unmap_range+0x56>
ffffffffc020208a:	ff2465e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x3c>
}
ffffffffc020208e:	60a6                	ld	ra,72(sp)
ffffffffc0202090:	6406                	ld	s0,64(sp)
ffffffffc0202092:	74e2                	ld	s1,56(sp)
ffffffffc0202094:	7942                	ld	s2,48(sp)
ffffffffc0202096:	79a2                	ld	s3,40(sp)
ffffffffc0202098:	7a02                	ld	s4,32(sp)
ffffffffc020209a:	6ae2                	ld	s5,24(sp)
ffffffffc020209c:	6b42                	ld	s6,16(sp)
ffffffffc020209e:	6161                	addi	sp,sp,80
ffffffffc02020a0:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02020a2:	0017f713          	andi	a4,a5,1
ffffffffc02020a6:	d365                	beqz	a4,ffffffffc0202086 <unmap_range+0x4e>
    if (PPN(pa) >= npage) {
ffffffffc02020a8:	000a3717          	auipc	a4,0xa3
ffffffffc02020ac:	37873703          	ld	a4,888(a4) # ffffffffc02a5420 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02020b0:	078a                	slli	a5,a5,0x2
ffffffffc02020b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b4:	0ae7f363          	bgeu	a5,a4,ffffffffc020215a <unmap_range+0x122>
    return &pages[PPN(pa) - nbase];
ffffffffc02020b8:	000a3517          	auipc	a0,0xa3
ffffffffc02020bc:	37053503          	ld	a0,880(a0) # ffffffffc02a5428 <pages>
ffffffffc02020c0:	fff80737          	lui	a4,0xfff80
ffffffffc02020c4:	97ba                	add	a5,a5,a4
ffffffffc02020c6:	079a                	slli	a5,a5,0x6
ffffffffc02020c8:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020ca:	411c                	lw	a5,0(a0)
ffffffffc02020cc:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0x3fd59b87>
ffffffffc02020ce:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc02020d0:	cb99                	beqz	a5,ffffffffc02020e6 <unmap_range+0xae>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020d2:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020d6:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020da:	9452                	add	s0,s0,s4
ffffffffc02020dc:	b775                	j	ffffffffc0202088 <unmap_range+0x50>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020de:	9456                	add	s0,s0,s5
ffffffffc02020e0:	01647433          	and	s0,s0,s6
            continue;
ffffffffc02020e4:	b755                	j	ffffffffc0202088 <unmap_range+0x50>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020e6:	100027f3          	csrr	a5,sstatus
ffffffffc02020ea:	8b89                	andi	a5,a5,2
ffffffffc02020ec:	eb89                	bnez	a5,ffffffffc02020fe <unmap_range+0xc6>
        pmm_manager->free_pages(base, n);
ffffffffc02020ee:	000a3797          	auipc	a5,0xa3
ffffffffc02020f2:	3127b783          	ld	a5,786(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc02020f6:	4585                	li	a1,1
ffffffffc02020f8:	739c                	ld	a5,32(a5)
ffffffffc02020fa:	9782                	jalr	a5
    if (flag) {
ffffffffc02020fc:	bfd9                	j	ffffffffc02020d2 <unmap_range+0x9a>
        intr_disable();
ffffffffc02020fe:	e42a                	sd	a0,8(sp)
ffffffffc0202100:	d40fe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202104:	000a3797          	auipc	a5,0xa3
ffffffffc0202108:	2fc7b783          	ld	a5,764(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc020210c:	6522                	ld	a0,8(sp)
ffffffffc020210e:	4585                	li	a1,1
ffffffffc0202110:	739c                	ld	a5,32(a5)
ffffffffc0202112:	9782                	jalr	a5
        intr_enable();
ffffffffc0202114:	d26fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202118:	bf6d                	j	ffffffffc02020d2 <unmap_range+0x9a>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020211a:	00005697          	auipc	a3,0x5
ffffffffc020211e:	54668693          	addi	a3,a3,1350 # ffffffffc0207660 <etext+0xda6>
ffffffffc0202122:	00005617          	auipc	a2,0x5
ffffffffc0202126:	e1660613          	addi	a2,a2,-490 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020212a:	10f00593          	li	a1,271
ffffffffc020212e:	00005517          	auipc	a0,0x5
ffffffffc0202132:	52250513          	addi	a0,a0,1314 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202136:	b3afe0ef          	jal	ffffffffc0200470 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020213a:	00005697          	auipc	a3,0x5
ffffffffc020213e:	55668693          	addi	a3,a3,1366 # ffffffffc0207690 <etext+0xdd6>
ffffffffc0202142:	00005617          	auipc	a2,0x5
ffffffffc0202146:	df660613          	addi	a2,a2,-522 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020214a:	11000593          	li	a1,272
ffffffffc020214e:	00005517          	auipc	a0,0x5
ffffffffc0202152:	50250513          	addi	a0,a0,1282 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202156:	b1afe0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc020215a:	b95ff0ef          	jal	ffffffffc0201cee <pa2page.part.0>

ffffffffc020215e <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020215e:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202160:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202164:	fc86                	sd	ra,120(sp)
ffffffffc0202166:	f8a2                	sd	s0,112(sp)
ffffffffc0202168:	f4a6                	sd	s1,104(sp)
ffffffffc020216a:	f0ca                	sd	s2,96(sp)
ffffffffc020216c:	ecce                	sd	s3,88(sp)
ffffffffc020216e:	e8d2                	sd	s4,80(sp)
ffffffffc0202170:	e4d6                	sd	s5,72(sp)
ffffffffc0202172:	e0da                	sd	s6,64(sp)
ffffffffc0202174:	fc5e                	sd	s7,56(sp)
ffffffffc0202176:	f862                	sd	s8,48(sp)
ffffffffc0202178:	f466                	sd	s9,40(sp)
ffffffffc020217a:	f06a                	sd	s10,32(sp)
ffffffffc020217c:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020217e:	17d2                	slli	a5,a5,0x34
ffffffffc0202180:	20079563          	bnez	a5,ffffffffc020238a <exit_range+0x22c>
    assert(USER_ACCESS(start, end));
ffffffffc0202184:	00200c37          	lui	s8,0x200
ffffffffc0202188:	2585ec63          	bltu	a1,s8,ffffffffc02023e0 <exit_range+0x282>
ffffffffc020218c:	8b32                	mv	s6,a2
ffffffffc020218e:	24c5f963          	bgeu	a1,a2,ffffffffc02023e0 <exit_range+0x282>
ffffffffc0202192:	4785                	li	a5,1
ffffffffc0202194:	07fe                	slli	a5,a5,0x1f
ffffffffc0202196:	24c7e563          	bltu	a5,a2,ffffffffc02023e0 <exit_range+0x282>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020219a:	c0000a37          	lui	s4,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020219e:	ffe007b7          	lui	a5,0xffe00
ffffffffc02021a2:	8d2a                	mv	s10,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02021a4:	0145fa33          	and	s4,a1,s4
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02021a8:	00f5f4b3          	and	s1,a1,a5
        d1start += PDSIZE;
ffffffffc02021ac:	40000db7          	lui	s11,0x40000
    if (PPN(pa) >= npage) {
ffffffffc02021b0:	000a3617          	auipc	a2,0xa3
ffffffffc02021b4:	27060613          	addi	a2,a2,624 # ffffffffc02a5420 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021b8:	fff80837          	lui	a6,0xfff80
ffffffffc02021bc:	a811                	j	ffffffffc02021d0 <exit_range+0x72>
ffffffffc02021be:	01ba09b3          	add	s3,s4,s11
    } while (d1start != 0 && d1start < end);
ffffffffc02021c2:	12098d63          	beqz	s3,ffffffffc02022fc <exit_range+0x19e>
        d1start += PDSIZE;
ffffffffc02021c6:	40000a37          	lui	s4,0x40000
        d0start = d1start;
ffffffffc02021ca:	84d2                	mv	s1,s4
    } while (d1start != 0 && d1start < end);
ffffffffc02021cc:	1369f863          	bgeu	s3,s6,ffffffffc02022fc <exit_range+0x19e>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021d0:	01ea5913          	srli	s2,s4,0x1e
ffffffffc02021d4:	1ff97913          	andi	s2,s2,511
ffffffffc02021d8:	090e                	slli	s2,s2,0x3
ffffffffc02021da:	996a                	add	s2,s2,s10
ffffffffc02021dc:	00093a83          	ld	s5,0(s2)
        if (pde1&PTE_V){
ffffffffc02021e0:	001af793          	andi	a5,s5,1
ffffffffc02021e4:	dfe9                	beqz	a5,ffffffffc02021be <exit_range+0x60>
    if (PPN(pa) >= npage) {
ffffffffc02021e6:	621c                	ld	a5,0(a2)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021e8:	0a8a                	slli	s5,s5,0x2
ffffffffc02021ea:	00cada93          	srli	s5,s5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021ee:	1efaf763          	bgeu	s5,a5,ffffffffc02023dc <exit_range+0x27e>
    return &pages[PPN(pa) - nbase];
ffffffffc02021f2:	010a8733          	add	a4,s5,a6
    return page - pages + nbase;
ffffffffc02021f6:	00080337          	lui	t1,0x80
ffffffffc02021fa:	006706b3          	add	a3,a4,t1
    return page2ppn(page) << PGSHIFT;
ffffffffc02021fe:	00c69b93          	slli	s7,a3,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202202:	071a                	slli	a4,a4,0x6
    return KADDR(page2pa(page));
ffffffffc0202204:	1af6ff63          	bgeu	a3,a5,ffffffffc02023c2 <exit_range+0x264>
ffffffffc0202208:	000a3897          	auipc	a7,0xa3
ffffffffc020220c:	21088893          	addi	a7,a7,528 # ffffffffc02a5418 <va_pa_offset>
ffffffffc0202210:	0008b783          	ld	a5,0(a7)
            free_pd0 = 1;
ffffffffc0202214:	4c85                	li	s9,1
ffffffffc0202216:	6e05                	lui	t3,0x1
ffffffffc0202218:	9bbe                	add	s7,s7,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020221a:	01ba09b3          	add	s3,s4,s11
ffffffffc020221e:	a801                	j	ffffffffc020222e <exit_range+0xd0>
                    free_pd0 = 0;
ffffffffc0202220:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0202222:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202224:	c8d9                	beqz	s1,ffffffffc02022ba <exit_range+0x15c>
ffffffffc0202226:	0934fa63          	bgeu	s1,s3,ffffffffc02022ba <exit_range+0x15c>
ffffffffc020222a:	0f64f863          	bgeu	s1,s6,ffffffffc020231a <exit_range+0x1bc>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020222e:	0154d413          	srli	s0,s1,0x15
ffffffffc0202232:	1ff47413          	andi	s0,s0,511
ffffffffc0202236:	040e                	slli	s0,s0,0x3
ffffffffc0202238:	945e                	add	s0,s0,s7
ffffffffc020223a:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc020223c:	0017f693          	andi	a3,a5,1
ffffffffc0202240:	d2e5                	beqz	a3,ffffffffc0202220 <exit_range+0xc2>
    if (PPN(pa) >= npage) {
ffffffffc0202242:	6208                	ld	a0,0(a2)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202244:	078a                	slli	a5,a5,0x2
ffffffffc0202246:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202248:	18a7fa63          	bgeu	a5,a0,ffffffffc02023dc <exit_range+0x27e>
    return &pages[PPN(pa) - nbase];
ffffffffc020224c:	97c2                	add	a5,a5,a6
    return page - pages + nbase;
ffffffffc020224e:	00678eb3          	add	t4,a5,t1
    return &pages[PPN(pa) - nbase];
ffffffffc0202252:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202256:	00ce9693          	slli	a3,t4,0xc
    return KADDR(page2pa(page));
ffffffffc020225a:	14aef863          	bgeu	t4,a0,ffffffffc02023aa <exit_range+0x24c>
ffffffffc020225e:	0008b783          	ld	a5,0(a7)
ffffffffc0202262:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202264:	01c68533          	add	a0,a3,t3
                        if (pt[i]&PTE_V){
ffffffffc0202268:	629c                	ld	a5,0(a3)
ffffffffc020226a:	8b85                	andi	a5,a5,1
ffffffffc020226c:	fbdd                	bnez	a5,ffffffffc0202222 <exit_range+0xc4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020226e:	06a1                	addi	a3,a3,8
ffffffffc0202270:	fea69ce3          	bne	a3,a0,ffffffffc0202268 <exit_range+0x10a>
    return &pages[PPN(pa) - nbase];
ffffffffc0202274:	000a3517          	auipc	a0,0xa3
ffffffffc0202278:	1b453503          	ld	a0,436(a0) # ffffffffc02a5428 <pages>
ffffffffc020227c:	952e                	add	a0,a0,a1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020227e:	100027f3          	csrr	a5,sstatus
ffffffffc0202282:	8b89                	andi	a5,a5,2
ffffffffc0202284:	efd1                	bnez	a5,ffffffffc0202320 <exit_range+0x1c2>
        pmm_manager->free_pages(base, n);
ffffffffc0202286:	000a3797          	auipc	a5,0xa3
ffffffffc020228a:	17a7b783          	ld	a5,378(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc020228e:	4585                	li	a1,1
ffffffffc0202290:	e03a                	sd	a4,0(sp)
ffffffffc0202292:	739c                	ld	a5,32(a5)
ffffffffc0202294:	9782                	jalr	a5
    if (flag) {
ffffffffc0202296:	6702                	ld	a4,0(sp)
ffffffffc0202298:	00080337          	lui	t1,0x80
ffffffffc020229c:	000a3897          	auipc	a7,0xa3
ffffffffc02022a0:	17c88893          	addi	a7,a7,380 # ffffffffc02a5418 <va_pa_offset>
ffffffffc02022a4:	6e05                	lui	t3,0x1
ffffffffc02022a6:	000a3617          	auipc	a2,0xa3
ffffffffc02022aa:	17a60613          	addi	a2,a2,378 # ffffffffc02a5420 <npage>
ffffffffc02022ae:	fff80837          	lui	a6,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022b2:	00043023          	sd	zero,0(s0)
                d0start += PTSIZE;
ffffffffc02022b6:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022b8:	f4bd                	bnez	s1,ffffffffc0202226 <exit_range+0xc8>
            if (free_pd0) {
ffffffffc02022ba:	f00c82e3          	beqz	s9,ffffffffc02021be <exit_range+0x60>
    if (PPN(pa) >= npage) {
ffffffffc02022be:	621c                	ld	a5,0(a2)
ffffffffc02022c0:	10fafe63          	bgeu	s5,a5,ffffffffc02023dc <exit_range+0x27e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022c4:	000a3517          	auipc	a0,0xa3
ffffffffc02022c8:	16453503          	ld	a0,356(a0) # ffffffffc02a5428 <pages>
ffffffffc02022cc:	953a                	add	a0,a0,a4
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022ce:	100027f3          	csrr	a5,sstatus
ffffffffc02022d2:	8b89                	andi	a5,a5,2
ffffffffc02022d4:	e7c9                	bnez	a5,ffffffffc020235e <exit_range+0x200>
        pmm_manager->free_pages(base, n);
ffffffffc02022d6:	000a3797          	auipc	a5,0xa3
ffffffffc02022da:	12a7b783          	ld	a5,298(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc02022de:	4585                	li	a1,1
ffffffffc02022e0:	739c                	ld	a5,32(a5)
ffffffffc02022e2:	9782                	jalr	a5
ffffffffc02022e4:	fff80837          	lui	a6,0xfff80
ffffffffc02022e8:	000a3617          	auipc	a2,0xa3
ffffffffc02022ec:	13860613          	addi	a2,a2,312 # ffffffffc02a5420 <npage>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02022f0:	00093023          	sd	zero,0(s2)
        d1start += PDSIZE;
ffffffffc02022f4:	01ba09b3          	add	s3,s4,s11
    } while (d1start != 0 && d1start < end);
ffffffffc02022f8:	ec0997e3          	bnez	s3,ffffffffc02021c6 <exit_range+0x68>
}
ffffffffc02022fc:	70e6                	ld	ra,120(sp)
ffffffffc02022fe:	7446                	ld	s0,112(sp)
ffffffffc0202300:	74a6                	ld	s1,104(sp)
ffffffffc0202302:	7906                	ld	s2,96(sp)
ffffffffc0202304:	69e6                	ld	s3,88(sp)
ffffffffc0202306:	6a46                	ld	s4,80(sp)
ffffffffc0202308:	6aa6                	ld	s5,72(sp)
ffffffffc020230a:	6b06                	ld	s6,64(sp)
ffffffffc020230c:	7be2                	ld	s7,56(sp)
ffffffffc020230e:	7c42                	ld	s8,48(sp)
ffffffffc0202310:	7ca2                	ld	s9,40(sp)
ffffffffc0202312:	7d02                	ld	s10,32(sp)
ffffffffc0202314:	6de2                	ld	s11,24(sp)
ffffffffc0202316:	6109                	addi	sp,sp,128
ffffffffc0202318:	8082                	ret
            if (free_pd0) {
ffffffffc020231a:	ea0c86e3          	beqz	s9,ffffffffc02021c6 <exit_range+0x68>
ffffffffc020231e:	b745                	j	ffffffffc02022be <exit_range+0x160>
        intr_disable();
ffffffffc0202320:	e03a                	sd	a4,0(sp)
ffffffffc0202322:	e42a                	sd	a0,8(sp)
ffffffffc0202324:	b1cfe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202328:	000a3797          	auipc	a5,0xa3
ffffffffc020232c:	0d87b783          	ld	a5,216(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0202330:	6522                	ld	a0,8(sp)
ffffffffc0202332:	4585                	li	a1,1
ffffffffc0202334:	739c                	ld	a5,32(a5)
ffffffffc0202336:	9782                	jalr	a5
        intr_enable();
ffffffffc0202338:	b02fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020233c:	6702                	ld	a4,0(sp)
ffffffffc020233e:	fff80837          	lui	a6,0xfff80
ffffffffc0202342:	000a3617          	auipc	a2,0xa3
ffffffffc0202346:	0de60613          	addi	a2,a2,222 # ffffffffc02a5420 <npage>
ffffffffc020234a:	6e05                	lui	t3,0x1
ffffffffc020234c:	000a3897          	auipc	a7,0xa3
ffffffffc0202350:	0cc88893          	addi	a7,a7,204 # ffffffffc02a5418 <va_pa_offset>
ffffffffc0202354:	00080337          	lui	t1,0x80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202358:	00043023          	sd	zero,0(s0)
ffffffffc020235c:	bfa9                	j	ffffffffc02022b6 <exit_range+0x158>
        intr_disable();
ffffffffc020235e:	e02a                	sd	a0,0(sp)
ffffffffc0202360:	ae0fe0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202364:	000a3797          	auipc	a5,0xa3
ffffffffc0202368:	09c7b783          	ld	a5,156(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc020236c:	6502                	ld	a0,0(sp)
ffffffffc020236e:	4585                	li	a1,1
ffffffffc0202370:	739c                	ld	a5,32(a5)
ffffffffc0202372:	9782                	jalr	a5
        intr_enable();
ffffffffc0202374:	ac6fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202378:	000a3617          	auipc	a2,0xa3
ffffffffc020237c:	0a860613          	addi	a2,a2,168 # ffffffffc02a5420 <npage>
ffffffffc0202380:	fff80837          	lui	a6,0xfff80
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202384:	00093023          	sd	zero,0(s2)
ffffffffc0202388:	b7b5                	j	ffffffffc02022f4 <exit_range+0x196>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020238a:	00005697          	auipc	a3,0x5
ffffffffc020238e:	2d668693          	addi	a3,a3,726 # ffffffffc0207660 <etext+0xda6>
ffffffffc0202392:	00005617          	auipc	a2,0x5
ffffffffc0202396:	ba660613          	addi	a2,a2,-1114 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020239a:	12000593          	li	a1,288
ffffffffc020239e:	00005517          	auipc	a0,0x5
ffffffffc02023a2:	2b250513          	addi	a0,a0,690 # ffffffffc0207650 <etext+0xd96>
ffffffffc02023a6:	8cafe0ef          	jal	ffffffffc0200470 <__panic>
    return KADDR(page2pa(page));
ffffffffc02023aa:	00005617          	auipc	a2,0x5
ffffffffc02023ae:	1b660613          	addi	a2,a2,438 # ffffffffc0207560 <etext+0xca6>
ffffffffc02023b2:	06900593          	li	a1,105
ffffffffc02023b6:	00005517          	auipc	a0,0x5
ffffffffc02023ba:	1d250513          	addi	a0,a0,466 # ffffffffc0207588 <etext+0xcce>
ffffffffc02023be:	8b2fe0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc02023c2:	86de                	mv	a3,s7
ffffffffc02023c4:	00005617          	auipc	a2,0x5
ffffffffc02023c8:	19c60613          	addi	a2,a2,412 # ffffffffc0207560 <etext+0xca6>
ffffffffc02023cc:	06900593          	li	a1,105
ffffffffc02023d0:	00005517          	auipc	a0,0x5
ffffffffc02023d4:	1b850513          	addi	a0,a0,440 # ffffffffc0207588 <etext+0xcce>
ffffffffc02023d8:	898fe0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc02023dc:	913ff0ef          	jal	ffffffffc0201cee <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023e0:	00005697          	auipc	a3,0x5
ffffffffc02023e4:	2b068693          	addi	a3,a3,688 # ffffffffc0207690 <etext+0xdd6>
ffffffffc02023e8:	00005617          	auipc	a2,0x5
ffffffffc02023ec:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02023f0:	12100593          	li	a1,289
ffffffffc02023f4:	00005517          	auipc	a0,0x5
ffffffffc02023f8:	25c50513          	addi	a0,a0,604 # ffffffffc0207650 <etext+0xd96>
ffffffffc02023fc:	874fe0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0202400 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202400:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202402:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202404:	ec26                	sd	s1,24(sp)
ffffffffc0202406:	f406                	sd	ra,40(sp)
ffffffffc0202408:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020240a:	a03ff0ef          	jal	ffffffffc0201e0c <get_pte>
    if (ptep != NULL) {
ffffffffc020240e:	c901                	beqz	a0,ffffffffc020241e <page_remove+0x1e>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202410:	611c                	ld	a5,0(a0)
ffffffffc0202412:	f022                	sd	s0,32(sp)
ffffffffc0202414:	842a                	mv	s0,a0
ffffffffc0202416:	0017f713          	andi	a4,a5,1
ffffffffc020241a:	e711                	bnez	a4,ffffffffc0202426 <page_remove+0x26>
ffffffffc020241c:	7402                	ld	s0,32(sp)
}
ffffffffc020241e:	70a2                	ld	ra,40(sp)
ffffffffc0202420:	64e2                	ld	s1,24(sp)
ffffffffc0202422:	6145                	addi	sp,sp,48
ffffffffc0202424:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202426:	000a3717          	auipc	a4,0xa3
ffffffffc020242a:	ffa73703          	ld	a4,-6(a4) # ffffffffc02a5420 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020242e:	078a                	slli	a5,a5,0x2
ffffffffc0202430:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202432:	06e7f263          	bgeu	a5,a4,ffffffffc0202496 <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202436:	000a3517          	auipc	a0,0xa3
ffffffffc020243a:	ff253503          	ld	a0,-14(a0) # ffffffffc02a5428 <pages>
ffffffffc020243e:	fff80737          	lui	a4,0xfff80
ffffffffc0202442:	97ba                	add	a5,a5,a4
ffffffffc0202444:	079a                	slli	a5,a5,0x6
ffffffffc0202446:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202448:	411c                	lw	a5,0(a0)
ffffffffc020244a:	37fd                	addiw	a5,a5,-1
ffffffffc020244c:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc020244e:	cb91                	beqz	a5,ffffffffc0202462 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202450:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202454:	12048073          	sfence.vma	s1
ffffffffc0202458:	7402                	ld	s0,32(sp)
}
ffffffffc020245a:	70a2                	ld	ra,40(sp)
ffffffffc020245c:	64e2                	ld	s1,24(sp)
ffffffffc020245e:	6145                	addi	sp,sp,48
ffffffffc0202460:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202462:	100027f3          	csrr	a5,sstatus
ffffffffc0202466:	8b89                	andi	a5,a5,2
ffffffffc0202468:	eb89                	bnez	a5,ffffffffc020247a <page_remove+0x7a>
        pmm_manager->free_pages(base, n);
ffffffffc020246a:	000a3797          	auipc	a5,0xa3
ffffffffc020246e:	f967b783          	ld	a5,-106(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0202472:	4585                	li	a1,1
ffffffffc0202474:	739c                	ld	a5,32(a5)
ffffffffc0202476:	9782                	jalr	a5
    if (flag) {
ffffffffc0202478:	bfe1                	j	ffffffffc0202450 <page_remove+0x50>
        intr_disable();
ffffffffc020247a:	e42a                	sd	a0,8(sp)
ffffffffc020247c:	9c4fe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202480:	000a3797          	auipc	a5,0xa3
ffffffffc0202484:	f807b783          	ld	a5,-128(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0202488:	6522                	ld	a0,8(sp)
ffffffffc020248a:	4585                	li	a1,1
ffffffffc020248c:	739c                	ld	a5,32(a5)
ffffffffc020248e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202490:	9aafe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202494:	bf75                	j	ffffffffc0202450 <page_remove+0x50>
ffffffffc0202496:	859ff0ef          	jal	ffffffffc0201cee <pa2page.part.0>

ffffffffc020249a <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020249a:	7139                	addi	sp,sp,-64
ffffffffc020249c:	f822                	sd	s0,48(sp)
ffffffffc020249e:	e852                	sd	s4,16(sp)
ffffffffc02024a0:	842e                	mv	s0,a1
ffffffffc02024a2:	8a32                	mv	s4,a2
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024a4:	85b2                	mv	a1,a2
ffffffffc02024a6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02024a8:	f426                	sd	s1,40(sp)
ffffffffc02024aa:	fc06                	sd	ra,56(sp)
ffffffffc02024ac:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024ae:	95fff0ef          	jal	ffffffffc0201e0c <get_pte>
    if (ptep == NULL) {
ffffffffc02024b2:	c969                	beqz	a0,ffffffffc0202584 <page_insert+0xea>
    page->ref += 1;
ffffffffc02024b4:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02024b6:	611c                	ld	a5,0(a0)
ffffffffc02024b8:	ec4e                	sd	s3,24(sp)
ffffffffc02024ba:	0016871b          	addiw	a4,a3,1
ffffffffc02024be:	c018                	sw	a4,0(s0)
ffffffffc02024c0:	0017f713          	andi	a4,a5,1
ffffffffc02024c4:	89aa                	mv	s3,a0
ffffffffc02024c6:	eb15                	bnez	a4,ffffffffc02024fa <page_insert+0x60>
    return &pages[PPN(pa) - nbase];
ffffffffc02024c8:	000a3717          	auipc	a4,0xa3
ffffffffc02024cc:	f6073703          	ld	a4,-160(a4) # ffffffffc02a5428 <pages>
    return page - pages + nbase;
ffffffffc02024d0:	8c19                	sub	s0,s0,a4
ffffffffc02024d2:	000807b7          	lui	a5,0x80
ffffffffc02024d6:	8419                	srai	s0,s0,0x6
ffffffffc02024d8:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024da:	042a                	slli	s0,s0,0xa
ffffffffc02024dc:	8cc1                	or	s1,s1,s0
ffffffffc02024de:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024e2:	0099b023          	sd	s1,0(s3) # 80000 <_binary_obj___user_cow_out_size+0x73158>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024e6:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024ea:	69e2                	ld	s3,24(sp)
ffffffffc02024ec:	4501                	li	a0,0
}
ffffffffc02024ee:	70e2                	ld	ra,56(sp)
ffffffffc02024f0:	7442                	ld	s0,48(sp)
ffffffffc02024f2:	74a2                	ld	s1,40(sp)
ffffffffc02024f4:	6a42                	ld	s4,16(sp)
ffffffffc02024f6:	6121                	addi	sp,sp,64
ffffffffc02024f8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02024fa:	000a3717          	auipc	a4,0xa3
ffffffffc02024fe:	f2673703          	ld	a4,-218(a4) # ffffffffc02a5420 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202502:	078a                	slli	a5,a5,0x2
ffffffffc0202504:	f04a                	sd	s2,32(sp)
ffffffffc0202506:	e456                	sd	s5,8(sp)
ffffffffc0202508:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020250a:	06e7ff63          	bgeu	a5,a4,ffffffffc0202588 <page_insert+0xee>
    return &pages[PPN(pa) - nbase];
ffffffffc020250e:	000a3a97          	auipc	s5,0xa3
ffffffffc0202512:	f1aa8a93          	addi	s5,s5,-230 # ffffffffc02a5428 <pages>
ffffffffc0202516:	000ab703          	ld	a4,0(s5)
ffffffffc020251a:	fff80637          	lui	a2,0xfff80
ffffffffc020251e:	00c78933          	add	s2,a5,a2
ffffffffc0202522:	091a                	slli	s2,s2,0x6
ffffffffc0202524:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202526:	01240d63          	beq	s0,s2,ffffffffc0202540 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc020252a:	00092783          	lw	a5,0(s2)
ffffffffc020252e:	37fd                	addiw	a5,a5,-1 # 7ffff <_binary_obj___user_cow_out_size+0x73157>
ffffffffc0202530:	00f92023          	sw	a5,0(s2)
        if (page_ref(page) ==
ffffffffc0202534:	cb91                	beqz	a5,ffffffffc0202548 <page_insert+0xae>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202536:	120a0073          	sfence.vma	s4
ffffffffc020253a:	7902                	ld	s2,32(sp)
ffffffffc020253c:	6aa2                	ld	s5,8(sp)
}
ffffffffc020253e:	bf49                	j	ffffffffc02024d0 <page_insert+0x36>
    return page->ref;
ffffffffc0202540:	7902                	ld	s2,32(sp)
ffffffffc0202542:	6aa2                	ld	s5,8(sp)
    page->ref -= 1;
ffffffffc0202544:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202546:	b769                	j	ffffffffc02024d0 <page_insert+0x36>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202548:	100027f3          	csrr	a5,sstatus
ffffffffc020254c:	8b89                	andi	a5,a5,2
ffffffffc020254e:	ef81                	bnez	a5,ffffffffc0202566 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202550:	000a3797          	auipc	a5,0xa3
ffffffffc0202554:	eb07b783          	ld	a5,-336(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0202558:	854a                	mv	a0,s2
ffffffffc020255a:	4585                	li	a1,1
ffffffffc020255c:	739c                	ld	a5,32(a5)
ffffffffc020255e:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202560:	000ab703          	ld	a4,0(s5)
ffffffffc0202564:	bfc9                	j	ffffffffc0202536 <page_insert+0x9c>
        intr_disable();
ffffffffc0202566:	8dafe0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc020256a:	000a3797          	auipc	a5,0xa3
ffffffffc020256e:	e967b783          	ld	a5,-362(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0202572:	854a                	mv	a0,s2
ffffffffc0202574:	4585                	li	a1,1
ffffffffc0202576:	739c                	ld	a5,32(a5)
ffffffffc0202578:	9782                	jalr	a5
        intr_enable();
ffffffffc020257a:	8c0fe0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020257e:	000ab703          	ld	a4,0(s5)
ffffffffc0202582:	bf55                	j	ffffffffc0202536 <page_insert+0x9c>
        return -E_NO_MEM;
ffffffffc0202584:	5571                	li	a0,-4
ffffffffc0202586:	b7a5                	j	ffffffffc02024ee <page_insert+0x54>
ffffffffc0202588:	f66ff0ef          	jal	ffffffffc0201cee <pa2page.part.0>

ffffffffc020258c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020258c:	00006797          	auipc	a5,0x6
ffffffffc0202590:	6c478793          	addi	a5,a5,1732 # ffffffffc0208c50 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202594:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202596:	711d                	addi	sp,sp,-96
ffffffffc0202598:	ec86                	sd	ra,88(sp)
ffffffffc020259a:	e4a6                	sd	s1,72(sp)
ffffffffc020259c:	fc4e                	sd	s3,56(sp)
ffffffffc020259e:	f05a                	sd	s6,32(sp)
ffffffffc02025a0:	ec5e                	sd	s7,24(sp)
ffffffffc02025a2:	e8a2                	sd	s0,80(sp)
ffffffffc02025a4:	e0ca                	sd	s2,64(sp)
ffffffffc02025a6:	f852                	sd	s4,48(sp)
ffffffffc02025a8:	f456                	sd	s5,40(sp)
ffffffffc02025aa:	e862                	sd	s8,16(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02025ac:	000a3b97          	auipc	s7,0xa3
ffffffffc02025b0:	e54b8b93          	addi	s7,s7,-428 # ffffffffc02a5400 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025b4:	00005517          	auipc	a0,0x5
ffffffffc02025b8:	0f450513          	addi	a0,a0,244 # ffffffffc02076a8 <etext+0xdee>
    pmm_manager = &default_pmm_manager;
ffffffffc02025bc:	00fbb023          	sd	a5,0(s7)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025c0:	bd1fd0ef          	jal	ffffffffc0200190 <cprintf>
    pmm_manager->init();
ffffffffc02025c4:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025c8:	000a3997          	auipc	s3,0xa3
ffffffffc02025cc:	e5098993          	addi	s3,s3,-432 # ffffffffc02a5418 <va_pa_offset>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025d0:	000a3b17          	auipc	s6,0xa3
ffffffffc02025d4:	e58b0b13          	addi	s6,s6,-424 # ffffffffc02a5428 <pages>
    pmm_manager->init();
ffffffffc02025d8:	679c                	ld	a5,8(a5)
    npage = maxpa / PGSIZE;
ffffffffc02025da:	000a3497          	auipc	s1,0xa3
ffffffffc02025de:	e4648493          	addi	s1,s1,-442 # ffffffffc02a5420 <npage>
    pmm_manager->init();
ffffffffc02025e2:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025e4:	57f5                	li	a5,-3
ffffffffc02025e6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025e8:	00005517          	auipc	a0,0x5
ffffffffc02025ec:	0d850513          	addi	a0,a0,216 # ffffffffc02076c0 <etext+0xe06>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025f0:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025f4:	b9dfd0ef          	jal	ffffffffc0200190 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025f8:	46c5                	li	a3,17
ffffffffc02025fa:	06ee                	slli	a3,a3,0x1b
ffffffffc02025fc:	40100613          	li	a2,1025
ffffffffc0202600:	16fd                	addi	a3,a3,-1
ffffffffc0202602:	0656                	slli	a2,a2,0x15
ffffffffc0202604:	07e005b7          	lui	a1,0x7e00
ffffffffc0202608:	00005517          	auipc	a0,0x5
ffffffffc020260c:	0d050513          	addi	a0,a0,208 # ffffffffc02076d8 <etext+0xe1e>
ffffffffc0202610:	b81fd0ef          	jal	ffffffffc0200190 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202614:	77fd                	lui	a5,0xfffff
ffffffffc0202616:	000a4617          	auipc	a2,0xa4
ffffffffc020261a:	e6160613          	addi	a2,a2,-415 # ffffffffc02a6477 <end+0xfff>
ffffffffc020261e:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc0202620:	000887b7          	lui	a5,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202624:	00cb3023          	sd	a2,0(s6)
    npage = maxpa / PGSIZE;
ffffffffc0202628:	e09c                	sd	a5,0(s1)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020262a:	4701                	li	a4,0
ffffffffc020262c:	4685                	li	a3,1
ffffffffc020262e:	fff80837          	lui	a6,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202632:	00671793          	slli	a5,a4,0x6
ffffffffc0202636:	97b2                	add	a5,a5,a2
ffffffffc0202638:	07a1                	addi	a5,a5,8 # 88008 <_binary_obj___user_cow_out_size+0x7b160>
ffffffffc020263a:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020263e:	6088                	ld	a0,0(s1)
ffffffffc0202640:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202642:	000b3603          	ld	a2,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202646:	010507b3          	add	a5,a0,a6
ffffffffc020264a:	fef764e3          	bltu	a4,a5,ffffffffc0202632 <pmm_init+0xa6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020264e:	079a                	slli	a5,a5,0x6
ffffffffc0202650:	00f606b3          	add	a3,a2,a5
ffffffffc0202654:	c02007b7          	lui	a5,0xc0200
ffffffffc0202658:	60f6e363          	bltu	a3,a5,ffffffffc0202c5e <pmm_init+0x6d2>
ffffffffc020265c:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202660:	4745                	li	a4,17
ffffffffc0202662:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202664:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202666:	4ae6e263          	bltu	a3,a4,ffffffffc0202b0a <pmm_init+0x57e>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020266a:	00005517          	auipc	a0,0x5
ffffffffc020266e:	09650513          	addi	a0,a0,150 # ffffffffc0207700 <etext+0xe46>
ffffffffc0202672:	b1ffd0ef          	jal	ffffffffc0200190 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202676:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020267a:	000a3917          	auipc	s2,0xa3
ffffffffc020267e:	d9690913          	addi	s2,s2,-618 # ffffffffc02a5410 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202682:	7b9c                	ld	a5,48(a5)
ffffffffc0202684:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202686:	00005517          	auipc	a0,0x5
ffffffffc020268a:	09250513          	addi	a0,a0,146 # ffffffffc0207718 <etext+0xe5e>
ffffffffc020268e:	b03fd0ef          	jal	ffffffffc0200190 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202692:	00009697          	auipc	a3,0x9
ffffffffc0202696:	96e68693          	addi	a3,a3,-1682 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020269a:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020269e:	c02007b7          	lui	a5,0xc0200
ffffffffc02026a2:	5cf6ea63          	bltu	a3,a5,ffffffffc0202c76 <pmm_init+0x6ea>
ffffffffc02026a6:	0009b783          	ld	a5,0(s3)
ffffffffc02026aa:	8e9d                	sub	a3,a3,a5
ffffffffc02026ac:	000a3797          	auipc	a5,0xa3
ffffffffc02026b0:	d4d7be23          	sd	a3,-676(a5) # ffffffffc02a5408 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026b4:	100027f3          	csrr	a5,sstatus
ffffffffc02026b8:	8b89                	andi	a5,a5,2
ffffffffc02026ba:	46079f63          	bnez	a5,ffffffffc0202b38 <pmm_init+0x5ac>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026be:	000bb783          	ld	a5,0(s7)
ffffffffc02026c2:	779c                	ld	a5,40(a5)
ffffffffc02026c4:	9782                	jalr	a5
ffffffffc02026c6:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02026c8:	6098                	ld	a4,0(s1)
ffffffffc02026ca:	c80007b7          	lui	a5,0xc8000
ffffffffc02026ce:	83b1                	srli	a5,a5,0xc
ffffffffc02026d0:	5ce7ef63          	bltu	a5,a4,ffffffffc0202cae <pmm_init+0x722>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026d4:	00093503          	ld	a0,0(s2)
ffffffffc02026d8:	5a050b63          	beqz	a0,ffffffffc0202c8e <pmm_init+0x702>
ffffffffc02026dc:	03451793          	slli	a5,a0,0x34
ffffffffc02026e0:	5a079763          	bnez	a5,ffffffffc0202c8e <pmm_init+0x702>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026e4:	4601                	li	a2,0
ffffffffc02026e6:	4581                	li	a1,0
ffffffffc02026e8:	8fdff0ef          	jal	ffffffffc0201fe4 <get_page>
ffffffffc02026ec:	62051d63          	bnez	a0,ffffffffc0202d26 <pmm_init+0x79a>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026f0:	4505                	li	a0,1
ffffffffc02026f2:	e18ff0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc02026f6:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026f8:	00093503          	ld	a0,0(s2)
ffffffffc02026fc:	85d2                	mv	a1,s4
ffffffffc02026fe:	4681                	li	a3,0
ffffffffc0202700:	4601                	li	a2,0
ffffffffc0202702:	d99ff0ef          	jal	ffffffffc020249a <page_insert>
ffffffffc0202706:	60051063          	bnez	a0,ffffffffc0202d06 <pmm_init+0x77a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020270a:	00093503          	ld	a0,0(s2)
ffffffffc020270e:	4601                	li	a2,0
ffffffffc0202710:	4581                	li	a1,0
ffffffffc0202712:	efaff0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc0202716:	5c050863          	beqz	a0,ffffffffc0202ce6 <pmm_init+0x75a>
    assert(pte2page(*ptep) == p1);
ffffffffc020271a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020271c:	0017f713          	andi	a4,a5,1
ffffffffc0202720:	5a070763          	beqz	a4,ffffffffc0202cce <pmm_init+0x742>
    if (PPN(pa) >= npage) {
ffffffffc0202724:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202726:	078a                	slli	a5,a5,0x2
ffffffffc0202728:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020272a:	52e7f863          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc020272e:	000b3683          	ld	a3,0(s6)
ffffffffc0202732:	fff80637          	lui	a2,0xfff80
ffffffffc0202736:	97b2                	add	a5,a5,a2
ffffffffc0202738:	079a                	slli	a5,a5,0x6
ffffffffc020273a:	97b6                	add	a5,a5,a3
ffffffffc020273c:	10fa1ee3          	bne	s4,a5,ffffffffc0203058 <pmm_init+0xacc>
    assert(page_ref(p1) == 1);
ffffffffc0202740:	000a2683          	lw	a3,0(s4) # 40000000 <_binary_obj___user_cow_out_size+0x3fff3158>
ffffffffc0202744:	4785                	li	a5,1
ffffffffc0202746:	14f695e3          	bne	a3,a5,ffffffffc0203090 <pmm_init+0xb04>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020274a:	00093503          	ld	a0,0(s2)
ffffffffc020274e:	77fd                	lui	a5,0xfffff
ffffffffc0202750:	6114                	ld	a3,0(a0)
ffffffffc0202752:	068a                	slli	a3,a3,0x2
ffffffffc0202754:	8efd                	and	a3,a3,a5
ffffffffc0202756:	00c6d613          	srli	a2,a3,0xc
ffffffffc020275a:	10e67fe3          	bgeu	a2,a4,ffffffffc0203078 <pmm_init+0xaec>
ffffffffc020275e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202762:	96e2                	add	a3,a3,s8
ffffffffc0202764:	0006ba83          	ld	s5,0(a3)
ffffffffc0202768:	0a8a                	slli	s5,s5,0x2
ffffffffc020276a:	00fafab3          	and	s5,s5,a5
ffffffffc020276e:	00cad793          	srli	a5,s5,0xc
ffffffffc0202772:	62e7fa63          	bgeu	a5,a4,ffffffffc0202da6 <pmm_init+0x81a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202776:	4601                	li	a2,0
ffffffffc0202778:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020277a:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020277c:	e90ff0ef          	jal	ffffffffc0201e0c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202780:	0c21                	addi	s8,s8,8 # 200008 <_binary_obj___user_cow_out_size+0x1f3160>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202782:	61851263          	bne	a0,s8,ffffffffc0202d86 <pmm_init+0x7fa>

    p2 = alloc_page();
ffffffffc0202786:	4505                	li	a0,1
ffffffffc0202788:	d82ff0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc020278c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020278e:	00093503          	ld	a0,0(s2)
ffffffffc0202792:	85d6                	mv	a1,s5
ffffffffc0202794:	46d1                	li	a3,20
ffffffffc0202796:	6605                	lui	a2,0x1
ffffffffc0202798:	d03ff0ef          	jal	ffffffffc020249a <page_insert>
ffffffffc020279c:	5a051563          	bnez	a0,ffffffffc0202d46 <pmm_init+0x7ba>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027a0:	00093503          	ld	a0,0(s2)
ffffffffc02027a4:	4601                	li	a2,0
ffffffffc02027a6:	6585                	lui	a1,0x1
ffffffffc02027a8:	e64ff0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc02027ac:	100502e3          	beqz	a0,ffffffffc02030b0 <pmm_init+0xb24>
    assert(*ptep & PTE_U);
ffffffffc02027b0:	611c                	ld	a5,0(a0)
ffffffffc02027b2:	0107f713          	andi	a4,a5,16
ffffffffc02027b6:	70070563          	beqz	a4,ffffffffc0202ec0 <pmm_init+0x934>
    assert(*ptep & PTE_W);
ffffffffc02027ba:	8b91                	andi	a5,a5,4
ffffffffc02027bc:	6c078263          	beqz	a5,ffffffffc0202e80 <pmm_init+0x8f4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027c0:	00093503          	ld	a0,0(s2)
ffffffffc02027c4:	611c                	ld	a5,0(a0)
ffffffffc02027c6:	8bc1                	andi	a5,a5,16
ffffffffc02027c8:	68078c63          	beqz	a5,ffffffffc0202e60 <pmm_init+0x8d4>
    assert(page_ref(p2) == 1);
ffffffffc02027cc:	000aa703          	lw	a4,0(s5)
ffffffffc02027d0:	4785                	li	a5,1
ffffffffc02027d2:	58f71a63          	bne	a4,a5,ffffffffc0202d66 <pmm_init+0x7da>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027d6:	4681                	li	a3,0
ffffffffc02027d8:	6605                	lui	a2,0x1
ffffffffc02027da:	85d2                	mv	a1,s4
ffffffffc02027dc:	cbfff0ef          	jal	ffffffffc020249a <page_insert>
ffffffffc02027e0:	64051063          	bnez	a0,ffffffffc0202e20 <pmm_init+0x894>
    assert(page_ref(p1) == 2);
ffffffffc02027e4:	000a2703          	lw	a4,0(s4)
ffffffffc02027e8:	4789                	li	a5,2
ffffffffc02027ea:	60f71b63          	bne	a4,a5,ffffffffc0202e00 <pmm_init+0x874>
    assert(page_ref(p2) == 0);
ffffffffc02027ee:	000aa783          	lw	a5,0(s5)
ffffffffc02027f2:	5e079763          	bnez	a5,ffffffffc0202de0 <pmm_init+0x854>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027f6:	00093503          	ld	a0,0(s2)
ffffffffc02027fa:	4601                	li	a2,0
ffffffffc02027fc:	6585                	lui	a1,0x1
ffffffffc02027fe:	e0eff0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc0202802:	5a050f63          	beqz	a0,ffffffffc0202dc0 <pmm_init+0x834>
    assert(pte2page(*ptep) == p1);
ffffffffc0202806:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202808:	00177793          	andi	a5,a4,1
ffffffffc020280c:	4c078163          	beqz	a5,ffffffffc0202cce <pmm_init+0x742>
    if (PPN(pa) >= npage) {
ffffffffc0202810:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202812:	00271793          	slli	a5,a4,0x2
ffffffffc0202816:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202818:	44d7f163          	bgeu	a5,a3,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc020281c:	000b3683          	ld	a3,0(s6)
ffffffffc0202820:	fff80637          	lui	a2,0xfff80
ffffffffc0202824:	97b2                	add	a5,a5,a2
ffffffffc0202826:	079a                	slli	a5,a5,0x6
ffffffffc0202828:	97b6                	add	a5,a5,a3
ffffffffc020282a:	6efa1b63          	bne	s4,a5,ffffffffc0202f20 <pmm_init+0x994>
    assert((*ptep & PTE_U) == 0);
ffffffffc020282e:	8b41                	andi	a4,a4,16
ffffffffc0202830:	6c071863          	bnez	a4,ffffffffc0202f00 <pmm_init+0x974>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202834:	00093503          	ld	a0,0(s2)
ffffffffc0202838:	4581                	li	a1,0
ffffffffc020283a:	bc7ff0ef          	jal	ffffffffc0202400 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020283e:	000a2703          	lw	a4,0(s4)
ffffffffc0202842:	4785                	li	a5,1
ffffffffc0202844:	68f71e63          	bne	a4,a5,ffffffffc0202ee0 <pmm_init+0x954>
    assert(page_ref(p2) == 0);
ffffffffc0202848:	000aa783          	lw	a5,0(s5)
ffffffffc020284c:	76079663          	bnez	a5,ffffffffc0202fb8 <pmm_init+0xa2c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202850:	00093503          	ld	a0,0(s2)
ffffffffc0202854:	6585                	lui	a1,0x1
ffffffffc0202856:	babff0ef          	jal	ffffffffc0202400 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020285a:	000a2783          	lw	a5,0(s4)
ffffffffc020285e:	72079d63          	bnez	a5,ffffffffc0202f98 <pmm_init+0xa0c>
    assert(page_ref(p2) == 0);
ffffffffc0202862:	000aa783          	lw	a5,0(s5)
ffffffffc0202866:	70079963          	bnez	a5,ffffffffc0202f78 <pmm_init+0x9ec>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020286a:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020286e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202870:	000a3783          	ld	a5,0(s4)
ffffffffc0202874:	078a                	slli	a5,a5,0x2
ffffffffc0202876:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202878:	3ee7f163          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc020287c:	fff806b7          	lui	a3,0xfff80
ffffffffc0202880:	000b3503          	ld	a0,0(s6)
ffffffffc0202884:	97b6                	add	a5,a5,a3
ffffffffc0202886:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202888:	00f506b3          	add	a3,a0,a5
ffffffffc020288c:	428c                	lw	a1,0(a3)
ffffffffc020288e:	4685                	li	a3,1
ffffffffc0202890:	6cd59463          	bne	a1,a3,ffffffffc0202f58 <pmm_init+0x9cc>
    return page - pages + nbase;
ffffffffc0202894:	8799                	srai	a5,a5,0x6
ffffffffc0202896:	00080637          	lui	a2,0x80
ffffffffc020289a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020289c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02028a0:	6ae7f063          	bgeu	a5,a4,ffffffffc0202f40 <pmm_init+0x9b4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02028a4:	0009b783          	ld	a5,0(s3)
ffffffffc02028a8:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02028aa:	639c                	ld	a5,0(a5)
ffffffffc02028ac:	078a                	slli	a5,a5,0x2
ffffffffc02028ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028b0:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc02028b4:	8f91                	sub	a5,a5,a2
ffffffffc02028b6:	079a                	slli	a5,a5,0x6
ffffffffc02028b8:	953e                	add	a0,a0,a5
ffffffffc02028ba:	100027f3          	csrr	a5,sstatus
ffffffffc02028be:	8b89                	andi	a5,a5,2
ffffffffc02028c0:	2c079663          	bnez	a5,ffffffffc0202b8c <pmm_init+0x600>
        pmm_manager->free_pages(base, n);
ffffffffc02028c4:	000bb783          	ld	a5,0(s7)
ffffffffc02028c8:	739c                	ld	a5,32(a5)
ffffffffc02028ca:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028cc:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028d0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028d2:	078a                	slli	a5,a5,0x2
ffffffffc02028d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028d6:	38e7f263          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc02028da:	000b3503          	ld	a0,0(s6)
ffffffffc02028de:	fff80737          	lui	a4,0xfff80
ffffffffc02028e2:	97ba                	add	a5,a5,a4
ffffffffc02028e4:	079a                	slli	a5,a5,0x6
ffffffffc02028e6:	953e                	add	a0,a0,a5
ffffffffc02028e8:	100027f3          	csrr	a5,sstatus
ffffffffc02028ec:	8b89                	andi	a5,a5,2
ffffffffc02028ee:	28079363          	bnez	a5,ffffffffc0202b74 <pmm_init+0x5e8>
ffffffffc02028f2:	000bb783          	ld	a5,0(s7)
ffffffffc02028f6:	4585                	li	a1,1
ffffffffc02028f8:	739c                	ld	a5,32(a5)
ffffffffc02028fa:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028fc:	00093783          	ld	a5,0(s2)
ffffffffc0202900:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd59b88>
  asm volatile("sfence.vma");
ffffffffc0202904:	12000073          	sfence.vma
ffffffffc0202908:	100027f3          	csrr	a5,sstatus
ffffffffc020290c:	8b89                	andi	a5,a5,2
ffffffffc020290e:	24079963          	bnez	a5,ffffffffc0202b60 <pmm_init+0x5d4>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202912:	000bb783          	ld	a5,0(s7)
ffffffffc0202916:	779c                	ld	a5,40(a5)
ffffffffc0202918:	9782                	jalr	a5
ffffffffc020291a:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020291c:	71441e63          	bne	s0,s4,ffffffffc0203038 <pmm_init+0xaac>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202920:	00005517          	auipc	a0,0x5
ffffffffc0202924:	10850513          	addi	a0,a0,264 # ffffffffc0207a28 <etext+0x116e>
ffffffffc0202928:	869fd0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc020292c:	100027f3          	csrr	a5,sstatus
ffffffffc0202930:	8b89                	andi	a5,a5,2
ffffffffc0202932:	20079d63          	bnez	a5,ffffffffc0202b4c <pmm_init+0x5c0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202936:	000bb783          	ld	a5,0(s7)
ffffffffc020293a:	779c                	ld	a5,40(a5)
ffffffffc020293c:	9782                	jalr	a5
ffffffffc020293e:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202940:	6098                	ld	a4,0(s1)
ffffffffc0202942:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202946:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202948:	00c71793          	slli	a5,a4,0xc
ffffffffc020294c:	6a85                	lui	s5,0x1
ffffffffc020294e:	02f47c63          	bgeu	s0,a5,ffffffffc0202986 <pmm_init+0x3fa>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202952:	00c45793          	srli	a5,s0,0xc
ffffffffc0202956:	00093503          	ld	a0,0(s2)
ffffffffc020295a:	2ee7f363          	bgeu	a5,a4,ffffffffc0202c40 <pmm_init+0x6b4>
ffffffffc020295e:	0009b583          	ld	a1,0(s3)
ffffffffc0202962:	4601                	li	a2,0
ffffffffc0202964:	95a2                	add	a1,a1,s0
ffffffffc0202966:	ca6ff0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc020296a:	2a050b63          	beqz	a0,ffffffffc0202c20 <pmm_init+0x694>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020296e:	611c                	ld	a5,0(a0)
ffffffffc0202970:	078a                	slli	a5,a5,0x2
ffffffffc0202972:	0147f7b3          	and	a5,a5,s4
ffffffffc0202976:	28879563          	bne	a5,s0,ffffffffc0202c00 <pmm_init+0x674>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020297a:	6098                	ld	a4,0(s1)
ffffffffc020297c:	9456                	add	s0,s0,s5
ffffffffc020297e:	00c71793          	slli	a5,a4,0xc
ffffffffc0202982:	fcf468e3          	bltu	s0,a5,ffffffffc0202952 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202986:	00093783          	ld	a5,0(s2)
ffffffffc020298a:	639c                	ld	a5,0(a5)
ffffffffc020298c:	68079663          	bnez	a5,ffffffffc0203018 <pmm_init+0xa8c>

    struct Page *p;
    p = alloc_page();
ffffffffc0202990:	4505                	li	a0,1
ffffffffc0202992:	b78ff0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0202996:	842a                	mv	s0,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202998:	00093503          	ld	a0,0(s2)
ffffffffc020299c:	85a2                	mv	a1,s0
ffffffffc020299e:	4699                	li	a3,6
ffffffffc02029a0:	10000613          	li	a2,256
ffffffffc02029a4:	af7ff0ef          	jal	ffffffffc020249a <page_insert>
ffffffffc02029a8:	64051863          	bnez	a0,ffffffffc0202ff8 <pmm_init+0xa6c>
    assert(page_ref(p) == 1);
ffffffffc02029ac:	4018                	lw	a4,0(s0)
ffffffffc02029ae:	4785                	li	a5,1
ffffffffc02029b0:	62f71463          	bne	a4,a5,ffffffffc0202fd8 <pmm_init+0xa4c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02029b4:	00093503          	ld	a0,0(s2)
ffffffffc02029b8:	6605                	lui	a2,0x1
ffffffffc02029ba:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x6f70>
ffffffffc02029be:	4699                	li	a3,6
ffffffffc02029c0:	85a2                	mv	a1,s0
ffffffffc02029c2:	ad9ff0ef          	jal	ffffffffc020249a <page_insert>
ffffffffc02029c6:	46051d63          	bnez	a0,ffffffffc0202e40 <pmm_init+0x8b4>
    assert(page_ref(p) == 2);
ffffffffc02029ca:	4018                	lw	a4,0(s0)
ffffffffc02029cc:	4789                	li	a5,2
ffffffffc02029ce:	74f71163          	bne	a4,a5,ffffffffc0203110 <pmm_init+0xb84>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029d2:	00005597          	auipc	a1,0x5
ffffffffc02029d6:	18e58593          	addi	a1,a1,398 # ffffffffc0207b60 <etext+0x12a6>
ffffffffc02029da:	10000513          	li	a0,256
ffffffffc02029de:	657030ef          	jal	ffffffffc0206834 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029e2:	6585                	lui	a1,0x1
ffffffffc02029e4:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x6f70>
ffffffffc02029e8:	10000513          	li	a0,256
ffffffffc02029ec:	65b030ef          	jal	ffffffffc0206846 <strcmp>
ffffffffc02029f0:	70051063          	bnez	a0,ffffffffc02030f0 <pmm_init+0xb64>
    return page - pages + nbase;
ffffffffc02029f4:	000b3683          	ld	a3,0(s6)
ffffffffc02029f8:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc02029fc:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc02029fe:	40d406b3          	sub	a3,s0,a3
ffffffffc0202a02:	8699                	srai	a3,a3,0x6
ffffffffc0202a04:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202a06:	00c69793          	slli	a5,a3,0xc
ffffffffc0202a0a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a0c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a0e:	52e7f963          	bgeu	a5,a4,ffffffffc0202f40 <pmm_init+0x9b4>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a12:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a16:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a1a:	97b6                	add	a5,a5,a3
ffffffffc0202a1c:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_cow_out_size+0x73258>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a20:	5df030ef          	jal	ffffffffc02067fe <strlen>
ffffffffc0202a24:	6a051663          	bnez	a0,ffffffffc02030d0 <pmm_init+0xb44>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a28:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a2c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a2e:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd59b88>
ffffffffc0202a32:	078a                	slli	a5,a5,0x2
ffffffffc0202a34:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a36:	22e7f263          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a3a:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202a3e:	50e7f163          	bgeu	a5,a4,ffffffffc0202f40 <pmm_init+0x9b4>
ffffffffc0202a42:	0009b783          	ld	a5,0(s3)
ffffffffc0202a46:	00f689b3          	add	s3,a3,a5
ffffffffc0202a4a:	100027f3          	csrr	a5,sstatus
ffffffffc0202a4e:	8b89                	andi	a5,a5,2
ffffffffc0202a50:	18079d63          	bnez	a5,ffffffffc0202bea <pmm_init+0x65e>
        pmm_manager->free_pages(base, n);
ffffffffc0202a54:	000bb783          	ld	a5,0(s7)
ffffffffc0202a58:	8522                	mv	a0,s0
ffffffffc0202a5a:	4585                	li	a1,1
ffffffffc0202a5c:	739c                	ld	a5,32(a5)
ffffffffc0202a5e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a60:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202a64:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a66:	078a                	slli	a5,a5,0x2
ffffffffc0202a68:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a6a:	1ee7f863          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a6e:	000b3503          	ld	a0,0(s6)
ffffffffc0202a72:	fff80737          	lui	a4,0xfff80
ffffffffc0202a76:	97ba                	add	a5,a5,a4
ffffffffc0202a78:	079a                	slli	a5,a5,0x6
ffffffffc0202a7a:	953e                	add	a0,a0,a5
ffffffffc0202a7c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a80:	8b89                	andi	a5,a5,2
ffffffffc0202a82:	14079863          	bnez	a5,ffffffffc0202bd2 <pmm_init+0x646>
ffffffffc0202a86:	000bb783          	ld	a5,0(s7)
ffffffffc0202a8a:	4585                	li	a1,1
ffffffffc0202a8c:	739c                	ld	a5,32(a5)
ffffffffc0202a8e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a90:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a94:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a96:	078a                	slli	a5,a5,0x2
ffffffffc0202a98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a9a:	1ce7f063          	bgeu	a5,a4,ffffffffc0202c5a <pmm_init+0x6ce>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a9e:	000b3503          	ld	a0,0(s6)
ffffffffc0202aa2:	fff80737          	lui	a4,0xfff80
ffffffffc0202aa6:	97ba                	add	a5,a5,a4
ffffffffc0202aa8:	079a                	slli	a5,a5,0x6
ffffffffc0202aaa:	953e                	add	a0,a0,a5
ffffffffc0202aac:	100027f3          	csrr	a5,sstatus
ffffffffc0202ab0:	8b89                	andi	a5,a5,2
ffffffffc0202ab2:	10079463          	bnez	a5,ffffffffc0202bba <pmm_init+0x62e>
ffffffffc0202ab6:	000bb783          	ld	a5,0(s7)
ffffffffc0202aba:	4585                	li	a1,1
ffffffffc0202abc:	739c                	ld	a5,32(a5)
ffffffffc0202abe:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202ac0:	00093783          	ld	a5,0(s2)
ffffffffc0202ac4:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202ac8:	12000073          	sfence.vma
ffffffffc0202acc:	100027f3          	csrr	a5,sstatus
ffffffffc0202ad0:	8b89                	andi	a5,a5,2
ffffffffc0202ad2:	0c079a63          	bnez	a5,ffffffffc0202ba6 <pmm_init+0x61a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ad6:	000bb783          	ld	a5,0(s7)
ffffffffc0202ada:	779c                	ld	a5,40(a5)
ffffffffc0202adc:	9782                	jalr	a5
ffffffffc0202ade:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202ae0:	3c8c1063          	bne	s8,s0,ffffffffc0202ea0 <pmm_init+0x914>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ae4:	00005517          	auipc	a0,0x5
ffffffffc0202ae8:	0f450513          	addi	a0,a0,244 # ffffffffc0207bd8 <etext+0x131e>
ffffffffc0202aec:	ea4fd0ef          	jal	ffffffffc0200190 <cprintf>
}
ffffffffc0202af0:	6446                	ld	s0,80(sp)
ffffffffc0202af2:	60e6                	ld	ra,88(sp)
ffffffffc0202af4:	64a6                	ld	s1,72(sp)
ffffffffc0202af6:	6906                	ld	s2,64(sp)
ffffffffc0202af8:	79e2                	ld	s3,56(sp)
ffffffffc0202afa:	7a42                	ld	s4,48(sp)
ffffffffc0202afc:	7aa2                	ld	s5,40(sp)
ffffffffc0202afe:	7b02                	ld	s6,32(sp)
ffffffffc0202b00:	6be2                	ld	s7,24(sp)
ffffffffc0202b02:	6c42                	ld	s8,16(sp)
ffffffffc0202b04:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202b06:	80aff06f          	j	ffffffffc0201b10 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202b0a:	6785                	lui	a5,0x1
ffffffffc0202b0c:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7071>
ffffffffc0202b0e:	96be                	add	a3,a3,a5
ffffffffc0202b10:	77fd                	lui	a5,0xfffff
ffffffffc0202b12:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202b14:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202b18:	14a6f163          	bgeu	a3,a0,ffffffffc0202c5a <pmm_init+0x6ce>
    pmm_manager->init_memmap(base, n);
ffffffffc0202b1c:	000bb583          	ld	a1,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202b20:	96c2                	add	a3,a3,a6
ffffffffc0202b22:	00669513          	slli	a0,a3,0x6
ffffffffc0202b26:	6994                	ld	a3,16(a1)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202b28:	8f1d                	sub	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202b2a:	00c75593          	srli	a1,a4,0xc
ffffffffc0202b2e:	9532                	add	a0,a0,a2
ffffffffc0202b30:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b32:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b36:	be15                	j	ffffffffc020266a <pmm_init+0xde>
        intr_disable();
ffffffffc0202b38:	b09fd0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b3c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b40:	779c                	ld	a5,40(a5)
ffffffffc0202b42:	9782                	jalr	a5
ffffffffc0202b44:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b46:	af5fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b4a:	bebd                	j	ffffffffc02026c8 <pmm_init+0x13c>
        intr_disable();
ffffffffc0202b4c:	af5fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202b50:	000bb783          	ld	a5,0(s7)
ffffffffc0202b54:	779c                	ld	a5,40(a5)
ffffffffc0202b56:	9782                	jalr	a5
ffffffffc0202b58:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b5a:	ae1fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b5e:	b3cd                	j	ffffffffc0202940 <pmm_init+0x3b4>
        intr_disable();
ffffffffc0202b60:	ae1fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202b64:	000bb783          	ld	a5,0(s7)
ffffffffc0202b68:	779c                	ld	a5,40(a5)
ffffffffc0202b6a:	9782                	jalr	a5
ffffffffc0202b6c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b6e:	acdfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b72:	b36d                	j	ffffffffc020291c <pmm_init+0x390>
ffffffffc0202b74:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202b76:	acbfd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b7a:	000bb783          	ld	a5,0(s7)
ffffffffc0202b7e:	6502                	ld	a0,0(sp)
ffffffffc0202b80:	4585                	li	a1,1
ffffffffc0202b82:	739c                	ld	a5,32(a5)
ffffffffc0202b84:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b86:	ab5fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202b8a:	bb8d                	j	ffffffffc02028fc <pmm_init+0x370>
ffffffffc0202b8c:	e42e                	sd	a1,8(sp)
ffffffffc0202b8e:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202b90:	ab1fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202b94:	000bb783          	ld	a5,0(s7)
ffffffffc0202b98:	65a2                	ld	a1,8(sp)
ffffffffc0202b9a:	6502                	ld	a0,0(sp)
ffffffffc0202b9c:	739c                	ld	a5,32(a5)
ffffffffc0202b9e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ba0:	a9bfd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202ba4:	b325                	j	ffffffffc02028cc <pmm_init+0x340>
        intr_disable();
ffffffffc0202ba6:	a9bfd0ef          	jal	ffffffffc0200640 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202baa:	000bb783          	ld	a5,0(s7)
ffffffffc0202bae:	779c                	ld	a5,40(a5)
ffffffffc0202bb0:	9782                	jalr	a5
ffffffffc0202bb2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bb4:	a87fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202bb8:	b725                	j	ffffffffc0202ae0 <pmm_init+0x554>
ffffffffc0202bba:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202bbc:	a85fd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202bc0:	000bb783          	ld	a5,0(s7)
ffffffffc0202bc4:	6502                	ld	a0,0(sp)
ffffffffc0202bc6:	4585                	li	a1,1
ffffffffc0202bc8:	739c                	ld	a5,32(a5)
ffffffffc0202bca:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bcc:	a6ffd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202bd0:	bdc5                	j	ffffffffc0202ac0 <pmm_init+0x534>
ffffffffc0202bd2:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202bd4:	a6dfd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202bd8:	000bb783          	ld	a5,0(s7)
ffffffffc0202bdc:	6502                	ld	a0,0(sp)
ffffffffc0202bde:	4585                	li	a1,1
ffffffffc0202be0:	739c                	ld	a5,32(a5)
ffffffffc0202be2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202be4:	a57fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202be8:	b565                	j	ffffffffc0202a90 <pmm_init+0x504>
        intr_disable();
ffffffffc0202bea:	a57fd0ef          	jal	ffffffffc0200640 <intr_disable>
ffffffffc0202bee:	000bb783          	ld	a5,0(s7)
ffffffffc0202bf2:	8522                	mv	a0,s0
ffffffffc0202bf4:	4585                	li	a1,1
ffffffffc0202bf6:	739c                	ld	a5,32(a5)
ffffffffc0202bf8:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bfa:	a41fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0202bfe:	b58d                	j	ffffffffc0202a60 <pmm_init+0x4d4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c00:	00005697          	auipc	a3,0x5
ffffffffc0202c04:	e8868693          	addi	a3,a3,-376 # ffffffffc0207a88 <etext+0x11ce>
ffffffffc0202c08:	00004617          	auipc	a2,0x4
ffffffffc0202c0c:	33060613          	addi	a2,a2,816 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202c10:	23100593          	li	a1,561
ffffffffc0202c14:	00005517          	auipc	a0,0x5
ffffffffc0202c18:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202c1c:	855fd0ef          	jal	ffffffffc0200470 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c20:	00005697          	auipc	a3,0x5
ffffffffc0202c24:	e2868693          	addi	a3,a3,-472 # ffffffffc0207a48 <etext+0x118e>
ffffffffc0202c28:	00004617          	auipc	a2,0x4
ffffffffc0202c2c:	31060613          	addi	a2,a2,784 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202c30:	23000593          	li	a1,560
ffffffffc0202c34:	00005517          	auipc	a0,0x5
ffffffffc0202c38:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202c3c:	835fd0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0202c40:	86a2                	mv	a3,s0
ffffffffc0202c42:	00005617          	auipc	a2,0x5
ffffffffc0202c46:	91e60613          	addi	a2,a2,-1762 # ffffffffc0207560 <etext+0xca6>
ffffffffc0202c4a:	23000593          	li	a1,560
ffffffffc0202c4e:	00005517          	auipc	a0,0x5
ffffffffc0202c52:	a0250513          	addi	a0,a0,-1534 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202c56:	81bfd0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0202c5a:	894ff0ef          	jal	ffffffffc0201cee <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c5e:	00005617          	auipc	a2,0x5
ffffffffc0202c62:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0207608 <etext+0xd4e>
ffffffffc0202c66:	07f00593          	li	a1,127
ffffffffc0202c6a:	00005517          	auipc	a0,0x5
ffffffffc0202c6e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202c72:	ffefd0ef          	jal	ffffffffc0200470 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c76:	00005617          	auipc	a2,0x5
ffffffffc0202c7a:	99260613          	addi	a2,a2,-1646 # ffffffffc0207608 <etext+0xd4e>
ffffffffc0202c7e:	0c100593          	li	a1,193
ffffffffc0202c82:	00005517          	auipc	a0,0x5
ffffffffc0202c86:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202c8a:	fe6fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c8e:	00005697          	auipc	a3,0x5
ffffffffc0202c92:	aca68693          	addi	a3,a3,-1334 # ffffffffc0207758 <etext+0xe9e>
ffffffffc0202c96:	00004617          	auipc	a2,0x4
ffffffffc0202c9a:	2a260613          	addi	a2,a2,674 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202c9e:	1f400593          	li	a1,500
ffffffffc0202ca2:	00005517          	auipc	a0,0x5
ffffffffc0202ca6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202caa:	fc6fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202cae:	00005697          	auipc	a3,0x5
ffffffffc0202cb2:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0207738 <etext+0xe7e>
ffffffffc0202cb6:	00004617          	auipc	a2,0x4
ffffffffc0202cba:	28260613          	addi	a2,a2,642 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202cbe:	1f300593          	li	a1,499
ffffffffc0202cc2:	00005517          	auipc	a0,0x5
ffffffffc0202cc6:	98e50513          	addi	a0,a0,-1650 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202cca:	fa6fd0ef          	jal	ffffffffc0200470 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202cce:	00005617          	auipc	a2,0x5
ffffffffc0202cd2:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0207818 <etext+0xf5e>
ffffffffc0202cd6:	07400593          	li	a1,116
ffffffffc0202cda:	00005517          	auipc	a0,0x5
ffffffffc0202cde:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0207588 <etext+0xcce>
ffffffffc0202ce2:	f8efd0ef          	jal	ffffffffc0200470 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ce6:	00005697          	auipc	a3,0x5
ffffffffc0202cea:	b0268693          	addi	a3,a3,-1278 # ffffffffc02077e8 <etext+0xf2e>
ffffffffc0202cee:	00004617          	auipc	a2,0x4
ffffffffc0202cf2:	24a60613          	addi	a2,a2,586 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202cf6:	1fc00593          	li	a1,508
ffffffffc0202cfa:	00005517          	auipc	a0,0x5
ffffffffc0202cfe:	95650513          	addi	a0,a0,-1706 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202d02:	f6efd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202d06:	00005697          	auipc	a3,0x5
ffffffffc0202d0a:	ab268693          	addi	a3,a3,-1358 # ffffffffc02077b8 <etext+0xefe>
ffffffffc0202d0e:	00004617          	auipc	a2,0x4
ffffffffc0202d12:	22a60613          	addi	a2,a2,554 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202d16:	1f900593          	li	a1,505
ffffffffc0202d1a:	00005517          	auipc	a0,0x5
ffffffffc0202d1e:	93650513          	addi	a0,a0,-1738 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202d22:	f4efd0ef          	jal	ffffffffc0200470 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202d26:	00005697          	auipc	a3,0x5
ffffffffc0202d2a:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0207790 <etext+0xed6>
ffffffffc0202d2e:	00004617          	auipc	a2,0x4
ffffffffc0202d32:	20a60613          	addi	a2,a2,522 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202d36:	1f500593          	li	a1,501
ffffffffc0202d3a:	00005517          	auipc	a0,0x5
ffffffffc0202d3e:	91650513          	addi	a0,a0,-1770 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202d42:	f2efd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d46:	00005697          	auipc	a3,0x5
ffffffffc0202d4a:	b5268693          	addi	a3,a3,-1198 # ffffffffc0207898 <etext+0xfde>
ffffffffc0202d4e:	00004617          	auipc	a2,0x4
ffffffffc0202d52:	1ea60613          	addi	a2,a2,490 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202d56:	20500593          	li	a1,517
ffffffffc0202d5a:	00005517          	auipc	a0,0x5
ffffffffc0202d5e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202d62:	f0efd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d66:	00005697          	auipc	a3,0x5
ffffffffc0202d6a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0207938 <etext+0x107e>
ffffffffc0202d6e:	00004617          	auipc	a2,0x4
ffffffffc0202d72:	1ca60613          	addi	a2,a2,458 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202d76:	20a00593          	li	a1,522
ffffffffc0202d7a:	00005517          	auipc	a0,0x5
ffffffffc0202d7e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202d82:	eeefd0ef          	jal	ffffffffc0200470 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d86:	00005697          	auipc	a3,0x5
ffffffffc0202d8a:	aea68693          	addi	a3,a3,-1302 # ffffffffc0207870 <etext+0xfb6>
ffffffffc0202d8e:	00004617          	auipc	a2,0x4
ffffffffc0202d92:	1aa60613          	addi	a2,a2,426 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202d96:	20200593          	li	a1,514
ffffffffc0202d9a:	00005517          	auipc	a0,0x5
ffffffffc0202d9e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202da2:	ecefd0ef          	jal	ffffffffc0200470 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202da6:	86d6                	mv	a3,s5
ffffffffc0202da8:	00004617          	auipc	a2,0x4
ffffffffc0202dac:	7b860613          	addi	a2,a2,1976 # ffffffffc0207560 <etext+0xca6>
ffffffffc0202db0:	20100593          	li	a1,513
ffffffffc0202db4:	00005517          	auipc	a0,0x5
ffffffffc0202db8:	89c50513          	addi	a0,a0,-1892 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202dbc:	eb4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202dc0:	00005697          	auipc	a3,0x5
ffffffffc0202dc4:	b1068693          	addi	a3,a3,-1264 # ffffffffc02078d0 <etext+0x1016>
ffffffffc0202dc8:	00004617          	auipc	a2,0x4
ffffffffc0202dcc:	17060613          	addi	a2,a2,368 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202dd0:	20f00593          	li	a1,527
ffffffffc0202dd4:	00005517          	auipc	a0,0x5
ffffffffc0202dd8:	87c50513          	addi	a0,a0,-1924 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202ddc:	e94fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202de0:	00005697          	auipc	a3,0x5
ffffffffc0202de4:	bb868693          	addi	a3,a3,-1096 # ffffffffc0207998 <etext+0x10de>
ffffffffc0202de8:	00004617          	auipc	a2,0x4
ffffffffc0202dec:	15060613          	addi	a2,a2,336 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202df0:	20e00593          	li	a1,526
ffffffffc0202df4:	00005517          	auipc	a0,0x5
ffffffffc0202df8:	85c50513          	addi	a0,a0,-1956 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202dfc:	e74fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202e00:	00005697          	auipc	a3,0x5
ffffffffc0202e04:	b8068693          	addi	a3,a3,-1152 # ffffffffc0207980 <etext+0x10c6>
ffffffffc0202e08:	00004617          	auipc	a2,0x4
ffffffffc0202e0c:	13060613          	addi	a2,a2,304 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202e10:	20d00593          	li	a1,525
ffffffffc0202e14:	00005517          	auipc	a0,0x5
ffffffffc0202e18:	83c50513          	addi	a0,a0,-1988 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202e1c:	e54fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202e20:	00005697          	auipc	a3,0x5
ffffffffc0202e24:	b3068693          	addi	a3,a3,-1232 # ffffffffc0207950 <etext+0x1096>
ffffffffc0202e28:	00004617          	auipc	a2,0x4
ffffffffc0202e2c:	11060613          	addi	a2,a2,272 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202e30:	20c00593          	li	a1,524
ffffffffc0202e34:	00005517          	auipc	a0,0x5
ffffffffc0202e38:	81c50513          	addi	a0,a0,-2020 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202e3c:	e34fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e40:	00005697          	auipc	a3,0x5
ffffffffc0202e44:	cc868693          	addi	a3,a3,-824 # ffffffffc0207b08 <etext+0x124e>
ffffffffc0202e48:	00004617          	auipc	a2,0x4
ffffffffc0202e4c:	0f060613          	addi	a2,a2,240 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202e50:	23b00593          	li	a1,571
ffffffffc0202e54:	00004517          	auipc	a0,0x4
ffffffffc0202e58:	7fc50513          	addi	a0,a0,2044 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202e5c:	e14fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e60:	00005697          	auipc	a3,0x5
ffffffffc0202e64:	ac068693          	addi	a3,a3,-1344 # ffffffffc0207920 <etext+0x1066>
ffffffffc0202e68:	00004617          	auipc	a2,0x4
ffffffffc0202e6c:	0d060613          	addi	a2,a2,208 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202e70:	20900593          	li	a1,521
ffffffffc0202e74:	00004517          	auipc	a0,0x4
ffffffffc0202e78:	7dc50513          	addi	a0,a0,2012 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202e7c:	df4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e80:	00005697          	auipc	a3,0x5
ffffffffc0202e84:	a9068693          	addi	a3,a3,-1392 # ffffffffc0207910 <etext+0x1056>
ffffffffc0202e88:	00004617          	auipc	a2,0x4
ffffffffc0202e8c:	0b060613          	addi	a2,a2,176 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202e90:	20800593          	li	a1,520
ffffffffc0202e94:	00004517          	auipc	a0,0x4
ffffffffc0202e98:	7bc50513          	addi	a0,a0,1980 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202e9c:	dd4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ea0:	00005697          	auipc	a3,0x5
ffffffffc0202ea4:	b6868693          	addi	a3,a3,-1176 # ffffffffc0207a08 <etext+0x114e>
ffffffffc0202ea8:	00004617          	auipc	a2,0x4
ffffffffc0202eac:	09060613          	addi	a2,a2,144 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202eb0:	24c00593          	li	a1,588
ffffffffc0202eb4:	00004517          	auipc	a0,0x4
ffffffffc0202eb8:	79c50513          	addi	a0,a0,1948 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202ebc:	db4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ec0:	00005697          	auipc	a3,0x5
ffffffffc0202ec4:	a4068693          	addi	a3,a3,-1472 # ffffffffc0207900 <etext+0x1046>
ffffffffc0202ec8:	00004617          	auipc	a2,0x4
ffffffffc0202ecc:	07060613          	addi	a2,a2,112 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202ed0:	20700593          	li	a1,519
ffffffffc0202ed4:	00004517          	auipc	a0,0x4
ffffffffc0202ed8:	77c50513          	addi	a0,a0,1916 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202edc:	d94fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ee0:	00005697          	auipc	a3,0x5
ffffffffc0202ee4:	97868693          	addi	a3,a3,-1672 # ffffffffc0207858 <etext+0xf9e>
ffffffffc0202ee8:	00004617          	auipc	a2,0x4
ffffffffc0202eec:	05060613          	addi	a2,a2,80 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202ef0:	21400593          	li	a1,532
ffffffffc0202ef4:	00004517          	auipc	a0,0x4
ffffffffc0202ef8:	75c50513          	addi	a0,a0,1884 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202efc:	d74fd0ef          	jal	ffffffffc0200470 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202f00:	00005697          	auipc	a3,0x5
ffffffffc0202f04:	ab068693          	addi	a3,a3,-1360 # ffffffffc02079b0 <etext+0x10f6>
ffffffffc0202f08:	00004617          	auipc	a2,0x4
ffffffffc0202f0c:	03060613          	addi	a2,a2,48 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202f10:	21100593          	li	a1,529
ffffffffc0202f14:	00004517          	auipc	a0,0x4
ffffffffc0202f18:	73c50513          	addi	a0,a0,1852 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202f1c:	d54fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f20:	00005697          	auipc	a3,0x5
ffffffffc0202f24:	92068693          	addi	a3,a3,-1760 # ffffffffc0207840 <etext+0xf86>
ffffffffc0202f28:	00004617          	auipc	a2,0x4
ffffffffc0202f2c:	01060613          	addi	a2,a2,16 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202f30:	21000593          	li	a1,528
ffffffffc0202f34:	00004517          	auipc	a0,0x4
ffffffffc0202f38:	71c50513          	addi	a0,a0,1820 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202f3c:	d34fd0ef          	jal	ffffffffc0200470 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f40:	00004617          	auipc	a2,0x4
ffffffffc0202f44:	62060613          	addi	a2,a2,1568 # ffffffffc0207560 <etext+0xca6>
ffffffffc0202f48:	06900593          	li	a1,105
ffffffffc0202f4c:	00004517          	auipc	a0,0x4
ffffffffc0202f50:	63c50513          	addi	a0,a0,1596 # ffffffffc0207588 <etext+0xcce>
ffffffffc0202f54:	d1cfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f58:	00005697          	auipc	a3,0x5
ffffffffc0202f5c:	a8868693          	addi	a3,a3,-1400 # ffffffffc02079e0 <etext+0x1126>
ffffffffc0202f60:	00004617          	auipc	a2,0x4
ffffffffc0202f64:	fd860613          	addi	a2,a2,-40 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202f68:	21b00593          	li	a1,539
ffffffffc0202f6c:	00004517          	auipc	a0,0x4
ffffffffc0202f70:	6e450513          	addi	a0,a0,1764 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202f74:	cfcfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f78:	00005697          	auipc	a3,0x5
ffffffffc0202f7c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0207998 <etext+0x10de>
ffffffffc0202f80:	00004617          	auipc	a2,0x4
ffffffffc0202f84:	fb860613          	addi	a2,a2,-72 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202f88:	21900593          	li	a1,537
ffffffffc0202f8c:	00004517          	auipc	a0,0x4
ffffffffc0202f90:	6c450513          	addi	a0,a0,1732 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202f94:	cdcfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f98:	00005697          	auipc	a3,0x5
ffffffffc0202f9c:	a3068693          	addi	a3,a3,-1488 # ffffffffc02079c8 <etext+0x110e>
ffffffffc0202fa0:	00004617          	auipc	a2,0x4
ffffffffc0202fa4:	f9860613          	addi	a2,a2,-104 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202fa8:	21800593          	li	a1,536
ffffffffc0202fac:	00004517          	auipc	a0,0x4
ffffffffc0202fb0:	6a450513          	addi	a0,a0,1700 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202fb4:	cbcfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fb8:	00005697          	auipc	a3,0x5
ffffffffc0202fbc:	9e068693          	addi	a3,a3,-1568 # ffffffffc0207998 <etext+0x10de>
ffffffffc0202fc0:	00004617          	auipc	a2,0x4
ffffffffc0202fc4:	f7860613          	addi	a2,a2,-136 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202fc8:	21500593          	li	a1,533
ffffffffc0202fcc:	00004517          	auipc	a0,0x4
ffffffffc0202fd0:	68450513          	addi	a0,a0,1668 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202fd4:	c9cfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202fd8:	00005697          	auipc	a3,0x5
ffffffffc0202fdc:	b1868693          	addi	a3,a3,-1256 # ffffffffc0207af0 <etext+0x1236>
ffffffffc0202fe0:	00004617          	auipc	a2,0x4
ffffffffc0202fe4:	f5860613          	addi	a2,a2,-168 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0202fe8:	23a00593          	li	a1,570
ffffffffc0202fec:	00004517          	auipc	a0,0x4
ffffffffc0202ff0:	66450513          	addi	a0,a0,1636 # ffffffffc0207650 <etext+0xd96>
ffffffffc0202ff4:	c7cfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202ff8:	00005697          	auipc	a3,0x5
ffffffffc0202ffc:	ac068693          	addi	a3,a3,-1344 # ffffffffc0207ab8 <etext+0x11fe>
ffffffffc0203000:	00004617          	auipc	a2,0x4
ffffffffc0203004:	f3860613          	addi	a2,a2,-200 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203008:	23900593          	li	a1,569
ffffffffc020300c:	00004517          	auipc	a0,0x4
ffffffffc0203010:	64450513          	addi	a0,a0,1604 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203014:	c5cfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203018:	00005697          	auipc	a3,0x5
ffffffffc020301c:	a8868693          	addi	a3,a3,-1400 # ffffffffc0207aa0 <etext+0x11e6>
ffffffffc0203020:	00004617          	auipc	a2,0x4
ffffffffc0203024:	f1860613          	addi	a2,a2,-232 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203028:	23500593          	li	a1,565
ffffffffc020302c:	00004517          	auipc	a0,0x4
ffffffffc0203030:	62450513          	addi	a0,a0,1572 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203034:	c3cfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203038:	00005697          	auipc	a3,0x5
ffffffffc020303c:	9d068693          	addi	a3,a3,-1584 # ffffffffc0207a08 <etext+0x114e>
ffffffffc0203040:	00004617          	auipc	a2,0x4
ffffffffc0203044:	ef860613          	addi	a2,a2,-264 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203048:	22300593          	li	a1,547
ffffffffc020304c:	00004517          	auipc	a0,0x4
ffffffffc0203050:	60450513          	addi	a0,a0,1540 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203054:	c1cfd0ef          	jal	ffffffffc0200470 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203058:	00004697          	auipc	a3,0x4
ffffffffc020305c:	7e868693          	addi	a3,a3,2024 # ffffffffc0207840 <etext+0xf86>
ffffffffc0203060:	00004617          	auipc	a2,0x4
ffffffffc0203064:	ed860613          	addi	a2,a2,-296 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203068:	1fd00593          	li	a1,509
ffffffffc020306c:	00004517          	auipc	a0,0x4
ffffffffc0203070:	5e450513          	addi	a0,a0,1508 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203074:	bfcfd0ef          	jal	ffffffffc0200470 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203078:	00004617          	auipc	a2,0x4
ffffffffc020307c:	4e860613          	addi	a2,a2,1256 # ffffffffc0207560 <etext+0xca6>
ffffffffc0203080:	20000593          	li	a1,512
ffffffffc0203084:	00004517          	auipc	a0,0x4
ffffffffc0203088:	5cc50513          	addi	a0,a0,1484 # ffffffffc0207650 <etext+0xd96>
ffffffffc020308c:	be4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203090:	00004697          	auipc	a3,0x4
ffffffffc0203094:	7c868693          	addi	a3,a3,1992 # ffffffffc0207858 <etext+0xf9e>
ffffffffc0203098:	00004617          	auipc	a2,0x4
ffffffffc020309c:	ea060613          	addi	a2,a2,-352 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02030a0:	1fe00593          	li	a1,510
ffffffffc02030a4:	00004517          	auipc	a0,0x4
ffffffffc02030a8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0207650 <etext+0xd96>
ffffffffc02030ac:	bc4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02030b0:	00005697          	auipc	a3,0x5
ffffffffc02030b4:	82068693          	addi	a3,a3,-2016 # ffffffffc02078d0 <etext+0x1016>
ffffffffc02030b8:	00004617          	auipc	a2,0x4
ffffffffc02030bc:	e8060613          	addi	a2,a2,-384 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02030c0:	20600593          	li	a1,518
ffffffffc02030c4:	00004517          	auipc	a0,0x4
ffffffffc02030c8:	58c50513          	addi	a0,a0,1420 # ffffffffc0207650 <etext+0xd96>
ffffffffc02030cc:	ba4fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02030d0:	00005697          	auipc	a3,0x5
ffffffffc02030d4:	ae068693          	addi	a3,a3,-1312 # ffffffffc0207bb0 <etext+0x12f6>
ffffffffc02030d8:	00004617          	auipc	a2,0x4
ffffffffc02030dc:	e6060613          	addi	a2,a2,-416 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02030e0:	24300593          	li	a1,579
ffffffffc02030e4:	00004517          	auipc	a0,0x4
ffffffffc02030e8:	56c50513          	addi	a0,a0,1388 # ffffffffc0207650 <etext+0xd96>
ffffffffc02030ec:	b84fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030f0:	00005697          	auipc	a3,0x5
ffffffffc02030f4:	a8868693          	addi	a3,a3,-1400 # ffffffffc0207b78 <etext+0x12be>
ffffffffc02030f8:	00004617          	auipc	a2,0x4
ffffffffc02030fc:	e4060613          	addi	a2,a2,-448 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203100:	24000593          	li	a1,576
ffffffffc0203104:	00004517          	auipc	a0,0x4
ffffffffc0203108:	54c50513          	addi	a0,a0,1356 # ffffffffc0207650 <etext+0xd96>
ffffffffc020310c:	b64fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203110:	00005697          	auipc	a3,0x5
ffffffffc0203114:	a3868693          	addi	a3,a3,-1480 # ffffffffc0207b48 <etext+0x128e>
ffffffffc0203118:	00004617          	auipc	a2,0x4
ffffffffc020311c:	e2060613          	addi	a2,a2,-480 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203120:	23c00593          	li	a1,572
ffffffffc0203124:	00004517          	auipc	a0,0x4
ffffffffc0203128:	52c50513          	addi	a0,a0,1324 # ffffffffc0207650 <etext+0xd96>
ffffffffc020312c:	b44fd0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0203130 <copy_range>:
               bool share) {
ffffffffc0203130:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203132:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0203136:	f466                	sd	s9,40(sp)
ffffffffc0203138:	fc86                	sd	ra,120(sp)
ffffffffc020313a:	8cba                	mv	s9,a4
ffffffffc020313c:	f8a2                	sd	s0,112(sp)
ffffffffc020313e:	f4a6                	sd	s1,104(sp)
ffffffffc0203140:	f0ca                	sd	s2,96(sp)
ffffffffc0203142:	ecce                	sd	s3,88(sp)
ffffffffc0203144:	e8d2                	sd	s4,80(sp)
ffffffffc0203146:	e4d6                	sd	s5,72(sp)
ffffffffc0203148:	e0da                	sd	s6,64(sp)
ffffffffc020314a:	fc5e                	sd	s7,56(sp)
ffffffffc020314c:	f862                	sd	s8,48(sp)
ffffffffc020314e:	f06a                	sd	s10,32(sp)
ffffffffc0203150:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203152:	03479713          	slli	a4,a5,0x34
ffffffffc0203156:	20071763          	bnez	a4,ffffffffc0203364 <copy_range+0x234>
    assert(USER_ACCESS(start, end));
ffffffffc020315a:	002007b7          	lui	a5,0x200
ffffffffc020315e:	8432                	mv	s0,a2
ffffffffc0203160:	1ef66263          	bltu	a2,a5,ffffffffc0203344 <copy_range+0x214>
ffffffffc0203164:	89b6                	mv	s3,a3
ffffffffc0203166:	1cd67f63          	bgeu	a2,a3,ffffffffc0203344 <copy_range+0x214>
ffffffffc020316a:	4785                	li	a5,1
ffffffffc020316c:	07fe                	slli	a5,a5,0x1f
ffffffffc020316e:	1cd7eb63          	bltu	a5,a3,ffffffffc0203344 <copy_range+0x214>
ffffffffc0203172:	5c7d                	li	s8,-1
ffffffffc0203174:	8aaa                	mv	s5,a0
ffffffffc0203176:	892e                	mv	s2,a1
ffffffffc0203178:	6a05                	lui	s4,0x1
ffffffffc020317a:	00cc5c13          	srli	s8,s8,0xc
    if (PPN(pa) >= npage) {
ffffffffc020317e:	000a2b97          	auipc	s7,0xa2
ffffffffc0203182:	2a2b8b93          	addi	s7,s7,674 # ffffffffc02a5420 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203186:	000a2b17          	auipc	s6,0xa2
ffffffffc020318a:	2a2b0b13          	addi	s6,s6,674 # ffffffffc02a5428 <pages>
ffffffffc020318e:	fff80d37          	lui	s10,0xfff80
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203192:	4601                	li	a2,0
ffffffffc0203194:	85a2                	mv	a1,s0
ffffffffc0203196:	854a                	mv	a0,s2
ffffffffc0203198:	c75fe0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc020319c:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020319e:	c941                	beqz	a0,ffffffffc020322e <copy_range+0xfe>
        if (*ptep & PTE_V) {
ffffffffc02031a0:	611c                	ld	a5,0(a0)
ffffffffc02031a2:	8b85                	andi	a5,a5,1
ffffffffc02031a4:	e78d                	bnez	a5,ffffffffc02031ce <copy_range+0x9e>
        start += PGSIZE;
ffffffffc02031a6:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02031a8:	c019                	beqz	s0,ffffffffc02031ae <copy_range+0x7e>
ffffffffc02031aa:	ff3464e3          	bltu	s0,s3,ffffffffc0203192 <copy_range+0x62>
    return 0;
ffffffffc02031ae:	4501                	li	a0,0
}
ffffffffc02031b0:	70e6                	ld	ra,120(sp)
ffffffffc02031b2:	7446                	ld	s0,112(sp)
ffffffffc02031b4:	74a6                	ld	s1,104(sp)
ffffffffc02031b6:	7906                	ld	s2,96(sp)
ffffffffc02031b8:	69e6                	ld	s3,88(sp)
ffffffffc02031ba:	6a46                	ld	s4,80(sp)
ffffffffc02031bc:	6aa6                	ld	s5,72(sp)
ffffffffc02031be:	6b06                	ld	s6,64(sp)
ffffffffc02031c0:	7be2                	ld	s7,56(sp)
ffffffffc02031c2:	7c42                	ld	s8,48(sp)
ffffffffc02031c4:	7ca2                	ld	s9,40(sp)
ffffffffc02031c6:	7d02                	ld	s10,32(sp)
ffffffffc02031c8:	6de2                	ld	s11,24(sp)
ffffffffc02031ca:	6109                	addi	sp,sp,128
ffffffffc02031cc:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02031ce:	4605                	li	a2,1
ffffffffc02031d0:	85a2                	mv	a1,s0
ffffffffc02031d2:	8556                	mv	a0,s5
ffffffffc02031d4:	c39fe0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc02031d8:	cd79                	beqz	a0,ffffffffc02032b6 <copy_range+0x186>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031da:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc02031dc:	0017f713          	andi	a4,a5,1
ffffffffc02031e0:	0007849b          	sext.w	s1,a5
ffffffffc02031e4:	14070463          	beqz	a4,ffffffffc020332c <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc02031e8:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031ec:	078a                	slli	a5,a5,0x2
ffffffffc02031ee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031f0:	12e7f263          	bgeu	a5,a4,ffffffffc0203314 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc02031f4:	000b3d83          	ld	s11,0(s6)
ffffffffc02031f8:	97ea                	add	a5,a5,s10
ffffffffc02031fa:	079a                	slli	a5,a5,0x6
            struct Page *npage = alloc_page();
ffffffffc02031fc:	4505                	li	a0,1
ffffffffc02031fe:	9dbe                	add	s11,s11,a5
ffffffffc0203200:	b0bfe0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0203204:	872a                	mv	a4,a0
            assert(page != NULL);
ffffffffc0203206:	0e0d8763          	beqz	s11,ffffffffc02032f4 <copy_range+0x1c4>
            assert(npage != NULL);
ffffffffc020320a:	c569                	beqz	a0,ffffffffc02032d4 <copy_range+0x1a4>
            if(share){
ffffffffc020320c:	020c8863          	beqz	s9,ffffffffc020323c <copy_range+0x10c>
                page_insert(from, page, start, perm & (~PTE_W));
ffffffffc0203210:	88ed                	andi	s1,s1,27
ffffffffc0203212:	8622                	mv	a2,s0
ffffffffc0203214:	86a6                	mv	a3,s1
ffffffffc0203216:	85ee                	mv	a1,s11
ffffffffc0203218:	854a                	mv	a0,s2
ffffffffc020321a:	a80ff0ef          	jal	ffffffffc020249a <page_insert>
                ret = page_insert(to, page, start, perm & (~PTE_W));
ffffffffc020321e:	8622                	mv	a2,s0
ffffffffc0203220:	86a6                	mv	a3,s1
ffffffffc0203222:	85ee                	mv	a1,s11
ffffffffc0203224:	8556                	mv	a0,s5
ffffffffc0203226:	a74ff0ef          	jal	ffffffffc020249a <page_insert>
        start += PGSIZE;
ffffffffc020322a:	9452                	add	s0,s0,s4
ffffffffc020322c:	bfb5                	j	ffffffffc02031a8 <copy_range+0x78>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020322e:	002007b7          	lui	a5,0x200
ffffffffc0203232:	97a2                	add	a5,a5,s0
ffffffffc0203234:	ffe00437          	lui	s0,0xffe00
ffffffffc0203238:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc020323a:	b7bd                	j	ffffffffc02031a8 <copy_range+0x78>
    return page - pages + nbase;
ffffffffc020323c:	000b3783          	ld	a5,0(s6)
ffffffffc0203240:	000805b7          	lui	a1,0x80
    return KADDR(page2pa(page));
ffffffffc0203244:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc0203248:	40fd86b3          	sub	a3,s11,a5
ffffffffc020324c:	8699                	srai	a3,a3,0x6
ffffffffc020324e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0203250:	0186f533          	and	a0,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0203254:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203256:	06c57363          	bgeu	a0,a2,ffffffffc02032bc <copy_range+0x18c>
    return page - pages + nbase;
ffffffffc020325a:	40f707b3          	sub	a5,a4,a5
    return KADDR(page2pa(page));
ffffffffc020325e:	000a2517          	auipc	a0,0xa2
ffffffffc0203262:	1ba53503          	ld	a0,442(a0) # ffffffffc02a5418 <va_pa_offset>
    return page - pages + nbase;
ffffffffc0203266:	8799                	srai	a5,a5,0x6
ffffffffc0203268:	97ae                	add	a5,a5,a1
    return KADDR(page2pa(page));
ffffffffc020326a:	0187f833          	and	a6,a5,s8
ffffffffc020326e:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203272:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203274:	04c87363          	bgeu	a6,a2,ffffffffc02032ba <copy_range+0x18a>
                memcpy((void *)dst_kvaddr, (void *)src_kvaddr, PGSIZE);
ffffffffc0203278:	6605                	lui	a2,0x1
ffffffffc020327a:	953e                	add	a0,a0,a5
ffffffffc020327c:	e43a                	sd	a4,8(sp)
ffffffffc020327e:	624030ef          	jal	ffffffffc02068a2 <memcpy>
                ret = page_insert(to, npage, start, perm);
ffffffffc0203282:	6722                	ld	a4,8(sp)
ffffffffc0203284:	01f4f693          	andi	a3,s1,31
ffffffffc0203288:	8622                	mv	a2,s0
ffffffffc020328a:	85ba                	mv	a1,a4
ffffffffc020328c:	8556                	mv	a0,s5
ffffffffc020328e:	a0cff0ef          	jal	ffffffffc020249a <page_insert>
                assert(ret == 0);
ffffffffc0203292:	f0050ae3          	beqz	a0,ffffffffc02031a6 <copy_range+0x76>
ffffffffc0203296:	00005697          	auipc	a3,0x5
ffffffffc020329a:	98268693          	addi	a3,a3,-1662 # ffffffffc0207c18 <etext+0x135e>
ffffffffc020329e:	00004617          	auipc	a2,0x4
ffffffffc02032a2:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02032a6:	19400593          	li	a1,404
ffffffffc02032aa:	00004517          	auipc	a0,0x4
ffffffffc02032ae:	3a650513          	addi	a0,a0,934 # ffffffffc0207650 <etext+0xd96>
ffffffffc02032b2:	9befd0ef          	jal	ffffffffc0200470 <__panic>
                return -E_NO_MEM;
ffffffffc02032b6:	5571                	li	a0,-4
ffffffffc02032b8:	bde5                	j	ffffffffc02031b0 <copy_range+0x80>
ffffffffc02032ba:	86be                	mv	a3,a5
ffffffffc02032bc:	00004617          	auipc	a2,0x4
ffffffffc02032c0:	2a460613          	addi	a2,a2,676 # ffffffffc0207560 <etext+0xca6>
ffffffffc02032c4:	06900593          	li	a1,105
ffffffffc02032c8:	00004517          	auipc	a0,0x4
ffffffffc02032cc:	2c050513          	addi	a0,a0,704 # ffffffffc0207588 <etext+0xcce>
ffffffffc02032d0:	9a0fd0ef          	jal	ffffffffc0200470 <__panic>
            assert(npage != NULL);
ffffffffc02032d4:	00005697          	auipc	a3,0x5
ffffffffc02032d8:	93468693          	addi	a3,a3,-1740 # ffffffffc0207c08 <etext+0x134e>
ffffffffc02032dc:	00004617          	auipc	a2,0x4
ffffffffc02032e0:	c5c60613          	addi	a2,a2,-932 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02032e4:	17300593          	li	a1,371
ffffffffc02032e8:	00004517          	auipc	a0,0x4
ffffffffc02032ec:	36850513          	addi	a0,a0,872 # ffffffffc0207650 <etext+0xd96>
ffffffffc02032f0:	980fd0ef          	jal	ffffffffc0200470 <__panic>
            assert(page != NULL);
ffffffffc02032f4:	00005697          	auipc	a3,0x5
ffffffffc02032f8:	90468693          	addi	a3,a3,-1788 # ffffffffc0207bf8 <etext+0x133e>
ffffffffc02032fc:	00004617          	auipc	a2,0x4
ffffffffc0203300:	c3c60613          	addi	a2,a2,-964 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203304:	17200593          	li	a1,370
ffffffffc0203308:	00004517          	auipc	a0,0x4
ffffffffc020330c:	34850513          	addi	a0,a0,840 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203310:	960fd0ef          	jal	ffffffffc0200470 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203314:	00004617          	auipc	a2,0x4
ffffffffc0203318:	31c60613          	addi	a2,a2,796 # ffffffffc0207630 <etext+0xd76>
ffffffffc020331c:	06200593          	li	a1,98
ffffffffc0203320:	00004517          	auipc	a0,0x4
ffffffffc0203324:	26850513          	addi	a0,a0,616 # ffffffffc0207588 <etext+0xcce>
ffffffffc0203328:	948fd0ef          	jal	ffffffffc0200470 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020332c:	00004617          	auipc	a2,0x4
ffffffffc0203330:	4ec60613          	addi	a2,a2,1260 # ffffffffc0207818 <etext+0xf5e>
ffffffffc0203334:	07400593          	li	a1,116
ffffffffc0203338:	00004517          	auipc	a0,0x4
ffffffffc020333c:	25050513          	addi	a0,a0,592 # ffffffffc0207588 <etext+0xcce>
ffffffffc0203340:	930fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203344:	00004697          	auipc	a3,0x4
ffffffffc0203348:	34c68693          	addi	a3,a3,844 # ffffffffc0207690 <etext+0xdd6>
ffffffffc020334c:	00004617          	auipc	a2,0x4
ffffffffc0203350:	bec60613          	addi	a2,a2,-1044 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203354:	15e00593          	li	a1,350
ffffffffc0203358:	00004517          	auipc	a0,0x4
ffffffffc020335c:	2f850513          	addi	a0,a0,760 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203360:	910fd0ef          	jal	ffffffffc0200470 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203364:	00004697          	auipc	a3,0x4
ffffffffc0203368:	2fc68693          	addi	a3,a3,764 # ffffffffc0207660 <etext+0xda6>
ffffffffc020336c:	00004617          	auipc	a2,0x4
ffffffffc0203370:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203374:	15d00593          	li	a1,349
ffffffffc0203378:	00004517          	auipc	a0,0x4
ffffffffc020337c:	2d850513          	addi	a0,a0,728 # ffffffffc0207650 <etext+0xd96>
ffffffffc0203380:	8f0fd0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0203384 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203384:	12058073          	sfence.vma	a1
}
ffffffffc0203388:	8082                	ret

ffffffffc020338a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020338a:	7179                	addi	sp,sp,-48
ffffffffc020338c:	e84a                	sd	s2,16(sp)
ffffffffc020338e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203390:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203392:	ec26                	sd	s1,24(sp)
ffffffffc0203394:	e44e                	sd	s3,8(sp)
ffffffffc0203396:	f406                	sd	ra,40(sp)
ffffffffc0203398:	f022                	sd	s0,32(sp)
ffffffffc020339a:	84ae                	mv	s1,a1
ffffffffc020339c:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020339e:	96dfe0ef          	jal	ffffffffc0201d0a <alloc_pages>
    if (page != NULL) {
ffffffffc02033a2:	c92d                	beqz	a0,ffffffffc0203414 <pgdir_alloc_page+0x8a>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02033a4:	842a                	mv	s0,a0
ffffffffc02033a6:	86ce                	mv	a3,s3
ffffffffc02033a8:	854a                	mv	a0,s2
ffffffffc02033aa:	8626                	mv	a2,s1
ffffffffc02033ac:	85a2                	mv	a1,s0
ffffffffc02033ae:	8ecff0ef          	jal	ffffffffc020249a <page_insert>
ffffffffc02033b2:	e529                	bnez	a0,ffffffffc02033fc <pgdir_alloc_page+0x72>
        if (swap_init_ok) {
ffffffffc02033b4:	000a2797          	auipc	a5,0xa2
ffffffffc02033b8:	07c7a783          	lw	a5,124(a5) # ffffffffc02a5430 <swap_init_ok>
ffffffffc02033bc:	cfa9                	beqz	a5,ffffffffc0203416 <pgdir_alloc_page+0x8c>
            if (check_mm_struct != NULL) {
ffffffffc02033be:	000a2517          	auipc	a0,0xa2
ffffffffc02033c2:	09253503          	ld	a0,146(a0) # ffffffffc02a5450 <check_mm_struct>
ffffffffc02033c6:	c921                	beqz	a0,ffffffffc0203416 <pgdir_alloc_page+0x8c>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02033c8:	4681                	li	a3,0
ffffffffc02033ca:	8622                	mv	a2,s0
ffffffffc02033cc:	85a6                	mv	a1,s1
ffffffffc02033ce:	031000ef          	jal	ffffffffc0203bfe <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02033d2:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02033d4:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02033d6:	4785                	li	a5,1
ffffffffc02033d8:	02f70f63          	beq	a4,a5,ffffffffc0203416 <pgdir_alloc_page+0x8c>
ffffffffc02033dc:	00005697          	auipc	a3,0x5
ffffffffc02033e0:	84c68693          	addi	a3,a3,-1972 # ffffffffc0207c28 <etext+0x136e>
ffffffffc02033e4:	00004617          	auipc	a2,0x4
ffffffffc02033e8:	b5460613          	addi	a2,a2,-1196 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02033ec:	1d400593          	li	a1,468
ffffffffc02033f0:	00004517          	auipc	a0,0x4
ffffffffc02033f4:	26050513          	addi	a0,a0,608 # ffffffffc0207650 <etext+0xd96>
ffffffffc02033f8:	878fd0ef          	jal	ffffffffc0200470 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033fc:	100027f3          	csrr	a5,sstatus
ffffffffc0203400:	8b89                	andi	a5,a5,2
ffffffffc0203402:	e395                	bnez	a5,ffffffffc0203426 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0203404:	000a2797          	auipc	a5,0xa2
ffffffffc0203408:	ffc7b783          	ld	a5,-4(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc020340c:	8522                	mv	a0,s0
ffffffffc020340e:	4585                	li	a1,1
ffffffffc0203410:	739c                	ld	a5,32(a5)
ffffffffc0203412:	9782                	jalr	a5
            return NULL;
ffffffffc0203414:	4401                	li	s0,0
}
ffffffffc0203416:	70a2                	ld	ra,40(sp)
ffffffffc0203418:	8522                	mv	a0,s0
ffffffffc020341a:	7402                	ld	s0,32(sp)
ffffffffc020341c:	64e2                	ld	s1,24(sp)
ffffffffc020341e:	6942                	ld	s2,16(sp)
ffffffffc0203420:	69a2                	ld	s3,8(sp)
ffffffffc0203422:	6145                	addi	sp,sp,48
ffffffffc0203424:	8082                	ret
        intr_disable();
ffffffffc0203426:	a1afd0ef          	jal	ffffffffc0200640 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020342a:	000a2797          	auipc	a5,0xa2
ffffffffc020342e:	fd67b783          	ld	a5,-42(a5) # ffffffffc02a5400 <pmm_manager>
ffffffffc0203432:	8522                	mv	a0,s0
ffffffffc0203434:	4585                	li	a1,1
ffffffffc0203436:	739c                	ld	a5,32(a5)
ffffffffc0203438:	9782                	jalr	a5
        intr_enable();
ffffffffc020343a:	a00fd0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020343e:	bfd9                	j	ffffffffc0203414 <pgdir_alloc_page+0x8a>

ffffffffc0203440 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0203440:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0203442:	00004617          	auipc	a2,0x4
ffffffffc0203446:	1ee60613          	addi	a2,a2,494 # ffffffffc0207630 <etext+0xd76>
ffffffffc020344a:	06200593          	li	a1,98
ffffffffc020344e:	00004517          	auipc	a0,0x4
ffffffffc0203452:	13a50513          	addi	a0,a0,314 # ffffffffc0207588 <etext+0xcce>
pa2page(uintptr_t pa) {
ffffffffc0203456:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203458:	818fd0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc020345c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020345c:	7135                	addi	sp,sp,-160
ffffffffc020345e:	ed06                	sd	ra,152(sp)
     swapfs_init();
ffffffffc0203460:	115010ef          	jal	ffffffffc0204d74 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0203464:	000a2697          	auipc	a3,0xa2
ffffffffc0203468:	fd46b683          	ld	a3,-44(a3) # ffffffffc02a5438 <max_swap_offset>
ffffffffc020346c:	010007b7          	lui	a5,0x1000
ffffffffc0203470:	17e1                	addi	a5,a5,-8 # fffff8 <_binary_obj___user_cow_out_size+0xff3150>
ffffffffc0203472:	ff968713          	addi	a4,a3,-7
ffffffffc0203476:	46e7ee63          	bltu	a5,a4,ffffffffc02038f2 <swap_init+0x496>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc020347a:	00097797          	auipc	a5,0x97
ffffffffc020347e:	a4e78793          	addi	a5,a5,-1458 # ffffffffc0299ec8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203482:	6798                	ld	a4,8(a5)
ffffffffc0203484:	e14a                	sd	s2,128(sp)
ffffffffc0203486:	ecde                	sd	s7,88(sp)
     sm = &swap_manager_fifo;
ffffffffc0203488:	000a2b97          	auipc	s7,0xa2
ffffffffc020348c:	fb8b8b93          	addi	s7,s7,-72 # ffffffffc02a5440 <sm>
ffffffffc0203490:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc0203494:	9702                	jalr	a4
ffffffffc0203496:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0203498:	c519                	beqz	a0,ffffffffc02034a6 <swap_init+0x4a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020349a:	60ea                	ld	ra,152(sp)
ffffffffc020349c:	6be6                	ld	s7,88(sp)
ffffffffc020349e:	854a                	mv	a0,s2
ffffffffc02034a0:	690a                	ld	s2,128(sp)
ffffffffc02034a2:	610d                	addi	sp,sp,160
ffffffffc02034a4:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034a6:	000bb703          	ld	a4,0(s7)
          swap_init_ok = 1;
ffffffffc02034aa:	4785                	li	a5,1
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034ac:	00004517          	auipc	a0,0x4
ffffffffc02034b0:	7c450513          	addi	a0,a0,1988 # ffffffffc0207c70 <etext+0x13b6>
ffffffffc02034b4:	630c                	ld	a1,0(a4)
ffffffffc02034b6:	e922                	sd	s0,144(sp)
ffffffffc02034b8:	e0ea                	sd	s10,64(sp)
ffffffffc02034ba:	fc6e                	sd	s11,56(sp)
          swap_init_ok = 1;
ffffffffc02034bc:	000a2717          	auipc	a4,0xa2
ffffffffc02034c0:	f6f72a23          	sw	a5,-140(a4) # ffffffffc02a5430 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034c4:	e526                	sd	s1,136(sp)
ffffffffc02034c6:	fcce                	sd	s3,120(sp)
ffffffffc02034c8:	f8d2                	sd	s4,112(sp)
ffffffffc02034ca:	f4d6                	sd	s5,104(sp)
ffffffffc02034cc:	f0da                	sd	s6,96(sp)
ffffffffc02034ce:	e8e2                	sd	s8,80(sp)
ffffffffc02034d0:	e4e6                	sd	s9,72(sp)
    return listelm->next;
ffffffffc02034d2:	0009e417          	auipc	s0,0x9e
ffffffffc02034d6:	e4640413          	addi	s0,s0,-442 # ffffffffc02a1318 <free_area>
ffffffffc02034da:	cb7fc0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc02034de:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02034e0:	4d01                	li	s10,0
ffffffffc02034e2:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034e4:	38878763          	beq	a5,s0,ffffffffc0203872 <swap_init+0x416>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034e8:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02034ec:	8b09                	andi	a4,a4,2
ffffffffc02034ee:	38070463          	beqz	a4,ffffffffc0203876 <swap_init+0x41a>
        count ++, total += p->property;
ffffffffc02034f2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02034f6:	679c                	ld	a5,8(a5)
ffffffffc02034f8:	2d85                	addiw	s11,s11,1 # 40000001 <_binary_obj___user_cow_out_size+0x3fff3159>
ffffffffc02034fa:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034fe:	fe8795e3          	bne	a5,s0,ffffffffc02034e8 <swap_init+0x8c>
     }
     assert(total == nr_free_pages());
ffffffffc0203502:	84ea                	mv	s1,s10
ffffffffc0203504:	8cffe0ef          	jal	ffffffffc0201dd2 <nr_free_pages>
ffffffffc0203508:	48951963          	bne	a0,s1,ffffffffc020399a <swap_init+0x53e>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020350c:	866a                	mv	a2,s10
ffffffffc020350e:	85ee                	mv	a1,s11
ffffffffc0203510:	00004517          	auipc	a0,0x4
ffffffffc0203514:	77850513          	addi	a0,a0,1912 # ffffffffc0207c88 <etext+0x13ce>
ffffffffc0203518:	c79fc0ef          	jal	ffffffffc0200190 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020351c:	4bf000ef          	jal	ffffffffc02041da <mm_create>
ffffffffc0203520:	e82a                	sd	a0,16(sp)
     assert(mm != NULL);
ffffffffc0203522:	4c050c63          	beqz	a0,ffffffffc02039fa <swap_init+0x59e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203526:	000a2797          	auipc	a5,0xa2
ffffffffc020352a:	f2a78793          	addi	a5,a5,-214 # ffffffffc02a5450 <check_mm_struct>
ffffffffc020352e:	6398                	ld	a4,0(a5)
ffffffffc0203530:	44071563          	bnez	a4,ffffffffc020397a <swap_init+0x51e>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203534:	000a2717          	auipc	a4,0xa2
ffffffffc0203538:	edc70713          	addi	a4,a4,-292 # ffffffffc02a5410 <boot_pgdir>
ffffffffc020353c:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203540:	6742                	ld	a4,16(sp)
ffffffffc0203542:	e398                	sd	a4,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203544:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203548:	01673c23          	sd	s6,24(a4)
     assert(pgdir[0] == 0);
ffffffffc020354c:	48079763          	bnez	a5,ffffffffc02039da <swap_init+0x57e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203550:	6599                	lui	a1,0x6
ffffffffc0203552:	460d                	li	a2,3
ffffffffc0203554:	6505                	lui	a0,0x1
ffffffffc0203556:	4cd000ef          	jal	ffffffffc0204222 <vma_create>
ffffffffc020355a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020355c:	58050b63          	beqz	a0,ffffffffc0203af2 <swap_init+0x696>

     insert_vma_struct(mm, vma);
ffffffffc0203560:	64c2                	ld	s1,16(sp)
ffffffffc0203562:	8526                	mv	a0,s1
ffffffffc0203564:	52d000ef          	jal	ffffffffc0204290 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203568:	00004517          	auipc	a0,0x4
ffffffffc020356c:	79050513          	addi	a0,a0,1936 # ffffffffc0207cf8 <etext+0x143e>
ffffffffc0203570:	c21fc0ef          	jal	ffffffffc0200190 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203574:	6c88                	ld	a0,24(s1)
ffffffffc0203576:	4605                	li	a2,1
ffffffffc0203578:	6585                	lui	a1,0x1
ffffffffc020357a:	893fe0ef          	jal	ffffffffc0201e0c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020357e:	52050a63          	beqz	a0,ffffffffc0203ab2 <swap_init+0x656>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203582:	00004517          	auipc	a0,0x4
ffffffffc0203586:	7c650513          	addi	a0,a0,1990 # ffffffffc0207d48 <etext+0x148e>
ffffffffc020358a:	0009e497          	auipc	s1,0x9e
ffffffffc020358e:	dc648493          	addi	s1,s1,-570 # ffffffffc02a1350 <check_rp>
ffffffffc0203592:	bfffc0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc0203596:	8a26                	mv	s4,s1
ffffffffc0203598:	0009e997          	auipc	s3,0x9e
ffffffffc020359c:	dd898993          	addi	s3,s3,-552 # ffffffffc02a1370 <swap_out_seq_no>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
          check_rp[i] = alloc_page();
ffffffffc02035a0:	4505                	li	a0,1
ffffffffc02035a2:	f68fe0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc02035a6:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_softint_out_size-0x7070>
          assert(check_rp[i] != NULL );
ffffffffc02035aa:	32050463          	beqz	a0,ffffffffc02038d2 <swap_init+0x476>
ffffffffc02035ae:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02035b0:	8b89                	andi	a5,a5,2
ffffffffc02035b2:	3a079463          	bnez	a5,ffffffffc020395a <swap_init+0x4fe>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035b6:	0a21                	addi	s4,s4,8
ffffffffc02035b8:	ff3a14e3          	bne	s4,s3,ffffffffc02035a0 <swap_init+0x144>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02035bc:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02035be:	0009ea17          	auipc	s4,0x9e
ffffffffc02035c2:	d92a0a13          	addi	s4,s4,-622 # ffffffffc02a1350 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02035c6:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02035c8:	f03e                	sd	a5,32(sp)
ffffffffc02035ca:	641c                	ld	a5,8(s0)
ffffffffc02035cc:	e400                	sd	s0,8(s0)
ffffffffc02035ce:	f43e                	sd	a5,40(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02035d0:	0009e797          	auipc	a5,0x9e
ffffffffc02035d4:	d587a783          	lw	a5,-680(a5) # ffffffffc02a1328 <free_area+0x10>
ffffffffc02035d8:	ec3e                	sd	a5,24(sp)
     nr_free = 0;
ffffffffc02035da:	0009e797          	auipc	a5,0x9e
ffffffffc02035de:	d407a723          	sw	zero,-690(a5) # ffffffffc02a1328 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02035e2:	000a3503          	ld	a0,0(s4)
ffffffffc02035e6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035e8:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc02035ea:	fa8fe0ef          	jal	ffffffffc0201d92 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035ee:	ff3a1ae3          	bne	s4,s3,ffffffffc02035e2 <swap_init+0x186>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02035f2:	0009ea17          	auipc	s4,0x9e
ffffffffc02035f6:	d36a2a03          	lw	s4,-714(s4) # ffffffffc02a1328 <free_area+0x10>
ffffffffc02035fa:	4791                	li	a5,4
ffffffffc02035fc:	48fa1b63          	bne	s4,a5,ffffffffc0203a92 <swap_init+0x636>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203600:	00004517          	auipc	a0,0x4
ffffffffc0203604:	7d050513          	addi	a0,a0,2000 # ffffffffc0207dd0 <etext+0x1516>
ffffffffc0203608:	b89fc0ef          	jal	ffffffffc0200190 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020360c:	6785                	lui	a5,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020360e:	000a2717          	auipc	a4,0xa2
ffffffffc0203612:	e2072d23          	sw	zero,-454(a4) # ffffffffc02a5448 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203616:	46a9                	li	a3,10
ffffffffc0203618:	00d78023          	sb	a3,0(a5) # 1000 <_binary_obj___user_softint_out_size-0x7070>
     assert(pgfault_num==1);
ffffffffc020361c:	000a2717          	auipc	a4,0xa2
ffffffffc0203620:	e2c72703          	lw	a4,-468(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203624:	4785                	li	a5,1
ffffffffc0203626:	5af71663          	bne	a4,a5,ffffffffc0203bd2 <swap_init+0x776>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020362a:	6785                	lui	a5,0x1
ffffffffc020362c:	00d78823          	sb	a3,16(a5) # 1010 <_binary_obj___user_softint_out_size-0x7060>
     assert(pgfault_num==1);
ffffffffc0203630:	000a2797          	auipc	a5,0xa2
ffffffffc0203634:	e187a783          	lw	a5,-488(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203638:	42e79d63          	bne	a5,a4,ffffffffc0203a72 <swap_init+0x616>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020363c:	6789                	lui	a5,0x2
ffffffffc020363e:	46ad                	li	a3,11
ffffffffc0203640:	00d78023          	sb	a3,0(a5) # 2000 <_binary_obj___user_softint_out_size-0x6070>
     assert(pgfault_num==2);
ffffffffc0203644:	000a2717          	auipc	a4,0xa2
ffffffffc0203648:	e0472703          	lw	a4,-508(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc020364c:	4789                	li	a5,2
ffffffffc020364e:	50f71263          	bne	a4,a5,ffffffffc0203b52 <swap_init+0x6f6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203652:	6789                	lui	a5,0x2
ffffffffc0203654:	00d78823          	sb	a3,16(a5) # 2010 <_binary_obj___user_softint_out_size-0x6060>
     assert(pgfault_num==2);
ffffffffc0203658:	000a2797          	auipc	a5,0xa2
ffffffffc020365c:	df07a783          	lw	a5,-528(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203660:	50e79963          	bne	a5,a4,ffffffffc0203b72 <swap_init+0x716>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203664:	678d                	lui	a5,0x3
ffffffffc0203666:	46b1                	li	a3,12
ffffffffc0203668:	00d78023          	sb	a3,0(a5) # 3000 <_binary_obj___user_softint_out_size-0x5070>
     assert(pgfault_num==3);
ffffffffc020366c:	000a2717          	auipc	a4,0xa2
ffffffffc0203670:	ddc72703          	lw	a4,-548(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203674:	478d                	li	a5,3
ffffffffc0203676:	50f71e63          	bne	a4,a5,ffffffffc0203b92 <swap_init+0x736>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020367a:	678d                	lui	a5,0x3
ffffffffc020367c:	00d78823          	sb	a3,16(a5) # 3010 <_binary_obj___user_softint_out_size-0x5060>
     assert(pgfault_num==3);
ffffffffc0203680:	000a2797          	auipc	a5,0xa2
ffffffffc0203684:	dc87a783          	lw	a5,-568(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203688:	52e79563          	bne	a5,a4,ffffffffc0203bb2 <swap_init+0x756>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020368c:	6791                	lui	a5,0x4
ffffffffc020368e:	46b5                	li	a3,13
ffffffffc0203690:	00d78023          	sb	a3,0(a5) # 4000 <_binary_obj___user_softint_out_size-0x4070>
     assert(pgfault_num==4);
ffffffffc0203694:	000a2717          	auipc	a4,0xa2
ffffffffc0203698:	db472703          	lw	a4,-588(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc020369c:	47471b63          	bne	a4,s4,ffffffffc0203b12 <swap_init+0x6b6>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02036a0:	6791                	lui	a5,0x4
ffffffffc02036a2:	00d78823          	sb	a3,16(a5) # 4010 <_binary_obj___user_softint_out_size-0x4060>
     assert(pgfault_num==4);
ffffffffc02036a6:	000a2797          	auipc	a5,0xa2
ffffffffc02036aa:	da27a783          	lw	a5,-606(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc02036ae:	48e79263          	bne	a5,a4,ffffffffc0203b32 <swap_init+0x6d6>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02036b2:	0009e797          	auipc	a5,0x9e
ffffffffc02036b6:	c767a783          	lw	a5,-906(a5) # ffffffffc02a1328 <free_area+0x10>
ffffffffc02036ba:	30079063          	bnez	a5,ffffffffc02039ba <swap_init+0x55e>
ffffffffc02036be:	0009e797          	auipc	a5,0x9e
ffffffffc02036c2:	cda78793          	addi	a5,a5,-806 # ffffffffc02a1398 <swap_in_seq_no>
ffffffffc02036c6:	0009e717          	auipc	a4,0x9e
ffffffffc02036ca:	caa70713          	addi	a4,a4,-854 # ffffffffc02a1370 <swap_out_seq_no>
ffffffffc02036ce:	0009e617          	auipc	a2,0x9e
ffffffffc02036d2:	cf260613          	addi	a2,a2,-782 # ffffffffc02a13c0 <pra_list_head>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02036d6:	56fd                	li	a3,-1
ffffffffc02036d8:	c394                	sw	a3,0(a5)
ffffffffc02036da:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02036dc:	0791                	addi	a5,a5,4
ffffffffc02036de:	0711                	addi	a4,a4,4
ffffffffc02036e0:	fec79ce3          	bne	a5,a2,ffffffffc02036d8 <swap_init+0x27c>
ffffffffc02036e4:	6585                	lui	a1,0x1
ffffffffc02036e6:	0009e717          	auipc	a4,0x9e
ffffffffc02036ea:	c4a70713          	addi	a4,a4,-950 # ffffffffc02a1330 <check_ptep>
ffffffffc02036ee:	0009ea97          	auipc	s5,0x9e
ffffffffc02036f2:	c62a8a93          	addi	s5,s5,-926 # ffffffffc02a1350 <check_rp>
    if (PPN(pa) >= npage) {
ffffffffc02036f6:	000a2c97          	auipc	s9,0xa2
ffffffffc02036fa:	d2ac8c93          	addi	s9,s9,-726 # ffffffffc02a5420 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02036fe:	000a2c17          	auipc	s8,0xa2
ffffffffc0203702:	d2ac0c13          	addi	s8,s8,-726 # ffffffffc02a5428 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203706:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020370a:	4601                	li	a2,0
ffffffffc020370c:	855a                	mv	a0,s6
ffffffffc020370e:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0203710:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203712:	efafe0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc0203716:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203718:	65a2                	ld	a1,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020371a:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc020371c:	20050363          	beqz	a0,ffffffffc0203922 <swap_init+0x4c6>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203720:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203722:	0017f613          	andi	a2,a5,1
ffffffffc0203726:	20060e63          	beqz	a2,ffffffffc0203942 <swap_init+0x4e6>
    if (PPN(pa) >= npage) {
ffffffffc020372a:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020372e:	078a                	slli	a5,a5,0x2
ffffffffc0203730:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203732:	16c7f463          	bgeu	a5,a2,ffffffffc020389a <swap_init+0x43e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203736:	00006697          	auipc	a3,0x6
ffffffffc020373a:	87268693          	addi	a3,a3,-1934 # ffffffffc0208fa8 <nbase>
ffffffffc020373e:	0006ba03          	ld	s4,0(a3)
ffffffffc0203742:	000c3603          	ld	a2,0(s8)
ffffffffc0203746:	000ab503          	ld	a0,0(s5)
ffffffffc020374a:	414787b3          	sub	a5,a5,s4
ffffffffc020374e:	079a                	slli	a5,a5,0x6
ffffffffc0203750:	97b2                	add	a5,a5,a2
ffffffffc0203752:	16f51063          	bne	a0,a5,ffffffffc02038b2 <swap_init+0x456>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203756:	6785                	lui	a5,0x1
ffffffffc0203758:	95be                	add	a1,a1,a5
ffffffffc020375a:	6795                	lui	a5,0x5
ffffffffc020375c:	0721                	addi	a4,a4,8
ffffffffc020375e:	0aa1                	addi	s5,s5,8
ffffffffc0203760:	faf593e3          	bne	a1,a5,ffffffffc0203706 <swap_init+0x2aa>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203764:	00004517          	auipc	a0,0x4
ffffffffc0203768:	71450513          	addi	a0,a0,1812 # ffffffffc0207e78 <etext+0x15be>
ffffffffc020376c:	a25fc0ef          	jal	ffffffffc0200190 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203770:	000bb783          	ld	a5,0(s7)
ffffffffc0203774:	7f9c                	ld	a5,56(a5)
ffffffffc0203776:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203778:	34051d63          	bnez	a0,ffffffffc0203ad2 <swap_init+0x676>

     nr_free = nr_free_store;
ffffffffc020377c:	67e2                	ld	a5,24(sp)
ffffffffc020377e:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203780:	7782                	ld	a5,32(sp)
ffffffffc0203782:	e01c                	sd	a5,0(s0)
ffffffffc0203784:	77a2                	ld	a5,40(sp)
ffffffffc0203786:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203788:	6088                	ld	a0,0(s1)
ffffffffc020378a:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020378c:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc020378e:	e04fe0ef          	jal	ffffffffc0201d92 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203792:	ff349be3          	bne	s1,s3,ffffffffc0203788 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203796:	67c2                	ld	a5,16(sp)
ffffffffc0203798:	0007bc23          	sd	zero,24(a5) # 5018 <_binary_obj___user_softint_out_size-0x3058>
     mm_destroy(mm);
ffffffffc020379c:	853e                	mv	a0,a5
ffffffffc020379e:	3c3000ef          	jal	ffffffffc0204360 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02037a2:	000a2797          	auipc	a5,0xa2
ffffffffc02037a6:	c6e78793          	addi	a5,a5,-914 # ffffffffc02a5410 <boot_pgdir>
ffffffffc02037aa:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02037ac:	000cb703          	ld	a4,0(s9)
     check_mm_struct = NULL;
ffffffffc02037b0:	000a2697          	auipc	a3,0xa2
ffffffffc02037b4:	ca06b023          	sd	zero,-864(a3) # ffffffffc02a5450 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037b8:	639c                	ld	a5,0(a5)
ffffffffc02037ba:	078a                	slli	a5,a5,0x2
ffffffffc02037bc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037be:	0ce7fc63          	bgeu	a5,a4,ffffffffc0203896 <swap_init+0x43a>
    return &pages[PPN(pa) - nbase];
ffffffffc02037c2:	414786b3          	sub	a3,a5,s4
ffffffffc02037c6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02037c8:	8699                	srai	a3,a3,0x6
ffffffffc02037ca:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02037cc:	00c69793          	slli	a5,a3,0xc
ffffffffc02037d0:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02037d2:	000c3503          	ld	a0,0(s8)
    return page2ppn(page) << PGSHIFT;
ffffffffc02037d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02037d8:	26e7f163          	bgeu	a5,a4,ffffffffc0203a3a <swap_init+0x5de>
     free_page(pde2page(pd0[0]));
ffffffffc02037dc:	000a2797          	auipc	a5,0xa2
ffffffffc02037e0:	c3c7b783          	ld	a5,-964(a5) # ffffffffc02a5418 <va_pa_offset>
ffffffffc02037e4:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02037e6:	639c                	ld	a5,0(a5)
ffffffffc02037e8:	078a                	slli	a5,a5,0x2
ffffffffc02037ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037ec:	0ae7f563          	bgeu	a5,a4,ffffffffc0203896 <swap_init+0x43a>
    return &pages[PPN(pa) - nbase];
ffffffffc02037f0:	414787b3          	sub	a5,a5,s4
ffffffffc02037f4:	079a                	slli	a5,a5,0x6
ffffffffc02037f6:	953e                	add	a0,a0,a5
ffffffffc02037f8:	4585                	li	a1,1
ffffffffc02037fa:	d98fe0ef          	jal	ffffffffc0201d92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037fe:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203802:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203806:	078a                	slli	a5,a5,0x2
ffffffffc0203808:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020380a:	08e7f663          	bgeu	a5,a4,ffffffffc0203896 <swap_init+0x43a>
    return &pages[PPN(pa) - nbase];
ffffffffc020380e:	000c3503          	ld	a0,0(s8)
ffffffffc0203812:	414787b3          	sub	a5,a5,s4
ffffffffc0203816:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203818:	953e                	add	a0,a0,a5
ffffffffc020381a:	4585                	li	a1,1
ffffffffc020381c:	d76fe0ef          	jal	ffffffffc0201d92 <free_pages>
     pgdir[0] = 0;
ffffffffc0203820:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203824:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203828:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020382a:	00878a63          	beq	a5,s0,ffffffffc020383e <swap_init+0x3e2>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020382e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203832:	679c                	ld	a5,8(a5)
ffffffffc0203834:	3dfd                	addiw	s11,s11,-1
ffffffffc0203836:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020383a:	fe879ae3          	bne	a5,s0,ffffffffc020382e <swap_init+0x3d2>
     }
     assert(count==0);
ffffffffc020383e:	200d9a63          	bnez	s11,ffffffffc0203a52 <swap_init+0x5f6>
     assert(total==0);
ffffffffc0203842:	1c0d1c63          	bnez	s10,ffffffffc0203a1a <swap_init+0x5be>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203846:	00004517          	auipc	a0,0x4
ffffffffc020384a:	68250513          	addi	a0,a0,1666 # ffffffffc0207ec8 <etext+0x160e>
ffffffffc020384e:	943fc0ef          	jal	ffffffffc0200190 <cprintf>
}
ffffffffc0203852:	60ea                	ld	ra,152(sp)
     cprintf("check_swap() succeeded!\n");
ffffffffc0203854:	644a                	ld	s0,144(sp)
ffffffffc0203856:	64aa                	ld	s1,136(sp)
ffffffffc0203858:	79e6                	ld	s3,120(sp)
ffffffffc020385a:	7a46                	ld	s4,112(sp)
ffffffffc020385c:	7aa6                	ld	s5,104(sp)
ffffffffc020385e:	7b06                	ld	s6,96(sp)
ffffffffc0203860:	6c46                	ld	s8,80(sp)
ffffffffc0203862:	6ca6                	ld	s9,72(sp)
ffffffffc0203864:	6d06                	ld	s10,64(sp)
ffffffffc0203866:	7de2                	ld	s11,56(sp)
}
ffffffffc0203868:	6be6                	ld	s7,88(sp)
ffffffffc020386a:	854a                	mv	a0,s2
ffffffffc020386c:	690a                	ld	s2,128(sp)
ffffffffc020386e:	610d                	addi	sp,sp,160
ffffffffc0203870:	8082                	ret
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203872:	4481                	li	s1,0
ffffffffc0203874:	b941                	j	ffffffffc0203504 <swap_init+0xa8>
        assert(PageProperty(p));
ffffffffc0203876:	00004697          	auipc	a3,0x4
ffffffffc020387a:	94268693          	addi	a3,a3,-1726 # ffffffffc02071b8 <etext+0x8fe>
ffffffffc020387e:	00003617          	auipc	a2,0x3
ffffffffc0203882:	6ba60613          	addi	a2,a2,1722 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203886:	0bc00593          	li	a1,188
ffffffffc020388a:	00004517          	auipc	a0,0x4
ffffffffc020388e:	3d650513          	addi	a0,a0,982 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203892:	bdffc0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0203896:	babff0ef          	jal	ffffffffc0203440 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020389a:	00004617          	auipc	a2,0x4
ffffffffc020389e:	d9660613          	addi	a2,a2,-618 # ffffffffc0207630 <etext+0xd76>
ffffffffc02038a2:	06200593          	li	a1,98
ffffffffc02038a6:	00004517          	auipc	a0,0x4
ffffffffc02038aa:	ce250513          	addi	a0,a0,-798 # ffffffffc0207588 <etext+0xcce>
ffffffffc02038ae:	bc3fc0ef          	jal	ffffffffc0200470 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02038b2:	00004697          	auipc	a3,0x4
ffffffffc02038b6:	59e68693          	addi	a3,a3,1438 # ffffffffc0207e50 <etext+0x1596>
ffffffffc02038ba:	00003617          	auipc	a2,0x3
ffffffffc02038be:	67e60613          	addi	a2,a2,1662 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02038c2:	0fc00593          	li	a1,252
ffffffffc02038c6:	00004517          	auipc	a0,0x4
ffffffffc02038ca:	39a50513          	addi	a0,a0,922 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc02038ce:	ba3fc0ef          	jal	ffffffffc0200470 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02038d2:	00004697          	auipc	a3,0x4
ffffffffc02038d6:	49e68693          	addi	a3,a3,1182 # ffffffffc0207d70 <etext+0x14b6>
ffffffffc02038da:	00003617          	auipc	a2,0x3
ffffffffc02038de:	65e60613          	addi	a2,a2,1630 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02038e2:	0dc00593          	li	a1,220
ffffffffc02038e6:	00004517          	auipc	a0,0x4
ffffffffc02038ea:	37a50513          	addi	a0,a0,890 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc02038ee:	b83fc0ef          	jal	ffffffffc0200470 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02038f2:	00004617          	auipc	a2,0x4
ffffffffc02038f6:	34e60613          	addi	a2,a2,846 # ffffffffc0207c40 <etext+0x1386>
ffffffffc02038fa:	02800593          	li	a1,40
ffffffffc02038fe:	00004517          	auipc	a0,0x4
ffffffffc0203902:	36250513          	addi	a0,a0,866 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203906:	e922                	sd	s0,144(sp)
ffffffffc0203908:	e526                	sd	s1,136(sp)
ffffffffc020390a:	e14a                	sd	s2,128(sp)
ffffffffc020390c:	fcce                	sd	s3,120(sp)
ffffffffc020390e:	f8d2                	sd	s4,112(sp)
ffffffffc0203910:	f4d6                	sd	s5,104(sp)
ffffffffc0203912:	f0da                	sd	s6,96(sp)
ffffffffc0203914:	ecde                	sd	s7,88(sp)
ffffffffc0203916:	e8e2                	sd	s8,80(sp)
ffffffffc0203918:	e4e6                	sd	s9,72(sp)
ffffffffc020391a:	e0ea                	sd	s10,64(sp)
ffffffffc020391c:	fc6e                	sd	s11,56(sp)
ffffffffc020391e:	b53fc0ef          	jal	ffffffffc0200470 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203922:	00004697          	auipc	a3,0x4
ffffffffc0203926:	51668693          	addi	a3,a3,1302 # ffffffffc0207e38 <etext+0x157e>
ffffffffc020392a:	00003617          	auipc	a2,0x3
ffffffffc020392e:	60e60613          	addi	a2,a2,1550 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203932:	0fb00593          	li	a1,251
ffffffffc0203936:	00004517          	auipc	a0,0x4
ffffffffc020393a:	32a50513          	addi	a0,a0,810 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc020393e:	b33fc0ef          	jal	ffffffffc0200470 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203942:	00004617          	auipc	a2,0x4
ffffffffc0203946:	ed660613          	addi	a2,a2,-298 # ffffffffc0207818 <etext+0xf5e>
ffffffffc020394a:	07400593          	li	a1,116
ffffffffc020394e:	00004517          	auipc	a0,0x4
ffffffffc0203952:	c3a50513          	addi	a0,a0,-966 # ffffffffc0207588 <etext+0xcce>
ffffffffc0203956:	b1bfc0ef          	jal	ffffffffc0200470 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020395a:	00004697          	auipc	a3,0x4
ffffffffc020395e:	42e68693          	addi	a3,a3,1070 # ffffffffc0207d88 <etext+0x14ce>
ffffffffc0203962:	00003617          	auipc	a2,0x3
ffffffffc0203966:	5d660613          	addi	a2,a2,1494 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020396a:	0dd00593          	li	a1,221
ffffffffc020396e:	00004517          	auipc	a0,0x4
ffffffffc0203972:	2f250513          	addi	a0,a0,754 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203976:	afbfc0ef          	jal	ffffffffc0200470 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020397a:	00004697          	auipc	a3,0x4
ffffffffc020397e:	34668693          	addi	a3,a3,838 # ffffffffc0207cc0 <etext+0x1406>
ffffffffc0203982:	00003617          	auipc	a2,0x3
ffffffffc0203986:	5b660613          	addi	a2,a2,1462 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020398a:	0c700593          	li	a1,199
ffffffffc020398e:	00004517          	auipc	a0,0x4
ffffffffc0203992:	2d250513          	addi	a0,a0,722 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203996:	adbfc0ef          	jal	ffffffffc0200470 <__panic>
     assert(total == nr_free_pages());
ffffffffc020399a:	00004697          	auipc	a3,0x4
ffffffffc020399e:	84668693          	addi	a3,a3,-1978 # ffffffffc02071e0 <etext+0x926>
ffffffffc02039a2:	00003617          	auipc	a2,0x3
ffffffffc02039a6:	59660613          	addi	a2,a2,1430 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02039aa:	0bf00593          	li	a1,191
ffffffffc02039ae:	00004517          	auipc	a0,0x4
ffffffffc02039b2:	2b250513          	addi	a0,a0,690 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc02039b6:	abbfc0ef          	jal	ffffffffc0200470 <__panic>
     assert( nr_free == 0);         
ffffffffc02039ba:	00004697          	auipc	a3,0x4
ffffffffc02039be:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0207388 <etext+0xace>
ffffffffc02039c2:	00003617          	auipc	a2,0x3
ffffffffc02039c6:	57660613          	addi	a2,a2,1398 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02039ca:	0f300593          	li	a1,243
ffffffffc02039ce:	00004517          	auipc	a0,0x4
ffffffffc02039d2:	29250513          	addi	a0,a0,658 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc02039d6:	a9bfc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02039da:	00004697          	auipc	a3,0x4
ffffffffc02039de:	2fe68693          	addi	a3,a3,766 # ffffffffc0207cd8 <etext+0x141e>
ffffffffc02039e2:	00003617          	auipc	a2,0x3
ffffffffc02039e6:	55660613          	addi	a2,a2,1366 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02039ea:	0cc00593          	li	a1,204
ffffffffc02039ee:	00004517          	auipc	a0,0x4
ffffffffc02039f2:	27250513          	addi	a0,a0,626 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc02039f6:	a7bfc0ef          	jal	ffffffffc0200470 <__panic>
     assert(mm != NULL);
ffffffffc02039fa:	00004697          	auipc	a3,0x4
ffffffffc02039fe:	2b668693          	addi	a3,a3,694 # ffffffffc0207cb0 <etext+0x13f6>
ffffffffc0203a02:	00003617          	auipc	a2,0x3
ffffffffc0203a06:	53660613          	addi	a2,a2,1334 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203a0a:	0c400593          	li	a1,196
ffffffffc0203a0e:	00004517          	auipc	a0,0x4
ffffffffc0203a12:	25250513          	addi	a0,a0,594 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203a16:	a5bfc0ef          	jal	ffffffffc0200470 <__panic>
     assert(total==0);
ffffffffc0203a1a:	00004697          	auipc	a3,0x4
ffffffffc0203a1e:	49e68693          	addi	a3,a3,1182 # ffffffffc0207eb8 <etext+0x15fe>
ffffffffc0203a22:	00003617          	auipc	a2,0x3
ffffffffc0203a26:	51660613          	addi	a2,a2,1302 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203a2a:	11e00593          	li	a1,286
ffffffffc0203a2e:	00004517          	auipc	a0,0x4
ffffffffc0203a32:	23250513          	addi	a0,a0,562 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203a36:	a3bfc0ef          	jal	ffffffffc0200470 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a3a:	00004617          	auipc	a2,0x4
ffffffffc0203a3e:	b2660613          	addi	a2,a2,-1242 # ffffffffc0207560 <etext+0xca6>
ffffffffc0203a42:	06900593          	li	a1,105
ffffffffc0203a46:	00004517          	auipc	a0,0x4
ffffffffc0203a4a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0207588 <etext+0xcce>
ffffffffc0203a4e:	a23fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(count==0);
ffffffffc0203a52:	00004697          	auipc	a3,0x4
ffffffffc0203a56:	45668693          	addi	a3,a3,1110 # ffffffffc0207ea8 <etext+0x15ee>
ffffffffc0203a5a:	00003617          	auipc	a2,0x3
ffffffffc0203a5e:	4de60613          	addi	a2,a2,1246 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203a62:	11d00593          	li	a1,285
ffffffffc0203a66:	00004517          	auipc	a0,0x4
ffffffffc0203a6a:	1fa50513          	addi	a0,a0,506 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203a6e:	a03fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==1);
ffffffffc0203a72:	00004697          	auipc	a3,0x4
ffffffffc0203a76:	38668693          	addi	a3,a3,902 # ffffffffc0207df8 <etext+0x153e>
ffffffffc0203a7a:	00003617          	auipc	a2,0x3
ffffffffc0203a7e:	4be60613          	addi	a2,a2,1214 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203a82:	09500593          	li	a1,149
ffffffffc0203a86:	00004517          	auipc	a0,0x4
ffffffffc0203a8a:	1da50513          	addi	a0,a0,474 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203a8e:	9e3fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a92:	00004697          	auipc	a3,0x4
ffffffffc0203a96:	31668693          	addi	a3,a3,790 # ffffffffc0207da8 <etext+0x14ee>
ffffffffc0203a9a:	00003617          	auipc	a2,0x3
ffffffffc0203a9e:	49e60613          	addi	a2,a2,1182 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203aa2:	0ea00593          	li	a1,234
ffffffffc0203aa6:	00004517          	auipc	a0,0x4
ffffffffc0203aaa:	1ba50513          	addi	a0,a0,442 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203aae:	9c3fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203ab2:	00004697          	auipc	a3,0x4
ffffffffc0203ab6:	27e68693          	addi	a3,a3,638 # ffffffffc0207d30 <etext+0x1476>
ffffffffc0203aba:	00003617          	auipc	a2,0x3
ffffffffc0203abe:	47e60613          	addi	a2,a2,1150 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203ac2:	0d700593          	li	a1,215
ffffffffc0203ac6:	00004517          	auipc	a0,0x4
ffffffffc0203aca:	19a50513          	addi	a0,a0,410 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203ace:	9a3fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(ret==0);
ffffffffc0203ad2:	00004697          	auipc	a3,0x4
ffffffffc0203ad6:	3ce68693          	addi	a3,a3,974 # ffffffffc0207ea0 <etext+0x15e6>
ffffffffc0203ada:	00003617          	auipc	a2,0x3
ffffffffc0203ade:	45e60613          	addi	a2,a2,1118 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203ae2:	10200593          	li	a1,258
ffffffffc0203ae6:	00004517          	auipc	a0,0x4
ffffffffc0203aea:	17a50513          	addi	a0,a0,378 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203aee:	983fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(vma != NULL);
ffffffffc0203af2:	00004697          	auipc	a3,0x4
ffffffffc0203af6:	1f668693          	addi	a3,a3,502 # ffffffffc0207ce8 <etext+0x142e>
ffffffffc0203afa:	00003617          	auipc	a2,0x3
ffffffffc0203afe:	43e60613          	addi	a2,a2,1086 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203b02:	0cf00593          	li	a1,207
ffffffffc0203b06:	00004517          	auipc	a0,0x4
ffffffffc0203b0a:	15a50513          	addi	a0,a0,346 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203b0e:	963fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==4);
ffffffffc0203b12:	00004697          	auipc	a3,0x4
ffffffffc0203b16:	31668693          	addi	a3,a3,790 # ffffffffc0207e28 <etext+0x156e>
ffffffffc0203b1a:	00003617          	auipc	a2,0x3
ffffffffc0203b1e:	41e60613          	addi	a2,a2,1054 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203b22:	09f00593          	li	a1,159
ffffffffc0203b26:	00004517          	auipc	a0,0x4
ffffffffc0203b2a:	13a50513          	addi	a0,a0,314 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203b2e:	943fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==4);
ffffffffc0203b32:	00004697          	auipc	a3,0x4
ffffffffc0203b36:	2f668693          	addi	a3,a3,758 # ffffffffc0207e28 <etext+0x156e>
ffffffffc0203b3a:	00003617          	auipc	a2,0x3
ffffffffc0203b3e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203b42:	0a100593          	li	a1,161
ffffffffc0203b46:	00004517          	auipc	a0,0x4
ffffffffc0203b4a:	11a50513          	addi	a0,a0,282 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203b4e:	923fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==2);
ffffffffc0203b52:	00004697          	auipc	a3,0x4
ffffffffc0203b56:	2b668693          	addi	a3,a3,694 # ffffffffc0207e08 <etext+0x154e>
ffffffffc0203b5a:	00003617          	auipc	a2,0x3
ffffffffc0203b5e:	3de60613          	addi	a2,a2,990 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203b62:	09700593          	li	a1,151
ffffffffc0203b66:	00004517          	auipc	a0,0x4
ffffffffc0203b6a:	0fa50513          	addi	a0,a0,250 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203b6e:	903fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==2);
ffffffffc0203b72:	00004697          	auipc	a3,0x4
ffffffffc0203b76:	29668693          	addi	a3,a3,662 # ffffffffc0207e08 <etext+0x154e>
ffffffffc0203b7a:	00003617          	auipc	a2,0x3
ffffffffc0203b7e:	3be60613          	addi	a2,a2,958 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203b82:	09900593          	li	a1,153
ffffffffc0203b86:	00004517          	auipc	a0,0x4
ffffffffc0203b8a:	0da50513          	addi	a0,a0,218 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203b8e:	8e3fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==3);
ffffffffc0203b92:	00004697          	auipc	a3,0x4
ffffffffc0203b96:	28668693          	addi	a3,a3,646 # ffffffffc0207e18 <etext+0x155e>
ffffffffc0203b9a:	00003617          	auipc	a2,0x3
ffffffffc0203b9e:	39e60613          	addi	a2,a2,926 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203ba2:	09b00593          	li	a1,155
ffffffffc0203ba6:	00004517          	auipc	a0,0x4
ffffffffc0203baa:	0ba50513          	addi	a0,a0,186 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203bae:	8c3fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==3);
ffffffffc0203bb2:	00004697          	auipc	a3,0x4
ffffffffc0203bb6:	26668693          	addi	a3,a3,614 # ffffffffc0207e18 <etext+0x155e>
ffffffffc0203bba:	00003617          	auipc	a2,0x3
ffffffffc0203bbe:	37e60613          	addi	a2,a2,894 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203bc2:	09d00593          	li	a1,157
ffffffffc0203bc6:	00004517          	auipc	a0,0x4
ffffffffc0203bca:	09a50513          	addi	a0,a0,154 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203bce:	8a3fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(pgfault_num==1);
ffffffffc0203bd2:	00004697          	auipc	a3,0x4
ffffffffc0203bd6:	22668693          	addi	a3,a3,550 # ffffffffc0207df8 <etext+0x153e>
ffffffffc0203bda:	00003617          	auipc	a2,0x3
ffffffffc0203bde:	35e60613          	addi	a2,a2,862 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203be2:	09300593          	li	a1,147
ffffffffc0203be6:	00004517          	auipc	a0,0x4
ffffffffc0203bea:	07a50513          	addi	a0,a0,122 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203bee:	883fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0203bf2 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203bf2:	000a2797          	auipc	a5,0xa2
ffffffffc0203bf6:	84e7b783          	ld	a5,-1970(a5) # ffffffffc02a5440 <sm>
ffffffffc0203bfa:	6b9c                	ld	a5,16(a5)
ffffffffc0203bfc:	8782                	jr	a5

ffffffffc0203bfe <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203bfe:	000a2797          	auipc	a5,0xa2
ffffffffc0203c02:	8427b783          	ld	a5,-1982(a5) # ffffffffc02a5440 <sm>
ffffffffc0203c06:	739c                	ld	a5,32(a5)
ffffffffc0203c08:	8782                	jr	a5

ffffffffc0203c0a <swap_out>:
{
ffffffffc0203c0a:	715d                	addi	sp,sp,-80
ffffffffc0203c0c:	e486                	sd	ra,72(sp)
ffffffffc0203c0e:	e0a2                	sd	s0,64(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203c10:	cdf9                	beqz	a1,ffffffffc0203cee <swap_out+0xe4>
ffffffffc0203c12:	f84a                	sd	s2,48(sp)
ffffffffc0203c14:	f44e                	sd	s3,40(sp)
ffffffffc0203c16:	f052                	sd	s4,32(sp)
ffffffffc0203c18:	ec56                	sd	s5,24(sp)
ffffffffc0203c1a:	fc26                	sd	s1,56(sp)
ffffffffc0203c1c:	e85a                	sd	s6,16(sp)
ffffffffc0203c1e:	8a2e                	mv	s4,a1
ffffffffc0203c20:	892a                	mv	s2,a0
ffffffffc0203c22:	8ab2                	mv	s5,a2
ffffffffc0203c24:	4401                	li	s0,0
ffffffffc0203c26:	000a2997          	auipc	s3,0xa2
ffffffffc0203c2a:	81a98993          	addi	s3,s3,-2022 # ffffffffc02a5440 <sm>
ffffffffc0203c2e:	a83d                	j	ffffffffc0203c6c <swap_out+0x62>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c30:	67a2                	ld	a5,8(sp)
ffffffffc0203c32:	8626                	mv	a2,s1
ffffffffc0203c34:	85a2                	mv	a1,s0
ffffffffc0203c36:	7f94                	ld	a3,56(a5)
ffffffffc0203c38:	00004517          	auipc	a0,0x4
ffffffffc0203c3c:	31050513          	addi	a0,a0,784 # ffffffffc0207f48 <etext+0x168e>
     for (i = 0; i != n; ++ i)
ffffffffc0203c40:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203c42:	82b1                	srli	a3,a3,0xc
ffffffffc0203c44:	0685                	addi	a3,a3,1
ffffffffc0203c46:	d4afc0ef          	jal	ffffffffc0200190 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c4a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203c4c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c4e:	7d1c                	ld	a5,56(a0)
ffffffffc0203c50:	83b1                	srli	a5,a5,0xc
ffffffffc0203c52:	97ae                	add	a5,a5,a1
ffffffffc0203c54:	07a2                	slli	a5,a5,0x8
ffffffffc0203c56:	00fb3023          	sd	a5,0(s6)
                    free_page(page);
ffffffffc0203c5a:	938fe0ef          	jal	ffffffffc0201d92 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203c5e:	01893503          	ld	a0,24(s2)
ffffffffc0203c62:	85a6                	mv	a1,s1
ffffffffc0203c64:	f20ff0ef          	jal	ffffffffc0203384 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c68:	068a0063          	beq	s4,s0,ffffffffc0203cc8 <swap_out+0xbe>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c6c:	0009b783          	ld	a5,0(s3)
ffffffffc0203c70:	8656                	mv	a2,s5
ffffffffc0203c72:	002c                	addi	a1,sp,8
ffffffffc0203c74:	7b9c                	ld	a5,48(a5)
ffffffffc0203c76:	854a                	mv	a0,s2
ffffffffc0203c78:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c7a:	e135                	bnez	a0,ffffffffc0203cde <swap_out+0xd4>
          v=page->pra_vaddr; 
ffffffffc0203c7c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c7e:	01893503          	ld	a0,24(s2)
ffffffffc0203c82:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c84:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c86:	85a6                	mv	a1,s1
ffffffffc0203c88:	984fe0ef          	jal	ffffffffc0201e0c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c8c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c8e:	8b2a                	mv	s6,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c90:	8b85                	andi	a5,a5,1
ffffffffc0203c92:	c3a5                	beqz	a5,ffffffffc0203cf2 <swap_out+0xe8>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203c94:	65a2                	ld	a1,8(sp)
ffffffffc0203c96:	7d9c                	ld	a5,56(a1)
ffffffffc0203c98:	83b1                	srli	a5,a5,0xc
ffffffffc0203c9a:	0785                	addi	a5,a5,1
ffffffffc0203c9c:	00879513          	slli	a0,a5,0x8
ffffffffc0203ca0:	19a010ef          	jal	ffffffffc0204e3a <swapfs_write>
ffffffffc0203ca4:	d551                	beqz	a0,ffffffffc0203c30 <swap_out+0x26>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ca6:	00004517          	auipc	a0,0x4
ffffffffc0203caa:	28a50513          	addi	a0,a0,650 # ffffffffc0207f30 <etext+0x1676>
ffffffffc0203cae:	ce2fc0ef          	jal	ffffffffc0200190 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203cb2:	0009b783          	ld	a5,0(s3)
ffffffffc0203cb6:	6622                	ld	a2,8(sp)
ffffffffc0203cb8:	85a6                	mv	a1,s1
ffffffffc0203cba:	739c                	ld	a5,32(a5)
ffffffffc0203cbc:	854a                	mv	a0,s2
ffffffffc0203cbe:	4681                	li	a3,0
     for (i = 0; i != n; ++ i)
ffffffffc0203cc0:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203cc2:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203cc4:	fa8a14e3          	bne	s4,s0,ffffffffc0203c6c <swap_out+0x62>
ffffffffc0203cc8:	74e2                	ld	s1,56(sp)
ffffffffc0203cca:	7942                	ld	s2,48(sp)
ffffffffc0203ccc:	79a2                	ld	s3,40(sp)
ffffffffc0203cce:	7a02                	ld	s4,32(sp)
ffffffffc0203cd0:	6ae2                	ld	s5,24(sp)
ffffffffc0203cd2:	6b42                	ld	s6,16(sp)
}
ffffffffc0203cd4:	60a6                	ld	ra,72(sp)
ffffffffc0203cd6:	8522                	mv	a0,s0
ffffffffc0203cd8:	6406                	ld	s0,64(sp)
ffffffffc0203cda:	6161                	addi	sp,sp,80
ffffffffc0203cdc:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203cde:	85a2                	mv	a1,s0
ffffffffc0203ce0:	00004517          	auipc	a0,0x4
ffffffffc0203ce4:	20850513          	addi	a0,a0,520 # ffffffffc0207ee8 <etext+0x162e>
ffffffffc0203ce8:	ca8fc0ef          	jal	ffffffffc0200190 <cprintf>
                  break;
ffffffffc0203cec:	bff1                	j	ffffffffc0203cc8 <swap_out+0xbe>
     for (i = 0; i != n; ++ i)
ffffffffc0203cee:	4401                	li	s0,0
ffffffffc0203cf0:	b7d5                	j	ffffffffc0203cd4 <swap_out+0xca>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203cf2:	00004697          	auipc	a3,0x4
ffffffffc0203cf6:	22668693          	addi	a3,a3,550 # ffffffffc0207f18 <etext+0x165e>
ffffffffc0203cfa:	00003617          	auipc	a2,0x3
ffffffffc0203cfe:	23e60613          	addi	a2,a2,574 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203d02:	06800593          	li	a1,104
ffffffffc0203d06:	00004517          	auipc	a0,0x4
ffffffffc0203d0a:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203d0e:	f62fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0203d12 <swap_in>:
{
ffffffffc0203d12:	7179                	addi	sp,sp,-48
ffffffffc0203d14:	e84a                	sd	s2,16(sp)
ffffffffc0203d16:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203d18:	4505                	li	a0,1
{
ffffffffc0203d1a:	ec26                	sd	s1,24(sp)
ffffffffc0203d1c:	e44e                	sd	s3,8(sp)
ffffffffc0203d1e:	f406                	sd	ra,40(sp)
ffffffffc0203d20:	f022                	sd	s0,32(sp)
ffffffffc0203d22:	84ae                	mv	s1,a1
ffffffffc0203d24:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203d26:	fe5fd0ef          	jal	ffffffffc0201d0a <alloc_pages>
     assert(result!=NULL);
ffffffffc0203d2a:	c129                	beqz	a0,ffffffffc0203d6c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d2c:	842a                	mv	s0,a0
ffffffffc0203d2e:	01893503          	ld	a0,24(s2)
ffffffffc0203d32:	4601                	li	a2,0
ffffffffc0203d34:	85a6                	mv	a1,s1
ffffffffc0203d36:	8d6fe0ef          	jal	ffffffffc0201e0c <get_pte>
ffffffffc0203d3a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203d3c:	6108                	ld	a0,0(a0)
ffffffffc0203d3e:	85a2                	mv	a1,s0
ffffffffc0203d40:	06c010ef          	jal	ffffffffc0204dac <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203d44:	00093583          	ld	a1,0(s2)
ffffffffc0203d48:	8626                	mv	a2,s1
ffffffffc0203d4a:	00004517          	auipc	a0,0x4
ffffffffc0203d4e:	24e50513          	addi	a0,a0,590 # ffffffffc0207f98 <etext+0x16de>
ffffffffc0203d52:	81a1                	srli	a1,a1,0x8
ffffffffc0203d54:	c3cfc0ef          	jal	ffffffffc0200190 <cprintf>
}
ffffffffc0203d58:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203d5a:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203d5e:	7402                	ld	s0,32(sp)
ffffffffc0203d60:	64e2                	ld	s1,24(sp)
ffffffffc0203d62:	6942                	ld	s2,16(sp)
ffffffffc0203d64:	69a2                	ld	s3,8(sp)
ffffffffc0203d66:	4501                	li	a0,0
ffffffffc0203d68:	6145                	addi	sp,sp,48
ffffffffc0203d6a:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d6c:	00004697          	auipc	a3,0x4
ffffffffc0203d70:	21c68693          	addi	a3,a3,540 # ffffffffc0207f88 <etext+0x16ce>
ffffffffc0203d74:	00003617          	auipc	a2,0x3
ffffffffc0203d78:	1c460613          	addi	a2,a2,452 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203d7c:	07e00593          	li	a1,126
ffffffffc0203d80:	00004517          	auipc	a0,0x4
ffffffffc0203d84:	ee050513          	addi	a0,a0,-288 # ffffffffc0207c60 <etext+0x13a6>
ffffffffc0203d88:	ee8fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0203d8c <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d8c:	0009d797          	auipc	a5,0x9d
ffffffffc0203d90:	63478793          	addi	a5,a5,1588 # ffffffffc02a13c0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203d94:	f51c                	sd	a5,40(a0)
ffffffffc0203d96:	e79c                	sd	a5,8(a5)
ffffffffc0203d98:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203d9a:	4501                	li	a0,0
ffffffffc0203d9c:	8082                	ret

ffffffffc0203d9e <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203d9e:	4501                	li	a0,0
ffffffffc0203da0:	8082                	ret

ffffffffc0203da2 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203da2:	4501                	li	a0,0
ffffffffc0203da4:	8082                	ret

ffffffffc0203da6 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203da6:	4501                	li	a0,0
ffffffffc0203da8:	8082                	ret

ffffffffc0203daa <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203daa:	715d                	addi	sp,sp,-80
ffffffffc0203dac:	f84a                	sd	s2,48(sp)
ffffffffc0203dae:	f44e                	sd	s3,40(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203db0:	00004517          	auipc	a0,0x4
ffffffffc0203db4:	22850513          	addi	a0,a0,552 # ffffffffc0207fd8 <etext+0x171e>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203db8:	690d                	lui	s2,0x3
ffffffffc0203dba:	49b1                	li	s3,12
_fifo_check_swap(void) {
ffffffffc0203dbc:	e0a2                	sd	s0,64(sp)
ffffffffc0203dbe:	e486                	sd	ra,72(sp)
ffffffffc0203dc0:	fc26                	sd	s1,56(sp)
ffffffffc0203dc2:	f052                	sd	s4,32(sp)
ffffffffc0203dc4:	ec56                	sd	s5,24(sp)
ffffffffc0203dc6:	e85a                	sd	s6,16(sp)
ffffffffc0203dc8:	e45e                	sd	s7,8(sp)
ffffffffc0203dca:	e062                	sd	s8,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dcc:	bc4fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dd0:	01390023          	sb	s3,0(s2) # 3000 <_binary_obj___user_softint_out_size-0x5070>
    assert(pgfault_num==4);
ffffffffc0203dd4:	000a1417          	auipc	s0,0xa1
ffffffffc0203dd8:	67442403          	lw	s0,1652(s0) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203ddc:	4791                	li	a5,4
ffffffffc0203dde:	16f41d63          	bne	s0,a5,ffffffffc0203f58 <_fifo_check_swap+0x1ae>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203de2:	00004517          	auipc	a0,0x4
ffffffffc0203de6:	23650513          	addi	a0,a0,566 # ffffffffc0208018 <etext+0x175e>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203dea:	6a85                	lui	s5,0x1
ffffffffc0203dec:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dee:	ba2fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203df2:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_softint_out_size-0x7070>
    assert(pgfault_num==4);
ffffffffc0203df6:	000a1497          	auipc	s1,0xa1
ffffffffc0203dfa:	6524a483          	lw	s1,1618(s1) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203dfe:	2c849d63          	bne	s1,s0,ffffffffc02040d8 <_fifo_check_swap+0x32e>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e02:	00004517          	auipc	a0,0x4
ffffffffc0203e06:	23e50513          	addi	a0,a0,574 # ffffffffc0208040 <etext+0x1786>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e0a:	6b91                	lui	s7,0x4
ffffffffc0203e0c:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e0e:	b82fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e12:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_softint_out_size-0x4070>
    assert(pgfault_num==4);
ffffffffc0203e16:	000a1a17          	auipc	s4,0xa1
ffffffffc0203e1a:	632a2a03          	lw	s4,1586(s4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203e1e:	289a1d63          	bne	s4,s1,ffffffffc02040b8 <_fifo_check_swap+0x30e>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e22:	00004517          	auipc	a0,0x4
ffffffffc0203e26:	24650513          	addi	a0,a0,582 # ffffffffc0208068 <etext+0x17ae>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e2a:	6409                	lui	s0,0x2
ffffffffc0203e2c:	44ad                	li	s1,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e2e:	b62fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e32:	00940023          	sb	s1,0(s0) # 2000 <_binary_obj___user_softint_out_size-0x6070>
    assert(pgfault_num==4);
ffffffffc0203e36:	000a1797          	auipc	a5,0xa1
ffffffffc0203e3a:	6127a783          	lw	a5,1554(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203e3e:	25479d63          	bne	a5,s4,ffffffffc0204098 <_fifo_check_swap+0x2ee>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e42:	00004517          	auipc	a0,0x4
ffffffffc0203e46:	24e50513          	addi	a0,a0,590 # ffffffffc0208090 <etext+0x17d6>
ffffffffc0203e4a:	b46fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e4e:	6795                	lui	a5,0x5
ffffffffc0203e50:	4739                	li	a4,14
ffffffffc0203e52:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_softint_out_size-0x3070>
    assert(pgfault_num==5);
ffffffffc0203e56:	000a1a17          	auipc	s4,0xa1
ffffffffc0203e5a:	5f2a2a03          	lw	s4,1522(s4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203e5e:	4795                	li	a5,5
ffffffffc0203e60:	20fa1c63          	bne	s4,a5,ffffffffc0204078 <_fifo_check_swap+0x2ce>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e64:	00004517          	auipc	a0,0x4
ffffffffc0203e68:	20450513          	addi	a0,a0,516 # ffffffffc0208068 <etext+0x17ae>
ffffffffc0203e6c:	b24fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e70:	00940023          	sb	s1,0(s0)
    assert(pgfault_num==5);
ffffffffc0203e74:	000a1797          	auipc	a5,0xa1
ffffffffc0203e78:	5d47a783          	lw	a5,1492(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203e7c:	1d479e63          	bne	a5,s4,ffffffffc0204058 <_fifo_check_swap+0x2ae>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e80:	00004517          	auipc	a0,0x4
ffffffffc0203e84:	19850513          	addi	a0,a0,408 # ffffffffc0208018 <etext+0x175e>
ffffffffc0203e88:	b08fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e8c:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e90:	000a1717          	auipc	a4,0xa1
ffffffffc0203e94:	5b872703          	lw	a4,1464(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203e98:	4799                	li	a5,6
ffffffffc0203e9a:	18f71f63          	bne	a4,a5,ffffffffc0204038 <_fifo_check_swap+0x28e>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e9e:	00004517          	auipc	a0,0x4
ffffffffc0203ea2:	1ca50513          	addi	a0,a0,458 # ffffffffc0208068 <etext+0x17ae>
ffffffffc0203ea6:	aeafc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203eaa:	00940023          	sb	s1,0(s0)
    assert(pgfault_num==7);
ffffffffc0203eae:	000a1717          	auipc	a4,0xa1
ffffffffc0203eb2:	59a72703          	lw	a4,1434(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203eb6:	479d                	li	a5,7
ffffffffc0203eb8:	16f71063          	bne	a4,a5,ffffffffc0204018 <_fifo_check_swap+0x26e>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203ebc:	00004517          	auipc	a0,0x4
ffffffffc0203ec0:	11c50513          	addi	a0,a0,284 # ffffffffc0207fd8 <etext+0x171e>
ffffffffc0203ec4:	accfc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ec8:	01390023          	sb	s3,0(s2)
    assert(pgfault_num==8);
ffffffffc0203ecc:	000a1717          	auipc	a4,0xa1
ffffffffc0203ed0:	57c72703          	lw	a4,1404(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203ed4:	47a1                	li	a5,8
ffffffffc0203ed6:	12f71163          	bne	a4,a5,ffffffffc0203ff8 <_fifo_check_swap+0x24e>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203eda:	00004517          	auipc	a0,0x4
ffffffffc0203ede:	16650513          	addi	a0,a0,358 # ffffffffc0208040 <etext+0x1786>
ffffffffc0203ee2:	aaefc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ee6:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203eea:	000a1717          	auipc	a4,0xa1
ffffffffc0203eee:	55e72703          	lw	a4,1374(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203ef2:	47a5                	li	a5,9
ffffffffc0203ef4:	0ef71263          	bne	a4,a5,ffffffffc0203fd8 <_fifo_check_swap+0x22e>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203ef8:	00004517          	auipc	a0,0x4
ffffffffc0203efc:	19850513          	addi	a0,a0,408 # ffffffffc0208090 <etext+0x17d6>
ffffffffc0203f00:	a90fc0ef          	jal	ffffffffc0200190 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203f04:	6795                	lui	a5,0x5
ffffffffc0203f06:	4739                	li	a4,14
ffffffffc0203f08:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_softint_out_size-0x3070>
    assert(pgfault_num==10);
ffffffffc0203f0c:	000a1417          	auipc	s0,0xa1
ffffffffc0203f10:	53c42403          	lw	s0,1340(s0) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203f14:	47a9                	li	a5,10
ffffffffc0203f16:	0af41163          	bne	s0,a5,ffffffffc0203fb8 <_fifo_check_swap+0x20e>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203f1a:	00004517          	auipc	a0,0x4
ffffffffc0203f1e:	0fe50513          	addi	a0,a0,254 # ffffffffc0208018 <etext+0x175e>
ffffffffc0203f22:	a6efc0ef          	jal	ffffffffc0200190 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f26:	6785                	lui	a5,0x1
ffffffffc0203f28:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_softint_out_size-0x7070>
ffffffffc0203f2c:	06879663          	bne	a5,s0,ffffffffc0203f98 <_fifo_check_swap+0x1ee>
    assert(pgfault_num==11);
ffffffffc0203f30:	000a1717          	auipc	a4,0xa1
ffffffffc0203f34:	51872703          	lw	a4,1304(a4) # ffffffffc02a5448 <pgfault_num>
ffffffffc0203f38:	47ad                	li	a5,11
ffffffffc0203f3a:	02f71f63          	bne	a4,a5,ffffffffc0203f78 <_fifo_check_swap+0x1ce>
}
ffffffffc0203f3e:	60a6                	ld	ra,72(sp)
ffffffffc0203f40:	6406                	ld	s0,64(sp)
ffffffffc0203f42:	74e2                	ld	s1,56(sp)
ffffffffc0203f44:	7942                	ld	s2,48(sp)
ffffffffc0203f46:	79a2                	ld	s3,40(sp)
ffffffffc0203f48:	7a02                	ld	s4,32(sp)
ffffffffc0203f4a:	6ae2                	ld	s5,24(sp)
ffffffffc0203f4c:	6b42                	ld	s6,16(sp)
ffffffffc0203f4e:	6ba2                	ld	s7,8(sp)
ffffffffc0203f50:	6c02                	ld	s8,0(sp)
ffffffffc0203f52:	4501                	li	a0,0
ffffffffc0203f54:	6161                	addi	sp,sp,80
ffffffffc0203f56:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203f58:	00004697          	auipc	a3,0x4
ffffffffc0203f5c:	ed068693          	addi	a3,a3,-304 # ffffffffc0207e28 <etext+0x156e>
ffffffffc0203f60:	00003617          	auipc	a2,0x3
ffffffffc0203f64:	fd860613          	addi	a2,a2,-40 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203f68:	05400593          	li	a1,84
ffffffffc0203f6c:	00004517          	auipc	a0,0x4
ffffffffc0203f70:	09450513          	addi	a0,a0,148 # ffffffffc0208000 <etext+0x1746>
ffffffffc0203f74:	cfcfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==11);
ffffffffc0203f78:	00004697          	auipc	a3,0x4
ffffffffc0203f7c:	1c868693          	addi	a3,a3,456 # ffffffffc0208140 <etext+0x1886>
ffffffffc0203f80:	00003617          	auipc	a2,0x3
ffffffffc0203f84:	fb860613          	addi	a2,a2,-72 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203f88:	07600593          	li	a1,118
ffffffffc0203f8c:	00004517          	auipc	a0,0x4
ffffffffc0203f90:	07450513          	addi	a0,a0,116 # ffffffffc0208000 <etext+0x1746>
ffffffffc0203f94:	cdcfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f98:	00004697          	auipc	a3,0x4
ffffffffc0203f9c:	18068693          	addi	a3,a3,384 # ffffffffc0208118 <etext+0x185e>
ffffffffc0203fa0:	00003617          	auipc	a2,0x3
ffffffffc0203fa4:	f9860613          	addi	a2,a2,-104 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203fa8:	07400593          	li	a1,116
ffffffffc0203fac:	00004517          	auipc	a0,0x4
ffffffffc0203fb0:	05450513          	addi	a0,a0,84 # ffffffffc0208000 <etext+0x1746>
ffffffffc0203fb4:	cbcfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==10);
ffffffffc0203fb8:	00004697          	auipc	a3,0x4
ffffffffc0203fbc:	15068693          	addi	a3,a3,336 # ffffffffc0208108 <etext+0x184e>
ffffffffc0203fc0:	00003617          	auipc	a2,0x3
ffffffffc0203fc4:	f7860613          	addi	a2,a2,-136 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203fc8:	07200593          	li	a1,114
ffffffffc0203fcc:	00004517          	auipc	a0,0x4
ffffffffc0203fd0:	03450513          	addi	a0,a0,52 # ffffffffc0208000 <etext+0x1746>
ffffffffc0203fd4:	c9cfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==9);
ffffffffc0203fd8:	00004697          	auipc	a3,0x4
ffffffffc0203fdc:	12068693          	addi	a3,a3,288 # ffffffffc02080f8 <etext+0x183e>
ffffffffc0203fe0:	00003617          	auipc	a2,0x3
ffffffffc0203fe4:	f5860613          	addi	a2,a2,-168 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0203fe8:	06f00593          	li	a1,111
ffffffffc0203fec:	00004517          	auipc	a0,0x4
ffffffffc0203ff0:	01450513          	addi	a0,a0,20 # ffffffffc0208000 <etext+0x1746>
ffffffffc0203ff4:	c7cfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==8);
ffffffffc0203ff8:	00004697          	auipc	a3,0x4
ffffffffc0203ffc:	0f068693          	addi	a3,a3,240 # ffffffffc02080e8 <etext+0x182e>
ffffffffc0204000:	00003617          	auipc	a2,0x3
ffffffffc0204004:	f3860613          	addi	a2,a2,-200 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204008:	06c00593          	li	a1,108
ffffffffc020400c:	00004517          	auipc	a0,0x4
ffffffffc0204010:	ff450513          	addi	a0,a0,-12 # ffffffffc0208000 <etext+0x1746>
ffffffffc0204014:	c5cfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==7);
ffffffffc0204018:	00004697          	auipc	a3,0x4
ffffffffc020401c:	0c068693          	addi	a3,a3,192 # ffffffffc02080d8 <etext+0x181e>
ffffffffc0204020:	00003617          	auipc	a2,0x3
ffffffffc0204024:	f1860613          	addi	a2,a2,-232 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204028:	06900593          	li	a1,105
ffffffffc020402c:	00004517          	auipc	a0,0x4
ffffffffc0204030:	fd450513          	addi	a0,a0,-44 # ffffffffc0208000 <etext+0x1746>
ffffffffc0204034:	c3cfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==6);
ffffffffc0204038:	00004697          	auipc	a3,0x4
ffffffffc020403c:	09068693          	addi	a3,a3,144 # ffffffffc02080c8 <etext+0x180e>
ffffffffc0204040:	00003617          	auipc	a2,0x3
ffffffffc0204044:	ef860613          	addi	a2,a2,-264 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204048:	06600593          	li	a1,102
ffffffffc020404c:	00004517          	auipc	a0,0x4
ffffffffc0204050:	fb450513          	addi	a0,a0,-76 # ffffffffc0208000 <etext+0x1746>
ffffffffc0204054:	c1cfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==5);
ffffffffc0204058:	00004697          	auipc	a3,0x4
ffffffffc020405c:	06068693          	addi	a3,a3,96 # ffffffffc02080b8 <etext+0x17fe>
ffffffffc0204060:	00003617          	auipc	a2,0x3
ffffffffc0204064:	ed860613          	addi	a2,a2,-296 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204068:	06300593          	li	a1,99
ffffffffc020406c:	00004517          	auipc	a0,0x4
ffffffffc0204070:	f9450513          	addi	a0,a0,-108 # ffffffffc0208000 <etext+0x1746>
ffffffffc0204074:	bfcfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==5);
ffffffffc0204078:	00004697          	auipc	a3,0x4
ffffffffc020407c:	04068693          	addi	a3,a3,64 # ffffffffc02080b8 <etext+0x17fe>
ffffffffc0204080:	00003617          	auipc	a2,0x3
ffffffffc0204084:	eb860613          	addi	a2,a2,-328 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204088:	06000593          	li	a1,96
ffffffffc020408c:	00004517          	auipc	a0,0x4
ffffffffc0204090:	f7450513          	addi	a0,a0,-140 # ffffffffc0208000 <etext+0x1746>
ffffffffc0204094:	bdcfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==4);
ffffffffc0204098:	00004697          	auipc	a3,0x4
ffffffffc020409c:	d9068693          	addi	a3,a3,-624 # ffffffffc0207e28 <etext+0x156e>
ffffffffc02040a0:	00003617          	auipc	a2,0x3
ffffffffc02040a4:	e9860613          	addi	a2,a2,-360 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02040a8:	05d00593          	li	a1,93
ffffffffc02040ac:	00004517          	auipc	a0,0x4
ffffffffc02040b0:	f5450513          	addi	a0,a0,-172 # ffffffffc0208000 <etext+0x1746>
ffffffffc02040b4:	bbcfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==4);
ffffffffc02040b8:	00004697          	auipc	a3,0x4
ffffffffc02040bc:	d7068693          	addi	a3,a3,-656 # ffffffffc0207e28 <etext+0x156e>
ffffffffc02040c0:	00003617          	auipc	a2,0x3
ffffffffc02040c4:	e7860613          	addi	a2,a2,-392 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02040c8:	05a00593          	li	a1,90
ffffffffc02040cc:	00004517          	auipc	a0,0x4
ffffffffc02040d0:	f3450513          	addi	a0,a0,-204 # ffffffffc0208000 <etext+0x1746>
ffffffffc02040d4:	b9cfc0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgfault_num==4);
ffffffffc02040d8:	00004697          	auipc	a3,0x4
ffffffffc02040dc:	d5068693          	addi	a3,a3,-688 # ffffffffc0207e28 <etext+0x156e>
ffffffffc02040e0:	00003617          	auipc	a2,0x3
ffffffffc02040e4:	e5860613          	addi	a2,a2,-424 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02040e8:	05700593          	li	a1,87
ffffffffc02040ec:	00004517          	auipc	a0,0x4
ffffffffc02040f0:	f1450513          	addi	a0,a0,-236 # ffffffffc0208000 <etext+0x1746>
ffffffffc02040f4:	b7cfc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02040f8 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040f8:	7518                	ld	a4,40(a0)
{
ffffffffc02040fa:	1141                	addi	sp,sp,-16
ffffffffc02040fc:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc02040fe:	c30d                	beqz	a4,ffffffffc0204120 <_fifo_swap_out_victim+0x28>
     assert(in_tick==0);
ffffffffc0204100:	e221                	bnez	a2,ffffffffc0204140 <_fifo_swap_out_victim+0x48>
    return listelm->prev;
ffffffffc0204102:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0204104:	4681                	li	a3,0
ffffffffc0204106:	00f70863          	beq	a4,a5,ffffffffc0204116 <_fifo_swap_out_victim+0x1e>
    __list_del(listelm->prev, listelm->next);
ffffffffc020410a:	6390                	ld	a2,0(a5)
ffffffffc020410c:	6798                	ld	a4,8(a5)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc020410e:	fd878693          	addi	a3,a5,-40
    prev->next = next;
ffffffffc0204112:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0204114:	e310                	sd	a2,0(a4)
}
ffffffffc0204116:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204118:	e194                	sd	a3,0(a1)
}
ffffffffc020411a:	4501                	li	a0,0
ffffffffc020411c:	0141                	addi	sp,sp,16
ffffffffc020411e:	8082                	ret
         assert(head != NULL);
ffffffffc0204120:	00004697          	auipc	a3,0x4
ffffffffc0204124:	03068693          	addi	a3,a3,48 # ffffffffc0208150 <etext+0x1896>
ffffffffc0204128:	00003617          	auipc	a2,0x3
ffffffffc020412c:	e1060613          	addi	a2,a2,-496 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204130:	04100593          	li	a1,65
ffffffffc0204134:	00004517          	auipc	a0,0x4
ffffffffc0204138:	ecc50513          	addi	a0,a0,-308 # ffffffffc0208000 <etext+0x1746>
ffffffffc020413c:	b34fc0ef          	jal	ffffffffc0200470 <__panic>
     assert(in_tick==0);
ffffffffc0204140:	00004697          	auipc	a3,0x4
ffffffffc0204144:	02068693          	addi	a3,a3,32 # ffffffffc0208160 <etext+0x18a6>
ffffffffc0204148:	00003617          	auipc	a2,0x3
ffffffffc020414c:	df060613          	addi	a2,a2,-528 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204150:	04200593          	li	a1,66
ffffffffc0204154:	00004517          	auipc	a0,0x4
ffffffffc0204158:	eac50513          	addi	a0,a0,-340 # ffffffffc0208000 <etext+0x1746>
ffffffffc020415c:	b14fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204160 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204160:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204162:	cb91                	beqz	a5,ffffffffc0204176 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0204164:	6794                	ld	a3,8(a5)
ffffffffc0204166:	02860713          	addi	a4,a2,40
}
ffffffffc020416a:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020416c:	e298                	sd	a4,0(a3)
ffffffffc020416e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204170:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc0204172:	f61c                	sd	a5,40(a2)
ffffffffc0204174:	8082                	ret
{
ffffffffc0204176:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204178:	00004697          	auipc	a3,0x4
ffffffffc020417c:	ff868693          	addi	a3,a3,-8 # ffffffffc0208170 <etext+0x18b6>
ffffffffc0204180:	00003617          	auipc	a2,0x3
ffffffffc0204184:	db860613          	addi	a2,a2,-584 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204188:	03200593          	li	a1,50
ffffffffc020418c:	00004517          	auipc	a0,0x4
ffffffffc0204190:	e7450513          	addi	a0,a0,-396 # ffffffffc0208000 <etext+0x1746>
{
ffffffffc0204194:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204196:	adafc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc020419a <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020419a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020419c:	00004697          	auipc	a3,0x4
ffffffffc02041a0:	00c68693          	addi	a3,a3,12 # ffffffffc02081a8 <etext+0x18ee>
ffffffffc02041a4:	00003617          	auipc	a2,0x3
ffffffffc02041a8:	d9460613          	addi	a2,a2,-620 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02041ac:	06d00593          	li	a1,109
ffffffffc02041b0:	00004517          	auipc	a0,0x4
ffffffffc02041b4:	01850513          	addi	a0,a0,24 # ffffffffc02081c8 <etext+0x190e>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02041b8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02041ba:	ab6fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02041be <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02041be:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02041c0:	00003617          	auipc	a2,0x3
ffffffffc02041c4:	47060613          	addi	a2,a2,1136 # ffffffffc0207630 <etext+0xd76>
ffffffffc02041c8:	06200593          	li	a1,98
ffffffffc02041cc:	00003517          	auipc	a0,0x3
ffffffffc02041d0:	3bc50513          	addi	a0,a0,956 # ffffffffc0207588 <etext+0xcce>
pa2page(uintptr_t pa) {
ffffffffc02041d4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02041d6:	a9afc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02041da <mm_create>:
mm_create(void) {
ffffffffc02041da:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02041dc:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02041e0:	e022                	sd	s0,0(sp)
ffffffffc02041e2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02041e4:	951fd0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc02041e8:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02041ea:	c505                	beqz	a0,ffffffffc0204212 <mm_create+0x38>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02041ec:	000a1797          	auipc	a5,0xa1
ffffffffc02041f0:	2447a783          	lw	a5,580(a5) # ffffffffc02a5430 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc02041f4:	e408                	sd	a0,8(s0)
ffffffffc02041f6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02041f8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02041fc:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204200:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204204:	ef81                	bnez	a5,ffffffffc020421c <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204206:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020420a:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020420e:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204212:	60a2                	ld	ra,8(sp)
ffffffffc0204214:	8522                	mv	a0,s0
ffffffffc0204216:	6402                	ld	s0,0(sp)
ffffffffc0204218:	0141                	addi	sp,sp,16
ffffffffc020421a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020421c:	9d7ff0ef          	jal	ffffffffc0203bf2 <swap_init_mm>
ffffffffc0204220:	b7ed                	j	ffffffffc020420a <mm_create+0x30>

ffffffffc0204222 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204222:	1101                	addi	sp,sp,-32
ffffffffc0204224:	e04a                	sd	s2,0(sp)
ffffffffc0204226:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204228:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020422c:	e822                	sd	s0,16(sp)
ffffffffc020422e:	e426                	sd	s1,8(sp)
ffffffffc0204230:	ec06                	sd	ra,24(sp)
ffffffffc0204232:	84ae                	mv	s1,a1
ffffffffc0204234:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204236:	8fffd0ef          	jal	ffffffffc0201b34 <kmalloc>
    if (vma != NULL) {
ffffffffc020423a:	c509                	beqz	a0,ffffffffc0204244 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020423c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204240:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204242:	cd00                	sw	s0,24(a0)
}
ffffffffc0204244:	60e2                	ld	ra,24(sp)
ffffffffc0204246:	6442                	ld	s0,16(sp)
ffffffffc0204248:	64a2                	ld	s1,8(sp)
ffffffffc020424a:	6902                	ld	s2,0(sp)
ffffffffc020424c:	6105                	addi	sp,sp,32
ffffffffc020424e:	8082                	ret

ffffffffc0204250 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0204250:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0204252:	c505                	beqz	a0,ffffffffc020427a <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0204254:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204256:	c501                	beqz	a0,ffffffffc020425e <find_vma+0xe>
ffffffffc0204258:	651c                	ld	a5,8(a0)
ffffffffc020425a:	02f5f263          	bgeu	a1,a5,ffffffffc020427e <find_vma+0x2e>
    return listelm->next;
ffffffffc020425e:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0204260:	00f68d63          	beq	a3,a5,ffffffffc020427a <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204264:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204268:	00e5e663          	bltu	a1,a4,ffffffffc0204274 <find_vma+0x24>
ffffffffc020426c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204270:	00e5ec63          	bltu	a1,a4,ffffffffc0204288 <find_vma+0x38>
ffffffffc0204274:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204276:	fef697e3          	bne	a3,a5,ffffffffc0204264 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020427a:	4501                	li	a0,0
}
ffffffffc020427c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020427e:	691c                	ld	a5,16(a0)
ffffffffc0204280:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020425e <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0204284:	ea88                	sd	a0,16(a3)
ffffffffc0204286:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0204288:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020428c:	ea88                	sd	a0,16(a3)
ffffffffc020428e:	8082                	ret

ffffffffc0204290 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204290:	6590                	ld	a2,8(a1)
ffffffffc0204292:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_softint_out_size-0x7060>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204296:	1141                	addi	sp,sp,-16
ffffffffc0204298:	e406                	sd	ra,8(sp)
ffffffffc020429a:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020429c:	01066763          	bltu	a2,a6,ffffffffc02042aa <insert_vma_struct+0x1a>
ffffffffc02042a0:	a085                	j	ffffffffc0204300 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02042a2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02042a6:	04e66863          	bltu	a2,a4,ffffffffc02042f6 <insert_vma_struct+0x66>
ffffffffc02042aa:	86be                	mv	a3,a5
ffffffffc02042ac:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02042ae:	fef51ae3          	bne	a0,a5,ffffffffc02042a2 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02042b2:	02a68463          	beq	a3,a0,ffffffffc02042da <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02042b6:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02042ba:	fe86b883          	ld	a7,-24(a3)
ffffffffc02042be:	08e8f163          	bgeu	a7,a4,ffffffffc0204340 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042c2:	04e66f63          	bltu	a2,a4,ffffffffc0204320 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02042c6:	00f50a63          	beq	a0,a5,ffffffffc02042da <insert_vma_struct+0x4a>
ffffffffc02042ca:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042ce:	05076963          	bltu	a4,a6,ffffffffc0204320 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02042d2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02042d6:	02c77363          	bgeu	a4,a2,ffffffffc02042fc <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02042da:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02042dc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02042de:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02042e2:	e390                	sd	a2,0(a5)
ffffffffc02042e4:	e690                	sd	a2,8(a3)
}
ffffffffc02042e6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02042e8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02042ea:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02042ec:	0017079b          	addiw	a5,a4,1
ffffffffc02042f0:	d11c                	sw	a5,32(a0)
}
ffffffffc02042f2:	0141                	addi	sp,sp,16
ffffffffc02042f4:	8082                	ret
    if (le_prev != list) {
ffffffffc02042f6:	fca690e3          	bne	a3,a0,ffffffffc02042b6 <insert_vma_struct+0x26>
ffffffffc02042fa:	bfd1                	j	ffffffffc02042ce <insert_vma_struct+0x3e>
ffffffffc02042fc:	e9fff0ef          	jal	ffffffffc020419a <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204300:	00004697          	auipc	a3,0x4
ffffffffc0204304:	ed868693          	addi	a3,a3,-296 # ffffffffc02081d8 <etext+0x191e>
ffffffffc0204308:	00003617          	auipc	a2,0x3
ffffffffc020430c:	c3060613          	addi	a2,a2,-976 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204310:	07400593          	li	a1,116
ffffffffc0204314:	00004517          	auipc	a0,0x4
ffffffffc0204318:	eb450513          	addi	a0,a0,-332 # ffffffffc02081c8 <etext+0x190e>
ffffffffc020431c:	954fc0ef          	jal	ffffffffc0200470 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204320:	00004697          	auipc	a3,0x4
ffffffffc0204324:	ef868693          	addi	a3,a3,-264 # ffffffffc0208218 <etext+0x195e>
ffffffffc0204328:	00003617          	auipc	a2,0x3
ffffffffc020432c:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204330:	06c00593          	li	a1,108
ffffffffc0204334:	00004517          	auipc	a0,0x4
ffffffffc0204338:	e9450513          	addi	a0,a0,-364 # ffffffffc02081c8 <etext+0x190e>
ffffffffc020433c:	934fc0ef          	jal	ffffffffc0200470 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204340:	00004697          	auipc	a3,0x4
ffffffffc0204344:	eb868693          	addi	a3,a3,-328 # ffffffffc02081f8 <etext+0x193e>
ffffffffc0204348:	00003617          	auipc	a2,0x3
ffffffffc020434c:	bf060613          	addi	a2,a2,-1040 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204350:	06b00593          	li	a1,107
ffffffffc0204354:	00004517          	auipc	a0,0x4
ffffffffc0204358:	e7450513          	addi	a0,a0,-396 # ffffffffc02081c8 <etext+0x190e>
ffffffffc020435c:	914fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204360 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204360:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204362:	1141                	addi	sp,sp,-16
ffffffffc0204364:	e406                	sd	ra,8(sp)
ffffffffc0204366:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204368:	e78d                	bnez	a5,ffffffffc0204392 <mm_destroy+0x32>
ffffffffc020436a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020436c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020436e:	00a40c63          	beq	s0,a0,ffffffffc0204386 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204372:	6118                	ld	a4,0(a0)
ffffffffc0204374:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204376:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204378:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020437a:	e398                	sd	a4,0(a5)
ffffffffc020437c:	87dfd0ef          	jal	ffffffffc0201bf8 <kfree>
    return listelm->next;
ffffffffc0204380:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204382:	fea418e3          	bne	s0,a0,ffffffffc0204372 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204386:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204388:	6402                	ld	s0,0(sp)
ffffffffc020438a:	60a2                	ld	ra,8(sp)
ffffffffc020438c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020438e:	86bfd06f          	j	ffffffffc0201bf8 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204392:	00004697          	auipc	a3,0x4
ffffffffc0204396:	ea668693          	addi	a3,a3,-346 # ffffffffc0208238 <etext+0x197e>
ffffffffc020439a:	00003617          	auipc	a2,0x3
ffffffffc020439e:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02043a2:	09400593          	li	a1,148
ffffffffc02043a6:	00004517          	auipc	a0,0x4
ffffffffc02043aa:	e2250513          	addi	a0,a0,-478 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02043ae:	8c2fc0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02043b2 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043b2:	6785                	lui	a5,0x1
ffffffffc02043b4:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7071>
       struct vma_struct **vma_store) {
ffffffffc02043b6:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043b8:	963e                	add	a2,a2,a5
ffffffffc02043ba:	77fd                	lui	a5,0xfffff
ffffffffc02043bc:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc02043be:	f822                	sd	s0,48(sp)
ffffffffc02043c0:	f426                	sd	s1,40(sp)
ffffffffc02043c2:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02043c4:	00f5f4b3          	and	s1,a1,a5
    if (!USER_ACCESS(start, end)) {
ffffffffc02043c8:	002005b7          	lui	a1,0x200
ffffffffc02043cc:	00f67433          	and	s0,a2,a5
ffffffffc02043d0:	08b4e363          	bltu	s1,a1,ffffffffc0204456 <mm_map+0xa4>
ffffffffc02043d4:	0884f163          	bgeu	s1,s0,ffffffffc0204456 <mm_map+0xa4>
ffffffffc02043d8:	4785                	li	a5,1
ffffffffc02043da:	07fe                	slli	a5,a5,0x1f
ffffffffc02043dc:	0687ed63          	bltu	a5,s0,ffffffffc0204456 <mm_map+0xa4>
ffffffffc02043e0:	ec4e                	sd	s3,24(sp)
ffffffffc02043e2:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02043e4:	c93d                	beqz	a0,ffffffffc020445a <mm_map+0xa8>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02043e6:	85a6                	mv	a1,s1
ffffffffc02043e8:	e852                	sd	s4,16(sp)
ffffffffc02043ea:	e456                	sd	s5,8(sp)
ffffffffc02043ec:	8a3a                	mv	s4,a4
ffffffffc02043ee:	8ab6                	mv	s5,a3
ffffffffc02043f0:	e61ff0ef          	jal	ffffffffc0204250 <find_vma>
ffffffffc02043f4:	c501                	beqz	a0,ffffffffc02043fc <mm_map+0x4a>
ffffffffc02043f6:	651c                	ld	a5,8(a0)
ffffffffc02043f8:	0487ec63          	bltu	a5,s0,ffffffffc0204450 <mm_map+0x9e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043fc:	03000513          	li	a0,48
ffffffffc0204400:	f04a                	sd	s2,32(sp)
ffffffffc0204402:	f32fd0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc0204406:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204408:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020440a:	02090a63          	beqz	s2,ffffffffc020443e <mm_map+0x8c>
        vma->vm_start = vm_start;
ffffffffc020440e:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204412:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204416:	01592c23          	sw	s5,24(s2)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020441a:	854e                	mv	a0,s3
ffffffffc020441c:	85ca                	mv	a1,s2
ffffffffc020441e:	e73ff0ef          	jal	ffffffffc0204290 <insert_vma_struct>
    if (vma_store != NULL) {
ffffffffc0204422:	000a0463          	beqz	s4,ffffffffc020442a <mm_map+0x78>
        *vma_store = vma;
ffffffffc0204426:	012a3023          	sd	s2,0(s4)
ffffffffc020442a:	7902                	ld	s2,32(sp)
ffffffffc020442c:	69e2                	ld	s3,24(sp)
ffffffffc020442e:	6a42                	ld	s4,16(sp)
ffffffffc0204430:	6aa2                	ld	s5,8(sp)
    }
    ret = 0;
ffffffffc0204432:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc0204434:	70e2                	ld	ra,56(sp)
ffffffffc0204436:	7442                	ld	s0,48(sp)
ffffffffc0204438:	74a2                	ld	s1,40(sp)
ffffffffc020443a:	6121                	addi	sp,sp,64
ffffffffc020443c:	8082                	ret
ffffffffc020443e:	70e2                	ld	ra,56(sp)
ffffffffc0204440:	7442                	ld	s0,48(sp)
ffffffffc0204442:	7902                	ld	s2,32(sp)
ffffffffc0204444:	69e2                	ld	s3,24(sp)
ffffffffc0204446:	6a42                	ld	s4,16(sp)
ffffffffc0204448:	6aa2                	ld	s5,8(sp)
ffffffffc020444a:	74a2                	ld	s1,40(sp)
ffffffffc020444c:	6121                	addi	sp,sp,64
ffffffffc020444e:	8082                	ret
ffffffffc0204450:	69e2                	ld	s3,24(sp)
ffffffffc0204452:	6a42                	ld	s4,16(sp)
ffffffffc0204454:	6aa2                	ld	s5,8(sp)
        return -E_INVAL;
ffffffffc0204456:	5575                	li	a0,-3
ffffffffc0204458:	bff1                	j	ffffffffc0204434 <mm_map+0x82>
    assert(mm != NULL);
ffffffffc020445a:	00004697          	auipc	a3,0x4
ffffffffc020445e:	85668693          	addi	a3,a3,-1962 # ffffffffc0207cb0 <etext+0x13f6>
ffffffffc0204462:	00003617          	auipc	a2,0x3
ffffffffc0204466:	ad660613          	addi	a2,a2,-1322 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020446a:	0a700593          	li	a1,167
ffffffffc020446e:	00004517          	auipc	a0,0x4
ffffffffc0204472:	d5a50513          	addi	a0,a0,-678 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204476:	f04a                	sd	s2,32(sp)
ffffffffc0204478:	e852                	sd	s4,16(sp)
ffffffffc020447a:	e456                	sd	s5,8(sp)
ffffffffc020447c:	ff5fb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204480 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204480:	7139                	addi	sp,sp,-64
ffffffffc0204482:	fc06                	sd	ra,56(sp)
ffffffffc0204484:	f822                	sd	s0,48(sp)
ffffffffc0204486:	f426                	sd	s1,40(sp)
ffffffffc0204488:	f04a                	sd	s2,32(sp)
ffffffffc020448a:	ec4e                	sd	s3,24(sp)
ffffffffc020448c:	e852                	sd	s4,16(sp)
ffffffffc020448e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204490:	c525                	beqz	a0,ffffffffc02044f8 <dup_mmap+0x78>
ffffffffc0204492:	892a                	mv	s2,a0
ffffffffc0204494:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204496:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204498:	c1a5                	beqz	a1,ffffffffc02044f8 <dup_mmap+0x78>
    return listelm->prev;
ffffffffc020449a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020449c:	04848c63          	beq	s1,s0,ffffffffc02044f4 <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044a0:	03000513          	li	a0,48
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02044a4:	fe843a83          	ld	s5,-24(s0)
ffffffffc02044a8:	ff043a03          	ld	s4,-16(s0)
ffffffffc02044ac:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044b0:	e84fd0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc02044b4:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02044b6:	c50d                	beqz	a0,ffffffffc02044e0 <dup_mmap+0x60>
        vma->vm_start = vm_start;
ffffffffc02044b8:	01553423          	sd	s5,8(a0)
ffffffffc02044bc:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044c0:	01352c23          	sw	s3,24(a0)
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02044c4:	854a                	mv	a0,s2
ffffffffc02044c6:	dcbff0ef          	jal	ffffffffc0204290 <insert_vma_struct>

        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02044ca:	ff043683          	ld	a3,-16(s0)
ffffffffc02044ce:	fe843603          	ld	a2,-24(s0)
ffffffffc02044d2:	6c8c                	ld	a1,24(s1)
ffffffffc02044d4:	01893503          	ld	a0,24(s2)
ffffffffc02044d8:	4705                	li	a4,1
ffffffffc02044da:	c57fe0ef          	jal	ffffffffc0203130 <copy_range>
ffffffffc02044de:	dd55                	beqz	a0,ffffffffc020449a <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc02044e0:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02044e2:	70e2                	ld	ra,56(sp)
ffffffffc02044e4:	7442                	ld	s0,48(sp)
ffffffffc02044e6:	74a2                	ld	s1,40(sp)
ffffffffc02044e8:	7902                	ld	s2,32(sp)
ffffffffc02044ea:	69e2                	ld	s3,24(sp)
ffffffffc02044ec:	6a42                	ld	s4,16(sp)
ffffffffc02044ee:	6aa2                	ld	s5,8(sp)
ffffffffc02044f0:	6121                	addi	sp,sp,64
ffffffffc02044f2:	8082                	ret
    return 0;
ffffffffc02044f4:	4501                	li	a0,0
ffffffffc02044f6:	b7f5                	j	ffffffffc02044e2 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc02044f8:	00004697          	auipc	a3,0x4
ffffffffc02044fc:	d5868693          	addi	a3,a3,-680 # ffffffffc0208250 <etext+0x1996>
ffffffffc0204500:	00003617          	auipc	a2,0x3
ffffffffc0204504:	a3860613          	addi	a2,a2,-1480 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204508:	0c000593          	li	a1,192
ffffffffc020450c:	00004517          	auipc	a0,0x4
ffffffffc0204510:	cbc50513          	addi	a0,a0,-836 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204514:	f5dfb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204518 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0204518:	1101                	addi	sp,sp,-32
ffffffffc020451a:	ec06                	sd	ra,24(sp)
ffffffffc020451c:	e822                	sd	s0,16(sp)
ffffffffc020451e:	e426                	sd	s1,8(sp)
ffffffffc0204520:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204522:	c531                	beqz	a0,ffffffffc020456e <exit_mmap+0x56>
ffffffffc0204524:	591c                	lw	a5,48(a0)
ffffffffc0204526:	84aa                	mv	s1,a0
ffffffffc0204528:	e3b9                	bnez	a5,ffffffffc020456e <exit_mmap+0x56>
    return listelm->next;
ffffffffc020452a:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020452c:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204530:	02850663          	beq	a0,s0,ffffffffc020455c <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204534:	ff043603          	ld	a2,-16(s0)
ffffffffc0204538:	fe843583          	ld	a1,-24(s0)
ffffffffc020453c:	854a                	mv	a0,s2
ffffffffc020453e:	afbfd0ef          	jal	ffffffffc0202038 <unmap_range>
ffffffffc0204542:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204544:	fe8498e3          	bne	s1,s0,ffffffffc0204534 <exit_mmap+0x1c>
ffffffffc0204548:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020454a:	00848c63          	beq	s1,s0,ffffffffc0204562 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020454e:	ff043603          	ld	a2,-16(s0)
ffffffffc0204552:	fe843583          	ld	a1,-24(s0)
ffffffffc0204556:	854a                	mv	a0,s2
ffffffffc0204558:	c07fd0ef          	jal	ffffffffc020215e <exit_range>
ffffffffc020455c:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020455e:	fe8498e3          	bne	s1,s0,ffffffffc020454e <exit_mmap+0x36>
    }
}
ffffffffc0204562:	60e2                	ld	ra,24(sp)
ffffffffc0204564:	6442                	ld	s0,16(sp)
ffffffffc0204566:	64a2                	ld	s1,8(sp)
ffffffffc0204568:	6902                	ld	s2,0(sp)
ffffffffc020456a:	6105                	addi	sp,sp,32
ffffffffc020456c:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020456e:	00004697          	auipc	a3,0x4
ffffffffc0204572:	d0268693          	addi	a3,a3,-766 # ffffffffc0208270 <etext+0x19b6>
ffffffffc0204576:	00003617          	auipc	a2,0x3
ffffffffc020457a:	9c260613          	addi	a2,a2,-1598 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020457e:	0d600593          	li	a1,214
ffffffffc0204582:	00004517          	auipc	a0,0x4
ffffffffc0204586:	c4650513          	addi	a0,a0,-954 # ffffffffc02081c8 <etext+0x190e>
ffffffffc020458a:	ee7fb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc020458e <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020458e:	7139                	addi	sp,sp,-64
ffffffffc0204590:	f822                	sd	s0,48(sp)
ffffffffc0204592:	f426                	sd	s1,40(sp)
ffffffffc0204594:	fc06                	sd	ra,56(sp)
ffffffffc0204596:	f04a                	sd	s2,32(sp)
ffffffffc0204598:	ec4e                	sd	s3,24(sp)
ffffffffc020459a:	e852                	sd	s4,16(sp)
ffffffffc020459c:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc020459e:	c3dff0ef          	jal	ffffffffc02041da <mm_create>
    assert(mm != NULL);
ffffffffc02045a2:	842a                	mv	s0,a0
ffffffffc02045a4:	03200493          	li	s1,50
ffffffffc02045a8:	30050163          	beqz	a0,ffffffffc02048aa <vmm_init+0x31c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045ac:	03000513          	li	a0,48
ffffffffc02045b0:	d84fd0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc02045b4:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02045b6:	26050a63          	beqz	a0,ffffffffc020482a <vmm_init+0x29c>
        vma->vm_end = vm_end;
ffffffffc02045ba:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc02045be:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc02045c0:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc02045c4:	e91c                	sd	a5,16(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc02045c6:	14ed                	addi	s1,s1,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02045c8:	8522                	mv	a0,s0
ffffffffc02045ca:	cc7ff0ef          	jal	ffffffffc0204290 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02045ce:	fcf9                	bnez	s1,ffffffffc02045ac <vmm_init+0x1e>
ffffffffc02045d0:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02045d4:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045d8:	03000513          	li	a0,48
ffffffffc02045dc:	d58fd0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc02045e0:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02045e2:	26050463          	beqz	a0,ffffffffc020484a <vmm_init+0x2bc>
        vma->vm_end = vm_end;
ffffffffc02045e6:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc02045ea:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc02045ec:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc02045f0:	e91c                	sd	a5,16(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02045f2:	0495                	addi	s1,s1,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02045f4:	8522                	mv	a0,s0
ffffffffc02045f6:	c9bff0ef          	jal	ffffffffc0204290 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02045fa:	fd249fe3          	bne	s1,s2,ffffffffc02045d8 <vmm_init+0x4a>
ffffffffc02045fe:	641c                	ld	a5,8(s0)
ffffffffc0204600:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204602:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204606:	32f40263          	beq	s0,a5,ffffffffc020492a <vmm_init+0x39c>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020460a:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd59b70>
ffffffffc020460e:	ffe70693          	addi	a3,a4,-2
ffffffffc0204612:	26d61c63          	bne	a2,a3,ffffffffc020488a <vmm_init+0x2fc>
ffffffffc0204616:	ff07b683          	ld	a3,-16(a5)
ffffffffc020461a:	26e69863          	bne	a3,a4,ffffffffc020488a <vmm_init+0x2fc>
    for (i = 1; i <= step2; i ++) {
ffffffffc020461e:	0715                	addi	a4,a4,5
ffffffffc0204620:	679c                	ld	a5,8(a5)
ffffffffc0204622:	feb712e3          	bne	a4,a1,ffffffffc0204606 <vmm_init+0x78>
ffffffffc0204626:	4a1d                	li	s4,7
ffffffffc0204628:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020462a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020462e:	85a6                	mv	a1,s1
ffffffffc0204630:	8522                	mv	a0,s0
ffffffffc0204632:	c1fff0ef          	jal	ffffffffc0204250 <find_vma>
ffffffffc0204636:	89aa                	mv	s3,a0
        assert(vma1 != NULL);
ffffffffc0204638:	2c050963          	beqz	a0,ffffffffc020490a <vmm_init+0x37c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020463c:	00148593          	addi	a1,s1,1
ffffffffc0204640:	8522                	mv	a0,s0
ffffffffc0204642:	c0fff0ef          	jal	ffffffffc0204250 <find_vma>
ffffffffc0204646:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc0204648:	36050163          	beqz	a0,ffffffffc02049aa <vmm_init+0x41c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020464c:	85d2                	mv	a1,s4
ffffffffc020464e:	8522                	mv	a0,s0
ffffffffc0204650:	c01ff0ef          	jal	ffffffffc0204250 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204654:	32051b63          	bnez	a0,ffffffffc020498a <vmm_init+0x3fc>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204658:	00348593          	addi	a1,s1,3
ffffffffc020465c:	8522                	mv	a0,s0
ffffffffc020465e:	bf3ff0ef          	jal	ffffffffc0204250 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204662:	30051463          	bnez	a0,ffffffffc020496a <vmm_init+0x3dc>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204666:	00448593          	addi	a1,s1,4
ffffffffc020466a:	8522                	mv	a0,s0
ffffffffc020466c:	be5ff0ef          	jal	ffffffffc0204250 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204670:	2c051d63          	bnez	a0,ffffffffc020494a <vmm_init+0x3bc>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204674:	0089b783          	ld	a5,8(s3)
ffffffffc0204678:	26979963          	bne	a5,s1,ffffffffc02048ea <vmm_init+0x35c>
ffffffffc020467c:	0109b783          	ld	a5,16(s3)
ffffffffc0204680:	27479563          	bne	a5,s4,ffffffffc02048ea <vmm_init+0x35c>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204684:	00893783          	ld	a5,8(s2)
ffffffffc0204688:	24979163          	bne	a5,s1,ffffffffc02048ca <vmm_init+0x33c>
ffffffffc020468c:	01093783          	ld	a5,16(s2)
ffffffffc0204690:	23479d63          	bne	a5,s4,ffffffffc02048ca <vmm_init+0x33c>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204694:	0495                	addi	s1,s1,5
ffffffffc0204696:	0a15                	addi	s4,s4,5
ffffffffc0204698:	f9549be3          	bne	s1,s5,ffffffffc020462e <vmm_init+0xa0>
ffffffffc020469c:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc020469e:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02046a0:	85a6                	mv	a1,s1
ffffffffc02046a2:	8522                	mv	a0,s0
ffffffffc02046a4:	badff0ef          	jal	ffffffffc0204250 <find_vma>
        if (vma_below_5 != NULL ) {
ffffffffc02046a8:	38051f63          	bnez	a0,ffffffffc0204a46 <vmm_init+0x4b8>
    for (i =4; i>=0; i--) {
ffffffffc02046ac:	14fd                	addi	s1,s1,-1
ffffffffc02046ae:	ff2499e3          	bne	s1,s2,ffffffffc02046a0 <vmm_init+0x112>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc02046b2:	8522                	mv	a0,s0
ffffffffc02046b4:	cadff0ef          	jal	ffffffffc0204360 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02046b8:	00004517          	auipc	a0,0x4
ffffffffc02046bc:	d1850513          	addi	a0,a0,-744 # ffffffffc02083d0 <etext+0x1b16>
ffffffffc02046c0:	ad1fb0ef          	jal	ffffffffc0200190 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02046c4:	f0efd0ef          	jal	ffffffffc0201dd2 <nr_free_pages>
ffffffffc02046c8:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02046ca:	b11ff0ef          	jal	ffffffffc02041da <mm_create>
ffffffffc02046ce:	000a1797          	auipc	a5,0xa1
ffffffffc02046d2:	d8a7b123          	sd	a0,-638(a5) # ffffffffc02a5450 <check_mm_struct>
ffffffffc02046d6:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc02046d8:	34050763          	beqz	a0,ffffffffc0204a26 <vmm_init+0x498>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046dc:	000a1497          	auipc	s1,0xa1
ffffffffc02046e0:	d344b483          	ld	s1,-716(s1) # ffffffffc02a5410 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02046e4:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046e6:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02046e8:	3a079963          	bnez	a5,ffffffffc0204a9a <vmm_init+0x50c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02046ec:	03000513          	li	a0,48
ffffffffc02046f0:	c44fd0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc02046f4:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02046f6:	16050a63          	beqz	a0,ffffffffc020486a <vmm_init+0x2dc>
        vma->vm_end = vm_end;
ffffffffc02046fa:	00200737          	lui	a4,0x200
        vma->vm_flags = vm_flags;
ffffffffc02046fe:	4789                	li	a5,2
        vma->vm_end = vm_end;
ffffffffc0204700:	e918                	sd	a4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204702:	cd1c                	sw	a5,24(a0)

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204704:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204706:	00053423          	sd	zero,8(a0)
    insert_vma_struct(mm, vma);
ffffffffc020470a:	8522                	mv	a0,s0
ffffffffc020470c:	b85ff0ef          	jal	ffffffffc0204290 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204710:	8522                	mv	a0,s0
ffffffffc0204712:	10000593          	li	a1,256
ffffffffc0204716:	b3bff0ef          	jal	ffffffffc0204250 <find_vma>
ffffffffc020471a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020471e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204722:	34a99c63          	bne	s3,a0,ffffffffc0204a7a <vmm_init+0x4ec>
        *(char *)(addr + i) = i;
ffffffffc0204726:	00f78023          	sb	a5,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020472a:	0785                	addi	a5,a5,1
ffffffffc020472c:	fee79de3          	bne	a5,a4,ffffffffc0204726 <vmm_init+0x198>
ffffffffc0204730:	6705                	lui	a4,0x1
ffffffffc0204732:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_softint_out_size-0x6d1a>
ffffffffc0204736:	10000793          	li	a5,256
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020473a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020473e:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0204742:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0204744:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204746:	fec79ce3          	bne	a5,a2,ffffffffc020473e <vmm_init+0x1b0>
    }

    assert(sum == 0);
ffffffffc020474a:	2a071e63          	bnez	a4,ffffffffc0204a06 <vmm_init+0x478>
    return pa2page(PDE_ADDR(pde));
ffffffffc020474e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0204750:	000a1a97          	auipc	s5,0xa1
ffffffffc0204754:	cd0a8a93          	addi	s5,s5,-816 # ffffffffc02a5420 <npage>
ffffffffc0204758:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020475c:	078a                	slli	a5,a5,0x2
ffffffffc020475e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204760:	2ae7f163          	bgeu	a5,a4,ffffffffc0204a02 <vmm_init+0x474>
    return &pages[PPN(pa) - nbase];
ffffffffc0204764:	00005a17          	auipc	s4,0x5
ffffffffc0204768:	844a3a03          	ld	s4,-1980(s4) # ffffffffc0208fa8 <nbase>
ffffffffc020476c:	414786b3          	sub	a3,a5,s4
ffffffffc0204770:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204772:	8699                	srai	a3,a3,0x6
ffffffffc0204774:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0204776:	00c69793          	slli	a5,a3,0xc
ffffffffc020477a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020477c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020477e:	26e7f663          	bgeu	a5,a4,ffffffffc02049ea <vmm_init+0x45c>
ffffffffc0204782:	000a1797          	auipc	a5,0xa1
ffffffffc0204786:	c967b783          	ld	a5,-874(a5) # ffffffffc02a5418 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020478a:	4581                	li	a1,0
ffffffffc020478c:	8526                	mv	a0,s1
ffffffffc020478e:	00f689b3          	add	s3,a3,a5
ffffffffc0204792:	c6ffd0ef          	jal	ffffffffc0202400 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204796:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020479a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020479e:	078a                	slli	a5,a5,0x2
ffffffffc02047a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047a2:	26e7f063          	bgeu	a5,a4,ffffffffc0204a02 <vmm_init+0x474>
    return &pages[PPN(pa) - nbase];
ffffffffc02047a6:	000a1997          	auipc	s3,0xa1
ffffffffc02047aa:	c8298993          	addi	s3,s3,-894 # ffffffffc02a5428 <pages>
ffffffffc02047ae:	0009b503          	ld	a0,0(s3)
ffffffffc02047b2:	414787b3          	sub	a5,a5,s4
ffffffffc02047b6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02047b8:	953e                	add	a0,a0,a5
ffffffffc02047ba:	4585                	li	a1,1
ffffffffc02047bc:	dd6fd0ef          	jal	ffffffffc0201d92 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047c0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02047c2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047c6:	078a                	slli	a5,a5,0x2
ffffffffc02047c8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047ca:	22e7fc63          	bgeu	a5,a4,ffffffffc0204a02 <vmm_init+0x474>
    return &pages[PPN(pa) - nbase];
ffffffffc02047ce:	0009b503          	ld	a0,0(s3)
ffffffffc02047d2:	414787b3          	sub	a5,a5,s4
ffffffffc02047d6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02047d8:	953e                	add	a0,a0,a5
ffffffffc02047da:	4585                	li	a1,1
ffffffffc02047dc:	db6fd0ef          	jal	ffffffffc0201d92 <free_pages>
    pgdir[0] = 0;
ffffffffc02047e0:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc02047e4:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02047e8:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02047ec:	8522                	mv	a0,s0
ffffffffc02047ee:	b73ff0ef          	jal	ffffffffc0204360 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02047f2:	000a1797          	auipc	a5,0xa1
ffffffffc02047f6:	c407bf23          	sd	zero,-930(a5) # ffffffffc02a5450 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02047fa:	dd8fd0ef          	jal	ffffffffc0201dd2 <nr_free_pages>
ffffffffc02047fe:	1ca91663          	bne	s2,a0,ffffffffc02049ca <vmm_init+0x43c>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204802:	00004517          	auipc	a0,0x4
ffffffffc0204806:	c5e50513          	addi	a0,a0,-930 # ffffffffc0208460 <etext+0x1ba6>
ffffffffc020480a:	987fb0ef          	jal	ffffffffc0200190 <cprintf>
}
ffffffffc020480e:	7442                	ld	s0,48(sp)
ffffffffc0204810:	70e2                	ld	ra,56(sp)
ffffffffc0204812:	74a2                	ld	s1,40(sp)
ffffffffc0204814:	7902                	ld	s2,32(sp)
ffffffffc0204816:	69e2                	ld	s3,24(sp)
ffffffffc0204818:	6a42                	ld	s4,16(sp)
ffffffffc020481a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020481c:	00004517          	auipc	a0,0x4
ffffffffc0204820:	c6450513          	addi	a0,a0,-924 # ffffffffc0208480 <etext+0x1bc6>
}
ffffffffc0204824:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204826:	96bfb06f          	j	ffffffffc0200190 <cprintf>
        assert(vma != NULL);
ffffffffc020482a:	00003697          	auipc	a3,0x3
ffffffffc020482e:	4be68693          	addi	a3,a3,1214 # ffffffffc0207ce8 <etext+0x142e>
ffffffffc0204832:	00002617          	auipc	a2,0x2
ffffffffc0204836:	70660613          	addi	a2,a2,1798 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020483a:	11300593          	li	a1,275
ffffffffc020483e:	00004517          	auipc	a0,0x4
ffffffffc0204842:	98a50513          	addi	a0,a0,-1654 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204846:	c2bfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma != NULL);
ffffffffc020484a:	00003697          	auipc	a3,0x3
ffffffffc020484e:	49e68693          	addi	a3,a3,1182 # ffffffffc0207ce8 <etext+0x142e>
ffffffffc0204852:	00002617          	auipc	a2,0x2
ffffffffc0204856:	6e660613          	addi	a2,a2,1766 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020485a:	11900593          	li	a1,281
ffffffffc020485e:	00004517          	auipc	a0,0x4
ffffffffc0204862:	96a50513          	addi	a0,a0,-1686 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204866:	c0bfb0ef          	jal	ffffffffc0200470 <__panic>
    assert(vma != NULL);
ffffffffc020486a:	00003697          	auipc	a3,0x3
ffffffffc020486e:	47e68693          	addi	a3,a3,1150 # ffffffffc0207ce8 <etext+0x142e>
ffffffffc0204872:	00002617          	auipc	a2,0x2
ffffffffc0204876:	6c660613          	addi	a2,a2,1734 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020487a:	15200593          	li	a1,338
ffffffffc020487e:	00004517          	auipc	a0,0x4
ffffffffc0204882:	94a50513          	addi	a0,a0,-1718 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204886:	bebfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020488a:	00004697          	auipc	a3,0x4
ffffffffc020488e:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02082a8 <etext+0x19ee>
ffffffffc0204892:	00002617          	auipc	a2,0x2
ffffffffc0204896:	6a660613          	addi	a2,a2,1702 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020489a:	12200593          	li	a1,290
ffffffffc020489e:	00004517          	auipc	a0,0x4
ffffffffc02048a2:	92a50513          	addi	a0,a0,-1750 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02048a6:	bcbfb0ef          	jal	ffffffffc0200470 <__panic>
    assert(mm != NULL);
ffffffffc02048aa:	00003697          	auipc	a3,0x3
ffffffffc02048ae:	40668693          	addi	a3,a3,1030 # ffffffffc0207cb0 <etext+0x13f6>
ffffffffc02048b2:	00002617          	auipc	a2,0x2
ffffffffc02048b6:	68660613          	addi	a2,a2,1670 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02048ba:	10c00593          	li	a1,268
ffffffffc02048be:	00004517          	auipc	a0,0x4
ffffffffc02048c2:	90a50513          	addi	a0,a0,-1782 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02048c6:	babfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02048ca:	00004697          	auipc	a3,0x4
ffffffffc02048ce:	a9668693          	addi	a3,a3,-1386 # ffffffffc0208360 <etext+0x1aa6>
ffffffffc02048d2:	00002617          	auipc	a2,0x2
ffffffffc02048d6:	66660613          	addi	a2,a2,1638 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02048da:	13300593          	li	a1,307
ffffffffc02048de:	00004517          	auipc	a0,0x4
ffffffffc02048e2:	8ea50513          	addi	a0,a0,-1814 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02048e6:	b8bfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02048ea:	00004697          	auipc	a3,0x4
ffffffffc02048ee:	a4668693          	addi	a3,a3,-1466 # ffffffffc0208330 <etext+0x1a76>
ffffffffc02048f2:	00002617          	auipc	a2,0x2
ffffffffc02048f6:	64660613          	addi	a2,a2,1606 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02048fa:	13200593          	li	a1,306
ffffffffc02048fe:	00004517          	auipc	a0,0x4
ffffffffc0204902:	8ca50513          	addi	a0,a0,-1846 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204906:	b6bfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma1 != NULL);
ffffffffc020490a:	00004697          	auipc	a3,0x4
ffffffffc020490e:	9d668693          	addi	a3,a3,-1578 # ffffffffc02082e0 <etext+0x1a26>
ffffffffc0204912:	00002617          	auipc	a2,0x2
ffffffffc0204916:	62660613          	addi	a2,a2,1574 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020491a:	12800593          	li	a1,296
ffffffffc020491e:	00004517          	auipc	a0,0x4
ffffffffc0204922:	8aa50513          	addi	a0,a0,-1878 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204926:	b4bfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020492a:	00004697          	auipc	a3,0x4
ffffffffc020492e:	96668693          	addi	a3,a3,-1690 # ffffffffc0208290 <etext+0x19d6>
ffffffffc0204932:	00002617          	auipc	a2,0x2
ffffffffc0204936:	60660613          	addi	a2,a2,1542 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020493a:	12000593          	li	a1,288
ffffffffc020493e:	00004517          	auipc	a0,0x4
ffffffffc0204942:	88a50513          	addi	a0,a0,-1910 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204946:	b2bfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma5 == NULL);
ffffffffc020494a:	00004697          	auipc	a3,0x4
ffffffffc020494e:	9d668693          	addi	a3,a3,-1578 # ffffffffc0208320 <etext+0x1a66>
ffffffffc0204952:	00002617          	auipc	a2,0x2
ffffffffc0204956:	5e660613          	addi	a2,a2,1510 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020495a:	13000593          	li	a1,304
ffffffffc020495e:	00004517          	auipc	a0,0x4
ffffffffc0204962:	86a50513          	addi	a0,a0,-1942 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204966:	b0bfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma4 == NULL);
ffffffffc020496a:	00004697          	auipc	a3,0x4
ffffffffc020496e:	9a668693          	addi	a3,a3,-1626 # ffffffffc0208310 <etext+0x1a56>
ffffffffc0204972:	00002617          	auipc	a2,0x2
ffffffffc0204976:	5c660613          	addi	a2,a2,1478 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020497a:	12e00593          	li	a1,302
ffffffffc020497e:	00004517          	auipc	a0,0x4
ffffffffc0204982:	84a50513          	addi	a0,a0,-1974 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204986:	aebfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma3 == NULL);
ffffffffc020498a:	00004697          	auipc	a3,0x4
ffffffffc020498e:	97668693          	addi	a3,a3,-1674 # ffffffffc0208300 <etext+0x1a46>
ffffffffc0204992:	00002617          	auipc	a2,0x2
ffffffffc0204996:	5a660613          	addi	a2,a2,1446 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020499a:	12c00593          	li	a1,300
ffffffffc020499e:	00004517          	auipc	a0,0x4
ffffffffc02049a2:	82a50513          	addi	a0,a0,-2006 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02049a6:	acbfb0ef          	jal	ffffffffc0200470 <__panic>
        assert(vma2 != NULL);
ffffffffc02049aa:	00004697          	auipc	a3,0x4
ffffffffc02049ae:	94668693          	addi	a3,a3,-1722 # ffffffffc02082f0 <etext+0x1a36>
ffffffffc02049b2:	00002617          	auipc	a2,0x2
ffffffffc02049b6:	58660613          	addi	a2,a2,1414 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02049ba:	12a00593          	li	a1,298
ffffffffc02049be:	00004517          	auipc	a0,0x4
ffffffffc02049c2:	80a50513          	addi	a0,a0,-2038 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02049c6:	aabfb0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02049ca:	00004697          	auipc	a3,0x4
ffffffffc02049ce:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0208438 <etext+0x1b7e>
ffffffffc02049d2:	00002617          	auipc	a2,0x2
ffffffffc02049d6:	56660613          	addi	a2,a2,1382 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02049da:	17000593          	li	a1,368
ffffffffc02049de:	00003517          	auipc	a0,0x3
ffffffffc02049e2:	7ea50513          	addi	a0,a0,2026 # ffffffffc02081c8 <etext+0x190e>
ffffffffc02049e6:	a8bfb0ef          	jal	ffffffffc0200470 <__panic>
    return KADDR(page2pa(page));
ffffffffc02049ea:	00003617          	auipc	a2,0x3
ffffffffc02049ee:	b7660613          	addi	a2,a2,-1162 # ffffffffc0207560 <etext+0xca6>
ffffffffc02049f2:	06900593          	li	a1,105
ffffffffc02049f6:	00003517          	auipc	a0,0x3
ffffffffc02049fa:	b9250513          	addi	a0,a0,-1134 # ffffffffc0207588 <etext+0xcce>
ffffffffc02049fe:	a73fb0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0204a02:	fbcff0ef          	jal	ffffffffc02041be <pa2page.part.0>
    assert(sum == 0);
ffffffffc0204a06:	00004697          	auipc	a3,0x4
ffffffffc0204a0a:	a2268693          	addi	a3,a3,-1502 # ffffffffc0208428 <etext+0x1b6e>
ffffffffc0204a0e:	00002617          	auipc	a2,0x2
ffffffffc0204a12:	52a60613          	addi	a2,a2,1322 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204a16:	16300593          	li	a1,355
ffffffffc0204a1a:	00003517          	auipc	a0,0x3
ffffffffc0204a1e:	7ae50513          	addi	a0,a0,1966 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204a22:	a4ffb0ef          	jal	ffffffffc0200470 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204a26:	00004697          	auipc	a3,0x4
ffffffffc0204a2a:	9ca68693          	addi	a3,a3,-1590 # ffffffffc02083f0 <etext+0x1b36>
ffffffffc0204a2e:	00002617          	auipc	a2,0x2
ffffffffc0204a32:	50a60613          	addi	a2,a2,1290 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204a36:	14b00593          	li	a1,331
ffffffffc0204a3a:	00003517          	auipc	a0,0x3
ffffffffc0204a3e:	78e50513          	addi	a0,a0,1934 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204a42:	a2ffb0ef          	jal	ffffffffc0200470 <__panic>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204a46:	6914                	ld	a3,16(a0)
ffffffffc0204a48:	6510                	ld	a2,8(a0)
ffffffffc0204a4a:	0004859b          	sext.w	a1,s1
ffffffffc0204a4e:	00004517          	auipc	a0,0x4
ffffffffc0204a52:	94250513          	addi	a0,a0,-1726 # ffffffffc0208390 <etext+0x1ad6>
ffffffffc0204a56:	f3afb0ef          	jal	ffffffffc0200190 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0204a5a:	00004697          	auipc	a3,0x4
ffffffffc0204a5e:	95e68693          	addi	a3,a3,-1698 # ffffffffc02083b8 <etext+0x1afe>
ffffffffc0204a62:	00002617          	auipc	a2,0x2
ffffffffc0204a66:	4d660613          	addi	a2,a2,1238 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204a6a:	13b00593          	li	a1,315
ffffffffc0204a6e:	00003517          	auipc	a0,0x3
ffffffffc0204a72:	75a50513          	addi	a0,a0,1882 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204a76:	9fbfb0ef          	jal	ffffffffc0200470 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204a7a:	00004697          	auipc	a3,0x4
ffffffffc0204a7e:	98e68693          	addi	a3,a3,-1650 # ffffffffc0208408 <etext+0x1b4e>
ffffffffc0204a82:	00002617          	auipc	a2,0x2
ffffffffc0204a86:	4b660613          	addi	a2,a2,1206 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204a8a:	15700593          	li	a1,343
ffffffffc0204a8e:	00003517          	auipc	a0,0x3
ffffffffc0204a92:	73a50513          	addi	a0,a0,1850 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204a96:	9dbfb0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204a9a:	00003697          	auipc	a3,0x3
ffffffffc0204a9e:	23e68693          	addi	a3,a3,574 # ffffffffc0207cd8 <etext+0x141e>
ffffffffc0204aa2:	00002617          	auipc	a2,0x2
ffffffffc0204aa6:	49660613          	addi	a2,a2,1174 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204aaa:	14f00593          	li	a1,335
ffffffffc0204aae:	00003517          	auipc	a0,0x3
ffffffffc0204ab2:	71a50513          	addi	a0,a0,1818 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204ab6:	9bbfb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204aba <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204aba:	715d                	addi	sp,sp,-80
ffffffffc0204abc:	e0a2                	sd	s0,64(sp)
ffffffffc0204abe:	fc26                	sd	s1,56(sp)
ffffffffc0204ac0:	e486                	sd	ra,72(sp)
ffffffffc0204ac2:	f84a                	sd	s2,48(sp)
ffffffffc0204ac4:	84aa                	mv	s1,a0
ffffffffc0204ac6:	8432                	mv	s0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ac8:	100027f3          	csrr	a5,sstatus
ffffffffc0204acc:	8b89                	andi	a5,a5,2
ffffffffc0204ace:	4901                	li	s2,0
ffffffffc0204ad0:	16079463          	bnez	a5,ffffffffc0204c38 <do_pgfault+0x17e>
    bool intr_flag = 0;
    local_intr_save(intr_flag);//关闭中断
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204ad4:	85a2                	mv	a1,s0
ffffffffc0204ad6:	8526                	mv	a0,s1
ffffffffc0204ad8:	f78ff0ef          	jal	ffffffffc0204250 <find_vma>

    pgfault_num++;
ffffffffc0204adc:	000a1797          	auipc	a5,0xa1
ffffffffc0204ae0:	96c7a783          	lw	a5,-1684(a5) # ffffffffc02a5448 <pgfault_num>
ffffffffc0204ae4:	2785                	addiw	a5,a5,1
ffffffffc0204ae6:	000a1717          	auipc	a4,0xa1
ffffffffc0204aea:	96f72123          	sw	a5,-1694(a4) # ffffffffc02a5448 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204aee:	14050f63          	beqz	a0,ffffffffc0204c4c <do_pgfault+0x192>
ffffffffc0204af2:	651c                	ld	a5,8(a0)
ffffffffc0204af4:	14f46c63          	bltu	s0,a5,ffffffffc0204c4c <do_pgfault+0x192>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204af8:	4d1c                	lw	a5,24(a0)
ffffffffc0204afa:	f44e                	sd	s3,40(sp)
        perm |= (PTE_R | PTE_W);
ffffffffc0204afc:	49d9                	li	s3,22
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204afe:	8b89                	andi	a5,a5,2
ffffffffc0204b00:	c7e9                	beqz	a5,ffffffffc0204bca <do_pgfault+0x110>
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204b02:	77fd                	lui	a5,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0204b04:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204b06:	8c7d                	and	s0,s0,a5
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0204b08:	85a2                	mv	a1,s0
ffffffffc0204b0a:	4605                	li	a2,1
ffffffffc0204b0c:	b00fd0ef          	jal	ffffffffc0201e0c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0204b10:	610c                	ld	a1,0(a0)
ffffffffc0204b12:	10058163          	beqz	a1,ffffffffc0204c14 <do_pgfault+0x15a>
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
       
       if (*ptep & PTE_V) {
ffffffffc0204b16:	0015f793          	andi	a5,a1,1
ffffffffc0204b1a:	cbd5                	beqz	a5,ffffffffc0204bce <do_pgfault+0x114>
ffffffffc0204b1c:	f052                	sd	s4,32(sp)
ffffffffc0204b1e:	ec56                	sd	s5,24(sp)
            
            assert((*ptep & PTE_W) == 0);//不可写引起的缺页
ffffffffc0204b20:	0045f793          	andi	a5,a1,4
ffffffffc0204b24:	18079663          	bnez	a5,ffffffffc0204cb0 <do_pgfault+0x1f6>
    if (PPN(pa) >= npage) {
ffffffffc0204b28:	000a1a17          	auipc	s4,0xa1
ffffffffc0204b2c:	8f8a0a13          	addi	s4,s4,-1800 # ffffffffc02a5420 <npage>
ffffffffc0204b30:	000a3703          	ld	a4,0(s4)
            struct Page *page = pa2page(PTE_ADDR(*ptep));  // 获取物理页
ffffffffc0204b34:	00259793          	slli	a5,a1,0x2
ffffffffc0204b38:	83b1                	srli	a5,a5,0xc
ffffffffc0204b3a:	18e7fb63          	bgeu	a5,a4,ffffffffc0204cd0 <do_pgfault+0x216>
    return &pages[PPN(pa) - nbase];
ffffffffc0204b3e:	00004997          	auipc	s3,0x4
ffffffffc0204b42:	46a9b983          	ld	s3,1130(s3) # ffffffffc0208fa8 <nbase>
ffffffffc0204b46:	000a1a97          	auipc	s5,0xa1
ffffffffc0204b4a:	8e2a8a93          	addi	s5,s5,-1822 # ffffffffc02a5428 <pages>
ffffffffc0204b4e:	000ab903          	ld	s2,0(s5)
ffffffffc0204b52:	413787b3          	sub	a5,a5,s3
ffffffffc0204b56:	079a                	slli	a5,a5,0x6
ffffffffc0204b58:	993e                	add	s2,s2,a5
            //cprintf("start cow,page ref :%d\n",page->ref);
            // 2. 检查引用计数，判断是否需要复制
            if (page_ref(page) > 1) {
ffffffffc0204b5a:	00092703          	lw	a4,0(s2)
ffffffffc0204b5e:	4785                	li	a5,1
ffffffffc0204b60:	0ee7d063          	bge	a5,a4,ffffffffc0204c40 <do_pgfault+0x186>
                //cprintf("REF > 1\n");
                perm = *ptep & 0xff; //获得权限
                // struct Page *new_page = alloc_page();  // 分配新物理页
                struct Page* new_page = pgdir_alloc_page(mm->pgdir, addr, perm|PTE_W);
ffffffffc0204b64:	6c88                	ld	a0,24(s1)
                perm = *ptep & 0xff; //获得权限
ffffffffc0204b66:	0ff5f613          	zext.b	a2,a1
                struct Page* new_page = pgdir_alloc_page(mm->pgdir, addr, perm|PTE_W);
ffffffffc0204b6a:	00466613          	ori	a2,a2,4
ffffffffc0204b6e:	85a2                	mv	a1,s0
ffffffffc0204b70:	81bfe0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
                if (new_page == NULL) {
ffffffffc0204b74:	0e050c63          	beqz	a0,ffffffffc0204c6c <do_pgfault+0x1b2>
    return page - pages + nbase;
ffffffffc0204b78:	000ab603          	ld	a2,0(s5)
    return KADDR(page2pa(page));
ffffffffc0204b7c:	57fd                	li	a5,-1
ffffffffc0204b7e:	000a3703          	ld	a4,0(s4)
    return page - pages + nbase;
ffffffffc0204b82:	40c906b3          	sub	a3,s2,a2
ffffffffc0204b86:	8699                	srai	a3,a3,0x6
ffffffffc0204b88:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204b8a:	83b1                	srli	a5,a5,0xc
ffffffffc0204b8c:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b90:	00c69593          	slli	a1,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b94:	10e87163          	bgeu	a6,a4,ffffffffc0204c96 <do_pgfault+0x1dc>
    return page - pages + nbase;
ffffffffc0204b98:	40c506b3          	sub	a3,a0,a2
ffffffffc0204b9c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204b9e:	000a1517          	auipc	a0,0xa1
ffffffffc0204ba2:	87a53503          	ld	a0,-1926(a0) # ffffffffc02a5418 <va_pa_offset>
    return page - pages + nbase;
ffffffffc0204ba6:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204ba8:	8ff5                	and	a5,a5,a3
ffffffffc0204baa:	95aa                	add	a1,a1,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204bae:	0ce7f863          	bgeu	a5,a4,ffffffffc0204c7e <do_pgfault+0x1c4>
                    goto failed;
                }
                // 3. 复制内存内容
                void *kva_src = page2kva(page);
                void *kva_dst = page2kva(new_page); 
                memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc0204bb2:	9536                	add	a0,a0,a3
ffffffffc0204bb4:	6605                	lui	a2,0x1
ffffffffc0204bb6:	4ed010ef          	jal	ffffffffc02068a2 <memcpy>
    page->ref -= 1;
ffffffffc0204bba:	00092783          	lw	a5,0(s2)
                // 4. 减少原页面引用计数
                page_ref_dec(page);
                return 0;
ffffffffc0204bbe:	7a02                	ld	s4,32(sp)
ffffffffc0204bc0:	6ae2                	ld	s5,24(sp)
ffffffffc0204bc2:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0x3fd59b87>
ffffffffc0204bc4:	00f92023          	sw	a5,0(s2)
ffffffffc0204bc8:	a835                	j	ffffffffc0204c04 <do_pgfault+0x14a>
    uint32_t perm = PTE_U;
ffffffffc0204bca:	49c1                	li	s3,16
ffffffffc0204bcc:	bf1d                	j	ffffffffc0204b02 <do_pgfault+0x48>
            else {
                *ptep |= PTE_W | PTE_R;
                return 0;
            }
        }else{
            if (swap_init_ok) {
ffffffffc0204bce:	000a1797          	auipc	a5,0xa1
ffffffffc0204bd2:	8627a783          	lw	a5,-1950(a5) # ffffffffc02a5430 <swap_init_ok>
ffffffffc0204bd6:	c7c1                	beqz	a5,ffffffffc0204c5e <do_pgfault+0x1a4>
                //(2) According to the mm,
                //addr AND page, setup the
                //map of phy addr <--->
                //logical addr
                //(3) make the page swappable.
                swap_in(mm, addr, &page);  
ffffffffc0204bd8:	0030                	addi	a2,sp,8
ffffffffc0204bda:	85a2                	mv	a1,s0
ffffffffc0204bdc:	8526                	mv	a0,s1
                struct Page *page = NULL;
ffffffffc0204bde:	e402                	sd	zero,8(sp)
                swap_in(mm, addr, &page);  
ffffffffc0204be0:	932ff0ef          	jal	ffffffffc0203d12 <swap_in>
                page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204be4:	65a2                	ld	a1,8(sp)
ffffffffc0204be6:	6c88                	ld	a0,24(s1)
ffffffffc0204be8:	86ce                	mv	a3,s3
ffffffffc0204bea:	8622                	mv	a2,s0
ffffffffc0204bec:	8affd0ef          	jal	ffffffffc020249a <page_insert>
                swap_map_swappable(mm, addr, page, 1);
ffffffffc0204bf0:	6622                	ld	a2,8(sp)
ffffffffc0204bf2:	8526                	mv	a0,s1
ffffffffc0204bf4:	85a2                	mv	a1,s0
ffffffffc0204bf6:	4685                	li	a3,1
ffffffffc0204bf8:	806ff0ef          	jal	ffffffffc0203bfe <swap_map_swappable>
                page->pra_vaddr = addr;
ffffffffc0204bfc:	67a2                	ld	a5,8(sp)
ffffffffc0204bfe:	ff80                	sd	s0,56(a5)
    if (flag) {
ffffffffc0204c00:	02091963          	bnez	s2,ffffffffc0204c32 <do_pgfault+0x178>
ffffffffc0204c04:	79a2                	ld	s3,40(sp)
                return 0;
ffffffffc0204c06:	4501                	li	a0,0
   }
    local_intr_restore(intr_flag);
   ret = 0;
failed:
    return ret;
}   
ffffffffc0204c08:	60a6                	ld	ra,72(sp)
ffffffffc0204c0a:	6406                	ld	s0,64(sp)
ffffffffc0204c0c:	74e2                	ld	s1,56(sp)
ffffffffc0204c0e:	7942                	ld	s2,48(sp)
ffffffffc0204c10:	6161                	addi	sp,sp,80
ffffffffc0204c12:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204c14:	6c88                	ld	a0,24(s1)
ffffffffc0204c16:	864e                	mv	a2,s3
ffffffffc0204c18:	85a2                	mv	a1,s0
ffffffffc0204c1a:	f70fe0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0204c1e:	f16d                	bnez	a0,ffffffffc0204c00 <do_pgfault+0x146>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204c20:	00004517          	auipc	a0,0x4
ffffffffc0204c24:	8a850513          	addi	a0,a0,-1880 # ffffffffc02084c8 <etext+0x1c0e>
ffffffffc0204c28:	d68fb0ef          	jal	ffffffffc0200190 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204c2c:	79a2                	ld	s3,40(sp)
ffffffffc0204c2e:	5571                	li	a0,-4
ffffffffc0204c30:	bfe1                	j	ffffffffc0204c08 <do_pgfault+0x14e>
        intr_enable();
ffffffffc0204c32:	a09fb0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0204c36:	b7f9                	j	ffffffffc0204c04 <do_pgfault+0x14a>
        intr_disable();
ffffffffc0204c38:	a09fb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc0204c3c:	4905                	li	s2,1
ffffffffc0204c3e:	bd59                	j	ffffffffc0204ad4 <do_pgfault+0x1a>
                *ptep |= PTE_W | PTE_R;
ffffffffc0204c40:	0065e593          	ori	a1,a1,6
ffffffffc0204c44:	7a02                	ld	s4,32(sp)
ffffffffc0204c46:	6ae2                	ld	s5,24(sp)
ffffffffc0204c48:	e10c                	sd	a1,0(a0)
                return 0;
ffffffffc0204c4a:	bf6d                	j	ffffffffc0204c04 <do_pgfault+0x14a>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204c4c:	85a2                	mv	a1,s0
ffffffffc0204c4e:	00004517          	auipc	a0,0x4
ffffffffc0204c52:	84a50513          	addi	a0,a0,-1974 # ffffffffc0208498 <etext+0x1bde>
ffffffffc0204c56:	d3afb0ef          	jal	ffffffffc0200190 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204c5a:	5575                	li	a0,-3
        goto failed;
ffffffffc0204c5c:	b775                	j	ffffffffc0204c08 <do_pgfault+0x14e>
                cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204c5e:	00004517          	auipc	a0,0x4
ffffffffc0204c62:	8c250513          	addi	a0,a0,-1854 # ffffffffc0208520 <etext+0x1c66>
ffffffffc0204c66:	d2afb0ef          	jal	ffffffffc0200190 <cprintf>
                goto failed;
ffffffffc0204c6a:	b7c9                	j	ffffffffc0204c2c <do_pgfault+0x172>
                    cprintf("cow alloc page failed\n");
ffffffffc0204c6c:	00004517          	auipc	a0,0x4
ffffffffc0204c70:	89c50513          	addi	a0,a0,-1892 # ffffffffc0208508 <etext+0x1c4e>
ffffffffc0204c74:	d1cfb0ef          	jal	ffffffffc0200190 <cprintf>
                    goto failed;
ffffffffc0204c78:	7a02                	ld	s4,32(sp)
ffffffffc0204c7a:	6ae2                	ld	s5,24(sp)
ffffffffc0204c7c:	bf45                	j	ffffffffc0204c2c <do_pgfault+0x172>
    return KADDR(page2pa(page));
ffffffffc0204c7e:	00003617          	auipc	a2,0x3
ffffffffc0204c82:	8e260613          	addi	a2,a2,-1822 # ffffffffc0207560 <etext+0xca6>
ffffffffc0204c86:	06900593          	li	a1,105
ffffffffc0204c8a:	00003517          	auipc	a0,0x3
ffffffffc0204c8e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0207588 <etext+0xcce>
ffffffffc0204c92:	fdefb0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0204c96:	86ae                	mv	a3,a1
ffffffffc0204c98:	00003617          	auipc	a2,0x3
ffffffffc0204c9c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0207560 <etext+0xca6>
ffffffffc0204ca0:	06900593          	li	a1,105
ffffffffc0204ca4:	00003517          	auipc	a0,0x3
ffffffffc0204ca8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0207588 <etext+0xcce>
ffffffffc0204cac:	fc4fb0ef          	jal	ffffffffc0200470 <__panic>
            assert((*ptep & PTE_W) == 0);//不可写引起的缺页
ffffffffc0204cb0:	00004697          	auipc	a3,0x4
ffffffffc0204cb4:	84068693          	addi	a3,a3,-1984 # ffffffffc02084f0 <etext+0x1c36>
ffffffffc0204cb8:	00002617          	auipc	a2,0x2
ffffffffc0204cbc:	28060613          	addi	a2,a2,640 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0204cc0:	1d500593          	li	a1,469
ffffffffc0204cc4:	00003517          	auipc	a0,0x3
ffffffffc0204cc8:	50450513          	addi	a0,a0,1284 # ffffffffc02081c8 <etext+0x190e>
ffffffffc0204ccc:	fa4fb0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0204cd0:	ceeff0ef          	jal	ffffffffc02041be <pa2page.part.0>

ffffffffc0204cd4 <user_mem_check>:


bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204cd4:	7179                	addi	sp,sp,-48
ffffffffc0204cd6:	f022                	sd	s0,32(sp)
ffffffffc0204cd8:	f406                	sd	ra,40(sp)
ffffffffc0204cda:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204cdc:	c535                	beqz	a0,ffffffffc0204d48 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204cde:	002007b7          	lui	a5,0x200
ffffffffc0204ce2:	04f5ee63          	bltu	a1,a5,ffffffffc0204d3e <user_mem_check+0x6a>
ffffffffc0204ce6:	ec26                	sd	s1,24(sp)
ffffffffc0204ce8:	00c584b3          	add	s1,a1,a2
ffffffffc0204cec:	0695fc63          	bgeu	a1,s1,ffffffffc0204d64 <user_mem_check+0x90>
ffffffffc0204cf0:	4785                	li	a5,1
ffffffffc0204cf2:	07fe                	slli	a5,a5,0x1f
ffffffffc0204cf4:	0697e863          	bltu	a5,s1,ffffffffc0204d64 <user_mem_check+0x90>
ffffffffc0204cf8:	e84a                	sd	s2,16(sp)
ffffffffc0204cfa:	e44e                	sd	s3,8(sp)
ffffffffc0204cfc:	e052                	sd	s4,0(sp)
ffffffffc0204cfe:	892a                	mv	s2,a0
ffffffffc0204d00:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d02:	6a05                	lui	s4,0x1
ffffffffc0204d04:	a821                	j	ffffffffc0204d1c <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d06:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d0a:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204d0c:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d0e:	c685                	beqz	a3,ffffffffc0204d36 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204d10:	c399                	beqz	a5,ffffffffc0204d16 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d12:	02e46263          	bltu	s0,a4,ffffffffc0204d36 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204d16:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204d18:	04947863          	bgeu	s0,s1,ffffffffc0204d68 <user_mem_check+0x94>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204d1c:	85a2                	mv	a1,s0
ffffffffc0204d1e:	854a                	mv	a0,s2
ffffffffc0204d20:	d30ff0ef          	jal	ffffffffc0204250 <find_vma>
ffffffffc0204d24:	c909                	beqz	a0,ffffffffc0204d36 <user_mem_check+0x62>
ffffffffc0204d26:	6518                	ld	a4,8(a0)
ffffffffc0204d28:	00e46763          	bltu	s0,a4,ffffffffc0204d36 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d2c:	4d1c                	lw	a5,24(a0)
ffffffffc0204d2e:	fc099ce3          	bnez	s3,ffffffffc0204d06 <user_mem_check+0x32>
ffffffffc0204d32:	8b85                	andi	a5,a5,1
ffffffffc0204d34:	f3ed                	bnez	a5,ffffffffc0204d16 <user_mem_check+0x42>
ffffffffc0204d36:	64e2                	ld	s1,24(sp)
ffffffffc0204d38:	6942                	ld	s2,16(sp)
ffffffffc0204d3a:	69a2                	ld	s3,8(sp)
ffffffffc0204d3c:	6a02                	ld	s4,0(sp)
            return 0;
ffffffffc0204d3e:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204d40:	70a2                	ld	ra,40(sp)
ffffffffc0204d42:	7402                	ld	s0,32(sp)
ffffffffc0204d44:	6145                	addi	sp,sp,48
ffffffffc0204d46:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204d48:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d4c:	4501                	li	a0,0
ffffffffc0204d4e:	fef5e9e3          	bltu	a1,a5,ffffffffc0204d40 <user_mem_check+0x6c>
ffffffffc0204d52:	962e                	add	a2,a2,a1
ffffffffc0204d54:	fec5f6e3          	bgeu	a1,a2,ffffffffc0204d40 <user_mem_check+0x6c>
ffffffffc0204d58:	c8000537          	lui	a0,0xc8000
ffffffffc0204d5c:	0505                	addi	a0,a0,1 # ffffffffc8000001 <end+0x7d5ab89>
ffffffffc0204d5e:	00a63533          	sltu	a0,a2,a0
ffffffffc0204d62:	bff9                	j	ffffffffc0204d40 <user_mem_check+0x6c>
ffffffffc0204d64:	64e2                	ld	s1,24(sp)
ffffffffc0204d66:	bfe1                	j	ffffffffc0204d3e <user_mem_check+0x6a>
ffffffffc0204d68:	64e2                	ld	s1,24(sp)
ffffffffc0204d6a:	6942                	ld	s2,16(sp)
ffffffffc0204d6c:	69a2                	ld	s3,8(sp)
ffffffffc0204d6e:	6a02                	ld	s4,0(sp)
        return 1;
ffffffffc0204d70:	4505                	li	a0,1
ffffffffc0204d72:	b7f9                	j	ffffffffc0204d40 <user_mem_check+0x6c>

ffffffffc0204d74 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204d74:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d76:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204d78:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204d7a:	86dfb0ef          	jal	ffffffffc02005e6 <ide_device_valid>
ffffffffc0204d7e:	cd01                	beqz	a0,ffffffffc0204d96 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d80:	4505                	li	a0,1
ffffffffc0204d82:	86bfb0ef          	jal	ffffffffc02005ec <ide_device_size>
}
ffffffffc0204d86:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204d88:	810d                	srli	a0,a0,0x3
ffffffffc0204d8a:	000a0797          	auipc	a5,0xa0
ffffffffc0204d8e:	6aa7b723          	sd	a0,1710(a5) # ffffffffc02a5438 <max_swap_offset>
}
ffffffffc0204d92:	0141                	addi	sp,sp,16
ffffffffc0204d94:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204d96:	00003617          	auipc	a2,0x3
ffffffffc0204d9a:	7b260613          	addi	a2,a2,1970 # ffffffffc0208548 <etext+0x1c8e>
ffffffffc0204d9e:	45b5                	li	a1,13
ffffffffc0204da0:	00003517          	auipc	a0,0x3
ffffffffc0204da4:	7c850513          	addi	a0,a0,1992 # ffffffffc0208568 <etext+0x1cae>
ffffffffc0204da8:	ec8fb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204dac <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204dac:	1141                	addi	sp,sp,-16
ffffffffc0204dae:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204db0:	00855793          	srli	a5,a0,0x8
ffffffffc0204db4:	cbb1                	beqz	a5,ffffffffc0204e08 <swapfs_read+0x5c>
ffffffffc0204db6:	000a0717          	auipc	a4,0xa0
ffffffffc0204dba:	68273703          	ld	a4,1666(a4) # ffffffffc02a5438 <max_swap_offset>
ffffffffc0204dbe:	04e7f563          	bgeu	a5,a4,ffffffffc0204e08 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204dc2:	000a0617          	auipc	a2,0xa0
ffffffffc0204dc6:	66663603          	ld	a2,1638(a2) # ffffffffc02a5428 <pages>
ffffffffc0204dca:	00004717          	auipc	a4,0x4
ffffffffc0204dce:	1de73703          	ld	a4,478(a4) # ffffffffc0208fa8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204dd2:	000a0697          	auipc	a3,0xa0
ffffffffc0204dd6:	64e6b683          	ld	a3,1614(a3) # ffffffffc02a5420 <npage>
    return page - pages + nbase;
ffffffffc0204dda:	40c58633          	sub	a2,a1,a2
ffffffffc0204dde:	8619                	srai	a2,a2,0x6
ffffffffc0204de0:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204de2:	00c61713          	slli	a4,a2,0xc
ffffffffc0204de6:	8331                	srli	a4,a4,0xc
ffffffffc0204de8:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204dec:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204dee:	02d77963          	bgeu	a4,a3,ffffffffc0204e20 <swapfs_read+0x74>
ffffffffc0204df2:	000a0797          	auipc	a5,0xa0
ffffffffc0204df6:	6267b783          	ld	a5,1574(a5) # ffffffffc02a5418 <va_pa_offset>
}
ffffffffc0204dfa:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204dfc:	46a1                	li	a3,8
ffffffffc0204dfe:	963e                	add	a2,a2,a5
ffffffffc0204e00:	4505                	li	a0,1
}
ffffffffc0204e02:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e04:	feefb06f          	j	ffffffffc02005f2 <ide_read_secs>
ffffffffc0204e08:	86aa                	mv	a3,a0
ffffffffc0204e0a:	00003617          	auipc	a2,0x3
ffffffffc0204e0e:	77660613          	addi	a2,a2,1910 # ffffffffc0208580 <etext+0x1cc6>
ffffffffc0204e12:	45d1                	li	a1,20
ffffffffc0204e14:	00003517          	auipc	a0,0x3
ffffffffc0204e18:	75450513          	addi	a0,a0,1876 # ffffffffc0208568 <etext+0x1cae>
ffffffffc0204e1c:	e54fb0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0204e20:	86b2                	mv	a3,a2
ffffffffc0204e22:	06900593          	li	a1,105
ffffffffc0204e26:	00002617          	auipc	a2,0x2
ffffffffc0204e2a:	73a60613          	addi	a2,a2,1850 # ffffffffc0207560 <etext+0xca6>
ffffffffc0204e2e:	00002517          	auipc	a0,0x2
ffffffffc0204e32:	75a50513          	addi	a0,a0,1882 # ffffffffc0207588 <etext+0xcce>
ffffffffc0204e36:	e3afb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204e3a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204e3a:	1141                	addi	sp,sp,-16
ffffffffc0204e3c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e3e:	00855793          	srli	a5,a0,0x8
ffffffffc0204e42:	cbb1                	beqz	a5,ffffffffc0204e96 <swapfs_write+0x5c>
ffffffffc0204e44:	000a0717          	auipc	a4,0xa0
ffffffffc0204e48:	5f473703          	ld	a4,1524(a4) # ffffffffc02a5438 <max_swap_offset>
ffffffffc0204e4c:	04e7f563          	bgeu	a5,a4,ffffffffc0204e96 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204e50:	000a0617          	auipc	a2,0xa0
ffffffffc0204e54:	5d863603          	ld	a2,1496(a2) # ffffffffc02a5428 <pages>
ffffffffc0204e58:	00004717          	auipc	a4,0x4
ffffffffc0204e5c:	15073703          	ld	a4,336(a4) # ffffffffc0208fa8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204e60:	000a0697          	auipc	a3,0xa0
ffffffffc0204e64:	5c06b683          	ld	a3,1472(a3) # ffffffffc02a5420 <npage>
    return page - pages + nbase;
ffffffffc0204e68:	40c58633          	sub	a2,a1,a2
ffffffffc0204e6c:	8619                	srai	a2,a2,0x6
ffffffffc0204e6e:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204e70:	00c61713          	slli	a4,a2,0xc
ffffffffc0204e74:	8331                	srli	a4,a4,0xc
ffffffffc0204e76:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e7a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e7c:	02d77963          	bgeu	a4,a3,ffffffffc0204eae <swapfs_write+0x74>
ffffffffc0204e80:	000a0797          	auipc	a5,0xa0
ffffffffc0204e84:	5987b783          	ld	a5,1432(a5) # ffffffffc02a5418 <va_pa_offset>
}
ffffffffc0204e88:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e8a:	46a1                	li	a3,8
ffffffffc0204e8c:	963e                	add	a2,a2,a5
ffffffffc0204e8e:	4505                	li	a0,1
}
ffffffffc0204e90:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e92:	f84fb06f          	j	ffffffffc0200616 <ide_write_secs>
ffffffffc0204e96:	86aa                	mv	a3,a0
ffffffffc0204e98:	00003617          	auipc	a2,0x3
ffffffffc0204e9c:	6e860613          	addi	a2,a2,1768 # ffffffffc0208580 <etext+0x1cc6>
ffffffffc0204ea0:	45e5                	li	a1,25
ffffffffc0204ea2:	00003517          	auipc	a0,0x3
ffffffffc0204ea6:	6c650513          	addi	a0,a0,1734 # ffffffffc0208568 <etext+0x1cae>
ffffffffc0204eaa:	dc6fb0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0204eae:	86b2                	mv	a3,a2
ffffffffc0204eb0:	06900593          	li	a1,105
ffffffffc0204eb4:	00002617          	auipc	a2,0x2
ffffffffc0204eb8:	6ac60613          	addi	a2,a2,1708 # ffffffffc0207560 <etext+0xca6>
ffffffffc0204ebc:	00002517          	auipc	a0,0x2
ffffffffc0204ec0:	6cc50513          	addi	a0,a0,1740 # ffffffffc0207588 <etext+0xcce>
ffffffffc0204ec4:	dacfb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204ec8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204ec8:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204eca:	9402                	jalr	s0

	jal do_exit
ffffffffc0204ecc:	698000ef          	jal	ffffffffc0205564 <do_exit>

ffffffffc0204ed0 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ed0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ed2:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204ed6:	e022                	sd	s0,0(sp)
ffffffffc0204ed8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204eda:	c5bfc0ef          	jal	ffffffffc0201b34 <kmalloc>
ffffffffc0204ede:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204ee0:	cd21                	beqz	a0,ffffffffc0204f38 <alloc_proc+0x68>
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;                           // 设置进程状态为未初始化
        proc->pid = -1;                                      // 设置进程ID为-1（还未分配）
        proc->cr3 = boot_cr3;                                // 设置CR3寄存器的值（页目录基址）
ffffffffc0204ee2:	000a0717          	auipc	a4,0xa0
ffffffffc0204ee6:	52673703          	ld	a4,1318(a4) # ffffffffc02a5408 <boot_cr3>
        proc->state = PROC_UNINIT;                           // 设置进程状态为未初始化
ffffffffc0204eea:	57fd                	li	a5,-1
ffffffffc0204eec:	1782                	slli	a5,a5,0x20
ffffffffc0204eee:	e11c                	sd	a5,0(a0)
        proc->cr3 = boot_cr3;                                // 设置CR3寄存器的值（页目录基址）
ffffffffc0204ef0:	f558                	sd	a4,168(a0)
        proc->runs = 0;                                      // 设置进程运行次数为0
ffffffffc0204ef2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                                    // 设置内核栈地址为0（还未分配）
ffffffffc0204ef6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;                              // 设置不需要重新调度
ffffffffc0204efa:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;                                 // 设置父进程为空
ffffffffc0204efe:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                                     // 设置内存管理字段为空
ffffffffc0204f02:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 初始化上下文信息为0
ffffffffc0204f06:	07000613          	li	a2,112
ffffffffc0204f0a:	4581                	li	a1,0
ffffffffc0204f0c:	03050513          	addi	a0,a0,48
ffffffffc0204f10:	181010ef          	jal	ffffffffc0206890 <memset>
        proc->tf = NULL;                                     // 设置trapframe为空
        proc->flags = 0;                                     // 设置进程标志为0
        memset(proc->name, 0, PROC_NAME_LEN);                // 初始化进程名为0
ffffffffc0204f14:	0b440513          	addi	a0,s0,180
        proc->tf = NULL;                                     // 设置trapframe为空
ffffffffc0204f18:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                                     // 设置进程标志为0
ffffffffc0204f1c:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN);                // 初始化进程名为0
ffffffffc0204f20:	463d                	li	a2,15
ffffffffc0204f22:	4581                	li	a1,0
ffffffffc0204f24:	16d010ef          	jal	ffffffffc0206890 <memset>
        proc->wait_state = 0;
ffffffffc0204f28:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL; // Child Pointer 表示当前进程的子进程
ffffffffc0204f2c:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL; // Older Sibling Pointer 表示当前进程的上一个兄弟进程
ffffffffc0204f30:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL; // Younger Sibling Pointer 表示当前进程的下一个兄弟进程
ffffffffc0204f34:	0e043c23          	sd	zero,248(s0)

    }
    return proc;
}
ffffffffc0204f38:	60a2                	ld	ra,8(sp)
ffffffffc0204f3a:	8522                	mv	a0,s0
ffffffffc0204f3c:	6402                	ld	s0,0(sp)
ffffffffc0204f3e:	0141                	addi	sp,sp,16
ffffffffc0204f40:	8082                	ret

ffffffffc0204f42 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204f42:	000a0797          	auipc	a5,0xa0
ffffffffc0204f46:	51e7b783          	ld	a5,1310(a5) # ffffffffc02a5460 <current>
ffffffffc0204f4a:	73c8                	ld	a0,160(a5)
ffffffffc0204f4c:	e27fb06f          	j	ffffffffc0200d72 <forkrets>

ffffffffc0204f50 <user_main>:
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    //KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
    //KERNEL_EXECVE(exit);
    KERNEL_EXECVE(cow);
ffffffffc0204f50:	000a0797          	auipc	a5,0xa0
ffffffffc0204f54:	5107b783          	ld	a5,1296(a5) # ffffffffc02a5460 <current>
user_main(void *arg) {
ffffffffc0204f58:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(cow);
ffffffffc0204f5a:	00003617          	auipc	a2,0x3
ffffffffc0204f5e:	64660613          	addi	a2,a2,1606 # ffffffffc02085a0 <etext+0x1ce6>
ffffffffc0204f62:	43cc                	lw	a1,4(a5)
ffffffffc0204f64:	00003517          	auipc	a0,0x3
ffffffffc0204f68:	64450513          	addi	a0,a0,1604 # ffffffffc02085a8 <etext+0x1cee>
user_main(void *arg) {
ffffffffc0204f6c:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(cow);
ffffffffc0204f6e:	a22fb0ef          	jal	ffffffffc0200190 <cprintf>
ffffffffc0204f72:	3fe08717          	auipc	a4,0x3fe08
ffffffffc0204f76:	f3670713          	addi	a4,a4,-202 # cea8 <_binary_obj___user_cow_out_size>
ffffffffc0204f7a:	00018797          	auipc	a5,0x18
ffffffffc0204f7e:	76678793          	addi	a5,a5,1894 # ffffffffc021d6e0 <_binary_obj___user_cow_out_start>
ffffffffc0204f82:	00003517          	auipc	a0,0x3
ffffffffc0204f86:	61e50513          	addi	a0,a0,1566 # ffffffffc02085a0 <etext+0x1ce6>
    int64_t ret=0, len = strlen(name);
ffffffffc0204f8a:	e802                	sd	zero,16(sp)
ffffffffc0204f8c:	e43a                	sd	a4,8(sp)
ffffffffc0204f8e:	f03e                	sd	a5,32(sp)
ffffffffc0204f90:	f42a                	sd	a0,40(sp)
ffffffffc0204f92:	06d010ef          	jal	ffffffffc02067fe <strlen>
ffffffffc0204f96:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204f98:	4511                	li	a0,4
ffffffffc0204f9a:	55a2                	lw	a1,40(sp)
ffffffffc0204f9c:	4662                	lw	a2,24(sp)
ffffffffc0204f9e:	5682                	lw	a3,32(sp)
ffffffffc0204fa0:	4722                	lw	a4,8(sp)
ffffffffc0204fa2:	48a9                	li	a7,10
ffffffffc0204fa4:	9002                	ebreak
ffffffffc0204fa6:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204fa8:	65c2                	ld	a1,16(sp)
ffffffffc0204faa:	00003517          	auipc	a0,0x3
ffffffffc0204fae:	62650513          	addi	a0,a0,1574 # ffffffffc02085d0 <etext+0x1d16>
ffffffffc0204fb2:	9defb0ef          	jal	ffffffffc0200190 <cprintf>
    //cprintf("user_main execve ok.\n");
#endif
    panic("user_main execve failed.\n");
ffffffffc0204fb6:	00003617          	auipc	a2,0x3
ffffffffc0204fba:	62a60613          	addi	a2,a2,1578 # ffffffffc02085e0 <etext+0x1d26>
ffffffffc0204fbe:	34700593          	li	a1,839
ffffffffc0204fc2:	00003517          	auipc	a0,0x3
ffffffffc0204fc6:	63e50513          	addi	a0,a0,1598 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0204fca:	ca6fb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0204fce <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204fce:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204fd0:	1141                	addi	sp,sp,-16
ffffffffc0204fd2:	e406                	sd	ra,8(sp)
ffffffffc0204fd4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204fd8:	02f6ee63          	bltu	a3,a5,ffffffffc0205014 <put_pgdir+0x46>
ffffffffc0204fdc:	000a0717          	auipc	a4,0xa0
ffffffffc0204fe0:	43c73703          	ld	a4,1084(a4) # ffffffffc02a5418 <va_pa_offset>
    if (PPN(pa) >= npage) {
ffffffffc0204fe4:	000a0797          	auipc	a5,0xa0
ffffffffc0204fe8:	43c7b783          	ld	a5,1084(a5) # ffffffffc02a5420 <npage>
    return pa2page(PADDR(kva));
ffffffffc0204fec:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0204fee:	82b1                	srli	a3,a3,0xc
ffffffffc0204ff0:	02f6fe63          	bgeu	a3,a5,ffffffffc020502c <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204ff4:	00004797          	auipc	a5,0x4
ffffffffc0204ff8:	fb47b783          	ld	a5,-76(a5) # ffffffffc0208fa8 <nbase>
ffffffffc0204ffc:	000a0517          	auipc	a0,0xa0
ffffffffc0205000:	42c53503          	ld	a0,1068(a0) # ffffffffc02a5428 <pages>
}
ffffffffc0205004:	60a2                	ld	ra,8(sp)
ffffffffc0205006:	8e9d                	sub	a3,a3,a5
ffffffffc0205008:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020500a:	4585                	li	a1,1
ffffffffc020500c:	9536                	add	a0,a0,a3
}
ffffffffc020500e:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0205010:	d83fc06f          	j	ffffffffc0201d92 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0205014:	00002617          	auipc	a2,0x2
ffffffffc0205018:	5f460613          	addi	a2,a2,1524 # ffffffffc0207608 <etext+0xd4e>
ffffffffc020501c:	06e00593          	li	a1,110
ffffffffc0205020:	00002517          	auipc	a0,0x2
ffffffffc0205024:	56850513          	addi	a0,a0,1384 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205028:	c48fb0ef          	jal	ffffffffc0200470 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020502c:	00002617          	auipc	a2,0x2
ffffffffc0205030:	60460613          	addi	a2,a2,1540 # ffffffffc0207630 <etext+0xd76>
ffffffffc0205034:	06200593          	li	a1,98
ffffffffc0205038:	00002517          	auipc	a0,0x2
ffffffffc020503c:	55050513          	addi	a0,a0,1360 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205040:	c30fb0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0205044 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0205044:	7179                	addi	sp,sp,-48
ffffffffc0205046:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0205048:	000a0917          	auipc	s2,0xa0
ffffffffc020504c:	41890913          	addi	s2,s2,1048 # ffffffffc02a5460 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0205050:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0205052:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0205056:	f406                	sd	ra,40(sp)
    if (proc != current) {
ffffffffc0205058:	02a48a63          	beq	s1,a0,ffffffffc020508c <proc_run+0x48>
ffffffffc020505c:	e84e                	sd	s3,16(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020505e:	100027f3          	csrr	a5,sstatus
ffffffffc0205062:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205064:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205066:	ef9d                	bnez	a5,ffffffffc02050a4 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0205068:	755c                	ld	a5,168(a0)
ffffffffc020506a:	577d                	li	a4,-1
ffffffffc020506c:	177e                	slli	a4,a4,0x3f
ffffffffc020506e:	83b1                	srli	a5,a5,0xc
              current = proc;
ffffffffc0205070:	00a93023          	sd	a0,0(s2)
ffffffffc0205074:	8fd9                	or	a5,a5,a4
ffffffffc0205076:	18079073          	csrw	satp,a5
              switch_to(&(prev->context), &(next->context));
ffffffffc020507a:	03050593          	addi	a1,a0,48
ffffffffc020507e:	03048513          	addi	a0,s1,48
ffffffffc0205082:	124010ef          	jal	ffffffffc02061a6 <switch_to>
    if (flag) {
ffffffffc0205086:	00099863          	bnez	s3,ffffffffc0205096 <proc_run+0x52>
ffffffffc020508a:	69c2                	ld	s3,16(sp)
}
ffffffffc020508c:	70a2                	ld	ra,40(sp)
ffffffffc020508e:	7482                	ld	s1,32(sp)
ffffffffc0205090:	6962                	ld	s2,24(sp)
ffffffffc0205092:	6145                	addi	sp,sp,48
ffffffffc0205094:	8082                	ret
        intr_enable();
ffffffffc0205096:	69c2                	ld	s3,16(sp)
ffffffffc0205098:	70a2                	ld	ra,40(sp)
ffffffffc020509a:	7482                	ld	s1,32(sp)
ffffffffc020509c:	6962                	ld	s2,24(sp)
ffffffffc020509e:	6145                	addi	sp,sp,48
ffffffffc02050a0:	d9afb06f          	j	ffffffffc020063a <intr_enable>
ffffffffc02050a4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02050a6:	d9afb0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02050aa:	6522                	ld	a0,8(sp)
ffffffffc02050ac:	4985                	li	s3,1
ffffffffc02050ae:	bf6d                	j	ffffffffc0205068 <proc_run+0x24>

ffffffffc02050b0 <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc02050b0:	000a0717          	auipc	a4,0xa0
ffffffffc02050b4:	3a872703          	lw	a4,936(a4) # ffffffffc02a5458 <nr_process>
ffffffffc02050b8:	6785                	lui	a5,0x1
ffffffffc02050ba:	36f75e63          	bge	a4,a5,ffffffffc0205436 <do_fork+0x386>
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02050be:	711d                	addi	sp,sp,-96
ffffffffc02050c0:	e8a2                	sd	s0,80(sp)
ffffffffc02050c2:	e4a6                	sd	s1,72(sp)
ffffffffc02050c4:	e0ca                	sd	s2,64(sp)
ffffffffc02050c6:	fc4e                	sd	s3,56(sp)
ffffffffc02050c8:	ec86                	sd	ra,88(sp)
ffffffffc02050ca:	89aa                	mv	s3,a0
ffffffffc02050cc:	892e                	mv	s2,a1
ffffffffc02050ce:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc02050d0:	e01ff0ef          	jal	ffffffffc0204ed0 <alloc_proc>
ffffffffc02050d4:	842a                	mv	s0,a0
ffffffffc02050d6:	30050763          	beqz	a0,ffffffffc02053e4 <do_fork+0x334>
    proc->parent = current;
ffffffffc02050da:	f852                	sd	s4,48(sp)
ffffffffc02050dc:	000a0a17          	auipc	s4,0xa0
ffffffffc02050e0:	384a0a13          	addi	s4,s4,900 # ffffffffc02a5460 <current>
ffffffffc02050e4:	000a3783          	ld	a5,0(s4)
    assert(current->wait_state == 0); // 确保当前进程的等待状态为0
ffffffffc02050e8:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_softint_out_size-0x6f84>
    proc->parent = current;
ffffffffc02050ec:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 确保当前进程的等待状态为0
ffffffffc02050ee:	3a071663          	bnez	a4,ffffffffc020549a <do_fork+0x3ea>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02050f2:	4509                	li	a0,2
ffffffffc02050f4:	c17fc0ef          	jal	ffffffffc0201d0a <alloc_pages>
    if (page != NULL) {
ffffffffc02050f8:	2e050e63          	beqz	a0,ffffffffc02053f4 <do_fork+0x344>
    return page - pages + nbase;
ffffffffc02050fc:	e06a                	sd	s10,0(sp)
ffffffffc02050fe:	000a0d17          	auipc	s10,0xa0
ffffffffc0205102:	32ad0d13          	addi	s10,s10,810 # ffffffffc02a5428 <pages>
ffffffffc0205106:	000d3783          	ld	a5,0(s10)
ffffffffc020510a:	e862                	sd	s8,16(sp)
ffffffffc020510c:	00004c17          	auipc	s8,0x4
ffffffffc0205110:	e9cc3c03          	ld	s8,-356(s8) # ffffffffc0208fa8 <nbase>
ffffffffc0205114:	40f506b3          	sub	a3,a0,a5
ffffffffc0205118:	e466                	sd	s9,8(sp)
    return KADDR(page2pa(page));
ffffffffc020511a:	000a0c97          	auipc	s9,0xa0
ffffffffc020511e:	306c8c93          	addi	s9,s9,774 # ffffffffc02a5420 <npage>
ffffffffc0205122:	ec5e                	sd	s7,24(sp)
    return page - pages + nbase;
ffffffffc0205124:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205126:	5bfd                	li	s7,-1
ffffffffc0205128:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc020512c:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc020512e:	00cbdb93          	srli	s7,s7,0xc
ffffffffc0205132:	0176f733          	and	a4,a3,s7
ffffffffc0205136:	f05a                	sd	s6,32(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0205138:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020513a:	38f77663          	bgeu	a4,a5,ffffffffc02054c6 <do_fork+0x416>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020513e:	000a3703          	ld	a4,0(s4)
ffffffffc0205142:	000a0a17          	auipc	s4,0xa0
ffffffffc0205146:	2d6a0a13          	addi	s4,s4,726 # ffffffffc02a5418 <va_pa_offset>
ffffffffc020514a:	000a3783          	ld	a5,0(s4)
ffffffffc020514e:	02873b03          	ld	s6,40(a4)
ffffffffc0205152:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205154:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205156:	020b0863          	beqz	s6,ffffffffc0205186 <do_fork+0xd6>
    if (clone_flags & CLONE_VM) {
ffffffffc020515a:	1009f993          	andi	s3,s3,256
ffffffffc020515e:	18098a63          	beqz	s3,ffffffffc02052f2 <do_fork+0x242>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205162:	030b2703          	lw	a4,48(s6)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205166:	018b3783          	ld	a5,24(s6)
ffffffffc020516a:	c02006b7          	lui	a3,0xc0200
ffffffffc020516e:	2705                	addiw	a4,a4,1
ffffffffc0205170:	02eb2823          	sw	a4,48(s6)
    proc->mm = mm;
ffffffffc0205174:	03643423          	sd	s6,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205178:	36d7e463          	bltu	a5,a3,ffffffffc02054e0 <do_fork+0x430>
ffffffffc020517c:	000a3703          	ld	a4,0(s4)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205180:	6814                	ld	a3,16(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205182:	8f99                	sub	a5,a5,a4
ffffffffc0205184:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205186:	6789                	lui	a5,0x2
ffffffffc0205188:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6190>
ffffffffc020518c:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020518e:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205190:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205192:	87b6                	mv	a5,a3
ffffffffc0205194:	12048713          	addi	a4,s1,288
ffffffffc0205198:	00063883          	ld	a7,0(a2)
ffffffffc020519c:	00863803          	ld	a6,8(a2)
ffffffffc02051a0:	6a08                	ld	a0,16(a2)
ffffffffc02051a2:	6e0c                	ld	a1,24(a2)
ffffffffc02051a4:	0117b023          	sd	a7,0(a5)
ffffffffc02051a8:	0107b423          	sd	a6,8(a5)
ffffffffc02051ac:	eb88                	sd	a0,16(a5)
ffffffffc02051ae:	ef8c                	sd	a1,24(a5)
ffffffffc02051b0:	02060613          	addi	a2,a2,32
ffffffffc02051b4:	02078793          	addi	a5,a5,32
ffffffffc02051b8:	fee610e3          	bne	a2,a4,ffffffffc0205198 <do_fork+0xe8>
    proc->tf->gpr.a0 = 0;
ffffffffc02051bc:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051c0:	1a090863          	beqz	s2,ffffffffc0205370 <do_fork+0x2c0>
ffffffffc02051c4:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051c8:	00000797          	auipc	a5,0x0
ffffffffc02051cc:	d7a78793          	addi	a5,a5,-646 # ffffffffc0204f42 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051d0:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051d2:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051d4:	100027f3          	csrr	a5,sstatus
ffffffffc02051d8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051da:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051dc:	1a079963          	bnez	a5,ffffffffc020538e <do_fork+0x2de>
    if (++ last_pid >= MAX_PID) {
ffffffffc02051e0:	00095517          	auipc	a0,0x95
ffffffffc02051e4:	d3452503          	lw	a0,-716(a0) # ffffffffc0299f14 <last_pid.1>
ffffffffc02051e8:	00095897          	auipc	a7,0x95
ffffffffc02051ec:	d2c88893          	addi	a7,a7,-724 # ffffffffc0299f14 <last_pid.1>
ffffffffc02051f0:	6789                	lui	a5,0x2
ffffffffc02051f2:	2505                	addiw	a0,a0,1
ffffffffc02051f4:	00a8a023          	sw	a0,0(a7)
ffffffffc02051f8:	1af55c63          	bge	a0,a5,ffffffffc02053b0 <do_fork+0x300>
    if (last_pid >= next_safe) {
ffffffffc02051fc:	00095797          	auipc	a5,0x95
ffffffffc0205200:	d147a783          	lw	a5,-748(a5) # ffffffffc0299f10 <next_safe.0>
ffffffffc0205204:	000a0497          	auipc	s1,0xa0
ffffffffc0205208:	1cc48493          	addi	s1,s1,460 # ffffffffc02a53d0 <proc_list>
ffffffffc020520c:	06f54363          	blt	a0,a5,ffffffffc0205272 <do_fork+0x1c2>
ffffffffc0205210:	000a0497          	auipc	s1,0xa0
ffffffffc0205214:	1c048493          	addi	s1,s1,448 # ffffffffc02a53d0 <proc_list>
ffffffffc0205218:	0084b303          	ld	t1,8(s1)
        next_safe = MAX_PID;
ffffffffc020521c:	00095e17          	auipc	t3,0x95
ffffffffc0205220:	cf4e0e13          	addi	t3,t3,-780 # ffffffffc0299f10 <next_safe.0>
ffffffffc0205224:	6789                	lui	a5,0x2
ffffffffc0205226:	00fe2023          	sw	a5,0(t3)
ffffffffc020522a:	86aa                	mv	a3,a0
ffffffffc020522c:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc020522e:	02930e63          	beq	t1,s1,ffffffffc020526a <do_fork+0x1ba>
ffffffffc0205232:	882e                	mv	a6,a1
ffffffffc0205234:	879a                	mv	a5,t1
ffffffffc0205236:	6609                	lui	a2,0x2
ffffffffc0205238:	a811                	j	ffffffffc020524c <do_fork+0x19c>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020523a:	00e6d663          	bge	a3,a4,ffffffffc0205246 <do_fork+0x196>
ffffffffc020523e:	00c75463          	bge	a4,a2,ffffffffc0205246 <do_fork+0x196>
                next_safe = proc->pid;
ffffffffc0205242:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205244:	4805                	li	a6,1
ffffffffc0205246:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205248:	00978d63          	beq	a5,s1,ffffffffc0205262 <do_fork+0x1b2>
            if (proc->pid == last_pid) {
ffffffffc020524c:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x6134>
ffffffffc0205250:	fed715e3          	bne	a4,a3,ffffffffc020523a <do_fork+0x18a>
                if (++ last_pid >= next_safe) {
ffffffffc0205254:	2685                	addiw	a3,a3,1
ffffffffc0205256:	18c6d963          	bge	a3,a2,ffffffffc02053e8 <do_fork+0x338>
ffffffffc020525a:	679c                	ld	a5,8(a5)
ffffffffc020525c:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020525e:	fe9797e3          	bne	a5,s1,ffffffffc020524c <do_fork+0x19c>
ffffffffc0205262:	00080463          	beqz	a6,ffffffffc020526a <do_fork+0x1ba>
ffffffffc0205266:	00ce2023          	sw	a2,0(t3)
ffffffffc020526a:	c581                	beqz	a1,ffffffffc0205272 <do_fork+0x1c2>
ffffffffc020526c:	00d8a023          	sw	a3,0(a7)
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205270:	8536                	mv	a0,a3
        proc->pid = get_pid();
ffffffffc0205272:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205274:	45a9                	li	a1,10
ffffffffc0205276:	19c010ef          	jal	ffffffffc0206412 <hash32>
ffffffffc020527a:	02051793          	slli	a5,a0,0x20
ffffffffc020527e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205282:	0009c797          	auipc	a5,0x9c
ffffffffc0205286:	14e78793          	addi	a5,a5,334 # ffffffffc02a13d0 <hash_list>
ffffffffc020528a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020528c:	6510                	ld	a2,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020528e:	7018                	ld	a4,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205290:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc0205294:	e21c                	sd	a5,0(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205296:	6494                	ld	a3,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205298:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020529a:	7b7c                	ld	a5,240(a4)
    elm->next = next;
ffffffffc020529c:	f070                	sd	a2,224(s0)
    elm->prev = prev;
ffffffffc020529e:	ec68                	sd	a0,216(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02052a0:	0c840613          	addi	a2,s0,200
    prev->next = next->prev = elm;
ffffffffc02052a4:	e290                	sd	a2,0(a3)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02052a6:	10f43023          	sd	a5,256(s0)
ffffffffc02052aa:	e490                	sd	a2,8(s1)
    elm->next = next;
ffffffffc02052ac:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc02052ae:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02052b0:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02052b4:	c391                	beqz	a5,ffffffffc02052b8 <do_fork+0x208>
        proc->optr->yptr = proc;
ffffffffc02052b6:	ffe0                	sd	s0,248(a5)
    nr_process ++;
ffffffffc02052b8:	000a0797          	auipc	a5,0xa0
ffffffffc02052bc:	1a07a783          	lw	a5,416(a5) # ffffffffc02a5458 <nr_process>
    proc->parent->cptr = proc;
ffffffffc02052c0:	fb60                	sd	s0,240(a4)
    nr_process ++;
ffffffffc02052c2:	2785                	addiw	a5,a5,1
ffffffffc02052c4:	000a0717          	auipc	a4,0xa0
ffffffffc02052c8:	18f72a23          	sw	a5,404(a4) # ffffffffc02a5458 <nr_process>
    if (flag) {
ffffffffc02052cc:	0e091663          	bnez	s2,ffffffffc02053b8 <do_fork+0x308>
    wakeup_proc(proc);
ffffffffc02052d0:	8522                	mv	a0,s0
ffffffffc02052d2:	73f000ef          	jal	ffffffffc0206210 <wakeup_proc>
    ret = proc->pid;
ffffffffc02052d6:	4048                	lw	a0,4(s0)
ffffffffc02052d8:	7a42                	ld	s4,48(sp)
ffffffffc02052da:	7b02                	ld	s6,32(sp)
ffffffffc02052dc:	6be2                	ld	s7,24(sp)
ffffffffc02052de:	6c42                	ld	s8,16(sp)
ffffffffc02052e0:	6ca2                	ld	s9,8(sp)
ffffffffc02052e2:	6d02                	ld	s10,0(sp)
}
ffffffffc02052e4:	60e6                	ld	ra,88(sp)
ffffffffc02052e6:	6446                	ld	s0,80(sp)
ffffffffc02052e8:	64a6                	ld	s1,72(sp)
ffffffffc02052ea:	6906                	ld	s2,64(sp)
ffffffffc02052ec:	79e2                	ld	s3,56(sp)
ffffffffc02052ee:	6125                	addi	sp,sp,96
ffffffffc02052f0:	8082                	ret
ffffffffc02052f2:	f456                	sd	s5,40(sp)
    if ((mm = mm_create()) == NULL) {
ffffffffc02052f4:	ee7fe0ef          	jal	ffffffffc02041da <mm_create>
ffffffffc02052f8:	8aaa                	mv	s5,a0
ffffffffc02052fa:	c979                	beqz	a0,ffffffffc02053d0 <do_fork+0x320>
    if ((page = alloc_page()) == NULL) {
ffffffffc02052fc:	4505                	li	a0,1
ffffffffc02052fe:	a0dfc0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0205302:	c561                	beqz	a0,ffffffffc02053ca <do_fork+0x31a>
    return page - pages + nbase;
ffffffffc0205304:	000d3703          	ld	a4,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205308:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc020530c:	40e506b3          	sub	a3,a0,a4
ffffffffc0205310:	8699                	srai	a3,a3,0x6
ffffffffc0205312:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0205314:	0176fbb3          	and	s7,a3,s7
    return page2ppn(page) << PGSHIFT;
ffffffffc0205318:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020531a:	1efbf163          	bgeu	s7,a5,ffffffffc02054fc <do_fork+0x44c>
ffffffffc020531e:	000a3783          	ld	a5,0(s4)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205322:	000a0597          	auipc	a1,0xa0
ffffffffc0205326:	0ee5b583          	ld	a1,238(a1) # ffffffffc02a5410 <boot_pgdir>
ffffffffc020532a:	6605                	lui	a2,0x1
ffffffffc020532c:	00f689b3          	add	s3,a3,a5
ffffffffc0205330:	854e                	mv	a0,s3
ffffffffc0205332:	570010ef          	jal	ffffffffc02068a2 <memcpy>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205336:	4b85                	li	s7,1
    mm->pgdir = pgdir;
ffffffffc0205338:	013abc23          	sd	s3,24(s5)
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020533c:	038b0993          	addi	s3,s6,56
ffffffffc0205340:	4179b7af          	amoor.d	a5,s7,(s3)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205344:	0177f7b3          	and	a5,a5,s7
ffffffffc0205348:	c799                	beqz	a5,ffffffffc0205356 <do_fork+0x2a6>
        schedule();
ffffffffc020534a:	761000ef          	jal	ffffffffc02062aa <schedule>
ffffffffc020534e:	4179b7af          	amoor.d	a5,s7,(s3)
    while (!try_lock(lock)) {
ffffffffc0205352:	8b85                	andi	a5,a5,1
ffffffffc0205354:	fbfd                	bnez	a5,ffffffffc020534a <do_fork+0x29a>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205356:	85da                	mv	a1,s6
ffffffffc0205358:	8556                	mv	a0,s5
ffffffffc020535a:	926ff0ef          	jal	ffffffffc0204480 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020535e:	57f9                	li	a5,-2
ffffffffc0205360:	60f9b7af          	amoand.d	a5,a5,(s3)
ffffffffc0205364:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205366:	cbf1                	beqz	a5,ffffffffc020543a <do_fork+0x38a>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205368:	8b56                	mv	s6,s5
    if (ret != 0) {
ffffffffc020536a:	e931                	bnez	a0,ffffffffc02053be <do_fork+0x30e>
ffffffffc020536c:	7aa2                	ld	s5,40(sp)
ffffffffc020536e:	bbd5                	j	ffffffffc0205162 <do_fork+0xb2>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205370:	8936                	mv	s2,a3
ffffffffc0205372:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205376:	00000797          	auipc	a5,0x0
ffffffffc020537a:	bcc78793          	addi	a5,a5,-1076 # ffffffffc0204f42 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020537e:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205380:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205382:	100027f3          	csrr	a5,sstatus
ffffffffc0205386:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205388:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020538a:	e4078be3          	beqz	a5,ffffffffc02051e0 <do_fork+0x130>
        intr_disable();
ffffffffc020538e:	ab2fb0ef          	jal	ffffffffc0200640 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205392:	00095517          	auipc	a0,0x95
ffffffffc0205396:	b8252503          	lw	a0,-1150(a0) # ffffffffc0299f14 <last_pid.1>
ffffffffc020539a:	00095897          	auipc	a7,0x95
ffffffffc020539e:	b7a88893          	addi	a7,a7,-1158 # ffffffffc0299f14 <last_pid.1>
ffffffffc02053a2:	6789                	lui	a5,0x2
ffffffffc02053a4:	2505                	addiw	a0,a0,1
ffffffffc02053a6:	00a8a023          	sw	a0,0(a7)
        return 1;
ffffffffc02053aa:	4905                	li	s2,1
ffffffffc02053ac:	e4f548e3          	blt	a0,a5,ffffffffc02051fc <do_fork+0x14c>
        last_pid = 1;
ffffffffc02053b0:	4505                	li	a0,1
ffffffffc02053b2:	00a8a023          	sw	a0,0(a7)
        goto inside;
ffffffffc02053b6:	bda9                	j	ffffffffc0205210 <do_fork+0x160>
        intr_enable();
ffffffffc02053b8:	a82fb0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc02053bc:	bf11                	j	ffffffffc02052d0 <do_fork+0x220>
    exit_mmap(mm);
ffffffffc02053be:	8556                	mv	a0,s5
ffffffffc02053c0:	958ff0ef          	jal	ffffffffc0204518 <exit_mmap>
    put_pgdir(mm);
ffffffffc02053c4:	8556                	mv	a0,s5
ffffffffc02053c6:	c09ff0ef          	jal	ffffffffc0204fce <put_pgdir>
    mm_destroy(mm);
ffffffffc02053ca:	8556                	mv	a0,s5
ffffffffc02053cc:	f95fe0ef          	jal	ffffffffc0204360 <mm_destroy>
ffffffffc02053d0:	7aa2                	ld	s5,40(sp)
ffffffffc02053d2:	7b02                	ld	s6,32(sp)
ffffffffc02053d4:	6be2                	ld	s7,24(sp)
ffffffffc02053d6:	6c42                	ld	s8,16(sp)
ffffffffc02053d8:	6ca2                	ld	s9,8(sp)
ffffffffc02053da:	6d02                	ld	s10,0(sp)
    kfree(proc);
ffffffffc02053dc:	8522                	mv	a0,s0
ffffffffc02053de:	81bfc0ef          	jal	ffffffffc0201bf8 <kfree>
ffffffffc02053e2:	7a42                	ld	s4,48(sp)
    ret = -E_NO_MEM;
ffffffffc02053e4:	5571                	li	a0,-4
    return ret;
ffffffffc02053e6:	bdfd                	j	ffffffffc02052e4 <do_fork+0x234>
                    if (last_pid >= MAX_PID) {
ffffffffc02053e8:	6789                	lui	a5,0x2
ffffffffc02053ea:	00f6c363          	blt	a3,a5,ffffffffc02053f0 <do_fork+0x340>
                        last_pid = 1;
ffffffffc02053ee:	4685                	li	a3,1
                    goto repeat;
ffffffffc02053f0:	4585                	li	a1,1
ffffffffc02053f2:	bd35                	j	ffffffffc020522e <do_fork+0x17e>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02053f4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02053f6:	c02007b7          	lui	a5,0xc0200
ffffffffc02053fa:	06f6ee63          	bltu	a3,a5,ffffffffc0205476 <do_fork+0x3c6>
ffffffffc02053fe:	000a0797          	auipc	a5,0xa0
ffffffffc0205402:	01a7b783          	ld	a5,26(a5) # ffffffffc02a5418 <va_pa_offset>
    if (PPN(pa) >= npage) {
ffffffffc0205406:	000a0717          	auipc	a4,0xa0
ffffffffc020540a:	01a73703          	ld	a4,26(a4) # ffffffffc02a5420 <npage>
    return pa2page(PADDR(kva));
ffffffffc020540e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205412:	83b1                	srli	a5,a5,0xc
ffffffffc0205414:	02e7ff63          	bgeu	a5,a4,ffffffffc0205452 <do_fork+0x3a2>
    return &pages[PPN(pa) - nbase];
ffffffffc0205418:	00004717          	auipc	a4,0x4
ffffffffc020541c:	b9073703          	ld	a4,-1136(a4) # ffffffffc0208fa8 <nbase>
ffffffffc0205420:	000a0517          	auipc	a0,0xa0
ffffffffc0205424:	00853503          	ld	a0,8(a0) # ffffffffc02a5428 <pages>
ffffffffc0205428:	4589                	li	a1,2
ffffffffc020542a:	8f99                	sub	a5,a5,a4
ffffffffc020542c:	079a                	slli	a5,a5,0x6
ffffffffc020542e:	953e                	add	a0,a0,a5
ffffffffc0205430:	963fc0ef          	jal	ffffffffc0201d92 <free_pages>
}
ffffffffc0205434:	b765                	j	ffffffffc02053dc <do_fork+0x32c>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205436:	556d                	li	a0,-5
}
ffffffffc0205438:	8082                	ret
        panic("Unlock failed.\n");
ffffffffc020543a:	00003617          	auipc	a2,0x3
ffffffffc020543e:	1fe60613          	addi	a2,a2,510 # ffffffffc0208638 <etext+0x1d7e>
ffffffffc0205442:	03100593          	li	a1,49
ffffffffc0205446:	00003517          	auipc	a0,0x3
ffffffffc020544a:	20250513          	addi	a0,a0,514 # ffffffffc0208648 <etext+0x1d8e>
ffffffffc020544e:	822fb0ef          	jal	ffffffffc0200470 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205452:	00002617          	auipc	a2,0x2
ffffffffc0205456:	1de60613          	addi	a2,a2,478 # ffffffffc0207630 <etext+0xd76>
ffffffffc020545a:	06200593          	li	a1,98
ffffffffc020545e:	00002517          	auipc	a0,0x2
ffffffffc0205462:	12a50513          	addi	a0,a0,298 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205466:	f456                	sd	s5,40(sp)
ffffffffc0205468:	f05a                	sd	s6,32(sp)
ffffffffc020546a:	ec5e                	sd	s7,24(sp)
ffffffffc020546c:	e862                	sd	s8,16(sp)
ffffffffc020546e:	e466                	sd	s9,8(sp)
ffffffffc0205470:	e06a                	sd	s10,0(sp)
ffffffffc0205472:	ffffa0ef          	jal	ffffffffc0200470 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205476:	00002617          	auipc	a2,0x2
ffffffffc020547a:	19260613          	addi	a2,a2,402 # ffffffffc0207608 <etext+0xd4e>
ffffffffc020547e:	06e00593          	li	a1,110
ffffffffc0205482:	00002517          	auipc	a0,0x2
ffffffffc0205486:	10650513          	addi	a0,a0,262 # ffffffffc0207588 <etext+0xcce>
ffffffffc020548a:	f456                	sd	s5,40(sp)
ffffffffc020548c:	f05a                	sd	s6,32(sp)
ffffffffc020548e:	ec5e                	sd	s7,24(sp)
ffffffffc0205490:	e862                	sd	s8,16(sp)
ffffffffc0205492:	e466                	sd	s9,8(sp)
ffffffffc0205494:	e06a                	sd	s10,0(sp)
ffffffffc0205496:	fdbfa0ef          	jal	ffffffffc0200470 <__panic>
    assert(current->wait_state == 0); // 确保当前进程的等待状态为0
ffffffffc020549a:	00003697          	auipc	a3,0x3
ffffffffc020549e:	17e68693          	addi	a3,a3,382 # ffffffffc0208618 <etext+0x1d5e>
ffffffffc02054a2:	00002617          	auipc	a2,0x2
ffffffffc02054a6:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02054aa:	1ac00593          	li	a1,428
ffffffffc02054ae:	00003517          	auipc	a0,0x3
ffffffffc02054b2:	15250513          	addi	a0,a0,338 # ffffffffc0208600 <etext+0x1d46>
ffffffffc02054b6:	f456                	sd	s5,40(sp)
ffffffffc02054b8:	f05a                	sd	s6,32(sp)
ffffffffc02054ba:	ec5e                	sd	s7,24(sp)
ffffffffc02054bc:	e862                	sd	s8,16(sp)
ffffffffc02054be:	e466                	sd	s9,8(sp)
ffffffffc02054c0:	e06a                	sd	s10,0(sp)
ffffffffc02054c2:	faffa0ef          	jal	ffffffffc0200470 <__panic>
    return KADDR(page2pa(page));
ffffffffc02054c6:	00002617          	auipc	a2,0x2
ffffffffc02054ca:	09a60613          	addi	a2,a2,154 # ffffffffc0207560 <etext+0xca6>
ffffffffc02054ce:	06900593          	li	a1,105
ffffffffc02054d2:	00002517          	auipc	a0,0x2
ffffffffc02054d6:	0b650513          	addi	a0,a0,182 # ffffffffc0207588 <etext+0xcce>
ffffffffc02054da:	f456                	sd	s5,40(sp)
ffffffffc02054dc:	f95fa0ef          	jal	ffffffffc0200470 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02054e0:	86be                	mv	a3,a5
ffffffffc02054e2:	00002617          	auipc	a2,0x2
ffffffffc02054e6:	12660613          	addi	a2,a2,294 # ffffffffc0207608 <etext+0xd4e>
ffffffffc02054ea:	16000593          	li	a1,352
ffffffffc02054ee:	00003517          	auipc	a0,0x3
ffffffffc02054f2:	11250513          	addi	a0,a0,274 # ffffffffc0208600 <etext+0x1d46>
ffffffffc02054f6:	f456                	sd	s5,40(sp)
ffffffffc02054f8:	f79fa0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc02054fc:	00002617          	auipc	a2,0x2
ffffffffc0205500:	06460613          	addi	a2,a2,100 # ffffffffc0207560 <etext+0xca6>
ffffffffc0205504:	06900593          	li	a1,105
ffffffffc0205508:	00002517          	auipc	a0,0x2
ffffffffc020550c:	08050513          	addi	a0,a0,128 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205510:	f61fa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0205514 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205514:	7129                	addi	sp,sp,-320
ffffffffc0205516:	fa22                	sd	s0,304(sp)
ffffffffc0205518:	f626                	sd	s1,296(sp)
ffffffffc020551a:	f24a                	sd	s2,288(sp)
ffffffffc020551c:	84ae                	mv	s1,a1
ffffffffc020551e:	892a                	mv	s2,a0
ffffffffc0205520:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205522:	850a                	mv	a0,sp
ffffffffc0205524:	12000613          	li	a2,288
ffffffffc0205528:	4581                	li	a1,0
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020552a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020552c:	364010ef          	jal	ffffffffc0206890 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205530:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205532:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205534:	100027f3          	csrr	a5,sstatus
ffffffffc0205538:	edd7f793          	andi	a5,a5,-291
ffffffffc020553c:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205540:	860a                	mv	a2,sp
ffffffffc0205542:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205546:	00000717          	auipc	a4,0x0
ffffffffc020554a:	98270713          	addi	a4,a4,-1662 # ffffffffc0204ec8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020554e:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0205550:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205552:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205554:	b5dff0ef          	jal	ffffffffc02050b0 <do_fork>
}
ffffffffc0205558:	70f2                	ld	ra,312(sp)
ffffffffc020555a:	7452                	ld	s0,304(sp)
ffffffffc020555c:	74b2                	ld	s1,296(sp)
ffffffffc020555e:	7912                	ld	s2,288(sp)
ffffffffc0205560:	6131                	addi	sp,sp,320
ffffffffc0205562:	8082                	ret

ffffffffc0205564 <do_exit>:
do_exit(int error_code) {
ffffffffc0205564:	7179                	addi	sp,sp,-48
ffffffffc0205566:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc0205568:	000a0417          	auipc	s0,0xa0
ffffffffc020556c:	ef840413          	addi	s0,s0,-264 # ffffffffc02a5460 <current>
ffffffffc0205570:	601c                	ld	a5,0(s0)
ffffffffc0205572:	000a0717          	auipc	a4,0xa0
ffffffffc0205576:	efe73703          	ld	a4,-258(a4) # ffffffffc02a5470 <idleproc>
do_exit(int error_code) {
ffffffffc020557a:	f406                	sd	ra,40(sp)
ffffffffc020557c:	ec26                	sd	s1,24(sp)
    if (current == idleproc) {
ffffffffc020557e:	0ce78d63          	beq	a5,a4,ffffffffc0205658 <do_exit+0xf4>
    if (current == initproc) {
ffffffffc0205582:	000a0497          	auipc	s1,0xa0
ffffffffc0205586:	ee648493          	addi	s1,s1,-282 # ffffffffc02a5468 <initproc>
ffffffffc020558a:	6098                	ld	a4,0(s1)
ffffffffc020558c:	e84a                	sd	s2,16(sp)
ffffffffc020558e:	e44e                	sd	s3,8(sp)
ffffffffc0205590:	e052                	sd	s4,0(sp)
ffffffffc0205592:	0ee78c63          	beq	a5,a4,ffffffffc020568a <do_exit+0x126>
    struct mm_struct *mm = current->mm;
ffffffffc0205596:	0287b983          	ld	s3,40(a5)
ffffffffc020559a:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc020559c:	02098563          	beqz	s3,ffffffffc02055c6 <do_exit+0x62>
ffffffffc02055a0:	000a0797          	auipc	a5,0xa0
ffffffffc02055a4:	e687b783          	ld	a5,-408(a5) # ffffffffc02a5408 <boot_cr3>
ffffffffc02055a8:	577d                	li	a4,-1
ffffffffc02055aa:	177e                	slli	a4,a4,0x3f
ffffffffc02055ac:	83b1                	srli	a5,a5,0xc
ffffffffc02055ae:	8fd9                	or	a5,a5,a4
ffffffffc02055b0:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02055b4:	0309a783          	lw	a5,48(s3)
ffffffffc02055b8:	37fd                	addiw	a5,a5,-1
ffffffffc02055ba:	02f9a823          	sw	a5,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02055be:	cfc5                	beqz	a5,ffffffffc0205676 <do_exit+0x112>
        current->mm = NULL;
ffffffffc02055c0:	601c                	ld	a5,0(s0)
ffffffffc02055c2:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02055c6:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc02055c8:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02055cc:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055ce:	100027f3          	csrr	a5,sstatus
ffffffffc02055d2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055d4:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055d6:	e7f1                	bnez	a5,ffffffffc02056a2 <do_exit+0x13e>
        proc = current->parent;
ffffffffc02055d8:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055da:	800007b7          	lui	a5,0x80000
ffffffffc02055de:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_cow_out_size+0xffffffff7fff3159>
        proc = current->parent;
ffffffffc02055e0:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055e2:	0ec52703          	lw	a4,236(a0)
ffffffffc02055e6:	0cf70263          	beq	a4,a5,ffffffffc02056aa <do_exit+0x146>
        while (current->cptr != NULL) {
ffffffffc02055ea:	6018                	ld	a4,0(s0)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055ec:	800009b7          	lui	s3,0x80000
ffffffffc02055f0:	0985                	addi	s3,s3,1 # ffffffff80000001 <_binary_obj___user_cow_out_size+0xffffffff7fff3159>
        while (current->cptr != NULL) {
ffffffffc02055f2:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055f4:	490d                	li	s2,3
        while (current->cptr != NULL) {
ffffffffc02055f6:	e789                	bnez	a5,ffffffffc0205600 <do_exit+0x9c>
ffffffffc02055f8:	a81d                	j	ffffffffc020562e <do_exit+0xca>
ffffffffc02055fa:	6018                	ld	a4,0(s0)
ffffffffc02055fc:	7b7c                	ld	a5,240(a4)
ffffffffc02055fe:	cb85                	beqz	a5,ffffffffc020562e <do_exit+0xca>
            current->cptr = proc->optr;
ffffffffc0205600:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205604:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205606:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205608:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020560a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020560e:	10e7b023          	sd	a4,256(a5)
ffffffffc0205612:	c311                	beqz	a4,ffffffffc0205616 <do_exit+0xb2>
                initproc->cptr->yptr = proc;
ffffffffc0205614:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205616:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205618:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020561a:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020561c:	fd271fe3          	bne	a4,s2,ffffffffc02055fa <do_exit+0x96>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205620:	0ec52783          	lw	a5,236(a0)
ffffffffc0205624:	fd379be3          	bne	a5,s3,ffffffffc02055fa <do_exit+0x96>
                    wakeup_proc(initproc);
ffffffffc0205628:	3e9000ef          	jal	ffffffffc0206210 <wakeup_proc>
ffffffffc020562c:	b7f9                	j	ffffffffc02055fa <do_exit+0x96>
    if (flag) {
ffffffffc020562e:	020a1263          	bnez	s4,ffffffffc0205652 <do_exit+0xee>
    schedule();
ffffffffc0205632:	479000ef          	jal	ffffffffc02062aa <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205636:	601c                	ld	a5,0(s0)
ffffffffc0205638:	00003617          	auipc	a2,0x3
ffffffffc020563c:	04860613          	addi	a2,a2,72 # ffffffffc0208680 <etext+0x1dc6>
ffffffffc0205640:	1fa00593          	li	a1,506
ffffffffc0205644:	43d4                	lw	a3,4(a5)
ffffffffc0205646:	00003517          	auipc	a0,0x3
ffffffffc020564a:	fba50513          	addi	a0,a0,-70 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020564e:	e23fa0ef          	jal	ffffffffc0200470 <__panic>
        intr_enable();
ffffffffc0205652:	fe9fa0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc0205656:	bff1                	j	ffffffffc0205632 <do_exit+0xce>
        panic("idleproc exit.\n");
ffffffffc0205658:	00003617          	auipc	a2,0x3
ffffffffc020565c:	00860613          	addi	a2,a2,8 # ffffffffc0208660 <etext+0x1da6>
ffffffffc0205660:	1ce00593          	li	a1,462
ffffffffc0205664:	00003517          	auipc	a0,0x3
ffffffffc0205668:	f9c50513          	addi	a0,a0,-100 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020566c:	e84a                	sd	s2,16(sp)
ffffffffc020566e:	e44e                	sd	s3,8(sp)
ffffffffc0205670:	e052                	sd	s4,0(sp)
ffffffffc0205672:	dfffa0ef          	jal	ffffffffc0200470 <__panic>
            exit_mmap(mm);
ffffffffc0205676:	854e                	mv	a0,s3
ffffffffc0205678:	ea1fe0ef          	jal	ffffffffc0204518 <exit_mmap>
            put_pgdir(mm);
ffffffffc020567c:	854e                	mv	a0,s3
ffffffffc020567e:	951ff0ef          	jal	ffffffffc0204fce <put_pgdir>
            mm_destroy(mm);
ffffffffc0205682:	854e                	mv	a0,s3
ffffffffc0205684:	cddfe0ef          	jal	ffffffffc0204360 <mm_destroy>
ffffffffc0205688:	bf25                	j	ffffffffc02055c0 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020568a:	00003617          	auipc	a2,0x3
ffffffffc020568e:	fe660613          	addi	a2,a2,-26 # ffffffffc0208670 <etext+0x1db6>
ffffffffc0205692:	1d100593          	li	a1,465
ffffffffc0205696:	00003517          	auipc	a0,0x3
ffffffffc020569a:	f6a50513          	addi	a0,a0,-150 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020569e:	dd3fa0ef          	jal	ffffffffc0200470 <__panic>
        intr_disable();
ffffffffc02056a2:	f9ffa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc02056a6:	4a05                	li	s4,1
ffffffffc02056a8:	bf05                	j	ffffffffc02055d8 <do_exit+0x74>
            wakeup_proc(proc);
ffffffffc02056aa:	367000ef          	jal	ffffffffc0206210 <wakeup_proc>
ffffffffc02056ae:	bf35                	j	ffffffffc02055ea <do_exit+0x86>

ffffffffc02056b0 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02056b0:	7179                	addi	sp,sp,-48
ffffffffc02056b2:	ec26                	sd	s1,24(sp)
ffffffffc02056b4:	e84a                	sd	s2,16(sp)
ffffffffc02056b6:	e44e                	sd	s3,8(sp)
ffffffffc02056b8:	f406                	sd	ra,40(sp)
ffffffffc02056ba:	f022                	sd	s0,32(sp)
ffffffffc02056bc:	84aa                	mv	s1,a0
ffffffffc02056be:	892e                	mv	s2,a1
ffffffffc02056c0:	000a0997          	auipc	s3,0xa0
ffffffffc02056c4:	da098993          	addi	s3,s3,-608 # ffffffffc02a5460 <current>
    if (pid != 0) {
ffffffffc02056c8:	cd19                	beqz	a0,ffffffffc02056e6 <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02056ca:	6789                	lui	a5,0x2
ffffffffc02056cc:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6072>
ffffffffc02056ce:	fff5071b          	addiw	a4,a0,-1
ffffffffc02056d2:	12e7f363          	bgeu	a5,a4,ffffffffc02057f8 <do_wait.part.0+0x148>
}
ffffffffc02056d6:	70a2                	ld	ra,40(sp)
ffffffffc02056d8:	7402                	ld	s0,32(sp)
ffffffffc02056da:	64e2                	ld	s1,24(sp)
ffffffffc02056dc:	6942                	ld	s2,16(sp)
ffffffffc02056de:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc02056e0:	5579                	li	a0,-2
}
ffffffffc02056e2:	6145                	addi	sp,sp,48
ffffffffc02056e4:	8082                	ret
        proc = current->cptr;
ffffffffc02056e6:	0009b703          	ld	a4,0(s3)
ffffffffc02056ea:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02056ec:	d46d                	beqz	s0,ffffffffc02056d6 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056ee:	468d                	li	a3,3
ffffffffc02056f0:	a021                	j	ffffffffc02056f8 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02056f2:	10043403          	ld	s0,256(s0)
ffffffffc02056f6:	c065                	beqz	s0,ffffffffc02057d6 <do_wait.part.0+0x126>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056f8:	401c                	lw	a5,0(s0)
ffffffffc02056fa:	fed79ce3          	bne	a5,a3,ffffffffc02056f2 <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc) {
ffffffffc02056fe:	000a0797          	auipc	a5,0xa0
ffffffffc0205702:	d727b783          	ld	a5,-654(a5) # ffffffffc02a5470 <idleproc>
ffffffffc0205706:	14878063          	beq	a5,s0,ffffffffc0205846 <do_wait.part.0+0x196>
ffffffffc020570a:	000a0797          	auipc	a5,0xa0
ffffffffc020570e:	d5e7b783          	ld	a5,-674(a5) # ffffffffc02a5468 <initproc>
ffffffffc0205712:	12f40a63          	beq	s0,a5,ffffffffc0205846 <do_wait.part.0+0x196>
    if (code_store != NULL) {
ffffffffc0205716:	00090663          	beqz	s2,ffffffffc0205722 <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc020571a:	0e842783          	lw	a5,232(s0)
ffffffffc020571e:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205722:	100027f3          	csrr	a5,sstatus
ffffffffc0205726:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205728:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020572a:	10079763          	bnez	a5,ffffffffc0205838 <do_wait.part.0+0x188>
    __list_del(listelm->prev, listelm->next);
ffffffffc020572e:	6c74                	ld	a3,216(s0)
ffffffffc0205730:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205732:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc0205736:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0205738:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc020573a:	6474                	ld	a3,200(s0)
ffffffffc020573c:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc020573e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0205740:	e314                	sd	a3,0(a4)
ffffffffc0205742:	c399                	beqz	a5,ffffffffc0205748 <do_wait.part.0+0x98>
        proc->optr->yptr = proc->yptr;
ffffffffc0205744:	7c78                	ld	a4,248(s0)
ffffffffc0205746:	fff8                	sd	a4,248(a5)
    if (proc->yptr != NULL) {
ffffffffc0205748:	7c78                	ld	a4,248(s0)
ffffffffc020574a:	c36d                	beqz	a4,ffffffffc020582c <do_wait.part.0+0x17c>
        proc->yptr->optr = proc->optr;
ffffffffc020574c:	10f73023          	sd	a5,256(a4)
    nr_process --;
ffffffffc0205750:	000a0797          	auipc	a5,0xa0
ffffffffc0205754:	d087a783          	lw	a5,-760(a5) # ffffffffc02a5458 <nr_process>
ffffffffc0205758:	37fd                	addiw	a5,a5,-1
ffffffffc020575a:	000a0717          	auipc	a4,0xa0
ffffffffc020575e:	cef72f23          	sw	a5,-770(a4) # ffffffffc02a5458 <nr_process>
    if (flag) {
ffffffffc0205762:	e271                	bnez	a2,ffffffffc0205826 <do_wait.part.0+0x176>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205764:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205766:	c02007b7          	lui	a5,0xc0200
ffffffffc020576a:	10f6e663          	bltu	a3,a5,ffffffffc0205876 <do_wait.part.0+0x1c6>
ffffffffc020576e:	000a0717          	auipc	a4,0xa0
ffffffffc0205772:	caa73703          	ld	a4,-854(a4) # ffffffffc02a5418 <va_pa_offset>
    if (PPN(pa) >= npage) {
ffffffffc0205776:	000a0797          	auipc	a5,0xa0
ffffffffc020577a:	caa7b783          	ld	a5,-854(a5) # ffffffffc02a5420 <npage>
    return pa2page(PADDR(kva));
ffffffffc020577e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205780:	82b1                	srli	a3,a3,0xc
ffffffffc0205782:	0cf6fe63          	bgeu	a3,a5,ffffffffc020585e <do_wait.part.0+0x1ae>
    return &pages[PPN(pa) - nbase];
ffffffffc0205786:	00004797          	auipc	a5,0x4
ffffffffc020578a:	8227b783          	ld	a5,-2014(a5) # ffffffffc0208fa8 <nbase>
ffffffffc020578e:	000a0517          	auipc	a0,0xa0
ffffffffc0205792:	c9a53503          	ld	a0,-870(a0) # ffffffffc02a5428 <pages>
ffffffffc0205796:	4589                	li	a1,2
ffffffffc0205798:	8e9d                	sub	a3,a3,a5
ffffffffc020579a:	069a                	slli	a3,a3,0x6
ffffffffc020579c:	9536                	add	a0,a0,a3
ffffffffc020579e:	df4fc0ef          	jal	ffffffffc0201d92 <free_pages>
    kfree(proc);
ffffffffc02057a2:	8522                	mv	a0,s0
ffffffffc02057a4:	c54fc0ef          	jal	ffffffffc0201bf8 <kfree>
}
ffffffffc02057a8:	70a2                	ld	ra,40(sp)
ffffffffc02057aa:	7402                	ld	s0,32(sp)
ffffffffc02057ac:	64e2                	ld	s1,24(sp)
ffffffffc02057ae:	6942                	ld	s2,16(sp)
ffffffffc02057b0:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc02057b2:	4501                	li	a0,0
}
ffffffffc02057b4:	6145                	addi	sp,sp,48
ffffffffc02057b6:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02057b8:	000a0997          	auipc	s3,0xa0
ffffffffc02057bc:	ca898993          	addi	s3,s3,-856 # ffffffffc02a5460 <current>
ffffffffc02057c0:	0009b703          	ld	a4,0(s3)
ffffffffc02057c4:	f487b683          	ld	a3,-184(a5)
ffffffffc02057c8:	f0e697e3          	bne	a3,a4,ffffffffc02056d6 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02057cc:	f287a603          	lw	a2,-216(a5)
ffffffffc02057d0:	468d                	li	a3,3
ffffffffc02057d2:	06d60063          	beq	a2,a3,ffffffffc0205832 <do_wait.part.0+0x182>
        current->wait_state = WT_CHILD;
ffffffffc02057d6:	800007b7          	lui	a5,0x80000
ffffffffc02057da:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_cow_out_size+0xffffffff7fff3159>
        current->state = PROC_SLEEPING;
ffffffffc02057dc:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc02057de:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc02057e2:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc02057e4:	2c7000ef          	jal	ffffffffc02062aa <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02057e8:	0009b783          	ld	a5,0(s3)
ffffffffc02057ec:	0b07a783          	lw	a5,176(a5)
ffffffffc02057f0:	8b85                	andi	a5,a5,1
ffffffffc02057f2:	e7b9                	bnez	a5,ffffffffc0205840 <do_wait.part.0+0x190>
    if (pid != 0) {
ffffffffc02057f4:	ee0489e3          	beqz	s1,ffffffffc02056e6 <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02057f8:	45a9                	li	a1,10
ffffffffc02057fa:	8526                	mv	a0,s1
ffffffffc02057fc:	417000ef          	jal	ffffffffc0206412 <hash32>
ffffffffc0205800:	02051793          	slli	a5,a0,0x20
ffffffffc0205804:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205808:	0009c797          	auipc	a5,0x9c
ffffffffc020580c:	bc878793          	addi	a5,a5,-1080 # ffffffffc02a13d0 <hash_list>
ffffffffc0205810:	96be                	add	a3,a3,a5
ffffffffc0205812:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205814:	a029                	j	ffffffffc020581e <do_wait.part.0+0x16e>
            if (proc->pid == pid) {
ffffffffc0205816:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020581a:	f8970fe3          	beq	a4,s1,ffffffffc02057b8 <do_wait.part.0+0x108>
    return listelm->next;
ffffffffc020581e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205820:	fef69be3          	bne	a3,a5,ffffffffc0205816 <do_wait.part.0+0x166>
ffffffffc0205824:	bd4d                	j	ffffffffc02056d6 <do_wait.part.0+0x26>
        intr_enable();
ffffffffc0205826:	e15fa0ef          	jal	ffffffffc020063a <intr_enable>
ffffffffc020582a:	bf2d                	j	ffffffffc0205764 <do_wait.part.0+0xb4>
       proc->parent->cptr = proc->optr;
ffffffffc020582c:	7018                	ld	a4,32(s0)
ffffffffc020582e:	fb7c                	sd	a5,240(a4)
ffffffffc0205830:	b705                	j	ffffffffc0205750 <do_wait.part.0+0xa0>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205832:	f2878413          	addi	s0,a5,-216
ffffffffc0205836:	b5e1                	j	ffffffffc02056fe <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc0205838:	e09fa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc020583c:	4605                	li	a2,1
ffffffffc020583e:	bdc5                	j	ffffffffc020572e <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc0205840:	555d                	li	a0,-9
ffffffffc0205842:	d23ff0ef          	jal	ffffffffc0205564 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc0205846:	00003617          	auipc	a2,0x3
ffffffffc020584a:	e5a60613          	addi	a2,a2,-422 # ffffffffc02086a0 <etext+0x1de6>
ffffffffc020584e:	2f200593          	li	a1,754
ffffffffc0205852:	00003517          	auipc	a0,0x3
ffffffffc0205856:	dae50513          	addi	a0,a0,-594 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020585a:	c17fa0ef          	jal	ffffffffc0200470 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020585e:	00002617          	auipc	a2,0x2
ffffffffc0205862:	dd260613          	addi	a2,a2,-558 # ffffffffc0207630 <etext+0xd76>
ffffffffc0205866:	06200593          	li	a1,98
ffffffffc020586a:	00002517          	auipc	a0,0x2
ffffffffc020586e:	d1e50513          	addi	a0,a0,-738 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205872:	bfffa0ef          	jal	ffffffffc0200470 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205876:	00002617          	auipc	a2,0x2
ffffffffc020587a:	d9260613          	addi	a2,a2,-622 # ffffffffc0207608 <etext+0xd4e>
ffffffffc020587e:	06e00593          	li	a1,110
ffffffffc0205882:	00002517          	auipc	a0,0x2
ffffffffc0205886:	d0650513          	addi	a0,a0,-762 # ffffffffc0207588 <etext+0xcce>
ffffffffc020588a:	be7fa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc020588e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020588e:	1141                	addi	sp,sp,-16
ffffffffc0205890:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205892:	d40fc0ef          	jal	ffffffffc0201dd2 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205896:	a9afc0ef          	jal	ffffffffc0201b30 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020589a:	4601                	li	a2,0
ffffffffc020589c:	4581                	li	a1,0
ffffffffc020589e:	fffff517          	auipc	a0,0xfffff
ffffffffc02058a2:	6b250513          	addi	a0,a0,1714 # ffffffffc0204f50 <user_main>
ffffffffc02058a6:	c6fff0ef          	jal	ffffffffc0205514 <kernel_thread>
    if (pid <= 0) {
ffffffffc02058aa:	00a04563          	bgtz	a0,ffffffffc02058b4 <init_main+0x26>
ffffffffc02058ae:	a071                	j	ffffffffc020593a <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02058b0:	1fb000ef          	jal	ffffffffc02062aa <schedule>
    if (code_store != NULL) {
ffffffffc02058b4:	4581                	li	a1,0
ffffffffc02058b6:	4501                	li	a0,0
ffffffffc02058b8:	df9ff0ef          	jal	ffffffffc02056b0 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02058bc:	d975                	beqz	a0,ffffffffc02058b0 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02058be:	00003517          	auipc	a0,0x3
ffffffffc02058c2:	e2250513          	addi	a0,a0,-478 # ffffffffc02086e0 <etext+0x1e26>
ffffffffc02058c6:	8cbfa0ef          	jal	ffffffffc0200190 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058ca:	000a0797          	auipc	a5,0xa0
ffffffffc02058ce:	b9e7b783          	ld	a5,-1122(a5) # ffffffffc02a5468 <initproc>
ffffffffc02058d2:	7bf8                	ld	a4,240(a5)
ffffffffc02058d4:	e339                	bnez	a4,ffffffffc020591a <init_main+0x8c>
ffffffffc02058d6:	7ff8                	ld	a4,248(a5)
ffffffffc02058d8:	e329                	bnez	a4,ffffffffc020591a <init_main+0x8c>
ffffffffc02058da:	1007b703          	ld	a4,256(a5)
ffffffffc02058de:	ef15                	bnez	a4,ffffffffc020591a <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02058e0:	000a0697          	auipc	a3,0xa0
ffffffffc02058e4:	b786a683          	lw	a3,-1160(a3) # ffffffffc02a5458 <nr_process>
ffffffffc02058e8:	4709                	li	a4,2
ffffffffc02058ea:	0ae69463          	bne	a3,a4,ffffffffc0205992 <init_main+0x104>
ffffffffc02058ee:	000a0697          	auipc	a3,0xa0
ffffffffc02058f2:	ae268693          	addi	a3,a3,-1310 # ffffffffc02a53d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02058f6:	6698                	ld	a4,8(a3)
ffffffffc02058f8:	0c878793          	addi	a5,a5,200
ffffffffc02058fc:	06f71b63          	bne	a4,a5,ffffffffc0205972 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205900:	629c                	ld	a5,0(a3)
ffffffffc0205902:	04f71863          	bne	a4,a5,ffffffffc0205952 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0205906:	00003517          	auipc	a0,0x3
ffffffffc020590a:	ec250513          	addi	a0,a0,-318 # ffffffffc02087c8 <etext+0x1f0e>
ffffffffc020590e:	883fa0ef          	jal	ffffffffc0200190 <cprintf>
    return 0;
}
ffffffffc0205912:	60a2                	ld	ra,8(sp)
ffffffffc0205914:	4501                	li	a0,0
ffffffffc0205916:	0141                	addi	sp,sp,16
ffffffffc0205918:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020591a:	00003697          	auipc	a3,0x3
ffffffffc020591e:	dee68693          	addi	a3,a3,-530 # ffffffffc0208708 <etext+0x1e4e>
ffffffffc0205922:	00001617          	auipc	a2,0x1
ffffffffc0205926:	61660613          	addi	a2,a2,1558 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020592a:	35a00593          	li	a1,858
ffffffffc020592e:	00003517          	auipc	a0,0x3
ffffffffc0205932:	cd250513          	addi	a0,a0,-814 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205936:	b3bfa0ef          	jal	ffffffffc0200470 <__panic>
        panic("create user_main failed.\n");
ffffffffc020593a:	00003617          	auipc	a2,0x3
ffffffffc020593e:	d8660613          	addi	a2,a2,-634 # ffffffffc02086c0 <etext+0x1e06>
ffffffffc0205942:	35200593          	li	a1,850
ffffffffc0205946:	00003517          	auipc	a0,0x3
ffffffffc020594a:	cba50513          	addi	a0,a0,-838 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020594e:	b23fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205952:	00003697          	auipc	a3,0x3
ffffffffc0205956:	e4668693          	addi	a3,a3,-442 # ffffffffc0208798 <etext+0x1ede>
ffffffffc020595a:	00001617          	auipc	a2,0x1
ffffffffc020595e:	5de60613          	addi	a2,a2,1502 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205962:	35d00593          	li	a1,861
ffffffffc0205966:	00003517          	auipc	a0,0x3
ffffffffc020596a:	c9a50513          	addi	a0,a0,-870 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020596e:	b03fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205972:	00003697          	auipc	a3,0x3
ffffffffc0205976:	df668693          	addi	a3,a3,-522 # ffffffffc0208768 <etext+0x1eae>
ffffffffc020597a:	00001617          	auipc	a2,0x1
ffffffffc020597e:	5be60613          	addi	a2,a2,1470 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205982:	35c00593          	li	a1,860
ffffffffc0205986:	00003517          	auipc	a0,0x3
ffffffffc020598a:	c7a50513          	addi	a0,a0,-902 # ffffffffc0208600 <etext+0x1d46>
ffffffffc020598e:	ae3fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(nr_process == 2);
ffffffffc0205992:	00003697          	auipc	a3,0x3
ffffffffc0205996:	dc668693          	addi	a3,a3,-570 # ffffffffc0208758 <etext+0x1e9e>
ffffffffc020599a:	00001617          	auipc	a2,0x1
ffffffffc020599e:	59e60613          	addi	a2,a2,1438 # ffffffffc0206f38 <etext+0x67e>
ffffffffc02059a2:	35b00593          	li	a1,859
ffffffffc02059a6:	00003517          	auipc	a0,0x3
ffffffffc02059aa:	c5a50513          	addi	a0,a0,-934 # ffffffffc0208600 <etext+0x1d46>
ffffffffc02059ae:	ac3fa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02059b2 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059b2:	7171                	addi	sp,sp,-176
ffffffffc02059b4:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059b6:	000a0d97          	auipc	s11,0xa0
ffffffffc02059ba:	aaad8d93          	addi	s11,s11,-1366 # ffffffffc02a5460 <current>
ffffffffc02059be:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059c2:	e54e                	sd	s3,136(sp)
ffffffffc02059c4:	e94a                	sd	s2,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02059c6:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059ca:	892a                	mv	s2,a0
ffffffffc02059cc:	ed26                	sd	s1,152(sp)
ffffffffc02059ce:	f8da                	sd	s6,112(sp)
ffffffffc02059d0:	84ae                	mv	s1,a1
ffffffffc02059d2:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059d4:	854e                	mv	a0,s3
ffffffffc02059d6:	862e                	mv	a2,a1
ffffffffc02059d8:	4681                	li	a3,0
ffffffffc02059da:	85ca                	mv	a1,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02059dc:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02059de:	af6ff0ef          	jal	ffffffffc0204cd4 <user_mem_check>
ffffffffc02059e2:	44050c63          	beqz	a0,ffffffffc0205e3a <do_execve+0x488>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02059e6:	4641                	li	a2,16
ffffffffc02059e8:	1808                	addi	a0,sp,48
ffffffffc02059ea:	4581                	li	a1,0
ffffffffc02059ec:	6a5000ef          	jal	ffffffffc0206890 <memset>
    if (len > PROC_NAME_LEN) {
ffffffffc02059f0:	47bd                	li	a5,15
ffffffffc02059f2:	8626                	mv	a2,s1
ffffffffc02059f4:	0e97ed63          	bltu	a5,s1,ffffffffc0205aee <do_execve+0x13c>
    memcpy(local_name, name, len);
ffffffffc02059f8:	85ca                	mv	a1,s2
ffffffffc02059fa:	1808                	addi	a0,sp,48
ffffffffc02059fc:	6a7000ef          	jal	ffffffffc02068a2 <memcpy>
    if (mm != NULL) {
ffffffffc0205a00:	0e098e63          	beqz	s3,ffffffffc0205afc <do_execve+0x14a>
        cputs("mm != NULL");
ffffffffc0205a04:	00002517          	auipc	a0,0x2
ffffffffc0205a08:	2ac50513          	addi	a0,a0,684 # ffffffffc0207cb0 <etext+0x13f6>
ffffffffc0205a0c:	fbafa0ef          	jal	ffffffffc02001c6 <cputs>
ffffffffc0205a10:	000a0797          	auipc	a5,0xa0
ffffffffc0205a14:	9f87b783          	ld	a5,-1544(a5) # ffffffffc02a5408 <boot_cr3>
ffffffffc0205a18:	577d                	li	a4,-1
ffffffffc0205a1a:	177e                	slli	a4,a4,0x3f
ffffffffc0205a1c:	83b1                	srli	a5,a5,0xc
ffffffffc0205a1e:	8fd9                	or	a5,a5,a4
ffffffffc0205a20:	18079073          	csrw	satp,a5
ffffffffc0205a24:	0309a783          	lw	a5,48(s3)
ffffffffc0205a28:	37fd                	addiw	a5,a5,-1
ffffffffc0205a2a:	02f9a823          	sw	a5,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205a2e:	2e078663          	beqz	a5,ffffffffc0205d1a <do_execve+0x368>
        current->mm = NULL;
ffffffffc0205a32:	000db783          	ld	a5,0(s11)
ffffffffc0205a36:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205a3a:	fa0fe0ef          	jal	ffffffffc02041da <mm_create>
ffffffffc0205a3e:	84aa                	mv	s1,a0
ffffffffc0205a40:	20050563          	beqz	a0,ffffffffc0205c4a <do_execve+0x298>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205a44:	4505                	li	a0,1
ffffffffc0205a46:	ac4fc0ef          	jal	ffffffffc0201d0a <alloc_pages>
ffffffffc0205a4a:	3e050c63          	beqz	a0,ffffffffc0205e42 <do_execve+0x490>
    return page - pages + nbase;
ffffffffc0205a4e:	e8ea                	sd	s10,80(sp)
ffffffffc0205a50:	000a0d17          	auipc	s10,0xa0
ffffffffc0205a54:	9d8d0d13          	addi	s10,s10,-1576 # ffffffffc02a5428 <pages>
ffffffffc0205a58:	000d3783          	ld	a5,0(s10)
ffffffffc0205a5c:	00003717          	auipc	a4,0x3
ffffffffc0205a60:	54c73703          	ld	a4,1356(a4) # ffffffffc0208fa8 <nbase>
ffffffffc0205a64:	ece6                	sd	s9,88(sp)
ffffffffc0205a66:	40f506b3          	sub	a3,a0,a5
    return KADDR(page2pa(page));
ffffffffc0205a6a:	000a0c97          	auipc	s9,0xa0
ffffffffc0205a6e:	9b6c8c93          	addi	s9,s9,-1610 # ffffffffc02a5420 <npage>
ffffffffc0205a72:	f4de                	sd	s7,104(sp)
    return page - pages + nbase;
ffffffffc0205a74:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a76:	5bfd                	li	s7,-1
ffffffffc0205a78:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0205a7c:	96ba                	add	a3,a3,a4
ffffffffc0205a7e:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a80:	00cbd713          	srli	a4,s7,0xc
ffffffffc0205a84:	f03a                	sd	a4,32(sp)
ffffffffc0205a86:	fcd6                	sd	s5,120(sp)
ffffffffc0205a88:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a8a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a8c:	3cf77e63          	bgeu	a4,a5,ffffffffc0205e68 <do_execve+0x4b6>
ffffffffc0205a90:	000a0a97          	auipc	s5,0xa0
ffffffffc0205a94:	988a8a93          	addi	s5,s5,-1656 # ffffffffc02a5418 <va_pa_offset>
ffffffffc0205a98:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205a9c:	000a0597          	auipc	a1,0xa0
ffffffffc0205aa0:	9745b583          	ld	a1,-1676(a1) # ffffffffc02a5410 <boot_pgdir>
ffffffffc0205aa4:	6605                	lui	a2,0x1
ffffffffc0205aa6:	00f68933          	add	s2,a3,a5
ffffffffc0205aaa:	854a                	mv	a0,s2
ffffffffc0205aac:	5f7000ef          	jal	ffffffffc02068a2 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205ab0:	000b2703          	lw	a4,0(s6)
ffffffffc0205ab4:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205ab8:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205abc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_cow_out_size+0x464b76d7>
ffffffffc0205ac0:	06f70563          	beq	a4,a5,ffffffffc0205b2a <do_execve+0x178>
        ret = -E_INVAL_ELF;
ffffffffc0205ac4:	5961                	li	s2,-8
    put_pgdir(mm);
ffffffffc0205ac6:	8526                	mv	a0,s1
ffffffffc0205ac8:	d06ff0ef          	jal	ffffffffc0204fce <put_pgdir>
ffffffffc0205acc:	7ae6                	ld	s5,120(sp)
ffffffffc0205ace:	7ba6                	ld	s7,104(sp)
ffffffffc0205ad0:	6ce6                	ld	s9,88(sp)
ffffffffc0205ad2:	6d46                	ld	s10,80(sp)
    mm_destroy(mm);
ffffffffc0205ad4:	8526                	mv	a0,s1
ffffffffc0205ad6:	88bfe0ef          	jal	ffffffffc0204360 <mm_destroy>
    do_exit(ret);
ffffffffc0205ada:	854a                	mv	a0,s2
ffffffffc0205adc:	f122                	sd	s0,160(sp)
ffffffffc0205ade:	e152                	sd	s4,128(sp)
ffffffffc0205ae0:	fcd6                	sd	s5,120(sp)
ffffffffc0205ae2:	f4de                	sd	s7,104(sp)
ffffffffc0205ae4:	f0e2                	sd	s8,96(sp)
ffffffffc0205ae6:	ece6                	sd	s9,88(sp)
ffffffffc0205ae8:	e8ea                	sd	s10,80(sp)
ffffffffc0205aea:	a7bff0ef          	jal	ffffffffc0205564 <do_exit>
    if (len > PROC_NAME_LEN) {
ffffffffc0205aee:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc0205af0:	85ca                	mv	a1,s2
ffffffffc0205af2:	1808                	addi	a0,sp,48
ffffffffc0205af4:	5af000ef          	jal	ffffffffc02068a2 <memcpy>
    if (mm != NULL) {
ffffffffc0205af8:	f00996e3          	bnez	s3,ffffffffc0205a04 <do_execve+0x52>
    if (current->mm != NULL) {
ffffffffc0205afc:	000db783          	ld	a5,0(s11)
ffffffffc0205b00:	779c                	ld	a5,40(a5)
ffffffffc0205b02:	df85                	beqz	a5,ffffffffc0205a3a <do_execve+0x88>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205b04:	00003617          	auipc	a2,0x3
ffffffffc0205b08:	ce460613          	addi	a2,a2,-796 # ffffffffc02087e8 <etext+0x1f2e>
ffffffffc0205b0c:	20400593          	li	a1,516
ffffffffc0205b10:	00003517          	auipc	a0,0x3
ffffffffc0205b14:	af050513          	addi	a0,a0,-1296 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205b18:	f122                	sd	s0,160(sp)
ffffffffc0205b1a:	e152                	sd	s4,128(sp)
ffffffffc0205b1c:	fcd6                	sd	s5,120(sp)
ffffffffc0205b1e:	f4de                	sd	s7,104(sp)
ffffffffc0205b20:	f0e2                	sd	s8,96(sp)
ffffffffc0205b22:	ece6                	sd	s9,88(sp)
ffffffffc0205b24:	e8ea                	sd	s10,80(sp)
ffffffffc0205b26:	94bfa0ef          	jal	ffffffffc0200470 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205b2a:	038b5703          	lhu	a4,56(s6)
ffffffffc0205b2e:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205b30:	020b3a03          	ld	s4,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205b34:	00371793          	slli	a5,a4,0x3
ffffffffc0205b38:	8f99                	sub	a5,a5,a4
ffffffffc0205b3a:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205b3c:	9a5a                	add	s4,s4,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205b3e:	97d2                	add	a5,a5,s4
ffffffffc0205b40:	f122                	sd	s0,160(sp)
ffffffffc0205b42:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205b44:	00fa7e63          	bgeu	s4,a5,ffffffffc0205b60 <do_execve+0x1ae>
ffffffffc0205b48:	f0e2                	sd	s8,96(sp)
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205b4a:	000a2783          	lw	a5,0(s4)
ffffffffc0205b4e:	4705                	li	a4,1
ffffffffc0205b50:	0ee78f63          	beq	a5,a4,ffffffffc0205c4e <do_execve+0x29c>
    for (; ph < ph_end; ph ++) {
ffffffffc0205b54:	77a2                	ld	a5,40(sp)
ffffffffc0205b56:	038a0a13          	addi	s4,s4,56
ffffffffc0205b5a:	fefa68e3          	bltu	s4,a5,ffffffffc0205b4a <do_execve+0x198>
ffffffffc0205b5e:	7c06                	ld	s8,96(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205b60:	4701                	li	a4,0
ffffffffc0205b62:	46ad                	li	a3,11
ffffffffc0205b64:	00100637          	lui	a2,0x100
ffffffffc0205b68:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205b6c:	8526                	mv	a0,s1
ffffffffc0205b6e:	845fe0ef          	jal	ffffffffc02043b2 <mm_map>
ffffffffc0205b72:	892a                	mv	s2,a0
ffffffffc0205b74:	18051d63          	bnez	a0,ffffffffc0205d0e <do_execve+0x35c>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205b78:	6c88                	ld	a0,24(s1)
ffffffffc0205b7a:	467d                	li	a2,31
ffffffffc0205b7c:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205b80:	80bfd0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0205b84:	38050163          	beqz	a0,ffffffffc0205f06 <do_execve+0x554>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b88:	6c88                	ld	a0,24(s1)
ffffffffc0205b8a:	467d                	li	a2,31
ffffffffc0205b8c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205b90:	ffafd0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0205b94:	34050863          	beqz	a0,ffffffffc0205ee4 <do_execve+0x532>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b98:	6c88                	ld	a0,24(s1)
ffffffffc0205b9a:	467d                	li	a2,31
ffffffffc0205b9c:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205ba0:	feafd0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0205ba4:	30050f63          	beqz	a0,ffffffffc0205ec2 <do_execve+0x510>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ba8:	6c88                	ld	a0,24(s1)
ffffffffc0205baa:	467d                	li	a2,31
ffffffffc0205bac:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205bb0:	fdafd0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0205bb4:	2e050663          	beqz	a0,ffffffffc0205ea0 <do_execve+0x4ee>
    mm->mm_count += 1;
ffffffffc0205bb8:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205bba:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205bbe:	6c94                	ld	a3,24(s1)
ffffffffc0205bc0:	2785                	addiw	a5,a5,1
ffffffffc0205bc2:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205bc4:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205bc6:	c02007b7          	lui	a5,0xc0200
ffffffffc0205bca:	2af6ee63          	bltu	a3,a5,ffffffffc0205e86 <do_execve+0x4d4>
ffffffffc0205bce:	000ab783          	ld	a5,0(s5)
ffffffffc0205bd2:	577d                	li	a4,-1
ffffffffc0205bd4:	177e                	slli	a4,a4,0x3f
ffffffffc0205bd6:	8e9d                	sub	a3,a3,a5
ffffffffc0205bd8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205bdc:	f654                	sd	a3,168(a2)
ffffffffc0205bde:	8fd9                	or	a5,a5,a4
ffffffffc0205be0:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205be4:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205be6:	4581                	li	a1,0
ffffffffc0205be8:	12000613          	li	a2,288
    uintptr_t sstatus = tf->status;
ffffffffc0205bec:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205bf0:	8522                	mv	a0,s0
ffffffffc0205bf2:	49f000ef          	jal	ffffffffc0206890 <memset>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205bf6:	000db983          	ld	s3,0(s11)
    tf->epc = elf->e_entry;          // 设置异常返回入口，也就是程序的起始位置
ffffffffc0205bfa:	018b3703          	ld	a4,24(s6)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;  // 清除SPP位表示用户态,设置SPIE位使能中断
ffffffffc0205bfe:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;          // 设置用户栈
ffffffffc0205c02:	4785                	li	a5,1
ffffffffc0205c04:	07fe                	slli	a5,a5,0x1f
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c06:	0b498993          	addi	s3,s3,180
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;  // 清除SPP位表示用户态,设置SPIE位使能中断
ffffffffc0205c0a:	0204e493          	ori	s1,s1,32
    tf->epc = elf->e_entry;          // 设置异常返回入口，也就是程序的起始位置
ffffffffc0205c0e:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;          // 设置用户栈
ffffffffc0205c12:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;  // 清除SPP位表示用户态,设置SPIE位使能中断
ffffffffc0205c14:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205c18:	4641                	li	a2,16
ffffffffc0205c1a:	4581                	li	a1,0
ffffffffc0205c1c:	854e                	mv	a0,s3
ffffffffc0205c1e:	473000ef          	jal	ffffffffc0206890 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205c22:	180c                	addi	a1,sp,48
ffffffffc0205c24:	854e                	mv	a0,s3
ffffffffc0205c26:	463d                	li	a2,15
ffffffffc0205c28:	47b000ef          	jal	ffffffffc02068a2 <memcpy>
ffffffffc0205c2c:	740a                	ld	s0,160(sp)
ffffffffc0205c2e:	6a0a                	ld	s4,128(sp)
ffffffffc0205c30:	7ae6                	ld	s5,120(sp)
ffffffffc0205c32:	7ba6                	ld	s7,104(sp)
ffffffffc0205c34:	6ce6                	ld	s9,88(sp)
ffffffffc0205c36:	6d46                	ld	s10,80(sp)
}
ffffffffc0205c38:	70aa                	ld	ra,168(sp)
ffffffffc0205c3a:	64ea                	ld	s1,152(sp)
ffffffffc0205c3c:	69aa                	ld	s3,136(sp)
ffffffffc0205c3e:	7b46                	ld	s6,112(sp)
ffffffffc0205c40:	6da6                	ld	s11,72(sp)
ffffffffc0205c42:	854a                	mv	a0,s2
ffffffffc0205c44:	694a                	ld	s2,144(sp)
ffffffffc0205c46:	614d                	addi	sp,sp,176
ffffffffc0205c48:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0205c4a:	5971                	li	s2,-4
ffffffffc0205c4c:	b579                	j	ffffffffc0205ada <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205c4e:	028a3603          	ld	a2,40(s4)
ffffffffc0205c52:	020a3783          	ld	a5,32(s4)
ffffffffc0205c56:	1ef66a63          	bltu	a2,a5,ffffffffc0205e4a <do_execve+0x498>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c5a:	004a2783          	lw	a5,4(s4)
ffffffffc0205c5e:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c62:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205c66:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c68:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c6a:	c2f1                	beqz	a3,ffffffffc0205d2e <do_execve+0x37c>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205c6c:	1a079f63          	bnez	a5,ffffffffc0205e2a <do_execve+0x478>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c70:	47dd                	li	a5,23
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205c72:	00276693          	ori	a3,a4,2
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205c76:	ec3e                	sd	a5,24(sp)
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205c78:	c709                	beqz	a4,ffffffffc0205c82 <do_execve+0x2d0>
ffffffffc0205c7a:	67e2                	ld	a5,24(sp)
ffffffffc0205c7c:	0087e793          	ori	a5,a5,8
ffffffffc0205c80:	ec3e                	sd	a5,24(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205c82:	010a3583          	ld	a1,16(s4)
ffffffffc0205c86:	4701                	li	a4,0
ffffffffc0205c88:	8526                	mv	a0,s1
ffffffffc0205c8a:	f28fe0ef          	jal	ffffffffc02043b2 <mm_map>
ffffffffc0205c8e:	892a                	mv	s2,a0
ffffffffc0205c90:	1a051b63          	bnez	a0,ffffffffc0205e46 <do_execve+0x494>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c94:	010a3b83          	ld	s7,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c98:	020a3903          	ld	s2,32(s4)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c9c:	008a3983          	ld	s3,8(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ca0:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ca2:	995e                	add	s2,s2,s7
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ca4:	00fbfc33          	and	s8,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ca8:	99da                	add	s3,s3,s6
        while (start < end) {
ffffffffc0205caa:	052be963          	bltu	s7,s2,ffffffffc0205cfc <do_execve+0x34a>
ffffffffc0205cae:	aa41                	j	ffffffffc0205e3e <do_execve+0x48c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205cb0:	6785                	lui	a5,0x1
ffffffffc0205cb2:	418b8533          	sub	a0,s7,s8
ffffffffc0205cb6:	9c3e                	add	s8,s8,a5
            if (end < la) {
ffffffffc0205cb8:	41790633          	sub	a2,s2,s7
ffffffffc0205cbc:	01896463          	bltu	s2,s8,ffffffffc0205cc4 <do_execve+0x312>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205cc0:	417c0633          	sub	a2,s8,s7
    return page - pages + nbase;
ffffffffc0205cc4:	000d3683          	ld	a3,0(s10)
ffffffffc0205cc8:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205cca:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205cce:	40d406b3          	sub	a3,s0,a3
ffffffffc0205cd2:	8699                	srai	a3,a3,0x6
ffffffffc0205cd4:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205cd6:	7782                	ld	a5,32(sp)
ffffffffc0205cd8:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205cdc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205cde:	16b87963          	bgeu	a6,a1,ffffffffc0205e50 <do_execve+0x49e>
ffffffffc0205ce2:	000ab583          	ld	a1,0(s5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205ce6:	e432                	sd	a2,8(sp)
ffffffffc0205ce8:	96ae                	add	a3,a3,a1
ffffffffc0205cea:	9536                	add	a0,a0,a3
ffffffffc0205cec:	85ce                	mv	a1,s3
ffffffffc0205cee:	3b5000ef          	jal	ffffffffc02068a2 <memcpy>
            start += size, from += size;
ffffffffc0205cf2:	6622                	ld	a2,8(sp)
ffffffffc0205cf4:	9bb2                	add	s7,s7,a2
ffffffffc0205cf6:	99b2                	add	s3,s3,a2
        while (start < end) {
ffffffffc0205cf8:	052bf263          	bgeu	s7,s2,ffffffffc0205d3c <do_execve+0x38a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205cfc:	6c88                	ld	a0,24(s1)
ffffffffc0205cfe:	6662                	ld	a2,24(sp)
ffffffffc0205d00:	85e2                	mv	a1,s8
ffffffffc0205d02:	e88fd0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0205d06:	842a                	mv	s0,a0
ffffffffc0205d08:	f545                	bnez	a0,ffffffffc0205cb0 <do_execve+0x2fe>
ffffffffc0205d0a:	7c06                	ld	s8,96(sp)
        ret = -E_NO_MEM;
ffffffffc0205d0c:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc0205d0e:	8526                	mv	a0,s1
ffffffffc0205d10:	809fe0ef          	jal	ffffffffc0204518 <exit_mmap>
ffffffffc0205d14:	740a                	ld	s0,160(sp)
ffffffffc0205d16:	6a0a                	ld	s4,128(sp)
ffffffffc0205d18:	b37d                	j	ffffffffc0205ac6 <do_execve+0x114>
            exit_mmap(mm);
ffffffffc0205d1a:	854e                	mv	a0,s3
ffffffffc0205d1c:	ffcfe0ef          	jal	ffffffffc0204518 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205d20:	854e                	mv	a0,s3
ffffffffc0205d22:	aacff0ef          	jal	ffffffffc0204fce <put_pgdir>
            mm_destroy(mm);
ffffffffc0205d26:	854e                	mv	a0,s3
ffffffffc0205d28:	e38fe0ef          	jal	ffffffffc0204360 <mm_destroy>
ffffffffc0205d2c:	b319                	j	ffffffffc0205a32 <do_execve+0x80>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d2e:	0e078a63          	beqz	a5,ffffffffc0205e22 <do_execve+0x470>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205d32:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205d34:	00176693          	ori	a3,a4,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205d38:	ec3e                	sd	a5,24(sp)
ffffffffc0205d3a:	bf3d                	j	ffffffffc0205c78 <do_execve+0x2c6>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205d3c:	010a3903          	ld	s2,16(s4)
ffffffffc0205d40:	028a3683          	ld	a3,40(s4)
ffffffffc0205d44:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205d46:	078bfb63          	bgeu	s7,s8,ffffffffc0205dbc <do_execve+0x40a>
            if (start == end) {
ffffffffc0205d4a:	e17905e3          	beq	s2,s7,ffffffffc0205b54 <do_execve+0x1a2>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d4e:	6505                	lui	a0,0x1
ffffffffc0205d50:	955e                	add	a0,a0,s7
ffffffffc0205d52:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205d56:	417909b3          	sub	s3,s2,s7
            if (end < la) {
ffffffffc0205d5a:	0d897d63          	bgeu	s2,s8,ffffffffc0205e34 <do_execve+0x482>
    return page - pages + nbase;
ffffffffc0205d5e:	000d3683          	ld	a3,0(s10)
ffffffffc0205d62:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205d64:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205d68:	40d406b3          	sub	a3,s0,a3
ffffffffc0205d6c:	8699                	srai	a3,a3,0x6
ffffffffc0205d6e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205d70:	00c69613          	slli	a2,a3,0xc
ffffffffc0205d74:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d76:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d78:	0cb67c63          	bgeu	a2,a1,ffffffffc0205e50 <do_execve+0x49e>
ffffffffc0205d7c:	000ab583          	ld	a1,0(s5)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d80:	864e                	mv	a2,s3
            start += size;
ffffffffc0205d82:	99de                	add	s3,s3,s7
ffffffffc0205d84:	96ae                	add	a3,a3,a1
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d86:	9536                	add	a0,a0,a3
ffffffffc0205d88:	4581                	li	a1,0
ffffffffc0205d8a:	307000ef          	jal	ffffffffc0206890 <memset>
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d8e:	03897463          	bgeu	s2,s8,ffffffffc0205db6 <do_execve+0x404>
ffffffffc0205d92:	dd3901e3          	beq	s2,s3,ffffffffc0205b54 <do_execve+0x1a2>
ffffffffc0205d96:	00003697          	auipc	a3,0x3
ffffffffc0205d9a:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0208810 <etext+0x1f56>
ffffffffc0205d9e:	00001617          	auipc	a2,0x1
ffffffffc0205da2:	19a60613          	addi	a2,a2,410 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205da6:	25900593          	li	a1,601
ffffffffc0205daa:	00003517          	auipc	a0,0x3
ffffffffc0205dae:	85650513          	addi	a0,a0,-1962 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205db2:	ebefa0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0205db6:	ff8990e3          	bne	s3,s8,ffffffffc0205d96 <do_execve+0x3e4>
            start += size;
ffffffffc0205dba:	8be2                	mv	s7,s8
        while (start < end) {
ffffffffc0205dbc:	d92bfce3          	bgeu	s7,s2,ffffffffc0205b54 <do_execve+0x1a2>
ffffffffc0205dc0:	56fd                	li	a3,-1
ffffffffc0205dc2:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205dc6:	e43e                	sd	a5,8(sp)
ffffffffc0205dc8:	a0a9                	j	ffffffffc0205e12 <do_execve+0x460>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205dca:	6785                	lui	a5,0x1
ffffffffc0205dcc:	418b8533          	sub	a0,s7,s8
ffffffffc0205dd0:	9c3e                	add	s8,s8,a5
            if (end < la) {
ffffffffc0205dd2:	417909b3          	sub	s3,s2,s7
ffffffffc0205dd6:	01896463          	bltu	s2,s8,ffffffffc0205dde <do_execve+0x42c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205dda:	417c09b3          	sub	s3,s8,s7
    return page - pages + nbase;
ffffffffc0205dde:	000d3683          	ld	a3,0(s10)
ffffffffc0205de2:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205de4:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205de8:	40d406b3          	sub	a3,s0,a3
ffffffffc0205dec:	8699                	srai	a3,a3,0x6
ffffffffc0205dee:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205df0:	67a2                	ld	a5,8(sp)
ffffffffc0205df2:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205df6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205df8:	04b87c63          	bgeu	a6,a1,ffffffffc0205e50 <do_execve+0x49e>
ffffffffc0205dfc:	000ab583          	ld	a1,0(s5)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205e00:	864e                	mv	a2,s3
            start += size;
ffffffffc0205e02:	9bce                	add	s7,s7,s3
ffffffffc0205e04:	96ae                	add	a3,a3,a1
            memset(page2kva(page) + off, 0, size);
ffffffffc0205e06:	9536                	add	a0,a0,a3
ffffffffc0205e08:	4581                	li	a1,0
ffffffffc0205e0a:	287000ef          	jal	ffffffffc0206890 <memset>
        while (start < end) {
ffffffffc0205e0e:	d52bf3e3          	bgeu	s7,s2,ffffffffc0205b54 <do_execve+0x1a2>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205e12:	6c88                	ld	a0,24(s1)
ffffffffc0205e14:	6662                	ld	a2,24(sp)
ffffffffc0205e16:	85e2                	mv	a1,s8
ffffffffc0205e18:	d72fd0ef          	jal	ffffffffc020338a <pgdir_alloc_page>
ffffffffc0205e1c:	842a                	mv	s0,a0
ffffffffc0205e1e:	f555                	bnez	a0,ffffffffc0205dca <do_execve+0x418>
ffffffffc0205e20:	b5ed                	j	ffffffffc0205d0a <do_execve+0x358>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205e22:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205e24:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205e26:	ec3e                	sd	a5,24(sp)
ffffffffc0205e28:	bd81                	j	ffffffffc0205c78 <do_execve+0x2c6>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205e2a:	47dd                	li	a5,23
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205e2c:	00376693          	ori	a3,a4,3
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205e30:	ec3e                	sd	a5,24(sp)
ffffffffc0205e32:	b599                	j	ffffffffc0205c78 <do_execve+0x2c6>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205e34:	417c09b3          	sub	s3,s8,s7
ffffffffc0205e38:	b71d                	j	ffffffffc0205d5e <do_execve+0x3ac>
        return -E_INVAL;
ffffffffc0205e3a:	5975                	li	s2,-3
ffffffffc0205e3c:	bbf5                	j	ffffffffc0205c38 <do_execve+0x286>
        while (start < end) {
ffffffffc0205e3e:	895e                	mv	s2,s7
ffffffffc0205e40:	b701                	j	ffffffffc0205d40 <do_execve+0x38e>
    int ret = -E_NO_MEM;
ffffffffc0205e42:	5971                	li	s2,-4
ffffffffc0205e44:	b941                	j	ffffffffc0205ad4 <do_execve+0x122>
ffffffffc0205e46:	7c06                	ld	s8,96(sp)
ffffffffc0205e48:	b5d9                	j	ffffffffc0205d0e <do_execve+0x35c>
            ret = -E_INVAL_ELF;
ffffffffc0205e4a:	7c06                	ld	s8,96(sp)
ffffffffc0205e4c:	5961                	li	s2,-8
ffffffffc0205e4e:	b5c1                	j	ffffffffc0205d0e <do_execve+0x35c>
ffffffffc0205e50:	00001617          	auipc	a2,0x1
ffffffffc0205e54:	71060613          	addi	a2,a2,1808 # ffffffffc0207560 <etext+0xca6>
ffffffffc0205e58:	06900593          	li	a1,105
ffffffffc0205e5c:	00001517          	auipc	a0,0x1
ffffffffc0205e60:	72c50513          	addi	a0,a0,1836 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205e64:	e0cfa0ef          	jal	ffffffffc0200470 <__panic>
ffffffffc0205e68:	00001617          	auipc	a2,0x1
ffffffffc0205e6c:	6f860613          	addi	a2,a2,1784 # ffffffffc0207560 <etext+0xca6>
ffffffffc0205e70:	06900593          	li	a1,105
ffffffffc0205e74:	00001517          	auipc	a0,0x1
ffffffffc0205e78:	71450513          	addi	a0,a0,1812 # ffffffffc0207588 <etext+0xcce>
ffffffffc0205e7c:	f122                	sd	s0,160(sp)
ffffffffc0205e7e:	e152                	sd	s4,128(sp)
ffffffffc0205e80:	f0e2                	sd	s8,96(sp)
ffffffffc0205e82:	deefa0ef          	jal	ffffffffc0200470 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205e86:	00001617          	auipc	a2,0x1
ffffffffc0205e8a:	78260613          	addi	a2,a2,1922 # ffffffffc0207608 <etext+0xd4e>
ffffffffc0205e8e:	27400593          	li	a1,628
ffffffffc0205e92:	00002517          	auipc	a0,0x2
ffffffffc0205e96:	76e50513          	addi	a0,a0,1902 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205e9a:	f0e2                	sd	s8,96(sp)
ffffffffc0205e9c:	dd4fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ea0:	00003697          	auipc	a3,0x3
ffffffffc0205ea4:	a8868693          	addi	a3,a3,-1400 # ffffffffc0208928 <etext+0x206e>
ffffffffc0205ea8:	00001617          	auipc	a2,0x1
ffffffffc0205eac:	09060613          	addi	a2,a2,144 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205eb0:	26f00593          	li	a1,623
ffffffffc0205eb4:	00002517          	auipc	a0,0x2
ffffffffc0205eb8:	74c50513          	addi	a0,a0,1868 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205ebc:	f0e2                	sd	s8,96(sp)
ffffffffc0205ebe:	db2fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ec2:	00003697          	auipc	a3,0x3
ffffffffc0205ec6:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02088e0 <etext+0x2026>
ffffffffc0205eca:	00001617          	auipc	a2,0x1
ffffffffc0205ece:	06e60613          	addi	a2,a2,110 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205ed2:	26e00593          	li	a1,622
ffffffffc0205ed6:	00002517          	auipc	a0,0x2
ffffffffc0205eda:	72a50513          	addi	a0,a0,1834 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205ede:	f0e2                	sd	s8,96(sp)
ffffffffc0205ee0:	d90fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ee4:	00003697          	auipc	a3,0x3
ffffffffc0205ee8:	9b468693          	addi	a3,a3,-1612 # ffffffffc0208898 <etext+0x1fde>
ffffffffc0205eec:	00001617          	auipc	a2,0x1
ffffffffc0205ef0:	04c60613          	addi	a2,a2,76 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205ef4:	26d00593          	li	a1,621
ffffffffc0205ef8:	00002517          	auipc	a0,0x2
ffffffffc0205efc:	70850513          	addi	a0,a0,1800 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205f00:	f0e2                	sd	s8,96(sp)
ffffffffc0205f02:	d6efa0ef          	jal	ffffffffc0200470 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205f06:	00003697          	auipc	a3,0x3
ffffffffc0205f0a:	94a68693          	addi	a3,a3,-1718 # ffffffffc0208850 <etext+0x1f96>
ffffffffc0205f0e:	00001617          	auipc	a2,0x1
ffffffffc0205f12:	02a60613          	addi	a2,a2,42 # ffffffffc0206f38 <etext+0x67e>
ffffffffc0205f16:	26c00593          	li	a1,620
ffffffffc0205f1a:	00002517          	auipc	a0,0x2
ffffffffc0205f1e:	6e650513          	addi	a0,a0,1766 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0205f22:	f0e2                	sd	s8,96(sp)
ffffffffc0205f24:	d4cfa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0205f28 <do_yield>:
    current->need_resched = 1;
ffffffffc0205f28:	0009f797          	auipc	a5,0x9f
ffffffffc0205f2c:	5387b783          	ld	a5,1336(a5) # ffffffffc02a5460 <current>
ffffffffc0205f30:	4705                	li	a4,1
}
ffffffffc0205f32:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205f34:	ef98                	sd	a4,24(a5)
}
ffffffffc0205f36:	8082                	ret

ffffffffc0205f38 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205f38:	1101                	addi	sp,sp,-32
ffffffffc0205f3a:	e822                	sd	s0,16(sp)
ffffffffc0205f3c:	e426                	sd	s1,8(sp)
ffffffffc0205f3e:	ec06                	sd	ra,24(sp)
ffffffffc0205f40:	842e                	mv	s0,a1
ffffffffc0205f42:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205f44:	c999                	beqz	a1,ffffffffc0205f5a <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205f46:	0009f797          	auipc	a5,0x9f
ffffffffc0205f4a:	51a7b783          	ld	a5,1306(a5) # ffffffffc02a5460 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205f4e:	4685                	li	a3,1
ffffffffc0205f50:	4611                	li	a2,4
ffffffffc0205f52:	7788                	ld	a0,40(a5)
ffffffffc0205f54:	d81fe0ef          	jal	ffffffffc0204cd4 <user_mem_check>
ffffffffc0205f58:	c909                	beqz	a0,ffffffffc0205f6a <do_wait+0x32>
ffffffffc0205f5a:	85a2                	mv	a1,s0
}
ffffffffc0205f5c:	6442                	ld	s0,16(sp)
ffffffffc0205f5e:	60e2                	ld	ra,24(sp)
ffffffffc0205f60:	8526                	mv	a0,s1
ffffffffc0205f62:	64a2                	ld	s1,8(sp)
ffffffffc0205f64:	6105                	addi	sp,sp,32
ffffffffc0205f66:	f4aff06f          	j	ffffffffc02056b0 <do_wait.part.0>
ffffffffc0205f6a:	60e2                	ld	ra,24(sp)
ffffffffc0205f6c:	6442                	ld	s0,16(sp)
ffffffffc0205f6e:	64a2                	ld	s1,8(sp)
ffffffffc0205f70:	5575                	li	a0,-3
ffffffffc0205f72:	6105                	addi	sp,sp,32
ffffffffc0205f74:	8082                	ret

ffffffffc0205f76 <do_kill>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205f76:	6789                	lui	a5,0x2
ffffffffc0205f78:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205f7c:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6072>
ffffffffc0205f7e:	06e7e763          	bltu	a5,a4,ffffffffc0205fec <do_kill+0x76>
do_kill(int pid) {
ffffffffc0205f82:	1141                	addi	sp,sp,-16
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205f84:	45a9                	li	a1,10
do_kill(int pid) {
ffffffffc0205f86:	e022                	sd	s0,0(sp)
ffffffffc0205f88:	e406                	sd	ra,8(sp)
ffffffffc0205f8a:	842a                	mv	s0,a0
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205f8c:	486000ef          	jal	ffffffffc0206412 <hash32>
ffffffffc0205f90:	02051793          	slli	a5,a0,0x20
ffffffffc0205f94:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205f98:	0009b797          	auipc	a5,0x9b
ffffffffc0205f9c:	43878793          	addi	a5,a5,1080 # ffffffffc02a13d0 <hash_list>
ffffffffc0205fa0:	953e                	add	a0,a0,a5
ffffffffc0205fa2:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205fa4:	a029                	j	ffffffffc0205fae <do_kill+0x38>
            if (proc->pid == pid) {
ffffffffc0205fa6:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205faa:	00870a63          	beq	a4,s0,ffffffffc0205fbe <do_kill+0x48>
ffffffffc0205fae:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205fb0:	fef51be3          	bne	a0,a5,ffffffffc0205fa6 <do_kill+0x30>
}
ffffffffc0205fb4:	60a2                	ld	ra,8(sp)
ffffffffc0205fb6:	6402                	ld	s0,0(sp)
    return -E_INVAL;
ffffffffc0205fb8:	5575                	li	a0,-3
}
ffffffffc0205fba:	0141                	addi	sp,sp,16
ffffffffc0205fbc:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205fbe:	fd87a703          	lw	a4,-40(a5)
        return -E_KILLED;
ffffffffc0205fc2:	555d                	li	a0,-9
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205fc4:	00177693          	andi	a3,a4,1
ffffffffc0205fc8:	ea89                	bnez	a3,ffffffffc0205fda <do_kill+0x64>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205fca:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205fcc:	00176713          	ori	a4,a4,1
ffffffffc0205fd0:	fce7ac23          	sw	a4,-40(a5)
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205fd4:	0006c763          	bltz	a3,ffffffffc0205fe2 <do_kill+0x6c>
            return 0;
ffffffffc0205fd8:	4501                	li	a0,0
}
ffffffffc0205fda:	60a2                	ld	ra,8(sp)
ffffffffc0205fdc:	6402                	ld	s0,0(sp)
ffffffffc0205fde:	0141                	addi	sp,sp,16
ffffffffc0205fe0:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205fe2:	f2878513          	addi	a0,a5,-216
ffffffffc0205fe6:	22a000ef          	jal	ffffffffc0206210 <wakeup_proc>
ffffffffc0205fea:	b7fd                	j	ffffffffc0205fd8 <do_kill+0x62>
    return -E_INVAL;
ffffffffc0205fec:	5575                	li	a0,-3
}
ffffffffc0205fee:	8082                	ret

ffffffffc0205ff0 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205ff0:	1101                	addi	sp,sp,-32
ffffffffc0205ff2:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205ff4:	0009f797          	auipc	a5,0x9f
ffffffffc0205ff8:	3dc78793          	addi	a5,a5,988 # ffffffffc02a53d0 <proc_list>
ffffffffc0205ffc:	ec06                	sd	ra,24(sp)
ffffffffc0205ffe:	e822                	sd	s0,16(sp)
ffffffffc0206000:	e04a                	sd	s2,0(sp)
ffffffffc0206002:	0009b497          	auipc	s1,0x9b
ffffffffc0206006:	3ce48493          	addi	s1,s1,974 # ffffffffc02a13d0 <hash_list>
ffffffffc020600a:	e79c                	sd	a5,8(a5)
ffffffffc020600c:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020600e:	0009f717          	auipc	a4,0x9f
ffffffffc0206012:	3c270713          	addi	a4,a4,962 # ffffffffc02a53d0 <proc_list>
ffffffffc0206016:	87a6                	mv	a5,s1
ffffffffc0206018:	e79c                	sd	a5,8(a5)
ffffffffc020601a:	e39c                	sd	a5,0(a5)
ffffffffc020601c:	07c1                	addi	a5,a5,16
ffffffffc020601e:	fee79de3          	bne	a5,a4,ffffffffc0206018 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0206022:	eaffe0ef          	jal	ffffffffc0204ed0 <alloc_proc>
ffffffffc0206026:	0009f917          	auipc	s2,0x9f
ffffffffc020602a:	44a90913          	addi	s2,s2,1098 # ffffffffc02a5470 <idleproc>
ffffffffc020602e:	00a93023          	sd	a0,0(s2)
ffffffffc0206032:	10050163          	beqz	a0,ffffffffc0206134 <proc_init+0x144>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0206036:	4689                	li	a3,2
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0206038:	00003717          	auipc	a4,0x3
ffffffffc020603c:	fc870713          	addi	a4,a4,-56 # ffffffffc0209000 <bootstack>
    idleproc->need_resched = 1;
ffffffffc0206040:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0206042:	0b450413          	addi	s0,a0,180
    idleproc->state = PROC_RUNNABLE;
ffffffffc0206046:	e114                	sd	a3,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0206048:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc020604a:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020604c:	4641                	li	a2,16
ffffffffc020604e:	8522                	mv	a0,s0
ffffffffc0206050:	4581                	li	a1,0
ffffffffc0206052:	03f000ef          	jal	ffffffffc0206890 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0206056:	8522                	mv	a0,s0
ffffffffc0206058:	463d                	li	a2,15
ffffffffc020605a:	00003597          	auipc	a1,0x3
ffffffffc020605e:	92e58593          	addi	a1,a1,-1746 # ffffffffc0208988 <etext+0x20ce>
ffffffffc0206062:	041000ef          	jal	ffffffffc02068a2 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0206066:	0009f797          	auipc	a5,0x9f
ffffffffc020606a:	3f27a783          	lw	a5,1010(a5) # ffffffffc02a5458 <nr_process>

    current = idleproc;
ffffffffc020606e:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206072:	4601                	li	a2,0
    nr_process ++;
ffffffffc0206074:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206076:	4581                	li	a1,0
ffffffffc0206078:	00000517          	auipc	a0,0x0
ffffffffc020607c:	81650513          	addi	a0,a0,-2026 # ffffffffc020588e <init_main>
    current = idleproc;
ffffffffc0206080:	0009f697          	auipc	a3,0x9f
ffffffffc0206084:	3ee6b023          	sd	a4,992(a3) # ffffffffc02a5460 <current>
    nr_process ++;
ffffffffc0206088:	0009f717          	auipc	a4,0x9f
ffffffffc020608c:	3cf72823          	sw	a5,976(a4) # ffffffffc02a5458 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0206090:	c84ff0ef          	jal	ffffffffc0205514 <kernel_thread>
ffffffffc0206094:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0206096:	08a05363          	blez	a0,ffffffffc020611c <proc_init+0x12c>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020609a:	6789                	lui	a5,0x2
ffffffffc020609c:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6072>
ffffffffc020609e:	fff5071b          	addiw	a4,a0,-1
ffffffffc02060a2:	02e7e463          	bltu	a5,a4,ffffffffc02060ca <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02060a6:	45a9                	li	a1,10
ffffffffc02060a8:	36a000ef          	jal	ffffffffc0206412 <hash32>
ffffffffc02060ac:	02051713          	slli	a4,a0,0x20
ffffffffc02060b0:	01c75793          	srli	a5,a4,0x1c
ffffffffc02060b4:	00f486b3          	add	a3,s1,a5
ffffffffc02060b8:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02060ba:	a029                	j	ffffffffc02060c4 <proc_init+0xd4>
            if (proc->pid == pid) {
ffffffffc02060bc:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02060c0:	04870b63          	beq	a4,s0,ffffffffc0206116 <proc_init+0x126>
    return listelm->next;
ffffffffc02060c4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02060c6:	fef69be3          	bne	a3,a5,ffffffffc02060bc <proc_init+0xcc>
    return NULL;
ffffffffc02060ca:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02060cc:	0b478493          	addi	s1,a5,180
ffffffffc02060d0:	4641                	li	a2,16
ffffffffc02060d2:	4581                	li	a1,0
ffffffffc02060d4:	8526                	mv	a0,s1
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02060d6:	0009f417          	auipc	s0,0x9f
ffffffffc02060da:	39240413          	addi	s0,s0,914 # ffffffffc02a5468 <initproc>
ffffffffc02060de:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02060e0:	7b0000ef          	jal	ffffffffc0206890 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02060e4:	8526                	mv	a0,s1
ffffffffc02060e6:	463d                	li	a2,15
ffffffffc02060e8:	00003597          	auipc	a1,0x3
ffffffffc02060ec:	8c858593          	addi	a1,a1,-1848 # ffffffffc02089b0 <etext+0x20f6>
ffffffffc02060f0:	7b2000ef          	jal	ffffffffc02068a2 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02060f4:	00093783          	ld	a5,0(s2)
ffffffffc02060f8:	cbb5                	beqz	a5,ffffffffc020616c <proc_init+0x17c>
ffffffffc02060fa:	43dc                	lw	a5,4(a5)
ffffffffc02060fc:	eba5                	bnez	a5,ffffffffc020616c <proc_init+0x17c>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02060fe:	601c                	ld	a5,0(s0)
ffffffffc0206100:	c7b1                	beqz	a5,ffffffffc020614c <proc_init+0x15c>
ffffffffc0206102:	43d8                	lw	a4,4(a5)
ffffffffc0206104:	4785                	li	a5,1
ffffffffc0206106:	04f71363          	bne	a4,a5,ffffffffc020614c <proc_init+0x15c>
}
ffffffffc020610a:	60e2                	ld	ra,24(sp)
ffffffffc020610c:	6442                	ld	s0,16(sp)
ffffffffc020610e:	64a2                	ld	s1,8(sp)
ffffffffc0206110:	6902                	ld	s2,0(sp)
ffffffffc0206112:	6105                	addi	sp,sp,32
ffffffffc0206114:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0206116:	f2878793          	addi	a5,a5,-216
ffffffffc020611a:	bf4d                	j	ffffffffc02060cc <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc020611c:	00003617          	auipc	a2,0x3
ffffffffc0206120:	87460613          	addi	a2,a2,-1932 # ffffffffc0208990 <etext+0x20d6>
ffffffffc0206124:	37d00593          	li	a1,893
ffffffffc0206128:	00002517          	auipc	a0,0x2
ffffffffc020612c:	4d850513          	addi	a0,a0,1240 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0206130:	b40fa0ef          	jal	ffffffffc0200470 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0206134:	00003617          	auipc	a2,0x3
ffffffffc0206138:	83c60613          	addi	a2,a2,-1988 # ffffffffc0208970 <etext+0x20b6>
ffffffffc020613c:	36f00593          	li	a1,879
ffffffffc0206140:	00002517          	auipc	a0,0x2
ffffffffc0206144:	4c050513          	addi	a0,a0,1216 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0206148:	b28fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020614c:	00003697          	auipc	a3,0x3
ffffffffc0206150:	89468693          	addi	a3,a3,-1900 # ffffffffc02089e0 <etext+0x2126>
ffffffffc0206154:	00001617          	auipc	a2,0x1
ffffffffc0206158:	de460613          	addi	a2,a2,-540 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020615c:	38400593          	li	a1,900
ffffffffc0206160:	00002517          	auipc	a0,0x2
ffffffffc0206164:	4a050513          	addi	a0,a0,1184 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0206168:	b08fa0ef          	jal	ffffffffc0200470 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020616c:	00003697          	auipc	a3,0x3
ffffffffc0206170:	84c68693          	addi	a3,a3,-1972 # ffffffffc02089b8 <etext+0x20fe>
ffffffffc0206174:	00001617          	auipc	a2,0x1
ffffffffc0206178:	dc460613          	addi	a2,a2,-572 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020617c:	38300593          	li	a1,899
ffffffffc0206180:	00002517          	auipc	a0,0x2
ffffffffc0206184:	48050513          	addi	a0,a0,1152 # ffffffffc0208600 <etext+0x1d46>
ffffffffc0206188:	ae8fa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc020618c <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020618c:	1141                	addi	sp,sp,-16
ffffffffc020618e:	e022                	sd	s0,0(sp)
ffffffffc0206190:	e406                	sd	ra,8(sp)
ffffffffc0206192:	0009f417          	auipc	s0,0x9f
ffffffffc0206196:	2ce40413          	addi	s0,s0,718 # ffffffffc02a5460 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020619a:	6018                	ld	a4,0(s0)
ffffffffc020619c:	6f1c                	ld	a5,24(a4)
ffffffffc020619e:	dffd                	beqz	a5,ffffffffc020619c <cpu_idle+0x10>
            schedule();
ffffffffc02061a0:	10a000ef          	jal	ffffffffc02062aa <schedule>
ffffffffc02061a4:	bfdd                	j	ffffffffc020619a <cpu_idle+0xe>

ffffffffc02061a6 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02061a6:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02061aa:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02061ae:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02061b0:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02061b2:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02061b6:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02061ba:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02061be:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02061c2:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02061c6:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02061ca:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02061ce:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02061d2:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02061d6:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02061da:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02061de:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02061e2:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02061e4:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02061e6:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02061ea:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02061ee:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02061f2:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02061f6:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02061fa:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02061fe:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0206202:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206206:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc020620a:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020620e:	8082                	ret

ffffffffc0206210 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206210:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0206212:	1141                	addi	sp,sp,-16
ffffffffc0206214:	e406                	sd	ra,8(sp)
ffffffffc0206216:	e022                	sd	s0,0(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206218:	478d                	li	a5,3
ffffffffc020621a:	06f70963          	beq	a4,a5,ffffffffc020628c <wakeup_proc+0x7c>
ffffffffc020621e:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206220:	100027f3          	csrr	a5,sstatus
ffffffffc0206224:	8b89                	andi	a5,a5,2
ffffffffc0206226:	eb99                	bnez	a5,ffffffffc020623c <wakeup_proc+0x2c>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206228:	4789                	li	a5,2
ffffffffc020622a:	02f70763          	beq	a4,a5,ffffffffc0206258 <wakeup_proc+0x48>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020622e:	60a2                	ld	ra,8(sp)
ffffffffc0206230:	6402                	ld	s0,0(sp)
            proc->state = PROC_RUNNABLE;
ffffffffc0206232:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0206234:	0e052623          	sw	zero,236(a0)
}
ffffffffc0206238:	0141                	addi	sp,sp,16
ffffffffc020623a:	8082                	ret
        intr_disable();
ffffffffc020623c:	c04fa0ef          	jal	ffffffffc0200640 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0206240:	4018                	lw	a4,0(s0)
ffffffffc0206242:	4789                	li	a5,2
ffffffffc0206244:	02f70863          	beq	a4,a5,ffffffffc0206274 <wakeup_proc+0x64>
            proc->state = PROC_RUNNABLE;
ffffffffc0206248:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc020624a:	0e042623          	sw	zero,236(s0)
}
ffffffffc020624e:	6402                	ld	s0,0(sp)
ffffffffc0206250:	60a2                	ld	ra,8(sp)
ffffffffc0206252:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206254:	be6fa06f          	j	ffffffffc020063a <intr_enable>
ffffffffc0206258:	6402                	ld	s0,0(sp)
ffffffffc020625a:	60a2                	ld	ra,8(sp)
            warn("wakeup runnable process.\n");
ffffffffc020625c:	00002617          	auipc	a2,0x2
ffffffffc0206260:	7e460613          	addi	a2,a2,2020 # ffffffffc0208a40 <etext+0x2186>
ffffffffc0206264:	45c9                	li	a1,18
ffffffffc0206266:	00002517          	auipc	a0,0x2
ffffffffc020626a:	7c250513          	addi	a0,a0,1986 # ffffffffc0208a28 <etext+0x216e>
}
ffffffffc020626e:	0141                	addi	sp,sp,16
            warn("wakeup runnable process.\n");
ffffffffc0206270:	a6afa06f          	j	ffffffffc02004da <__warn>
ffffffffc0206274:	00002617          	auipc	a2,0x2
ffffffffc0206278:	7cc60613          	addi	a2,a2,1996 # ffffffffc0208a40 <etext+0x2186>
ffffffffc020627c:	45c9                	li	a1,18
ffffffffc020627e:	00002517          	auipc	a0,0x2
ffffffffc0206282:	7aa50513          	addi	a0,a0,1962 # ffffffffc0208a28 <etext+0x216e>
ffffffffc0206286:	a54fa0ef          	jal	ffffffffc02004da <__warn>
    if (flag) {
ffffffffc020628a:	b7d1                	j	ffffffffc020624e <wakeup_proc+0x3e>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020628c:	00002697          	auipc	a3,0x2
ffffffffc0206290:	77c68693          	addi	a3,a3,1916 # ffffffffc0208a08 <etext+0x214e>
ffffffffc0206294:	00001617          	auipc	a2,0x1
ffffffffc0206298:	ca460613          	addi	a2,a2,-860 # ffffffffc0206f38 <etext+0x67e>
ffffffffc020629c:	45a5                	li	a1,9
ffffffffc020629e:	00002517          	auipc	a0,0x2
ffffffffc02062a2:	78a50513          	addi	a0,a0,1930 # ffffffffc0208a28 <etext+0x216e>
ffffffffc02062a6:	9cafa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc02062aa <schedule>:

void
schedule(void) {
ffffffffc02062aa:	1141                	addi	sp,sp,-16
ffffffffc02062ac:	e406                	sd	ra,8(sp)
ffffffffc02062ae:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02062b0:	100027f3          	csrr	a5,sstatus
ffffffffc02062b4:	8b89                	andi	a5,a5,2
ffffffffc02062b6:	4401                	li	s0,0
ffffffffc02062b8:	efbd                	bnez	a5,ffffffffc0206336 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02062ba:	0009f897          	auipc	a7,0x9f
ffffffffc02062be:	1a68b883          	ld	a7,422(a7) # ffffffffc02a5460 <current>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02062c2:	0009f517          	auipc	a0,0x9f
ffffffffc02062c6:	1ae53503          	ld	a0,430(a0) # ffffffffc02a5470 <idleproc>
        current->need_resched = 0;
ffffffffc02062ca:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02062ce:	04a88e63          	beq	a7,a0,ffffffffc020632a <schedule+0x80>
ffffffffc02062d2:	0c888693          	addi	a3,a7,200
ffffffffc02062d6:	0009f617          	auipc	a2,0x9f
ffffffffc02062da:	0fa60613          	addi	a2,a2,250 # ffffffffc02a53d0 <proc_list>
        le = last;
ffffffffc02062de:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02062e0:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02062e2:	4809                	li	a6,2
ffffffffc02062e4:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02062e6:	00c78863          	beq	a5,a2,ffffffffc02062f6 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02062ea:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02062ee:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02062f2:	03070163          	beq	a4,a6,ffffffffc0206314 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02062f6:	fef697e3          	bne	a3,a5,ffffffffc02062e4 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02062fa:	ed89                	bnez	a1,ffffffffc0206314 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02062fc:	451c                	lw	a5,8(a0)
ffffffffc02062fe:	2785                	addiw	a5,a5,1
ffffffffc0206300:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206302:	00a88463          	beq	a7,a0,ffffffffc020630a <schedule+0x60>
            proc_run(next);
ffffffffc0206306:	d3ffe0ef          	jal	ffffffffc0205044 <proc_run>
    if (flag) {
ffffffffc020630a:	e819                	bnez	s0,ffffffffc0206320 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020630c:	60a2                	ld	ra,8(sp)
ffffffffc020630e:	6402                	ld	s0,0(sp)
ffffffffc0206310:	0141                	addi	sp,sp,16
ffffffffc0206312:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206314:	4198                	lw	a4,0(a1)
ffffffffc0206316:	4789                	li	a5,2
ffffffffc0206318:	fef712e3          	bne	a4,a5,ffffffffc02062fc <schedule+0x52>
ffffffffc020631c:	852e                	mv	a0,a1
ffffffffc020631e:	bff9                	j	ffffffffc02062fc <schedule+0x52>
}
ffffffffc0206320:	6402                	ld	s0,0(sp)
ffffffffc0206322:	60a2                	ld	ra,8(sp)
ffffffffc0206324:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0206326:	b14fa06f          	j	ffffffffc020063a <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020632a:	0009f617          	auipc	a2,0x9f
ffffffffc020632e:	0a660613          	addi	a2,a2,166 # ffffffffc02a53d0 <proc_list>
ffffffffc0206332:	86b2                	mv	a3,a2
ffffffffc0206334:	b76d                	j	ffffffffc02062de <schedule+0x34>
        intr_disable();
ffffffffc0206336:	b0afa0ef          	jal	ffffffffc0200640 <intr_disable>
        return 1;
ffffffffc020633a:	4405                	li	s0,1
ffffffffc020633c:	bfbd                	j	ffffffffc02062ba <schedule+0x10>

ffffffffc020633e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020633e:	0009f797          	auipc	a5,0x9f
ffffffffc0206342:	1227b783          	ld	a5,290(a5) # ffffffffc02a5460 <current>
}
ffffffffc0206346:	43c8                	lw	a0,4(a5)
ffffffffc0206348:	8082                	ret

ffffffffc020634a <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc020634a:	4501                	li	a0,0
ffffffffc020634c:	8082                	ret

ffffffffc020634e <sys_putc>:
    cputchar(c);
ffffffffc020634e:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206350:	1141                	addi	sp,sp,-16
ffffffffc0206352:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206354:	e71f90ef          	jal	ffffffffc02001c4 <cputchar>
}
ffffffffc0206358:	60a2                	ld	ra,8(sp)
ffffffffc020635a:	4501                	li	a0,0
ffffffffc020635c:	0141                	addi	sp,sp,16
ffffffffc020635e:	8082                	ret

ffffffffc0206360 <sys_kill>:
    return do_kill(pid);
ffffffffc0206360:	4108                	lw	a0,0(a0)
ffffffffc0206362:	c15ff06f          	j	ffffffffc0205f76 <do_kill>

ffffffffc0206366 <sys_yield>:
    return do_yield();
ffffffffc0206366:	bc3ff06f          	j	ffffffffc0205f28 <do_yield>

ffffffffc020636a <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc020636a:	6d14                	ld	a3,24(a0)
ffffffffc020636c:	6910                	ld	a2,16(a0)
ffffffffc020636e:	650c                	ld	a1,8(a0)
ffffffffc0206370:	6108                	ld	a0,0(a0)
ffffffffc0206372:	e40ff06f          	j	ffffffffc02059b2 <do_execve>

ffffffffc0206376 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206376:	650c                	ld	a1,8(a0)
ffffffffc0206378:	4108                	lw	a0,0(a0)
ffffffffc020637a:	bbfff06f          	j	ffffffffc0205f38 <do_wait>

ffffffffc020637e <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020637e:	0009f797          	auipc	a5,0x9f
ffffffffc0206382:	0e27b783          	ld	a5,226(a5) # ffffffffc02a5460 <current>
    return do_fork(0, stack, tf);
ffffffffc0206386:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206388:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc020638a:	6a0c                	ld	a1,16(a2)
ffffffffc020638c:	d25fe06f          	j	ffffffffc02050b0 <do_fork>

ffffffffc0206390 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206390:	4108                	lw	a0,0(a0)
ffffffffc0206392:	9d2ff06f          	j	ffffffffc0205564 <do_exit>

ffffffffc0206396 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206396:	711d                	addi	sp,sp,-96
ffffffffc0206398:	e4a6                	sd	s1,72(sp)
    struct trapframe *tf = current->tf;
ffffffffc020639a:	0009f497          	auipc	s1,0x9f
ffffffffc020639e:	0c648493          	addi	s1,s1,198 # ffffffffc02a5460 <current>
ffffffffc02063a2:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02063a4:	e8a2                	sd	s0,80(sp)
ffffffffc02063a6:	ec86                	sd	ra,88(sp)
    struct trapframe *tf = current->tf;
ffffffffc02063a8:	7340                	ld	s0,160(a4)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02063aa:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02063ac:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02063ae:	02d7ed63          	bltu	a5,a3,ffffffffc02063e8 <syscall+0x52>
        if (syscalls[num] != NULL) {
ffffffffc02063b2:	00003797          	auipc	a5,0x3
ffffffffc02063b6:	8d678793          	addi	a5,a5,-1834 # ffffffffc0208c88 <syscalls>
ffffffffc02063ba:	00369713          	slli	a4,a3,0x3
ffffffffc02063be:	97ba                	add	a5,a5,a4
ffffffffc02063c0:	639c                	ld	a5,0(a5)
ffffffffc02063c2:	c39d                	beqz	a5,ffffffffc02063e8 <syscall+0x52>
            arg[0] = tf->gpr.a1;
ffffffffc02063c4:	7028                	ld	a0,96(s0)
ffffffffc02063c6:	742c                	ld	a1,104(s0)
ffffffffc02063c8:	7830                	ld	a2,112(s0)
ffffffffc02063ca:	7c34                	ld	a3,120(s0)
ffffffffc02063cc:	6c38                	ld	a4,88(s0)
ffffffffc02063ce:	f02a                	sd	a0,32(sp)
ffffffffc02063d0:	f42e                	sd	a1,40(sp)
ffffffffc02063d2:	f832                	sd	a2,48(sp)
ffffffffc02063d4:	fc36                	sd	a3,56(sp)
ffffffffc02063d6:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02063d8:	0828                	addi	a0,sp,24
ffffffffc02063da:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02063dc:	60e6                	ld	ra,88(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02063de:	e828                	sd	a0,80(s0)
}
ffffffffc02063e0:	6446                	ld	s0,80(sp)
ffffffffc02063e2:	64a6                	ld	s1,72(sp)
ffffffffc02063e4:	6125                	addi	sp,sp,96
ffffffffc02063e6:	8082                	ret
    print_trapframe(tf);
ffffffffc02063e8:	8522                	mv	a0,s0
ffffffffc02063ea:	e436                	sd	a3,8(sp)
ffffffffc02063ec:	c44fa0ef          	jal	ffffffffc0200830 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02063f0:	609c                	ld	a5,0(s1)
ffffffffc02063f2:	66a2                	ld	a3,8(sp)
ffffffffc02063f4:	00002617          	auipc	a2,0x2
ffffffffc02063f8:	66c60613          	addi	a2,a2,1644 # ffffffffc0208a60 <etext+0x21a6>
ffffffffc02063fc:	43d8                	lw	a4,4(a5)
ffffffffc02063fe:	06200593          	li	a1,98
ffffffffc0206402:	0b478793          	addi	a5,a5,180
ffffffffc0206406:	00002517          	auipc	a0,0x2
ffffffffc020640a:	68a50513          	addi	a0,a0,1674 # ffffffffc0208a90 <etext+0x21d6>
ffffffffc020640e:	862fa0ef          	jal	ffffffffc0200470 <__panic>

ffffffffc0206412 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0206412:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206416:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_cow_out_size+0xffffffff9e363159>
ffffffffc0206418:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc020641c:	02000513          	li	a0,32
ffffffffc0206420:	9d0d                	subw	a0,a0,a1
}
ffffffffc0206422:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0206426:	8082                	ret

ffffffffc0206428 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206428:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020642c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020642e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206432:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206434:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206438:	f022                	sd	s0,32(sp)
ffffffffc020643a:	ec26                	sd	s1,24(sp)
ffffffffc020643c:	e84a                	sd	s2,16(sp)
ffffffffc020643e:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206440:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206444:	84aa                	mv	s1,a0
ffffffffc0206446:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
ffffffffc0206448:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020644a:	05067063          	bgeu	a2,a6,ffffffffc020648a <printnum+0x62>
ffffffffc020644e:	e44e                	sd	s3,8(sp)
ffffffffc0206450:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206452:	4785                	li	a5,1
ffffffffc0206454:	00e7d763          	bge	a5,a4,ffffffffc0206462 <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0206458:	85ca                	mv	a1,s2
ffffffffc020645a:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc020645c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020645e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206460:	fc65                	bnez	s0,ffffffffc0206458 <printnum+0x30>
ffffffffc0206462:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206464:	1a02                	slli	s4,s4,0x20
ffffffffc0206466:	020a5a13          	srli	s4,s4,0x20
ffffffffc020646a:	00002797          	auipc	a5,0x2
ffffffffc020646e:	63e78793          	addi	a5,a5,1598 # ffffffffc0208aa8 <etext+0x21ee>
ffffffffc0206472:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206474:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206476:	0007c503          	lbu	a0,0(a5)
}
ffffffffc020647a:	70a2                	ld	ra,40(sp)
ffffffffc020647c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020647e:	85ca                	mv	a1,s2
ffffffffc0206480:	87a6                	mv	a5,s1
}
ffffffffc0206482:	6942                	ld	s2,16(sp)
ffffffffc0206484:	64e2                	ld	s1,24(sp)
ffffffffc0206486:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206488:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020648a:	03065633          	divu	a2,a2,a6
ffffffffc020648e:	8722                	mv	a4,s0
ffffffffc0206490:	f99ff0ef          	jal	ffffffffc0206428 <printnum>
ffffffffc0206494:	bfc1                	j	ffffffffc0206464 <printnum+0x3c>

ffffffffc0206496 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206496:	7119                	addi	sp,sp,-128
ffffffffc0206498:	f4a6                	sd	s1,104(sp)
ffffffffc020649a:	f0ca                	sd	s2,96(sp)
ffffffffc020649c:	ecce                	sd	s3,88(sp)
ffffffffc020649e:	e8d2                	sd	s4,80(sp)
ffffffffc02064a0:	e4d6                	sd	s5,72(sp)
ffffffffc02064a2:	e0da                	sd	s6,64(sp)
ffffffffc02064a4:	f862                	sd	s8,48(sp)
ffffffffc02064a6:	fc86                	sd	ra,120(sp)
ffffffffc02064a8:	f8a2                	sd	s0,112(sp)
ffffffffc02064aa:	fc5e                	sd	s7,56(sp)
ffffffffc02064ac:	f466                	sd	s9,40(sp)
ffffffffc02064ae:	f06a                	sd	s10,32(sp)
ffffffffc02064b0:	ec6e                	sd	s11,24(sp)
ffffffffc02064b2:	892a                	mv	s2,a0
ffffffffc02064b4:	84ae                	mv	s1,a1
ffffffffc02064b6:	8c32                	mv	s8,a2
ffffffffc02064b8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064ba:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064be:	05500b13          	li	s6,85
ffffffffc02064c2:	00003a97          	auipc	s5,0x3
ffffffffc02064c6:	8c6a8a93          	addi	s5,s5,-1850 # ffffffffc0208d88 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064ca:	000c4503          	lbu	a0,0(s8)
ffffffffc02064ce:	001c0413          	addi	s0,s8,1
ffffffffc02064d2:	01350a63          	beq	a0,s3,ffffffffc02064e6 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc02064d6:	cd0d                	beqz	a0,ffffffffc0206510 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc02064d8:	85a6                	mv	a1,s1
ffffffffc02064da:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02064dc:	00044503          	lbu	a0,0(s0)
ffffffffc02064e0:	0405                	addi	s0,s0,1
ffffffffc02064e2:	ff351ae3          	bne	a0,s3,ffffffffc02064d6 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc02064e6:	5cfd                	li	s9,-1
ffffffffc02064e8:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc02064ea:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02064ee:	4b81                	li	s7,0
ffffffffc02064f0:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064f2:	00044683          	lbu	a3,0(s0)
ffffffffc02064f6:	00140c13          	addi	s8,s0,1
ffffffffc02064fa:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02064fe:	0ff5f593          	zext.b	a1,a1
ffffffffc0206502:	02bb6663          	bltu	s6,a1,ffffffffc020652e <vprintfmt+0x98>
ffffffffc0206506:	058a                	slli	a1,a1,0x2
ffffffffc0206508:	95d6                	add	a1,a1,s5
ffffffffc020650a:	4198                	lw	a4,0(a1)
ffffffffc020650c:	9756                	add	a4,a4,s5
ffffffffc020650e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206510:	70e6                	ld	ra,120(sp)
ffffffffc0206512:	7446                	ld	s0,112(sp)
ffffffffc0206514:	74a6                	ld	s1,104(sp)
ffffffffc0206516:	7906                	ld	s2,96(sp)
ffffffffc0206518:	69e6                	ld	s3,88(sp)
ffffffffc020651a:	6a46                	ld	s4,80(sp)
ffffffffc020651c:	6aa6                	ld	s5,72(sp)
ffffffffc020651e:	6b06                	ld	s6,64(sp)
ffffffffc0206520:	7be2                	ld	s7,56(sp)
ffffffffc0206522:	7c42                	ld	s8,48(sp)
ffffffffc0206524:	7ca2                	ld	s9,40(sp)
ffffffffc0206526:	7d02                	ld	s10,32(sp)
ffffffffc0206528:	6de2                	ld	s11,24(sp)
ffffffffc020652a:	6109                	addi	sp,sp,128
ffffffffc020652c:	8082                	ret
            putch('%', putdat);
ffffffffc020652e:	85a6                	mv	a1,s1
ffffffffc0206530:	02500513          	li	a0,37
ffffffffc0206534:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206536:	fff44783          	lbu	a5,-1(s0)
ffffffffc020653a:	02500713          	li	a4,37
ffffffffc020653e:	8c22                	mv	s8,s0
ffffffffc0206540:	f8e785e3          	beq	a5,a4,ffffffffc02064ca <vprintfmt+0x34>
ffffffffc0206544:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0206548:	1c7d                	addi	s8,s8,-1
ffffffffc020654a:	fee79de3          	bne	a5,a4,ffffffffc0206544 <vprintfmt+0xae>
ffffffffc020654e:	bfb5                	j	ffffffffc02064ca <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0206550:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0206554:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc0206556:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc020655a:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020655e:	8462                	mv	s0,s8
                ch = *fmt;
ffffffffc0206560:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
ffffffffc0206562:	02e56463          	bltu	a0,a4,ffffffffc020658a <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
ffffffffc0206566:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc020656a:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020656e:	0197073b          	addw	a4,a4,s9
ffffffffc0206572:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206576:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
ffffffffc0206578:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020657c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020657e:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206582:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
ffffffffc0206586:	feb570e3          	bgeu	a0,a1,ffffffffc0206566 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc020658a:	f60d54e3          	bgez	s10,ffffffffc02064f2 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc020658e:	8d66                	mv	s10,s9
ffffffffc0206590:	5cfd                	li	s9,-1
ffffffffc0206592:	b785                	j	ffffffffc02064f2 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206594:	8db6                	mv	s11,a3
ffffffffc0206596:	8462                	mv	s0,s8
ffffffffc0206598:	bfa9                	j	ffffffffc02064f2 <vprintfmt+0x5c>
ffffffffc020659a:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc020659c:	4b85                	li	s7,1
            goto reswitch;
ffffffffc020659e:	bf91                	j	ffffffffc02064f2 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc02065a0:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02065a2:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02065a6:	00c7c463          	blt	a5,a2,ffffffffc02065ae <vprintfmt+0x118>
    else if (lflag) {
ffffffffc02065aa:	18060763          	beqz	a2,ffffffffc0206738 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
ffffffffc02065ae:	000a3603          	ld	a2,0(s4)
ffffffffc02065b2:	46c1                	li	a3,16
ffffffffc02065b4:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02065b6:	000d879b          	sext.w	a5,s11
ffffffffc02065ba:	876a                	mv	a4,s10
ffffffffc02065bc:	85a6                	mv	a1,s1
ffffffffc02065be:	854a                	mv	a0,s2
ffffffffc02065c0:	e69ff0ef          	jal	ffffffffc0206428 <printnum>
            break;
ffffffffc02065c4:	b719                	j	ffffffffc02064ca <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc02065c6:	000a2503          	lw	a0,0(s4)
ffffffffc02065ca:	85a6                	mv	a1,s1
ffffffffc02065cc:	0a21                	addi	s4,s4,8
ffffffffc02065ce:	9902                	jalr	s2
            break;
ffffffffc02065d0:	bded                	j	ffffffffc02064ca <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02065d2:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02065d4:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02065d8:	00c7c463          	blt	a5,a2,ffffffffc02065e0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02065dc:	14060963          	beqz	a2,ffffffffc020672e <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
ffffffffc02065e0:	000a3603          	ld	a2,0(s4)
ffffffffc02065e4:	46a9                	li	a3,10
ffffffffc02065e6:	8a3a                	mv	s4,a4
ffffffffc02065e8:	b7f9                	j	ffffffffc02065b6 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc02065ea:	85a6                	mv	a1,s1
ffffffffc02065ec:	03000513          	li	a0,48
ffffffffc02065f0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02065f2:	85a6                	mv	a1,s1
ffffffffc02065f4:	07800513          	li	a0,120
ffffffffc02065f8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02065fa:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02065fe:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206600:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206602:	bf55                	j	ffffffffc02065b6 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0206604:	85a6                	mv	a1,s1
ffffffffc0206606:	02500513          	li	a0,37
ffffffffc020660a:	9902                	jalr	s2
            break;
ffffffffc020660c:	bd7d                	j	ffffffffc02064ca <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc020660e:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206612:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0206614:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0206616:	bf95                	j	ffffffffc020658a <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0206618:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020661a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020661e:	00c7c463          	blt	a5,a2,ffffffffc0206626 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0206622:	10060163          	beqz	a2,ffffffffc0206724 <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
ffffffffc0206626:	000a3603          	ld	a2,0(s4)
ffffffffc020662a:	46a1                	li	a3,8
ffffffffc020662c:	8a3a                	mv	s4,a4
ffffffffc020662e:	b761                	j	ffffffffc02065b6 <vprintfmt+0x120>
            if (width < 0)
ffffffffc0206630:	87ea                	mv	a5,s10
ffffffffc0206632:	000d5363          	bgez	s10,ffffffffc0206638 <vprintfmt+0x1a2>
ffffffffc0206636:	4781                	li	a5,0
ffffffffc0206638:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020663c:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc020663e:	bd55                	j	ffffffffc02064f2 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206640:	000a3703          	ld	a4,0(s4)
ffffffffc0206644:	12070b63          	beqz	a4,ffffffffc020677a <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
ffffffffc0206648:	0da05563          	blez	s10,ffffffffc0206712 <vprintfmt+0x27c>
ffffffffc020664c:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206650:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
ffffffffc0206654:	14fd9a63          	bne	s11,a5,ffffffffc02067a8 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206658:	00074783          	lbu	a5,0(a4)
ffffffffc020665c:	0007851b          	sext.w	a0,a5
ffffffffc0206660:	c785                	beqz	a5,ffffffffc0206688 <vprintfmt+0x1f2>
ffffffffc0206662:	5dfd                	li	s11,-1
ffffffffc0206664:	000cc563          	bltz	s9,ffffffffc020666e <vprintfmt+0x1d8>
ffffffffc0206668:	3cfd                	addiw	s9,s9,-1
ffffffffc020666a:	01bc8d63          	beq	s9,s11,ffffffffc0206684 <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020666e:	0c0b9a63          	bnez	s7,ffffffffc0206742 <vprintfmt+0x2ac>
                    putch(ch, putdat);
ffffffffc0206672:	85a6                	mv	a1,s1
ffffffffc0206674:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206676:	00044783          	lbu	a5,0(s0)
ffffffffc020667a:	0405                	addi	s0,s0,1
ffffffffc020667c:	3d7d                	addiw	s10,s10,-1
ffffffffc020667e:	0007851b          	sext.w	a0,a5
ffffffffc0206682:	f3ed                	bnez	a5,ffffffffc0206664 <vprintfmt+0x1ce>
            for (; width > 0; width --) {
ffffffffc0206684:	01a05963          	blez	s10,ffffffffc0206696 <vprintfmt+0x200>
                putch(' ', putdat);
ffffffffc0206688:	85a6                	mv	a1,s1
ffffffffc020668a:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc020668e:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0206690:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206692:	fe0d1be3          	bnez	s10,ffffffffc0206688 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206696:	0a21                	addi	s4,s4,8
ffffffffc0206698:	bd0d                	j	ffffffffc02064ca <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020669a:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020669c:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02066a0:	00c7c363          	blt	a5,a2,ffffffffc02066a6 <vprintfmt+0x210>
    else if (lflag) {
ffffffffc02066a4:	c625                	beqz	a2,ffffffffc020670c <vprintfmt+0x276>
        return va_arg(*ap, long);
ffffffffc02066a6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02066aa:	0a044f63          	bltz	s0,ffffffffc0206768 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
ffffffffc02066ae:	8622                	mv	a2,s0
ffffffffc02066b0:	8a5e                	mv	s4,s7
ffffffffc02066b2:	46a9                	li	a3,10
ffffffffc02066b4:	b709                	j	ffffffffc02065b6 <vprintfmt+0x120>
            if (err < 0) {
ffffffffc02066b6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02066ba:	4661                	li	a2,24
            if (err < 0) {
ffffffffc02066bc:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc02066c0:	8fb9                	xor	a5,a5,a4
ffffffffc02066c2:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02066c6:	02d64663          	blt	a2,a3,ffffffffc02066f2 <vprintfmt+0x25c>
ffffffffc02066ca:	00003797          	auipc	a5,0x3
ffffffffc02066ce:	81678793          	addi	a5,a5,-2026 # ffffffffc0208ee0 <error_string>
ffffffffc02066d2:	00369713          	slli	a4,a3,0x3
ffffffffc02066d6:	97ba                	add	a5,a5,a4
ffffffffc02066d8:	639c                	ld	a5,0(a5)
ffffffffc02066da:	cf81                	beqz	a5,ffffffffc02066f2 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
ffffffffc02066dc:	86be                	mv	a3,a5
ffffffffc02066de:	00000617          	auipc	a2,0x0
ffffffffc02066e2:	20a60613          	addi	a2,a2,522 # ffffffffc02068e8 <etext+0x2e>
ffffffffc02066e6:	85a6                	mv	a1,s1
ffffffffc02066e8:	854a                	mv	a0,s2
ffffffffc02066ea:	0f4000ef          	jal	ffffffffc02067de <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02066ee:	0a21                	addi	s4,s4,8
ffffffffc02066f0:	bbe9                	j	ffffffffc02064ca <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02066f2:	00002617          	auipc	a2,0x2
ffffffffc02066f6:	3d660613          	addi	a2,a2,982 # ffffffffc0208ac8 <etext+0x220e>
ffffffffc02066fa:	85a6                	mv	a1,s1
ffffffffc02066fc:	854a                	mv	a0,s2
ffffffffc02066fe:	0e0000ef          	jal	ffffffffc02067de <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206702:	0a21                	addi	s4,s4,8
ffffffffc0206704:	b3d9                	j	ffffffffc02064ca <vprintfmt+0x34>
            lflag ++;
ffffffffc0206706:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206708:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc020670a:	b3e5                	j	ffffffffc02064f2 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc020670c:	000a2403          	lw	s0,0(s4)
ffffffffc0206710:	bf69                	j	ffffffffc02066aa <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206712:	00074783          	lbu	a5,0(a4)
ffffffffc0206716:	0007851b          	sext.w	a0,a5
ffffffffc020671a:	dfb5                	beqz	a5,ffffffffc0206696 <vprintfmt+0x200>
ffffffffc020671c:	00170413          	addi	s0,a4,1
ffffffffc0206720:	5dfd                	li	s11,-1
ffffffffc0206722:	b789                	j	ffffffffc0206664 <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
ffffffffc0206724:	000a6603          	lwu	a2,0(s4)
ffffffffc0206728:	46a1                	li	a3,8
ffffffffc020672a:	8a3a                	mv	s4,a4
ffffffffc020672c:	b569                	j	ffffffffc02065b6 <vprintfmt+0x120>
ffffffffc020672e:	000a6603          	lwu	a2,0(s4)
ffffffffc0206732:	46a9                	li	a3,10
ffffffffc0206734:	8a3a                	mv	s4,a4
ffffffffc0206736:	b541                	j	ffffffffc02065b6 <vprintfmt+0x120>
ffffffffc0206738:	000a6603          	lwu	a2,0(s4)
ffffffffc020673c:	46c1                	li	a3,16
ffffffffc020673e:	8a3a                	mv	s4,a4
ffffffffc0206740:	bd9d                	j	ffffffffc02065b6 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206742:	3781                	addiw	a5,a5,-32
ffffffffc0206744:	05e00713          	li	a4,94
ffffffffc0206748:	f2f775e3          	bgeu	a4,a5,ffffffffc0206672 <vprintfmt+0x1dc>
                    putch('?', putdat);
ffffffffc020674c:	03f00513          	li	a0,63
ffffffffc0206750:	85a6                	mv	a1,s1
ffffffffc0206752:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206754:	00044783          	lbu	a5,0(s0)
ffffffffc0206758:	0405                	addi	s0,s0,1
ffffffffc020675a:	3d7d                	addiw	s10,s10,-1
ffffffffc020675c:	0007851b          	sext.w	a0,a5
ffffffffc0206760:	d395                	beqz	a5,ffffffffc0206684 <vprintfmt+0x1ee>
ffffffffc0206762:	f00cd3e3          	bgez	s9,ffffffffc0206668 <vprintfmt+0x1d2>
ffffffffc0206766:	bff1                	j	ffffffffc0206742 <vprintfmt+0x2ac>
                putch('-', putdat);
ffffffffc0206768:	85a6                	mv	a1,s1
ffffffffc020676a:	02d00513          	li	a0,45
ffffffffc020676e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206770:	40800633          	neg	a2,s0
ffffffffc0206774:	8a5e                	mv	s4,s7
ffffffffc0206776:	46a9                	li	a3,10
ffffffffc0206778:	bd3d                	j	ffffffffc02065b6 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc020677a:	01a05663          	blez	s10,ffffffffc0206786 <vprintfmt+0x2f0>
ffffffffc020677e:	02d00793          	li	a5,45
ffffffffc0206782:	00fd9b63          	bne	s11,a5,ffffffffc0206798 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206786:	02800793          	li	a5,40
ffffffffc020678a:	853e                	mv	a0,a5
ffffffffc020678c:	00002417          	auipc	s0,0x2
ffffffffc0206790:	33540413          	addi	s0,s0,821 # ffffffffc0208ac1 <etext+0x2207>
ffffffffc0206794:	5dfd                	li	s11,-1
ffffffffc0206796:	b5f9                	j	ffffffffc0206664 <vprintfmt+0x1ce>
ffffffffc0206798:	00002417          	auipc	s0,0x2
ffffffffc020679c:	32940413          	addi	s0,s0,809 # ffffffffc0208ac1 <etext+0x2207>
                p = "(null)";
ffffffffc02067a0:	00002717          	auipc	a4,0x2
ffffffffc02067a4:	32070713          	addi	a4,a4,800 # ffffffffc0208ac0 <etext+0x2206>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02067a8:	853a                	mv	a0,a4
ffffffffc02067aa:	85e6                	mv	a1,s9
ffffffffc02067ac:	e43a                	sd	a4,8(sp)
ffffffffc02067ae:	06a000ef          	jal	ffffffffc0206818 <strnlen>
ffffffffc02067b2:	40ad0d3b          	subw	s10,s10,a0
ffffffffc02067b6:	6722                	ld	a4,8(sp)
ffffffffc02067b8:	01a05b63          	blez	s10,ffffffffc02067ce <vprintfmt+0x338>
                    putch(padc, putdat);
ffffffffc02067bc:	2d81                	sext.w	s11,s11
ffffffffc02067be:	85a6                	mv	a1,s1
ffffffffc02067c0:	856e                	mv	a0,s11
ffffffffc02067c2:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02067c4:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc02067c6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02067c8:	6722                	ld	a4,8(sp)
ffffffffc02067ca:	fe0d1ae3          	bnez	s10,ffffffffc02067be <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02067ce:	00074783          	lbu	a5,0(a4)
ffffffffc02067d2:	0007851b          	sext.w	a0,a5
ffffffffc02067d6:	ec0780e3          	beqz	a5,ffffffffc0206696 <vprintfmt+0x200>
ffffffffc02067da:	5dfd                	li	s11,-1
ffffffffc02067dc:	b561                	j	ffffffffc0206664 <vprintfmt+0x1ce>

ffffffffc02067de <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02067de:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02067e0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02067e4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02067e6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02067e8:	ec06                	sd	ra,24(sp)
ffffffffc02067ea:	f83a                	sd	a4,48(sp)
ffffffffc02067ec:	fc3e                	sd	a5,56(sp)
ffffffffc02067ee:	e0c2                	sd	a6,64(sp)
ffffffffc02067f0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02067f2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02067f4:	ca3ff0ef          	jal	ffffffffc0206496 <vprintfmt>
}
ffffffffc02067f8:	60e2                	ld	ra,24(sp)
ffffffffc02067fa:	6161                	addi	sp,sp,80
ffffffffc02067fc:	8082                	ret

ffffffffc02067fe <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02067fe:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206802:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206804:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0206806:	cb81                	beqz	a5,ffffffffc0206816 <strlen+0x18>
        cnt ++;
ffffffffc0206808:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020680a:	00a707b3          	add	a5,a4,a0
ffffffffc020680e:	0007c783          	lbu	a5,0(a5)
ffffffffc0206812:	fbfd                	bnez	a5,ffffffffc0206808 <strlen+0xa>
ffffffffc0206814:	8082                	ret
    }
    return cnt;
}
ffffffffc0206816:	8082                	ret

ffffffffc0206818 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0206818:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020681a:	e589                	bnez	a1,ffffffffc0206824 <strnlen+0xc>
ffffffffc020681c:	a811                	j	ffffffffc0206830 <strnlen+0x18>
        cnt ++;
ffffffffc020681e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206820:	00f58863          	beq	a1,a5,ffffffffc0206830 <strnlen+0x18>
ffffffffc0206824:	00f50733          	add	a4,a0,a5
ffffffffc0206828:	00074703          	lbu	a4,0(a4)
ffffffffc020682c:	fb6d                	bnez	a4,ffffffffc020681e <strnlen+0x6>
ffffffffc020682e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206830:	852e                	mv	a0,a1
ffffffffc0206832:	8082                	ret

ffffffffc0206834 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206834:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206836:	0005c703          	lbu	a4,0(a1)
ffffffffc020683a:	0585                	addi	a1,a1,1
ffffffffc020683c:	0785                	addi	a5,a5,1
ffffffffc020683e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206842:	fb75                	bnez	a4,ffffffffc0206836 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206844:	8082                	ret

ffffffffc0206846 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206846:	00054783          	lbu	a5,0(a0)
ffffffffc020684a:	e791                	bnez	a5,ffffffffc0206856 <strcmp+0x10>
ffffffffc020684c:	a02d                	j	ffffffffc0206876 <strcmp+0x30>
ffffffffc020684e:	00054783          	lbu	a5,0(a0)
ffffffffc0206852:	cf89                	beqz	a5,ffffffffc020686c <strcmp+0x26>
ffffffffc0206854:	85b6                	mv	a1,a3
ffffffffc0206856:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc020685a:	0505                	addi	a0,a0,1
ffffffffc020685c:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206860:	fef707e3          	beq	a4,a5,ffffffffc020684e <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206864:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206868:	9d19                	subw	a0,a0,a4
ffffffffc020686a:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020686c:	0015c703          	lbu	a4,1(a1)
ffffffffc0206870:	4501                	li	a0,0
}
ffffffffc0206872:	9d19                	subw	a0,a0,a4
ffffffffc0206874:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206876:	0005c703          	lbu	a4,0(a1)
ffffffffc020687a:	4501                	li	a0,0
ffffffffc020687c:	b7f5                	j	ffffffffc0206868 <strcmp+0x22>

ffffffffc020687e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020687e:	a021                	j	ffffffffc0206886 <strchr+0x8>
        if (*s == c) {
ffffffffc0206880:	00f58763          	beq	a1,a5,ffffffffc020688e <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0206884:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206886:	00054783          	lbu	a5,0(a0)
ffffffffc020688a:	fbfd                	bnez	a5,ffffffffc0206880 <strchr+0x2>
    }
    return NULL;
ffffffffc020688c:	4501                	li	a0,0
}
ffffffffc020688e:	8082                	ret

ffffffffc0206890 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206890:	ca01                	beqz	a2,ffffffffc02068a0 <memset+0x10>
ffffffffc0206892:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206894:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206896:	0785                	addi	a5,a5,1
ffffffffc0206898:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020689c:	fef61de3          	bne	a2,a5,ffffffffc0206896 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02068a0:	8082                	ret

ffffffffc02068a2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02068a2:	ca19                	beqz	a2,ffffffffc02068b8 <memcpy+0x16>
ffffffffc02068a4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02068a6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02068a8:	0005c703          	lbu	a4,0(a1)
ffffffffc02068ac:	0585                	addi	a1,a1,1
ffffffffc02068ae:	0785                	addi	a5,a5,1
ffffffffc02068b0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02068b4:	feb61ae3          	bne	a2,a1,ffffffffc02068a8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02068b8:	8082                	ret
