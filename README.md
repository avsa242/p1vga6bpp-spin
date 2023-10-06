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
* graphics.common.spinh (provided by spin-standard-library)
* 19.2k RAM for the display buffer (double-buffering not possible)
* `-D_PASM_` must be defined on the build commandline

## Compiler Compatibility

| Processor | Language | Compiler               | Backend     | Status                |
|-----------|----------|------------------------|-------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.5.0)       | Bytecode    | OK                    |
| P1        | SPIN1    | FlexSpin (6.5.0)       | Native code | OK                    |

(other versions or toolchains not listed are not supported, and _may or may not_ work)


## Limitations

* Very early in development - may malfunction, or outright fail to build
* No ability to adjust video timings from outside the engine

