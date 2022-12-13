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

		IFND	PATCHWORK_I
PATCHWORK_I	SET	-1

TEMPLATE	MACRO
		dc.b	"L=LEVEL/K/N,"
		dc.b	"MINOS/K/N,"
		dc.b	"TINY/S,"
		dc.b	"SMALL/S,"
		dc.b	"STL=STACKLINES/K/N,"
		dc.b	"STC=STACKCHECK/S,"
		dc.b	"SHOWPC/S,"
		dc.b	"AREG=AREGCHECK/S,"
		dc.b	"DREG=DREGCHECK/S,"
		dc.b	"ROMHITS/S,"
		dc.b	"DEADLY/S,"
		dc.b	"DIS=DISABLECHECK/S,"
		dc.b	"NPM=NOPERMIT/S,"
		dc.b	"NODISPC/S,"
		dc.b	"DR=DISRANGE/K/N,"
		dc.b	"TN=TASKNAME/K"
		dc.b	0
		ENDM

		rsreset		;-- Parameter Structure (args+)
arg_Tresh	rs.l	1	;Output treshold
arg_MinOS	rs.l	1	;MinOS
arg_Tiny	rs.l	1	;Only the first line
arg_Small	rs.l	1	;Only reason and PC
arg_Stacklines	rs.l	1	;Stack lines
arg_Stackcheck	rs.l	1	;Test stack with SegTracker
arg_ShowPC	rs.l	1	;Show PC area
arg_ARegcheck	rs.l	1	;Test address registers with SegTracker
arg_DRegcheck	rs.l	1	;Test data registers with SegTracker
arg_RomHits	rs.l	1	;Also throw hits from the AmigaOS ROM
arg_Deadly	rs.l	1	;Deadly Hits
arg_ChkDisable	rs.l	1	;Check Disable()
arg_NoPermit	rs.l	1	;Do not patch Permit()
arg_NoDisPC	rs.l	1	;Do not disassemble PC
arg_DisRange	rs.l	1	;Disassembly range
arg_TaskName	rs.l	1	;Task name
arg_SIZEOF	rs.w	0	; Structure size

		rsreset		;-- Global Variables
gl_Stacklines	rs.l	1	;Lines of the stack
gl_Tresh	rs.w	1	;Treshold
gl_MinOS	rs.w	1	;MinOS, or 0 for all OS
gl_SIZEOF	rs.w	0


dpatch		MACRO	;<function offset> <new function>
		dc.w	\1
		dc.l	\2
		ENDM

		rsreset		;-- Register on the stack --
REG_D0		rs.l	1
REG_D1		rs.l	1
REG_D2		rs.l	1
REG_D3		rs.l	1
REG_D4		rs.l	1
REG_D5		rs.l	1
REG_D6		rs.l	1
REG_D7		rs.l	1
REG_A0		rs.l	1
REG_A1		rs.l	1
REG_A2		rs.l	1
REG_A3		rs.l	1
REG_A4		rs.l	1
REG_A5		rs.l	1
REG_A6		rs.l	1
REG_A7		rs.l	1
REG_PC		rs.l	1
REG_SP		rs.l	0	;the stack area starts here
REG_TERM	EQU	-1

REGB_STR	EQU	8	;String pointer
REGF_STR	EQU	1<<REGB_STR
REGB_WORD	EQU	9	;signed word
REGF_WORD	EQU	1<<REGB_WORD
REGB_UWORD	EQU	10	;unsigned word
REGF_UWORD	EQU	1<<REGB_UWORD
REGB_UBYTE	EQU	11	;unsigned byte
REGF_UBYTE	EQU	1<<REGB_UBYTE
REGB_BPTR	EQU	12	;BPTR
REGF_BPTR	EQU	1<<REGB_BPTR
REGB_TERM	EQU	15	;Termination (reserved)

PATCH		MACRO	;<name>,<desc>[,<reg offset>,...]
		IFND	alert_badone
		XREF	alert_badone
		ENDC
desc\@		dc.b	"%s ",\2,0	;Description
		even
		dc.w	REG_TERM
CARG		SET	3
		REPT	NARG-2
		dc.w	\+
		ENDR
		dc.l	desc\@		;text
\1		ds.w	0
.THIS		dc.w	$4ef9		;JMP	$xxxxxxxx.l
		dc.l	alert_badone
		; function starts here
		ENDM

		ENDC
