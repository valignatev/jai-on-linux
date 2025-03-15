main :: () {
    // signal(SIGPIPE, SIG_IGN);
    wayland_socket_fd := to_string(getenv("WAYLAND_SOCKET"));
    if wayland_socket_fd {
        print("ws: %\n", wayland_socket_fd);
    }

    xdg_runtime_dir := to_string(getenv("XDG_RUNTIME_DIR"));
    wayland_display := to_string(getenv("WAYLAND_DISPLAY"));

    path: string;
    if xdg_runtime_dir {
        path = join(xdg_runtime_dir, wayland_display, separator="/");
    } else {
        gid := sprint("%", getgid());
        defer free(gid);
        path = join("/run/user", gid, wayland_display, separator="/");
    }

    wayland_socket := socket(AF_UNIX, .SOCK_STREAM, 0);
    if wayland_socket < 0 {
        log_error("Couldn't create a wayland socket\n");
        return;
    }

    addr: sockaddr_un;
    addr.sun_family = AF_UNIX;
    assert(path.count <= 107, "sockaddr_un can only handle 108 characters in path, so weak!");
    memcpy(xx addr.sun_path.data, xx path.data, path.count);

    con := connect(wayland_socket, xx *addr, size_of(type_of(addr)));
    if (con < 0) {
        log_error("Couldn't connect to Wayland server at %\n", path);
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

    request_buffer: [..]u32;
    event_buffer: [..]u32;
    array_reserve(*request_buffer, 65536 / size_of(u32));
    array_reserve(*event_buffer, 65536 / size_of(u32));


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
                request_buffer.count = request_buffer.allocated;
                request_buffer[0] = interface_name_uint;

                string_buffer := request_buffer;
                string_buffer.data += 1;
                string_buffer.count -= 1;

                encoded_size := encode_string(interface_name_str, string_buffer);
                request_buffer[1 + encoded_size] = version;
                request_buffer[1 + encoded_size + 1] = wl_shm_id;
                request_buffer.count = encoded_size + 3;
                request := create_request(registry_id, xx Wl_Registry_Requests.BIND, request_buffer);
                print("request: header: %\nbody: %\n", request.header, []u8.{count=request.body.count*4, data=xx request.body.data});

                w = write(wayland_socket, *request.header, size_of(type_of(request.header)));
                if w != size_of(Header) {
                    code, str := System.get_error_value_and_string();
                    log_error("Coulnd't send BIND request Header %\nerror_code: %, message: %\n", interface_name_str, code, str);
                }
                w = write(wayland_socket, request_buffer.data, xx (request_buffer.count * size_of(u32)));
                if w != request.body.count * size_of(u32) {
                    code, str := System.get_error_value_and_string();
                    log_error("Coulnd't send BIND request for %\nerror_code: %, message: %\n", interface_name_str, code, str);
                }
            } else if interface_name_str == "wl_compositor" {
                wl_compositor_id = get_new_id();

                request_buffer.count = request_buffer.allocated;
                request_buffer[0] = interface_name_uint;

                string_buffer := request_buffer;
                string_buffer.data += 1;
                string_buffer.count -= 1;

                encoded_size := encode_string(interface_name_str, string_buffer);
                request_buffer[1 + encoded_size] = version;
                request_buffer[1 + encoded_size + 1] = wl_compositor_id;
                request_buffer.count = encoded_size + 3;
                request := create_request(registry_id, xx Wl_Registry_Requests.BIND, request_buffer);
                print("request: header: %\nbody: %\n", request.header, []u8.{count=request.body.count*4, data=xx request.body.data});

                w = write(wayland_socket, *request.header, size_of(type_of(request.header)));
                if w != size_of(Header) {
                    code, str := System.get_error_value_and_string();
                    log_error("Coulnd't send BIND request Header %\nerror_code: %, message: %\n", interface_name_str, code, str);
                }
                w = write(wayland_socket, request_buffer.data, xx (request_buffer.count * size_of(u32)));
                if w != request.body.count * size_of(u32) {
                    code, str := System.get_error_value_and_string();
                    log_error("Coulnd't send BIND request for %\nerror_code: %, message: %\n", interface_name_str, code, str);
                }
            } else if interface_name_str == "xdg_wm_base" {
                xdg_wm_base_id = get_new_id();

                request_buffer.count = request_buffer.allocated;
                request_buffer[0] = interface_name_uint;

                string_buffer := request_buffer;
                string_buffer.data += 1;
                string_buffer.count -= 1;

                encoded_size := encode_string(interface_name_str, string_buffer);
                request_buffer[1 + encoded_size] = version;
                request_buffer[1 + encoded_size + 1] = xdg_wm_base_id;
                request_buffer.count = encoded_size + 3;
                request := create_request(registry_id, xx Wl_Registry_Requests.BIND, request_buffer);
                print("request: header: %\nbody: %\n", request.header, []u8.{count=request.body.count*4, data=xx request.body.data});

                w = write(wayland_socket, *request.header, size_of(type_of(request.header)));
                if w != size_of(Header) {
                    code, str := System.get_error_value_and_string();
                    log_error("Coulnd't send BIND request Header %\nerror_code: %, message: %\n", interface_name_str, code, str);
                }
                w = write(wayland_socket, request_buffer.data, xx (request_buffer.count * size_of(u32)));
                if w != request.body.count * size_of(u32) {
                    code, str := System.get_error_value_and_string();
                    log_error("Coulnd't send BIND request for %\nerror_code: %, message: %\n", interface_name_str, code, str);
                }
            }
        } else {
            print("Got event: %\n", event);
        }
    }
}


align_u32 :: (original: u32) -> u32 {
    // I don't fucking know how it works, this is just magic from space
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


global_display_id : object : 1;
next_id := global_display_id;

get_new_id :: () -> u32 {
    next_id += 1;
    result := next_id;
    return result;
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


create_request :: (object_id: object, opcode: u32, body: []u32) -> Request {
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


object :: u32;

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
