.section  .text, "ax", @progbits
.set      nomips16
.set      nomicromips
.set      noreorder

.global   _start
.ent      _start
.type     _start, @function
_start:
/* 1000 80000400 */  lui $sp, %hi(0x800F2A70)
/* 1004 80000404 */  addiu $sp, $sp, %lo(0x800F2A70)
/* 1008 80000408 */  lui $a0, 0
/* 100C 8000040C */  lui $a1, %hi(PAYLOAD)
/* 1010 80000410 */  addiu $a1, $a1, %lo(PAYLOAD)
/* 1014 80000414 */  lui $a2, %hi(0x80400000)
/* 1018 80000418 */  lui $a3, %hi(END)
/* 101C 8000041C */  addiu $a3, $a3, %lo(END)
/* 1020 80000420 */  jal (DMA_COPY)
/* 1024 80000424 */  subu $a3, $a3, $a1
/* 1028 80000428 */  lui $t0, 0xA460
pi_loop:
/* 102C 8000042C */  lw $t1, 0x0010 ($t0)
/* 1030 80000430 */  andi $t2, $t1, 0x0001
/* 1034 80000434 */  bnez $t2, pi_loop
/* 1038 80000438 */  nop
/* 103C 8000043C */  LUI $s0, 0x800D
/* 1040 80000440 */  ADDIU $s0, $s0, 0xCE50
/* 1044 80000444 */  LI $t1, 0x29790
bssLoop:
/* 104C 8000044C SD $zero, 0x0000 ($s0) */ .word 0xFE000000
/* 1050 80000450 */  ADDI $t1, $t1, -8
/* 1054 80000454 */  BNEZ $t1, bssLoop
/* 1058 80000458 */  ADDI $s0, $s0, 8
/* 105C 8000045C */  NOP
.end _start
.size _start, . - _start
