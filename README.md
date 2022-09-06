# p1vga6bpp-spin
----------------

This is a P8X32A/Propeller VGA 6bpp display engine

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A). Please install the library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* Integration with generic bitmap graphics library
* 160x120 resolution, 6bpp color
* Optional wait for VSync signal

## Requirements

P1/SPIN1:
* spin-standard-library
* 1 extra core/cog for the PASM display engine
* lib.gfx.bitmap.spin (provided by spin-standard-library)
* 19.2k RAM for the display buffer (double-buffering not possible)
* `-D_PASM_` must be defined on the build commandline

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (5.9.14-beta) | Native code | OK                    |
| P1        | SPIN1    | OpenSpin (1.00.81)     | Bytecode    | Untested (deprecated) |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | NuCode      | Unsupported           |
| P2        | SPIN2    | FlexSpin (5.9.14-beta) | Native code | Unsupported           |
| P1        | SPIN1    | Brad's Spin Tool (any) | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | Propeller Tool (any)   | Bytecode    | Unsupported           |
| P1, P2    | SPIN1, 2 | PNut (any)             | Bytecode    | Unsupported           |

## Limitations

* Very early in development - may malfunction, or outright fail to build
* No ability to adjust video timings from outside the engine

