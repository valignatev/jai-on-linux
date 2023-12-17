# Jai on Linux
For now it's just glorified xcb bindings for Jai programming language, but I want to have a bunch of things here that would give more qualiti of life things for Linux programming. 


## X11
For now this repo has bindings to libxcb, libxcb-image and libxcb-shm (bundled with libxcb-image).

They come in two flavors:
1) libname.jai - a version that will make Jai link the library

2) libname-dynamic.jai - a version that will not link the library, but you will have to load function pointers yourself. This is helpful when you want to ship a binary that supports both X11 and Wayland, but you don't want user's computer to necessarily have both installed in order for the program to run at all.

See `xcb_example.jai`


## TODO

- [ ] xcb-based XDND implementation for dragndrop
- [ ] XInput for smooth scrolling and gestures
- [ ] xkbcommon for keyboard handling
- [ ] EGL for graphics
- [ ] WM hints for icons and stuff like that
- [ ] xcb-based clipboard hangling
- [ ] libxcb-cursor
- [ ] Wayland stuff (sigh)


## Wishlist
I'd like to be able to rawdog the X11 wire and don't require linking or loading any C libraries at all, but I'm not sure if it's feasible at the moment considering that a lot of useful things do require xcb connection. For example, libxkbcommon and graphics stuff. Not sure if it's possible to substitute it with something else.
