AT_COMPILE_TIME :: true;
PRESERVE_COMMENTS :: false;

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

#add_context procs_struct_name := "";
generate_bindings :: () -> bool {
    init_tables();
    // xcb
    {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb.h");
        array_add(*opts.system_library_paths, "/usr/lib");
        array_add(*opts.system_library_names, "libxcb.so");
        // Enable if things start segfaulting or otherwise behave weirdly and
        // you suspect it's due to structs getting generated incorrectly
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = visitor;
        // Turn function definitions into type declarations that you can load at
        // runtime

        result := generate_bindings(opts, "generated/xcb.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.procs_struct_name = "XCB_Procs";
        defer context.procs_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_fp.jai");
        if !result return result;
    }

    // xcb-image
    {
        parent_struct_initted = false;
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb_image.h");

        // xcb_image includes shm.h and uses its types, you can include it right here
        // if you just want to inine its declarations
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "/usr/include/xcb/shm.h");
        array_add(*opts.system_library_paths, "/usr/lib");
        array_add(*opts.system_library_names, "libxcb-image.so");
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;

        opts.visitor = visitor;

        result := generate_bindings(opts, "generated/xcb_image.jai");
        if !result return result;

        // TODO: seems like bindings generator eats this when it generates the bindings
        // once and on subsequent generations it doesn't have this info anymore.
        // Need to research
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "/usr/include/xcb/shm.h");
        opts.generate_library_declarations = false;
        context.procs_struct_name = "XCB_Image_Procs";
        defer context.procs_struct_name = "";

        result = generate_bindings(opts, "generated/xcb_image_fp.jai");
        if !result return result;
    }

    // xkbcommon
    {
        parent_struct_initted = false;

        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xkbcommon/xkbcommon.h");
        array_add(*opts.system_library_paths, "/usr/lib");
        array_add(*opts.system_library_names, "libxkbcommon.so");
        opts.generate_compile_time_struct_checks = false;
        opts.try_to_preserve_comments = PRESERVE_COMMENTS;
        opts.mimic_spacing_flags = .STRUCT | .GLOBAL;

        opts.visitor = visitor;

        result := generate_bindings(opts, "generated/xkbcommon.jai");
        if !result return result;

        opts.generate_library_declarations = false;
        context.procs_struct_name = "XKB_Common_Procs";
        defer context.procs_struct_name = "";

        result = generate_bindings(opts, "generated/xkbcommon_fp.jai");
        if !result return result;
    }
    return true;
}

visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    result := harden(decl, parent_decl);
    if context.procs_struct_name {
        return as_function_pointers(decl, parent_decl);
    } else {
        return result;
    }
}

harden :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    // va_list is just a glorified void pointer!
    if decl.name == "va_list" {
        decl.output_name = "*void";
    }
    // Transform some enums into enum_flags and change their bit-ness according to the way
    // functions take them. Jai is way more disciplinned than C about these things so we do
    // this while generating bindings to avoid casting all over the place and get better static
    // typing.
    if decl.kind == .ENUM {
        remapping, found := table_find(*enums, decl.name);
        if found {
            en := cast(*Enum)decl;
            en.flags |= remapping.flags;
            en.type = remapping.type;
        }

    // Similarly, there are functions that take bitmasked values of some enums in practice,
    // but it's just u32 in the C header. We tighten it up.
    } else if decl.kind == .FUNCTION {
        
        remapping, found := table_find(*functions_and_structs, decl.name);
        if !found return .RECURSE;

        f := cast(*Function)decl;
        args := f.type.type_of_function.arguments;

        for args {
            new_type_of_arg:, found = table_find(*remapping, it.name);
            if found {
                it.type = new_type_of_arg;
            }
        }
    } else if decl.kind == .STRUCT {
        remapping, found := table_find(*functions_and_structs, decl.name);
        if found {
            st := cast(*Struct)decl;
            for st.declarations {
                new_type_of_member:, found = table_find(*remapping, it.name);
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
// libxcb at compile time. Very good for software that supports both wayland and x11
// It also puts all the functions into a wrapper Procs struct
parent_struct_initted := false;
_struct: *Struct;
as_function_pointers :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    if !parent_struct_initted {
        _struct = New(Struct);
        _struct.name = context.procs_struct_name;
        _struct.output_name = context.procs_struct_name;
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
    decl.foreign_name = "";
    if decl.kind == .FUNCTION {
        // We can't remove declarations from global scope members because we're
        // iterating over them, so we're copying the declaration, putting it into
        // the Procs struct, and then omitting the original declaration from being
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

    // Function arguments
    table_add(*create_window_args, "_class", *xcb_window_class_t_type);
    table_add(*create_window_args, "value_mask", *xcb_cw_t_type);
    table_add(*create_change_gc_args, "value_mask", *xcb_gc_t_type);
    for create_window_functions {
        table_add(*functions_and_structs, it, create_window_args);
    }
    for create_change_gc_functions {
        table_add(*functions_and_structs, it, create_change_gc_args);
    }

    table_add(*query_best_size_args, "_class", *xcb_query_shape_of_t_type);
    for query_best_size_functions {
        table_add(*functions_and_structs, it, query_best_size_args);
    }

    // Struct members
    table_add(*xcb_setup_t_members, "image_byte_order", *xcb_image_order_t_type);
    table_add(*functions_and_structs, "xcb_setup_t", xcb_setup_t_members);
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
xcb_setup_t_members: Args_Table;
functions_and_structs: Table(string, Args_Table);

xcb_window_class_t_type :: CType.{
    hardcoded_jai_string = "xcb_window_class_t",
};

xcb_query_shape_of_t_type :: CType.{
    hardcoded_jai_string = "xcb_query_shape_of_t",
};

xcb_cw_t_type :: CType.{
    hardcoded_jai_string = "xcb_cw_t",
};

xcb_gc_t_type :: CType.{
    hardcoded_jai_string = "xcb_gc_t",
};

xcb_image_order_t_type :: CType.{
    hardcoded_jai_string = "xcb_image_order_t",
    // Size is in bytes, not in bits
    size = 1,
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

query_best_size_functions :: string.[
    "xcb_query_best_size",
    "xcb_query_best_size_unchecked",
];


#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";
#import "Hash_Table";
