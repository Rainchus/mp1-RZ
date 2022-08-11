.n64
.relativeinclude on

.create "rom/mp1RZ.z64", 0
.incbin "rom/base.z64"

.definelabel mallocPerm, 0x8003B6A4
.definelabel SleepVProcess, 0x800635B4
.definelabel PAYLOAD_ROM, 0x02000000
.definelabel PAYLOAD_RAM, 0x80400000
.definelabel RZ_RAM,      PAYLOAD_RAM + 0x40
.definelabel DMA_FUNC,    0x80061FE8

;=================================================
; Base ROM Editing Region
;=================================================
//ROM 0x15070
.headersize 0x7FFFF400
.org 0x8005B6E4

	lui   a0, hi(PAYLOAD_ROM)     ;payload rom: 0x02000000
	lui   a1, hi(PAYLOAD_RAM)     ;payload ram: 0x80400000
	li    a2, (END - PAYLOAD_RAM) ;payload end
	jal   DMA_FUNC                ;dma
	nop
	j   init                    ;displaced boot routine
	nop


;graph thread main hook
;original function call will be displaced in c code. it takes no arguments
//0x1B05C ROM
.headersize 0x7FFFF400
.org 0x80025348
JAL RZ_RAM
NOP

;=================================================
; New Code Region
;=================================================
.headersize (PAYLOAD_RAM - PAYLOAD_ROM)
.org PAYLOAD_RAM
init: //displaced boot code
	LUI at, 0x800E
	SW s1, 0x8910 (at)
	JAL mallocPerm
	ADDIU a0, r0, 0x0010
	ADDU s0, v0, r0
	ADDU a0, s1, r0
	ADDU a1, s0, r0
	JAL 0x80061FE8
	ADDIU a2, r0, 0x0010
	J 0x8005B708
	NOP

.org RZ_RAM
.incbin "bin/rz.bin"
.align 8
END:
.close