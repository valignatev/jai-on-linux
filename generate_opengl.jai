/*
TODOS:
- Implement kinds
- When printing outputting types, consider the target platform. For example, don't print EGLsizeiANDROID bullshit unconditionally.
- Vendor khrplatfrom.h and eglplatform.h instead of sourcing them from /usr/include

- Explore an idea of just trying to load every EGL extension instead of checking if they are available, because the API surface is small.

NOTES:
- We can't use namespaces attribute of <enums> tag, because it's not mentioned in <command> for all extensions.
At least EGL doesn't use these namespaces anywhere. Sadge. But maybe we can still define them as enums but then alias to flat identifiers.
We'll see...
*/
Raw_Enum_Value :: struct {
    api: string;
    value: string;
    name: string;
    alias: string;
    type: string;
    groups: []string;
    comment: string;
}


Raw_Enum_Namespace :: struct {
    namespace: string;
    start: string;
    end: string;
    vendor: string;
    group: string;
    type: string;
    comment: string;
    values: [..]Raw_Enum_Value;
}


Raw_Command :: struct {
    // This comment should be printed before the command. There's only one
    // in gl.xml actually
    comment: string;
    // <ptype> goes here
    proto: Raw_Command_Param;
    alias: string;
    vecequiv: string;
    params: [..]Raw_Command_Param;
}


Raw_Command_Param :: struct {
    name: string;
    class: string;
    // Array of combined cdatas of the <param> child nodes, excluding <name>
    type: []string;
    group: string;
    len: string;
    kind: string;
}


Raw_Require_Remove :: struct {
    // Seems like "api" attribute on <require> tag happens only once
    // in GL_ARB_framebuffer_object extension?
    api: string;
    profile: string;
    comment: string;
    enums: [..]string;
    commands: [..]string;
}


Raw_Feature :: struct {
    api: string;
    name: string;
    number: string;
    requires: [..]Raw_Require_Remove;
    removes: [..]Raw_Require_Remove;
}


Raw_Extension :: struct {
    name: string;
    comment: string;
    // I assume this is like a condition for the extension to be supported, but
    // that's just my guess. I need to ask someone who actually knows.
    protect: string;
    // Separated by | - e.g. something like "gl|clcore|gles"
    supported: []string;
    // Test if maybe extensions have only a single require block
    requires: [..]Raw_Require_Remove;
}

Raw_OpenGL :: struct {
    // name of the xml file. So if the file is gl.xml, name will be "gl".
    name: string;
    platform_header: string;
    // Raw unstripped C code that we're gonna pass to the Bindingds_Generator
    types: string;
    enum_namespaces: [..]Raw_Enum_Namespace;
    commands_namespace: [..]Raw_Command;
    features: [..]Raw_Feature;
    extensions: [..]Raw_Extension;
}


Preprocessed_Namespace :: struct {
    comment: string;
    vendor: string; // Change to enum later
    // Names of enums that are mentioned in the <enums /> tag, aka groups attribute
    enums: [..]string;
    // flat defines without an attached enum and <unused /> members that get turned into
    // comments
    flat_entries: [..]string;
}


// TODO: Implement
Preprocessed_Enum :: struct {
    name: string;
    type: string;
    is_bitmask: bool;
    variants: [..]Preprocessed_Enum_Value;
}


Preprocessed_Enum_Value :: struct {
    name: string;
    alias: string;
    value: string;
    comment: string;
    api: GL_API;
}


Preprocessed_Command :: struct {
    comment: string;
    name: string;
    alias: string;
    vecequiv: string;
    return_type: string;
    arguments: [..]string;
}


Preprocessed_Feature :: struct {
    // todo: alias for flags or some kind of making sure that there's only one set here
    // at a time;
    api: GL_API;
    // Previous versions of the protocol that this one should support;
    prev_features: GL_API;
    // TODO: what to do with profile="compatibility" on <require> ?
    // I thought that <remove> should handle that, but apparently not???
    enums: []string;
    commands: []string;
    removes: []string;
}


Preprocessed_Extension :: struct {
    // TODO: implement "protect"
    name: string;
    disabled: bool;
    comment: string;
    api: GL_API;
    enums_core:   [..]string;
    enums_compat: [..]string;
    commands_core:   [..]string;
    commands_compat: [..]string;
}


// TODO: Key doesn't have to be a string here
GL_Prev_Features :: Table(string, GL_API);
gl_prev_features: GL_Prev_Features;

GL_API :: enum_flags u64 {
    GL_VERSION_1_0;
    GL_VERSION_1_1;
    GL_VERSION_1_2;
    GL_VERSION_1_3;
    GL_VERSION_1_4;
    GL_VERSION_1_5;

    GL_VERSION_2_0;
    GL_VERSION_2_1;

    GL_VERSION_3_0;
    GL_VERSION_3_1;
    GL_VERSION_3_2;
    GL_VERSION_3_3;

    GL_VERSION_4_0;
    GL_VERSION_4_1;
    GL_VERSION_4_2;
    GL_VERSION_4_3;
    GL_VERSION_4_4;
    GL_VERSION_4_5;
    GL_VERSION_4_6;

    // gles1
    GL_VERSION_ES_CM_1_0;
    // gles2
    GL_ES_VERSION_2_0;
    GL_ES_VERSION_3_0;
    GL_ES_VERSION_3_1;
    GL_ES_VERSION_3_2;

    // glsc2
    GL_SC_VERSION_2_0;

    EGL_VERSION_1_0;
    EGL_VERSION_1_1;
    EGL_VERSION_1_2;
    EGL_VERSION_1_3;
    EGL_VERSION_1_4;
    EGL_VERSION_1_5;

    // Unsupported for now (or forever)
    GLX_VERSION_1_0;
    GLX_VERSION_1_1;
    GLX_VERSION_1_2;
    GLX_VERSION_1_3;
    GLX_VERSION_1_4;

    WGL_VERSION_1_0;
}


GL_Extension :: string;

GL_Profile :: enum {
    Core;
    Compatibility;
}


Feature_Table    :: Table(string, Preprocessed_Feature);
Extension_Table  :: Table(string, Preprocessed_Extension);
Enum_Value_Table :: Table(string, Preprocessed_Enum_Value);
Command_Table    :: Table(string, Preprocessed_Command);
// A table of types from xml file name to the generated string;
// So if the file was gl.xml, key will be "gl"
Types_Table      :: Table(string, string);


types: Types_Table;
enum_values: Enum_Value_Table;
commands: Command_Table;
features: Feature_Table;
extensions: Extension_Table;

// TODO: somehow configure output files?
GL_Generation_Options :: struct {
    api: GL_API;
    profile: GL_Profile;
    extensions: []GL_Extension;
    output_directory: string;
}


main :: () {
    gl_protocols_path := "./protocols/gl/gl.xml";
    egl_protocols_path := "./protocols/gl/egl.xml";

    raw_gl_xml_string, ok := read_entire_file(gl_protocols_path);
    if !ok {
        log_error("Coulnd't open gl.xml\n");
        return;
    }
    raw_egl_xml_string:, ok= read_entire_file(egl_protocols_path);
    if !ok {
        log_error("Coulnd't open egl.xml\n");
        return;
    }

    raw_opengl: Raw_OpenGL;
    raw_opengl.platform_header = "/usr/include/KHR/khrplatform.h";
    raw_opengl.name = "gl";

    raw_egl: Raw_OpenGL;
    raw_egl.platform_header = "/usr/include/EGL/eglplatform.h";
    raw_egl.name = "egl";

    success: bool;
    success = parse_raw_opengl(*raw_opengl, raw_gl_xml_string);
    if !success {
        log_error("Unable to parse gl.xml\n");
    }

    success = parse_raw_opengl(*raw_egl, raw_egl_xml_string);
    if !success {
        log_error("Unable to parse egl.xml\n");
    }

    preprocess_raw_opengl(*raw_opengl);
    preprocess_raw_opengl(*raw_egl);

    gl_gen_options: GL_Generation_Options;
    gl_gen_options.api = .GL_VERSION_3_3 | .EGL_VERSION_1_5;
    gl_gen_options.extensions = .[
        "GL_ARB_direct_state_access",
        "GL_ARB_separate_shader_objects",
        "GL_KHR_debug",
        "EGL_EXT_platform_xcb",
        "EGL_EXT_platform_base",
        "GL_EXT_texture_filter_anisotropic",
        "GL_EXT_texture_sRGB",
        "GL_EXT_texture_compression_s3tc",
        "GL_ARB_texture_compression_bptc",
        "GL_ARB_internalformat_query2",
        "GL_ARB_debug_output",
    ];
    gl_gen_options.output_directory = "./protocols/gl/";

    generate_jai_bindings(gl_gen_options);
}

types_builder: String_Builder;
types_done: bool;
parse_raw_opengl :: (raw: *Raw_OpenGL, raw_xml_string: string) -> bool {
    root, result := xml_parse(raw_xml_string);
    if result.status != .ok {
        log_error("Problem with XML file: %\n", result.status);
        return false;
    }

    // TODO: Maybe submit a patch to jai-xml that does this cdata collection
    // And that accepts user data to the callback, and returns something that indicates a walk
    // iterator that it's time to stop.
    cb :: (node: *XMLNode) {
        if types_done return;
        // kinds for gl.xml, enums for egl.xml
        if node.name == "kinds" || node.name == "enums" {
            types_done = true;
            return;
        }

        if node.type == .pcdata {
            // urlencode 101 boysssss
            value := replace(node.value, "&lt;", "<");
            value = replace(value, "&gt;", ">");
            if node.prev_sibling && node.prev_sibling.name == "name" {
                // Massive hack for jai-xml eating a whitespace at the beginning
                // of cdata. I need to report this
                print_to_builder(*types_builder, " %", value);
            } else {
                append(*types_builder, value);
            }
        }

        if node.name == "type" && node.first_child {
            append(*types_builder, "\n");
        }
    }

    assert(root.type == .document, "Unexpected top level root");
    registry := root.first_child.next_sibling;

    assert(registry.name == "registry", tprint("Expected registry, got: %\n", registry.name));

    registry_item := registry.first_child;
    // jai-xml has a bug in its for_expansion that makes continue statement unusable.
    // So I'm not using it until the bug is fixed
    while registry_item {
        defer registry_item = registry_item.next_sibling;

        if registry_item.name == "types" {

            xml_walk_depthfirst(registry_item, cb);
            types_string := builder_to_string(*types_builder);
            types_done = false;
            raw.types = types_string;

        } else if registry_item.name == "enums" {
            raw_enum_node := registry_item;
            raw_enum_namespace: Raw_Enum_Namespace;

            for raw_enum_node.attributes {
                if it.name == {
                    case "namespace"; raw_enum_namespace.namespace = it.value;
                    case "start"; raw_enum_namespace.start = it.value;
                    case "end"; raw_enum_namespace.end = it.value;
                    case "vendor"; raw_enum_namespace.vendor = it.value;
                    case "group"; raw_enum_namespace.group = it.value;
                    case "type"; raw_enum_namespace.type = it.value;
                    case "comment"; raw_enum_namespace.comment = it.value;
                    case; log_error("Unexpected enums attribute: %\n", it.*);
                }
            }

            first_child := raw_enum_node.first_child;
            while first_child {
                defer first_child = first_child.next_sibling;

                raw_enum_value: Raw_Enum_Value;
                if first_child.name == "enum" {
                    for attr: first_child.attributes {
                        if attr.name == {
                            case "value"; raw_enum_value.value = attr.value;
                            case "name"; raw_enum_value.name = attr.value;
                            case "alias"; raw_enum_value.alias = attr.value;
                            case "group"; {
                                groups := split(attr.value, ",");
                                raw_enum_value.groups = groups;
                            }
                            case "comment"; raw_enum_value.comment = attr.value;
                            case "api"; raw_enum_value.api = attr.value;
                            case "type"; raw_enum_value.type = attr.value;
                            case; assert(false, tprint("Unexpected <enum> attribute: %", attr.name));
                        }
                    }
                } else if first_child.name == "unused" {
                    b: String_Builder;
                    for attr: first_child.attributes {
                        if attr.name == {
                            case "start"; print_to_builder(*b, "% ", attr.value);
                            case "end"; print_to_builder(*b, "to % - ", attr.value);
                            case "vendor"; print_to_builder(*b, "% - ", attr.value);
                            case "comment"; print_to_builder(*b, attr.value);
                        }
                    }

                    raw_enum_value.comment = builder_to_string(*b);
                }
                array_add(*raw_enum_namespace.values, raw_enum_value);
            }

            array_add(*raw.enum_namespaces, raw_enum_namespace);
        } else if registry_item.name == "commands" {
            command_node := registry_item.first_child;

            // Iterating over all of the commands
            comment_to_remember: string;
            while command_node {
                defer command_node = command_node.next_sibling;

                raw_command: Raw_Command;
                if comment_to_remember {
                    raw_command.comment = comment_to_remember;
                    comment_to_remember = "";
                }

                if command_node.type == .comment {
                    comment_to_remember = command_node.value;
                    continue;
                }

                assert(
                    command_node.name == "command",
                    tprint("Expect first child of <commands> to be <command>, got %", command_node.name),
                );

                proto_node := command_node.first_child;
                assert(
                    proto_node.name == "proto",
                    tprint("Expect first child of the <command /> node to be <proto>, got %", proto_node.name),
                );

                // Parse proto
                raw_command.proto = parse_raw_command_param(proto_node);

                // Parse params and other shit
                next_node := proto_node.next_sibling;
                while next_node {
                    defer next_node = next_node.next_sibling;
                   
                    ifx next_node.name == {
                        case "param"; {
                            param := parse_raw_command_param(next_node);
                            array_add(*raw_command.params, param);
                        }
                        case "alias";
                        case "vecequiv"; {
                            raw_command.alias = attribute_get_value(next_node, "name");
                        }
                        case "glx"; // Fuck GLX, all my homies hate GLX
                        case; {
                            assert(false, tprint("Unexpected command child node: %\n", next_node.name));
                        }
                    }
                }
                array_add(*raw.commands_namespace, raw_command);
            }
        } else if registry_item.name == "feature" {
            raw_feature: Raw_Feature;

            for attr: registry_item.attributes {
                if attr.name == {
                    case "api"; raw_feature.api = attr.value;
                    case "name"; raw_feature.name = attr.value;
                    case "number"; raw_feature.number = attr.value;
                    case; assert(false, tprint("unexpected feature attribute: %", attr.name));
                }
            }

            require_remove_node := registry_item.first_child;

            // Iterating over all of the requires or removes of the feature.
            while require_remove_node {

                defer require_remove_node = require_remove_node.next_sibling;

                if require_remove_node.type != .element {
                    // There are comments that we just skip for now. Doesn't look like
                    // they're that much useful in an actual generated code.
                    continue;
                }

                raw_require_remove := parse_raw_require_remove(require_remove_node);

                if require_remove_node.name == "require" {
                    array_add(*raw_feature.requires, raw_require_remove);
                } else if require_remove_node.name == "remove" {
                    array_add(*raw_feature.removes, raw_require_remove);
                } else {
                    assert(false, tprint("Unexpected <feature> child node: %\n", require_remove_node.name));
                }
            }
            array_add(*raw.features, raw_feature);

        } else if registry_item.name == "extensions" {

            extension_node := registry_item.first_child;
            while extension_node {
                defer extension_node = extension_node.next_sibling;

                if extension_node.name != "extension" {
                    assert(false, tprint("Unexpected <extensions> child: %", extension_node.name));
                }

                raw_extension: Raw_Extension;

                for attr: extension_node.attributes {
                    if attr.name == {
                        case "name"; raw_extension.name = attr.value;
                        case "protect"; raw_extension.protect = attr.value;
                        case "supported"; {
                            splitted := split(attr.value, "|");
                            raw_extension.supported = splitted;
                        }
                        case "comment"; raw_extension.comment = attr.value;
                        case; assert(false, tprint("unexpected extension attribute: %", attr.name));
                    }
                }

                require_node := extension_node.first_child;

                // Iterating over all of the requires of the extension;
                while require_node {
                    defer require_node = require_node.next_sibling;

                    if require_node.name != "require" {
                        assert(false, tprint("Unexpected <extension> child: %", require_node.name));
                    }

                    require := parse_raw_require_remove(require_node);
                    array_add(*raw_extension.requires, require);
                }

                array_add(*raw.extensions, raw_extension);
            }
        } else {
            // print("%\n", formatStruct(registry_item, 1, true));
        }
    }

    return true;
}

// Temp shit because we don't have capturing lambdas, and the callback doesn't accept user data lmfao
cdata: [..]string;
param_cdata_done: bool;
parse_raw_command_param :: (param_node: *XMLNode) -> Raw_Command_Param {
    param_child := param_node.first_child;
    result: Raw_Command_Param;
    defer {
        array_reset_keeping_memory(*cdata);
        param_cdata_done = false;
        reset_temporary_storage();
    }

    for param_node.attributes {
        if it.name == {
            case "kind"; result.kind = it.value;
            case "class"; result.class = it.value;
            case "group"; result.group = it.value;
            case "len"; result.len = it.value;
            case; assert(false, "unexpected attr % on node: %", it.name, xml_write(param_node));
        }
    }

    // TODO: Maybe submit a patch to jai-xml that does this cdata collection
    // And that accepts user data to the callback, and returns something that indicates a walk
    // iterator that it's time to stop.
    cb :: (node: *XMLNode) {
        if param_cdata_done return;
        if node.name == "name" {
            param_cdata_done = true;
            return;
        }

        if node.type == .pcdata {
            splitted := split(node.value, " ",, temp);
            for splitted {
                value := trim(it);
                if value array_add(*cdata, value);
            }
        }
    }
    xml_walk_depthfirst(param_child, cb);
    assert(cdata.count > 0, "expected cdata to be populated. Tag is: %", xml_write(param_node));

    result.type = array_copy(cdata);
    
    while param_child && param_child.name != "name" {
        param_child = param_child.next_sibling;
    }

    assert(param_child && param_child.name == "name", "Unexpected command proto, couldn't find name: %", xml_write(param_node));
    assert(param_child.next_sibling == null, "Expected name to be the last child of the param: %", xml_write(param_node));

    result.name = trim(param_child.first_child.value);
    return result;
}

parse_raw_require_remove :: (require_remove_node: *XMLNode) -> Raw_Require_Remove {
    raw_require_remove: Raw_Require_Remove;
    for attr: require_remove_node.attributes {
        if attr.name == {
            case "comment"; raw_require_remove.comment = attr.value;
            case "profile"; raw_require_remove.profile = attr.value;
            case "api"; raw_require_remove.api = attr.value;
            case; assert(false, tprint("Unexpected <%> attribute: %=\"%\"", require_remove_node.name, attr.name, attr.value));
        }
    }

    // Stands for require_remove_child, but I couldn't be bothered to spell it every time.
    rr_child := require_remove_node.first_child;
    while rr_child {
        defer rr_child = rr_child.next_sibling;

        if rr_child.type != .element {
            // There are comments that we just skip for now. Doesn't look like
            // they're that much useful in an actual generated code.
            continue;
        }
        if rr_child.name == "type" {
            // We always provide all typedefs, so no need to pick those individually.
            // I'm like 83% confident that it's the right way to go.
            continue;
        }

        if rr_child.name == {
            case "enum"; #through;
            case "command"; {
                for attr: rr_child.attributes {
                    if attr.name == {
                        case "name"; {
                            if rr_child.name == "enum" {
                                array_add(*raw_require_remove.enums, attr.value);
                            } else {
                                array_add(*raw_require_remove.commands, attr.value);
                            }
                        }
                        case "comment"; // Skip comments, at least for now
                        case; assert(false, tprint("Unexpected % attribute: %", rr_child.name, attr.name));
                    }
                }
            }
            case; assert(false, tprint("Unexpected % inside of %", rr_child.name, require_remove_node.name));
        }
    }
    return raw_require_remove;
}


preprocess_raw_opengl :: (raw: *Raw_OpenGL) -> bool {
    table_set(*gl_prev_features, "GL_VERSION_1_0", 0);
    table_set(*gl_prev_features, "GL_VERSION_1_1", .GL_VERSION_1_0);
    table_set(*gl_prev_features, "GL_VERSION_1_2", .GL_VERSION_1_0 | .GL_VERSION_1_1);
    table_set(*gl_prev_features, "GL_VERSION_1_3", .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2);

    table_set(
        *gl_prev_features,
        "GL_VERSION_3_1",
        .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2 | .GL_VERSION_1_3 |
        .GL_VERSION_1_4 | .GL_VERSION_1_5 | .GL_VERSION_2_0 | .GL_VERSION_2_1 |
        .GL_VERSION_3_0,
    );
    table_set(
        *gl_prev_features,
        "GL_VERSION_3_2",
        .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2 | .GL_VERSION_1_3 |
        .GL_VERSION_1_4 | .GL_VERSION_1_5 | .GL_VERSION_2_0 | .GL_VERSION_2_1 |
        .GL_VERSION_3_0 | .GL_VERSION_3_1,
    );
    table_set(
        *gl_prev_features,
        "GL_VERSION_3_3",
        .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2 | .GL_VERSION_1_3 |
        .GL_VERSION_1_4 | .GL_VERSION_1_5 | .GL_VERSION_2_0 | .GL_VERSION_2_1 |
        .GL_VERSION_3_0 | .GL_VERSION_3_1 | .GL_VERSION_3_2,
    );

    table_set(
        *gl_prev_features,
        "GL_VERSION_4_0",
        .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2 | .GL_VERSION_1_3 |
        .GL_VERSION_1_4 | .GL_VERSION_1_5 | .GL_VERSION_2_0 | .GL_VERSION_2_1 |
        .GL_VERSION_3_0 | .GL_VERSION_3_1 | .GL_VERSION_3_2 | .GL_VERSION_3_3,
    );

    table_set(
        *gl_prev_features,
        "GL_VERSION_4_6",
        .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2 | .GL_VERSION_1_3 |
        .GL_VERSION_1_4 | .GL_VERSION_1_5 | .GL_VERSION_2_0 | .GL_VERSION_2_1 |
        .GL_VERSION_3_0 | .GL_VERSION_3_1 | .GL_VERSION_3_2 | .GL_VERSION_3_3 |
        .GL_VERSION_4_0 | .GL_VERSION_4_1 | .GL_VERSION_4_2,
    );
    table_set(
        *gl_prev_features,
        "GL_VERSION_4_6",
        .GL_VERSION_1_0 | .GL_VERSION_1_1 | .GL_VERSION_1_2 | .GL_VERSION_1_3 |
        .GL_VERSION_1_4 | .GL_VERSION_1_5 | .GL_VERSION_2_0 | .GL_VERSION_2_1 |
        .GL_VERSION_3_0 | .GL_VERSION_3_1 | .GL_VERSION_3_2 | .GL_VERSION_3_3 |
        .GL_VERSION_4_0 | .GL_VERSION_4_1 | .GL_VERSION_4_2 | .GL_VERSION_4_3 |
        .GL_VERSION_4_4 | .GL_VERSION_4_5,
    );

    table_set(
        *gl_prev_features,
        "EGL_VERSION_1_5",
        .EGL_VERSION_1_0 | .EGL_VERSION_1_1 | .EGL_VERSION_1_2 | .EGL_VERSION_1_3 |
        .EGL_VERSION_1_4,
    );

    gb: String_Builder;

    types_builder: String_Builder;
    // Generate types
    {
        // Writing types code into a temporary file because Bindings_Generator
        // doesn't work with in-memory code.
        // Even though it seems like it would be very easy to add this funcionality
        temp_types_file := "./temp.h";
        write_entire_file(temp_types_file, raw.types);
        defer file_delete(temp_types_file);

        types_opts: Generate_Bindings_Options;
        types_opts.add_generator_command = false;
        types_opts.strip_enum_prefixes = false;

        array_add(*types_opts.source_files, raw.platform_header);
        array_add(*types_opts.source_files, temp_types_file);
        array_add(*types_opts.typedef_prefixes_to_unwrap, "khronos_");
        types_opts.generate_compile_time_struct_checks = false;
        types_opts.try_to_preserve_comments = true;
        types_opts.mimic_spacing_flags = .STRUCT | .GLOBAL;
        types_opts.visitor = gl_types_visitor;

        types_builder, success := generate_bindings(types_opts, log_results=false);
        if !success return success;
        cut_scope_file(*types_builder);

        // Inserting ifdef for GLhalf and Apple
        if raw.name == "gl" {
            print_to_builder(
                *types_builder,
                replace(
                    builder_to_string(*types_builder,, temp),
                    "GLcharARB :: u8;",
                    tprint("GLcharARB :: u8;\n\n%", GLhandleARB_MACOS_Hack),
                ),
            );
        } else if raw.name == "egl" {
            print_to_builder(*types_builder, "%", EGL_CAST_Hack);
        }
        table_set(*types, raw.name, builder_to_string(*types_builder));
    }

    // Preprocess enums
    {
        for raw_namespace: raw.enum_namespaces {
            using raw_namespace;

            b: String_Builder;

            // TODO: Think about how and at what point it is better to print the comment
            // TODO: Check it different namespaces have conflicting info about some enum being a bitmask?
            is_bitmask := type == "bitmask";

            for values {
                raw_value := it.value;

                pe: Preprocessed_Enum_Value;
                pe.name = it.name;
                pe.value = it.value;
                pe.alias = it.alias;
                pe.comment = it.comment;

                if !it.api {
                    table_set(*enum_values, pe.name, pe);
                } else {
                    api := api_from_string(it.api);
                    pe.api = api;
                }

                // TODO: groups
                // if !it.groups && it.name {
                //     array_add(*preprocessed.flat_entries, tprint("% :: %;%\n", it.name, it.value, ifx it.comment tprint(" // %", it.comment)));
                // } else if it.groups {
                //     for g: it.groups {
                //         // Specialcasing SpecialNumbers - this is not a real enum, just a bunch of "magic numbers" bungled together in the XML
                //         // They even have different types - a couple of them are u64, and others are u32.
                //         if g == "SpecialNumbers" {
                //             array_add(*preprocessed.flat_entries, tprint("% :: %;%\n", it.name, it.value, ifx it.comment tprint(" // %", it.comment)));
                //             continue;
                //         }

                //         array_add(*preprocessed.enums, g);
                //         raw_enum, newly_added := table_find_or_add(*enums, g);
                //         if newly_added {
                //             raw_enum.name = g;
                //             raw_enum.is_bitmask = is_bitmask;
                //             raw_enum.type = ifx starts_with(it.value, "-") "GLint" else "GLenum";
                //         }
                //         array_add(*raw_enum.variants, it);
                //     }
                // }
            }
        }
    }

    // Preprocess commands
    {
        format_param :: (raw: Raw_Command_Param, store_name: bool = true) -> string {
            // pb stands for param_builder
            pb: String_Builder;

            pointer_level: string;
            type: string;

            for raw.type {
                value := trim(replace(it, "const", "",, temp));

                if !value {
                    continue;
                }

                if contains(value, "*") {
                    pointer_level = value;
                } else {
                    // TODO: handle groups
                    // if raw.group {
                    //     type = raw.group;
                    // } else {
                    // char leaked in egl.xml
                    if value == "char" {
                        type = "u8";
                    } else {
                        type = value;
                    }
                    // }
                }
            }
            if store_name {
                name := raw.name;
                if name == "context" name = "context_";
                if name == "string" name = "string_";
                print_to_builder(*pb, "%1: %2%3", name, pointer_level, type);
            } else {
                print_to_builder(*pb, "%1%2", pointer_level, type);
            }
            
            return builder_to_string(*pb);
        }
        // cb stands for command_builder
        cb: String_Builder;
        for raw_command: raw.commands_namespace {
            pc: Preprocessed_Command;
            // defer append(*gb, builder_to_string(*cb));

            comment_builder: String_Builder;
            if raw_command.comment {
                comment_lines := split(raw_command.comment, "\n");
                append(*comment_builder, "/*\n");
                for comment_lines {
                    print_to_builder(*comment_builder, "%\n", it);
                }
                append(*comment_builder, "*/\n");

                pc.comment = builder_to_string(*comment_builder);
            }

            pc.name = raw_command.proto.name;
            pc.return_type = format_param(raw_command.proto, store_name=false);
            // print_to_builder(*cb, "% :: (", raw_command.proto.name);

            for raw_param: raw_command.params {
                formatted := format_param(raw_param);
                array_add(*pc.arguments, formatted);
            }

            pc.alias = raw_command.alias;
            pc.vecequiv = raw_command.vecequiv;

            table_set(*commands, pc.name, pc);

            // append(*cb, join(..params, ", "));
            // if type == "void" {
            //     append(*cb, ") #foreign;\n\n");
            // } else {
            //     print_to_builder(*cb, ") -> % #foreign;\n\n", type);
            // }
        }
    }

    // Preprocess features
    {
        for feature: raw.features {
            pf: Preprocessed_Feature;
            pf.api = enum_name_to_value(GL_API, feature.name);
            prev_features, found := table_find(*gl_prev_features, feature.name);
            if found {
                pf.prev_features = prev_features;
            }
            enums: [..]string;
            commands: [..]string;
            for req: feature.requires {
                for req.enums {
                    array_add(*enums, it);
                }
                for req.commands {
                    array_add(*commands, it);
                }
            }
            pf.enums = enums;
            pf.commands = commands;
            removes: [..]string;

            for req: feature.removes {
                for req.enums {
                    array_add(*removes, it);
                }
                for req.commands {
                    array_add(*removes, it);
                }
            }

            pf.removes = removes;
            table_set(*features, feature.name, pf);
            // print("%\n", formatStruct(pf, 1, true));
        }
    }

    // Preprocess extensions
    {

        for ex: raw.extensions {
            pe: Preprocessed_Extension;
            pe.name = ex.name;
            pe.comment = ex.comment;

            api: GL_API;
            for ex.supported {
                if it == "disabled" {
                    pe.disabled = true;
                    continue;
                }
                api |= api_from_string(it);
            }
            pe.api = api;

            for require: ex.requires {
                if require.profile {
                    if require.profile == "compatibility" {
                        for require.enums {
                            array_add(*pe.enums_compat, it);
                        }
                        for require.commands {
                            array_add(*pe.commands_compat, it);
                        }
                    } else {
                        // Should never happen
                        assert(false, "this should never happen, but we found unexpected extension profile: %\n", require.profile);
                    }
                } else {
                    for require.enums {
                        array_add(*pe.enums_core, it);
                    }
                    for require.commands {
                        array_add(*pe.commands_core, it);
                    }
                }
            }

            table_set(*extensions, pe.name, pe);
        }
    }
    return true;
}


Api_Loader_Info :: struct {
    api: GL_API;
    api_name: string;
    lib_name: string;
    has_loader: bool;
    core_procs: string;
    ext_procs: string;
    supported_extensions_code: string;
}


operator== :: inline (a: Api_Loader_Info, b: Api_Loader_Info) -> bool {
    return a.api_name == b.api_name;
}

operator> :: inline (a: Api_Loader_Info, b: Api_Loader_Info) -> s64 {
    return xx ((cast(u8)a.has_loader) < (cast(u8)b.has_loader));
}

#poke_name Basic operator==;
#poke_name Sort operator>;


generate_jai_bindings :: (options: GL_Generation_Options) -> bool {
    api_enum_info := type_info(GL_API);
    api_infos: [..]Api_Loader_Info;

    for api_enum_info.values {
        if options.api & xx it {
            info := api_to_api_info(xx it);
            if !array_find(api_infos, info) {
                array_add(*api_infos, info);
            }
        }
    }

    // I want to generate platform apis that have getprocaddress first, and
    // core core apis last, so that I can also easily load procaddress function first
    // at runtime. bubble_sort is superior btw!
    bubble_sort(api_infos, (a, b) => a > b);
    for * api_info: api_infos {
        output_path := parse_path(options.output_directory);

        array_add(*output_path.words, tprint("%.jai", api_info.api_name));
        output_path.trailing_slash = false;
        output_file := path_to_string(output_path);

        api_value := api_info.api;
        log("Generating GL bindings for %\n", api_value);

        enum_name := enum_value_to_name(api_value);
        feature, found := table_find(*features, enum_name);
        assert(found, tprint("coulnd't find requested api: %", enum_name));

        gb: String_Builder;
        // Print types
        {
            generated_types, found := table_find(*types, api_info.api_name);
            assert(found, tprint("Couldn't find generated types for %", api_info.api_name));
            append(*gb, generated_types);
        }

        // Print enums
        {

            for api_enum_info.names {
                value := api_enum_info.values[it_index];
                if feature.prev_features & xx value {
                    generate_enum_values(it, options.profile, *gb);
                }
            }
            log("Generating enum values for target feature: %\n", enum_name);
            generate_enum_values(enum_name, options.profile, *gb);

            // Extensions
            for ext_name: options.extensions {
                ext, found := table_find(*extensions, ext_name);
                assert(found, tprint("Couldn't find extension %", ext_name));

                if !(api_value & ext.api) || ext.disabled || table_contains(*already_printed_identifiers, ext.name) {
                    continue;
                }

                if ext.enums_core.count {
                    print_to_builder(*gb, "\n    // %\n", ext.name);
                }
                if ext.comment {
                    print_to_builder(*gb, "// %\n", ext.comment);
                }
                for ext.enums_core {
                    maybe_print_enum_value(it, *gb);
                }
                if options.profile == .Compatibility {
                    for ext.enums_compat {
                        maybe_print_enum_value(it, *gb);
                    }
                }
            }
        }

        // Print commands
        {
            // Print the surrounding struct
            {
                struct_name := tprint("%_Procs", to_upper_copy(api_info.api_name,, temp));
                api_info.core_procs = struct_name;
                print_to_builder(*gb, "\n% :: struct #type_info_procedures_are_void_pointers #type_info_no_size_complaint {", struct_name);
                defer print_to_builder(*gb, "}\n");
                for api_enum_info.names {
                    value := api_enum_info.values[it_index];
                    if feature.prev_features & xx value {
                        generate_commands(it, options.profile, *gb, indent="    ");
                    }
                }
                log("Generating commands for target feature: %\n", enum_name);
                generate_commands(enum_name, options.profile, *gb, indent="    ");
            }


            // Extensions
            struct_name := tprint("%_Ext_Procs", to_upper_copy(api_info.api_name,, temp));
            api_info.ext_procs = struct_name;
            print_to_builder(*gb, "\n% :: struct #type_info_procedures_are_void_pointers #type_info_no_size_complaint {", struct_name);
            defer print_to_builder(*gb, "}\n");
            for ext_name: options.extensions {
                ext, found := table_find(*extensions, ext_name);
                assert(found, tprint("Couldn't find extension %", ext_name));

                if !(api_value & ext.api) || ext.disabled || table_contains(*already_printed_identifiers, ext.name) {
                    continue;
                }

                // TODO: extensions shouldn't be loaded with dlsym, so put a note on them
                // so that the loader knows what to use
                if ext.commands_core.count {
                    if it_index > 0 append(*gb, "\n");
                    print_to_builder(*gb, "\n    // %\n", ext.name);
                }
                if ext.comment {
                    print_to_builder(*gb, "// %\n", ext.comment);
                }
                if ext.commands_core.count {
                    // print_to_builder(*gb, "    using %_ext: struct {\n", ext.name);
                    print_to_builder(*gb, "    %: bool;\n", ext.name);
                }
                for ext.commands_core {
                    maybe_print_command(it, *gb, indent="    ");
                    append(*gb, "\n");
                }
                if options.profile == .Compatibility {
                    for ext.commands_compat {
                        maybe_print_command(it, *gb, indent="    ");
                        append(*gb, "\n");
                    }
                }

                // if ext.commands_core.count {
                //     print_to_builder(*gb, "\n");
                // }
            }
        }
        write_entire_file(output_file, builder_to_string(*gb));
    }

    // Create the module file
    output_path := parse_path(options.output_directory);
    array_add(*output_path.words, "module.jai");
    output_path.trailing_slash = false;
    output_file := path_to_string(output_path);

    // module_builder
    mb: String_Builder;
    // There should be only one of these
    has_supported_extensions_code: Api_Loader_Info;
    for api_infos {
        print_to_builder(*mb, "#load \"./%.jai\";\n", it.api_name);

        if it.supported_extensions_code {
            // TODO: Probably, it's better to put that in a platform file
            // e.g. egl_populate_supported_extensions in egl.jai, and then alias it or something.
            assert(
                has_supported_extensions_code.api_name == "",
                "This shouldn't happen, we only support generating a single platform API at once for now!",
            );
            has_supported_extensions_code = it;
        }
    }

    append(*mb, "\n");

    for api_infos {
        print_to_builder(*mb, "using %_procs: %;\n", it.api_name, it.core_procs);
        print_to_builder(*mb, "using %_ext_procs: %;\n", it.api_name, it.ext_procs);
        // print("%\n", formatStruct(it, 1, true));
    }

    // Loader boilerplate
    print_to_builder(*mb, "\n%\n", SUPPORTED_EXTENSIONS);
    print_to_builder(*mb, "%\n", has_supported_extensions_code.supported_extensions_code);
    print_to_builder(*mb, "%", LOADER_CODE);

    // loader_builder
    lb: String_Builder;
    for api_infos {
        core_var := tprint("%_procs", it.api_name);
        ext_var := tprint("%_ext_proc", it.api_name);
        print_to_builder(*lb, "    result = load_procs(*%, \"%.so\");\n", core_var, it.lib_name);
        append(*lb, "    if !result return result;\n");
    }
    for api_infos {
        core_var := tprint("%_procs", it.api_name);
        ext_var := tprint("%_ext_procs", it.api_name);
        print_to_builder(*lb, "    result = load_extensions(*%);\n", ext_var);
        append(*lb, "    if !result return result;\n");
    }
    print_to_builder(*mb, "\n\n%\n", tprint(GL_LOAD_CODE, builder_to_string(*lb)));

    append(*mb, "\n#scope_file\n\n");
    append(*mb, "#import \"Basic\";\n");
    append(*mb, "#import \"Hash_Table\";\n");
    append(*mb, "#import \"String\";\n");
    append(*mb, "#import \"POSIX\";\n");

    write_entire_file(output_file, builder_to_string(*mb));
    
    return true;
}

Identifiers_Table :: Table(string, bool);
already_printed_identifiers: Identifiers_Table;
generate_enum_values :: (feature_name: string, profile: GL_Profile, builder: *String_Builder, indent: string = "") {
    prev_feature, found := table_find(*features, feature_name);
    assert(found, tprint("coulnd't find requested api: %", feature_name));

    print_to_builder(builder, "%", tprint("\n// %\n", feature_name));

    for prev_feature.enums {
        if profile == .Core && array_find(prev_feature.removes, it) {
            continue;
        }
        maybe_print_enum_value(it, builder);
    }
}


maybe_print_enum_value :: (name: string, builder: *String_Builder) {
    enum_value, found := table_find(*enum_values, name);
    assert(found, tprint("Couldn't find enum value: %", name));
    if table_contains(*already_printed_identifiers, enum_value.name) return;

    value := replace(enum_value.value, "EGL_CAST", "#run EGL_CAST");
    print_to_builder(builder, "% :: %;", enum_value.name, value);
    if enum_value.comment {
        print_to_builder(builder, "  // %", enum_value.comment);
    }
    table_set(*already_printed_identifiers, enum_value.name, true);

    if enum_value.alias && !table_contains(*already_printed_identifiers, enum_value.alias) {
        print_to_builder(builder, "\n% :: %;", enum_value.alias, enum_value.name);
        table_set(*already_printed_identifiers, enum_value.alias, true);
    }
    append(builder, "\n");
}


generate_commands :: (feature_name: string, profile: GL_Profile, builder: *String_Builder, indent: string = "") {
    prev_feature, found := table_find(*features, feature_name);
    assert(found, tprint("coulnd't find requested api: %", feature_name));

    print_to_builder(builder, "\n%", indent);
    print_to_builder(builder, "%", tprint("// %\n", feature_name));

    temp_builder: String_Builder;
    found_loader := false;
    for prev_feature.commands {
        if contains(to_lower_copy(it,, temp), "getprocaddress") {
            found_loader = true;
            maybe_print_command(it, builder, indent);
            append(builder, " @gl_loader");
            append(builder, "\n");
            append_and_steal_buffers(builder, *temp_builder);
            continue;
        }

        if profile == .Core && array_find(prev_feature.removes, it) {
            continue;
        }
        if !found_loader {
            maybe_print_command(it, *temp_builder, indent);
            append(*temp_builder, "\n");
        } else {
            maybe_print_command(it, builder, indent);
            append(builder, "\n");
        }
    }
    if !found_loader append_and_steal_buffers(builder, *temp_builder);
}

maybe_print_command :: (name: string, builder: *String_Builder, indent: string = "") {
    command, found := table_find(*commands, name);
    assert(found, tprint("Couldn't find command: %", name));
    if table_contains(*already_printed_identifiers, command.name) return;

    if command.comment {
        print_to_builder(builder, "\n%", command.comment);
    }
    append(builder, indent);
    print_to_builder(builder, "%: #type (", command.name);
    args := join(..command.arguments, separator=", ");
    print_to_builder(builder, "%)", args);
    if command.return_type && command.return_type != "void" {
        print_to_builder(builder, " -> % #c_call;", command.return_type);
    } else {
        append(builder, " #c_call;");
    }

    table_set(*already_printed_identifiers, command.name, true);
}

gl_types_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {
    // wl_ are wayland typedefs, AHardwareBuffer is some Android bullshit, and GLhandleARB is something we handle manually
    // because it depends on OS
    if starts_with(decl.name, "wl_") || decl.name == "AHardwareBuffer" || decl.name == "GLhandleARB" {
        decl.decl_flags |= .OMIT_FROM_OUTPUT;
    }
    return .RECURSE;
}


// @copypaste
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


api_from_string :: (raw: string) -> GL_API {
    api: GL_API;
    ti := type_info(GL_API);
    if raw == {
        case "gl"; #through;
        case "glcore"; {
            for ti.names {
                if  starts_with(it, "GL_VERSION_") &&  it != "GL_VERSION_ES_CM_1_0" {
                    api |= xx ti.values[it_index];
                }
            }
        }
        case "gles1"; {
            api = .GL_VERSION_ES_CM_1_0;
        }
        case "gles2"; {
            for ti.names {
                if  starts_with(it, "GL_ES_VERSION_") {
                    api |= xx ti.values[it_index];
                }
            }
        }
        case "glsc2"; {
            api = .GL_SC_VERSION_2_0;
        }
        case "egl"; {
            for ti.names {
                if  starts_with(it, "EGL_VERSION_") {
                    api |= xx ti.values[it_index];
                }
            }
        }
        case; assert(false, "%", raw);
    }
    return api;
}

api_to_api_info :: (api: GL_API) -> Api_Loader_Info {
    name := enum_value_to_name(api);

    result: Api_Loader_Info;
    result.api_name = "gl";
    result.api = api;

    if starts_with(name, "GL_VERSION_") &&  name != "GL_VERSION_ES_CM_1_0" {
        result.api_name = "gl";
        result.lib_name = "libGL";
    } else if name == "GL_VERSION_ES_CM_1_0" {
        result.api_name = "gles1";
    } else if starts_with(name, "GL_ES_VERSION_") {
        result.api_name = "gles2";
        result.lib_name = "libGLESv2";
    } else if name == "GL_SC_VERSION_2_0" {
        result.api_name = "glsc2";
    } else if starts_with(name, "EGL_VERSION_") {
        result.api_name = "egl";
        result.lib_name = "libEGL";
        result.has_loader = true;
        result.supported_extensions_code = EGL_SUPPORTED_EXTENSIONS;
    } else {
        assert(false, tprint("api_to_api_info not implemented for %", api));
    }

    return result;
}


GLhandleARB_MACOS_Hack :: #run trim(#string DONE
#if OS == .MACOS {
    GLhandleARB :: *void;
} else {
    GLhandleARB :: u32;
}
DONE);

EGL_CAST_Hack :: #run #string DONE
EGL_CAST :: (type: $T, val: $R) -> R #expand {
    return val;
}
DONE;


LOADER_CODE :: #string DONE
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
DONE


SUPPORTED_EXTENSIONS :: #string DONE
supported_extensions_populated := false;
GL_Available_Extensions :: Table(string, bool);
gl_available_extensions: GL_Available_Extensions;
DONE


EGL_SUPPORTED_EXTENSIONS :: #string DONE
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
DONE

GL_LOAD_CODE :: #string DONE
gl_load :: () -> bool {
    result := true;
%
    return result;
}
DONE

#import "jai-xml";
using Basic :: #import "Basic";
#import "File";
#import "Hash_Table";
table_find_or_add :: find_or_add;
using Sort :: #import "Sort";
#import "String";
#import "Bindings_Generator";
#import "Reflection";
#import "File_Utilities";
