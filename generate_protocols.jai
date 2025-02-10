Raw_Enum_Value :: struct {
    value: string;
    name: string;
    groups: []string;
    comment: string;
}

Raw_Enum :: struct {
    name: string;
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

Raw_OpenGL :: struct {
    enum_namespaces: [..]Raw_Enum_Namespace;
    // Something else
}

raw_opengl: Raw_OpenGL;


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
                // print("tag: %\n", formatStruct(it, 1, true));
            }

            // print("Raw enum: %\n", formatStruct(raw_enum, 1, true));
            array_add(*raw_opengl.enum_namespaces, raw_enum_namespace);
        }
    }

    return true;
}


generate_jai_bindings :: (raw_opengl: *Raw_OpenGL) -> bool {
    global_builder: String_Builder;

    // Generate enums
    enums: Table(string, Raw_Enum);
    flat_defines: Table(string, string);
    {
        for raw_namespace: raw_opengl.enum_namespaces {
            using raw_namespace;

            b: String_Builder;
            // TODO: Think about how and at what point it is better to print the comment
            if comment {
                table_set(*flat_defines, tprint("%_comment", it_index), comment);
            }

            // TODO: Check it different namespaces have conflicting info about some enum being a bitmask?
            is_bitmask := type == "bitmask";

            for values {
                if !it.groups && it.name {
                    table_set(*flat_defines, it.name, tprint("%;%\n", it.value, ifx it.comment tprint(" // %", it.comment)));
                } else if it.groups {
                    for g: it.groups {
                        raw_enum, newly_added := table_find_or_add(*enums, g);
                        if newly_added {
                            raw_enum.name = g;
                            raw_enum.is_bitmask = is_bitmask;
                        }
                        array_add(*raw_enum.variants, it);
                    }
                }
            }  
        }
    }

    for val, name: flat_defines {
        if contains(name, "comment") {
            print_to_builder(*global_builder, "// %\n", val);
        } else {
            print_to_builder(*global_builder, "% :: %", name, val);
        }
    }

    print_to_builder(*global_builder, "\n\n");
    for enum_, name: enums {
        print_to_builder(*global_builder, "% :: enum% GLenum {\n", name, ifx enum_.is_bitmask "_flags");

        defer append(*global_builder, "}\n\n");

        for enum_.variants {
            // Raw_Enum_Value :: struct {
            //     value: string;
            //     name: string;
            //     group: string;
            //     comment: string;
            // }

            append(*global_builder, "    ");
            print_to_builder(
                *global_builder,
                "% :: %;%\n",
                it.name, it.value, ifx it.comment tprint(" // %", it.comment),
            );
        }
    }
    // defer {
    //     append(*b, "}\n\n");
    //     append_and_steal_buffers(*global_builder, *b);
    // }
    // result := builder_to_string(*b);
    // print("%\n", result);


    generated_file := "./protocols/gl/gl.jai";
    write_entire_file(generated_file, builder_to_string(*global_builder));
    return true;
}

table_find_or_add :: find_or_add;

#import "jai-xml";
#import "Basic";
#import "File";
#import "Hash_Table";
#import "String";
