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

PW_GADTOOLS     SET     -1

		INCLUDE "exec/lists.i"
		INCLUDE "exec/nodes.i"
		INCLUDE "exec/libraries.i"
		INCLUDE "exec/memory.i"
		INCLUDE "utility/utility.i"
		INCLUDE "libraries/gadtools.i"
		INCLUDE "lvo/exec.i"
		INCLUDE "lvo/utility.i"
		INCLUDE "lvo/gadtools.i"

		INCLUDE patchwork.i
		INCLUDE refs.i

		SECTION text,CODE

*********************************************************
* Name          SP_Gadtools                             *
* Funktion      Gadtools-Patches setzen                 *
*                                                       *
* Parameter     keine                                   *
*                                                       *
*********************************************************
*> [SP_Gadtools] GLOBAL
		XDEF    SP_Gadtools
SP_Gadtools     movem.l a0-a1,-(SP)
	;-- Library öffnen ---------------------;
		lea     (.gadname,PC),a1
		moveq   #36,d0
		exec    OpenLibrary
		move.l  d0,gadbase
		beq     .done
	;-- Alle V36 patchen -------------------;
		move.l  d0,a1                   ;Alle V36+ Funktionen patchen
		lea     (v36_patches,PC),a0
		bsr     AddPatchTab
	;-- Alle V39 patchen -------------------;
		cmp     #39,(LIB_VERSION,a1)
		blo     .done
		lea     (v39_patches,PC),a0     ;V39+ patchen
		bsr     AddPatchTab
	;-- Fertig -----------------------------;
.done           movem.l (SP)+,a0-a1
		rts
	;-- Texte ------------------------------;
.gadname        dc.b    "gadtools.library",0
		even
*<
*********************************************************
* Name          RP_Gadtools                             *
* Funktion      Patches entfernen                       *
*                                                       *
* Parameter     keine                                   *
*                                                       *
*********************************************************
*> [RP_Gadtools] GLOBAL
		XDEF    RP_Gadtools
RP_Gadtools     movem.l a0-a1,-(SP)
		move.l  (gadbase,PC),d0
		beq     .exit
	;-- V36+ entfernen ---------------------;
		move.l  d0,a1                   ;V36-Patches entfernen
		lea     (v36_patches,PC),a0
		bsr     RemPatchTab
	;-- V39+ entfernen ---------------------;
		cmp     #39,(LIB_VERSION,a1)
		blo     .close
		lea     (v39_patches,PC),a0     ;V39+ patchen
		bsr     RemPatchTab
	;-- Lib schließen ----------------------;
.close          exec    CloseLibrary
	;-- Fertig -----------------------------;
.exit           movem.l (SP)+,a0-a1
		rts
*<
*********************************************************
* Name          gadtools_patches                        *
* Funktion      Tabelle aller Gadtools-Patches          *
*********************************************************
*> [v??_patches]
v36_patches     dpatch  _GADCreateContext,P_CreateContext
		dpatch  _GADCreateGadgetA,P_CreateGadgetA
		dpatch  _GADGT_RefreshWindow,P_RefreshWindow
		dpatch  _GADGT_SetGadgetAttrsA,P_SetGadgetAttrsA
		dc.w    0

v39_patches     dpatch  _GADGT_GetGadgetAttrsA,P_GetGadgetAttrsA
		dc.w    0
*<

gadbase         dc.l    0

*****************************************************************
*       == DIE PATCH-ROUTINEN                                   *
*****************************************************************

*********************************************************
* Patch         CreateContext()                         *
* Tests         - glistptr points to NULL               *
*********************************************************
*> [CreateContext()]
 PATCH P_CreateContext,"CreateContext(0x%08lx)",REG_A0

		tst.l   (a0)                    ;==NULL !!!
		beq     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notinited,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_notinited  dc.b    "glistpointer is not set to NULL",0
		even
*<

*********************************************************
* Patch         CreateGadget()                          *
* Tests         - kind known?                           *
*               - prev is NULL                          *
*               - <V40 combination of tags              *
*               - visualinfo && textattr set?           *
*********************************************************
*> [CreateGadgetA()]
 PATCH P_CreateGadgetA,"CreateGadgetA(%ld,0x%08lx,0x%08lx,0x%08lx)",REG_D0,REG_A0,REG_A1,REG_A2

		movem.l d0-d7/a0-a7,-(SP)
	;-- Check the kind ---------------------;
		cmp.l   #NUM_KINDS,d0
		bhs     .badnumber
		cmp.l   #10,d0
		bne     .number_ok
.badnumber      move.l  SP,a0
		lea     (.msg_badkind,PC),a1
		lea     (.THIS,PC),a2
		move.l  d0,-(SP)
		move.l  SP,d1
		moveq   #2,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit
		add.l   #4,SP
.number_ok
	;-- Previous must not be NULL ----------;
		movem.l (SP),d0-d7/a0-a6
		move.l  a0,d0
		bne     .prev_ok
		move.l  SP,a0
		lea     (.msg_prevnull,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit
	;-- Check NewGadget contents -----------;
.prev_ok        movem.l (SP),d0-d7/a0-a6
		lea     (.msg_newgadnull,PC),a1
		move.l  a1,d0
		beq     .put_newgad
		lea     (.msg_vinull,PC),a1
		tst.l   (gng_VisualInfo,a1)
		beq     .put_newgad
		lea     (.msg_tanull,PC),a1
		tst.l   (gng_TextAttr,a1)
		bne     .newgad_ok
.put_newgad     move.l  SP,a0
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit

	;; TODO: check for GTNM_Justification and GTNM_Clipped==TRUE : ELSE V40+ required
.newgad_ok      movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badkind    dc.b    "illegal gadget kind %ld",0
.msg_prevnull   dc.b    "previous must not be NULL",0
.msg_newgadnull dc.b    "newgad must not be NULL",0
.msg_vinull     dc.b    "no ng_VisualInfo given",0
.msg_tanull     dc.b    "no ng_TextAttr given",0
		even
*<

*********************************************************
* Patch         RefreshWindow()                         *
* Tests         - req not NULL                          *
*********************************************************
*> [RefreshWindow()]
 PATCH P_RefreshWindow,"GT_RefreshWindow(0x%08lx,0x%08lx)",REG_A0,REG_A1

		move.l  a1,d0                   ;;d0 will be trashed!!!
		beq     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notnull,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_notnull    dc.b    "set req to NULL for future compatibility",0
		even
*<

*********************************************************
* Patch         SetGadgetAttrsA()                       *
* Tests         - req not NULL                          *
*********************************************************
*> [SetGadgetAttrsA()]
 PATCH P_SetGadgetAttrsA,"GT_SetGadgetAttrsA(0x%08lx,0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2,REG_A3

		move.l  a2,d0                   ;;d0 will be trashed!!!
		beq     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notnull,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_notnull    dc.b    "set req to NULL for future compatibility",0
		even
*<


*********************************************************
* Patch         GetGadgetAttrsA()                   V39 *
* Tests         - req not NULL                          *
*               - Tag* longword aligned                 *
*********************************************************
*> [GetGadgetAttrsA()]
 PATCH P_GetGadgetAttrsA,"GT_GetGadgetAttrsA(0x%08lx,0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2,REG_A3

		move.l  a2,d0                   ;;d0 will be trashed!!!
		beq     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notnull,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  (gadbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_notnull    dc.b    "set req to NULL for future compatibility",0
		even
*<

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
