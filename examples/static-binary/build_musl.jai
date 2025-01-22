build_musl :: (musl_source: string, musl_target: string, dynamic := false, debug_info := true, optimize_for_speed_over_size := true, print_output := false) -> success: bool {
    log("Musl is located at: %\n", musl_source);

    success := make_directory_if_it_does_not_exist(musl_target);
    if !success {
        log_error("Could not create a target directory\n");
        return false;
    }

    configure: [..]string;
    array_add(*configure, "./configure");
    // Just hardcode disabling gcc wrapper for now.
    array_add(*configure, "--enable-wrapper=no");
    array_add(*configure, tprint("--prefix=%", musl_target));
    array_add(*configure, tprint("--enable-optimize=%", ifx optimize_for_speed_over_size then "yes" else "no"));
    array_add(*configure, tprint("--enable-debug=%", ifx debug_info then "yes" else "no"));
    if dynamic {
        array_add(*configure, "--disable-static");
    } else {
        array_add(*configure, "--disable-shared");
    }

    capture_and_return_output := !print_output;
    result, out, err := run_command(..configure, working_directory=musl_source, print_captured_output=print_output, capture_and_return_output=capture_and_return_output);

    if result.exit_code != 0 {
        log_error("Coulnd't configure musl, aborting\n");
        if capture_and_return_output {
            log_error("configure stdout is %\n", out);
            log_error("configure stderr is %\n", err);
        }
        return false;
    }

    make_result:, out, err = run_command("make", working_directory=musl_source, print_captured_output=print_output, capture_and_return_output=capture_and_return_output);
    if make_result.exit_code != 0 {
        log_error("Running make failed\n");
        if capture_and_return_output {
            log_error("make stdout is %\n", out);
            log_error("make stderr is %\n", err);
            return false;
        }
    }

    // make install-libs installs empty libs that we don't really need, so let's copy files manually
    files_to_copy: [..]string;
    array_add(*files_to_copy, join(musl_source, "/lib/crt1.o"), join(musl_target, "/crt1.o"));
    array_add(*files_to_copy, join(musl_source, "/lib/crti.o"), join(musl_target, "/crti.o"));
    array_add(*files_to_copy, join(musl_source, "/lib/crtn.o"), join(musl_target, "/crtn.o"));
    // We really just need to support both, but whatevs
    if dynamic {
        array_add(*files_to_copy, join(musl_source, "/lib/libc.so"), join(musl_target, "/libc.so"));
    } else {
        array_add(*files_to_copy, join(musl_source, "/lib/libc.a"), join(musl_target, "/libc.a"));
    }
    // There's also rcrt1.o and Scrt1.o, but we don't need them, I don't think so.

    for 0..files_to_copy.count/2 - 1 {
        copy_file(files_to_copy[it * 2], files_to_copy[it * 2 + 1]);
    }

    return true;
}


#import "Basic";
#import "Process";
#import "File";
#import "File_Utilities";
