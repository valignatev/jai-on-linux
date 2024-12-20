//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



XKB_X11_MIN_MAJOR_XKB_VERSION :: 1;

XKB_X11_MIN_MINOR_XKB_VERSION :: 0;

xkb_x11_setup_xkb_extension_flags :: enum u32 {
    XKB_X11_SETUP_XKB_EXTENSION_NO_FLAGS :: 0;
}

XKB_X11_Symbols :: struct #type_info_procedures_are_void_pointers {
    xkb_x11_setup_xkb_extension:         #type (connection: *xcb_connection_t, major_xkb_version: u16, minor_xkb_version: u16, flags: xkb_x11_setup_xkb_extension_flags, major_xkb_version_out: *u16, minor_xkb_version_out: *u16, base_event_out: *u8, base_error_out: *u8) -> s32 #c_call;
    xkb_x11_get_core_keyboard_device_id: #type (connection: *xcb_connection_t) -> s32 #c_call;
    xkb_x11_keymap_new_from_device:      #type (_context: *xkb_context, connection: *xcb_connection_t, device_id: s32, flags: xkb_keymap_compile_flags) -> *xkb_keymap #c_call;
    xkb_x11_state_new_from_device:       #type (keymap: *xkb_keymap, connection: *xcb_connection_t, device_id: s32) -> *xkb_state #c_call;
}

#scope_file

