/*
TODOS:
- Implement kinds
- When printing outputting types, consider the target platform. For example, don't print EGLsizeiANDROID bullshit unconditionally.
- Vendor khrplatfrom.h and eglplatform.h instead of sourcing them from /usr/include

NOTES:
- We can't use namespaces attribute of <enums> tag, because it's not mentioned in <command> for all extensions.
At least EGL doesn't use these namespaces anywhere. Sadge. But maybe we can still define them as enums but then alias to flat identifiers.
We'll see...

SPECIAL CASES:
  These are supposed to get #ifdef-d in the client code. I probably don't need them at all
  There are more of these
  <enum value="1" name="GL_VERSION_ES_CL_1_0" comment="Not an API enum. API definition macro for ES 1.0/1.1 headers" group="SpecialNumbers"/>
  <enum value="1" name="GL_VERSION_ES_CM_1_1" comment="Not an API enum. API definition macro for ES 1.0/1.1 headers" group="SpecialNumbers"/>
  <enum value="1" name="GL_VERSION_ES_CL_1_1" comment="Not an API enum. API definition macro for ES 1.0/1.1 headers" group="SpecialNumbers"/>
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
    platform_header: string;
    // Raw unstripped C code that we're gonna pass to the Bindingds_Generator
    types: string;
    enum_namespaces: [..]Raw_Enum_Namespace;
    commands_namespace: [..]Raw_Command;
    features: [..]Raw_Feature;
    extensions: [..]Raw_Extension;
}


generated_types: string;


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
    // TODO: Implement, very important!
    api: GL_API;
}


Preprocessed_Commands :: struct {
    name: string;
    return_type: string;
    arguments: []string;
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


features: Feature_Table;
extensions: Extension_Table;
enum_values: Enum_Value_Table;

// TODO: somehow configure output files?
GL_Generation_Options :: struct {
    api: GL_API;
    profile: GL_Profile;
    extensions: []GL_Extension;
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

    raw_egl: Raw_OpenGL;
    raw_egl.platform_header = "/usr/include/EGL/eglplatform.h";

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
    gl_gen_options.api = .GL_VERSION_4_6 | .EGL_VERSION_1_5;
    gl_gen_options.extensions = .["EGL_EXT_platform_xcb"];

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

    // TODO: Garbage, move to generation stage
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
        print_to_builder(
            *types_builder,
            replace(
                builder_to_string(*types_builder,, temp),
                "GLcharARB :: u8;",
                tprint("GLcharARB :: u8;\n\n%", GLhandleARB_MACOS_Hack),
            ),
        );
        generated_types = builder_to_string(*types_builder);
    }

    // Generate enums
    preprocessed_namespaces: [..]Preprocessed_Namespace;
    {
        for raw_namespace: raw.enum_namespaces {
            using raw_namespace;

            b: String_Builder;
            preprocessed: Preprocessed_Namespace;
            // TODO: Think about how and at what point it is better to print the comment
            preprocessed.comment = comment;

            // TODO: Check it different namespaces have conflicting info about some enum being a bitmask?
            is_bitmask := type == "bitmask";

            for values {

                raw_value := it.value;

                // Preprocessed_Enum_Value :: struct {
                //     name: string;
                //     value: string;
                //     comment: string;
                //     // TODO: Implement, very important!
                //     api: GL_API;
                // }
                pe: Preprocessed_Enum_Value;
                pe.name = it.name;
                pe.value = it.value;
                pe.alias = it.alias;
                //if it.alias print("alias: %\n", it.alias);
                pe.comment = it.comment;

                // TODO: properly implement api. This is just to avoid mixing up gl and gles for now
                if !it.api || it.api == "gl" || it.api == "egl" {
                    table_set(*enum_values, pe.name, pe);
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
            // array_add(*preprocessed_namespaces, preprocessed);
        }
    }

    // for ns: preprocessed_namespaces {
    //     if ns.comment {
    //         print_to_builder(*gb, "// %\n", ns.comment);
    //     }

    //     for ns.flat_entries {
    //         print_to_builder(*gb, it);
    //     }

    //     for enum_name: ns.enums {
    //         enum_, found := table_find(*enums, enum_name);
    //         if !found continue;

    //         print_to_builder(*gb, "% :: enum% % {\n", enum_name, ifx enum_.is_bitmask "_flags", enum_.type);
    //         defer append(*gb, "}\n\n");

    //         for enum_.variants {
    //             append(*gb, "    ");
    //             print_to_builder(
    //                 *gb,
    //                 "% :: %;%\n",
    //                 it.name, it.value, ifx it.comment tprint(" // %", it.comment),
    //             );
    //         }

    //         table_remove(*enums, enum_name);
    //     }
    // }

    // Generate commands
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
                    if raw.group {
                        type = raw.group;
                    } else {
                        type = value;
                    }
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
            defer append(*gb, builder_to_string(*cb));

            if raw_command.comment {
                comment_lines := split(raw_command.comment, "\n");
                append(*cb, "/*\n");
                for comment_lines {
                    print_to_builder(*cb, "%\n", it);
                }
                defer append(*cb, "*/\n");
            }
            
            print_to_builder(*cb, "% :: (", raw_command.proto.name);

            params: [..]string;
            for raw_param: raw_command.params {
                formatted := format_param(raw_param);
                array_add(*params, formatted);
            }

            append(*cb, join(..params, ", "));
            type := format_param(raw_command.proto, store_name=false);
            if type == "void" {
                append(*cb, ") #foreign;\n\n");
            } else {
                print_to_builder(*cb, ") -> % #foreign;\n\n", type);
            }
        }
    }

    // Features
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

    // Extensions
    {

        for ex: raw.extensions {
            pe: Preprocessed_Extension;
            pe.name = ex.name;
            pe.comment = ex.comment;

            api: GL_API;
            ti := type_info(GL_API);
            for ex.supported {
                if it == {
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
                    case "disabled"; {
                        pe.disabled = true;
                    }
                    case "egl"; {
                        for ti.names {
                            if  starts_with(it, "EGL_VERSION_") {
                                api |= xx ti.values[it_index];
                            }
                        }
                    }
                    case; assert(false, "%", it);
                }
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
        }
    }

}


generate_jai_bindings :: (options: GL_Generation_Options) -> bool {

    gb: String_Builder;
    // Print types
    {
        // TODO: print per api;
        append(*gb, generated_types);
    }

    // Print enums
    {
        ti := type_info(GL_API);
        for ti.names {
            value := ti.values[it_index];
            if options.api & xx value {
                log("Generating GL bindings for %\n", it);

                feature, found := table_find(*features, it);
                assert(found, tprint("coulnd't find requested api: %", it));

                // Generate all previous apis
                for ti.names {
                    value := ti.values[it_index];
                    if feature.prev_features & xx value {
                        log("Generating required bindings first: %\n", it);

                        prev_feature, found := table_find(*features, it);
                        assert(found, tprint("coulnd't find requested api: %", it));

                        print_to_builder(*gb, "%", tprint("\n// %\n", it));

                        for prev_feature.enums {
                            if options.profile == .Core && array_find(prev_feature.removes, it) {
                                continue;
                            }

                            enum_value, found := table_find(*enum_values, it);
                            assert(found, tprint("Couldn't find enum value: %", it));

                            print_to_builder(*gb, "% :: %;", enum_value.name, enum_value.value);
                            if enum_value.comment {
                                print_to_builder(*gb, "  // %", enum_value.comment);
                            }
                            if enum_value.alias {
                                print_to_builder(*gb, "\n% :: %;", enum_value.alias, enum_value.name);
                            }
                            append(*gb, "\n");
                        }
                    }
                }
                // Generate actual API. And don't forget the commands!!!
            }
        }
    }
    output_path := "./protocols/gl/gl.jai";
    write_entire_file(output_path, builder_to_string(*gb));
    return true;
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


GLhandleARB_MACOS_Hack :: #run trim(#string DONE
#if OS == .MACOS {
    GLhandleARB :: *void;
} else {
    GLhandleARB :: u32;
}
DONE);

#import "jai-xml";
#import "Basic";
#import "File";
#import "Hash_Table";
table_find_or_add :: find_or_add;
#import "String";
#import "Bindings_Generator";
#import "Reflection";
