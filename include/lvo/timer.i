
_TIMERAddTime			EQU	-42
_TIMERSubTime			EQU	-48
_TIMERCmpTime			EQU	-54
_TIMERReadEClock		EQU	-60
_TIMERGetSysTime		EQU	-66

timer		MACRO
		move.l	timerbase(PC),a6
		jsr	_TIMER\1(a6)
		ENDM
