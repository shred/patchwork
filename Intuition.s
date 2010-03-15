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

PW_INTUITION    SET     -1

		INCDIR  "INCLUDE:"
		INCLUDE "exec/lists.i"
		INCLUDE "exec/nodes.i"
		INCLUDE "exec/semaphores.i"
		INCLUDE "exec/libraries.i"
		INCLUDE "exec/memory.i"
		INCLUDE "exec/ports.i"
		INCLUDE "dos/dos.i"
		INCLUDE "intuition/intuition.i"
		INCLUDE "lvo/exec.i"
		INCLUDE "lvo/intuition.i"
		INCLUDE "PhxMacros.i"

		INCDIR  "CURRINC:"
		INCLUDE patchwork.i
		INCLUDE refs.i

		SECTION text,CODE

*********************************************************
* Name          SP_Intuition                            *
* Funktion      Intuition-Patches setzen                *
*                                                       *
* Parameter     keine                                   *
*                                                       *
*********************************************************
*> [SP_Intuition] GLOBAL
		XDEF    SP_Intuition
SP_Intuition    movem.l a0-a1,-(SP)
		lea     (.intuiname,PC),a1
		moveq   #36,d0
		exec    OpenLibrary
		move.l  d0,intuibase
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
.intuiname      dc.b    "intuition.library",0
		even
*<
*********************************************************
* Name          RP_Intuition                            *
* Funktion      Intuition-Patches entfernen             *
*                                                       *
* Parameter     keine                                   *
*                                                       *
*********************************************************
*> [RP_Intuition] GLOBAL
		XDEF    RP_Intuition
RP_Intuition    movem.l a0-a1,-(SP)
		move.l  (intuibase,PC),d0       ;IntuiBase da?
		beq     .nointui
	;-- V36+ entfernen ---------------------;
		move.l  d0,a1                   ;V36-Patches entfernen
		lea     (v36_patches,PC),a0
		bsr     RemPatchTab
	;-- V39+ entfernen ---------------------;
		cmp     #39,(LIB_VERSION,a1)
		blo     .close
		lea     (v39_patches,PC),a0     ;V39+ patchen
		bsr     RemPatchTab
	;-- Library schließen ------------------;
.close          exec    CloseLibrary            ;Library schließen
.nointui        movem.l (SP)+,a0-a1
		rts
*<
*********************************************************
* Name          intui_patches                           *
* Funktion      Tabelle aller Intuition-Patches         *
*********************************************************
*> [v??_patches]
v36_patches     dpatch  _INTCloseWindow,P_CloseWindow
		dpatch  _INTEasyRequestArgs,P_EasyRequestArgs
		dpatch  _INTGadgetMouse,P_GadgetMouse
		dpatch  _INTGetDefaultPubScreen,P_GetDefaultPubScreen
		dpatch  _INTMakeClass,P_MakeClass
		dpatch  _INTMakeScreen,P_MakeScreen
		dpatch  _INTModifyIDCMP,P_ModifyIDCMP
		dpatch  _INTRemakeDisplay,P_RemakeDisplay
		dpatch  _INTRequest,P_Request
		dpatch  _INTRethinkDisplay,P_RethinkDisplay
		dpatch  _INTSetEditHook,P_SetEditHook
		dpatch  _INTSetMenuStrip,P_SetMenuStrip
		dpatch  _INTSetPointer,P_SetPointer
		dc.w    0                       ;Ende!

v39_patches     dpatch  _INTScreenDepth,P_ScreenDepth
		dc.w    0                       ;Ende!

*<

intuibase       dc.l    0                       ;IntuiBase


*****************************************************************
*       == DIE PATCH-ROUTINEN                                   *
*****************************************************************

; PATCH P_ActivateGadget,"ActivateGadget(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2
;       P_AllocScreenBuffer
;       P_DoGadgetMethodA
;       P_DrawImage
;       P_ModifyProp
;       P_OffGadget
;       P_OnGadget
;       P_RefreshGadgets
;       P_RefreshGList
;       P_SetGadgetAttrsA
;       P_OpenWindow ???
;       P_OpenWindowTags ???
;       P_PubScreenStatus ???

*********************************************************
* Patch         CloseWindow()                           *
* Tests         - Keine Messages mehr für das Window    *
*********************************************************
*> [CloseWindow()]
 PATCH P_CloseWindow,"CloseWindow(0x%08lx)",REG_A0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  a0,a4                   ;^Merken
	;-- Sind noch Nachrichten in der Queue -;
		moveq   #0,d7                   ;eigene Msg zählen...
		moveq   #0,d6                   ;fremde Msg zählen
		move.l  (wd_UserPort,a4),d0     ;^UserPort
		beq     .no_port                ;schon freigegeben
		move.l  d0,a0                   ;^MsgPort
		move.l  (MP_MSGLIST,a0),a0      ;^erste Node
.loop           tst.l   (a0)                    ;zu Ende?
		beq     .list_done
		addq.l  #1,d6                   ;Fremde Node
		cmp.l   (im_IDCMPWindow,a0),a4  ;Ist es das Window?
		bne     .no_msg
		addq.l  #1,d7                   ;Pfui Teufel!
		subq.l  #1,d6                   ;Doch keine fremde Node
.no_msg         move.l  (a0),a0
		bra     .loop
.list_done      tst.l   d7                      ;und?
		beq     .no_port                ; 0 ist in Ordnung!
		tst.l   d6                      ;gab es was fremdes?
		beq     .no_port                ; nein: Port sauber entfernt
		move.l  SP,a0
		move.l  d7,-(SP)
		lea     (.msg_outmsg,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
.no_port
	;-- Gibt's noch einen Menu-Strip -------;
		tst.l   (wd_MenuStrip,a4)
		beq     .no_menu
		move.l  SP,a0
		move.l  (wd_MenuStrip,a4),-(SP)
		lea     (.msg_menustrip,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
.no_menu
	;-- Alles OK ---------------------------;
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_outmsg     dc.b    "still %ld Messages in the shared Window queue",0
.msg_menustrip  dc.b    "MenuStrip @0x%08lX not cleared",0
		even
*<

*********************************************************
* Patch         EasyRequestArgs()                       *
* Tests         - es_StructSize ok?                     *
*               - es_GadgetFormat hat ein Gadget        *
*********************************************************
*> [EasyRequestArgs()]
 PATCH P_EasyRequestArgs,"EasyRequestArgs(0x%08lx,0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2,REG_A3

		move.l  a1,d0                   ;; d0 WIRD VERÄNDERT!!!
		beq     .THIS                   ; keine EasyStruct: Enforcer wird grüßen
		movem.l d0-d7/a0-a7,-(SP)
	;-- StructSize OK ----------------------;
		move.l  (es_StructSize,a1),d0   ;Struct-Size
		cmp.l   #5*4,d0                 ;< mindestlänge? (EasyStruct_SIZEOF bis OS3.1)
		bhs     .size_ok
		move.l  SP,a0
		move.l  a1,-(SP)
		move.l  d0,-(SP)
		lea     (.msg_badsize,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
		move.l  (SP)+,a1
	;-- Gibt es ein Gadget? ----------------;
.size_ok        move.l  (es_GadgetFormat,a1),d0 ;Überhaupt ein Zeiger?
		beq     .no_string
		move.l  d0,a0                   ;Leerer String?
		tst.b   (a0)
		bne     .all_ok
.no_string      move.l  SP,a0
		lea     (.msg_badgadget,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
	;-- Alles OK ---------------------------;
.all_ok         movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badsize    dc.b    "es_StructSize is wrong (%ld byte)",0
.msg_badgadget  dc.b    "no gadget specified",0
		even
*<

*********************************************************
* Patch         GadgetMouse()                           *
* Tests         - Veraltet                              *
*********************************************************
*> [GadgetMouse()]
 PATCH P_GadgetMouse,"GadgetMouse(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_obsoleted,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		move.l  SP,d1
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_obsoleted  dc.b    "obsoleted, improve your class implementation",0
		even
*<

*********************************************************
* Patch         GetDefaultPubScreen()                   *
* Tests         - DEADLY                                *
*********************************************************
*> [GetDefaultPubScreen()]
 PATCH P_GetDefaultPubScreen,"GetDefaultPubScreen(0x%08lx)",REG_A0

		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit? ;;d0 wird verändert!!!
		beq     .THIS                   ; nee
		bsr     .THIS                   ;sonst Ergebnis holen
		tst.l   d0                      ;kein Screen da?
		beq     .leave
		move.l  #$FACEDEAD,d0           ;Text
.leave          rts
*<

*********************************************************
* Patch         MakeClass()                             *
* Tests         - keine NULL-Superclass                 *
*********************************************************
*> [MakeClass()]
 PATCH P_MakeClass,"MakeClass(\"%s\",\"%s\",0x%08lx,%ld,0x%08lx)",REG_A0|REGF_STR,REG_A1|REGF_STR,REG_A2,REG_D0|REGF_WORD,REG_D1

		movem.l d0-d7/a0-a7,-(SP)
		move.l  a1,d2
		move.l  a2,d3
		or.l    d3,d2
		bne     .okay
		move.l  SP,a0
		lea     (.msg_nosuper,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
.okay           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_nosuper    dc.b    "no superclass specified",0
		even
*<

*********************************************************
* Patch         MakeScreen()                            *
* Tests         - Returncode erst ab V39                *
*********************************************************
*> [MakeScreen()]
 PATCH P_MakeScreen,"MakeScreen(0x%08lx)",REG_A0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit? ;;d0 wird verändert!!!
		beq     .THIS                   ; nee
		bsr     .THIS                   ;sonst ausführen
		move.l  #$FACEDEAD,d0           ; und worst case zurück
		rts

.msg_v39        dc.b    "return code requires V39+",0
		even
*<

*********************************************************
* Patch         ModifyIDCMP()                           *
* Tests         - Keine Messages mehr für das Window    *
*               - Returncode erst ab V37                *
*********************************************************
*> [ModifyIDCMP()]
 PATCH P_ModifyIDCMP,"ModifyIDCMP(0x%08lx,0x%08lx)",REG_A0,REG_D0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  a0,a4                   ;^Merken
	;-- Sind noch Nachrichten in der Queue -;
		tst.l   d0                      ;Soll auf 0 gesetzt werden?
		bne     .no_port                ;  nein: dann egal
		moveq   #0,d7                   ;eigene Msg zählen...
		moveq   #0,d6                   ;fremde Msg zählen
		move.l  (wd_UserPort,a4),d0     ;^UserPort
		beq     .no_port                ;schon freigegeben
		move.l  d0,a0                   ;^MsgPort
		move.l  (MP_MSGLIST,a0),a0      ;^erste Node
.loop           tst.l   (a0)                    ;zu Ende?
		beq     .list_done
		addq.l  #1,d6                   ;Fremde Node
		cmp.l   (im_IDCMPWindow,a0),a4  ;Ist es das Window?
		bne     .no_msg
		addq.l  #1,d7                   ;Pfui Teufel!
		subq.l  #1,d6                   ;Doch keine fremde Node
.no_msg         move.l  (a0),a0
		bra     .loop
.list_done      tst.l   d7                      ;und?
		beq     .no_port                ; 0 ist in Ordnung!
		tst.l   d6                      ;gab es was fremdes?
		beq     .no_port                ; nein: Port sauber entfernt
		move.l  SP,a0
		move.l  d7,-(SP)
		lea     (.msg_outmsg,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
.no_port        move.l  SP,a0
		lea     (.msg_v37,PC),a1
		lea     (.THIS,PC),a2
		moveq   #37,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS


.msg_outmsg     dc.b    "still %ld Messages in the shared Window queue",0
.msg_v37        dc.b    "return code requires V37+",0
		even
*<

*********************************************************
* Patch         RemakeDisplay()                         *
* Tests         - Returncode erst ab V39                *
*********************************************************
*> [RemakeDisplay()]
 PATCH P_RemakeDisplay,"RemakeDisplay()"

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit? ;;d0 wird verändert!!!
		beq     .THIS                   ; nee
		bsr     .THIS                   ;sonst ausführen
		move.l  #$FACEDEAD,d0           ; und worst case zurück
		rts

.msg_v39        dc.b    "return code requires V39+",0
		even
*<

*********************************************************
* Patch         Request()                               *
* Tests         - Maximal 8 Requester in best. Windows  *
*********************************************************
*> [Request()]
 PATCH P_Request,"Request(0x%08lx,0x%08lx)",REG_A0,REG_A1

		move.l  a1,d0                   ;; d0 VERÄNDERT!
		beq     .THIS                   ; Enforcer macht das schon...
		movem.l d0-d7/a0-a7,-(SP)
		move.l  (wd_Flags,a1),d0        ;Flags holen
		and.l   #WFLG_SIZEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET,d0
		beq     .done                   ;  nichts davon
		moveq   #0,d0                   ;Zähler
		move.l  (wd_FirstRequest,a1),a2 ;^Requester-Liste
.loop           move.l  a2,d1                   ;Ende?
		beq     .cntdone
		addq.l  #1,d0
		move.l  (a2),a2                 ;nächster Requester
		bra     .loop
.cntdone        cmp.l   #9,d0                   ;>8 Requester?
		blo     .done                   ;nein->Okay
		move.l  SP,a0
		lea     (.msg_maxreq,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.done           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS                   ; nee

.msg_maxreq     dc.b    "maximum of 8 requesters exceeded"
		even
*<

*********************************************************
* Patch         RethinkDisplay()                        *
* Tests         - Returncode erst ab V39                *
*********************************************************
*> [RethinkDisplay()]
 PATCH P_RethinkDisplay,"RethinkDisplay()"

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit? ;;d0 wird verändert!!!
		beq     .THIS                   ; nee
		bsr     .THIS                   ;sonst ausführen
		move.l  #$FACEDEAD,d0           ; und worst case zurück
		rts

.msg_v39        dc.b    "return code requires V39+",0
		even
*<

*********************************************************
* Patch         ScreenDepth()                           *
* Tests         - Reserved muß NULL sein                *
*********************************************************
*> [ScreenDepth()]
 PATCH P_ScreenDepth,"ScreenDepth(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_D0,REG_A1

		move.l  a1,d1                   ;; REGISTER WIRD VERÄNDERT
		beq     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notnull,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_notnull    dc.b    "reserved must be NULL",0
		even
*<

*********************************************************
* Patch         SetEditHook()                           *
* Tests         - riskant!
*********************************************************
*> [SetEditHook()]
 PATCH P_SetEditHook,"SetEditHook(0x%08lx)",REG_A0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_risky,PC),a1
		lea     (.THIS,PC),a2
		moveq   #0,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS                   ;sonst ausführen

.msg_risky      dc.b    "risky function",0
		even
*<

*********************************************************
* Patch         SetMenuStrip()                          *
* Tests         - Mindestens ein Item                   *
*********************************************************
*> [SetMenuStrip()]
 PATCH P_SetMenuStrip,"SetMenuStrip(0x%08lx,0x%08lx)",REG_A0,REG_A1

		movem.l d0-d7/a0-a7,-(SP)
		move.l  a1,d0                   ;Gibt's überhaupt ein Menu?
		bne     .done   ;;
;;                beq     .no_menu
;;                move.l  a1,a5
;;.loop           move.l  a5,d0                   ;Ende?
;;                beq     .done
;;                tst.l   (mu_FirstItem,a5)       ;Ein Menüitem?
;;                bne     .next
;;                move.l  SP,a0
;;                move.l  (mu_MenuName,a5),d0
;;                beq     .no_name
;;                move.l  d0,-(SP)
;;                bra     .out
;;.no_name        pea     (.msg_noname,PC)
;;.out            lea     (.msg_noitems,PC),a1
;;                lea     (.THIS,PC),a2
;;                moveq   #3,d0
;;                move.l  SP,d1
;;                bsr     ShowHit
;;                add.l   #4,SP
;;.next           move.l  (mu_NextMenu,a5),a5
;;                bra     .loop
.no_menu        move.l  SP,a0
		lea     (.msg_nomenu,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.done           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

;;.msg_noname     dc.b    "[NULL ptr]",0
.msg_nomenu     dc.b    "where is the menu?",0
;;.msg_noitems    dc.b    "menu \"%s\" has no menu items",0
		even
*<

*********************************************************
* Patch         SetPointer()                            *
* Tests         - Zeiger im Chip-RAM                    *
*               - Breite <16                            *
*               - Offset <=0                            *
*********************************************************
*> [SetPointer()]
 PATCH P_SetPointer,"SetPointer(0x%08lx,0x%08lx,%ld,%ld,%ld,%ld)",REG_A0,REG_A1,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_D2|REGF_WORD,REG_D3|REGF_WORD

		movem.l d0-d7/a0-a7,-(SP)
	;-- Spritebreite -----------------------;
		cmp     #16,d1                  ;d1<=16 ?
		bls     .width_ok
		move.l  SP,a0
		movem.l d0-d3/a1,-(SP)
		lea     (.msg_badwidth,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d3/a1
	;-- Offset -----------------------------;
.width_ok       subq    #1,d2                   ;d2<=0
		bpl     .bad_offset
		subq    #1,d3                   ;d3<=0
		bpl     .bad_offset
		neg     d2
		cmp     d0,d2
		bgt     .bad_offset
		neg     d3
		cmp     d1,d3
		ble     .off_ok
.bad_offset     move.l  a1,-(SP)
		lea     (.msg_badoffset,PC),a1
		lea     (.THIS,PC),a2
		moveq   #0,d0
		bsr     ShowHit
		move.l  (SP)+,a1
	;-- Zeiger ins ChipRAM -----------------;
.off_ok         exec    TypeOfMem
		btst    #MEMB_CHIP,d0
		bne     .done
		move.l  SP,a0
		lea     (.msg_nochip,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
	;-- Okay -------------------------------;
.done           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badwidth   dc.b    "width must be below 16",0
.msg_badoffset  dc.b    "hot spot is outside of the sprite",0
.msg_nochip     dc.b    "sprite data must be in CHIP ram",0
		even
*<

*****************************************************************
*       == HILFS-ROUTINEN                                       *
*****************************************************************

*********************************************************
* Name          Find_Ptr                                *
* Funktion      Sucht Pointer in einer einfachen Liste  *
*                                                       *
* Parameter     -> a0.l ^Startelement e. einf. Liste    *
*               -> a1.l ^Zu suchender Eintrag           *
*               <- d0.l 0:nicht da ~0:gefunden  +CCR    *
*********************************************************
*> [Find_Ptr]
;Find_Ptr        pushm.l a0-a1
;.loop           move.l  a0,d0                   ;Ende der Liste?
;                beq     .done
;                cmp.l   a1,a0                   ;Gefunden?
;                beq     .found
;                move.l  (a0),a0                 ;Nächste Node
;                bra     .loop
;.found          moveq   #-1,d0
;.done           popm.l  a0-a1
;                tst.l   d0
;                rts
*<

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
