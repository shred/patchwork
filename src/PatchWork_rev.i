*
* PatchWork
*
* Copyright (C) 2021 Richard "Shred" Koerber
*	http://patchwork.shredzone.org
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
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*

VERSION		EQU     0
REVISION	EQU     18

PRGNAME		MACRO
		dc.b    'PatchWork'
		ENDM

VERS		MACRO
		PRGNAME
		dc.b    ' '
		dc.b	'0.18'
		ENDM

DATE		MACRO
		dc.b    '26.4.2021'
		ENDM

COPYRIGHT	MACRO
		dc.b	"(C) 1997-2021 Richard 'Shred' K",$f6,"rber"
		ENDM

PROJECTURL	MACRO
		dc.b	'https://patchwork.shredzone.org'
		ENDM

VSTRING		MACRO
		VERS
		dc.b	' ('
		DATE
		dc.b	')',13,10,0
		ENDM

VSTR		MACRO
		VERS
		dc.b	' ('
		DATE
		dc.b	')'
		ENDM

VERSTAG		MACRO
		dc.b    0,'$VER: '
		VSTR
		dc.b	0
		ENDM
