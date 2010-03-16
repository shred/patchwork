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

PW_UTILITY      SET     -1

		INCLUDE "exec/lists.i"
		INCLUDE "exec/nodes.i"
		INCLUDE "exec/libraries.i"
		INCLUDE "exec/memory.i"
		INCLUDE "utility/utility.i"
		INCLUDE "utility/tagitem.i"
		INCLUDE "utility/name.i"
		INCLUDE "lvo/exec.i"
		INCLUDE "lvo/utility.i"

		INCLUDE PatchWork.i
		INCLUDE Refs.i

		SECTION text,CODE

*--
* Set the patches
*
                XDEF    SP_Utility
SP_Utility      movem.l a0-a1,-(SP)
		move.l  (utilsbase,PC),a1
		lea     (v36_patches,PC),a0
		bsr     AddPatchTab
		cmp     #39,(LIB_VERSION,a1)
		blo     .done
		lea     (v39_patches,PC),a0
		bsr     AddPatchTab
.done           movem.l (SP)+,a0-a1
		rts

*--
* Remove the patches
*
		XDEF    RP_Utility
RP_Utility      movem.l a0-a1,-(SP)
		move.l  (utilsbase,PC),a1
		lea     (v36_patches,PC),a0
		bsr     RemPatchTab
		cmp     #39,(LIB_VERSION,a1)
		blo     .close
		lea     (v39_patches,PC),a0
		bsr     RemPatchTab
.close          movem.l (SP)+,a0-a1
		rts

*--
* Table of all patches
*
v36_patches     dpatch  _UTILSMapTags,P_MapTags
		dpatch  _UTILSSDivMod32,P_SDivMod32
		dpatch  _UTILSUDivMod32,P_UDivMod32
		dc.w    0

v39_patches     dpatch  _UTILSAllocNamedObjectA,P_AllocNamedObjectA
		dc.w    0


*------------------------------------------------------------------
* PATCHES
*
		
        ;TODO:
        ; PATCH RefreshTagItemClones

*---------------

        PATCH P_AllocNamedObjectA,"AllocNamedObjectA(\"%s\",0x%08lx)",REG_A0|REGF_STR,REG_A1
		movem.l d0-d7/a0-a7,-(SP)
		move.l  a1,a5
	;-- Name passed in? --------------------;
		move.l  a0,d0
		bne     .name_ok
		move.l  SP,a0
		lea     (.msg_noname,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  (utilsbase,PC),a6
		bsr     ShowHit
.name_ok
	;-- Correct ANO Flags? -----------------;
		move.l  a5,a0                   ;Find tag
		move.l  #ANO_Flags,d0
		utils   FindTagItem
		tst.l   d0                      ;present?
		beq     .done                   ; no: it's allright
		move.l  d0,a1
		move.l  (4,a1),d0
		and.l   #~(NSF_NODUPS|NSF_CASE),d0
		beq     .done
		move.l  SP,a0
		move.l  (4,a1),-(SP)
		lea     (.msg_badflags,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		move.l  SP,d1
		move.l  (utilsbase,PC),a6
		bsr     ShowHit
		add.l   #4,SP
.done           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_noname     dc.b    "no object name specified",0
.msg_badflags   dc.b    "bad ANO_Flags=0x%08lx",0
		even

*---------------
		
	PATCH P_MapTags,"MapTags(0x%08lx,0x%08lx,0x%08lx)",REG_A0,REG_A1,REG_D0
		cmp.l   #MAP_KEEP_NOT_FOUND,d0  ;This is the only secure one!
		beq     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_v39req,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0
		swap    d0                      ;MinOS 39
		move.l  (utilsbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_v39req     dc.b    "V39+ required for this mapType",0
		even
		
*---------------
		
	PATCH P_SDivMod32,"SDivMod32(%ld,%ld)",REG_D0,REG_D1
		tst.l   d1                      ;!= 0!!!
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_divzero,PC),a1
		lea     (.THIS,PC),a2
		moveq   #0,d0
		move.l  (utilsbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_divzero    dc.b    "division by zero",0
		even
		
*---------------
		
	PATCH P_UDivMod32,"UDivMod32(%lu,%lu)",REG_D0,REG_D1
		tst.l   d1                      ;!= 0!!!
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_divzero,PC),a1
		lea     (.THIS,PC),a2
		moveq   #0,d0
		move.l  (utilsbase,PC),a6
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_divzero    dc.b    "division by zero",0
		even

*---------------

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
