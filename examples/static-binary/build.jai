/*
This is an example of how to build a static executable on Linux with musl as your libc.
It also contains a helper to build musl itself.

Requirements:
1) musl (duh)
2) xz aka liblzma - something-something compression (or backdoors kekw)
These two are needed for stack traces when your program crashes - like after an assert or a debug_break
3) libunwind
4) libbacktrace

There are no helpers to compile xz, libunwind and libbacktrace for now, so you need to precompile them yourself. Sorry!
You also need a modified version of Runtime_Crash_Handler.jai. Patch is included.
*/
#load "./build_musl.jai";

BUILD_MUSL :: false;

build :: () {
    ws := Compiler.compiler_create_workspace("Target");
    if !ws {
        log_error("Failed to create workspace");
        return;
    }
    opts := Compiler.get_build_options();

    Compiler.set_build_options_dc(.{do_output=false});

    // Path to musl source code
    musl_source := join(#filepath, "musl-1.2.5");

    // Path where you want to get compiled object files and a library stored
    musl_out := join(#filepath, "musl-out");

#if BUILD_MUSL {
    result := build_musl(musl_source, musl_out, debug_info=false);
    if !result {
        return;
    }
}

    opts.use_custom_link_command = true;
    opts.output_executable_name = "exe";
    Compiler.set_build_options(opts, ws);

    Compiler.compiler_begin_intercept(ws);

    Compiler.add_build_file("main.jai", ws);

    while true {
        message := Compiler.compiler_wait_for_message();
        if message.kind == .COMPLETE break;

        if message.kind == .PHASE {
            phase_message := cast(*Compiler.Message_Phase)message;
            phase := phase_message.phase;

            if phase == .READY_FOR_CUSTOM_LINK_COMMAND {
                run_custom_link_command(message.workspace, phase_message, musl_out);
            }
        }
    }

    Compiler.compiler_end_intercept(ws);
}

run_custom_link_command :: (ws: Workspace, m: *Compiler.Message_Phase, musl_dir: string)  {
    opts := Compiler.get_build_options(ws);
    compiler_base_path := Compiler.compiler_get_base_path();

    suffix := "";
    target_filename := tprint("%1%2%3", opts.output_path, opts.output_executable_name, suffix);
    print("target_filename: %\n", target_filename);

    lld := "lld-linux";
    lld_exe_name := tprint("%/bin/%", compiler_base_path, lld);
    print("linker: %\n", lld_exe_name);

    args: [..]string;
    array_add(*args, lld_exe_name);
    array_add(*args, "-flavor");
    array_add(*args, "Gnu");
    array_add(*args, "--static");

    for m.compiler_generated_object_files array_add(*args, it);
    array_add(*args, tprint("%/crt1.o", musl_dir));
    array_add(*args, tprint("%/crti.o", musl_dir));
    array_add(*args, tprint("%/crtn.o", musl_dir));
    array_add(*args, tprint("%/libc.a", musl_dir));

    array_add(*args, join(#filepath, "/xz/liblzma.a"));
    array_add(*args, join(#filepath, "/libunwind/libunwind.a"));
    array_add(*args, join(#filepath, "/libbacktrace/libbacktrace.a"));
    
    array_add(*args, "-o");
    array_add(*args, target_filename);

    process_result := run_command(..args);

    if process_result.exit_code != 0 {
        print("Error: Link step failed! (Exit code %).\n", process_result.exit_code);
    }

    Compiler.compiler_custom_link_command_is_complete(ws);
}

#run build();

Compiler :: #import "Compiler";
#import "Basic";
#import "Process";
#import "String";
