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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*

VERSION         EQU     0
REVISION        EQU     18

DATE            MACRO
		dc.b    '16.3.2010'
		ENDM

VERS            MACRO
		dc.b    'PatchWork 0.18'
		ENDM
		
VSTRING         MACRO
		dc.b    'PatchWork 0.18 (16.3.2010)',13,10,0
		ENDM
		
VERSTAG         MACRO
		dc.b    0,'$VER: PatchWork 0.18 (16.3.2010)',0
		ENDM
		
TIME            MACRO
		dc.b    '01:56:35'
		ENDM
		
PRGNAME         MACRO
		dc.b    'PatchWork'
		ENDM
		
BASENAME        MACRO
		dc.b    'PATCHWORK'
		ENDM
		
VSTR            MACRO
		dc.b    'PatchWork 0.18 (16.3.2010)'
		ENDM
		
USER            MACRO
		dc.b    'shred'
		ENDM
		
HOST            MACRO
		dc.b    'fuchsia.home'
		ENDM
	
*jEdit: :tabSize=8:indentSize=8:mode=assembly-m68k:
