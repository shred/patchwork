
_GADCreateGadgetA		EQU	-30
_GADFreeGadgets			EQU	-36
_GADGT_SetGadgetAttrsA		EQU	-42
_GADCreateMenusA		EQU	-48
_GADFreeMenus			EQU	-54
_GADLayoutMenuItemsA		EQU	-60
_GADLayoutMenusA		EQU	-66
_GADGT_GetIMsg			EQU	-72
_GADGT_ReplyIMsg		EQU	-78
_GADGT_RefreshWindow		EQU	-84
_GADGT_BeginRefresh		EQU	-90
_GADGT_EndRefresh		EQU	-96
_GADGT_FilterIMsg		EQU	-102
_GADGT_PostFilterIMsg		EQU	-108
_GADCreateContext		EQU	-114
_GADDrawBevelBoxA		EQU	-120
_GADGetVisualInfoA		EQU	-126
_GADFreeVisualInfo		EQU	-132
_GADgadtoolsPrivate1		EQU	-138
_GADgadtoolsPrivate2		EQU	-144
_GADgadtoolsPrivate3		EQU	-150
_GADgadtoolsPrivate4		EQU	-156
_GADgadtoolsPrivate5		EQU	-162
_GADgadtoolsPrivate6		EQU	-168
_GADGT_GetGadgetAttrsA		EQU	-174	;V39


gad		MACRO
		IFNC	"\0","q"
		 move.l	gadbase(PC),a6
		ENDC
		jsr	_GAD\1(a6)
		ENDM
