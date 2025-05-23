//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



XCB_ICCCM_NUM_WM_SIZE_HINTS_ELEMENTS :: 18;

XCB_ICCCM_NUM_WM_HINTS_ELEMENTS :: 9;

/**
* @brief TextProperty reply structure.
*/
xcb_icccm_get_text_property_reply_t :: struct {
    /** Store reply to avoid memory allocation, should normally not be
    used directly */
    _reply:   *xcb_get_property_reply_t;

    /** Encoding used */
    encoding: xcb_atom_t;

    /** Length of the name field above */
    name_len: u32;

    /** Property value */
    name:     *u8;

    /** Format, may be 8, 16 or 32 */
    format:   u8;
}

/**
* @brief Deliver a GetProperty request to the X server.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param property Property atom to get.
* @return The request cookie.
*
* Allow to get a window property, in most case you might want to use
* above functions to get an ICCCM property for a given window.
*/
xcb_icccm_get_text_property :: (c: *xcb_connection_t, window: xcb_window_t, property: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_text_property()
*/
xcb_icccm_get_text_property_unchecked :: (c: *xcb_connection_t, window: xcb_window_t, property: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the property value of a window.
* @param c The connection to the X server.
* @param cookie TextProperty request cookie.
* @param prop TextProperty reply which is to be filled.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* If the function return 0 (failure), the content of prop is unmodified and
* therefore the structure must not be wiped.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_text_property_unchecked() is used.  Otherwise, it stores
* the error if any.  prop structure members should be freed by
* xcb_icccm_get_text_property_reply_wipe().
*/
xcb_icccm_get_text_property_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, prop: *xcb_icccm_get_text_property_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Wipe prop structure members previously allocated by
*        xcb_icccm_get_text_property_reply().
* @param prop prop structure whose members is going to be freed.
*/
xcb_icccm_get_text_property_reply_wipe :: (prop: *xcb_icccm_get_text_property_reply_t) -> void #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_NAME property value.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param encoding Encoding used for the data passed in the name parameter, the set property will also have this encoding as its type.
* @param format Encoding format.
* @param name_len Length of name value to set.
* @param name Name value to set.
*/
xcb_icccm_set_wm_name_checked :: (c: *xcb_connection_t, window: xcb_window_t, encoding: xcb_atom_t, format: u8, name_len: u32, name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_name_checked()
*/
xcb_icccm_set_wm_name :: (c: *xcb_connection_t, window: xcb_window_t, encoding: xcb_atom_t, format: u8, name_len: u32, name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Deliver a GetProperty request to the X server for WM_NAME.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_name :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_name()
*/
xcb_icccm_get_wm_name_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_NAME property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param prop WM_NAME property value.
* @param e Error if any.
* @see xcb_icccm_get_text_property_reply()
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_name_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, prop: *xcb_icccm_get_text_property_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_ICON_NAME property value.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param encoding Encoding used for the data passed in the name parameter, the set property will also have this encoding as its type.
* @param format Encoding format.
* @param name_len Length of name value to set.
* @param name Name value to set.
*/
xcb_icccm_set_wm_icon_name_checked :: (c: *xcb_connection_t, window: xcb_window_t, encoding: xcb_atom_t, format: u8, name_len: u32, name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_icon_name_checked()
*/
xcb_icccm_set_wm_icon_name :: (c: *xcb_connection_t, window: xcb_window_t, encoding: xcb_atom_t, format: u8, name_len: u32, name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Send request to get WM_ICON_NAME property of a window.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_icon_name :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_icon_name()
*/
xcb_icccm_get_wm_icon_name_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_ICON_NAME property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param prop WM_ICON_NAME property value.
* @param e Error if any.
* @see xcb_icccm_get_text_property_reply()
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_icon_name_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, prop: *xcb_icccm_get_text_property_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Deliver a ChangeProperty request to set WM_COLORMAP_WINDOWS property value.
* @param c The connection to the X server.
* @param wm_colormap_windows The WM_COLORMAP_WINDOWS atom
* @param window Window X identifier.
* @param list_len Windows list len.
* @param list Windows list.
* @return The request cookie.
*/
xcb_icccm_set_wm_colormap_windows_checked :: (c: *xcb_connection_t, window: xcb_window_t, wm_colormap_windows_atom: xcb_atom_t, list_len: u32, list: *xcb_window_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_colormap_windows_checked()
*/
xcb_icccm_set_wm_colormap_windows :: (c: *xcb_connection_t, window: xcb_window_t, wm_colormap_windows_atom: xcb_atom_t, list_len: u32, list: *xcb_window_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief WM_COLORMAP_WINDOWS structure.
*/
xcb_icccm_get_wm_colormap_windows_reply_t :: struct {
    /** Length of the windows list */
    windows_len: u32;

    /** Windows list */
    windows:     *xcb_window_t;

    /** Store reply to avoid memory allocation, should normally not be
    used directly */
    _reply:      *xcb_get_property_reply_t;
}

/**
* @brief Send request to get WM_COLORMAP_WINDOWS property of a given window.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_colormap_windows :: (c: *xcb_connection_t, window: xcb_window_t, wm_colormap_windows_atom: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_colormap_windows()
*/
xcb_icccm_get_wm_colormap_windows_unchecked :: (c: *xcb_connection_t, window: xcb_window_t, wm_colormap_windows_atom: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill the given structure with the WM_COLORMAP_WINDOWS property of a window.
* @param reply The reply of the GetProperty request.
* @param colormap_windows WM_COLORMAP property value.
* @return Return 1 on success, 0 otherwise.
*
* protocols structure members should be freed by
* xcb_icccm_get_wm_protocols_reply_wipe().
*/
xcb_icccm_get_wm_colormap_windows_from_reply :: (reply: *xcb_get_property_reply_t, colormap_windows: *xcb_icccm_get_wm_colormap_windows_reply_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Fill the given structure with the WM_COLORMAP_WINDOWS property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param protocols WM_COLORMAP_WINDOWS property value.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_colormap_windows_unchecked() is used.  Otherwise, it
* stores the error if any. protocols structure members should be
* freed by xcb_icccm_get_wm_colormap_windows_reply_wipe().
*/
xcb_icccm_get_wm_colormap_windows_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, windows: *xcb_icccm_get_wm_colormap_windows_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Wipe protocols structure members previously allocated by
*        xcb_icccm_get_wm_colormap_windows_reply().
* @param windows windows structure whose members is going to be freed.
*/
xcb_icccm_get_wm_colormap_windows_reply_wipe :: (windows: *xcb_icccm_get_wm_colormap_windows_reply_t) -> void #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_CLIENT_MACHINE property value.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param encoding Encoding used for the data passed in the name parameter, the set property will also have this encoding as its type.
* @param format Encoding format.
* @param name_len Length of name value to set.
* @param name Name value to set.
*/
xcb_icccm_set_wm_client_machine_checked :: (c: *xcb_connection_t, window: xcb_window_t, encoding: xcb_atom_t, format: u8, name_len: u32, name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_client_machine_checked()
*/
xcb_icccm_set_wm_client_machine :: (c: *xcb_connection_t, window: xcb_window_t, encoding: xcb_atom_t, format: u8, name_len: u32, name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Send request to get WM_CLIENT_MACHINE property of a window.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_client_machine :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_client_machine()
*/
xcb_icccm_get_wm_client_machine_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_CLIENT_MACHINE property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param prop WM_CLIENT_MACHINE property value.
* @param e Error if any.
* @see xcb_icccm_get_text_property_reply()
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_client_machine_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, prop: *xcb_icccm_get_text_property_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_CLASS property value.
*
* WM_CLASS string is a concatenation of the instance and class name
* strings respectively (including null character).
*
* @param c The connection to the X server.
* @param window Window X identifier.
* @param class_len Length of WM_CLASS string.
* @param class_name WM_CLASS string.
* @return The request cookie.
*/
xcb_icccm_set_wm_class_checked :: (c: *xcb_connection_t, window: xcb_window_t, class_len: u32, class_name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_class_checked()
*/
xcb_icccm_set_wm_class :: (c: *xcb_connection_t, window: xcb_window_t, class_len: u32, class_name: *u8) -> xcb_void_cookie_t #foreign libxcb_icccm;

xcb_icccm_get_wm_class_reply_t :: struct {
    /** Instance name */
    instance_name: *u8;

    /** Class of application */
    class_name:    *u8;

    /** Store reply to avoid memory allocation, should normally not be
    used directly */
    _reply:        *xcb_get_property_reply_t;
}

/**
* @brief Deliver a GetProperty request to the X server for WM_CLASS.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_class :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_class()
*/
xcb_icccm_get_wm_class_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill give structure with the WM_CLASS property of a window.
* @param prop The property structure to fill.
* @param reply The property request reply.
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_class_from_reply :: (prop: *xcb_icccm_get_wm_class_reply_t, reply: *xcb_get_property_reply_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_CLASS property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param prop WM_CLASS property value.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_class_unchecked() is used.  Otherwise, it stores the
* error if any. prop structure members should be freed by
* xcb_icccm_get_wm_class_reply_wipe().
*/
xcb_icccm_get_wm_class_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, prop: *xcb_icccm_get_wm_class_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Wipe prop structure members previously allocated by
*        xcb_icccm_get_wm_class_reply().
* @param prop prop structure whose members is going to be freed.
*/
xcb_icccm_get_wm_class_reply_wipe :: (prop: *xcb_icccm_get_wm_class_reply_t) -> void #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_TRANSIENT_FOR property value.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param transient_for_window The WM_TRANSIENT_FOR window X identifier.
* @return The request cookie.
*/
xcb_icccm_set_wm_transient_for_checked :: (c: *xcb_connection_t, window: xcb_window_t, transient_for_window: xcb_window_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_transient_for
*/
xcb_icccm_set_wm_transient_for :: (c: *xcb_connection_t, window: xcb_window_t, transient_for_window: xcb_window_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Send request to get WM_TRANSIENT_FOR property of a window.
* @param c The connection to the X server
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_transient_for :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_transient_for_unchecked()
*/
xcb_icccm_get_wm_transient_for_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given window pointer with the WM_TRANSIENT_FOR property of a window.
* @param prop WM_TRANSIENT_FOR property value.
* @param reply The get property request reply.
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_transient_for_from_reply :: (prop: *xcb_window_t, reply: *xcb_get_property_reply_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_TRANSIENT_FOR property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param prop WM_TRANSIENT_FOR property value.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_transient_for_unchecked() is used.  Otherwise, it stores
* the error if any.
*/
xcb_icccm_get_wm_transient_for_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, prop: *xcb_window_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/* WM_SIZE_HINTS */
xcb_icccm_size_hints_flags_t :: enum u32 {
    US_POSITION   :: 1;
    US_SIZE       :: 2;
    P_POSITION    :: 4;
    P_SIZE        :: 8;
    P_MIN_SIZE    :: 16;
    P_MAX_SIZE    :: 32;
    P_RESIZE_INC  :: 64;
    P_ASPECT      :: 128;
    BASE_SIZE     :: 256;
    P_WIN_GRAVITY :: 512;

    XCB_ICCCM_SIZE_HINT_US_POSITION   :: US_POSITION;
    XCB_ICCCM_SIZE_HINT_US_SIZE       :: US_SIZE;
    XCB_ICCCM_SIZE_HINT_P_POSITION    :: P_POSITION;
    XCB_ICCCM_SIZE_HINT_P_SIZE        :: P_SIZE;
    XCB_ICCCM_SIZE_HINT_P_MIN_SIZE    :: P_MIN_SIZE;
    XCB_ICCCM_SIZE_HINT_P_MAX_SIZE    :: P_MAX_SIZE;
    XCB_ICCCM_SIZE_HINT_P_RESIZE_INC  :: P_RESIZE_INC;
    XCB_ICCCM_SIZE_HINT_P_ASPECT      :: P_ASPECT;
    XCB_ICCCM_SIZE_HINT_BASE_SIZE     :: BASE_SIZE;
    XCB_ICCCM_SIZE_HINT_P_WIN_GRAVITY :: P_WIN_GRAVITY;
}

/**
* @brief Size hints structure.
*/
xcb_size_hints_t :: struct {
    /** User specified flags */
    flags:          u32;

    /** User-specified position */
    x:              s32;
    /** User-specified position */
    y:              s32;

    /** User-specified size */
    width:          s32;
    /** User-specified size */
    height:         s32;

    /** Program-specified minimum size */
    min_width:      s32;
    /** Program-specified minimum size */
    min_height:     s32;

    /** Program-specified maximum size */
    max_width:      s32;
    /** Program-specified maximum size */
    max_height:     s32;

    /** Program-specified resize increments */
    width_inc:      s32;
    /** Program-specified resize increments */
    height_inc:     s32;

    /** Program-specified minimum aspect ratios */
    min_aspect_num: s32;
    /** Program-specified minimum aspect ratios */
    min_aspect_den: s32;

    /** Program-specified maximum aspect ratios */
    max_aspect_num: s32;
    /** Program-specified maximum aspect ratios */
    max_aspect_den: s32;

    /** Program-specified base size */
    base_width:     s32;
    /** Program-specified base size */
    base_height:    s32;

    /** Program-specified window gravity */
    win_gravity:    u32;
}

/**
* @brief Set size hints to a given position.
* @param hints SIZE_HINTS structure.
* @param user_specified Is the size user-specified?
* @param x The X position.
* @param y The Y position.
*/
xcb_icccm_size_hints_set_position :: (hints: *xcb_size_hints_t, user_specified: s32, x: s32, y: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given size.
* @param hints SIZE_HINTS structure.
* @param user_specified is the size user-specified?
* @param width The width.
* @param height The height.
*/
xcb_icccm_size_hints_set_size :: (hints: *xcb_size_hints_t, user_specified: s32, width: s32, height: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given minimum size.
* @param hints SIZE_HINTS structure.
* @param width The minimum width.
* @param height The minimum height.
*/
xcb_icccm_size_hints_set_min_size :: (hints: *xcb_size_hints_t, min_width: s32, min_height: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given maximum size.
* @param hints SIZE_HINTS structure.
* @param width The maximum width.
* @param height The maximum height.
*/
xcb_icccm_size_hints_set_max_size :: (hints: *xcb_size_hints_t, max_width: s32, max_height: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given resize increments.
* @param hints SIZE_HINTS structure.
* @param width The resize increments width.
* @param height The resize increments height.
*/
xcb_icccm_size_hints_set_resize_inc :: (hints: *xcb_size_hints_t, width_inc: s32, height_inc: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given aspect ratios.
* @param hints SIZE_HINTS structure.
* @param min_aspect_num The minimum aspect ratios for the width.
* @param min_aspect_den The minimum aspect ratios for the height.
* @param max_aspect_num The maximum aspect ratios for the width.
* @param max_aspect_den The maximum aspect ratios for the height.
*/
xcb_icccm_size_hints_set_aspect :: (hints: *xcb_size_hints_t, min_aspect_num: s32, min_aspect_den: s32, max_aspect_num: s32, max_aspect_den: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given base size.
* @param hints SIZE_HINTS structure.
* @param base_width Base width.
* @param base_height Base height.
*/
xcb_icccm_size_hints_set_base_size :: (hints: *xcb_size_hints_t, base_width: s32, base_height: s32) -> void #foreign libxcb_icccm;

/**
* @brief Set size hints to a given window gravity.
* @param hints SIZE_HINTS structure.
* @param win_gravity Window gravity value.
*/
xcb_icccm_size_hints_set_win_gravity :: (hints: *xcb_size_hints_t, win_gravity: xcb_gravity_t) -> void #foreign libxcb_icccm;

/**
* @brief Deliver a ChangeProperty request to set a value to a given property.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param property Property to set value for.
* @param hints Hints value to set.
*/
xcb_icccm_set_wm_size_hints_checked :: (c: *xcb_connection_t, window: xcb_window_t, property: xcb_atom_t, hints: *xcb_size_hints_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_size_hints_checked()
*/
xcb_icccm_set_wm_size_hints :: (c: *xcb_connection_t, window: xcb_window_t, property: xcb_atom_t, hints: *xcb_size_hints_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Send request to get size hints structure for the named property.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param property Specify the property name.
* @return The request cookie.
*/
xcb_icccm_get_wm_size_hints :: (c: *xcb_connection_t, window: xcb_window_t, property: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_size_hints()
*/
xcb_icccm_get_wm_size_hints_unchecked :: (c: *xcb_connection_t, window: xcb_window_t, property: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the size hints of the named property.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param hints Size hints structure.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_size_hints_unchecked() is used.  Otherwise, it stores
* the error if any. The returned pointer should be freed.
*/
xcb_icccm_get_wm_size_hints_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, hints: *xcb_size_hints_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Deliver a ChangeProperty request to set WM_NORMAL_HINTS property value.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param hints Hints value to set.
*/
xcb_icccm_set_wm_normal_hints_checked :: (c: *xcb_connection_t, window: xcb_window_t, hints: *xcb_size_hints_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_normal_hints_checked()
*/
xcb_icccm_set_wm_normal_hints :: (c: *xcb_connection_t, window: xcb_window_t, hints: *xcb_size_hints_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Send request to get WM_NORMAL_HINTS property of a window.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_normal_hints :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_normal_hints()
*/
xcb_icccm_get_wm_normal_hints_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_NORMAL_HINTS property of a window.
* @param hints WM_NORMAL_HINTS property value.
* @param reply The get property request reply.
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_size_hints_from_reply :: (hints: *xcb_size_hints_t, reply: *xcb_get_property_reply_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_NORMAL_HINTS property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param hints WM_NORMAL_HINTS property value.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_normal_hints_unchecked() is used.  Otherwise, it stores
* the error if any. The returned pointer should be freed.
*/
xcb_icccm_get_wm_normal_hints_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, hints: *xcb_size_hints_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief WM hints structure (may be extended in the future).
*/
xcb_icccm_wm_hints_t :: struct {
    /** Marks which fields in this structure are defined */
    flags:         s32;

    /** Does this application rely on the window manager to get keyboard
    input? */
    input:         u32;

    /** See below */
    initial_state: s32;

    /** Pixmap to be used as icon */
    icon_pixmap:   xcb_pixmap_t;

    /** Window to be used as icon */
    icon_window:   xcb_window_t;

    /** Initial position of icon */
    icon_x:        s32;
    /** Initial position of icon */
    icon_y:        s32;

    /** Icon mask bitmap */
    icon_mask:     xcb_pixmap_t;

    /* Identifier of related window group */
    window_group:  xcb_window_t;
}

/**
* @brief WM_HINTS window states.
*/
xcb_icccm_wm_state_t :: enum u32 {
    WITHDRAWN :: 0;
    NORMAL    :: 1;
    ICONIC    :: 3;

    XCB_ICCCM_WM_STATE_WITHDRAWN :: WITHDRAWN;
    XCB_ICCCM_WM_STATE_NORMAL    :: NORMAL;
    XCB_ICCCM_WM_STATE_ICONIC    :: ICONIC;
}

xcb_icccm_wm_t :: enum u32 {
    INPUT         :: 1;
    STATE         :: 2;
    ICON_PIXMAP   :: 4;
    ICON_WINDOW   :: 8;
    ICON_POSITION :: 16;
    ICON_MASK     :: 32;
    WINDOW_GROUP  :: 64;
    X_URGENCY     :: 256;

    XCB_ICCCM_WM_HINT_INPUT         :: INPUT;
    XCB_ICCCM_WM_HINT_STATE         :: STATE;
    XCB_ICCCM_WM_HINT_ICON_PIXMAP   :: ICON_PIXMAP;
    XCB_ICCCM_WM_HINT_ICON_WINDOW   :: ICON_WINDOW;
    XCB_ICCCM_WM_HINT_ICON_POSITION :: ICON_POSITION;
    XCB_ICCCM_WM_HINT_ICON_MASK     :: ICON_MASK;
    XCB_ICCCM_WM_HINT_WINDOW_GROUP  :: WINDOW_GROUP;
    XCB_ICCCM_WM_HINT_X_URGENCY     :: X_URGENCY;
}

/**
* @brief Get urgency hint.
* @param hints WM_HINTS structure.
* @return Urgency hint value.
*/
xcb_icccm_wm_hints_get_urgency :: (hints: *xcb_icccm_wm_hints_t) -> u32 #foreign libxcb_icccm;

/**
* @brief Set input focus.
* @param hints WM_HINTS structure.
* @param input Input focus.
*/
xcb_icccm_wm_hints_set_input :: (hints: *xcb_icccm_wm_hints_t, input: u8) -> void #foreign libxcb_icccm;

/**
* @brief Set hints state to 'iconic'.
* @param hints WM_HINTS structure.
*/
xcb_icccm_wm_hints_set_iconic :: (hints: *xcb_icccm_wm_hints_t) -> void #foreign libxcb_icccm;

/**
* @brief Set hints state to 'normal'.
* @param hints WM_HINTS structure.
*/
xcb_icccm_wm_hints_set_normal :: (hints: *xcb_icccm_wm_hints_t) -> void #foreign libxcb_icccm;

/**
* @brief Set hints state to 'withdrawn'.
* @param hints WM_HINTS structure.
*/
xcb_icccm_wm_hints_set_withdrawn :: (hints: *xcb_icccm_wm_hints_t) -> void #foreign libxcb_icccm;

/**
* @brief Set hints state to none.
* @param hints WM_HINTS structure.
*/
xcb_icccm_wm_hints_set_none :: (hints: *xcb_icccm_wm_hints_t) -> void #foreign libxcb_icccm;

/**
* @brief Set pixmap to be used as icon.
* @param hints WM_HINTS structure.
* @param icon_pixmap Pixmap.
*/
xcb_icccm_wm_hints_set_icon_pixmap :: (hints: *xcb_icccm_wm_hints_t, icon_pixmap: xcb_pixmap_t) -> void #foreign libxcb_icccm;

/**
* @brief Set icon mask bitmap.
* @param hints WM_HINTS structure.
* @param icon_mask Pixmap.
*/
xcb_icccm_wm_hints_set_icon_mask :: (hints: *xcb_icccm_wm_hints_t, icon_mask: xcb_pixmap_t) -> void #foreign libxcb_icccm;

/**
* @brief Set window identifier to be used as icon.
* @param hints WM_HINTS structure.
* @param icon_window Window X identifier.
*/
xcb_icccm_wm_hints_set_icon_window :: (hints: *xcb_icccm_wm_hints_t, icon_window: xcb_window_t) -> void #foreign libxcb_icccm;

/**
* @brief Set identifier of related window group.
* @param hints WM_HINTS structure.
* @param window_group Window X identifier.
*/
xcb_icccm_wm_hints_set_window_group :: (hints: *xcb_icccm_wm_hints_t, window_group: xcb_window_t) -> void #foreign libxcb_icccm;

/**
* @brief Set urgency hints flag.
* @param hints WM_HINTS structure.
*/
xcb_icccm_wm_hints_set_urgency :: (hints: *xcb_icccm_wm_hints_t) -> void #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_HINTS property value.
* @param c The connection to the X server.
* @param window Window X identifier.
* @param hints Hints value to set.
*/
xcb_icccm_set_wm_hints_checked :: (c: *xcb_connection_t, window: xcb_window_t, hints: *xcb_icccm_wm_hints_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_hints_checked()
*/
xcb_icccm_set_wm_hints :: (c: *xcb_connection_t, window: xcb_window_t, hints: *xcb_icccm_wm_hints_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief Send request to get WM_HINTS property of a window.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_hints :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_hints()
*/
xcb_icccm_get_wm_hints_unchecked :: (c: *xcb_connection_t, window: xcb_window_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_HINTS property of a window.
* @param hints WM_HINTS property value.
* @param reply The get property request reply.
* @return Return 1 on success, 0 otherwise.
*/
xcb_icccm_get_wm_hints_from_reply :: (hints: *xcb_icccm_wm_hints_t, reply: *xcb_get_property_reply_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Fill given structure with the WM_HINTS property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param hints WM_HINTS property value.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_hints_unchecked() is used.  Otherwise, it stores the
* error if any. The returned pointer should be freed.
*/
xcb_icccm_get_wm_hints_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, hints: *xcb_icccm_wm_hints_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Deliver a SetProperty request to set WM_PROTOCOLS property value.
* @param c The connection to the X server.
* @param wm_protocols The WM_PROTOCOLS atom.
* @param window Window X identifier.
* @param list_len Atom list len.
* @param list Atom list.
*/
xcb_icccm_set_wm_protocols_checked :: (c: *xcb_connection_t, window: xcb_window_t, wm_protocols: xcb_atom_t, list_len: u32, list: *xcb_atom_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_set_wm_protocols_checked()
*/
xcb_icccm_set_wm_protocols :: (c: *xcb_connection_t, window: xcb_window_t, wm_protocols: xcb_atom_t, list_len: u32, list: *xcb_atom_t) -> xcb_void_cookie_t #foreign libxcb_icccm;

/**
* @brief WM_PROTOCOLS structure.
*/
xcb_icccm_get_wm_protocols_reply_t :: struct {
    /** Length of the atoms list */
    atoms_len: u32;

    /** Atoms list */
    atoms:     *xcb_atom_t;

    /** Store reply to avoid memory allocation, should normally not be
    used directly */
    _reply:    *xcb_get_property_reply_t;
}

/**
* @brief Send request to get WM_PROTOCOLS property of a given window.
* @param c The connection to the X server.
* @param window Window X identifier.
* @return The request cookie.
*/
xcb_icccm_get_wm_protocols :: (c: *xcb_connection_t, window: xcb_window_t, wm_protocol_atom: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @see xcb_icccm_get_wm_protocols()
*/
xcb_icccm_get_wm_protocols_unchecked :: (c: *xcb_connection_t, window: xcb_window_t, wm_protocol_atom: xcb_atom_t) -> xcb_get_property_cookie_t #foreign libxcb_icccm;

/**
* @brief Fill the given structure with the WM_PROTOCOLS property of a window.
* @param reply The reply of the GetProperty request.
* @param protocols WM_PROTOCOLS property value.
* @return Return 1 on success, 0 otherwise.
*
* protocols structure members should be freed by
* xcb_icccm_get_wm_protocols_reply_wipe().
*/
xcb_icccm_get_wm_protocols_from_reply :: (reply: *xcb_get_property_reply_t, protocols: *xcb_icccm_get_wm_protocols_reply_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Fill the given structure with the WM_PROTOCOLS property of a window.
* @param c The connection to the X server.
* @param cookie Request cookie.
* @param protocols WM_PROTOCOLS property value.
* @param e Error if any.
* @return Return 1 on success, 0 otherwise.
*
* The parameter e supplied to this function must be NULL if
* xcb_icccm_get_wm_protocols_unchecked() is used.  Otherwise, it stores the
* error if any. protocols structure members should be freed by
* xcb_icccm_get_wm_protocols_reply_wipe().
*/
xcb_icccm_get_wm_protocols_reply :: (c: *xcb_connection_t, cookie: xcb_get_property_cookie_t, protocols: *xcb_icccm_get_wm_protocols_reply_t, e: **xcb_generic_error_t) -> u8 #foreign libxcb_icccm;

/**
* @brief Wipe protocols structure members previously allocated by
*        xcb_icccm_get_wm_protocols_reply().
* @param protocols protocols structure whose members is going to be freed.
*/
xcb_icccm_get_wm_protocols_reply_wipe :: (protocols: *xcb_icccm_get_wm_protocols_reply_t) -> void #foreign libxcb_icccm;

#scope_file

libxcb_icccm :: #library,system "libxcb-icccm";
