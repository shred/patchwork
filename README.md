# PatchWork

PatchWork is an Amiga debugging tool like Enforcer or Mungwall. It patches library calls and validates the parameters against the AutoDocs. Illegal parameters (e.g. NULL where a pointer is expected) are reported. PatchWork helps you make your code more robust.

## Features

* Validates `commodities`, `dos`, `exec`, `gadtools`, `graphics`, `intuition` and `utility` library calls.
* Reports to the debugging console (e.g. Sushi).
* Shows a code extract of the violating code if [DisLib](http://aminet.net/package/util/libs/DisLib) by Thomas Richter is installed.
* 100% hand-made assembler code, so PatchWork only has a neglectable performance impact on your system.
* Works on any CPU, no MMU required.
* GPL licensed, open source.
* Source Code is available at [GitHub](https://github.com/shred/patchwork).

## Example Output

This is how a PatchWork hit looks like:

```
exec.library OldOpenLibrary("dos.library")
Severity 1: obsoleted, use OpenLibrary() instead
PC=08339720 TCB=08399D58 ("Shell Process")
Data: 00000001 020CE5C5 00004000 08350BA4 00000001 00000001 020CFF85 08339714
Addr: 08350BA4 08339732 08014E0C 08339714 084F3C08 00F92D70 0800083C 084F3BFC
----> 08339732 - "pwtest"  Hunk 0000, Offset 0000001A
----> 00F92D70 - "ROM - dos 39.23 (8.9.92)"  Hunk 0000, Offset 00000314
PC-8: 00000000 00000000 0833653C 00000000 00000030 00000000 43FA0018 2C780004
PC *: 4EAEFE68 22402C78 00044EAE FE627000 4E75646F 732E6C69 62726172 79004E71
Stck: 084F3BFC 08339724 00F9359C 00004000 0839A74C 08533B40 00001970 48E7303E
Stck: 24482649 61A66730 2C6A0018 206A0014 4EAEFF94 2848204B 610000B8 661C2449
----> 08339720 - "pwtest"  Hunk 0000, Offset 00000008
----> 08339724 - "pwtest"  Hunk 0000, Offset 0000000C
----> 00F9359C - "ROM - dos 39.23 (8.9.92)"  Hunk 0000, Offset 00000B40
```

## License

`PatchWork` is distributed under GPLv3 ([Gnu Public License](http://www.gnu.org/licenses/gpl.html)).
