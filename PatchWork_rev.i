;* Assembly includefile generated by RevUp 1.3 BETA 88 *

VERSION         EQU     0
REVISION        EQU     18
DATE    MACRO
		dc.b    '16.3.2010'
	ENDM
VERS    MACRO
		dc.b    'PatchWork 0.18'
	ENDM
VSTRING MACRO
		dc.b    'PatchWork 0.18 (16.3.2010)',13,10,0
	ENDM
VERSTAG MACRO
		dc.b    0,'$VER: PatchWork 0.18 (16.3.2010)',0
	ENDM
TIME    MACRO
		dc.b    '01:56:35'
	ENDM
PRGNAME MACRO
		dc.b    'PatchWork'
	ENDM
BASENAME        MACRO
		dc.b    'PATCHWORK'
	ENDM
VSTR    MACRO
		dc.b    'PatchWork 0.18 (16.3.2010)'
	ENDM
USER    MACRO
		dc.b    'shred'
	ENDM
HOST    MACRO
		dc.b    'fuchsia.home'
	ENDM
