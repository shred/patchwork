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
		INCLUDE "phxmacros.i"

		INCLUDE PatchWork.i
		INCLUDE Refs.i

		SECTION text,CODE

*--
* Set the patches
*
		XDEF    SP_Intuition
SP_Intuition    movem.l a0-a1,-(SP)
		lea     (.intuiname,PC),a1
		moveq   #36,d0
		exec    OpenLibrary
		move.l  d0,intuibase
		beq     .done
		move.l  d0,a1
		lea     (v36_patches,PC),a0
		bsr     AddPatchTab
		cmp     #39,(LIB_VERSION,a1)
		blo     .done
		lea     (v39_patches,PC),a0
		bsr     AddPatchTab
.done           movem.l (SP)+,a0-a1
		rts
		
.intuiname      dc.b    "intuition.library",0
		even
		
*--
* Remove the patches
*
		XDEF    RP_Intuition
RP_Intuition    movem.l a0-a1,-(SP)
		move.l  (intuibase,PC),d0
		beq     .nointui
		move.l  d0,a1
		lea     (v36_patches,PC),a0
		bsr     RemPatchTab
		cmp     #39,(LIB_VERSION,a1)
		blo     .close
		lea     (v39_patches,PC),a0
		bsr     RemPatchTab
.close          exec    CloseLibrary
.nointui        movem.l (SP)+,a0-a1
		rts

*--
* Table of all patches
*
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
		dc.w    0

v39_patches     dpatch  _INTScreenDepth,P_ScreenDepth
		dc.w    0

intuibase       dc.l    0


*------------------------------------------------------------------
* PATCHES
*

; TODO:
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

*---------------

        PATCH P_CloseWindow,"CloseWindow(0x%08lx)",REG_A0
		movem.l d0-d7/a0-a7,-(SP)
		move.l  a0,a4                   ;remember
	;-- Still messages in the queue? -------;
		moveq   #0,d7                   ;own message counter
		moveq   #0,d6                   ;Foreign message counter
		move.l  (wd_UserPort,a4),d0     ;^UserPort
		beq     .no_port                ;already released?
		move.l  d0,a0                   ;^MsgPort
		move.l  (MP_MSGLIST,a0),a0      ;^first node
.loop           tst.l   (a0)                    ;finished?
		beq     .list_done
		addq.l  #1,d6                   ;foreign node
		cmp.l   (im_IDCMPWindow,a0),a4  ;is it the window?
		bne     .no_msg
		addq.l  #1,d7                   ;Yuck!
		subq.l  #1,d6                   ;it's not a foreign node
.no_msg         move.l  (a0),a0
		bra     .loop
.list_done      tst.l   d7                      ;now?
		beq     .no_port                ; 0 is allright
		tst.l   d6                      ;something foreign?
		beq     .no_port                ; no: port was cleanly removed
		move.l  SP,a0
		move.l  d7,-(SP)
		lea     (.msg_outmsg,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
.no_port
	;-- Is there a menu strip? -------------;
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
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_outmsg     dc.b    "still %ld Messages in the shared Window queue",0
.msg_menustrip  dc.b    "MenuStrip @0x%08lX not cleared",0
		even
		
*---------------
		
	PATCH P_EasyRequestArgs,"EasyRequestArgs(0x%08lx,0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2,REG_A3
		move.l  a1,d0                   ;; register is trashed
		beq     .THIS                   ; no EasyStruct: Enforcer will complain
		movem.l d0-d7/a0-a7,-(SP)
	;-- StructSize OK ----------------------;
		move.l  (es_StructSize,a1),d0   ;Struct-Size
		cmp.l   #5*4,d0                 ;less than minimal size? (EasyStruct_SIZEOF up to OS3.1)
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
	;-- Are there Gadgets? -----------------;
.size_ok        move.l  (es_GadgetFormat,a1),d0 ;Is it a pointer?
		beq     .no_string
		move.l  d0,a0                   ;Empty string?
		tst.b   (a0)
		bne     .all_ok
.no_string      move.l  SP,a0
		lea     (.msg_badgadget,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
.all_ok         movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badsize    dc.b    "es_StructSize is wrong (%ld byte)",0
.msg_badgadget  dc.b    "no gadget specified",0
		even
		
*---------------
		
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
		
*---------------
		
	PATCH P_GetDefaultPubScreen,"GetDefaultPubScreen(0x%08lx)",REG_A0
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit? ;;register is trashed
		beq     .THIS                   ; nope
		bsr     .THIS
		tst.l   d0                      ;no screen there?
		beq     .leave
		move.l  #$FACEDEAD,d0           ;Text
.leave          rts

*---------------

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
		
*---------------
		
	PATCH P_MakeScreen,"MakeScreen(0x%08lx)",REG_A0
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit?
		beq     .THIS                   ; nope
		bsr     .THIS
		move.l  #$FACEDEAD,d0           ; return worst case
		rts

.msg_v39        dc.b    "return code requires V39+",0
		even
		
*---------------
		
	PATCH P_ModifyIDCMP,"ModifyIDCMP(0x%08lx,0x%08lx)",REG_A0,REG_D0
		movem.l d0-d7/a0-a7,-(SP)
		move.l  a0,a4                   ;Remember pointer
	;-- Messages in the queue? -------------;
		tst.l   d0                      ;to be cleared?
		bne     .no_port                ;  nope: don't care
		moveq   #0,d7                   ;count own messages
		moveq   #0,d6                   ;count foreign messages
		move.l  (wd_UserPort,a4),d0     ;^UserPort
		beq     .no_port                ;already released
		move.l  d0,a0                   ;^MsgPort
		move.l  (MP_MSGLIST,a0),a0      ;^first Node
.loop           tst.l   (a0)                    ;finished?
		beq     .list_done
		addq.l  #1,d6                   ;foreign Node
		cmp.l   (im_IDCMPWindow,a0),a4  ;is it a window?
		bne     .no_msg
		addq.l  #1,d7                   ;Yuck!
		subq.l  #1,d6                   ;it's not a foreign node
.no_msg         move.l  (a0),a0
		bra     .loop
.list_done      tst.l   d7                      ;now?
		beq     .no_port                ; 0 is allright!
		tst.l   d6                      ;was there something foreign?
		beq     .no_port                ; no: port was cleanly removed
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
		
*---------------
		
	PATCH P_RemakeDisplay,"RemakeDisplay()"
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit?
		beq     .THIS                   ; nope
		bsr     .THIS
		move.l  #$FACEDEAD,d0           ; return worst case
		rts

.msg_v39        dc.b    "return code requires V39+",0
		even
		
*---------------
		
	PATCH P_Request,"Request(0x%08lx,0x%08lx)",REG_A0,REG_A1
		move.l  a1,d0                   ;; register is trashed
		beq     .THIS                   ; Enforcer will take care of it...
		movem.l d0-d7/a0-a7,-(SP)
		move.l  (wd_Flags,a1),d0        ;get flags
		and.l   #WFLG_SIZEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET,d0
		beq     .done                   ;  none of them
		moveq   #0,d0                   ;Counter
		move.l  (wd_FirstRequest,a1),a2 ;^Requester list
.loop           move.l  a2,d1                   ;End?
		beq     .cntdone
		addq.l  #1,d0
		move.l  (a2),a2                 ;next requester
		bra     .loop
.cntdone        cmp.l   #9,d0                   ;more than 8 requester?
		blo     .done                   ;nope -> Okay
		move.l  SP,a0
		lea     (.msg_maxreq,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.done           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS                   ; nope

.msg_maxreq     dc.b    "maximum of 8 requesters exceeded"
		even
		
*---------------
		
	PATCH P_RethinkDisplay,"RethinkDisplay()"
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit?
		beq     .THIS                   ; nope
		bsr     .THIS
		move.l  #$FACEDEAD,d0           ; return worst case
		rts

.msg_v39        dc.b    "return code requires V39+",0
		even
		
*---------------
		
	PATCH P_ScreenDepth,"ScreenDepth(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_D0,REG_A1
		move.l  a1,d1                   ;; register is trashed
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
		
*---------------
		
	PATCH P_SetEditHook,"SetEditHook(0x%08lx)",REG_A0
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_risky,PC),a1
		lea     (.THIS,PC),a2
		moveq   #0,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_risky      dc.b    "risky function",0
		even
		
*---------------
		
	PATCH P_SetMenuStrip,"SetMenuStrip(0x%08lx,0x%08lx)",REG_A0,REG_A1
		movem.l d0-d7/a0-a7,-(SP)
		move.l  a1,d0                   ;is there a menu?
		bne     .done                   ; TODO:
;;                beq     .no_menu
;;                move.l  a1,a5
;;.loop           move.l  a5,d0                   ;End?
;;                beq     .done
;;                tst.l   (mu_FirstItem,a5)       ;A menu item?
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
		
*---------------
		
	PATCH P_SetPointer,"SetPointer(0x%08lx,0x%08lx,%ld,%ld,%ld,%ld)",REG_A0,REG_A1,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_D2|REGF_WORD,REG_D3|REGF_WORD
		movem.l d0-d7/a0-a7,-(SP)
	;-- Sprite width -----------------------;
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
	;-- Pointer into Chip RAM --------------;
.off_ok         exec    TypeOfMem
		btst    #MEMB_CHIP,d0
		bne     .done
		move.l  SP,a0
		lea     (.msg_nochip,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.done           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badwidth   dc.b    "width must be below 16",0
.msg_badoffset  dc.b    "hot spot is outside of the sprite",0
.msg_nochip     dc.b    "sprite data must be in CHIP ram",0
		even

*---------------
		
*--
* Finds a pointer in a linked list
*
*       -> a0.l ^ first element of a simple linked list
*       -> a1.l ^ entry to be found
*       <- d0.l 0: not found, ~0: found +CCR
*
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

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
