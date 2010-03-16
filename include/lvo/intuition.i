_INTOpenIntuition       equ     -30
_INTIntuition           equ     -36
_INTAddGadget           equ     -42
_INTClearDMRequest      equ     -48
_INTClearMenuStrip      equ     -54
_INTClearPointer        equ     -60
_INTCloseScreen         equ     -66
_INTCloseWindow         equ     -72
_INTCloseWorkBench      equ     -78
_INTCurrentTime         equ     -84
_INTDisplayAlert        equ     -90
_INTDisplayBeep         equ     -96
_INTDoubleClick         equ     -102
_INTDrawBorder          equ     -108
_INTDrawImage           equ     -114
_INTEndRequest          equ     -120
_INTGetDefPrefs         equ     -126
_INTGetPrefs            equ     -132
_INTInitRequester       equ     -138
_INTItemAddress         equ     -144
_INTModifyIDCMP         equ     -150
_INTModifyProp          equ     -156
_INTMoveScreen          equ     -162
_INTMoveWindow          equ     -168
_INTOffGadget           equ     -174
_INTOffMenu             equ     -180
_INTOnGadget            equ     -186
_INTOnMenu              equ     -192
_INTOpenScreen          equ     -198
_INTOpenWindow          equ     -204
_INTOpenWorkBench       equ     -210
_INTPrintIText          equ     -216
_INTRefreshGadgets      equ     -222
_INTRemoveGadget        equ     -228
_INTReportMouse         equ     -234
_INTRequest             equ     -240
_INTScreenToBack        equ     -246
_INTScreenToFront       equ     -252
_INTSetDMRequest        equ     -258
_INTSetMenuStrip        equ     -264
_INTSetPointer          equ     -270
_INTSetWindowTitles     equ     -276
_INTShowTitle           equ     -282
_INTSizeWindow          equ     -288
_INTViewAddress         equ     -294
_INTViewPortAddress     equ     -300
_INTWindowToBack        equ     -306
_INTWindowToFront       equ     -312
_INTWindowLimits        equ     -318
_INTSetPrefs            equ     -324    ;Kick 1.1
_INTIntuiTextLength     equ     -330
_INTWBenchToBack        equ     -336
_INTWBenchToFront       equ     -342
_INTAutoRequest         equ     -348
_INTBeginRefresh        equ     -354
_INTBuildSysRequest     equ     -360
_INTEndRefresh          equ     -366
_INTFreeSysRequest      equ     -372
_INTMakeScreen          equ     -378
_INTRemakeDisplay       equ     -384
_INTRethinkDisplay      equ     -390
_INTAllocRemember       equ     -396
_INTAlohaWorkbench      equ     -402
_INTFreeRemember        equ     -408
_INTLockIBase           equ     -414
_INTUnlockIBase         equ     -420
_INTGetScreenData       equ     -426    ;Kick 1.2
_INTRefreshGList        equ     -432
_INTAddGList            equ     -438
_INTRemoveGList         equ     -444
_INTActivateWindow      equ     -450
_INTRefreshWindowFrame  equ     -456
_INTActivateGadget      equ     -462
_INTNewModifyProp       equ     -468
_INTQueryOverscan       equ     -474    ;Kick 2.0
_INTMoveWindowInFrontOf equ     -480
_INTChangeWindowBox     equ     -486
_INTSetEditHook         equ     -492
_INTSetMouseQueue       equ     -498
_INTZipWindow           equ     -504
_INTLockPubScreen       equ     -510
_INTUnlockPubScreen     equ     -516
_INTLockPubScreenList   equ     -522
_INTUnlockPubScreenList equ     -528
_INTNextPubScreen       equ     -534
_INTSetDefaultPubScreen equ     -540
_INTSetPubScreenModes   equ     -546
_INTPubScreenStatus     equ     -552
_INTObtainGIRPort       equ     -558
_INTReleaseGIRPort      equ     -564
_INTGadgetMouse         equ     -570
_INTintuitionPrivate1   equ     -576
_INTGetDefaultPubScreen equ     -582
_INTEasyRequestArgs     equ     -588
_INTBuildEasyRequestArgs equ    -594
_INTSysReqHandler       equ     -600
_INTOpenWindowTagList   equ     -606
_INTOpenScreenTagList   equ     -612
_INTDrawImageState      equ     -618
_INTPointInImage        equ     -624
_INTEraseImage          equ     -630
_INTNewObjectA          equ     -636
_INTDisposeObject       equ     -642
_INTSetAttrsA           equ     -648
_INTGetAttr             equ     -654
_INTSetGadgetAttrsA     equ     -660
_INTNextObject          equ     -666
_INTMakeClass           equ     -678
_INTAddClass            equ     -684
_INTGetScreenDrawInfo   equ     -690
_INTFreeScreenDrawInfo  equ     -696
_INTResetMenuStrip      equ     -702
_INTRemoveClass         equ     -708
_INTFreeClass           equ     -714    ;Kick 3.0
_INTAllocScreenBuffer   equ     -768
_INTFreeScreenBuffer    equ     -774
_INTChangeScreenBuffer  equ     -780
_INTScreenDepth         equ     -786
_INTScreenPosition      equ     -792
_INTScrollWindowRaster  equ     -798
_INTLendMenus           equ     -804
_INTDoGadgetMethodA     equ     -810
_INTSetWindowPointerA   equ     -816
_INTTimedDisplayAlert   equ     -822
_INTHelpControl         equ     -828

intui           MACRO
		IFNC    "\0","D"
		 IFD     FAR
		  move.l intuibase,a6
		 ELSE
		  move.l (intuibase,PC),a6
		 ENDC
		ENDC
		jsr     _INT\1(a6)
		ENDM
		
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
