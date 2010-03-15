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

PW_EXEC         SET     -1

		INCDIR  "INCLUDE:"
		INCLUDE "exec/lists.i"
		INCLUDE "exec/nodes.i"
		INCLUDE "exec/semaphores.i"
		INCLUDE "exec/libraries.i"
		INCLUDE "exec/io.i"
		INCLUDE "exec/ports.i"
		INCLUDE "exec/tasks.i"
		INCLUDE "exec/execbase.i"
		INCLUDE "dos/dos.i"
		INCLUDE "lvo/exec.i"

		INCDIR  "CURRINC:"
		INCLUDE patchwork.i
		INCLUDE refs.i

		SECTION text,CODE

*********************************************************
* Name          SP_Exec                                 *
* Funktion      Exec-Patches setzen                     *
*                                                       *
* Parameter     keine                                   *
*                                                       *
*********************************************************
*> [SP_Exec] GLOBAL
		XDEF    SP_Exec
SP_Exec         movem.l a0-a1,-(SP)
		move.l  4.w,a1
		lea     (exec_patches,PC),a0
		bsr     AddPatchTab
		move.l  (args+arg_ChkDisable,PC),d0     ;DisableTest?
		beq     .notest
		move.l  4.w,a1
		lea     (exec_patches_cd,PC),a0
		bsr     AddPatchTab
.notest         move.l  (args+arg_NoPermit,PC),d0       ;NoPermit
		bne     .nopermit
		move.l  4.w,a1
		lea     (exec_patches_pm,PC),a0
		bsr     AddPatchTab
.nopermit
		movem.l (SP)+,a0-a1
		rts
*<
*********************************************************
* Name          RP_Exec                                 *
* Funktion      Exec-Patches entfernen                  *
*                                                       *
* Parameter     keine                                   *
*                                                       *
*********************************************************
*> [RP_Exec] GLOBAL
		XDEF    RP_Exec
RP_Exec         movem.l a0-a1,-(SP)
		move.l  (args+arg_NoPermit,PC),d0       ;NoPermit
		bne     .nopermit
		move.l  4.w,a1
		lea     (exec_patches_pm,PC),a0
		bsr     RemPatchTab
.nopermit       move.l  (args+arg_ChkDisable,PC),d0     ;DisableTest?
		beq     .notest
		move.l  4.w,a1
		lea     (exec_patches_cd,PC),a0
		bsr     RemPatchTab
.notest
		move.l  4.w,a1
		lea     (exec_patches,PC),a0
		bsr     RemPatchTab
		movem.l (SP)+,a0-a1
		rts
*<
*********************************************************
* Name          exec_patches                            *
* Funktion      Tabelle aller Exec-Patches              *
*********************************************************
*> [exec_patches]
exec_patches    dpatch  _EXECAddPort,P_AddPort
		dpatch  _EXECAllocMem,P_AllocMem
		dpatch  _EXECAllocVec,P_AllocVec
		dpatch  _EXECCopyMem,P_CopyMem
		dpatch  _EXECCopyMemQuick,P_CopyMemQuick
		dpatch  _EXECCreateIORequest,P_CreateIORequest
		dpatch  _EXECDeleteMsgPort,P_DeleteMsgPort
		dpatch  _EXECEnable,P_Enable
		dpatch  _EXECFindPort,P_FindPort
		dpatch  _EXECFindSemaphore,P_FindSemaphore
		dpatch  _EXECFindTask,P_FindTask
		dpatch  _EXECFreeSignal,P_FreeSignal
		dpatch  _EXECInitSemaphore,P_InitSemaphore
		dpatch  _EXECOldOpenLibrary,P_OldOpenLibrary
		dpatch  _EXECProcure,P_Procure
		dpatch  _EXECReleaseSemaphore,P_ReleaseSemaphore
		dpatch  _EXECReleaseSemaphoreList,P_ReleaseSemaphoreList
		dpatch  _EXECSetFunction,P_SetFunction
		dpatch  _EXECVacate,P_Vacate
		dc.w    0                       ;Ende!

	;-- CheckDisable --
exec_patches_cd dpatch  _EXECDisable,P_Disable_cd
		dpatch  _EXECEnable,P_Enable_cd
		dc.w    0                       ;Ende!

	;-- Patch Permit --
exec_patches_pm dpatch  _EXECPermit,P_Permit
		dc.w    0                       ;Ende!

*<



*****************************************************************
*       == DIE PATCH-ROUTINEN                                   *
*****************************************************************

*********************************************************
* Patch         AddPort()                               *
* Tests         - LN_NAME muß initialisiert sein        *
*********************************************************
*> [AddPort()]
 PATCH P_AddPort,"AddPort(0x%08lx)",REG_A1

		tst.l   (LN_NAME,a1)
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_lnname,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_lnname     dc.b    "port name not initialized",0
		even
*<

*********************************************************
* Patch         AllocMem()                              *
* Tests         - Size darf nicht 0 sein                *
*********************************************************
*> [AllocMem()]
 PATCH P_AllocMem,"AllocMem(%lu,0x%08lx)",REG_D0,REG_D1

		tst.l   d0
		bmi     .badone
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_sizebad,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS
.badone         movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_noneg,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_sizebad    dc.b    "allocating 0 bytes",0
.msg_noneg      dc.b    "don't use AllocMem(-1) to flush memory",0
		even
*<

*********************************************************
* Patch         AllocVec()                              *
* Tests         - Size darf nicht 0 sein                *
*********************************************************
*> [AllocVec()]
 PATCH P_AllocVec,"AllocVec(%lu,0x%08lx)",REG_D0,REG_D1

		tst.l   d0
		bmi     .badone
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_sizebad,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS
.badone         movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_noneg,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_sizebad    dc.b    "allocating 0 bytes",0
.msg_noneg      dc.b    "don't use AllocVec(-1) to flush memory",0
		even
*<

*********************************************************
* Patch         CopyMem()                               *
* Tests         - Overlapping parts                     *
*********************************************************
*> [CopyMem()]
 PATCH P_CopyMem,"CopyMem(0x%08lx,0x%08lx,%lu)",REG_A0,REG_A1,REG_D0

		movem.l d0-d7/a0-a7,-(SP)
;-                tst.l   d0                      ;Größe = 0 ?
;-                beq     .idle
		cmp.l   a1,a0                   ;Source < Dest?
;                beq     .overlap
		blt     .srcbefore
	;-- Dest vor Source --------------------;
		move.l  a1,d1                   ;Dest-Ende berechnen
		add.l   d0,d1
		cmp.l   a0,d1                   ;muß auch vor Source sein
		bls     .okay
		lea     (.msg_overlapinc,PC),a1
		bra     .overlap
	;-- Dest hinter Source -----------------;
.srcbefore      move.l  a0,d1                   ;Source-Ende berechnen
		add.l   d0,d1
		cmp.l   a1,d1
		bls     .okay
		lea     (.msg_overlapdec,PC),a1
	;-- Bereiche überschneiden sich --------;
.overlap        move.l  SP,a0
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
	;-- Speicher OK ------------------------;
.okay           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS
	;-- Idle -------------------------------;
;-.idle           move.l  SP,a0
;-                lea     (.msg_idle,PC),a1
;-                lea     (.THIS,PC),a2
;-                moveq   #1,d0
;-                bsr     ShowHit
;-                bra     .okay

.msg_overlapinc dc.b    "memory areas are overlapping (incremental)",0
.msg_overlapdec dc.b    "memory areas are overlapping (decremental)",0
;-.msg_idle       dc.b    "copying 0 bytes is wasted time",0
		even
*<

*********************************************************
* Patch         CopyMemQuick()                          *
* Tests         - Overlapping parts                     *
*               - Aligned registers                     *
*********************************************************
*> [CopyMemQuick()]
 PATCH P_CopyMemQuick,"CopyMemQuick(0x%08lx,0x%08lx,%lu)",REG_A0,REG_A1,REG_D0

		movem.l d0-d7/a0-a7,-(SP)
;-                tst.l   d0                      ;Länge = 0
;-                beq     .idle
	;-- Register ---------------------------;
		move.l  a0,d1
		move.l  a1,d2
		or.l    d2,d1
		or.l    d0,d1
		and     #$3,d1
		beq     .nobadpointer
	;-- Fehlerhaft ausgerichtet ------------;
		move.l  SP,a0
		lea     (.msg_badptr,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.nobadpointer
	;-- Modus ------------------------------;
		cmp.l   a1,a0                   ;Source < Dest?
;                beq     .overlap
		blt     .srcbefore
	;-- Dest vor Source --------------------;
		move.l  a1,d1                   ;Dest-Ende berechnen
		add.l   d0,d1
		cmp.l   a0,d1                   ;muß auch vor Source sein
		bls     .okay
		lea     (.msg_overlapinc,PC),a1
		bra     .overlap
	;-- Dest hinter Source -----------------;
.srcbefore      move.l  a0,d1                   ;Source-Ende berechnen
		add.l   d0,d1
		cmp.l   a1,d1
		bls     .okay
		lea     (.msg_overlapdec,PC),a1
	;-- Bereiche überschneiden sich --------;
.overlap        move.l  SP,a0
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
	;-- Speicher OK ------------------------;
.okay           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS
	;-- Idle -------------------------------;
;-.idle           move.l  SP,a0
;-                lea     (.msg_idle,PC),a1
;-                lea     (.THIS,PC),a2
;-                moveq   #1,d0
;-                bsr     ShowHit
;-                bra     .okay

.msg_overlapinc dc.b    "memory areas are overlapping (incremental)",0
.msg_overlapdec dc.b    "memory areas are overlapping (decremental)",0
.msg_badptr     dc.b    "pointer/size not longword aligned",0
;-.msg_idle       dc.b    "copying 0 bytes is wasted time",0
		even
*<

*********************************************************
* Patch         CreateIORequest()                       *
* Tests         - No MsgPort supplied                   *
*               - Size too small                        *
*********************************************************
*> [CreateIORequest()]
 PATCH P_CreateIORequest,"CreateIORequest(0x%08lx,%lu)",REG_A0,REG_D0

		movem.l d0-d7/a0-a7,-(SP)
	;-- MsgPort initialisiert? -------------;
		move.l  a0,d1
		beq     .msgportok
		lea     (MP_MSGLIST,a0),a1
		cmp.l   (MP_MSGLIST+LH_TAILPRED,a0),a1
		beq     .msgportok
		movem.l d0/a0,-(SP)
		lea     (2*4,SP),a0
		lea     (.msg_badmp,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
		movem.l (SP)+,d0/a0
	;-- Größe OK ---------------------------;
.msgportok      cmp.l   #IO_SIZE,d0
		bhs     .size_ok
		move.l  SP,a0
		lea     (.msg_badsize,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.size_ok
	;-- Fertig -----------------------------;
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badmp      dc.b    "ioReplyPort not initialized",0
.msg_badsize    dc.b    "size is too small",0
		even
*<

*********************************************************
* Patch         DeleteMsgPort()                         *
* Tests         - Port entleert?                        *
*********************************************************
*> [DeleteMsgPort()]
 PATCH P_DeleteMsgPort,"DeleteMsgPort(0x%08lx)",REG_A0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  a0,a5                   ;merken
	;-- Port immer noch public? ------------;
		exec    Forbid
		move.l  (PortList,a6),a0        ;;PRIVATE EXECBASE ACCESS ;erste Node holen
.loop           move.l  a0,d0                   ;Ende der Liste?
		beq     .not_found
		cmp.l   a0,a5                   ;ist das der Port
		beq     .mp_found
		move.l  (a0),a0
		bra     .loop
.mp_found       exec    Permit
		move.l  SP,a0
		lea     (.msg_public,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		bra     .private
.not_found      exec    Permit
.private
	;-- MsgPort initialisiert? -------------;
		move.l  a5,d0
		beq     .msgportok
		lea     (MP_MSGLIST,a5),a0
		cmp.l   (MP_MSGLIST+LH_TAILPRED,a5),a0
		beq     .msgportok
		move.l  SP,a0
		lea     (.msg_notempty,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
.msgportok
	;-- Fertig -----------------------------;
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_public     dc.b    "MsgPort is still public",0
.msg_notempty   dc.b    "MsgPort contained unreplied Messages",0
		even
*<

*********************************************************
* Patch         Enable()                                *
* Tests         - Disabled                              *
*********************************************************
*> [Enable()]
 PATCH P_Enable,"Enable()"

		cmp.b   #-1,(IDNestCnt,a6)
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_wodisable,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_wodisable  dc.b    "Disable() missing",0
		even
*<

*********************************************************
* Patch         FindPort()                              *
* Tests         - Forbidden                             *
*********************************************************
*> [FindPort()]
 PATCH P_FindPort,"FindPort(\"%s\")",REG_A1|REGF_STR

		cmp.b   #-1,(IDNestCnt,a6)
		bne     .THIS
		cmp.b   #-1,(TDNestCnt,a6)
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notforbid,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		move.l  SP,d1
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit?
		beq     .THIS                    ; nee
		bsr     .THIS                    ;suchen
		tst.l   d0                      ;kein Port da?
		beq     .leave
		move.l  #$FACEDEAD,d0           ;Text
.leave          rts

.msg_notforbid  dc.b    "Forbid() missing, unreliable result",0
		even
*<

*********************************************************
* Patch         FindSemaphore()                         *
* Tests         - Forbidden                             *
*********************************************************
*> [FindSemaphore()]
 PATCH P_FindSemaphore,"FindSemaphore(\"%s\")",REG_A1|REGF_STR

		cmp.b   #-1,(IDNestCnt,a6)
		bne     .THIS
		cmp.b   #-1,(TDNestCnt,a6)
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notforbid,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit?
		beq     .THIS                    ; nee
		bsr     .THIS                    ;suchen
		tst.l   d0                      ;keine Semaphore da?
		beq     .leave
		move.l  #$FACEDEAD,d0           ;Text
.leave          rts

.msg_notforbid  dc.b    "Forbid() missing, unreliable result",0
		even
*<

*********************************************************
* Patch         FindTask()                              *
* Tests         - Forbidden                             *
*********************************************************
*> [FindTask()]
 PATCH P_FindTask,"FindTask(\"%s\")",REG_A1|REGF_STR

		move.l  a1,d0                   ;; REGISTER WIRD VERÄNDERT !!!
		beq     .THIS
		cmp.b   #-1,(IDNestCnt,a6)
		bne     .THIS
		cmp.b   #-1,(TDNestCnt,a6)
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_notforbid,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		move.l  (args+arg_Deadly,PC),d0 ;Deadly hit?
		beq     .THIS                    ; nee
		bsr     .THIS                    ;suchen
		tst.l   d0                      ;kein Task da?
		beq     .leave
		move.l  #$FACEDEAD,d0           ;Text
.leave          rts

.msg_notforbid  dc.b    "Forbid() missing, unreliable result",0
		even
*<

*********************************************************
* Patch         FreeSignal()                            *
* Tests         - Warn if -1                            *
*********************************************************
*> [FreeSignal()]
 PATCH P_FreeSignal,"FreeSignal(%ld)",REG_D0

		cmp.b   #-1,d0
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_needsv37,PC),a1
		lea     (.THIS,PC),a2
		moveq   #37,d0                  ; Min. OS 37
		swap    d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_needsv37   dc.b    "V37+ will be required",0
		even
*<

*********************************************************
* Patch         InitSemaphore()                         *
* Tests         - Alles mit 0 initialisieren            *
*********************************************************
*> [InitSemaphore()]
 PATCH P_InitSemaphore,"InitSemaphore(0x%08lx)",REG_A0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  a0,a1
		moveq   #0,d1
		moveq   #(SS_SIZE>>1)-1,d0
.loop           or      (a0)+,d1
		dbra    d0,.loop
		tst     d1
		beq     .clean
		move.l  SP,a0
		lea     (.msg_badinit,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
.clean          movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_badinit    dc.b    "structure is not cleared",0
		even
*<

*********************************************************
* Patch         OldOpenLibrary()                        *
* Tests         - Generell bäh!                         *
*********************************************************
*> [OldOpenLibrary()]
 PATCH P_OldOpenLibrary,"OldOpenLibrary(\"%s\")",REG_A1|REGF_STR

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_obsolete,PC),a1
		lea     (.THIS,PC),a2
		moveq   #1,d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_obsolete   dc.b    "obsoleted, use OpenLibrary() instead",0
		even
*<

*********************************************************
* Patch         Permit()                                *
* Tests         - Forbidden                             *
*********************************************************
*> [Permit()]
 PATCH P_Permit,"Permit()"

		cmp.b   #-1,(TDNestCnt,a6)
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_woforbid,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_woforbid   dc.b    "Forbid() missing",0
		even
*<

*********************************************************
* Patch         Procure()                               *
* Tests         - Generelle Warnung                     *
*********************************************************
*> [Procure()]
 PATCH P_Procure,"Procure(0x%08lx,0x%08lx)",REG_A0,REG_A1

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_needsv39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_needsv39   dc.b    "V39+ will be required",0
		even
*<

*********************************************************
* Patch         ReleaseSemaphore()                      *
* Tests         - überhaupt belegt                      *
*********************************************************
*> [ReleaseSemaphore()]
 PATCH P_ReleaseSemaphore,"ReleaseSemaphore(0x%08lx)",REG_A0

		tst     (SS_NESTCOUNT,a0)       ;Darf nicht 0 sein
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_already,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_already    dc.b    "semaphore is not obtained",0
		even
*<

*********************************************************
* Patch         ReleaseSemaphoreList()                  *
* Tests         - überhaupt belegt                      *
*********************************************************
*> [ReleaseSemaphoreList()]
 PATCH P_ReleaseSemaphoreList,"ReleaseSemaphoreList(0x%08lx)",REG_A0

		movem.l d0-d7/a0-a7,-(SP)
		move.l  (a0),a4                 ;^1. Semaphore
.loop           tst.l   (a4)                    ;Ende der Liste?
		beq     .done
		tst     (SS_NESTCOUNT,a4)       ;Darf nicht 0 sein
		bne     .next
		move.l  SP,a0
		move.l  a4,-(SP)
		lea     (.msg_already,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
.next           move.l  (a4),a4                 ;Nächste Node
		bra     .loop
.done           movem.l (SP)+,d0-d7/a0-a7       ;Fertig
		bra     .THIS

.msg_already    dc.b    "semaphore @0x%08lx is not obtained",0
		even
*<

*********************************************************
* Patch         SetFunction()                           *
* Tests         - Bestimmte Exec-Funktionen nicht !     *
*********************************************************
*> [SetFunction()]
 PATCH P_SetFunction,"SetFunction(0x%08lx,%ld,0x%08lx)",REG_A1,REG_A0|REGF_WORD,REG_D0

		cmp.l   a6,a1                   ;wird exec gepatched?
		bne     .no_exec                ;  nö: uninteressant
		cmpa.w  #_EXECSupervisor,a0     ;Diese dürfen nicht gepatcht werden
		beq     .alert2                 ;  (Absturz!)
		cmpa.w  #_EXECSchedule,a0
		beq     .alert2
		cmpa.w  #_EXECSumLibrary,a0
		beq     .alert
		cmpa.w  #_EXECCacheClearU,a0
		beq     .alert
.no_exec        movem.l d0-d7/a0-a7,-(SP)
		move    a0,d1
		bmi     .not_pos
		move.l  SP,a0
		move.l  d1,-(SP)
		lea     (.msg_negative,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
		move.l  (SP)+,d1
.not_pos        neg     d1
		cmp     (LIB_NEGSIZE,a1),d1
		bls     .func_found
		move.l  SP,a0
		lea     (.msg_exceed,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		bsr     ShowHit
.func_found     cmp.b   #-1,(IDNestCnt,a6)
		bne     .forbidden
		cmp.b   #-1,(TDNestCnt,a6)
		bne     .forbidden
		move.l  SP,a0
		lea     (.msg_noforbid,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
.forbidden
		movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.alert2         tst.w   (SysFlags,a6)           ;Das geht dann gut...
		bpl     .no_exec
.alert          movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_dontpatch,PC),a1
		lea     (.THIS,PC),a2
		moveq   #2,d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		bra     .no_exec

.msg_negative   dc.b    "the function offset must be negative",0
.msg_dontpatch  dc.b    "your patch is called before SetFunction() returns",0
.msg_exceed     dc.b    "requested function does not exist",0
.msg_noforbid   dc.b    "Forbid() missing",0
		even
*<

*********************************************************
* Patch         Vacate()                                *
* Tests         - Generelle Warnung                     *
*********************************************************
*> [Vacate()]
 PATCH P_Vacate,"Vacate(0x%08lx,0x%08lx)",REG_A0,REG_A1

		movem.l d0-d7/a0-a7,-(SP)
		move.l  SP,a0
		lea     (.msg_needsv39,PC),a1
		lea     (.THIS,PC),a2
		moveq   #39,d0                  ;MinOS 39
		swap    d0
		bsr     ShowHit
.exit           movem.l (SP)+,d0-d7/a0-a7
		bra     .THIS

.msg_needsv39   dc.b    "V39+ will be required",0
		even
*<


*********************************************************
* Patch         Disable()                               *
* Tests         - Timeout                               *
*********************************************************
*> [Disable()]
 PATCH P_Disable_cd,"Disable()"

		cmp.b   #-1,(IDNestCnt,a6)
		bne     .THIS
		bsr     StartTimer
		bra     .THIS
*<
*********************************************************
* Patch         Enable()                                *
* Tests         - Timeout                               *
*********************************************************
*> [Enable()]
 PATCH P_Enable_cd,"Enable()"

		tst.b   (IDNestCnt,a6)          ;Muß exakt 0 sein -> enabling
		bne     .THIS
		movem.l d0-d7/a0-a7,-(SP)
		bsr     StopTimer
		bsr     .THIS
		bsr     CalcTimer
		cmp.l   #250,d0                 ;<250 ?
		bls     .okay
		move.l  SP,a0
		move.l  d0,-(SP)
		lea     (.msg_toolong,PC),a1
		lea     (.THIS,PC),a2
		moveq   #3,d0
		move.l  SP,d1
		bsr     ShowHit
		addq.l  #4,SP
.okay           movem.l (SP)+,d0-d7/a0-a7
		rts

.msg_toolong    dc.b    "Disable time exceeded (%ld ms)",0
		even
*<

		END
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
