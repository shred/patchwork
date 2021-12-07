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

		INCLUDE	"exec/execbase.i"
		INCLUDE	"exec/memory.i"
		INCLUDE	"devices/timer.i"
		INCLUDE	"lvo/exec.i"
		INCLUDE	"lvo/utility.i"
		INCLUDE	"lvo/timer.i"

		INCLUDE	phxmacros.i

		INCLUDE	PatchWork_rev.i
		INCLUDE	PatchWork.i

		MACHINE 68020

		SECTION	text,CODE

		rsreset
tmr_MsgPort	rs.l	1	;^Timer MsgPort
tmr_TimerReq	rs.l	1	;^Timer IORequest
tmr_TimerBase	rs.l	1	;^timer.device
tmr_StartTime	rs.l	2	;Starting time
tmr_StopTime	rs.l	2	;Ending time
tmr_EClock	rs.l	1	;EClock
tmr_SIZEOF	rs.w	0

*---
* Initializes the timer
*
*	<- d0.l Success
*
		PUBLIC	InitTimer
InitTimer	pushm.l	d1-d7/a0-a5
		move.l	(args+arg_ChkDisable,PC),d0
		beq	.notest
		lea	(timerstruct,PC),a5
		exec	CreateMsgPort
		move.l	d0,(tmr_MsgPort,a5)
		beq	.exit1
		move.l	d0,a0
		move.l	#IOTV_SIZE,d0
		exec	CreateIORequest
		move.l	d0,(tmr_TimerReq,a5)
		beq	.exit2
		lea	(.timername,PC),a0
		move.l	#UNIT_MICROHZ,d0
		move.l	(tmr_TimerReq,a5),a1
		moveq	#0,d1
		exec	OpenDevice
		tst.l	d0
		bne	.exit3
		move.l	(tmr_TimerReq,a5),a0
		move.l	(IO_DEVICE,a0),(tmr_TimerBase,a5)
.notest		moveq	#-1,d0
		bra	.exit1
.exit3		move.l	(tmr_TimerReq,a5),a0
		exec	DeleteIORequest
.exit2		move.l	(tmr_MsgPort,a5),a0
		exec	DeleteMsgPort
.exit1		popm.l	d1-d7/a0-a5
		rts

.timername	dc.b	"timer.device",0
		even


*---
* Closes the timer
*
		PUBLIC	ExitTimer
ExitTimer	pushm.l	d0-d7/a0-a5
		move.l	(args+arg_ChkDisable,PC),d0
		beq	.notest
		lea	(timerstruct,PC),a5
		move.l	(tmr_TimerReq,a5),a1
		exec	CloseDevice
		move.l	(tmr_TimerReq,a5),a0
		exec	DeleteIORequest
		move.l	(tmr_MsgPort,a5),a0
		exec	DeleteMsgPort
.notest		popm.l	d0-d7/a0-a5
		rts


*---
* Starts the timer
*
		PUBLIC	StartTimer
StartTimer	pushm.l	d0-d1/a0-a1/a5-a6
		lea	(timerstruct,PC),a5
		lea	(tmr_StartTime,a5),a0
		move.l	(tmr_TimerBase,a5),a6
		jsr	(_TIMERReadEClock,a6)
		popm.l	d0-d1/a0-a1/a5-a6
		rts

*---
* Stops the timer
*
*	<- d0.l Timestamp LSB
*	<- d1.l Timestamp MSB
*
		PUBLIC	StopTimer
StopTimer	pushm.l	d2/a0-a1/a5-a6
		lea	(timerstruct,PC),a5
		lea	(tmr_StopTime,a5),a0
		move.l	(tmr_TimerBase,a5),a6
		jsr	(_TIMERReadEClock,a6)
		move.l	d0,(tmr_EClock,a5)
		move.l	(tmr_StopTime+4,a5),d0
		sub.l	(tmr_StartTime+4,a5),d0
		move.l	(tmr_StopTime,a5),d1
		move.l	(tmr_StartTime,a5),d2
		subx.l	d2,d1
		popm.l	d2/a0-a1/a5-a6
		rts

*---
* Converts the timestamp to milliseconds
*
*	-> d0.l Timestamp LSB
*	-> d1.l Timestamp MSB
*	<- d0.l Difference (milliseconds)
*
		PUBLIC	CalcTimer
CalcTimer	pushm.l	d1-d3
		move.l	#1000,d3
		mulu.l	d3,d2:d0
		mulu.l	d3,d3:d1
		tst.l	d3
		bne	.error
		add.l	d1,d2
		move.l	(timerstruct+tmr_EClock,PC),d1
		beq	.error
		divu.l	d1,d2:d0
		bvs	.error
.exit		popm.l	d1-d3
		rts
.error		moveq	#0,d0
		bra	.exit

timerstruct	ds.b	tmr_SIZEOF
