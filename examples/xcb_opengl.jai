// This is @mmozeiko's libx + EGL example in C ported to xcb + EGL in Jai
// Original code: https://gist.github.com/mmozeiko/911347b5e3d998621295794e0ba334c4
// It requires EGL_EXT_platform_xcb extension, so if your system is circa the end of 2021 or newer you should be fine.
// Also, I don't know if it works on Nvidia. LMK if you test it

// example how to set up OpenGL core context on X11 with EGL and xcb
// and use basic functionality of OpenGL 4.5 version

// to compile on Ubuntu first install following packages: build-essential libxcb1-dev libgl-dev libegl-dev, then run:
// jai xcb_opengl.jai
// On Arch that would be (I'm not sure if it's the full list): base-devel libxcb libglvnd

// important extension functionality used here:
// https://registry.khronos.org/EGL/extensions/EXT/EGL_EXT_platform_xcb.txt
// (4.3) KHR_debug:                     https://www.khronos.org/registry/OpenGL/extensions/KHR/KHR_debug.txt
// (4.5) ARB_direct_state_access:       https://www.khronos.org/registry/OpenGL/extensions/ARB/ARB_direct_state_access.txt
// (4.1) ARB_separate_shader_objects:   https://www.khronos.org/registry/OpenGL/extensions/ARB/ARB_separate_shader_objects.txt
// (4.2) ARB_shading_language_420pack:  https://www.khronos.org/registry/OpenGL/extensions/ARB/ARB_shading_language_420pack.txt
// (4.3) ARB_explicit_uniform_location: https://www.khronos.org/registry/OpenGL/extensions/ARB/ARB_explicit_uniform_location.txt


// This is needed to get EGL native display from xcb connection
// eglGetDisplay(EGL_DEFAULT_DISPLAY) and eglGetDisplay(conn) work on my machines (Intel and AMD graphics),
// but this makes EGL guess what kind of pointer you pass to it, so we're being explicit here.

#load "../generated/egl.jai";
#load "../generated/glcorearb.jai";
#load "../generated/xcb.jai";

GetPlatformDisplayEXT: PFNEGLGETPLATFORMDISPLAYEXTPROC;

GL_Procs :: struct {
    glEnable:                   PFNGLENABLEPROC                  ;
    glDisable:                  PFNGLDISABLEPROC                 ;
    glBlendFunc:                PFNGLBLENDFUNCPROC               ;
    glViewport:                 PFNGLVIEWPORTPROC                ;
    glClearColor:               PFNGLCLEARCOLORPROC              ;
    glClear:                    PFNGLCLEARPROC                   ;
    glDrawArrays:               PFNGLDRAWARRAYSPROC              ;
    glCreateBuffers:            PFNGLCREATEBUFFERSPROC           ;
    glNamedBufferStorage:       PFNGLNAMEDBUFFERSTORAGEPROC      ;
    glBindVertexArray:          PFNGLBINDVERTEXARRAYPROC         ;
    glCreateVertexArrays:       PFNGLCREATEVERTEXARRAYSPROC      ;
    glVertexArrayAttribBinding: PFNGLVERTEXARRAYATTRIBBINDINGPROC;
    glVertexArrayVertexBuffer:  PFNGLVERTEXARRAYVERTEXBUFFERPROC ;
    glVertexArrayAttribFormat:  PFNGLVERTEXARRAYATTRIBFORMATPROC ;
    glEnableVertexArrayAttrib:  PFNGLENABLEVERTEXARRAYATTRIBPROC ;
    glCreateShaderProgramv:     PFNGLCREATESHADERPROGRAMVPROC    ;
    glGetProgramiv:             PFNGLGETPROGRAMIVPROC            ;
    glGetProgramInfoLog:        PFNGLGETPROGRAMINFOLOGPROC       ;
    glGenProgramPipelines:      PFNGLGENPROGRAMPIPELINESPROC     ;
    glUseProgramStages:         PFNGLUSEPROGRAMSTAGESPROC        ;
    glBindProgramPipeline:      PFNGLBINDPROGRAMPIPELINEPROC     ;
    glProgramUniformMatrix2fv:  PFNGLPROGRAMUNIFORMMATRIX2FVPROC ;
    glBindTextureUnit:          PFNGLBINDTEXTUREUNITPROC         ;
    glCreateTextures:           PFNGLCREATETEXTURESPROC          ;
    glTextureParameteri:        PFNGLTEXTUREPARAMETERIPROC       ;
    glTextureStorage2D:         PFNGLTEXTURESTORAGE2DPROC        ;
    glTextureSubImage2D:        PFNGLTEXTURESUBIMAGE2DPROC       ;
    glDebugMessageCallback:     PFNGLDEBUGMESSAGECALLBACKPROC    ;
}

using gl_procs: GL_Procs;


debug_callback :: (
    source: GLenum,
    type: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *GLchar,
    // Email about procedure headers not supporing trailing commas
    user: *void
) #c_call {
    // Pass the context as a user data maybe?
    push_context,defer_pop;

    log_error("%\n", to_string(message));
    if (severity == GL_DEBUG_SEVERITY_HIGH || severity == GL_DEBUG_SEVERITY_MEDIUM) {
        assert(false, "OpenGL API usage error! Use debugger to examine call stack!");
    }
}


glsl_vshader :: #string SHADER
#version 450 core
#line % // actual line number in this file for nicer error messages

layout (location=0) in vec2 a_pos; // position attribute index 0
layout (location=1) in vec2 a_uv; // uv attribute index 1
layout (location=2) in vec3 a_color; // color attribute index 2

layout (location=0) // (from ARB_explicit_uniform_location)
uniform mat2 u_matrix; // matrix uniform location 0

out gl_PerVertex { vec4 gl_Position; }; // required because of ARB_separate_shader_objects
out vec2 uv;
out vec4 color;

void main() {
    vec2 pos = u_matrix * a_pos;
    gl_Position = vec4(pos, 0, 1);
    uv = a_uv;
    color = vec4(a_color, 1);
}%
SHADER;


glsl_fshader :: #string SHADER
#version 450 core
#line % // actual line number in this file for nicer error messages

in vec2 uv;
in vec4 color;

layout (binding=0) // (from ARB_shading_language_420pack)
uniform sampler2D s_texture; // texture unit binding 0

layout (location=0)
out vec4 o_color; // output fragment data location 0

void main() {
    o_color = color * texture(s_texture, uv);
}%
SHADER;


main :: () {
    conn := xcb_connect(null, null);
    conn_error := xcb_connection_has_error(conn);
    if !conn || conn_error {
        log_error("Couldn't connect to X server: error: %\n", ifx conn_error else -1);
        return;
    }

    // xcb_generic_error_t *error;
    screen := xcb_setup_roots_iterator(xcb_get_setup(conn)).data;
    window := xcb_generate_id(conn);
    attributes: [3]u32 = .[
        0,
        xx xcb_event_mask_t.XCB_EVENT_MASK_KEY_PRESS | .XCB_EVENT_MASK_STRUCTURE_NOTIFY,
        xx xcb_gravity_t.XCB_GRAVITY_STATIC,
    ];

    width  : u16 = 1280;
    height : u16 = 720;
    window_cookie := xcb_create_window_checked(
        conn,
        XCB_COPY_FROM_PARENT,
        window,
        screen.root,
        0, 0, width, height, 1,
        .XCB_WINDOW_CLASS_INPUT_OUTPUT,
        screen.root_visual,
        .XCB_CW_BACK_PIXEL | .XCB_CW_EVENT_MASK | .XCB_CW_BIT_GRAVITY,
        attributes.data,
    );

    error := xcb_request_check(conn, window_cookie);
    if error {
        log_error("Couldn't create X window: error %\n", ifx error else null);
        return;
    }

    xcb_change_property(
        conn,
        xcb_prop_mode_t.XCB_PROP_MODE_REPLACE,
        window,
        xx xcb_atom_enum_t.XCB_ATOM_WM_NAME, xx xcb_atom_enum_t.XCB_ATOM_STRING, 8,
        13,
        "OpenGL Window".data,
    );

    protocols_cookie := xcb_intern_atom(conn, 1, 12, "WM_PROTOCOLS".data);
    delete_cookie := xcb_intern_atom(conn, 0, 16, "WM_DELETE_WINDOW".data);
    wm_protocols := xcb_intern_atom_reply(conn, protocols_cookie, null);
    delete_window := xcb_intern_atom_reply(conn, delete_cookie, null);

    xcb_change_property(conn, .XCB_PROP_MODE_REPLACE, window, wm_protocols.atom, 4, 32, 1, *delete_window.atom);

    GetPlatformDisplayEXT = xx eglGetProcAddress("eglGetPlatformDisplayEXT");

    // initialize EGL
    display: EGLDisplay ;
    attrib_list: []EGLint = .[
        EGL_PLATFORM_XCB_SCREEN_EXT,
        0, // This is a screenp that you can get from 2nd argument of xcb_connect
        EGL_NONE,
    ];

    {
        display = GetPlatformDisplayEXT(
            EGL_PLATFORM_XCB_EXT,
            conn,
            attrib_list.data,
        );
        assert(display != EGL_NO_DISPLAY, "Failed to get EGL display");

        major, minor: EGLint;

        if (!eglInitialize(display, *major, *minor)) {
            log_error("Cannot initialize EGL display\n");
            return;
        }
        if (major < 1 || (major == 1 && minor < 5)) {
            log_error("EGL version 1.5 or higher required\n");
            return;
        }
    }

    // Choose OpenGL API for EGL, by default it uses OpenGL ES
    ok := eglBindAPI(EGL_OPENGL_API);
    assert(xx ok, "Failed to select OpenGL API for EGL");

    // Choose EGL configuration
    config: EGLConfig ;
    {
        attr: []EGLint = .[
            EGL_SURFACE_TYPE,      EGL_WINDOW_BIT,
            EGL_CONFORMANT,        EGL_OPENGL_BIT,
            EGL_RENDERABLE_TYPE,   EGL_OPENGL_BIT,
            EGL_COLOR_BUFFER_TYPE, EGL_RGB_BUFFER,

            EGL_RED_SIZE,      8,
            EGL_GREEN_SIZE,    8,
            EGL_BLUE_SIZE,     8,
            EGL_DEPTH_SIZE,   24,
            EGL_STENCIL_SIZE,  8,

            // uncomment for multisampled framebuffer
            //EGL_SAMPLE_BUFFERS, 1,
            //EGL_SAMPLES,        4, // 4x MSAA

            EGL_NONE,
        ];

        count: EGLint;
        if (!eglChooseConfig(display, attr.data, *config, 1, *count) || count != 1)
        {
            log_error("Cannot choose EGL config\n");
        }
    }

    // Create EGL surface
    surface: *EGLSurface;
    {
        attr: []EGLint = .[
            EGL_GL_COLORSPACE, EGL_GL_COLORSPACE_LINEAR, // or use EGL_GL_COLORSPACE_SRGB for sRGB framebuffer
            EGL_RENDER_BUFFER, EGL_BACK_BUFFER,
            EGL_NONE,
        ];

        surface = eglCreateWindowSurface(display, config, window, attr.data);
        if (surface == EGL_NO_SURFACE) {
            log_error("Cannot create EGL surface\n");
        }
    }

    // Create EGL context
    egl_context: *EGLContext;
    {
        attr: []EGLint = .[
            EGL_CONTEXT_MAJOR_VERSION, 4,
            EGL_CONTEXT_MINOR_VERSION, 5,
            EGL_CONTEXT_OPENGL_PROFILE_MASK, EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT,

            // Ask for debug context for non "Release" builds
            // this is so we can enable debug callback
            EGL_CONTEXT_OPENGL_DEBUG, EGL_TRUE,
            EGL_NONE,
        ];

        egl_context = eglCreateContext(display, config, EGL_NO_CONTEXT, attr.data);
        if (egl_context == EGL_NO_CONTEXT)
        {
            log_error("Cannot create EGL context, OpenGL 4.5 not supported?\n");
            return;
        }
    }

    ok = eglMakeCurrent(display, surface, surface, egl_context);
    assert(xx ok, "Failed to make context current");

    // Load OpenGL functions
    procs_ti := type_info(GL_Procs);
    for procs_ti.members {
        proc_ti := cast(*Type_Info_Procedure) it.type;
        // print("%\n", it.name);
        member_offset := it.offset_in_bytes;
        member := cast(*type_of(proc_ti))(cast(*u8)(*gl_procs) + member_offset);
        member.* = xx eglGetProcAddress(it.name.data);
        if !member.* {
            log_error("You fucked up\n");
        }
        // print("loaded member is %\n", member.*);
    }

    // Enable debug callback
    glDebugMessageCallback(debug_callback, null);
    glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);


    Vertex :: struct {
        position: [2]float;
        uv: [2]float ;
        color: [3]float ;
    };

    // vertex buffer containing triangle vertices
    vbo: GLuint;
    {
        vertex_data := Vertex.[
            .{.[-0.00, +0.75], .[25.0, 50.0], .[1, 0, 0]},
            .{.[+0.75, -0.50], .[0.0,   0.0], .[0, 1, 0]},
            .{.[-0.75, -0.50], .[50.0,  0.0], .[0, 0, 1]},
        ];

        glCreateBuffers(1, *vbo);
        // We can do size_of(type_of(vertex_data)) here because its size is fully known at compile time
        glNamedBufferStorage(vbo, size_of(type_of(vertex_data)), vertex_data.data, 0);
    }

    ti_vertex := type_info(Vertex);

    // Vertex input
    vao: GLuint;
    {
        glCreateVertexArrays(1, *vao);

        vbuf_index := 0;
        glVertexArrayVertexBuffer(vao, xx vbuf_index, vbo, 0, size_of(Vertex));

        a_pos := 0;
        glVertexArrayAttribFormat(vao, xx a_pos, 2, GL_FLOAT, GL_FALSE, xx get_struct_field_info(ti_vertex, "position").offset_in_bytes);
        glVertexArrayAttribBinding(vao, xx a_pos, xx vbuf_index);
        glEnableVertexArrayAttrib(vao, xx a_pos);

        a_uv := 1;
        glVertexArrayAttribFormat(vao, xx a_uv, 2, GL_FLOAT, GL_FALSE, xx get_struct_field_info(ti_vertex, "uv").offset_in_bytes);
        glVertexArrayAttribBinding(vao, xx a_uv, xx vbuf_index);
        glEnableVertexArrayAttrib(vao, xx a_uv);

        a_color := 2;
        glVertexArrayAttribFormat(vao, xx a_color, 3, GL_FLOAT, GL_FALSE, xx get_struct_field_info(ti_vertex, "color").offset_in_bytes);
        glVertexArrayAttribBinding(vao, xx a_color, xx vbuf_index);
        glEnableVertexArrayAttrib(vao, xx a_color);
    }


    // Checkerboard texture, with 50% transparency on black colors
    texture: GLuint;
    {
        pixels := u32.[
            0x80000000, 0xffffffff,
            0xffffffff, 0x80000000,
        ];

        glCreateTextures(GL_TEXTURE_2D, 1, *texture);
        glTextureParameteri(texture, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTextureParameteri(texture, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTextureParameteri(texture, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTextureParameteri(texture, GL_TEXTURE_WRAP_T, GL_REPEAT);

        width  : GLsizei = 2;
        height : GLsizei = 2;
        glTextureStorage2D(texture, 1, GL_RGBA8, width, height);
        glTextureSubImage2D(texture, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels.data);
    }


    // Fragment & vertex shaders for drawing triangle
    pipeline, vshader, fshader: GLuint;
    {
        vshader = glCreateShaderProgramv(GL_VERTEX_SHADER, 1, *tprint(glsl_vshader, #location().line_number, "\0").data);
        fshader = glCreateShaderProgramv(GL_FRAGMENT_SHADER, 1, *tprint(glsl_fshader, #location().line_number, "\0").data);

        linked: GLint;
        glGetProgramiv(vshader, GL_LINK_STATUS, *linked);
        if (!linked) {
            message: [1024]u8;
            glGetProgramInfoLog(vshader, size_of(type_of(message)), null, message.data);
            log_error("%\n", message);
            assert(false, "Failed to create vertex shader!");
        }

        glGetProgramiv(fshader, GL_LINK_STATUS, *linked);
        if (!linked) {
            message: [1024]u8;
            glGetProgramInfoLog(fshader, size_of(type_of(message)), null, message.data);
            log_error("%\n", message);
            assert(false, "Failed to create fragment shader!");
        }

        glGenProgramPipelines(1, *pipeline);
        glUseProgramStages(pipeline, GL_VERTEX_SHADER_BIT, vshader);
        glUseProgramStages(pipeline, GL_FRAGMENT_SHADER_BIT, fshader);
    }

    // Setup global GL state
    {
        // Enable alpha blending
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        // Disble depth testing
        glDisable(GL_DEPTH_TEST);

        // Disable culling
        glDisable(GL_CULL_FACE);
    }

    // use 0 to disable vsync
    vsync := 1;
    ok = eglSwapInterval(display, xx vsync);
    assert(xx ok, "Failed to set vsync for EGL");

    cookie := xcb_map_window_checked(conn, window);
    error = xcb_request_check(conn, cookie);
    if (error) {
        log_error("Couldn't map X11 window: %\n", error);
        return;
    }

    quit := false;
    angle := 0.0;

    current_time: float64;
    last_time: float64;
    while !quit {       
        current_time = seconds_since_init();
        dt := cast(float)(current_time - last_time);
        Clamp(*dt, 0, 0.1);
        last_time = current_time;

        // Process all incoming X11 events
        event: *xcb_generic_event_t;
        event = xcb_poll_for_event(conn);
        if (event) {
            if event.response_type & ~0x80 == XCB_CLIENT_MESSAGE {
                message_event := cast(*xcb_client_message_event_t) event;
                if message_event.data.data32[0] == delete_window.atom {
                    // Window closed, exit
                    quit = true;
                }
                continue;
            }
        }
        // Do you need to free it? I don't know man...
        c_free(event);

        geom_cookie: xcb_get_geometry_cookie_t;
        geometry: *xcb_get_geometry_reply_t;

        geom_cookie = xcb_get_geometry(conn, window);
        geometry = xcb_get_geometry_reply(conn, *geom_cookie, null);
        width = geometry.width;
        height = geometry.height;
        
        // Render only if window size is non-zero
        if (width != 0 && height != 0) {
            // Setup output size covering all client area of window
            glViewport(0, 0, width, height);

            // Clear screen
            glClearColor(0.392, 0.584, 0.929, 1.0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

            // Setup rotation matrix in uniform
            {
                angle += dt * 2.0 * PI / 20.0; // full rotation in 20 seconds
                angle = fmod_cycling(angle, 2.0 * PI);

                aspect := cast(float)height / width;
                matrix := float.[
                    cos(angle) * aspect, -sin(angle),
                    sin(angle) * aspect,  cos(angle),
                ];

                u_matrix: GLint = 0;
                glProgramUniformMatrix2fv(vshader, u_matrix, 1, GL_FALSE, matrix.data);
            }

            // Activate shaders for next draw call
            glBindProgramPipeline(pipeline);

            // Provide vertex input
            glBindVertexArray(vao);

            // Bind texture to texture unit
            s_texture : GLuint = 0; // texture unit that sampler2D will use in GLSL code
            glBindTextureUnit(s_texture, texture);

            // Draw 3 vertices as triangle
            glDrawArrays(GL_TRIANGLES, 0, 3);

            // Swap the buffers to show output
            if (!eglSwapBuffers(display, surface))
            {
                log_error("Failed to swap OpenGL buffers!\n");
            }
        }
        else {
            // Window is minimized, cannot vsync - instead sleep a bit
            if (vsync) {
                sleep_milliseconds(10);
            }
        }
    }
}

libc :: #library,system "libc";
c_free :: (data: *void)  #foreign libc "free";

#import "Basic";
#import "Reflection";
#import "Math";
