AT_COMPILE_TIME :: false;
AS_FUNCTION_POINTERS :: false;

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
    // libxcb
    {
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb.h");
        array_add(*opts.system_library_paths, "/usr/lib");
        array_add(*opts.system_library_names, "libxcb.so");
        // Enable if things start segfaulting or otherwise behave weirdly and
        // you suspect it's due to structs getting generated incorrectly
        opts.generate_compile_time_struct_checks = false;

        // Turn function definitions into type declarations that you can load at
        // runtime
        #if AS_FUNCTION_POINTERS {
            opts.generate_library_declarations = false;
            opts.visitor = xcb_visitor;
            context.procs_struct_name = "XCB_Procs";
            output_filename := "xcb_dynamic.jai";
        } else {
            output_filename := "xcb.jai";
        }

        result := generate_bindings(opts, output_filename);
        if !result return xcb_result;
    }

    parent_struct_initted = false;
    // libxcb-image
    {
        opts: Generate_Bindings_Options;
        array_add(*opts.source_files, "/usr/include/xcb/xcb_image.h");

        // xcb_image includes shm.h and uses its types, you can include it right here
        // if you just want to inine its declarations
        array_add(*opts.path_fragments_to_treat_as_non_system_paths, "/usr/include/xcb/shm.h");
        array_add(*opts.system_library_paths, "/usr/lib");
        array_add(*opts.system_library_names, "libxcb-image.so");
        opts.generate_compile_time_struct_checks = false;

        #if AS_FUNCTION_POINTERS {
            opts.generate_library_declarations = false;
            opts.visitor = xcb_visitor;
            context.procs_struct_name = "XCB_Image_Procs";
            output_filename = "xcb_image_dynamic.jai";
        } else {
            output_filename = "xcb_image.jai";
    }

    xcb_image_result := generate_bindings(xcb_image_opts, output_filename);
    return xcb_image_result;
}

// This turns constant function declaration with #foreign lib specifier into
// type declaration that you can load at runtime so you don't have to link to
// libxcb at compile time. Very good for software that supports both wayland and x11
// It also puts all the functions into a wrapper Procs struct
parent_struct_initted := false;
_struct: *Struct;
xcb_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
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
    return .STOP;
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";
