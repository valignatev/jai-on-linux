# Jai on Linux
Quality of life things to make writing jai programs for linux easier. This readme is constantly under construction, so feel free to look into `generated` dir and into `generate.jai` to see what's going on and what is provided.

## GDB helpers
Pretty printers for strings and Jai arrays when debugging with GDB

## Bindings to C libraries
Bindinds to commonly used stuff. Linux system headers, X11 etc etc.  Look at `generated` to see what we have there.

Some of them come in two flavors:
1) libname.jai - a version that will make Jai link the library

2) libname_fp.jai - a version that will not link the library, but you will have to load function pointers yourself (hence _fp suffix). This is helpful when you want to ship a binary that supports both X11 and Wayland, but you don't want user's computer to necessarily have both installed in order for the program to run at all.

## Examples
See `examples` directory.


## License
generate.jai and generated files are licensed under whatever license you want so you can use them in any way you wish.

Some C headers and static libs that are in this repo might have som particular licenses (all FOSS though). I haven't bothered including those in, but let me know if I should.

