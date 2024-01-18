## Helpers for GDB

This is just quality of life pretty printers for Jai types.
For now, custom formatter for array views (so `[]Type`) and `string`s.

## Installation
First, your GDB should be compiled with pythong support, and loading python scripts should be enabled.

I think all linux distros have GDB like that by default, so you don't need to do anything. Let me know if your setup is different so I maybe expand this README!

You will see two files here: `gdbinit` and `python_custom.py`. Drop `gdbinit` to `~/.config/gdb/` (or add lines from it to your gdbinit) and drop python file next to it.

This should be pretty much it. Here's screenshot from CLion's debugging session with GDB set as the backend:

![](gdb_qol.png?raw=true)
