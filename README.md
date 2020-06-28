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
* 19.2k RAM for the display buffer (double-buffering not possible)

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* No ability to adjust video timings from outside the engine

## TODO

- [ ] Make it possible to adjust video timings
