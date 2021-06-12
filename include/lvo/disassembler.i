*
* disassembler.library by Thomas Richter
*
* This is copyrighted material, and not part of the patchwork license. It is only here
* for your convenience.
*
* The original file can be downloaded here:
*	http://aminet.net/package/util/libs/DisLib
*

_DISDisassemble			EQU	-66
_DISFindStartPosition		EQU	-72


disasm		MACRO
		IFNC	"\0","Q"
		 move.l	disasmbase(PC),a6
		ENDC
		jsr	_DIS\1(a6)
		ENDM
