*
* PatchWork
*
* Copyright (C) 2010 Richard "Shred" K�rber
*   http://patchwork.shredzone.org
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*

		XREF	KPrintF
		XREF	KPutChar

		IFND	PW_MAIN
		 XREF	gl, dosbase, args, utilsbase, disasmbase, AddPatchTab
		 XREF	RemPatchTab, alert_badone
		ENDC

		IFND	PW_EXEC
		 XREF	SP_Exec, RP_Exec
		ENDC

		IFND	PW_DOS
		 XREF	SP_Dos, RP_Dos
		ENDC

		IFND	PW_GRAPHICS
		 XREF	SP_Graphics, RP_Graphics
		ENDC

		IFND	PW_INTUITION
		 XREF	SP_Intuition, RP_Intuition
		ENDC

		IFND	PW_UTILITY
		 XREF	SP_Utility, RP_Utility
		ENDC

		IFND	PW_COMMODITIES
		 XREF	SP_Commodities, RP_Commodities
		ENDC

		IFND	PW_HIT
		 XREF	ShowHit
		ENDC

		IFND	PW_TIMER
		 XREF	InitTimer, ExitTimer, StartTimer, StopTimer, CalcTimer
		ENDC

		IFND	PW_GADTOOLS
		 XREF	SP_Gadtools, RP_Gadtools
		ENDC

*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k: