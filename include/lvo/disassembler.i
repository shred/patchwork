
_DISDisassemble         EQU     -66
_DISFindStartPosition   EQU     -72


disasm          MACRO
		IFNC    "\0","D"
		 IFD     FAR
		  move.l disasmbase,a6
		 ELSE
		  move.l disasmbase(PC),a6
		 ENDC
		ENDC
		jsr     _DIS\1(a6)
		ENDM

*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
