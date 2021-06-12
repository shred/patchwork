#
# PatchWork
#
# Copyright (C) 2021 Richard "Shred" Koerber
#   http://patchwork.shredzone.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

SRCP	  = src
INCP      = include
DSTP      = distribution
OBJP      = build
RELP      = release
DOCP      = docs

OBJS      = $(OBJP)/Main.o $(OBJP)/Hit.o $(OBJP)/Timer.o $(OBJP)/Exec.o \
            $(OBJP)/Dos.o $(OBJP)/Graphics.o $(OBJP)/Intuition.o \
            $(OBJP)/Utility.o $(OBJP)/Commodities.o $(OBJP)/Gadtools.o

AOPTS     = -Fhunk -esc -sc \
			-I $(INCP) -I ${AMIGA_NDK}/Include/include_i/
LOPTS     = -bamigahunk -mrel -s \
			-L ${AMIGA_NDK}/Include/linker_libs/ -l debug -l amiga

ASM       = vasmm68k_mot
LINK      = vlink

.PHONY : all clean release check

all: $(OBJP) $(OBJP)/PatchWork

clean:
	rm -rf $(OBJP) $(RELP)

release: clean all
	cp -r $(DSTP) $(RELP)				# Create base structure and static files
	mkdir $(RELP)/PatchWork

	cp $(OBJP)/PatchWork $(RELP)/PatchWork/			# Tools

	cp $(DOCP)/PatchWork.guide $(RELP)/PatchWork/	# Docs
	cp LICENSE.txt $(RELP)/PatchWork/

	rm -f $(OBJP)/PatchWork.lha						# Package
	cd $(RELP) ; lha c -q1 ../$(OBJP)/PatchWork.lha *
	mv $(OBJP)/PatchWork.lha $(RELP)/
	cp $(DOCP)/PatchWork.readme $(RELP)/

check:
	# Check for umlauts and other characters that are not platform neutral.
	# The following command will show the files and lines, and highlight the
	# illegal character. It should be replaced with an escape sequence.
	LC_ALL=C grep -R --color='auto' -P -n "[^\x00-\x7F]" $(SRCP) ; true

$(OBJP):
	mkdir -p $(OBJP)

$(OBJP)/PatchWork: $(OBJS)
	$(LINK) $(LOPTS) -o $(OBJP)/PatchWork -s $(OBJS)

$(OBJP)/%.o: $(SRCP)/%.s $(SRCP)/PatchWork.i $(SRCP)/PatchWork_rev.i
	$(ASM) $(AOPTS) -o $@ $<
