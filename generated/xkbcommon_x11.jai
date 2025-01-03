//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



XKB_X11_MIN_MAJOR_XKB_VERSION :: 1;

XKB_X11_MIN_MINOR_XKB_VERSION :: 0;

/** Flags for the xkb_x11_setup_xkb_extension() function. */
xkb_x11_setup_xkb_extension_flags :: enum u32 {
    XKB_X11_SETUP_XKB_EXTENSION_NO_FLAGS :: 0;
}

/**
* Setup the XKB X11 extension for this X client.
*
* The xkbcommon-x11 library uses various XKB requests.  Before doing so,
* an X client must notify the server that it will be using the extension.
* This function (or an XCB equivalent) must be called before any other
* function in this library is used.
*
* Some X servers may not support or disable the XKB extension.  If you
* want to support such servers, you need to use a different fallback.
*
* You may call this function several times; it is idempotent.
*
* @param connection
*     An XCB connection to the X server.
* @param major_xkb_version
*     See @p minor_xkb_version.
* @param minor_xkb_version
*     The XKB extension version to request.  To operate correctly, you
*     must have (major_xkb_version, minor_xkb_version) >=
*     (XKB_X11_MIN_MAJOR_XKB_VERSION, XKB_X11_MIN_MINOR_XKB_VERSION),
*     though this is not enforced.
* @param flags
*     Optional flags, or 0.
* @param[out] major_xkb_version_out
*     See @p minor_xkb_version_out.
* @param[out] minor_xkb_version_out
*     Backfilled with the compatible XKB extension version numbers picked
*     by the server.  Can be NULL.
* @param[out] base_event_out
*     Backfilled with the XKB base (also known as first) event code, needed
*     to distinguish XKB events.  Can be NULL.
* @param[out] base_error_out
*     Backfilled with the XKB base (also known as first) error code, needed
*     to distinguish XKB errors.  Can be NULL.
*
* @returns 1 on success, or 0 on failure.
*/
xkb_x11_setup_xkb_extension :: (connection: *xcb_connection_t, major_xkb_version: u16, minor_xkb_version: u16, flags: xkb_x11_setup_xkb_extension_flags, major_xkb_version_out: *u16, minor_xkb_version_out: *u16, base_event_out: *u8, base_error_out: *u8) -> s32 #foreign libxkbcommon_x11;

/**
* Get the keyboard device ID of the core X11 keyboard.
*
* @param connection An XCB connection to the X server.
*
* @returns A device ID which may be used with other xkb_x11_* functions,
*          or -1 on failure.
*/
xkb_x11_get_core_keyboard_device_id :: (connection: *xcb_connection_t) -> s32 #foreign libxkbcommon_x11;

/**
* Create a keymap from an X11 keyboard device.
*
* This function queries the X server with various requests, fetches the
* details of the active keymap on a keyboard device, and creates an
* xkb_keymap from these details.
*
* @param context
*     The context in which to create the keymap.
* @param connection
*     An XCB connection to the X server.
* @param device_id
*     An XInput device ID (in the range 0-127) with input class KEY.
*     Passing values outside of this range is an error (the XKB protocol
*     predates the XInput2 protocol, which first allowed IDs > 127).
* @param flags
*     Optional flags for the keymap, or 0.
*
* @returns A keymap retrieved from the X server, or NULL on failure.
*
* @memberof xkb_keymap
*/
xkb_x11_keymap_new_from_device :: (_context: *xkb_context, connection: *xcb_connection_t, device_id: s32, flags: xkb_keymap_compile_flags) -> *xkb_keymap #foreign libxkbcommon_x11;

/**
* Create a new keyboard state object from an X11 keyboard device.
*
* This function is the same as xkb_state_new(), only pre-initialized
* with the state of the device at the time this function is called.
*
* @param keymap
*     The keymap for which to create the state.
* @param connection
*     An XCB connection to the X server.
* @param device_id
*     An XInput 1 device ID (in the range 0-255) with input class KEY.
*     Passing values outside of this range is an error.
*
* @returns A new keyboard state object, or NULL on failure.
*
* @memberof xkb_state
*/
xkb_x11_state_new_from_device :: (keymap: *xkb_keymap, connection: *xcb_connection_t, device_id: s32) -> *xkb_state #foreign libxkbcommon_x11;

#scope_file

libxkbcommon_x11 :: #library,system "libxkbcommon-x11";
