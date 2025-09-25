// TODO: There are types that are enums in C headers but they're actually not,
// and we need to unroll them to avoid needless autocasts. For example,
// xcb_atom_enum_t enumerates built in atoms, but it's mostly useless as enum
// because all the interesting functions take xcb_atom_t which is just u32
// And we have to autocast this enum all over the place. We can put built in
// enums into global namespace, or put them into a struct rather than enum;
// Same with xcb_input_device_t from xinput. Those are just two reserved device ids,
// it's not really an enum. And they should be u16, not u32.
AT_COMPILE_TIME :: false;
PRESERVE_COMMENTS :: true;

Generate_For :: enum_flags {
    XCB;
    XCB_IMAGE;
    XKBCOMMON;
    XCB_XINPUT;
    XCB_XKB;
    XKB_X11;
    XCB_XCURSOR;
    XCB_SYNC;
    XCB_ICCCM;
    // This is not <sys/ioctl.h> (because that one is covered by built-in POSIX bindings)
    // This one is for macros from /usr/include/linux and /usr/include/asm-generic
    IOCTL;
    INPUT;
    UINPUT;
    LIBINPUT;
    LIBUDEV;
}

// Gives you Generate_For value that includes all of its flags combined.
GENERATE_FOR_ALL :: #run -> Generate_For {
    ti := type_info(Generate_For);
    all: Generate_For;
    for ti.names {
        all |= xx ti.values[it_index];
    }
    return all;
}
generate_for : Generate_For : GENERATE_FOR_ALL;

#if AT_COMPILE_TIME {
    #run {
        set_build_options_dc(.{do_output=false});
        if !generate_bindings() {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {
        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        if !generate_bindings() {
            exit(1);
        }
    }
}

#add_context symbols_struct_name := "";
generate_bindings :: () -> bool {
    init_tables();
    result := true;

    // xcb
    if generate_for & .XCB {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxcb.so", ""});
        // Enable if things start segfaulting or otherwise behave weirdly and
        // you suspect it's due to structs getting generated incorrectly
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;
        // Turn function definitions into type declarations that you can load at
        // runtime

        result = generate_bindings(opts, "generated/xcb.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_fp.jai");
        if !result return result;
    }

    // xcb-image
    if generate_for & .XCB_IMAGE{
        parent_struct_initted = false;
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb_image.h");

        // xcb_image includes shm.h and uses its types, you can include it right here
        // if you just want to inine its declarations
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "/usr/include/xcb/shm.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxcb-image.so", ""});
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xcb_image.jai");
        if !result return result;

        // TODO: seems like bindings generator eats this when it generates the bindings
        // once and on subsequent generations it doesn't have this info anymore.
        // Need to research
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "/usr/include/xcb/shm.h");
        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_Image_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_image_fp.jai");
        if !result return result;
    }

    // xinput
    if generate_for & .XCB_XINPUT {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "xinput.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxcb-xinput.so", ""});
        // Seems like that's the only type xinput.h uses from xfixes.
        // and it happens to be a u32 typedef. Sigh
        array_add(*opts.system_types_to_include, "xcb_xfixes_barrier_t");
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xcb_xinput.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_XInput_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_xinput_fp.jai");
        if !result return result;
    }

    // xcb-xkb
    if generate_for & .XCB_XKB {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "xkb.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxcb-xkb.so", ""});

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xcb_xkb.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_XKB_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_xkb_fp.jai");
        if !result return result;
    }

    // xcb-sync
    if generate_for & .XCB_SYNC {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "sync.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxcb-sync.so", ""});

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xcb_sync.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_Sync_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_sync_fp.jai");
        if !result return result;
    }

    // xkbcommon
    if generate_for & .XKBCOMMON {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xkbcommon/xkbcommon.h");
        array_add(*opts.source_files, "/usr/include/xkbcommon/xkbcommon-compose.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxkbcommon.so", ""});
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xkbcommon.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XKB_Common_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xkbcommon_fp.jai");
        if !result return result;
    }

    // xkbcommon-x11
    if generate_for & .XKB_X11 {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xkbcommon/xkbcommon-x11.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxkbcommon-x11.so", ""});

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xkbcommon_x11.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XKB_X11_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xkbcommon_x11_fp.jai");
        if !result return result;
    }

    // xcb-xcursor
    if generate_for & .XCB_XCURSOR {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb_cursor.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libxcb-cursor.so", ""});

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xcb_cursor.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_Cursor_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_cursor_fp.jai");
        if !result return result;
    }

    // xcb-icccm
    if generate_for & .XCB_ICCCM {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb_icccm.h");
        array_add(*opts.system_library_search_paths, "/usr/lib64");
        array_add(*opts.system_libraries, .{"libxcb-icccm.so", ""});

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = x11_visitor;

        result = generate_bindings(opts, "generated/xcb_icccm.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "XCB_ICCCM_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_icccm_fp.jai");
        if !result return result;
    }

    // ioctl macros
    if generate_for & (.IOCTL | .INPUT | .UINPUT) {
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/asm-generic/ioctl.h");
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = true;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        bindings_builder, success := generate_bindings(opts, log_results=false);
        if !success return success;

        cut_scope_file(*bindings_builder);
        ioctl_builder: String_Builder;
        append(*bindings_builder, IOC_MACROS);
        append_and_steal_buffers(*ioctl_builder, *bindings_builder);


        // Jai ships definitions in ioctls.h in its POSIX modules.
        // Remove the guard if you still want to have them generated into ioctl.jai!
        if false {
            opts.source_files[0] = "/usr/include/asm-generic/ioctls.h";
            opts.add_generator_command = false;
            bindings_builder, success = generate_bindings(opts, log_results=false);
            if !success return success;
            cut_scope_file(*bindings_builder);
            append_and_steal_buffers(*ioctl_builder, *bindings_builder);
        }

        append(*ioctl_builder, IOCTLS);

        opts.source_files[0] = "/usr/include/bits/ioctl-types.h";
        // In /usr/include/bits/ioctl-types.h, there's this part:
        // #ifndef _SYS_IOCTL_H
        // # error "Never use <bits/ioctls.h> directly; include <sys/ioctl.h> instead."
        // #endif
        // And libclang respects this #error directive and aborts. Since we only need types from this header,
        // we trick it to avoid the error.
        array_add(*opts.extra_clang_arguments, "-D _SYS_IOCTL_H");

        bindings_builder, success = generate_bindings(opts, log_results=true);
        if !success return success;
        append_and_steal_buffers(*ioctl_builder, *bindings_builder);

        filename := "generated/ioctl.jai";
        success = write_entire_file(filename, *ioctl_builder);
        if !success {
            log_error("Could not write generated output to \"%\"\n", filename);
            return false;
        }
        log("\nOK! generated '%'\n", filename);
    }

    // input.h
    if generate_for & (.INPUT | .UINPUT) {
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/linux/input.h");
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "linux/input.h");
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "linux/input-event-codes.h");

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = true;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        bindings_builder, success := generate_bindings(opts, log_results=true);
        if !success return success;

        input_builder: String_Builder;
        append(*input_builder, "#load \"./ioctl.jai\";\n\n");
        append_and_steal_buffers(*input_builder, *bindings_builder);

        cut_scope_file(*input_builder);
        append(*input_builder, INPUT_H_EVIO);

        filename := "generated/input.jai";
        success = write_entire_file(filename, *input_builder);
        if !success {
            log_error("Could not write generated output to \"%\"\n", filename);
            return false;
        }
        log("\nOK! generated '%'\n", filename);
    }

    // uinput.h
    if generate_for & .UINPUT {
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/linux/uinput.h");
        // array_add(*opts.path_fragments_to_treat_as_non_system_paths, "linux/types.h");

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = true;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        bindings_builder, success := generate_bindings(opts, log_results=true);
        if !success return success;

        uinput_builder: String_Builder;
        append(*uinput_builder, "#load \"./input.jai\";\n\n");
        append_and_steal_buffers(*uinput_builder, *bindings_builder);

        cut_scope_file(*uinput_builder);
        append(*uinput_builder, UINPUT);

        filename := "generated/uinput.jai";
        success = write_entire_file(filename, *uinput_builder);
        if !success {
            log_error("Could not write generated output to \"%\"\n", filename);
            return false;
        }
        log("\nOK! generated '%'\n", filename);
    }

    // libudev.h
    // TODO: translate udev_list_entry_foreach macro. This is the only macro in libudev as far as I can see.
    if generate_for & (.LIBINPUT | .LIBUDEV) {
        parent_struct_initted = false;
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/libudev.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libudev.so", ""});
        // TODO: maybe put this into #file_scope
        array_add(*opts.system_types_to_include, "dev_t");

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = libinput_udev_visitor;

        result = generate_bindings(opts, "generated/libudev.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "Libudev_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/libudev_fp.jai");
        if !result return result;
    }

    // libinput.h
    if generate_for & .LIBINPUT {
        parent_struct_initted = false;
        opts: Generate_Bindings_Options;
        opts.generated_library_path_prefix = "lib_";
        array_add(*opts.source_files, "/usr/include/libinput.h");
        array_add(*opts.system_library_search_paths, "/usr/lib");
        array_add(*opts.system_libraries, .{"libinput.so", ""});

        opts.visitor = libinput_udev_visitor;

        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        result = generate_bindings(opts, "generated/libinput.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.symbols_struct_name = "Libinput_Symbols";
        defer context.symbols_struct_name = "";

        result = generate_bindings(opts, "generated/libinput_fp.jai");
        if !result return result;
    }

    return result;
}

udev_names: Table(string, bool);

udev_name_occupied :: (name: string) -> bool {
    found, name := table_find_new(*udev_names, name);
    return found;
}

libinput_udev_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if decl.name == "libinput" && decl.type.type_of_struct {
        decl.output_name = "libinput_context";
    }
    if decl.name == "udev" && decl.type.type_of_struct {
        decl.output_name = "udev_context";
    }
    else if starts_with(decl.name, "udev_") && decl._expression.kind == .STRUCT {
        table_add(*udev_names, decl.name, true);
    }
    if starts_with(decl.name, "udev_") && decl.kind == .FUNCTION {
        f := cast(*Function)decl;
        args := f.type.type_of_function.arguments;
        for args {
            name_occupied, _ := table_find_new(*udev_names, it.name);
            if starts_with(it.name, "udev_") && name_occupied {
                it.output_name = tprint("%_", it.name);
            }
        }
    }
    if decl.name == "interface" {
        decl.output_name = "interface_";
    }

    if context.symbols_struct_name {
        return as_pointers(decl, parent_decl);
    } else {
        return .RECURSE;
    }
}

x11_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    result := harden_x11(decl, parent_decl);
    if context.symbols_struct_name {
        return as_pointers(decl, parent_decl);
    } else {
        return result;
    }
}

harden_x11 :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    // va_list is just a glorified void pointer!
    if decl.name == "va_list" {
        decl.output_name = "*void";
    }
    // Transform some enums into enum_flags and change their bit-ness according to the way
    // functions take them. Jai is way more disciplinned than C about these things so we do
    // this while generating bindings to avoid casting all over the place and get better static
    // typing.
    if decl.kind == .ENUM {
        found, remapping := table_find_new(*enums, decl.name);
        if found {
            en := cast(*Enum)decl;
            en.flags |= remapping.flags;
            en.type = remapping.type;
        }

    // Similarly, there are functions that take bitmasked values of some enums in practice,
    // but it's just u32 in the C header. We tighten it up.
    } else if decl.kind == .FUNCTION {
        
        found, remapping := table_find_new(*functions_and_structs, decl.name);
        if !found return .RECURSE;

        f := cast(*Function)decl;
        args := f.type.type_of_function.arguments;

        for args {
            found, new_type_of_arg: = table_find_new(*remapping, it.name);
            if found {
                it.type = new_type_of_arg;
            }
        }
    } else if decl.kind == .STRUCT {
        found, remapping := table_find_new(*functions_and_structs, decl.name);
        if found {
            st := cast(*Struct)decl;
            for st.declarations {
                found, new_type_of_member: = table_find_new(*remapping, it.name);
                if found {
                    it.type = new_type_of_member;
                }
            }
        }
    }

    return .RECURSE;
}

// This turns constant function declaration with #foreign lib specifier into
// type declaration that you can load at runtime so you don't have to link to
// a library at compile time. Does the same thing with extern declarations.
// Very good for software that supports, for example, both wayland and x11 so you don't have to
// directly link both libraries. It also puts all the functions into a wrapper Symbols struct.
parent_struct_initted := false;
_struct: *Struct;
as_pointers :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if !parent_struct_initted {
        _struct = New(Struct);
        _struct.name = context.symbols_struct_name;
        _struct.output_name = context.symbols_struct_name;
        _struct.decl_flags |= .TYPE_INFO_PROCEDURES_ARE_VOID_POINTERS;

        // I don't specify the size of the struct but it doesn't look like
        // anything complains about it or anything doesn't work correctly
        ctype := New(CType);
        ctype.type_of_struct = _struct;
        _struct.type = ctype;
        array_add(*context.generator.global_scope.members, _struct);

        parent_struct_initted = true;
    }

    // Make sure we don't have #elsewhere libname on anything
    if decl.foreign_name {
        decl.foreign_name = "";

        // Turn foreign typedef (e.g. extern type_t var) in to var: *type_t instead
        // of var: type_t
        // See xcb_extension_t in the headers for a particular case
        if decl.kind != .FUNCTION && decl.type.type_of_typedef {
            decl.type.pointer_to = decl.type.type_of_typedef.type;
            decl.type.type_of_typedef = null;
        }
        // We can't remove declarations from global scope members because we're
        // iterating over them, so we're copying the declaration, putting it into
        // the Symbols struct, and then omitting the original declaration from being
        // printed
        new_decl := New(Declaration);
        memcpy(new_decl, decl, size_of(Declaration));

        decl.decl_flags |= .OMIT_FROM_OUTPUT;

        new_decl.kind = .DECLARATION;
        array_add(*_struct.declarations, new_decl);
    }
    return .RECURSE;
}

// Copy-pasted from bindings-generator's init_compiler_context
// because we're calling this before bindings generator has started;
make_number_type :: (flags: Number_Flags) -> *CType {
    size := size_from_number_flags(flags);
    ty := New(CType);
    ty.size = size;
    ty.number_flags = flags;
    return ty;
}

init_tables :: () {
    type_def_u8  := make_number_type(._8BIT);
    type_def_u16 := make_number_type(._16BIT);
    type_def_u32 := make_number_type(._32BIT);
    type_def_u64 := make_number_type(._64BIT);

    // Enum remapping
    table_add(*enums, "xcb_cw_t", .{type_def_u32, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_gc_t", .{type_def_u32, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_window_class_t", .{type_def_u16, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_query_shape_of_t", .{type_def_u8, 0});
    table_add(*enums, "xcb_image_order_t", .{type_def_u8, 0});
    table_add(*enums, "xcb_xkb_nkn_detail_t", .{type_def_u16, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_xkb_state_part_t", .{type_def_u16, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_xkb_control_t", .{type_def_u32, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_xkb_event_type_t", .{type_def_u16, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_xkb_map_part_t", .{type_def_u16, .IS_ENUM_FLAGS});
    table_add(*enums, "xcb_prop_mode_t", .{type_def_u8, 0});

    // Function arguments and struct members
    table_add(*create_window_args, "_class", *xcb_window_class_t_type);
    table_add(*create_window_args, "value_mask", *xcb_cw_t_type);
    for create_window_functions {
        table_add(*functions_and_structs, it, create_window_args);
    }

    table_add(*create_change_gc_args, "value_mask", *xcb_gc_t_type);
    for create_change_gc_functions {
        table_add(*functions_and_structs, it, create_change_gc_args);
    }

    table_add(*query_best_size_args, "_class", *xcb_query_shape_of_t_type);
    for query_best_size_functions {
        table_add(*functions_and_structs, it, query_best_size_args);
    }

    table_add(*change_property_args, "mode", *xcb_prop_mode_t_type);
    for change_property_functions {
        table_add(*functions_and_structs, it, change_property_args);
    }

    table_add(*change_window_attributes_args, "value_mask", *xcb_cw_t_type);
    for change_window_attributes_functions {
        table_add(*functions_and_structs, it, change_window_attributes_args);
    }

    table_add(*xkb_select_events_args, "affectWhich", *xcb_xkb_event_type_t_type);
    table_add(*xkb_select_events_args, "clear", *xcb_xkb_event_type_t_type);
    table_add(*xkb_select_events_args, "selectAll", *xcb_xkb_event_type_t_type);
    table_add(*xkb_select_events_args, "affectMap", *xcb_xkb_map_part_t_type);
    table_add(*xkb_select_events_args, "map", *xcb_xkb_map_part_t_type);
    for xcb_xkb_select_events_functions {
        table_add(*functions_and_structs, it, xkb_select_events_args);
    }

    table_add(*xcb_setup_t_members, "image_byte_order", *xcb_image_order_t_type);
    table_add(*functions_and_structs, "xcb_setup_t", xcb_setup_t_members);

    table_add(*xcb_xkb_select_events_details_t_members, "affectNewKeyboard", *xcb_xkb_nkn_detail_t_type);
    table_add(*xcb_xkb_select_events_details_t_members, "newKeyboardDetails", *xcb_xkb_nkn_detail_t_type);
    table_add(*xcb_xkb_select_events_details_t_members, "affectState", *xcb_xkb_state_part_t_type);
    table_add(*xcb_xkb_select_events_details_t_members, "stateDetails", *xcb_xkb_state_part_t_type);
    table_add(*xcb_xkb_select_events_details_t_members, "affectCtrls", *xcb_xkb_control_t_type);
    table_add(*xcb_xkb_select_events_details_t_members, "ctrlDetails", *xcb_xkb_control_t_type);
    table_add(*functions_and_structs, "xcb_xkb_select_events_details_t", xcb_xkb_select_events_details_t_members);

    // This is weird one. These fields are u8, but the "enum" has ANY on it that's 16bit.
    // This is probably one of the case when enum is not really an enum
    // for string.["mods", "baseMods", "latchedMods", "lockedMods"] {
    //     table_add(*xcb_xkb_state_notify_event_t_members, it, );
    // }
    // table_add(*functions_and_structs, "xcb_xkb_state_notify_event_t", xcb_xkb_state_notify_event_t_members)
}

Enum_Remapping :: struct {
    type: *CType;
    flags: Enum.Enum_Flags;
};

enums: Table(string, Enum_Remapping);

// Args_Table holds remappings for function arguments and for struct members
Args_Table :: Table(string, *CType);
create_window_args: Args_Table;
create_change_gc_args: Args_Table;
query_best_size_args: Args_Table;
change_property_args: Args_Table;
change_window_attributes_args: Args_Table;
xcb_setup_t_members: Args_Table;
xcb_xkb_select_events_details_t_members: Args_Table;
xcb_xkb_state_notify_event_t_members: Args_Table;
xkb_select_events_args: Args_Table;

functions_and_structs: Table(string, Args_Table);

xcb_window_class_t_type :: CType.{
    hardcoded_jai_string = "xcb_window_class_t",
};

xcb_query_shape_of_t_type :: CType.{
    hardcoded_jai_string = "xcb_query_shape_of_t",
};

xcb_cw_t_type :: CType.{
    hardcoded_jai_string = "xcb_cw_t",
    // Size is in bytes, not in bits
    size = 4,
};

xcb_gc_t_type :: CType.{
    hardcoded_jai_string = "xcb_gc_t",
};

xcb_prop_mode_t_type :: CType.{
    hardcoded_jai_string = "xcb_prop_mode_t",
    size = 1,
};

xcb_image_order_t_type :: CType.{
    hardcoded_jai_string = "xcb_image_order_t",
    size = 1,
};

xcb_xkb_nkn_detail_t_type :: CType.{
    hardcoded_jai_string = "xcb_xkb_nkn_detail_t",
    size = 2,
};

xcb_xkb_state_part_t_type :: CType.{
    hardcoded_jai_string = "xcb_xkb_state_part_t",
    size = 2,
};

xcb_xkb_control_t_type :: CType.{
    hardcoded_jai_string = "xcb_xkb_control_t",
    size = 4,
};

xcb_xkb_event_type_t_type :: CType.{
    hardcoded_jai_string = "xcb_xkb_event_type_t",
    size = 2,
};

xcb_xkb_map_part_t_type :: CType.{
    hardcoded_jai_string = "xcb_xkb_map_part_t",
    size = 2,
};

create_window_functions :: string.[
    "xcb_create_window_checked",
    "xcb_create_window",
    "xcb_create_window_aux_checked",
    "xcb_create_window_aux",
];

create_change_gc_functions :: string.[
    "xcb_change_gc_checked",
    "xcb_change_gc",
    "xcb_change_gc_aux_checked",
    "xcb_change_gc_aux",
    "xcb_create_gc_value_list_serialize",
    "xcb_create_gc_value_list_unpack",
    "xcb_create_gc_value_list_sizeof",
    "xcb_create_gc_checked",
    "xcb_create_gc",
    "xcb_create_gc_aux_checked",
    "xcb_create_gc_aux",
    "xcb_create_gc_value_list",
    "xcb_change_gc_value_list_serialize",
    "xcb_change_gc_value_list_unpack",
    "xcb_change_gc_value_list_sizeof",
];

change_property_functions :: string.[
    "xcb_change_property_checked",
    "xcb_change_property",
    "xcb_change_property_request_t",
];

change_window_attributes_functions :: string.[
    "xcb_change_window_attributes_checked",
    "xcb_change_window_attributes",
    "xcb_change_window_attributes_aux_checked",
    "xcb_change_window_attributes_aux",
    "xcb_change_window_attributes_request_t",
];

xcb_xkb_select_events_functions :: string.[
    "xcb_xkb_select_events_checked",
    "xcb_xkb_select_events",
    "xcb_xkb_select_events_aux_checked",
    "xcb_xkb_select_events_aux",
    "xcb_xkb_select_events_request_t",
];

query_best_size_functions :: string.[
    "xcb_query_best_size",
    "xcb_query_best_size_unchecked",
];

IOC_MACROS :: #string CODE
_IOC :: (dir: u32, io_type: u32, nr: u32, size: u32) -> u32 #expand {
    result: u32 = (dir           << _IOC_DIRSHIFT)  | 
                  (io_type       << _IOC_TYPESHIFT) |
                  (nr            << _IOC_NRSHIFT)   |
                  (size          << _IOC_SIZESHIFT);
    return result;
}

/*
 * Used to create numbers.
 *
 * NOTE: _IOW means userland is writing and kernel is reading. _IOR
 * means userland is reading and kernel is writing.
 */
_IO :: (io_type: u32, nr: u32) -> u32 #expand {
    return _IOC(_IOC_NONE, io_type, nr, 0);
}

_IOR :: (io_type: u32, nr: u32, $type: Type) -> u32 #expand {
    return _IOC(_IOC_READ, io_type, nr, size_of(type));
}

_IOW :: (io_type: u32, nr: u32, $type: Type) -> u32 #expand {
    return _IOC(_IOC_WRITE, io_type, nr, size_of(type));
}

_IOWR :: (io_type: u32, nr: u32, $type: Type) -> u32 #expand {
    return _IOC(_IOC_READ|_IOC_WRITE, io_type, nr, size_of(type));
}

_IOR_BAD :: (io_type: u32, nr: u32, $type: Type) -> u32 #expand {
    return _IOC(_IOC_READ, io_type, nr, size_of(type));
}

_IOW_BAD :: (io_type: u32, nr: u32, $type: Type) -> u32 #expand {
    return _IOC(_IOC_WRITE, io_type, nr, size_of(type));
}

_IOWR_BAD :: (io_type: u32, nr: u32, $type: Type) -> u32 #expand {
    return _IOC(_IOC_READ|_IOC_WRITE, io_type, nr, size_of(type));
}

/* used to decode ioctl numbers.. */
_IOC_DIR :: (nr: u32) -> u32 #expand {
    return (nr >> _IOC_DIRSHIFT) & _IOC_DIRMASK;
}

_IOC_TYPE :: (nr: u32) -> u32 #expand {
    return (nr >> _IOC_TYPESHIFT) & _IOC_TYPEMASK;
}

_IOC_NR :: (nr: u32) -> u32 #expand {
    return (nr >> _IOC_NRSHIFT) & _IOC_NRMASK;
}

_IOC_SIZE :: (nr: u32) -> u32 #expand {
    return (nr >> _IOC_SIZESHIFT) & _IOC_SIZEMASK;
}

CODE

IOCTLS :: #string CODE
// TCGETS2      :: #run _IOR(#char "T", 0x2A, termios2       );
// TCSETS2      :: #run _IOW(#char "T", 0x2B, termios2       );
// TCSETSW2     :: #run _IOW(#char "T", 0x2C, termios2       );
// TCSETSF2     :: #run _IOW(#char "T", 0x2D, termios2       );
TIOCGPTN     :: #run _IOR(#char "T", 0x30, u32            ); /* Get Pty Number (of pty-mux device) */
TIOCSPTLCK   :: #run _IOW(#char "T", 0x31, s32            );  /* Lock/unlock Pty */
TIOCGDEV     :: #run _IOR(#char "T", 0x32, u32            ); /* Get primary device node of /dev/console */
TIOCSIG      :: #run _IOW(#char "T", 0x36, s32            );  /* pty: generate signal */
TIOCGPKT     :: #run _IOR(#char "T", 0x38, s32            ); /* Get packet mode state */
TIOCGPTLCK   :: #run _IOR(#char "T", 0x39, s32            ); /* Get Pty lock state */
TIOCGEXCL    :: #run _IOR(#char "T", 0x40, s32            ); /* Get exclusive mode state */
TIOCGPTPEER  :: #run _IO( #char "T",  0x41                ); /* Safely open the slave */
// TIOCGISO7816 :: #run _IOR(#char "T", 0x42, serial_iso7816 );
// TIOCSISO7816 :: #run _IOWR(#char "T", 0x43, serial_iso7816);

CODE

INPUT_H_EVIO :: #string CODE
EVIOCGVERSION    :: #run _IOR(#char "E", 0x01, s32);      /* get driver version */
EVIOCGID         :: #run _IOR(#char "E", 0x02, input_id); /* get device ID */
EVIOCGREP        :: #run _IOR(#char "E", 0x03, [2]u32);   /* get repeat settings */
EVIOCSREP        :: #run _IOW(#char "E", 0x03, [2]u32);   /* set repeat settings */

EVIOCGKEYCODE    :: #run _IOR(#char "E", 0x04, [2]u32);   /* get keycode */
EVIOCGKEYCODE_V2 :: #run _IOR(#char "E", 0x04, input_keymap_entry);
EVIOCSKEYCODE    :: #run _IOW(#char "E", 0x04, [2]u32);   /* set keycode */
EVIOCSKEYCODE_V2 :: #run _IOW(#char "E", 0x04, input_keymap_entry);

EVIOCGNAME :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x06, cast(u32)len); } /* get device name */
EVIOCGPHYS :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x07, cast(u32)len); } /* get physical location */
EVIOCGUNIQ :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x08, cast(u32)len); } /* get unique identifier */
EVIOCGPROP :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x09, cast(u32)len); } /* get device properties */

/**
 * EVIOCGMTSLOTS(len) - get MT slot values
 * @len: size of the data buffer in bytes
 *
 * The ioctl buffer argument should be binary equivalent to
 *
 * struct input_mt_request_layout {
 *	__u32 code;
 *	__s32 values[num_slots];
 * };
 *
 * where num_slots is the (arbitrary) number of MT slots to extract.
 *
 * The ioctl size argument (len) is the size of the buffer, which
 * should satisfy len = (num_slots + 1) * sizeof(__s32).  If len is
 * too small to fit all available slots, the first num_slots are
 * returned.
 *
 * Before the call, code is set to the wanted ABS_MT event type. On
 * return, values[] is filled with the slot values for the specified
 * ABS_MT code.
 *
 * If the request code is not an ABS_MT value, -EINVAL is returned.
 */
EVIOCGMTSLOTS :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x0a, cast(u32)len); }

EVIOCGKEY     :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x18, cast(u32)len); } /* get global key state */
EVIOCGLED     :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x19, cast(u32)len); } /* get all LEDs */
EVIOCGSND     :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x1a, cast(u32)len); } /* get all sounds status */
EVIOCGSW      :: (len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x1b, cast(u32)len); } /* get all switch states */

EVIOCGBIT     :: (ev: u32, len: s32) -> u32 #expand { return _IOC(_IOC_READ, #char "E", 0x20 + ev, cast(u32)len); } /* get event bits */
EVIOCGABS     :: (abs: s32)          -> u32 #expand { return _IOR(#char "E", 0x40 + abs, input_absinfo); }          /* get abs value/limits */
EVIOCSABS     :: (abs: s32)          -> u32 #expand { return _IOW(#char "E", 0xc0 + abs, input_absinfo); }          /* set abs value/limits */

EVIOCSFF      :: # run _IOW(#char "E", 0x80, ff_effect); /* send a force effect to a force feedback device */
EVIOCRMFF     :: # run _IOW(#char "E", 0x81, s32      ); /* Erase a force effect */
EVIOCGEFFECTS :: # run _IOR(#char "E", 0x84, s32      ); /* Report number of effects playable at the same time */

EVIOCGRAB     :: # run _IOW(#char "E", 0x90, s32      ); /* Grab/Release device */
EVIOCREVOKE   :: # run _IOW(#char "E", 0x91, s32      ); /* Revoke device access */

/**
 * EVIOCGMASK - Retrieve current event mask
 *
 * This ioctl allows user to retrieve the current event mask for specific
 * event type. The argument must be of type "struct input_mask" and
 * specifies the event type to query, the address of the receive buffer and
 * the size of the receive buffer.
 *
 * The event mask is a per-client mask that specifies which events are
 * forwarded to the client. Each event code is represented by a single bit
 * in the event mask. If the bit is set, the event is passed to the client
 * normally. Otherwise, the event is filtered and will never be queued on
 * the client's receive buffer.
 *
 * Event masks do not affect global state of the input device. They only
 * affect the file descriptor they are applied to.
 *
 * The default event mask for a client has all bits set, i.e. all events
 * are forwarded to the client. If the kernel is queried for an unknown
 * event type or if the receive buffer is larger than the number of
 * event codes known to the kernel, the kernel returns all zeroes for those
 * codes.
 *
 * At maximum, codes_size bytes are copied.
 *
 * This ioctl may fail with ENODEV in case the file is revoked, EFAULT
 * if the receive-buffer points to invalid memory, or EINVAL if the kernel
 * does not implement the ioctl.
 */
EVIOCGMASK :: #run _IOR(#char "E", 0x92, input_mask); /* Get event-masks */

/**
 * EVIOCSMASK - Set event mask
 *
 * This ioctl is the counterpart to EVIOCGMASK. Instead of receiving the
 * current event mask, this changes the client's event mask for a specific
 * type.  See EVIOCGMASK for a description of event-masks and the
 * argument-type.
 *
 * This ioctl provides full forward compatibility. If the passed event type
 * is unknown to the kernel, or if the number of event codes specified in
 * the mask is bigger than what is known to the kernel, the ioctl is still
 * accepted and applied. However, any unknown codes are left untouched and
 * stay cleared. That means, the kernel always filters unknown codes
 * regardless of what the client requests.  If the new mask doesn't cover
 * all known event-codes, all remaining codes are automatically cleared and
 * thus filtered.
 *
 * This ioctl may fail with ENODEV in case the file is revoked. EFAULT is
 * returned if the receive-buffer points to invalid memory. EINVAL is returned
 * if the kernel does not implement the ioctl.
 */
EVIOCSMASK    :: #run _IOW(#char "E", 0x93, input_mask); /* Set event-masks */

EVIOCSCLOCKID :: #run _IOW(#char "E", 0xa0, s32       ); /* Set clockid to be used for timestamps */

CODE

UINPUT :: #string CODE
UINPUT_IOCTL_BASE :: #char "U";

UI_DEV_CREATE :: #run _IO(UINPUT_IOCTL_BASE, 1);
UI_DEV_DESTROY :: #run _IO(UINPUT_IOCTL_BASE, 2);

/**
 * UI_DEV_SETUP - Set device parameters for setup
 *
 * This ioctl sets parameters for the input device to be created.  It
 * supersedes the old "struct uinput_user_dev" method, which wrote this data
 * via write(). To actually set the absolute axes UI_ABS_SETUP should be
 * used.
 *
 * The ioctl takes a "struct uinput_setup" object as argument. The fields of
 * this object are as follows:
 *              id: See the description of "struct input_id". This field is
 *                  copied unchanged into the new device.
 *            name: This is used unchanged as name for the new device.
 *  ff_effects_max: This limits the maximum numbers of force-feedback effects.
 *                  See below for a description of FF with uinput.
 *
 * This ioctl can be called multiple times and will overwrite previous values.
 * If this ioctl fails with -EINVAL, it is recommended to use the old
 * "uinput_user_dev" method via write() as a fallback, in case you run on an
 * old kernel that does not support this ioctl.
 *
 * This ioctl may fail with -EINVAL if it is not supported or if you passed
 * incorrect values, -ENOMEM if the kernel runs out of memory or -EFAULT if the
 * passed uinput_setup object cannot be read/written.
 * If this call fails, partial data may have already been applied to the
 * internal device.
 */
UI_DEV_SETUP :: #run _IOW(UINPUT_IOCTL_BASE, 3, uinput_setup);


UI_SET_EVBIT ::   #run _IOW(UINPUT_IOCTL_BASE, 100, s32);
UI_SET_KEYBIT ::  #run _IOW(UINPUT_IOCTL_BASE, 101, s32);
UI_SET_RELBIT ::  #run _IOW(UINPUT_IOCTL_BASE, 102, s32);
UI_SET_ABSBIT ::  #run _IOW(UINPUT_IOCTL_BASE, 103, s32);
UI_SET_MSCBIT ::  #run _IOW(UINPUT_IOCTL_BASE, 104, s32);
UI_SET_LEDBIT ::  #run _IOW(UINPUT_IOCTL_BASE, 105, s32);
UI_SET_SNDBIT ::  #run _IOW(UINPUT_IOCTL_BASE, 106, s32);
UI_SET_FFBIT ::   #run _IOW(UINPUT_IOCTL_BASE, 107, s32);
UI_SET_PHYS  ::   #run _IOW(UINPUT_IOCTL_BASE, 108, *u8);
UI_SET_SWBIT ::   #run _IOW(UINPUT_IOCTL_BASE, 109, s32);
UI_SET_PROPBIT :: #run _IOW(UINPUT_IOCTL_BASE, 110, s32);

CODE

// Bindings Generator adds #scope_file to every generated file unconditionally.
// see append(*builder, "\n\n#scope_file\n\n"); in Bindings_Generator/module.jai
// This is mostly a hack to work around it for when I join multiple generated string builders
// together.
cut_scope_file :: (builder: *String_Builder) #expand {
    buffer := get_current_buffer(builder);
    buffer_string: string;
    buffer_string.data = get_buffer_data(buffer);
    buffer_string.count = buffer.count;
    idx := find_index_from_left(buffer_string, "#scope_file");
    buffer.count = idx;
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";
#import "Hash_Table";
