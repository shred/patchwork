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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*

		INCLUDE	"exec/ports.i"
		INCLUDE	"exec/memory.i"
		INCLUDE	"dos/dos.i"
		INCLUDE	"dos/rdargs.i"
		INCLUDE	"lvo/exec.i"
		INCLUDE	"lvo/dos.i"

		INCLUDE	PatchWork_rev.i
		INCLUDE	PatchWork.i

		SECTION	text,CODE

Start	;-- Open DOS lib -----------------------;
		lea	(dosname,PC),a1
		moveq	#37,d0			;OS2.04+ required
		exec	OpenLibrary
		move.l	d0,dosbase
		beq	.error1
		lea	(utilsname,PC),a1
		moveq	#36,d0
		exec	OpenLibrary
		move.l	d0,utilsbase
		beq	.error2
		lea	(disasmname,PC),a1
		moveq	#40,d0
		exec	OpenLibrary
		move.l	d0,disasmbase
	;-- Create MessagePort -----------------;
		moveq	#MP_SIZE,d0
		move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1
		exec	AllocVec
		move.l	d0,msgport
		beq	.error3
		move.l	d0,a3
		move.b	#NT_MSGPORT,(LN_TYPE,a3)
		lea	(pwportname,PC),a0
		move.l	a0,(LN_NAME,a3)
		move.b	#PA_IGNORE,(MP_FLAGS,a3)
		sub.l	a1,a1
		exec.q	FindTask
		move.l	d0,(MP_SIGTASK,a3)
		lea	(MP_MSGLIST,a3),a0
		NEWLIST a0
	;-- Is a PatchWork running? ------------;
		exec.q	Forbid			;of course... :)
		lea	(pwportname,PC),a1	;look for the port
		exec.q	FindPort
		tst.l	d0
		beq	.no_port		;we're here for the first time
	;-- Close other PatchWork --------------;
		move.l	d0,a0
		move.l	(MP_SIGTASK,a0),a1	;get other task
		move.l	#SIGBREAKF_CTRL_C,d0	;send a CTRL-C signal
		exec.q	Signal
		exec.q	Permit			;enable multitasking
		lea	(msg_removing,PC),a0
		move.l	a0,d1
		dos	PutStr
		bra	.already		; and close ourself
	;-- First start ------------------------;
.no_port	move.l	(msgport,PC),a1		;set port
		exec.q	AddPort
		exec.q	Permit			;and continue
	;-- Read parameters --------------------;
		lea	(template,PC),a0	;Parse
		move.l	a0,d1
		lea	(args,PC),a0
		move.l	a0,d2
		moveq	#0,d3
		dos	ReadArgs
		move.l	d0,dosargs
		beq	.error5
	;-- Process ----------------------------;
		lea	(args,PC),a0
		lea	(gl,PC),a1
		moveq	#0,d0			;Tresh
		tst.l	(arg_Tresh,a0)
		beq	.notresh
		move.l	(arg_Tresh,a0),a2
		move.l	(a2),d0
.notresh	move	d0,(gl_Tresh,a1)
		moveq	#0,d0			;MinOS
		tst.l	(arg_MinOS,a0)
		beq	.nominos
		move.l	(arg_MinOS,a0),a2
		move.l	(a2),d1
		beq	.nominos
		cmp.l	#30,d1
		blo	.minos_err
		cmp.l	#45,d1
		bhi	.minos_err
		move.l	d1,d0
		bra	.nominos
.minos_err	movem.l	d0-d1/a0-a1,-(SP)
		lea	(msg_bados,PC),a0
		move.l	a0,d1
		dos	PutStr
		movem.l	(SP)+,d0-d1/a0-a1
.nominos	move	d0,(gl_MinOS,a1)
		moveq	#2,d0			;Stack lines
		tst.l	(arg_Stacklines,a0)
		beq	.stkok
		move.l	(arg_Stacklines,a0),a2
		move.l	(a2),d0
.stkok		move.l	d0,(gl_Stacklines,a1)
	;-- Initialize timer -------------------;
		bsr	InitTimer
		tst.l	d0
		beq	.error_tmr
	;-- Main program -----------------------;
		lea	(msg_copyright,PC),a0
		move.l	a0,d1
		dos	PutStr
		bsr	SP_Exec
		bsr	SP_Dos
		bsr	SP_Graphics
		bsr	SP_Intuition
		bsr	SP_Utility
		bsr	SP_Commodities
		bsr	SP_Gadtools
		move.l	#SIGBREAKF_CTRL_C,d0	;Wait for CTRL-C
		exec	Wait
		bsr	RP_Gadtools
		bsr	RP_Commodities
		bsr	RP_Utility
		bsr	RP_Intuition
		bsr	RP_Graphics
		bsr	RP_Dos
		bsr	RP_Exec
		bsr	ExitTimer		;exit timer
		lea	(msg_removed,PC),a0
		move.l	a0,d1
		dos	PutStr
.error_tmr	move.l	(dosargs,PC),d1		;release result
		dos	FreeArgs
		move.l	(msgport,PC),a1		;remove message port
		exec	RemPort
.already	move.l	(msgport,PC),a1
		exec	FreeVec
		move.l	(utilsbase,PC),a1	;release libraries
		exec	CloseLibrary
		move.l	(dosbase,PC),a1
		exec	CloseLibrary
		moveq	#0,d0
.exit		rts

.error6		move.l	(dosargs,PC),d1		;release result
		dos	FreeArgs
.error5		move.l	(msgport,PC),a1		;remove message port
		exec	RemPort
.error4		move.l	(msgport,PC),a1		;release message port
		exec	FreeVec

		move.l	(disasmbase,PC),d0	;close disassembler if available
		beq	.nodisasm
		move.l	d0,a1
		exec	CloseLibrary
.nodisasm

.error3		move.l	(utilsbase,PC),a1	;release libraries
		exec	CloseLibrary
.error2		move.l	(dosbase,PC),a1
		exec	CloseLibrary
.error1		moveq	#10,d0			; Failed
		bra.b	.exit

	;-- Version String ---------------------;
		VERSTAG
		COPYRIGHT
		dc.b	13,10,0
		PRGNAME
		dc.b	" - "
		PROJECTURL
		dc.b	13,10,0
		even

	;-- Variables --------------------------;
		PUBLIC	gl,dosbase,args,utilsbase,disasmbase
gl		ds.b	gl_SIZEOF		;Globals
dosbase		dc.l	0			;^DOS Library
utilsbase	dc.l	0			;^Utils Library
disasmbase	dc.l	0			;^Disassembler Library
dosargs		dc.l	0			;^Parser result
msgport		dc.l	0			;^MessagePort
args		ds.b	arg_SIZEOF		;Parameter Array
template	TEMPLATE

	;-- Texts ------------------------------;
msg_removing	dc.b	"Removing "
		PRGNAME
		dc.b	" now.\n",0
msg_removed	PRGNAME
		dc.b	" has been removed successfully.\n\n",0
msg_copyright	VERS
		dc.b	" "
		COPYRIGHT
		dc.b	"\n"
		PRGNAME
		dc.b	" - "
		PROJECTURL
		dc.b	"\n\n"
		dc.b	"Press <CTRL> <C> to stop "
		PRGNAME
		dc.b	" again.\n",0
msg_bados	dc.b	"MINOS is out of range!\n",0

dosname		dc.b	"dos.library",0		;DOS-Lib
utilsname	dc.b	"utility.library",0	;Utils-Lib
disasmname	dc.b	"disassembler.library",0 ;Disasm-Lib
pwportname	PRGNAME
		dc.b	$A0,"port",0		;Rendezvous Port
		even

*---
* Add patch table
*
*	-> a0.l ^Patch table
*	-> a1.l ^Library base
*
		PUBLIC	AddPatchTab
AddPatchTab	movem.l	d0-d3/a0-a6,-(SP)
		move.l	4.w,a6
		exec.q	Forbid
		move.l	a0,a4
		move.l	a1,a5
.patching	move	(a4)+,d0
		beq	.pdone
		move	d0,a0		;a0: Offset
		move.l	(a4)+,a3	;a3: Function
		lea	(6,a3),a1
		move.l	a1,d0		;d0: new function
		move.l	a5,a1		;a1: Base
		exec.q	Disable
		exec.q	SetFunction
		move.l	d0,(2,a3)	;set old pointer
		exec.q	CacheClearU	;clear caches
		exec.q	Enable
		bra	.patching
.pdone		exec.q	Permit
		movem.l	(SP)+,d0-d3/a0-a6
		rts

*---
* Remove patch table
*
*	-> a0.l ^Patch table
*	-> a1.l ^Library base
*
		PUBLIC	RemPatchTab
RemPatchTab	movem.l	d0-d3/a0-a6,-(SP)
		move.l	4.w,a6
		exec.q	Forbid
		move.l	a0,a4
		move.l	a1,a5
.patching	move	(a4)+,d0
		beq	.pdone
		move	d0,a0		;a0: Offset
		move.l	(a4)+,a3	;a3: Function
		move.l	(2,a3),d0	;d0: old function
		beq	.patching	; 0: next
		move.l	a5,a1		;a1: base
		exec.q	Disable
		exec.q	SetFunction
		exec.q	CacheClearU
		exec.q	Enable
		bra	.patching
.pdone		exec.q	Permit
		movem.l	(SP)+,d0-d3/a0-a6
		rts

*---
* Alert about a bad patch control program!
*
		PUBLIC	alert_badone
alert_badone	move.l	#$8BADC0DE,d7
		exec	Alert
.inf		bra	.inf		;Do not return any more
