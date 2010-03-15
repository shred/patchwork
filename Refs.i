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

*---- Generelle Referenzen --------------------------------------*

		XREF    KPrintF
		XREF    KPutChar

*---- Referenzen von   PW_Main.s    -----------------------------*

		IFND    PW_MAIN
	XREF    gl, dosbase, args, utilsbase, disasmbase, AddPatchTab
	XREF    RemPatchTab, alert_badone
		ENDC

*---- Referenzen von   PW_Exec.s    -----------------------------*

		IFND    PW_EXEC
		 XREF   SP_Exec, RP_Exec
		ENDC

*---- Referenzen von   PW_Dos.s     -----------------------------*

		IFND    PW_DOS
		 XREF   SP_Dos, RP_Dos
		ENDC

*---- Referenzen von   PW_Graphics.s    -------------------------*

		IFND    PW_GRAPHICS
		 XREF   SP_Graphics, RP_Graphics
		ENDC

*---- Referenzen von   PW_Intuition.s    ------------------------*

		IFND    PW_INTUITION
		 XREF   SP_Intuition, RP_Intuition
		ENDC

*---- Referenzen von   PW_Utility.s    --------------------------*

		IFND    PW_UTILITY
		 XREF   SP_Utility, RP_Utility
		ENDC

*---- Referenzen von   PW_Commodities.s    ----------------------*

		IFND    PW_COMMODITIES
		 XREF   SP_Commodities, RP_Commodities
		ENDC

*---- Referenzen von   PW_Hit.s     -----------------------------*

		IFND    PW_HIT
		 XREF   ShowHit
		ENDC

*---- Referenzen von   PW_Timer.s     ---------------------------*

		IFND    PW_TIMER
		 XREF   InitTimer, ExitTimer, StartTimer, StopTimer, CalcTimer
		ENDC

*---- Referenzen von   PW_Gadtools.s   --------------------------*

		IFND    PW_GADTOOLS
		 XREF   SP_Gadtools, RP_Gadtools
		ENDC

*----------------------------------------------------------------*
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
