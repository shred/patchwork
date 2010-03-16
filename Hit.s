*
* PatchWork
*
* Copyright (C) 2010 Richard "Shred" Körber
*   http://patchwork.shredzone.org
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*

* Requires DisLib by Thomas Richter, available in the AmiNet

PW_HIT          SET     -1

		INCLUDE "exec/lists.i"
		INCLUDE "exec/nodes.i"
		INCLUDE "exec/semaphores.i"
		INCLUDE "exec/io.i"
		INCLUDE "exec/ports.i"
		INCLUDE "exec/tasks.i"
		INCLUDE "exec/execbase.i"
		INCLUDE "dos/dos.i"
		INCLUDE "lvo/exec.i"
		INCLUDE "lvo/disassembler.i"
		INCLUDE "libraries/disassembler.i"

		INCLUDE patchwork.i
		INCLUDE refs.i


		SECTION text,CODE

*********************************************************
* Name          ShowHit                                 *
* Funktion      Zeigt einen Hit über debug an           *
*                                                       *
* Parameter     -> a0.l ^StackFrame (d0-d7,a0-a7,PC)    *
*               -> a1.l ^Fehler-String                  *
*               -> a2.l ^Patch-Struct                   *
*               -> a6.l ^Library-Base                   *
*               -> d0.l Schwere des Fehlers             *
*               -> d1.l Stack mit Ausgabeparametern     *
*                                                       *
* Hinweis       · Alle Register werden gescratched      *
*                                                       *
*********************************************************
*> [ShowHit] GLOBAL
		XDEF    ShowHit
ShowHit         movem.l d0-d7/a0-a6,-(SP)
		move.l  a0,a5                   ;a5: Stackframe
		move.l  a2,a4                   ;a4: struct
		move.l  d0,d5                   ;d5: schwere
	;-- Schwere unter Treshold? ------------;
		cmp     (gl+gl_Tresh,PC),d5
		blo     .exit
	;-- OS unter MINOS? --------------------;
		swap    d5
		tst     d5                      ;immer raus?
		beq     .out
		cmp     (gl+gl_MinOS,PC),d5
		bls     .exit
		clr     d5
	;-- RomHits? ---------------------------;
.out            swap    d5
		move.l  (args+arg_RomHits,PC),d0
		bne     .romhits
		move.l  (REG_PC,a5),d0
		cmp.l   #$f80000,d0             ;etwa im ROM?
		blo     .romhits
		cmp.l   #$1000000,d0
		blo     .exit
.romhits
	;-- Forbid nötig? ----------------------;
.forbid         move.l  4.w,a6
		move.b  (TDNestCnt,a6),d7       ;d7: Forbid-Zustand
		cmp.b   #-1,d7                  ;aus?
		bne     .forbidden
		exec.q  Forbid                  ; wenn noch nicht
.forbidden
		movem.l d1/a1,-(SP)
	;-- CR anhängen ------------------------;
		lea     (.msg_cr,PC),a0
		jsr     KPrintF
	;-- Fehlerort-Ausgabe ------------------;
		move.l  SP,d6                   ;SP merken
		move.l  -(a4),a0                ;Ausgabetext
	;---- Parameter-Register ---------------;
.srcloop        moveq   #0,d1
		move.b  -(a4),d1
		move.b  -(a4),d0                ;Typ
		bmi     .srcdone
		move.l  (a5,d1.w),d1
	;---- STRing-Zeiger? -------------------;
		btst    #REGB_STR-8,d0          ;String?
		beq     .no_str
		tst.l   d1                      ;Null-Ptr?
		bne     .no_nullptr
		lea     (.msg_nullptr,PC),a1
		move.l  a1,d1
		bra     .no_str
.no_nullptr     ;; Test auf gültige Adresse?
.no_str
	;---- WORD ? ---------------------------;
		btst    #REGB_WORD-8,d0         ;Word?
		beq     .no_word
		ext.l   d1
.no_word
	;---- UWORD ? --------------------------;
		btst    #REGB_UWORD-8,d0        ;UWord?
		beq     .no_uword
		swap    d1
		clr     d1
		swap    d1
.no_uword
	;---- UBYTE ? --------------------------;
		btst    #REGB_UBYTE-8,d0        ;UByte?
		beq     .no_ubyte
		and.l   #$FF,d1
.no_ubyte
	;---- BPTR ? ---------------------------;
		btst    #REGB_BPTR-8,d0         ;BPTR?
		beq     .no_bptr
		lsl.l   #2,d1
.no_bptr
	;---- Resultat setzen ------------------;
		move.l  d1,-(SP)
		bra     .srcloop
.srcdone        move.l  (REG_A6,a5),a1          ;Lib-Base
		move.l  (LN_NAME,a1),-(SP)      ;Library-Name
		move.l  SP,a1
		jsr     KPrintF
		move.l  d6,SP                   ;Stack restaurieren
	;-- Fehlertext-Ausgabe -----------------;
		move.l  d5,-(SP)
		lea     (.msg_cause,PC),a0
		move.l  SP,a1
		jsr     KPrintF
		addq.l  #4,SP
		movem.l (SP)+,d1/a0
		move.l  d1,a1
		jsr     KPrintF                 ;Text ausgeben
		lea     (.msg_cr,PC),a0
		jsr     KPrintF
	;-- TINY? ------------------------------;
		move.l  (args+arg_Tiny,PC),d0
		bne     .done                   ; dann wars das
	;-- Angaben zum Task -------------------;
		sub.l   a1,a1
		exec    FindTask
		move.l  d0,a0
		move.l  (LN_NAME,a0),-(SP)
		move.l  a0,-(SP)
		move.l  (64,a5),a1
		subq.l  #4,a1                   ;sizeof(JSR(xxxx,a6))
		move.l  a1,-(SP)
		move.l  SP,a1
		lea     (.msg_pc,PC),a0
		jsr     KPrintF
		add.l   #3*4,SP
	;-- SMALL? -----------------------------;
		move.l  (args+arg_Small,PC),d0
		bne     .done                   ; dann wars das
	;-- Datenregister ausgeben -------------;
		lea     (.msg_dreg,PC),a0
		move.l  a5,a1                   ;Stackframe schon OK
		jsr     KPrintF
		move.l  (args+arg_DRegcheck,PC),d0
		beq     .nodreg
		move.l  a5,a1
		bsr     FindSegLine
.nodreg
	;-- Adreßregister ausgeben -------------;
		lea     (.msg_areg,PC),a0
		lea     (32,a5),a1
		jsr     KPrintF
		move.l  (args+arg_ARegcheck,PC),d0
		beq     .noareg
		lea     (32,a5),a1
		bsr     FindSegLine
.noareg
	;-- PC ausgeben ------------------------;
		move.l  (args+arg_ShowPC,PC),d0 ;nötig?
		beq     .nopc
		move.l  (64,a5),a1              ;PC
		sub.l   #32+4,a1
		lea     (.msg_pc8,PC),a0
		jsr     KPrintF
		move.l  (64,a5),a1
		subq.l  #4,a1                   ;sizeof(JSR(xxxx,a6))
		lea     (.msg_pcstar,PC),a0
		jsr     KPrintF
.nopc
	;-- Disassembling ausgeben -------------;
		move.l  (args+arg_DisPC,PC),d0  ;nötig?
		beq     .nodis
		move.l  (64,a5),a0              ;PC
		subq.l  #4,a0                   ;sizeof(JSR(xxxx,a6))
		bsr     Disassemble
.nodis
	;-- Stackframe ausgeben ----------------;
		lea     (.msg_stack,PC),a0
		move.l  (60,a5),a1              ;^SP
		move.l  (gl+gl_Stacklines,PC),d0
.stkloop1       subq.l  #1,d0                   ;Zählen
		bcs     .stk1done
		movem.l a0/a1/d0,-(SP)
		jsr     KPrintF
		movem.l (SP)+,a0/a1/d0
		add.l   #8*4,a1
		bra     .stkloop1
.stk1done
	;-- SegTracker für PC ------------------;
		move.l  (64,a5),d0              ;PC
		subq.l  #4,d0                   ;sizeof(JSR(xxxx,a6))
		bsr     FindSeg
	;-- SegTracker für Stack ---------------;
		move.l  (args+arg_Stackcheck,PC),d0
		beq     .nostckchk
		move.l  (60,a5),a3
		move.l  (gl+gl_Stacklines,PC),d3
		lsl.l   #3,d3
.stk2loop       subq.l  #1,d3
		bcs     .nostckchk
		move.l  (a3)+,d0
		bsr     FindSeg
		bra     .stk2loop
.nostckchk
	;-- Forbid ggfs. auflösen --------------;
.done           tst.b   d7                      ;Wie war es?
		cmp.b   #-1,d7                  ;aus?
		bne     .nopermit
		exec.q  Permit
.nopermit
	;-- Fertig -----------------------------;
.exit           movem.l (SP)+,d0-d7/a0-a6
		rts

.msg_cause      dc.b    "\nSeverity %ld: ",0
.msg_dreg       dc.b    "Data: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_areg       dc.b    "Addr: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_pc8        dc.b    "PC-8: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_pcstar     dc.b    "PC *: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_stack      dc.b    "Stck: %08lx %08lx %08lx %08lx %08lx %08lx %08lx %08lx\n",0
.msg_pc         dc.b    "PC=%08lx TCB=%08lx (\"%s\")"
.msg_cr         dc.b    "\n",0
.msg_nullptr    dc.b    "[NULL POINTER]",0
		even
*<

*********************************************************
* Name          FindSegLine                             *
* Funktion      SegTracker-Ausgabe für eine Zeile       *
*                                                       *
* Parameter     -> a1.l Zeiger auf Langwörter (8 Stck)  *
*                                                       *
* Hinweis       · muß bereits im Forbid-State sein!     *
*               · nur d3-d7/a3-a5 werden gerettet       *
*                                                       *
*********************************************************
*> [FindSegLine]
FindSegLine     movem.l a3/d3,-(SP)
		move.l  a1,a3
		moveq   #7,d3
.loop           move.l  (a3)+,d0
		bsr     FindSeg
		dbra    d3,.loop
		movem.l (SP)+,a3/d3
		rts
*<

*********************************************************
* Name          FindSeg                                 *
* Funktion      SegTracker-Ausgabe                      *
*                                                       *
* Parameter     -> d0.l zu analysierender PC            *
*                                                       *
* Hinweis       · muß bereits im Forbid-State sein!     *
*               · nur d3-d7/a3-a5 werden gerettet       *
*                                                       *
*********************************************************
*> [FindSeg]
		clrfo
str_buffer      fo.b    200                     ;Textbuffer
str_offset      fo.l    1                       ;offset
str_hunk        fo.l    1                       ;hunk
str_bufptr      fo.l    1
str_val         fo.l    1
str_SIZEOF      fo.w    0

FindSeg         movem.l d3-d7/a3-a4,-(SP)
		link    a5,#str_SIZEOF
		move.l  d0,(str_val,a5)         ;Adresse schon mal eintragen
		lea     (.segtrname,PC),a1      ;Segtracker finden
		exec    FindSemaphore
		tst.l   d0
		beq     .exit                   ;kein Segtracker
		move.l  d0,a3                   ;^Semaphore merken
		move.l  (str_val,a5),a0         ;Aufruf vorbereiten
		lea     (str_hunk,a5),a1
		lea     (str_offset,a5),a2
		move.l  (SS_SIZE,a3),a4         ;^Funktion
		jsr     (a4)                    ;  aufrufen
		tst.l   d0                      ;gibt es ein Ergebnis?
		beq     .exit                   ;  nein: raus
		move.l  d0,a0                   ;String kopieren
		lea     (str_buffer,a5),a1
		move.l  a1,(str_bufptr,a5)
		move    #198,d0
.copy           move.b  (a0)+,(a1)+
		dbeq    d0,.copy
		clr.b   (a1)                    ;terminieren
		lea     (.msg_segtrstr,PC),a0   ;und die ganze Nachricht ausgeben
		lea     (str_val,a5),a1
		jsr     KPrintF
.exit           unlk    a5
		movem.l (SP)+,d3-d7/a3-a4
		rts
.segtrname      dc.b    "SegTracker",0
.msg_segtrstr   dc.b    "----> %08lx - \"%s\"  Hunk %04lx, Offset %08lx\n",0
		even
*<

*********************************************************
* Name          Disassemble                             *
* Funktion      Disassembliert                          *
*                                                       *
* Parameter     -> a0.l zu disassemblierender PC        *
*                                                       *
* Hinweis       · nur d3-d7/a3-a5 werden gerettet       *
*                                                       *
*********************************************************
*> [Disassemble]
		clrfo
dis_PC          fo.l    1
dis_Range       fo.l    1
dis_struct      fo.b    ds_SIZE
dis_SIZEOF      fo.w    0

Disassemble     movem.l d3-d7/a3-a4,-(SP)
		link    a5,#dis_SIZEOF
		move.l  (disasmbase,PC),d0      ;Disassembler vorhanden?
		beq     .exit
		move.l  a0,(dis_PC,a5)
	;-- Range holen ------------------------;
		moveq   #32,d1                  ;Default: 32 byte
		move.l  (args+arg_DisRange,PC),d0
		beq     .usedef
		move.l  d0,a1
		move.l  (a1),d1
.usedef         move.l  d1,(dis_Range,a5)
	;-- Start suchen -----------------------;
		move.l  (dis_Range,a5),d0       ;Min
		move.l  d0,d1
		addq.l  #8,d1
		addq.l  #8,d1                   ;Max
		move.l  (dis_PC,a5),a0          ;PC
		disasm  FindStartPosition
	;-- Disassemblieren --------------------;
		move.l  d0,(dis_struct+ds_From,a5)
		move.l  (dis_PC,a5),a0
		move.l  a0,(dis_struct+ds_PC,a5)
		add.l   (dis_Range,a5),a0
		move.l  a0,(dis_struct+ds_UpTo,a5)
		lea     (.putproc,PC),a1
		move.l  a1,(dis_struct+ds_PutProc,a5)
		clr.l   (dis_struct+ds_UserData,a5)
		clr     (dis_struct+ds_Truncate,a5)
		lea     (dis_struct,a5),a0
		disasm  Disassemble
	;-- Fertig -----------------------------;
.exit           unlk    a5
		movem.l (SP)+,d3-d7/a3-a4
		rts

	;== Ausgaberoutine =====================;
	; d0.b  auszugebendes Zeichen
.putproc        movem.l d0-d7/a0-a6,-(SP)
		jsr     KPutChar
		movem.l (SP)+,d0-d7/a0-a6
		rts
*<

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
