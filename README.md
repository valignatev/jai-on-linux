# Jai on Linux
Quality of life things to make writing jai programs for linux easier. For now mostly X11-adjacent bindings and helpers. This readme is constantly under construction, so feel free to look into `generated` dir and into `generate.jai` to see what's going on and what is provided

## Bindings to C libraries
Bindinds to xcb, xkbcommon and so on. Look at `generated` to see what we have there.

They come in two flavors:
1) libname.jai - a version that will make Jai link the library

2) libname_fp.jai - a version that will not link the library, but you will have to load function pointers yourself (hence _fp suffix). This is helpful when you want to ship a binary that supports both X11 and Wayland, but you don't want user's computer to necessarily have both installed in order for the program to run at all.

See `xcb_simple.jai`


## TODO

- [ ] xcb-based XDND implementation for dragndrop
- [ ] xcb-based clipboard handling
- [x] XInput for smooth scrolling and gestures (libxcb-xinput bindings)
- [x] xkbcommon for keyboard handling (libxkbcommon bindings)
- [ ] EGL for graphics
- [ ] WM hints for icons and stuff like that
- [x] libxcb-cursor
- [ ] Wayland stuff (sigh)
- [ ] Generate X11 extensions directly from xcbproto without relying on shared libs


## Wishlist
I'd like to be able to rawdog the X11 wire and don't require linking or loading any C libraries at all, but I'm not sure if it's feasible at the moment considering that a lot of useful things do require xcb connection. For example, libxkbcommon and graphics stuff. Not sure if it's possible to substitute it with something else.
