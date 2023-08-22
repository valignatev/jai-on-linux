AT_COMPILE_TIME :: false;

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

generate_bindings :: () -> bool {
    xcb_opts: Generate_Bindings_Options;
    array_add(*xcb_opts.source_files, "/usr/include/xcb/xcb.h");
    array_add(*xcb_opts.system_library_paths, "/usr/lib");
    array_add(*xcb_opts.system_library_names, "libxcb.so");
    // Enable if things start segfaulting or otherwise behave weirdly and
    // you suspect it's due to structs getting generated incorrectly
    xcb_opts.generate_compile_time_struct_checks = false;
    // TODO: experiment with a version that loads function pointers
    // opts.generate_library_declarations = false;
    
    output_filename := "xcb.jai";
    xcb_result := generate_bindings(xcb_opts, output_filename);
    if !xcb_result {
        return xcb_result;
    }

    xcb_image_opts: Generate_Bindings_Options;
    array_add(*xcb_image_opts.source_files, "/usr/include/xcb/xcb_image.h");
    // xcb_image includes shm.h and uses its types
    array_add(*xcb_image_opts.path_fragments_to_treat_as_non_system_paths, "/usr/include/xcb/shm.h");
    array_add(*xcb_image_opts.system_library_paths, "/usr/lib");
    array_add(*xcb_image_opts.system_library_names, "libxcb-image.so");
    xcb_image_opts.generate_compile_time_struct_checks = false;

    output_filename = "xcb_image.jai";
    xcb_image_result := generate_bindings(xcb_image_opts, output_filename);
    return xcb_image_result;
}

#import "Basic"()(TEMPORARY__USE_NEW_FLOAT_PRINTING=true);
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";
