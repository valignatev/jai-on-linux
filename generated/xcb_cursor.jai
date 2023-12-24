//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



xcb_cursor_context_t :: struct {}

xcb_cursor_context_new :: (conn: *xcb_connection_t, screen: *xcb_screen_t, ctx: **xcb_cursor_context_t) -> s32 #foreign libxcb_cursor;

xcb_cursor_load_cursor :: (ctx: *xcb_cursor_context_t, name: *u8) -> xcb_cursor_t #foreign libxcb_cursor;

xcb_cursor_context_free :: (ctx: *xcb_cursor_context_t) -> void #foreign libxcb_cursor;

#scope_file

libxcb_cursor :: #system_library "libxcb-cursor";
