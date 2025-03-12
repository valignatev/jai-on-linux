#load "./egl.jai";
#load "./gl.jai";

using egl_procs: EGL_Procs;
using egl_ext_procs: EGL_Ext_Procs;
using gl_procs: GL_Procs;
using gl_ext_procs: GL_Ext_Procs;

supported_extensions_populated := false;
GL_Available_Extensions :: Table(string, bool);
gl_available_extensions: GL_Available_Extensions;

populate_supported_extensions :: () {
    display: EGLDisplay = eglGetDisplay(xx EGL_DEFAULT_DISPLAY);
    // print("display:%\n", display);
    init := eglInitialize(display, null, null);
    // print("init:%\n", init);

    total_configs: s32;
    // eglGetConfigs(display, null, 0, *total_configs);
    // print("Total configs: %\n", total_configs);

    config_attribs: []EGLint = .[
        EGL_CONFORMANT, EGL_OPENGL_BIT,
        EGL_NONE,
    ];
    config: EGLConfig;
    num_configs: EGLint;
    choose := eglChooseConfig(display, config_attribs.data, *config, 1, *num_configs);
    // print("num: %, choose_res: %, config:%\n", num_configs,  choose, config);

    // TODO: This hardcodes desktop opengl
    // EGL GLES doesn't need to do this (and actually shoudln't)
    // Same with EGL_OPENGL_BIT above in config_attribs.
    ok := eglBindAPI(EGL_OPENGL_API);
    assert(xx ok, "Failed to select OpenGL API for EGL");

    context_: EGLContext  = eglCreateContext(display, config, xx EGL_NO_CONTEXT, null);
    // print("context:%\n", context_);
    result := eglMakeCurrent(display, xx EGL_NO_SURFACE, xx EGL_NO_SURFACE, context_);
    // print("res: %\n", result);

    // The NG way
    num: s32;
    glGetIntegerv(GL_NUM_EXTENSIONS, *num);
    if !num {
        // Fall back to the OG way
        extensions := glGetString(GL_EXTENSIONS);
        // print("ext_raw: %\n", extensions);
        if extensions {
            extensions_str := to_string(extensions);
            splitted := split(extensions_str, " ");

            for splitted {
                table_set(*gl_available_extensions, it, true);
                // print("%\n", it);
            }
        }

    } else {
        for 0..num-1 {
            ext:= to_string(glGetStringi(GL_EXTENSIONS, xx it));
            table_set(*gl_available_extensions, ext, true);
            // print("%\n", ext);
        }
    }

    egl_display_extensions := split(to_string(eglQueryString(display, EGL_EXTENSIONS)), " ",, temp);
    for egl_display_extensions {
        table_set(*gl_available_extensions, it, true);
    }

    egl_client_extensions := split(to_string(eglQueryString(xx EGL_NO_DISPLAY, EGL_EXTENSIONS)), " ",, temp);
    for egl_client_extensions {
        table_set(*gl_available_extensions, it, true);
    }

    eglDestroyContext(display, context_);
    eglTerminate(display);
    supported_extensions_populated = true;
}

loader_call :: #type (name: *u8) -> *void #c_call;
generic_c_call :: #type () #c_call;
loader_proc: loader_call;
load_procs :: (procs: *$T, libname: string) -> success := false {
    lib := dlopen(temp_c_string(libname), RTLD_NOW);
    if !lib {
        log_error("Failed to load %: %", libname, to_string(dlerror()));
        return false;
    }

    tis := cast(*Type_Info_Struct) type_info(T);
    for m : tis.members {
        notes := m.notes;

        if m.type.type == .POINTER {
            // Core/Compatibility procedures
            pi := cast(*Type_Info_Procedure) m.type;
            ppfn := cast(*generic_c_call)((cast(*u8) procs) + m.offset_in_bytes);
            if m.notes && array_find(m.notes, "gl_loader") {
                ppfn := cast(*loader_call)((cast(*u8) procs) + m.offset_in_bytes);
                ppfn.* = cast(loader_call) dlsym(lib, m.name.data);
                loader_proc = ppfn.*;
            } else {
                ppfn.* = cast(generic_c_call) loader_proc(m.name.data);
            }
            assert(!!(ppfn.*), "Failed to resolve function '%': %", m.name, to_string(dlerror()));
        }
    }

    return true;
}

load_extensions :: (procs: *$T) -> success := false  {
    if !supported_extensions_populated {
        populate_supported_extensions();
    }
    ti_ext := cast(*Type_Info_Struct) type_info(T);
    for m: ti_ext.members {
        if m.type.type == .BOOL {
            _, ext_found := table_find(*gl_available_extensions, m.name);
            ti := m.type;
            is_avail_ptr := cast(*bool)((cast(*u8)procs) + m.offset_in_bytes);
            is_avail_ptr.* = ext_found;
            if !ext_found {
                print("% is NO Tavailable\n", m.name);
                return false;
            }
            print("% is available\n", m.name);
        } else if m.type.type == .POINTER {
            pi := cast(*Type_Info_Procedure) m.type;
            ppfn := cast(*type_of(pi))((cast(*u8) procs) + m.offset_in_bytes);
            ppfn.* = xx loader_proc(m.name.data);
        }
    }

    return true;
}


gl_load :: () -> bool {
    result := true;
    result = load_procs(*egl_procs, "libEGL.so");
    if !result return result;
    result = load_procs(*gl_procs, "libGL.so");
    if !result return result;
    result = load_extensions(*egl_ext_procs);
    if !result return result;
    result = load_extensions(*gl_ext_procs);
    if !result return result;

    return result;
}


#scope_file

#import "Basic";
#import "Hash_Table";
#import "String";
#import "POSIX";
