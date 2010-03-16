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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*

PW_MAIN		SET	-1

		INCLUDE exec/ports.i
		INCLUDE exec/memory.i
		INCLUDE dos/dos.i
		INCLUDE dos/rdargs.i
		INCLUDE lvo/exec.i		;LVOs
		INCLUDE lvo/dos.i

		INCLUDE patchwork_rev.i
		INCLUDE patchwork.i
		INCLUDE refs.i

		SECTION text,CODE

Start	;-- DOS-Lib öffnen ---------------------;
		lea	(dosname,PC),a1
		moveq	#37,d0			;mindestens OS2.04
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
	;-- MessagePort einrichten -------------;
		moveq	#MP_SIZE,d0		;MessagePort belegen
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
	;-- Läuft PW bereits? ------------------;
		exec.q	Forbid			;natürlich! ;-)
		lea	(pwportname,PC),a1	;nach dem Port suchen
		exec.q	FindPort
		tst.l	d0
		beq	.no_port		;wir sind das erste mal hier!
	;-- Anderen PW abbrechen ---------------;
		move.l	d0,a0
		move.l	(MP_SIGTASK,a0),a1	;anderen Task holen
		move.l	#SIGBREAKF_CTRL_C,d0	;einfach ein CTRL-C schicken
		exec.q	Signal
		exec.q	Permit			;Multitasing läuft wieder
		lea	(msg_removing,PC),a0
		move.l	a0,d1
		dos	PutStr
		bra	.already		; und selbst beenden
	;-- Der erste Start --------------------;
.no_port	move.l	(msgport,PC),a1		;Port setzen
		exec.q	AddPort
		exec.q	Permit			;und weiter geht's
	;-- Parameter einlesen -----------------;
		lea	(template,PC),a0	;Parsen
		move.l	a0,d1
		lea	(args,PC),a0
		move.l	a0,d2
		moveq	#0,d3
		dos	ReadArgs
		move.l	d0,dosargs
		beq	.error5
	;-- Bearbeiten -------------------------;
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
.minos_err	movem.l d0-d1/a0-a1,-(SP)
		lea	(msg_bados,PC),a0
		move.l	a0,d1
		dos	PutStr
		movem.l (SP)+,d0-d1/a0-a1
.nominos	move	d0,(gl_MinOS,a1)
		moveq	#2,d0			;Stacklines
		tst.l	(arg_Stacklines,a0)
		beq	.stkok
		move.l	(arg_Stacklines,a0),a2
		move.l	(a2),d0
.stkok		move.l	d0,(gl_Stacklines,a1)
	;-- Timer initialisieren ---------------;
		bsr	InitTimer		;Timer initialisieren
		tst.l	d0
		beq	.error_tmr
	;-- Hauptprogramm ----------------------;
		lea	(msg_copyright,PC),a0
		move.l	a0,d1
		dos	PutStr
		bsr	SP_Exec			;Exec-Patches setzen
		bsr	SP_Dos			;DOS-Patches setzen
		bsr	SP_Graphics		;Graphics-Patches setzen
		bsr	SP_Intuition		;Intuition-Patches setzen
		bsr	SP_Utility		;Utility-Patches setzen
		bsr	SP_Commodities		;Commodities-Patches setzen
		bsr	SP_Gadtools		;Gadtools-Patches setzen
		move.l	#SIGBREAKF_CTRL_C,d0	;Warte auf CTRL-C
		exec	Wait
		bsr	RP_Gadtools		;Gadtools-Patches entfernen
		bsr	RP_Commodities		;Commodities-Patches entfernen
		bsr	RP_Utility		;Utility-Patches entfernen
		bsr	RP_Intuition		;Intuition-Patches entfernen
		bsr	RP_Graphics		;Graphics-Patches entfernen
		bsr	RP_Dos			;DOS-Patches entfernen
		bsr	RP_Exec			;Exec-Patches entfernen
		bsr	ExitTimer		;Timer beenden
		lea	(msg_removed,PC),a0
		move.l	a0,d1
		dos	PutStr
	;-- Fertig -----------------------------;
.error_tmr	move.l	(dosargs,PC),d1		;Result freigeben
		dos	FreeArgs
		move.l	(msgport,PC),a1		;MsgPort aushängen
		exec	RemPort
.already	move.l	(msgport,PC),a1
		exec	FreeVec
		move.l	(utilsbase,PC),a1	;UTILS freigeben
		exec	CloseLibrary
		move.l	(dosbase,PC),a1
		exec	CloseLibrary
		moveq	#0,d0			;Alles OK
.exit		rts
	;-- Fehler -----------------------------;
.error6		move.l	(dosargs,PC),d1		;Result freigeben
		dos	FreeArgs
.error5		move.l	(msgport,PC),a1		;MsgPort aushängen
		exec	RemPort
.error4		move.l	(msgport,PC),a1		;MsgPort entfernen
		exec	FreeVec

		move.l	(disasmbase,PC),d0	;Disassembler schließen, wenn verfügbar
		beq	.nodisasm
		move.l	d0,a1
		exec	CloseLibrary
.nodisasm

.error3		move.l	(utilsbase,PC),a1	;UTILS freigeben
		exec	CloseLibrary
.error2		move.l	(dosbase,PC),a1		;DOS freigeben
		exec	CloseLibrary
.error1		moveq	#10,d0			;Schlug fehl
		bra.b	.exit

	;-- Versionstrings ---------------------;
		VERSTAG
		dc.b	"(C) 1997-2010 Richard Körber",13,10,0
		PRGNAME
		dc.b	" - http://patchwork.shredzone.org",13,10,0
		even

	;-- Variablen --------------------------;
		XDEF	gl,dosbase,args,utilsbase,disasmbase
gl		ds.b	gl_SIZEOF		;Globale Variablen
dosbase		dc.l	0			;^DOS-Library
utilsbase	dc.l	0			;^Utils-Library
disasmbase	dc.l	0			;^Disassembler-Library
dosargs		dc.l	0			;^Ergebnis von Parse
msgport		dc.l	0			;^MessagePort
args		ds.b	arg_SIZEOF		;Parameter-Array
template	TEMPLATE

	;-- Texte ------------------------------;
msg_removing	dc.b	"Removing "
		PRGNAME
		dc.b	" now.\n",0
msg_removed	PRGNAME
		dc.b	" has been removed successfully.\n\n",0
msg_copyright	VERS
		dc.b	" (C) 1997-2010 by Richard Körber\n"
		PRGNAME
		dc.b	" - http://patchwork.shredzone.org\n\n"
		dc.b	"Press <CTRL> <C> to stop "
		PRGNAME
		dc.b	" again.\n",0
msg_bados	dc.b	"MINOS is out of range!\n",0

dosname		dc.b	"dos.library",0		;DOS-Lib
utilsname	dc.b	"utility.library",0	;Utils-Lib
disasmname	dc.b	"disassembler.library",0 ;Disasm-Lib
pwportname	PRGNAME
		dc.b	" port",0		;Rendezvous Port
		even


*
* AddPatchTab	-- Patch-Tabelle verwenden
*	-> a0.l ^Patch-Tabelle
*	-> a1.l ^Library-Base
*
		XDEF	AddPatchTab
AddPatchTab	movem.l d0-d3/a0-a6,-(SP)
		move.l	4.w,a6
		exec.q	Forbid
		move.l	a0,a4
		move.l	a1,a5
.patching	move	(a4)+,d0
		beq	.pdone
		move	d0,a0		;a0: Offset
		move.l	(a4)+,a3	;a3: Funktion
		lea	(6,a3),a1
		move.l	a1,d0		;d0: neue Funktion
		move.l	a5,a1		;a1: Base
		exec.q	Disable
		exec.q	SetFunction
		move.l	d0,(2,a3)	;alten Zeiger eintragen
		exec.q	CacheClearU	;Caches löschen
		exec.q	Enable
		bra	.patching
.pdone		exec.q	Permit
		movem.l (SP)+,d0-d3/a0-a6
		rts

*
* RemPatchTab	-- Patch-Tabelle entfernen
*	-> a0.l ^Patch-Tabelle
*	-> a1.l ^Library-Base
*
		XDEF	RemPatchTab
RemPatchTab	movem.l d0-d3/a0-a6,-(SP)
		move.l	4.w,a6
		exec.q	Forbid
		move.l	a0,a4
		move.l	a1,a5
.patching	move	(a4)+,d0
		beq	.pdone
		move	d0,a0		;a0: Offset
		move.l	(a4)+,a3	;a3: Funktion
		move.l	(2,a3),d0	;d0: alte Funktion
		beq	.patching	; 0: nächste
		move.l	a5,a1		;a1: base
		exec.q	Disable
		exec.q	SetFunction
		exec.q	CacheClearU
		exec.q	Enable
		bra	.patching
.pdone		exec.q	Permit
		movem.l (SP)+,d0-d3/a0-a6
		rts


*
* alert_badone	-- Schlechtes Patch-Control-Programm!
*
		XDEF	alert_badone
alert_badone	move.l	#$8BADC0DE,d7
		exec	Alert
.inf		bra	.inf		;Nie mehr zurückkehren!

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
