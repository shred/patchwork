*
* disassembler.library by Thomas Richter
*

_DISDisassemble			EQU	-66
_DISFindStartPosition		EQU	-72


disasm		MACRO
		IFNC	"\0","q"
		 move.l	disasmbase(PC),a6
		ENDC
		jsr	_DIS\1(a6)
		ENDM
