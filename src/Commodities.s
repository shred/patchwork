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

		INCLUDE	"exec/lists.i"
		INCLUDE	"exec/nodes.i"
		INCLUDE	"exec/libraries.i"
		INCLUDE	"exec/memory.i"
		INCLUDE	"libraries/commodities.i"

		INCLUDE	"lvo/exec.i"
		INCLUDE	"lvo/utility.i"
		INCLUDE	"lvo/commodities.i"

		INCLUDE	PatchWork.i

		SECTION	text,CODE

*--
* Set the patches
*
		PUBLIC	SP_Commodities
SP_Commodities	movem.l	a0-a1,-(SP)
		lea	(.cxname,PC),a1
		moveq	#36,d0
		exec	OpenLibrary
		move.l	d0,cxbase
		beq	.done
		move.l	d0,a1
		lea	(v36_patches,PC),a0
		bsr	AddPatchTab
.done		movem.l	(SP)+,a0-a1
		rts

.cxname		dc.b	"commodities.library",0
		even

*--
* Remove the patches
*
		PUBLIC	RP_Commodities
RP_Commodities	movem.l	a0-a1,-(SP)
		move.l	(cxbase,PC),d0		;CxBase present?
		beq	.nogfx
		move.l	d0,a1			;Remove V36 patches
		lea	(v36_patches,PC),a0
		bsr	RemPatchTab
.close		exec	CloseLibrary		;Close library
.nogfx		movem.l	(SP)+,a0-a1
		rts

*--
* Table of all patches
*
v36_patches	dpatch	_CXAttachCxObj,P_AttachCxObj
		dpatch	_CXCxBroker,P_CxBroker
		dpatch	_CXCxMsgData,P_CxMsgData
		dpatch	_CXCxMsgID,P_CxMsgID
		dpatch	_CXCxMsgType,P_CxMsgType
		dpatch	_CXDisposeCxMsg,P_DisposeCxMsg
		dpatch	_CXDivertCxMsg,P_DivertCxMsg
		dpatch	_CXEnqueueCxObj,P_EnqueueCxObj
		dpatch	_CXInsertCxObj,P_InsertCxObj
		dpatch	_CXRouteCxMsg,P_RouteCxMsg
		dpatch	_CXSetCxObjPri,P_SetCxObjPri
		dc.w	0

cxbase		dc.l	0			;CxBase


*------------------------------------------------------------------
* PATCHES
*

	PATCH P_AttachCxObj,"AttachCxObj(0x%08lx,0x%08lx)",REG_A0,REG_A1
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v38req,PC),a1
		lea	(.THIS,PC),a2
		moveq	#38,d0
		swap	d0			;MinOS 38
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v38req	dc.b	"V38+ required for headObj==NULL",0
		even

*---------------

	PATCH P_CxBroker,"CxBroker(0x%08lx,0x%08lx)",REG_A0,REG_D0
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	a0,a5
	;-- nb_Name OK? ------------------------;
		move.l	(nb_Name,a5),a0
		lea	(.msg_name,PC),a1
		moveq	#CBD_NAMELEN,d0
		bsr	.check
	;-- nb_Title OK? -----------------------;
		move.l	(nb_Title,a5),a0
		lea	(.msg_title,PC),a1
		moveq	#CBD_TITLELEN,d0
		bsr	.check
	;-- nb_Descr OK? -----------------------;
		move.l	(nb_Descr,a5),a0
		lea	(.msg_descr,PC),a1
		moveq	#CBD_DESCRLEN,d0
		bsr	.check
	;-- nb_Unique OK? ----------------------;
		moveq	#0,d0
		move	(nb_Unique,a5),d0
		cmp	#NBU_NOTIFY|NBU_UNIQUE,d0
		bls	.good_unique
		move.l	SP,a0
		move.l	d0,-(SP)
		lea	(.msg_badunique,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		move.l	SP,d1
		bsr	ShowHit
		add.l	#4,SP
.good_unique
.done		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

; check the passed in String
;	-> a0.l ^String
;	-> a1.l ^Text type for hit
;	-> d0.w maximum length
.check		move.l	a0,d1
		beq	.no_str
.checksize	subq	#1,d0
		bcs	.bad_len
		tst.b	(a0)+
		bne	.checksize
		rts
.bad_len	lea	(4,SP),a0
		move.l	a1,-(SP)
		lea	(.msg_strlen,PC),a1
.short_showhit	lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	SP,d1
		bsr	ShowHit
		add.l	#4,SP
		rts
.no_str		lea	(4,SP),a0
		move.l	a1,-(SP)
		lea	(.msg_nostr,PC),a1
		bra	.short_showhit

.msg_name	dc.b	"nb_Name",0
.msg_title	dc.b	"nb_Title",0
.msg_descr	dc.b	"nb_Descr",0
.msg_strlen	dc.b	"%s string is too long",0
.msg_nostr	dc.b	"%s is NULL",0
.msg_badunique	dc.b	"nb_Unique %ld is not allowed",0
		even

*---------------

	PATCH P_CxMsgData,"CxMsgData(0x%08lx)",REG_A0
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v38req,PC),a1
		lea	(.THIS,PC),a2
		moveq	#38,d0
		swap	d0			;MinOS 38
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v38req	dc.b	"V38+ required for cxm==NULL",0
		even

*---------------

	PATCH P_CxMsgID,"CxMsgID(0x%08lx)",REG_A0
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_notnull,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_notnull	dc.b	"cxm must not be NULL",0
		even

*---------------

	PATCH P_CxMsgType,"CxMsgType(0x%08lx)",REG_A0
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_notnull,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_notnull	dc.b	"cxm must not be NULL",0
		even

*---------------

	PATCH P_DisposeCxMsg,"DisposeCxMsg(0x%08lx)",REG_A0
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_notnull,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_notnull	dc.b	"cxm must not be NULL",0
		even

*---------------

	PATCH P_DivertCxMsg,"DivertCxMsg(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_notnull,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_notnull	dc.b	"cxm must not be NULL",0
		even

*---------------

	PATCH P_EnqueueCxObj,"EnqueueCxObj(0x%08lx,0x%08lx)",REG_A0,REG_A1
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v38req,PC),a1
		lea	(.THIS,PC),a2
		moveq	#38,d0
		swap	d0			;MinOS 38
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v38req	dc.b	"V38+ required for headObj==NULL",0
		even

*---------------

	PATCH P_InsertCxObj,"InsertCxObj(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v38req,PC),a1
		lea	(.THIS,PC),a2
		moveq	#38,d0
		swap	d0			;MinOS 38
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v38req	dc.b	"V38+ required for headObj==NULL",0
		even

*---------------

	PATCH P_RouteCxMsg,"RouteCxMsg(0x%08lx,0x%08lx)",REG_A0,REG_A1
		move.l	a0,d0			;; d0 is being changed!!!
		bne	.chk_a1
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_notnull,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
.chk_a1		move.l	a1,d0			;; d0 is being changed!!!
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_notnull2,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_notnull	dc.b	"cxm must not be NULL",0
.msg_notnull2	dc.b	"co must not be NULL",0
		even

*---------------

	PATCH P_SetCxObjPri,"SetCxObjPri(0x%08lx,%ld)",REG_A0,REG_D0
		movem.l	d0-d7/a0-a7,-(SP)
		and.l	#$ffffff00,d0		;In range?
		beq	.range_ok
		move.l	SP,a0
		lea	(.msg_badpri,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		bsr	ShowHit
.range_ok	move.l	SP,a0
		lea	(.msg_v38req,PC),a1
		lea	(.THIS,PC),a2
		moveq	#38,d0
		swap	d0			;MinOS 38
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		move.l	(args+arg_Deadly,PC),d0 ;Deadly hit?
		beq	.THIS			; nope
		bsr	.THIS
		move.l	#$FACEDEAD,d0
		rts

.msg_badpri	dc.b	"Priority is out of range (-128..127)",0
.msg_v38req	dc.b	"V38+ required for a result",0
		even
