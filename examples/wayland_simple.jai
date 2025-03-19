main :: () {
    // signal(SIGPIPE, SIG_IGN);

    wg_initted := wanger_init();
    if !wg_initted {
        log_error("Couldn't setup Wayland connection\n");
        return;
    }

    registry_id := get_new_id();

    msg: [3]u32;
    msg[0] = global_display_id;
    msg[1] = xx Wl_Display_Requests.GET_REGISTRY | (12 << 16);
    msg[2] = registry_id;

    w := write(wayland_socket, msg.data, msg.count * size_of(u32));

    if (w < 0) {
        log_error("Couldn't send wl_display.get_registry request");
        return;
    }

    registry_done_callback_id := get_new_id();


    // wl_display:sync
    msg[0] = global_display_id;
    msg[1] = xx Wl_Display_Requests.SYNC | (12 << 16);
    msg[2] = registry_done_callback_id;
    // print("id: %\n", registry_done_callback_id);

    w = write(wayland_socket, msg.data, msg.count * size_of(u32));

    if (w < 0) {
        log_error("Couldn't send wl_display.sync request");
        return;
    }

    wl_shm_id : object = 0;
    wl_compositor_id : object = 0;
    xdg_wm_base_id : object = 0;
    while true {
        event, success := read_event(wayland_socket, event_buffer);
        if !success {
            log_error("you fucked up\n");
            break;
        }

        // print("event: %\n", formatStruct(event, 1, true));
        if event.object_id == registry_done_callback_id {
            break;
        }

        if event.object_id == 1 && event.opcode == 0 {
            log_wayland_error(event);
        }

        if event.object_id == registry_id && event.opcode == xx Wl_Registry_Events.GLOBAL {
            interface_name_uint := event.body[0];
            interface_name_str := decode_string(*event.body[1]);
            version := event.body[1 + 1 + align_u32(xx (interface_name_str.count + 1))/4];
            print("interface: %, %, v%\n", interface_name_uint, interface_name_str, version);

            if interface_name_str == "wl_shm" {
                wl_shm_id = get_new_id();
                wl_bind := Wl_Registry_Bind.{
                    name=interface_name_uint,
                    interface_="wl_shm",
                    version=version,
                    interface_id=wl_shm_id,
                };
                success := encode_body(wl_bind, *request_buffer);
                request := create_request(registry_id, xx Wl_Registry_Requests.BIND, request_buffer);
                success = write_request(wayland_socket, request);
                if !success {
                    log_error("% bind failed\n", interface_name_str);
                    break;
                }
            } else if interface_name_str == "wl_compositor" {
                wl_compositor_id = get_new_id();
                wl_bind := Wl_Registry_Bind.{
                    name=interface_name_uint,
                    interface_="wl_compositor",
                    version=version,
                    interface_id=wl_compositor_id,
                };

                success := encode_body(wl_bind, *request_buffer);
                request := create_request(registry_id, xx Wl_Registry_Requests.BIND, request_buffer);
                success = write_request(wayland_socket, request);
                if !success {
                    log_error("% bind failed\n", interface_name_str);
                    break;
                }
            } else if interface_name_str == "xdg_wm_base" {
                xdg_wm_base_id = get_new_id();
                wl_bind := Wl_Registry_Bind.{
                    name=interface_name_uint,
                    interface_="xdg_wm_base",
                    version=version,
                    interface_id=xdg_wm_base_id,
                };
                success := encode_body(wl_bind, *request_buffer);

                request := create_request(registry_id, xx Wl_Registry_Requests.BIND, request_buffer);
                success = write_request(wayland_socket, request);
                if !success {
                    log_error("% bind failed\n", interface_name_str);
                    break;
                }
            }
        } else {
            print("Got event: %\n", event);
        }
    }
}


object :: u32;
global_display_id : object : 1;

get_new_id :: (wg : *Wanger = context.wanger) -> u32 {
    defer wg._next_id += 1;

    id := wg._next_id;
    return id;
}


Wanger :: struct {
    socket_fd: s32;
    sockaddr: sockaddr_un;
    _next_id: object = global_display_id + 1;

    request_buffer: [..]u32;
    event_buffer: [..]u32;
}


#add_context wanger: *Wanger;
wanger_init :: () -> success: bool {
    wanger := New(Wanger);

    wayland_display := to_string(getenv("WAYLAND_DISPLAY"));
    wayland_socket := to_string(getenv("WAYLAND_SOCKET"));

    path: string;
    defer free(path);

    // First, try WAYLAND_DISPLAY
    if wayland_display {
        path = get_socket_path(wayland_display);
    } else if wayland_socket {
        // Try WAYLAND_SOCKET
        if wayland_socket {
            socket_fd, success := string_to_int(wayland_socket, T=s32);

            // WAYLAND_SOCKET is set but it's nonsense
            if !success {
                log_error(
                    "Tried to connect to the compositor through WAYLAND_SOCKET, but its value is nonsense: %\n",
                    wayland_socket,
                );
                return false;
            }

            wanger.socket_fd = socket_fd;
        }
    }

    if !path && !wanger.socket_fd {
        // Final resort - try wayland-0. Some messed up configurations might use it.
        path = get_socket_path("wayland-0");
    }

    if path {
        socket_fd := socket(AF_UNIX, .SOCK_STREAM, 0);
        if socket_fd < 0 {
            code, err:= System.get_error_value_and_string();
            log_error("Couldn't create a Wayland socket descriptor (socket 2 failed): errno % - %\n", code, err);
            return false;
        }

        addr: sockaddr_un;
        addr.sun_family = AF_UNIX;
        assert(path.count <= 107, "sockaddr_un can only handle 108 characters in path by default, we don't support extended cases yet, sorry!");
        memcpy(xx addr.sun_path.data, xx path.data, path.count);

        connected := connect(socket_fd, xx *addr, size_of(type_of(addr)));
        if (connected < 0) {
            code, err:= System.get_error_value_and_string();
            log_error("Couldn't connect to Wayland server at %: errno % - %\n", path, code, err);
            return false;
        }

        wanger.socket_fd = socket_fd;
        wanger.sockaddr = addr;
    }

    // size of the Wayland request and event is u16, which means that
    // each individual payload can't be more than 2^16 bytes in size.
    array_reserve((*wanger.request_buffer).(*Resizable_Array), 16438, size_of(u32));
    array_reserve((*wanger.event_buffer).(*Resizable_Array), 16384, size_of(u32));
    context.wanger = wanger;

    return true;
}


get_socket_path :: (socket_name: string) -> string {
    xdg_runtime_dir := to_string(getenv("XDG_RUNTIME_DIR"));

    path: string;
    if xdg_runtime_dir {
        path = join(xdg_runtime_dir, socket_name, separator="/");
    } else {
        gid := sprint("%", getgid());
        defer free(gid);
        path = join("/run/user", gid, socket_name, separator="/");
    }

    return path;
}


Wl_Registry :: struct {
    id: object;
}

registry_bind :: (registry: Wl_Registry, name: u32, interface_: string, version: u32, interface_id: object, wg: *Wanger = context.wanger) {
    // 
};


Wl_Registry_Bind :: struct {
    name: u32;
    interface_: string;
    version: u32;
    interface_id: object;
}


align_u32 :: (original: u32) -> u32 {
    number_for_masking : u32 : 3;
    return (original + 3) & ~number_for_masking;
}


Wl_Display_Requests :: enum {
    SYNC :: 0;
    GET_REGISTRY :: 1;
}


Wl_Display_Events :: enum {
    ERROR :: 0;
    DELETE_ID :: 1;
}


Wl_Registry_Requests :: enum {
    BIND :: 0;
}


Wl_Registry_Events :: enum {
    GLOBAL :: 0;
    GLOBAL_REMOVE :: 1;
}


Wl_Callback_Events :: enum {
    DONE :: 0;
}


Header :: struct {
    object_id: object;
    opcode: u16;
    size: u16;
} #no_padding;


Event :: struct {
    using header: Header;
    body: []u32;
}


Request :: struct {
    using header: Header;
    body: []u32;
}


read_header :: inline (wayland_fd: s32) -> Header, success: bool {
    header: Header;
    size := read(wayland_fd, *header, size_of(Header));
    if size < size_of(Header) {
        // todo: log actual error
        log_error("Coulnd't read header from wayland socket\n");
        return header, false;
    }

    return header, true;
}


read_event :: (wayland_fd: s32, buffer: []u32) -> Event, success: bool {
    event: Event;
    event.body = buffer;
    header, success := read_header(wayland_fd);
    event.header = header;
    if !success {
        return event, false;
    }

    event_body_size := header.size - size_of(Header);
    event.body.count = event_body_size / size_of(u32);
    read_size := read(wayland_fd, xx event.body.data, xx event_body_size);
    if read_size != event_body_size {
        log_error("Failed to read event body. Expected to read %, but only read %\n", event.body.count, read_size);
        return event, false;
    }

    // print("Event size: %\n", header.size);
    return event, true;
}


write_request :: (wayland_fd: s32, request: Request) -> success: bool {
    // print("request: header: %\nbody: %\n", request.header, []u8.{count=request.body.count*4, data=xx request.body.data});
    header_size: u32 = size_of(type_of(request.header));
    w := write(wayland_fd, *request.header, header_size);
    if w != header_size {
        code, str := System.get_error_value_and_string();
        log_error("Coulnd't send % Header \nerror_code: %, message: %\n", request.header.opcode, code, str);
        return false;
    }
    body_size: u32 = xx (request.body.count * size_of(u32));
    w = write(wayland_fd, request.body.data, body_size);
    if w != body_size {
        code, str := System.get_error_value_and_string();
        log_error("Coulnd't send % Request \nerror_code: %, message: %\n", request.header.opcode, code, str);
        return false;
    }
    return true;
}


create_request :: (object_id: object, opcode: u32, buffer: []u32) -> Request {
    request: Request;

    request.object_id = object_id;
    request.opcode = xx,force opcode;
    request.size = xx,force (size_of(Header) + body.count * size_of(u32));
    request.body = body;
    return request;
}

log_wayland_error :: (event: Event) {
    object_id := event.body[0].(object);
    code := event.body[1];
    msg := decode_string(*event.body[3]);

    log_error("Got error\n Object: %\n Code: %\n Message: %\n", object_id, code, msg);
}


decode_string :: (wayland_string: *u32) -> string {
    result: string;
    // counts in wayland strings include null terminators
    result.count = wayland_string.* - 1;
    result.data = xx (wayland_string + 1);
    return result;
}


encode_string :: (source: string, buffer: []u32) -> size: u32 {
    count := source.count + 1;
    size : u32 = xx (align_u32(size_of(u32) + count.(u32,force)) / size_of(u32));
    assert(size <= buffer.count, "string is too big");
    buffer[0] = xx count;
    memcpy(*buffer[1], source.data, source.count);

    return size;
}

encode_body :: (body: $T, buffer: *[..]u32) -> success: bool {
    buffer.count = buffer.allocated;
    ti := type_info(T);
    #assert type_of(ti) == *Type_Info_Struct;

    cursor := 0;
    for m: ti.members {
        // print("type: %\n", m.type.(*Type).*);
        // print("%\n", it_index);
        offset := m.offset_in_bytes;
        if m.type.type == .INTEGER && m.type.runtime_size == 4 {
            value := ((*body).(*u8) + offset).(*u32).*;
            buffer.*[cursor] = value;
            cursor += 1;
            // print("% = %\n", m.name, value);
        } else if m.type.type == .STRING {
            value := ((*body).(*u8) + offset).(*string).*;
            string_buf := buffer.*;
            string_buf.count -= cursor;
            string_buf.data += cursor;
            size := encode_string(value, string_buf);
            cursor += size;
            // print("% = %\n", m.name, value);
        } else if m.type.type == .ARRAY {
            assert(false, "Arrays are not implemented yet\n");
        } else {
            assert(false, "What in the fuck: %\n%\n", formatStruct(m, 1, true), formatStruct(m.type, 1, true));
        }
    }
    buffer.count = cursor;
    return true;
}


sockaddr_un :: struct {
	sun_family: sa_family_t;
	sun_path: [108]u8;
};


#import "Basic";
#import "POSIX";
#import "String";
#import "Socket";
System :: #import "System";


libc :: #library,system "libc";
