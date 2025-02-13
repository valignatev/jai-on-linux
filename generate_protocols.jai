/*
TODOS:
- Implement kinds

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

Raw_OpenGL :: struct {
    enum_namespaces: [..]Raw_Enum_Namespace;
    commands_namespace: [..]Raw_Command;
    // features...
}

raw_opengl: Raw_OpenGL;

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
    raw_xml_string, ok := read_entire_file(gl_protocols_path);
    if !ok {
        log_error("Coulnd't open gl.xml\n");
        return;
    }

    success := parse_raw_opengl(*raw_opengl, raw_xml_string);
    if !success {
        log_error("Unable to parse gl.xml\n");
    }

    generate_jai_bindings(*raw_opengl);
}

parse_raw_opengl :: (raw: *Raw_OpenGL, raw_xml_string: string) -> bool {
    root, result := xml_parse(raw_xml_string);
    if result.status != .ok {
        log_error("Problem with XML file: %\n", result.status);
        return false;
    }

    assert(root.type == .document, "Unexpected top level root");
    registry := root.first_child.next_sibling;

    assert(registry.name == "registry", tprint("Expected registry, got: %\n", registry.name));

    registry_item := registry.first_child;
    // jai-xml has a bug in its for_expansion that makes continue statement unusable.
    // So I'm not using it until the bug is fixed
    while registry_item.next_sibling {
        defer registry_item = registry_item.next_sibling;

        if registry_item.name == "enums" {
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
                            case "group"; {
                                groups := split(attr.value, ",");
                                raw_enum_value.groups = groups;
                            }
                                // assert(
                                //     raw_enum_value.group == raw_enum.group,
                                //     tprint("Expected child group to be equal to the parent goup, got % != %\n", raw_enum_value.group, raw_enum.group),
                                // );
                            case "comment"; raw_enum_value.comment = attr.value;
                            case "api";raw_enum_value.api = attr.value;
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

            array_add(*raw_opengl.enum_namespaces, raw_enum_namespace);
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
                array_add(*raw_opengl.commands_namespace, raw_command);
            }
        }
    }

    return true;
}

// Temp shit because we don't have capturing lambdas, and the callback doesn't accept user data lmfao
cdata: [..]string;
done: bool;
parse_raw_command_param :: (param_node: *XMLNode) -> Raw_Command_Param {
    param_child := param_node.first_child;
    result: Raw_Command_Param;
    defer {
        array_reset_keeping_memory(*cdata);
        done = false;
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
        if done return;
        if node.name == "name" {
            done = true;
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

generate_jai_bindings :: (raw_opengl: *Raw_OpenGL) -> bool {
    // TODO: Make it into enum: gl, gles2, glsc...
    api_to_generate := "gl";

    gb: String_Builder;

    // Generate enums
    enums: Table(string, Raw_Enum);

    preprocessed_namespaces: [..]Preprocessed_Namespace;
    {
        for raw_namespace: raw_opengl.enum_namespaces {
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

        // Raw_Command_Param :: struct {
        //     name: string;
        //     class: string;
        //     // Array of combined cdatas of the <param> child nodes, excluding <name>
        //     type: []string;
        //     group: string;
        //     len: string;
        //     kind: string;
        // }
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
        for raw_command: raw_opengl.commands_namespace {
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

            
            // Raw_Command :: struct {
            //     // This comment should be printed before the command. There's only one
            //     // in gl.xml actually
            //     comment: string;
            //     // <ptype> goes here
            //     proto: Raw_Command_Param;
            //     alias: string;
            //     vecequiv: string;
            //     params: [..]Raw_Command_Param;
            // }
        }
    }

    generated_file := "./protocols/gl/gl.jai";
    write_entire_file(generated_file, builder_to_string(*gb));
    return true;
}

table_find_or_add :: find_or_add;

#import "jai-xml";
#import "Basic";
#import "File";
#import "Hash_Table";
#import "String";
