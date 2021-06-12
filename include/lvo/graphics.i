_GFXBltBitMap			EQU	-30
_GFXBltTemplate			EQU	-36
_GFXClearEOL			EQU	-42
_GFXClearScreen			EQU	-48
_GFXTextLength			EQU	-54
_GFXText			EQU	-60
_GFXSetFont			EQU	-66
_GFXOpenFont			EQU	-72
_GFXCloseFont			EQU	-78
_GFXAskSoftStyle		EQU	-84
_GFXSetSoftStyle		EQU	-90
_GFXAddBob			EQU	-96
_GFXAddVSprite			EQU	-102
_GFXDoCollision			EQU	-108
_GFXDrawGList			EQU	-114
_GFXInitGels			EQU	-120
_GFXInitMasks			EQU	-126
_GFXRemIBob			EQU	-132
_GFXRemVSprite			EQU	-138
_GFXSetCollision		EQU	-144
_GFXSortGList			EQU	-150
_GFXAddAnimOb			EQU	-156
_GFXAnimate			EQU	-162
_GFXGetGBuffers			EQU	-168
_GFXInitGMasks			EQU	-174
_GFXDrawEllipse			EQU	-180
_GFXAreaEllipse			EQU	-186
_GFXLoadRGB4			EQU	-192
_GFXInitRastPort		EQU	-198
_GFXInitVPort			EQU	-204
_GFXMrgCop			EQU	-210
_GFXMakeVPort			EQU	-216
_GFXLoadView			EQU	-222
_GFXWaitBlit			EQU	-228
_GFXSetRast			EQU	-234
_GFXMove			EQU	-240
_GFXDraw			EQU	-246
_GFXAreaMove			EQU	-252
_GFXAreaDraw			EQU	-258
_GFXAreaEnd			EQU	-264
_GFXWaitTOF			EQU	-270
_GFXQBlit			EQU	-276
_GFXInitArea			EQU	-282
_GFXSetRGB4			EQU	-288
_GFXQBSBlit			EQU	-294
_GFXBltClear			EQU	-300
_GFXRectFill			EQU	-306
_GFXBltPattern			EQU	-312
_GFXReadPixel			EQU	-318
_GFXWritePixel			EQU	-324
_GFXFlood			EQU	-330
_GFXPolyDraw			EQU	-336
_GFXSetAPen			EQU	-342
_GFXSetBPen			EQU	-348
_GFXSetDrMd			EQU	-354
_GFXInitView			EQU	-360
_GFXCBump			EQU	-366
_GFXCMove			EQU	-372
_GFXCWait			EQU	-378
_GFXVBeamPos			EQU	-384
_GFXInitBitMap			EQU	-390
_GFXScrollRaster		EQU	-396
_GFXWaitBOVP			EQU	-402
_GFXGetSprite			EQU	-408
_GFXFreeSprite			EQU	-414
_GFXChangeSprite		EQU	-420
_GFXMoveSprite			EQU	-426
_GFXLockLayerRom		EQU	-432
_GFXUnlockLayerRom		EQU	-438
_GFXSyncSBitMap			EQU	-444
_GFXCopySBitMap			EQU	-450
_GFXOwnBlitter			EQU	-456
_GFXDisownBlitter		EQU	-462
_GFXInitTmpRas			EQU	-468
_GFXAskFont			EQU	-474
_GFXAddFont			EQU	-480
_GFXRemFont			EQU	-486
_GFXAllocRaster			EQU	-492
_GFXFreeRaster			EQU	-498
_GFXAndRectRegion		EQU	-504
_GFXOrRectRegion		EQU	-510
_GFXNewRegion			EQU	-516
_GFXClearRectRegion		EQU	-522
_GFXClearRegion			EQU	-528
_GFXDisposeRegion		EQU	-534
_GFXFreeVPortCopLists		EQU	-540
_GFXFreeCopList			EQU	-546
_GFXClipBlit			EQU	-552
_GFXXorRectRegion		EQU	-558
_GFXFreeCprList			EQU	-564
_GFXGetColorMap			EQU	-570
_GFXFreeColorMap		EQU	-576
_GFXGetRGB4			EQU	-582
_GFXScrollVPort			EQU	-588
_GFXUCopperListInit		EQU	-594
_GFXFreeGBuffers		EQU	-600
_GFXBltBitMapRastPort		EQU	-606
_GFXOrRegionRegion		EQU	-612	;Kick 1.2
_GFXXorRegionRegion		EQU	-618
_GFXAndRegionRegion		EQU	-624
_GFXSetRGB4CM			EQU	-630
_GFXBltMaskBitMapRastPort	EQU	-636
_GFXAttemptLockLayerRom 	EQU	-654
_GFXGfxNew			EQU	-660
_GFXGfxFree			EQU	-666
_GFXGfxAssociate		EQU	-672
_GFXBitMapScale			EQU	-678	;Kick 2.0
_GFXScalerDiv			EQU	-684
_GFXTextExtent			EQU	-690
_GFXTextFit			EQU	-696
_GFXGfxLookUp			EQU	-702
_GFXVideoControl		EQU	-708
_GFXOpenMonitor			EQU	-714
_GFXCloseMonitor		EQU	-720
_GFXFindDisplayInfo		EQU	-726
_GFXNextDisplayInfo		EQU	-732
_GFXGetDisplayInfoData		EQU	-756
_GFXFontExtent			EQU	-762
_GFXReadPixelLine8		EQU	-768
_GFXWritePixelLine8		EQU	-774
_GFXReadPixelArray8		EQU	-780
_GFXWritePixelArray8		EQU	-786
_GFXGetVPModeID			EQU	-792
_GFXModeNotAvailable		EQU	-798
_GFXWeighTAMatch		EQU	-804
_GFXEraseRect			EQU	-810
_GFXExtendFont			EQU	-816
_GFXStripFont			EQU	-822
_GFXCalcIVG			EQU	-828	;Kick 3.0
_GFXAttachPalExtra		EQU	-834
_GFXObtainBestPenA		EQU	-840
_GFXSetRGB32			EQU	-852
_GFXGetAPen			EQU	-858
_GFXGetBPen			EQU	-864
_GFXGetDrMd			EQU	-870
_GFXGetOutlinePen		EQU	-876
_GFXLoadRGB32			EQU	-882
_GFXSetChipRev			EQU	-888
_GFXSetABPenDrMd		EQU	-894
_GFXGetRGB32			EQU	-900
_GFXAllocBitMap			EQU	-918
_GFXFreeBitMap			EQU	-924
_GFXGetExtSpriteA		EQU	-930
_GFXCoerceMode			EQU	-936
_GFXChangeVPBitMap		EQU	-942
_GFXReleasePen			EQU	-948
_GFXObtainPen			EQU	-954
_GFXGetBitMapAttr		EQU	-960
_GFXAllocDBufInfo		EQU	-966
_GFXFreeDBufInfo		EQU	-972
_GFXSetOutlinePen		EQU	-978
_GFXSetWriteMask		EQU	-984
_GFXSetMaxPen			EQU	-990
_GFXSetRGB32CM			EQU	-996
_GFXScrollRasterBF		EQU	-1002
_GFXFindColor			EQU	-1008
_GFXAllocSpriteDataA		EQU	-1020
_GFXChangeExtSpriteA		EQU	-1026
_GFXFreeSpriteData		EQU	-1032
_GFXSetRPAttrsA			EQU	-1038
_GFXGetRPAttrsA			EQU	-1044
_GFXBestModeIDA			EQU	-1050
_GFXWriteChunkyPixels		EQU	-1056	;Kick 3.1

gfx		MACRO
		move.l	gfxbase(PC),a6
		jsr	_GFX\1(a6)
		ENDM
