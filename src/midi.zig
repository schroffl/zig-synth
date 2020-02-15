const std = @import("std");
const helper = @import("helper.zig");
usingnamespace @import("includes.zig");

pub const Message = union(enum) {
    NoteOff: struct {
        channel: u4,
        note: u7,
        velocity: u7,
    },
    NoteOn: struct {
        channel: u4,
        note: u7,
        velocity: u7,
    },
    PolyphonicAftertouch: struct {
        note: u7,
        pressure: u7,
    },
    ControlChange: struct {
        controller: u7,
        value: u7,
    },
    ProgramChange: struct {
        number: u7,
    },
    ChannelAftertouch: struct {
        pressure: u7,
    },
    PitchBend: struct {
        channel: u4,
        value: u14,
    },
    TimingClock: void,
    Unknown: struct {
        length: usize,
    },

    pub fn parse(data: []u8) Message {
        std.debug.assert(data[0] >> 7 == 1);

        const status = @intCast(u3, data[0] >> 4 & 0b111);

        return switch (status) {
            0 => .{
                .NoteOff = .{
                    .channel = @intCast(u4, data[0] & 0xf),
                    .note = @intCast(u7, data[1] & 0x7f),
                    .velocity = @intCast(u7, data[2] & 0x7f),
                },
            },
            1 => .{
                .NoteOn = .{
                    .channel = @intCast(u4, data[0] & 0xf),
                    .note = @intCast(u7, data[1] & 0x7f),
                    .velocity = @intCast(u7, data[2] & 0x7f),
                },
            },
            2 => .{
                .PolyphonicAftertouch = .{
                    .note = @intCast(u7, data[1] & 0x7f),
                    .pressure = @intCast(u7, data[2] & 0x7f),
                },
            },
            3 => .{
                .ControlChange = .{
                    .controller = @intCast(u7, data[1] & 0x7f),
                    .value = @intCast(u7, data[2] & 0x7f),
                },
            },
            4 => .{
                .ProgramChange = .{
                    .number = @intCast(u7, data[1] & 0x7f),
                },
            },
            5 => .{
                .ChannelAftertouch = .{
                    .pressure = @intCast(u7, data[1] & 0x7f),
                },
            },
            6 => .{
                .PitchBend = .{
                    .channel = @intCast(u4, data[0] & 0xf),
                    .value = @intCast(u14, data[1] & 0x7f) | (@intCast(u14, data[2] & 0x7f) << 7),
                },
            },
            7 => parseExtended(data),
        };
    }

    fn parseExtended(data: []u8) Message {
        return switch (data[0]) {
            0xf8 => .{ .TimingClock = {} },
            else => .{
                .Unknown = .{
                    .length = data.len,
                },
            },
        };
    }
};

pub fn noteToFrequency(note: u7) f32 {
    const note_float = @intToFloat(f32, note);

    return 440 * std.math.pow(f32, 2, (@intToFloat(f32, note) - 69) / 12);
}

fn MIDIListener(comptime S: type) type {
    const H = struct {
        fn listener(msg: Message, state: *S) void {}
    };

    const decl = std.meta.declarationInfo(H, "listener");

    return decl.data.Fn.fn_type;
}

pub fn setup(
    proc: MIDIReadProc,
    input_ref: var,
) void {
    var client_ref: MIDIClientRef = undefined;
    const client_name = helper.createCFString("test");

    helper.checkStatus(
        "MIDIClientCreate",
        MIDIClientCreate(
            client_name,
            null,
            null,
            &client_ref,
        ),
    );

    var port_ref: MIDIPortRef = undefined;
    const port_name = helper.createCFString("test-port");

    helper.checkStatus(
        "MIDIInputPortCreate",
        MIDIInputPortCreate(
            client_ref,
            port_name,
            proc,
            input_ref,
            &port_ref,
        ),
    );

    const sources = MIDIGetNumberOfSources();
    var source_i: @TypeOf(sources) = 0;

    while (source_i < sources) : (source_i += 1) {
        const source = MIDIGetSource(source_i);

        helper.checkStatus(
            "MIDIPortConnectSource",
            MIDIPortConnectSource(
                port_ref,
                source,
                null,
            ),
        );
    }
}

pub fn findMIDISource(allocator: *std.mem.Allocator, hint: []const u8) !?MIDIEndpointRef {
    const sources = MIDIGetNumberOfSources();
    var source_i: @TypeOf(sources) = 0;

    while (source_i < sources) : (source_i += 1) {
        const source = MIDIGetSource(source_i);
        var source_name: CFStringRef = undefined;

        helper.checkStatus(
            "MIDIObjectGetStringProperty name",
            MIDIObjectGetStringProperty(
                source,
                kMIDIPropertyName,
                &source_name,
            ),
        );

        const zig_name = try helper.convertCFString(allocator, source_name);
        defer allocator.free(zig_name);

        if (std.mem.indexOf(u8, zig_name, hint) != null) {
            return source;
        }
    }

    return null;
}
