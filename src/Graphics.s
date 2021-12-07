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

		INCLUDE	"exec/lists.i"
		INCLUDE	"exec/nodes.i"
		INCLUDE	"exec/libraries.i"
		INCLUDE	"exec/memory.i"
		INCLUDE	"graphics/gfx.i"
		INCLUDE	"graphics/gfxbase.i"
		INCLUDE	"graphics/modeid.i"
		INCLUDE	"graphics/scale.i"
		INCLUDE	"graphics/sprite.i"
		INCLUDE	"graphics/text.i"
		INCLUDE	"graphics/view.i"
		INCLUDE	"lvo/exec.i"
		INCLUDE	"lvo/graphics.i"
		INCLUDE	"lvo/utility.i"

		INCLUDE	PatchWork.i

		SECTION	text,CODE

*--
* Set the patches
*
		PUBLIC	SP_Graphics
SP_Graphics	movem.l	a0-a1,-(SP)
		lea	(.gfxname,PC),a1
		moveq	#36,d0
		exec	OpenLibrary
		move.l	d0,gfxbase
		beq	.done
		move.l	d0,a1
		lea	(v36_patches,PC),a0
		bsr	AddPatchTab
		cmp	#39,(LIB_VERSION,a1)
		blo	.done
		lea	(v39_patches,PC),a0
		bsr	AddPatchTab
		cmp	#40,(LIB_VERSION,a1)
		blo	.done
		lea	(v40_patches,PC),a0
		bsr	AddPatchTab
.done		movem.l	(SP)+,a0-a1
		rts

.gfxname	dc.b	"graphics.library",0
		even

*--
* Remove the patches
*
		PUBLIC	RP_Graphics
RP_Graphics	movem.l	a0-a1,-(SP)
		move.l	(gfxbase,PC),d0
		beq	.nogfx
		move.l	d0,a1
		lea	(v36_patches,PC),a0
		bsr	RemPatchTab
		cmp	#39,(LIB_VERSION,a1)
		blo	.close
		lea	(v39_patches,PC),a0
		bsr	RemPatchTab
		cmp	#40,(LIB_VERSION,a1)
		blo	.close
		lea	(v40_patches,PC),a0
		bsr	RemPatchTab
.close		exec	CloseLibrary
.nogfx		movem.l	(SP)+,a0-a1
		rts

*--
* Table of all patches
*
v36_patches	dpatch	_GFXAreaEllipse,P_AreaEllipse
		dpatch	_GFXBitMapScale,P_BitMapScale
		dpatch	_GFXChangeSprite,P_ChangeSprite
		dpatch	_GFXDrawEllipse,P_DrawEllipse
		dpatch	_GFXEraseRect,P_EraseRect
		dpatch	_GFXFreeColorMap,P_FreeColorMap
		dpatch	_GFXMakeVPort,P_MakeVPort
		dpatch	_GFXRectFill,P_RectFill
		dpatch	_GFXScalerDiv,P_ScalerDiv
		dpatch	_GFXSetFont,P_SetFont
;		dpatch	_GFXWaitBOVP,P_WaitBOVP
		dc.w	0

v39_patches	dpatch	_GFXAllocSpriteDataA,P_AllocSpriteData
		dpatch	_GFXBestModeIDA,P_BestModeID
		dpatch	_GFXChangeVPBitMap,P_ChangeVPBitMap
		dpatch	_GFXGetExtSpriteA,P_GetExtSpriteA
		dpatch	_GFXSetChipRev,P_SetChipRev
		dpatch	_GFXSetMaxPen,P_SetMaxPen
		dc.w	0

v40_patches	dpatch	_GFXWriteChunkyPixels,P_WriteChunkyPixels
		dc.w	0

gfxbase	 dc.l	0			;GfxBase


*------------------------------------------------------------------
* PATCHES
*

	PATCH P_AllocSpriteData,"AllocSpriteDataA(0x%08lx,0x%08lx)",REG_A2,REG_A1
		movem.l	d0-d7/a0-a7,-(SP)
	;-- OldSpriteData? ---------------------;
		move.l	a1,a0			;Find tag
		move.l	#SPRITEA_OldDataFormat,d0
		utils	FindTagItem
		tst.l	d0			;present?
		bne	.done			; yes: we cannot test anything
	;-- Get OutputHeight -------------------;
		move.l	a1,a0			;Find tag
		move.l	#SPRITEA_OutputHeight,d0
		utils	FindTagItem
		tst.l	d0			;not present?
		beq	.done			; nope -> ok
	;-- Compare sizes ----------------------;
		move.l	d0,a0
		move.l	(4,a0),d1		;Read height
		moveq	#0,d0
		move	(bm_Rows,a2),d0
		cmp.l	d0,d1
		bls	.done
	;-- Does not fit -----------------------;
		move.l	SP,a0
		movem.l	d0-d1,-(SP)
		lea	(.msg_nottall,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	SP,d1
		bsr	ShowHit
		add.l	#2*4,SP
.done		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_nottall	dc.b	"bitmap (h=%lu) isn't tall enough for sprite (h=%lu)",0
		even

*---------------

	PATCH P_AreaEllipse,"AreaEllipse(0x%08lx,%ld,%ld,%ld,%ld)",REG_A1,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_D2|REGF_WORD,REG_D3|REGF_WORD
		tst	d2			;A > 0
		bls	.bad
		tst	d3			;B > 0
		bhi	.THIS
.bad		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_badrad,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_badrad	dc.b	"ellipse radius must be > 0",0
		even

*---------------

	PATCH P_BestModeID,"BestModeIDA(0x%08lx)",REG_A0
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	a0,a5
		move.l	#BIDTAG_NominalWidth,d0
		lea	(.msg_nw,PC),a4
		bsr	.check
		move.l	#BIDTAG_NominalHeight,d0
		lea	(.msg_nh,PC),a4
		bsr	.check
		move.l	#BIDTAG_DesiredWidth,d0
		lea	(.msg_dw,PC),a4
		bsr	.check
		move.l	#BIDTAG_DesiredHeight,d0
		lea	(.msg_dh,PC),a4
		bsr	.check
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.check		move.l	a5,a0
		utils	FindTagItem
		tst.l	d0
		beq	.chk_done
		move.l	d0,a3
		tst	(4,a3)			;upper word
		beq	.chk_rok
		lea	(4,SP),a0
		move.l	a4,-(SP)
		lea	(.msg_badrange,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		move.l	SP,d1
		movem.l	a3-a5,-(SP)
		bsr	ShowHit
		movem.l	(SP)+,a3-a5
		add.l	#1*4,SP
.chk_rok	tst	(6,a3)			;lower word
		bne	.chk_done
		lea	(4,SP),a0
		move.l	a4,-(SP)
		lea	(.msg_isnull,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	SP,d1
		move.l	a5,-(SP)
		bsr	ShowHit
		move.l	(SP)+,a5
		add.l	#1*4,SP
.chk_done	rts

.msg_badrange	dc.b	"Tag BIDTAG_%s: out of UWORD range",0
.msg_isnull	dc.b	"Tag BIDTAG_%s: 0 is not allowed",0
.msg_nw		dc.b	"NominalWidth",0
.msg_nh		dc.b	"NominalHeight",0
.msg_dw		dc.b	"DesiredWidth",0
.msg_dh		dc.b	"DesiredHeight",0
		even

*---------------

	PATCH P_BitMapScale,"BitMapScale(0x%08lx)",REG_A0
		movem.l	d0-d7/a0-a7,-(SP)
	;-- Range Checkings --------------------;
		move	(bsa_XSrcFactor,a0),d0	;Check range
		lea	(.msg_xsf,PC),a1
		bsr	.checkrange
		move	(bsa_XDestFactor,a0),d0 ;Check range
		lea	(.msg_xdf,PC),a1
		bsr	.checkrange
		move	(bsa_YSrcFactor,a0),d0	;Check range
		lea	(.msg_ysf,PC),a1
		bsr	.checkrange
		move	(bsa_YDestFactor,a0),d0 ;Check range
		lea	(.msg_ydf,PC),a1
		bsr	.checkrange
	;-- Flags = 0 --------------------------;
		tst.l	(bsa_Flags,a0)		;Flags = 0?
		beq	.goodflags
		move.l	a0,-(SP)
		lea	(1*4,SP),a0
		lea	(.msg_badflags,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		move.l	(SP)+,a0
.goodflags
	;-- Bug Test 1 -------------------------;
		move	(bsa_XSrcFactor,a0),d0
		cmp	(bsa_XDestFactor,a0),d0
		bne	.check1ok
		move	(bsa_SrcWidth,a0),d0
		cmp	#1024,d0
		bls	.check1ok
		move.l	a0,-(SP)
		lea	(1*4,SP),a0
		lea	(.msg_bug1,PC),a1
		lea	(.THIS,PC),a2
		moveq	#2,d0
		bsr	ShowHit
		move.l	(SP)+,a0
.check1ok
	;-- Bug Test 2 -------------------------;
		move	(bsa_DestX,a0),d0
		and	#$f,d0
		move	(bsa_SrcWidth,a0),d1
		mulu	(bsa_XDestFactor,a0),d1
		divu	(bsa_XSrcFactor,a0),d1
		add	d1,d0
		cmp	#1024,d0
		blo	.check2ok
		move.l	a0,-(SP)
		lea	(1*4,SP),a0
		lea	(.msg_bug2,PC),a1
		lea	(.THIS,PC),a2
		moveq	#2,d0
		bsr	ShowHit
		move.l	(SP)+,a0
.check2ok
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.checkrange	tst	d0			;0..
		beq	.cr_bad
		cmp	#16383,d0		;..16383
		bhi	.cr_bad
		rts
.cr_bad		move.l	a0,-(SP)
		and.l	#$ffff,d0
		move.l	d0,-(SP)
		move.l	a1,-(SP)
		lea	(3*4,SP),a0
		lea	(.msg_badrng,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	SP,d1
		bsr	ShowHit
		add.l	#2*4,SP
		move.l	(SP)+,a0
		rts

.msg_xsf	dc.b	"XSrcFactor",0
.msg_xdf	dc.b	"XDestFactor",0
.msg_ysf	dc.b	"YSrcFactor",0
.msg_ydf	dc.b	"YDestFactor",0
.msg_badrng	dc.b	"bsa_%s (=%ld) must be within 1..16383",0
.msg_bug1	dc.b	"Bug: cannot copy with width > 1024 (see autodocs)",0
.msg_bug2	dc.b	"Bug: cannot expand in Y direction (see autodocs)",0
.msg_badflags	dc.b	"bsa_Flags is not 0",0
		even

*---------------

	; TODO:
	; PATCH P_BltBitMap,"BltBitMap(0x%08lx,%ld,%ld,0x%08lx,%ld,%ld,%ld,%ld,0x%02lx,0x%02lx,0x%08lx)",REG_A0,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_A1,REG_D2|REGF_WORD,REG_D3|REGF_WORD,REG_D4|REGF_WORD,REG_D5|REGF_WORD,REG_D6|REGF_UBYTE,REG_D7|REGF_UBYTE,REG_A2

*---------------

	PATCH P_ChangeSprite,"ChangeSprite(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2
		movem.l	d0-d7/a0-a7,-(SP)
		move	(ss_height,a1),d3	;Sprite height
		beq	.initialized
		lsl	#2,d3			;*4
		tst.l	(4,a2,d3.w)		;Null?
		beq	.initialized
		move.l	SP,a0
		move.l	a2,-(SP)
		lea	(.msg_sprinit,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		move.l	(SP)+,a2
.initialized	move.l	a2,a1
		exec	TypeOfMem		;Right type?
		btst	#MEMB_CHIP,d0
		bne	.ramok
		move.l	SP,a0
		lea	(.msg_badmem,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
.ramok		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_sprinit	dc.b	"spriteimage not initialized",0
.msg_badmem	dc.b	"spriteimage must be in CHIP RAM",0
		even

*---------------

	PATCH P_ChangeVPBitMap,"ChangeVPBitMap(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_A2
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	(vp_RasInfo,a0),a3	;fetch ^ViewPort
		move.l	(ri_BitMap,a3),a3	;^current BitMap
		move	(bm_BytesPerRow,a3),d0	;BytesPerRow
		cmp	(bm_BytesPerRow,a1),d0
		bne	.notidentical
		move.b	(bm_Depth,a3),d0	;Depth
		cmp.b	(bm_Depth,a1),d0
		bne	.notidentical
.exit		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
.notidentical	move.l	SP,a0
		move.l	a1,-(SP)
		move.l	a3,-(SP)
		lea	(.msg_notsame,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		move.l	SP,d1
		bsr	ShowHit
		add.l	#2*4,SP
		bra	.exit

.msg_notsame	dc.b	"Current bitmap @0x%08lx and new bitmap @0x%08lx do not match",0
		even

*---------------

	PATCH P_DrawEllipse,"DrawEllipse(0x%08lx,%ld,%ld,%ld,%ld)",REG_A1,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_D2|REGF_WORD,REG_D3|REGF_WORD
		tst	d2			;A > 0
		bls	.bad
		tst	d3			;B > 0
		bhi	.THIS
.bad		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_badrad,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_badrad	dc.b	"ellipse radius must be > 0",0
		even

*---------------

	PATCH P_EraseRect,"EraseRect(0x%08lx,%ld,%ld,%ld,%ld)",REG_A1,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_D2|REGF_WORD,REG_D3|REGF_WORD
		cmp	d2,d0
		bgt	.bad			;xmin > xmax ?
		cmp	d3,d1
		ble	.THIS			;ymin > ymax ?
.bad		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_badrel,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_badrel	dc.b	"max must be >= min",0
		even

*---------------

	PATCH P_FreeColorMap,"FreeColorMap(0x%08lx)",REG_A0
		move.l	a0,d0			;;Register is trashed
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v39,PC),a1
		lea	(.THIS,PC),a2
		moveq	#39,d0			;MinOS 39
		swap	d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v39	dc.b	"V39+ will be required",0
		even

*---------------

	PATCH P_GetExtSpriteA,"GetExtSpriteA(0x%08lx,0x%08lx)",REG_A2,REG_A1
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_v40,PC),a1
		lea	(.THIS,PC),a2
		moveq	#40,d0			;MinOS 40
		swap	d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_v40	dc.b	"V40+ will be required for proper operation",0
		even

*---------------

	PATCH P_MakeVPort,"MakeVPort(0x%08lx,0x%08lx)",REG_A0,REG_A1
		movem.l	d0-d7/a0-a7,-(SP)
		tst.l	(vp_RasInfo,a1)	 	;RasInfo set?
		bne	.rasinfo		;; TypeOfMem()
		move.l	SP,a0
		lea	(.msg_norasinfo,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		bra	.exit
.rasinfo	move	(vp_Modes,a1),d0	;DualPF?
		and	#V_DUALPF,d0
		beq	.exit
		move.l	(vp_RasInfo,a1),a0	;second RasInfo?
		tst.l	(ri_Next,a0)
		bne	.exit
		move.l	SP,a0
		lea	(.msg_no2ndras,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
.exit		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_norasinfo	dc.b	"ViewPort->RasInfo has not been set",0
.msg_no2ndras	dc.b	"DUALPF ViewPort->RasInfo.Next has not been set",0
		even

*---------------

	PATCH P_RectFill,"RectFill(0x%08lx,%ld,%ld,%ld,%ld)",REG_A1,REG_D0|REGF_WORD,REG_D1|REGF_WORD,REG_D2|REGF_WORD,REG_D3|REGF_WORD
		cmp	d2,d0
		bgt	.bad			;xmin > xmax ?
		cmp	d3,d1
		ble	.THIS			;ymin > ymax ?
.bad		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_badrel,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_badrel	dc.b	"max must be >= min",0
		even

*---------------

	PATCH P_ScalerDiv,"ScalerDiv(%lu,%lu,%lu)",REG_D0|REGF_UWORD,REG_D1|REGF_UWORD,REG_D2|REGF_UWORD
		cmp	#16383,d0		;D0>16383?
		bhi	.bad
		cmp	#1,d1			;D1<1?
		blo	.bad
		cmp	#16383,d1
		bhi	.bad
		cmp	#1,d2			;D2<1?
		blo	.bad
		cmp	#16383,d2
		bls	.THIS
.bad		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_badrange,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_badrange	dc.b	"parameters are out of range",0
		even

*---------------

	PATCH P_SetChipRev,"SetChipRev(%lu)",REG_D0
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_donttouch,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_donttouch	dc.b	"do not use this function!",0
		even

*---------------

	PATCH P_SetFont,"SetFont(0x%08lx,0x%08lx)",REG_A1,REG_A0
	;-- NULL Font --------------------------;
		move.l	a0,d0			;; Register is trashed
		bne	.font_ok
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_nullfont,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
	;-- Font OK ----------------------------;
.font_ok	move.l	(tf_CharSpace,a0),d0	;; Register is trashed
		or.l	(tf_CharKern,a0),d0
		beq	.font_test		;both were NULL
		tst.l	(tf_CharSpace,a0)	;Space == NULL?
		beq	.font_bad
		tst.l	(tf_CharKern,a0)	;Kern == NULL?
		bne	.THIS			; Font OK
.font_bad	movem.l	d0-d7/a0-a7,-(SP)
		moveq	#0,d0			;Font size
		move	(tf_YSize,a0),d0
		move.l	d0,-(sp)
		move.l	(LN_NAME,a0),-(sp)
		lea	(2*4,sp),a0
		lea	(.msg_badfont,PC),a1
		lea	(.THIS,PC),a2
		moveq	#0,d0
		move.l	sp,d1
		bsr	ShowHit
		add.l	#2*4,sp
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS
.font_test	movem.l	a1/d1/d2,-(sp)		;Check 3rd condition
		moveq	#0,d2
		move.b	(tf_HiChar,a0),d2
		sub.b	(tf_LoChar,a0),d2
		addq	#1,d2
		move	(tf_XSize,a0),d0	;X Size
		move.l	(tf_CharLoc,a0),a1	;get CharLoc
.testloop	move.l	(a1)+,d1
		cmp	d0,d1
		bgt	.font_test_bad
		dbra	d2,.testloop
		movem.l	(sp)+,a1/d1/d2
		bra	.THIS
.font_test_bad	movem.l	(sp)+,a1/d1/d2
		bra	.font_bad

.msg_nullfont	dc.b	"NULL fonts are not allowed",0
.msg_badfont	dc.b	"BTW: %s/%lu variant is obsoleted in V36+",0
		even

*---------------

	PATCH P_SetMaxPen,"SetMaxPen(0x%08lx,%lu)",REG_A0,REG_D0
		tst.l	d0
		bne	.THIS
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_nonsense,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_nonsense	dc.b	"maxpen==0 does not make much sense",0
		even

*---------------

	PATCH P_WaitBOVP,"WaitBOVP(0x%08lx)",REG_A0
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_dontuse,PC),a1
		lea	(.THIS,PC),a2
		moveq	#1,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_dontuse	dc.b	"busy wait, do not use if ever possible",0
		even

*---------------

	PATCH P_WriteChunkyPixels,"WriteChunkyPixels(0x%08lx,%ld,%ld,%ld,%ld,0x%08lx,%ld)",REG_A0,REG_D0,REG_D1,REG_D2,REG_D3,REG_A2,REG_D4
	;-- Hardware present?
		tst.l	(gb_ChunkyToPlanarPtr,a6)
		bne	.hwpresent
		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_nohw,PC),a1
		lea	(.THIS,PC),a2
		moveq	#0,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
	;-- stop must be >= start
.hwpresent	cmp.l	d2,d0
		bgt	.bad			;xstop > xstart ?
		cmp.l	d3,d1
		ble	.THIS			;ystop > ystart ?
.bad		movem.l	d0-d7/a0-a7,-(SP)
		move.l	SP,a0
		lea	(.msg_badrange,PC),a1
		lea	(.THIS,PC),a2
		moveq	#3,d0
		bsr	ShowHit
		movem.l	(SP)+,d0-d7/a0-a7
		bra	.THIS

.msg_nohw	dc.b	"no chunky-to-planar hardware, this will be slow",0
.msg_badrange	dc.b	"stop must be >= start",0
		even
