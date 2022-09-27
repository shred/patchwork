*
* PatchWork
*
* Copyright (C) 2021 Richard "Shred" Koerber
*	http://patchwork.shredzone.org
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*

* Requires DisLib by Thomas Richter, available in the AmiNet

		INCLUDE	"exec/lists.i"
		INCLUDE	"exec/nodes.i"
		INCLUDE	"exec/semaphores.i"
		INCLUDE	"exec/io.i"
		INCLUDE	"exec/ports.i"
		INCLUDE	"exec/tasks.i"
		INCLUDE	"exec/execbase.i"
		INCLUDE	"dos/dos.i"
		INCLUDE	"libraries/disassembler.i"
		INCLUDE	"lvo/exec.i"
		INCLUDE	"lvo/disassembler.i"

		INCLUDE	PatchWork.i

		SECTION	text,CODE

*--
* Shows a hit via debug channel
*
* 	-> a0.l ^Stack Frame (d0-d7, a0-a7, PC)
* 	-> a1.l ^Error string
* 	-> a2.l ^Patch struct
* 	-> a6.l ^Library base
* 	-> d0.l Severity
* 	-> d1.l Stack with output parameters
*
		PUBLIC	ShowHit
ShowHit		movem.l	d0-d7/a0-a6,-(SP)
		move.l	a0,a5			;a5: Stackframe
		move.l	a2,a4			;a4: struct
		move.l	a6,a3			;a3: Library base
		move.l	d0,d5			;d5: severity
	;-- Severity below Treshold? -----------;
		cmp	(gl+gl_Tresh,PC),d5
		blo	.exit
	;-- OS below MINOS? --------------------;
		swap	d5
		tst	d5			;always out
		beq	.out
		cmp	(gl+gl_MinOS,PC),d5
		bls	.exit
		clr	d5
	;-- RomHits? ---------------------------;
.out		swap	d5
		move.l	(args+arg_RomHits,PC),d0
		bne	.romhits
		move.l	(REG_PC,a5),d0
		cmp.l	#$f80000,d0		;is it within the ROM?
		blo	.romhits
		cmp.l	#$1000000,d0
		blo	.exit
.romhits
	;-- Forbid required? -------------------;
.forbid		move.l	4.w,a6
		move.b	(TDNestCnt,a6),d7	;d7: Forbid state
		cmp.b	#-1,d7			;off?
		bne	.forbidden
		exec.q	Forbid			; if not already forbidden
.forbidden
		movem.l	d1/a1,-(SP)
	;-- Attach CR --------------------------;
		lea	(.msg_cr,PC),a0
		jsr	KPrintF
	;-- Print error location ---------------;
		move.l	SP,d6			;store SP
		move.l	-(a4),a0		;Output message
	;---- Parameter Register ---------------;
.srcloop	moveq	#0,d1
		move.b	-(a4),d1
		move.b	-(a4),d0		;Type
		bmi	.srcdone
		move.l	(a5,d1.w),d1
	;---- STRing pointer? ------------------;
		btst	#REGB_STR-8,d0		;String?
		beq	.no_str
		tst.l	d1			;Null Ptr?
		bne	.no_nullptr
		lea	(.msg_nullptr,PC),a1
		move.l	a1,d1
		bra	.no_str
.no_nullptr	;; Check for valid address?
.no_str
	;---- WORD ? ---------------------------;
		btst	#REGB_WORD-8,d0	 	;Word?
		beq	.no_word
		ext.l	d1
.no_word
	;---- UWORD ? --------------------------;
		btst	#REGB_UWORD-8,d0	;UWord?
		beq	.no_uword
		swap	d1
		clr	d1
		swap	d1
.no_uword
	;---- UBYTE ? --------------------------;
		btst	#REGB_UBYTE-8,d0	;UByte?
		beq	.no_ubyte
		and.l	#$FF,d1
.no_ubyte
	;---- BPTR ? ---------------------------;
		btst	#REGB_BPTR-8,d0	 	;BPTR?
		beq	.no_bptr
		lsl.l	#2,d1
.no_bptr
	;---- Set result ----------------------;
		move.l	d1,-(SP)
		bra	.srcloop
.srcdone	move.l	(LN_NAME,a3),-(SP)	;Library Name
		move.l	SP,a1
		jsr	KPrintF
		move.l	d6,SP			;Restore stack
	;-- Print error message ---------------;
		move.l	d5,-(SP)
		lea	(.msg_cause,PC),a0
		move.l	SP,a1
		jsr	KPrintF
		addq.l	#4,SP
		movem.l	(SP)+,d1/a0
		move.l	d1,a1
		jsr	KPrintF		 	;Print text
		lea	(.msg_cr,PC),a0
		jsr	KPrintF
	;-- TINY? ------------------------------;
		move.l	(args+arg_Tiny,PC),d0
		bne	.done			;then we're done...
	;-- Task information -------------------;
		sub.l	a1,a1
		exec	FindTask
		move.l	d0,a0
		move.l	(LN_NAME,a0),-(SP)
		move.l	a0,-(SP)
		move.l	(64,a5),a1
		subq.l	#4,a1			;sizeof(JSR(xxxx,a6))
		move.l	a1,-(SP)
		move.l	SP,a1
		lea	(.msg_pc,PC),a0
		jsr	KPrintF
		add.l	#3*4,SP
	;-- SMALL? -----------------------------;
		move.l	(args+arg_Small,PC),d0
		bne	.done			;then we're done...
	;-- Data registers ------- -------------;
		lea	(.msg_dreg,PC),a0
		move.l	a5,a1			;Stackframe is already OK
		jsr	KPrintF
		move.l	(args+arg_DRegcheck,PC),d0
		beq	.nodreg
		move.l	a5,a1
		bsr	FindSegLine
.nodreg
	;-- Address registers ------------------;
		lea	(.msg_areg,PC),a0
		lea	(32,a5),a1
		jsr	KPrintF
		move.l	(args+arg_ARegcheck,PC),d0
		beq	.noareg
		lea	(32,a5),a1
		bsr	FindSegLine
.noareg
	;-- PC ---------------------------------;
		move.l	(args+arg_ShowPC,PC),d0 ;required?
		beq	.nopc
		move.l	(64,a5),a1		;PC
		sub.l	#32+4,a1
		lea	(.msg_pc8,PC),a0
		jsr	KPrintF
		move.l	(64,a5),a1
		subq.l	#4,a1			;sizeof(JSR(xxxx,a6))
		lea	(.msg_pcstar,PC),a0
		jsr	KPrintF
.nopc
	;-- Disassembly ------------------------;
		move.l	(args+arg_NoDisPC,PC),d0 ;disabled?
		bne	.nodis
		move.l	(64,a5),a0		;PC
		subq.l	#4,a0			;sizeof(JSR(xxxx,a6))
		bsr	Disassemble
.nodis
	;-- Stack frame ------------------------;
		lea	(.msg_stack,PC),a0
		move.l	(60,a5),a1		;^SP
		move.l	(gl+gl_Stacklines,PC),d0
.stkloop1	subq.l	#1,d0			;Count
		bcs	.stk1done
		movem.l	a0/a1/d0,-(SP)
		jsr	KPrintF
		movem.l	(SP)+,a0/a1/d0
		add.l	#8*4,a1
		bra	.stkloop1
.stk1done
	;-- SegTracker for PC ------------------;
		move.l	(64,a5),d0		;PC
		subq.l	#4,d0			;sizeof(JSR(xxxx,a6))
		bsr	FindSeg
	;-- SegTracker for Stack ---------------;
		move.l	(args+arg_Stackcheck,PC),d0
		beq	.nostckchk
		move.l	(60,a5),a3
		move.l	(gl+gl_Stacklines,PC),d3
		lsl.l	#3,d3
.stk2loop	subq.l	#1,d3
		bcs	.nostckchk
		move.l	(a3)+,d0
		bsr	FindSeg
		bra	.stk2loop
.nostckchk
	;-- Permit if required -----------------;
.done		tst.b	d7			;How was the old state?
		cmp.b	#-1,d7			;forbidden?
		bne	.nopermit
		exec.q	Permit
.nopermit
.exit		movem.l	(SP)+,d0-d7/a0-a6
		rts

.msg_cause	dc.b	"\nSeverity %ld: ",0
.msg_dreg	dc.b	"Data: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_areg	dc.b	"Addr: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_pc8	dc.b	"PC-8: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_pcstar	dc.b	"PC *: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_stack	dc.b	"Stck: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_pc		dc.b	"PC=%08lx TCB=%08lx (\"%s\")"
.msg_cr		dc.b	"\n",0
.msg_nullptr	dc.b	"[NULL POINTER]",0
		even

*--
* SegTracker output for a line
*
* 	-> a1.l Pointer to 8 longwords
*
FindSegLine	movem.l	a3/d3,-(SP)
		move.l	a1,a3
		moveq	#7,d3
.loop		move.l	(a3)+,d0
		bsr	FindSeg
		dbra	d3,.loop
		movem.l	(SP)+,a3/d3
		rts

*--
* SegTracker output
*
* 	-> d0.l PC to be analyzed
*
		clrfo
str_buffer	fo.b	200			;Text buffer
str_offset	fo.l	1			;offset
str_hunk	fo.l	1			;hunk
str_bufptr	fo.l	1
str_val		fo.l	1
str_SIZEOF	fo.w	0

FindSeg		movem.l	d3-d7/a3-a4,-(SP)
		link	a5,#str_SIZEOF
		move.l	d0,(str_val,a5)	 	;Set the address
		lea	(.segtrname,PC),a1	;Find Segtracker
		exec	FindSemaphore
		tst.l	d0
		beq	.exit			;No Segtracker
		move.l	d0,a3			;Remember ^Semaphore
		move.l	(str_val,a5),a0	 	;Prepare invocation
		lea	(str_hunk,a5),a1
		lea	(str_offset,a5),a2
		move.l	(SS_SIZE,a3),a4	 	;^Function
		jsr	(a4)			; invoke
		tst.l	d0			;is there a result?
		beq	.exit			; no: leave
		move.l	d0,a0			;copy string
		lea	(str_buffer,a5),a1
		move.l	a1,(str_bufptr,a5)
		move	#198,d0
.copy		move.b	(a0)+,(a1)+
		dbeq	d0,.copy
		clr.b	(a1)			;terminate
		lea	(.msg_segtrstr,PC),a0	;and output the entire message
		lea	(str_val,a5),a1
		jsr	KPrintF
.exit		unlk	a5
		movem.l	(SP)+,d3-d7/a3-a4
		rts
.segtrname	dc.b	"SegTracker",0
.msg_segtrstr	dc.b	"----> %08lx - \"%s\"	Hunk %04lx, Offset %08lx\n",0
		even

*--
* Disassembles
*
* 	-> a0.l PC to be disassembled
*
		clrfo
dis_PC		fo.l	1
dis_Range	fo.l	1
dis_struct	fo.b	ds_SIZE
dis_SIZEOF	fo.w	0

Disassemble	movem.l	d3-d7/a3-a4,-(SP)
		link	a5,#dis_SIZEOF
		move.l	(disasmbase,PC),d0	;Disassembler available?
		beq	.exit
		move.l	a0,(dis_PC,a5)
	;-- Get range --------------------------;
		moveq	#32,d1			;Default: 32 byte
		move.l	(args+arg_DisRange,PC),d0
		beq	.usedef
		move.l	d0,a1
		move.l	(a1),d1
.usedef	 	move.l	d1,(dis_Range,a5)
	;-- Find start -------------------------;
		move.l	(dis_Range,a5),d0	;Min
		move.l	d0,d1
		addq.l	#8,d1
		addq.l	#8,d1			;Max
		move.l	(dis_PC,a5),a0		;PC
		disasm	FindStartPosition
	;-- Disassemble ------------------------;
		move.l	d0,(dis_struct+ds_From,a5)
		move.l	(dis_PC,a5),a0
		move.l	a0,(dis_struct+ds_PC,a5)
		add.l	(dis_Range,a5),a0
		move.l	a0,(dis_struct+ds_UpTo,a5)
		lea	(.putproc,PC),a1
		move.l	a1,(dis_struct+ds_PutProc,a5)
		clr.l	(dis_struct+ds_UserData,a5)
		clr	(dis_struct+ds_Truncate,a5)
		lea	(dis_struct,a5),a0
		disasm	Disassemble
.exit		unlk	a5
		movem.l	(SP)+,d3-d7/a3-a4
		rts

.putproc	movem.l	d0-d7/a0-a6,-(SP)
		jsr	KPutChar
		movem.l	(SP)+,d0-d7/a0-a6
		rts
