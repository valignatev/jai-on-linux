//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



XKB_KEYCODE_INVALID :: 0xffffffff;
XKB_LAYOUT_INVALID :: 0xffffffff;
XKB_LEVEL_INVALID :: 0xffffffff;
XKB_MOD_INVALID :: 0xffffffff;
XKB_LED_INVALID :: 0xffffffff;

XKB_KEYCODE_MAX :: 0xffffffff - 1;

XKB_KEYSYM_MAX :: 0x1fffffff;

xkb_context :: struct {}

xkb_keymap :: struct {}

xkb_state :: struct {}

xkb_keycode_t :: u32;

xkb_keysym_t :: u32;

xkb_layout_index_t :: u32;

xkb_layout_mask_t :: u32;

xkb_level_index_t :: u32;

xkb_mod_index_t :: u32;

xkb_mod_mask_t :: u32;

xkb_led_index_t :: u32;

xkb_led_mask_t :: u32;

xkb_rule_names :: struct {
    rules:   *u8;

    model:   *u8;

    layout:  *u8;

    variant: *u8;

    options: *u8;
}

xkb_keysym_flags :: enum u32 {
    NO_FLAGS         :: 0;
    CASE_INSENSITIVE :: 1;

    XKB_KEYSYM_NO_FLAGS         :: NO_FLAGS;
    XKB_KEYSYM_CASE_INSENSITIVE :: CASE_INSENSITIVE;
}

xkb_context_flags :: enum u32 {
    FLAGS             :: 0;
    DEFAULT_INCLUDES  :: 1;
    ENVIRONMENT_NAMES :: 2;
    SECURE_GETENV     :: 4;

    XKB_CONTEXT_NO_FLAGS             :: FLAGS;
    XKB_CONTEXT_NO_DEFAULT_INCLUDES  :: DEFAULT_INCLUDES;
    XKB_CONTEXT_NO_ENVIRONMENT_NAMES :: ENVIRONMENT_NAMES;
    XKB_CONTEXT_NO_SECURE_GETENV     :: SECURE_GETENV;
}

xkb_log_level :: enum u32 {
    CRITICAL :: 10;
    ERROR    :: 20;
    WARNING  :: 30;
    INFO     :: 40;
    DEBUG    :: 50;

    XKB_LOG_LEVEL_CRITICAL :: CRITICAL;
    XKB_LOG_LEVEL_ERROR    :: ERROR;
    XKB_LOG_LEVEL_WARNING  :: WARNING;
    XKB_LOG_LEVEL_INFO     :: INFO;
    XKB_LOG_LEVEL_DEBUG    :: DEBUG;
}

xkb_keymap_compile_flags :: enum u32 {
    XKB_KEYMAP_COMPILE_NO_FLAGS :: 0;
}

xkb_keymap_format :: enum u32 {
    XKB_KEYMAP_FORMAT_TEXT_V1 :: 1;
}

xkb_keymap_key_iter_t :: #type (keymap: *xkb_keymap, key: xkb_keycode_t, data: *void) -> void #c_call;

xkb_key_direction :: enum u32 {
    UP   :: 0;
    DOWN :: 1;

    XKB_KEY_UP   :: UP;
    XKB_KEY_DOWN :: DOWN;
}

xkb_state_component :: enum u32 {
    MODS_DEPRESSED   :: 1;
    MODS_LATCHED     :: 2;
    MODS_LOCKED      :: 4;
    MODS_EFFECTIVE   :: 8;
    LAYOUT_DEPRESSED :: 16;
    LAYOUT_LATCHED   :: 32;
    LAYOUT_LOCKED    :: 64;
    LAYOUT_EFFECTIVE :: 128;
    LEDS             :: 256;

    XKB_STATE_MODS_DEPRESSED   :: MODS_DEPRESSED;
    XKB_STATE_MODS_LATCHED     :: MODS_LATCHED;
    XKB_STATE_MODS_LOCKED      :: MODS_LOCKED;
    XKB_STATE_MODS_EFFECTIVE   :: MODS_EFFECTIVE;
    XKB_STATE_LAYOUT_DEPRESSED :: LAYOUT_DEPRESSED;
    XKB_STATE_LAYOUT_LATCHED   :: LAYOUT_LATCHED;
    XKB_STATE_LAYOUT_LOCKED    :: LAYOUT_LOCKED;
    XKB_STATE_LAYOUT_EFFECTIVE :: LAYOUT_EFFECTIVE;
    XKB_STATE_LEDS             :: LEDS;
}

xkb_state_match :: enum u32 {
    ANY           :: 1;
    ALL           :: 2;
    NON_EXCLUSIVE :: 65536;

    XKB_STATE_MATCH_ANY           :: ANY;
    XKB_STATE_MATCH_ALL           :: ALL;
    XKB_STATE_MATCH_NON_EXCLUSIVE :: NON_EXCLUSIVE;
}

xkb_consumed_mode :: enum u32 {
    XKB :: 0;
    GTK :: 1;

    XKB_CONSUMED_MODE_XKB :: XKB;
    XKB_CONSUMED_MODE_GTK :: GTK;
}

XKB_Common_Procs :: struct #type_info_procedures_are_void_pointers {
    xkb_keysym_get_name:                     #type (keysym: xkb_keysym_t, buffer: *u8, size: u64) -> s32 #c_call;
    xkb_keysym_from_name:                    #type (name: *u8, flags: xkb_keysym_flags) -> xkb_keysym_t #c_call;
    xkb_keysym_to_utf8:                      #type (keysym: xkb_keysym_t, buffer: *u8, size: u64) -> s32 #c_call;
    xkb_keysym_to_utf32:                     #type (keysym: xkb_keysym_t) -> u32 #c_call;
    xkb_utf32_to_keysym:                     #type (ucs: u32) -> xkb_keysym_t #c_call;
    xkb_keysym_to_upper:                     #type (ks: xkb_keysym_t) -> xkb_keysym_t #c_call;
    xkb_keysym_to_lower:                     #type (ks: xkb_keysym_t) -> xkb_keysym_t #c_call;
    xkb_context_new:                         #type (flags: xkb_context_flags) -> *xkb_context #c_call;
    xkb_context_ref:                         #type (_context: *xkb_context) -> *xkb_context #c_call;
    xkb_context_unref:                       #type (_context: *xkb_context) -> void #c_call;
    xkb_context_set_user_data:               #type (_context: *xkb_context, user_data: *void) -> void #c_call;
    xkb_context_get_user_data:               #type (_context: *xkb_context) -> *void #c_call;
    xkb_context_include_path_append:         #type (_context: *xkb_context, path: *u8) -> s32 #c_call;
    xkb_context_include_path_append_default: #type (_context: *xkb_context) -> s32 #c_call;
    xkb_context_include_path_reset_defaults: #type (_context: *xkb_context) -> s32 #c_call;
    xkb_context_include_path_clear:          #type (_context: *xkb_context) -> void #c_call;
    xkb_context_num_include_paths:           #type (_context: *xkb_context) -> u32 #c_call;
    xkb_context_include_path_get:            #type (_context: *xkb_context, index: u32) -> *u8 #c_call;
    xkb_context_set_log_level:               #type (_context: *xkb_context, level: xkb_log_level) -> void #c_call;
    xkb_context_get_log_level:               #type (_context: *xkb_context) -> xkb_log_level #c_call;
    xkb_context_set_log_verbosity:           #type (_context: *xkb_context, verbosity: s32) -> void #c_call;
    xkb_context_get_log_verbosity:           #type (_context: *xkb_context) -> s32 #c_call;
    xkb_context_set_log_fn:                  #type (_context: *xkb_context, log_fn: #type (_context: *xkb_context, level: xkb_log_level, format: *u8, args: *void) -> void #c_call) -> void #c_call;
    xkb_keymap_new_from_names:               #type (_context: *xkb_context, names: *xkb_rule_names, flags: xkb_keymap_compile_flags) -> *xkb_keymap #c_call;
    xkb_keymap_new_from_file:                #type (_context: *xkb_context, file: *FILE, format: xkb_keymap_format, flags: xkb_keymap_compile_flags) -> *xkb_keymap #c_call;
    xkb_keymap_new_from_string:              #type (_context: *xkb_context, _string: *u8, format: xkb_keymap_format, flags: xkb_keymap_compile_flags) -> *xkb_keymap #c_call;
    xkb_keymap_new_from_buffer:              #type (_context: *xkb_context, buffer: *u8, length: u64, format: xkb_keymap_format, flags: xkb_keymap_compile_flags) -> *xkb_keymap #c_call;
    xkb_keymap_ref:                          #type (keymap: *xkb_keymap) -> *xkb_keymap #c_call;
    xkb_keymap_unref:                        #type (keymap: *xkb_keymap) -> void #c_call;
    xkb_keymap_get_as_string:                #type (keymap: *xkb_keymap, format: xkb_keymap_format) -> *u8 #c_call;
    xkb_keymap_min_keycode:                  #type (keymap: *xkb_keymap) -> xkb_keycode_t #c_call;
    xkb_keymap_max_keycode:                  #type (keymap: *xkb_keymap) -> xkb_keycode_t #c_call;
    xkb_keymap_key_for_each:                 #type (keymap: *xkb_keymap, iter: xkb_keymap_key_iter_t, data: *void) -> void #c_call;
    xkb_keymap_key_get_name:                 #type (keymap: *xkb_keymap, key: xkb_keycode_t) -> *u8 #c_call;
    xkb_keymap_key_by_name:                  #type (keymap: *xkb_keymap, name: *u8) -> xkb_keycode_t #c_call;
    xkb_keymap_num_mods:                     #type (keymap: *xkb_keymap) -> xkb_mod_index_t #c_call;
    xkb_keymap_mod_get_name:                 #type (keymap: *xkb_keymap, idx: xkb_mod_index_t) -> *u8 #c_call;
    xkb_keymap_mod_get_index:                #type (keymap: *xkb_keymap, name: *u8) -> xkb_mod_index_t #c_call;
    xkb_keymap_num_layouts:                  #type (keymap: *xkb_keymap) -> xkb_layout_index_t #c_call;
    xkb_keymap_layout_get_name:              #type (keymap: *xkb_keymap, idx: xkb_layout_index_t) -> *u8 #c_call;
    xkb_keymap_layout_get_index:             #type (keymap: *xkb_keymap, name: *u8) -> xkb_layout_index_t #c_call;
    xkb_keymap_num_leds:                     #type (keymap: *xkb_keymap) -> xkb_led_index_t #c_call;
    xkb_keymap_led_get_name:                 #type (keymap: *xkb_keymap, idx: xkb_led_index_t) -> *u8 #c_call;
    xkb_keymap_led_get_index:                #type (keymap: *xkb_keymap, name: *u8) -> xkb_led_index_t #c_call;
    xkb_keymap_num_layouts_for_key:          #type (keymap: *xkb_keymap, key: xkb_keycode_t) -> xkb_layout_index_t #c_call;
    xkb_keymap_num_levels_for_key:           #type (keymap: *xkb_keymap, key: xkb_keycode_t, layout: xkb_layout_index_t) -> xkb_level_index_t #c_call;
    xkb_keymap_key_get_mods_for_level:       #type (keymap: *xkb_keymap, key: xkb_keycode_t, layout: xkb_layout_index_t, level: xkb_level_index_t, masks_out: *xkb_mod_mask_t, masks_size: u64) -> u64 #c_call;
    xkb_keymap_key_get_syms_by_level:        #type (keymap: *xkb_keymap, key: xkb_keycode_t, layout: xkb_layout_index_t, level: xkb_level_index_t, syms_out: **xkb_keysym_t) -> s32 #c_call;
    xkb_keymap_key_repeats:                  #type (keymap: *xkb_keymap, key: xkb_keycode_t) -> s32 #c_call;
    xkb_state_new:                           #type (keymap: *xkb_keymap) -> *xkb_state #c_call;
    xkb_state_ref:                           #type (state: *xkb_state) -> *xkb_state #c_call;
    xkb_state_unref:                         #type (state: *xkb_state) -> void #c_call;
    xkb_state_get_keymap:                    #type (state: *xkb_state) -> *xkb_keymap #c_call;
    xkb_state_update_key:                    #type (state: *xkb_state, key: xkb_keycode_t, direction: xkb_key_direction) -> xkb_state_component #c_call;
    xkb_state_update_mask:                   #type (state: *xkb_state, depressed_mods: xkb_mod_mask_t, latched_mods: xkb_mod_mask_t, locked_mods: xkb_mod_mask_t, depressed_layout: xkb_layout_index_t, latched_layout: xkb_layout_index_t, locked_layout: xkb_layout_index_t) -> xkb_state_component #c_call;
    xkb_state_key_get_syms:                  #type (state: *xkb_state, key: xkb_keycode_t, syms_out: **xkb_keysym_t) -> s32 #c_call;
    xkb_state_key_get_utf8:                  #type (state: *xkb_state, key: xkb_keycode_t, buffer: *u8, size: u64) -> s32 #c_call;
    xkb_state_key_get_utf32:                 #type (state: *xkb_state, key: xkb_keycode_t) -> u32 #c_call;
    xkb_state_key_get_one_sym:               #type (state: *xkb_state, key: xkb_keycode_t) -> xkb_keysym_t #c_call;
    xkb_state_key_get_layout:                #type (state: *xkb_state, key: xkb_keycode_t) -> xkb_layout_index_t #c_call;
    xkb_state_key_get_level:                 #type (state: *xkb_state, key: xkb_keycode_t, layout: xkb_layout_index_t) -> xkb_level_index_t #c_call;
    xkb_state_serialize_mods:                #type (state: *xkb_state, components: xkb_state_component) -> xkb_mod_mask_t #c_call;
    xkb_state_serialize_layout:              #type (state: *xkb_state, components: xkb_state_component) -> xkb_layout_index_t #c_call;
    xkb_state_mod_name_is_active:            #type (state: *xkb_state, name: *u8, type: xkb_state_component) -> s32 #c_call;
    xkb_state_mod_names_are_active:          #type (state: *xkb_state, type: xkb_state_component, match: xkb_state_match, __args: ..Any) -> s32 #c_call;
    xkb_state_mod_index_is_active:           #type (state: *xkb_state, idx: xkb_mod_index_t, type: xkb_state_component) -> s32 #c_call;
    xkb_state_mod_indices_are_active:        #type (state: *xkb_state, type: xkb_state_component, match: xkb_state_match, __args: ..Any) -> s32 #c_call;
    xkb_state_key_get_consumed_mods2:        #type (state: *xkb_state, key: xkb_keycode_t, mode: xkb_consumed_mode) -> xkb_mod_mask_t #c_call;
    xkb_state_key_get_consumed_mods:         #type (state: *xkb_state, key: xkb_keycode_t) -> xkb_mod_mask_t #c_call;
    xkb_state_mod_index_is_consumed2:        #type (state: *xkb_state, key: xkb_keycode_t, idx: xkb_mod_index_t, mode: xkb_consumed_mode) -> s32 #c_call;
    xkb_state_mod_index_is_consumed:         #type (state: *xkb_state, key: xkb_keycode_t, idx: xkb_mod_index_t) -> s32 #c_call;
    xkb_state_mod_mask_remove_consumed:      #type (state: *xkb_state, key: xkb_keycode_t, mask: xkb_mod_mask_t) -> xkb_mod_mask_t #c_call;
    xkb_state_layout_name_is_active:         #type (state: *xkb_state, name: *u8, type: xkb_state_component) -> s32 #c_call;
    xkb_state_layout_index_is_active:        #type (state: *xkb_state, idx: xkb_layout_index_t, type: xkb_state_component) -> s32 #c_call;
    xkb_state_led_name_is_active:            #type (state: *xkb_state, name: *u8) -> s32 #c_call;
    xkb_state_led_index_is_active:           #type (state: *xkb_state, idx: xkb_led_index_t) -> s32 #c_call;
}

#scope_file

