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

		INCLUDE	"exec/nodes.i"
		INCLUDE	"dos/dos.i"
		INCLUDE	"dos/var.i"
		INCLUDE	"lvo/exec.i"
		INCLUDE	"lvo/dos.i"

		INCLUDE	PatchWork.i

		SECTION	text,CODE

*--
* Set the patches
*
		PUBLIC	SP_Dos
SP_Dos		movem.l	a0-a1,-(SP)
		move.l	(dosbase,PC),a1
		lea	(dos_patches,PC),a0
		bsr	AddPatchTab
		movem.l	(SP)+,a0-a1
		rts

*--
* Remove the patches
*
		PUBLIC	RP_Dos
RP_Dos		movem.l	a0-a1,-(SP)
		move.l	(dosbase,PC),a1
		lea	(dos_patches,PC),a0
		bsr	RemPatchTab
		movem.l	(SP)+,a0-a1
		rts

*--
* Table of all patches
*
dos_patches	dpatch	_DOSAttemptLockDosList,P_AttemptLockDosList
		dpatch	_DOSCreateProc,P_CreateProc
		dpatch	_DOSDoPkt,P_DoPkt
		dpatch	_DOSExamine,P_Examine
		dpatch	_DOSExamineFH,P_ExamineFH
		dpatch	_DOSExAll,P_ExAll
		dpatch	_DOSExAllEnd,P_ExAllEnd
		dpatch	_DOSExNext,P_ExNext
		dpatch	_DOSGetVar,P_GetVar
		dpatch	_DOSInfo,P_Info
		dpatch	_DOSMatchEnd,P_MatchEnd
		dpatch	_DOSMatchFirst,P_MatchFirst
		dpatch	_DOSMatchNext,P_MatchNext
		dpatch	_DOSRunCommand,P_RunCommand
		dpatch	_DOSSetVBuf,P_SetVBuf
		dc.w	0


*------------------------------------------------------------------
* PATCHES
*

	PATCH P_AttemptLockDosList,"AttemptLockDosList(0x%08lx)",REG_D1
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_warn,PC),a1
		lea	(.THIS,PC),a2
		moveq	#40,d0			;MinOS 40
		swap	d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		move.l	(args+arg_Deadly,PC),d0 ;Deadly hit?
		beq	.THIS			; nope
		bsr	.THIS
		tst.l	d0			;Result != 0 ?
		bne	.leave
		moveq	#1,d0			;Return 1 instead
.leave		rts

.msg_warn	dc.b	"also returns 0x00000001 until V39.24 dos",0
		even

*---------------

	PATCH P_CreateProc,"CreateProc(\"%s\",%ld,Bx%08lx,%ld)",REG_D1|REGF_STR,REG_D2,REG_D3|REGF_BPTR,REG_D4

	;-- Check priority ---------------------;
		cmp.l	#-128,d2
		blt	.badpri
		cmp.l	#127,d2
		bls	.pri_ok
.badpri	 movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_pri,PC),a1
		lea	(.THIS,PC),a2
		moveq	#2,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
.pri_ok
	;-- Check stack ------------------------;
		move.l	d4,d0
		and	#%11,d0
		beq	.stack_ok
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_stack,PC),a1
		lea	(.THIS,PC),a2
		moveq	#2,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
.stack_ok
	;-- and anyways... ---------------------;
	;	movem.l	d0-d7/a0-a7,-(SP)
	;	move.l	SP,a0
	;	lea	(.msg_anyhow,PC),a1
	;	lea	(.THIS,PC),a2
	;	moveq	#0,d0
	;	move.l	(dosbase,PC),a6
	;	bsr	ShowHit
	;	movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_pri	dc.b	"pri is out of range (-128..127)",0
.msg_stack	dc.b	"stack size must be a multiple of 4",0
;.msg_anyhow	dc.b	"use CreateNewProc() if possible",0
		even

*---------------

	PATCH P_DoPkt,"DoPkt(0x%08lx,%ld,arg1..arg5)",REG_D1,REG_D2
		movem.l	d0-d7/a0-a7,-(SP)
		sub.l	a1,a1
		exec	FindTask
		move.l	d0,a0
		cmp.b	#NT_TASK,(LN_TYPE,a0)	;no Task
		bne	.okay
		move.l	SP,a0
		lea	(.msg_needv37,PC),a1
		lea	(.THIS,PC),a2
		moveq	#37,d0			;MinOS 37
		swap	d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
.okay		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_needv37	dc.b	"DoPkt() from a task requires V37+",0
		even

*---------------

	PATCH P_Examine,"Examine(Bx%08lx,0x%08lx)",REG_D1|REGF_BPTR,REG_D2
		move.l	d2,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"FileInfoBlock is not longword aligned",0
		even

*---------------

	PATCH P_ExamineFH,"ExamineFH(Bx%08lx,0x%08lx)",REG_D1|REGF_BPTR,REG_D2
		move.l	d2,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"FileInfoBlock is not longword aligned",0
		even

*---------------

	PATCH P_ExAll,"ExAll(Bx%08lx,0x%08lx,%ld,%ld,0x%08lx)",REG_D1|REGF_BPTR,REG_D2,REG_D3,REG_D4,REG_D5
		btst	#0,d2			;Word aligned?
		bne	.not_word
		btst	#1,d2			;also long aligned?
		beq	.THIS
	;-- not long aligned -------------------;
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_longalign,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
	;-- not word aligned -------------------;
.not_word	movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"buffer is not word aligned",0
.msg_longalign	dc.b	"buffer should be longword aligned",0
		even

*---------------

	PATCH P_ExAllEnd,"ExAllEnd(Bx%08lx,0x%08lx,%ld,%ld,0x%08lx)",REG_D1|REGF_BPTR,REG_D2,REG_D3,REG_D4,REG_D5
		btst	#0,d2			;Word aligned?
		bne	.not_word
		btst	#1,d2			;also long aligned?
		beq	.THIS
	;-- not long aligned -------------------;
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_longalign,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
	;-- not word aligned -------------------;
.not_word	movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"buffer is not word aligned",0
.msg_longalign	dc.b	"buffer should be longword aligned",0
		even

*---------------

	PATCH P_ExNext,"ExNext(Bx%08lx,0x%08lx)",REG_D1|REGF_BPTR,REG_D2
		move.l	d2,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"FileInfoBlock is not longword aligned",0
		even

*---------------

	PATCH P_GetVar,"GetVar(\"%s\",0x%08lx,%ld,0x%08lx)",REG_D1|REGF_STR,REG_D2,REG_D3,REG_D4
		btst	#GVB_DONT_NULL_TERM,d4	;Null term activated?
		beq	.THIS			; no: then it's OK anyways
		btst	#GVB_LOCAL_ONLY,d4	;Also local?
		beq	.need_39
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v37,PC),a1
		lea	(.THIS,PC),a2
		moveq	#37,d0			;MinOS 37
		swap	d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
.need_39	movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v39,PC),a1
		lea	(.THIS,PC),a2
		moveq	#39,d0			;MinOS 39
		swap	d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v37	dc.b	"this flags will require V37+",0
.msg_v39	dc.b	"this flags will require V39+",0
		even

*---------------

	PATCH P_Info,"Info(Bx%08lx,0x%08lx)",REG_D1|REGF_BPTR,REG_D2
		move.l	d2,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"parameterBlock is not longword aligned",0
		even

*---------------

	PATCH P_MatchEnd,"MatchEnd(0x%08lx)",REG_D1
		move.l	d1,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"AnchorPath is not longword aligned",0
		even

*---------------

	PATCH P_MatchFirst,"MatchFirst(\"%s\",0x%08lx)",REG_D1|REGF_STR,REG_D2
		move.l	d2,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"AnchorPath is not longword aligned",0
		even

*---------------

	PATCH P_MatchNext,"MatchNext(0x%08lx)",REG_D1
		move.l	d1,d0
		and	#%11,d0
		beq	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"AnchorPath is not longword aligned",0
		even

*---------------

	PATCH P_RunCommand,"RunCommand(Bx%08lx,%lu,\"%s\",%lu)",REG_D1|REGF_BPTR,REG_D2,REG_D3|REGF_STR,REG_D4
		tst.l	d3			;No string?
		beq	.THIS			; then leave
		movem.l	d0-d7/a0-a7,-(SP)
	;-- argptr length OK? ------------------;
		move.l	d3,a0
.getlen		tst.b	(a0)+
		bne	.getlen
		subq.l	#1,a0			;Do not count null terminator
		sub.l	d3,a0
		cmp.l	d4,a0			;Length is equal?
		beq	.size_ok
		move.l	SP,a0
		lea	(.msg_notmatch,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
.size_ok
	;-- last character is \n ? -------------;
		move.l	d3,a0
		add.l	d4,a0
		cmp.b	#"\n",-(a0)
		beq	.slashok
		move.l	SP,a0
		lea	(.msg_noslash,PC),a1
		lea	(.THIS,PC),a2
		move.l	#(38<<16)+2,d0		;MinOS 38
		move.l	(dosbase,PC),a6
		bsr	ShowHit
.slashok
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_notmatch	dc.b	"strlen(argptr) does not match to argsize",0
.msg_noslash	dc.b	"argptr does not end with '\\n'",0
		even

*---------------

	PATCH P_SetVBuf,"SetVBuf(Bx%08lx,0x%08lx,%ld,%ld)",REG_D1|REGF_BPTR,REG_D2,REG_D3,REG_D4
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	d2,d0
		and	#%11,d0
		beq	.not_impl
		move.l	SP,a0
		lea	(.msg_align,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
.not_impl	move.l	SP,a0
		lea	(.msg_notimpl,PC),a1
		lea	(.THIS,PC),a2
		moveq	#40,d0			;MinOS 40
		swap	d0
		move.l	(dosbase,PC),a6
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_align	dc.b	"buff is not longword aligned",0
.msg_notimpl	dc.b	"not implemented until V40+",0
		even
