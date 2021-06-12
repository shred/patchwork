# PatchWork

PatchWork is an Amiga debugging tool like MuForce or Mungwall. It patches library calls and validates the parameters against the AutoDocs. Illegal parameters (e.g. NULL where a pointer is expected) are reported. PatchWork helps you to make your code more robust.

## Features

* Validates `commodities`, `dos`, `exec`, `gadtools`, `graphics`, `intuition` and `utility` library calls.
* Reports to the debugging console (e.g. Sushi).
* Shows a code extract of the violating code if [DisLib](http://aminet.net/package/util/libs/DisLib) by Thomas Richter is installed.
* 100% hand-made assembler code, so PatchWork only has a neglectable performance impact on your system and can just be kept running.
* Works on any 68000 based CPU, no MMU required.
* GPL licensed, open source.
* Source Code is available at [GitHub](https://github.com/shred/patchwork).

## Example Output

This is how a full PatchWork hit with all options enabled looks like:

```
exec.library OldOpenLibrary("dos.library")
Severity 1: obsoleted, use OpenLibrary() instead
PC=07E9BCFC TCB=07BF34A0 ("Shell Process")
Data: FFFFFFFF 00000000 00000000 00000000 00000000 00000000 00000000 00000000
Addr: 07EA2A3A 07E9FF46 00000000 00000000 00000000 00000000 078007F8 07BF4510
----> 07EA2A3A - "pwtest"	Hunk 0001, Offset 00008A4A
----> 07E9FF46 - "pwtest"	Hunk 0001, Offset 00005F56
PC-8: 51CEFF22 4E7570FF 23C007EA 251E41FA 6D4E23C8 07EA2522 43FA4250 2C780004
PC *: 4EAEFE68 23C007EA 253A6100 7F886100 089A23C0 07EA266A 6700024C 203C0000
07e9bcdc :  51ce ff22                  dbra d6,$7e9bc00
07e9bce0 :  4e75                       rts
07e9bce2 :  70ff                       moveq.l #-$1,d0
07e9bce4 :  23c0 07ea 251e             move.l d0,$7ea251e
07e9bcea :  41fa 6d4e                  lea.l $7ea2a3a(pc),a0
07e9bcee :  23c8 07ea 2522             move.l a0,$7ea2522
07e9bcf4 :  43fa 4250                  lea.l $7e9ff46(pc),a1
07e9bcf8 :  2c78 0004                  movea.l $4.w,a6
07e9bcfc : *4eae fe68                  jsr -$198(a6)
07e9bd00 :  23c0 07ea 253a             move.l d0,$7ea253a
07e9bd06 :  6100 7f88                  bsr $7ea3c90
07e9bd0a :  6100 089a                  bsr $7e9c5a6
07e9bd0e :  23c0 07ea 266a             move.l d0,$7ea266a
07e9bd14 :  6700 024c                  beq $7e9bf62
07e9bd18 :  203c 0000 2800             move.l #$2800,d0
Stck: 07E9BD00 07BA246C 00000001 00F95C92 00000FA0 4D656761 20536F75 6E644372
Stck: 61636B65 72000000 07BF5E28 00000B48 02090909 05050500 00001111 114E4E4E
----> 07E9BCFC - "pwtest"	Hunk 0001, Offset 00001D0C
----> 07E9BD00 - "pwtest"	Hunk 0001, Offset 00001D10
----> 07BA246C - "pwtest"	Hunk 0000, Offset 0000000C
----> 00F95C92 - "ROM - dos 40.3 (1.4.93)"	Hunk 0000, Offset 000005AE
```

## Building from Source

This project is mainly made to be build on Linux machines. However, with a few modifications it can also be built on AmigaOS and other operating systems.

Requirements:

* [GNU make](http://www.gnu.org/software/make/) or another compatible make tool
* [vbcc](http://www.compilers.de/vbcc.html) (or just [vasm](http://sun.hasenbraten.de/vasm/) and [vlink](http://sun.hasenbraten.de/vlink/))
* [AmigaOS NDK 3.9](http://www.haage-partner.de/download/AmigaOS/NDK39.lha), unpacked on your build machine
* [disassembler.library](http://aminet.net/package/util/libs/DisLib) (the necessary include files are part of this project for your convenience)
* [lha](https://github.com/jca02266/lha)

Set the `AMIGA_NDK` env variable to the location of the unpacked `NDK_3.9` directory on your build machine.

Then just invoke `make` to build the project. The compiled project can be found in the `build` directory. `make release` will compile a release version in the `release` directory.

Today's standard encoding is UTF-8. Sadly AmigaOS does not support this encoding, so the files in this project have different encodings depending on their purpose. The assembler files must use plain ASCII encoding, so they can be edited on Linux and Amiga without encoding problems. For special characters in strings, always use escape sequences. Do not use special characters in comments. `make check` will test if these files contain illegal characters. All purely Amiga-related files (like AmigaGuide files) are expected to be ISO-8859-1 encoded. Then again, `README.md` (and other files related to the open source release) are UTF-8 encoded. If you are in doubt, use plain ASCII.

## Contribution and Release

The source code of this project can be found [at the official GitHub page](https://github.com/shred/patchwork).

If you found a bug or have a feature request, feel free to [open an issue](https://github.com/shred/patchwork/issues) or [send a pull request](https://github.com/shred/patchwork/pulls).

Official binaries are available [at the AmiNet](http://aminet.net/package/dev/debug/PatchWork).

**Please DO NOT UPLOAD new releases to this AmiNet project. If you want to release a fork, use a different project name.**

## License

`PatchWork` is distributed under GPLv3 ([Gnu Public License](http://www.gnu.org/licenses/gpl.html)).
