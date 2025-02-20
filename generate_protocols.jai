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


Raw_Enum :: struct {
    name: string;
    type: string;
    is_bitmask: bool;
    variants: [..]Raw_Enum_Value;
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
    // Seems like "api" attribute on <require> tag happens only onse
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


Preprocessed_Namespace :: struct {
    comment: string;
    vendor: string; // Change to enum later
    // Names of enums that are mentioned in the <enums /> tag, aka groups attribute
    enums: [..]string;
    // flat defines without an attached enum and <unused /> members that get turned into
    // comments
    flat_entries: [..]string;
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

    generate_jai_bindings(*raw_opengl, "./protocols/gl/gl.jai");
    generate_jai_bindings(*raw_egl, "./protocols/gl/egl.jai");
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

generate_jai_bindings :: (raw: *Raw_OpenGL, output_file_path: string) -> bool {
    // TODO: Make it into enum: gl, gles2, glsc...
    api_to_generate := "gl";

    gb: String_Builder;

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

        types_builder, success := generate_bindings(types_opts, log_results=true);
        if !success return success;
        cut_scope_file(*types_builder);

        // Inserting ifdef for GLhalf and Apple
        print_to_builder(
            *gb,
            replace(
                builder_to_string(*types_builder,, temp),
                "GLcharARB :: u8;",
                tprint("GLcharARB :: u8;\n\n%", GLhandleARB_MACOS_Hack),
            ),
        );
    }

    // Generate enums
    enums: Table(string, Raw_Enum);

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
                if it.api && it.api != api_to_generate continue;

                raw_value := it.value;
                // if raw_value 
                if !it.groups && it.name {
                    array_add(*preprocessed.flat_entries, tprint("% :: %;%\n", it.name, it.value, ifx it.comment tprint(" // %", it.comment)));
                } else if it.groups {
                    for g: it.groups {
                        // Specialcasing SpecialNumbers - this is not a real enum, just a bunch of "magic numbers" bungled together in the XML
                        // They even have different types - a couple of them are u64, and others are u32.
                        if g == "SpecialNumbers" {
                            array_add(*preprocessed.flat_entries, tprint("% :: %;%\n", it.name, it.value, ifx it.comment tprint(" // %", it.comment)));
                            continue;
                        }

                        array_add(*preprocessed.enums, g);
                        raw_enum, newly_added := table_find_or_add(*enums, g);
                        if newly_added {
                            raw_enum.name = g;
                            raw_enum.is_bitmask = is_bitmask;
                            raw_enum.type = ifx starts_with(it.value, "-") "GLint" else "GLenum";
                        }
                        array_add(*raw_enum.variants, it);
                    }
                }
            }
            array_add(*preprocessed_namespaces, preprocessed);
        }
    }

    for ns: preprocessed_namespaces {
        if ns.comment {
            print_to_builder(*gb, "// %\n", ns.comment);
        }

        for ns.flat_entries {
            print_to_builder(*gb, it);
        }

        for enum_name: ns.enums {
            enum_, found := table_find(*enums, enum_name);
            if !found continue;

            print_to_builder(*gb, "% :: enum% % {\n", enum_name, ifx enum_.is_bitmask "_flags", enum_.type);
            defer append(*gb, "}\n\n");

            for enum_.variants {
                append(*gb, "    ");
                print_to_builder(
                    *gb,
                    "% :: %;%\n",
                    it.name, it.value, ifx it.comment tprint(" // %", it.comment),
                );
            }

            table_remove(*enums, enum_name);
        }
    }

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

    write_entire_file(output_file_path, builder_to_string(*gb));
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
