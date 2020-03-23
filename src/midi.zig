const std = @import("std");

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
        channel: u4,
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
                    .channel = @intCast(u4, data[0] & 0xf),
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

pub fn noteToFrequency(note: u7) f64 {
    const note_float = @intToFloat(f64, note);

    return 440 * std.math.pow(f64, 2, (@intToFloat(f32, note) - 69) / 12);
}

pub fn frequencyToNote(frequency: f64) ?f64 {
    const result = 12 * std.math.log2(frequency / 440) + 69;

    const upper_bound = @intToFloat(f64, std.math.maxInt(u7));
    const lower_bound = @intToFloat(f64, std.math.minInt(u7));

    if (result >= lower_bound and result <= upper_bound) {
        return result;
    } else {
        return null;
    }
}

// TODO Figure out if a logarithmic relation makes sense here
pub fn velocityToFloat(comptime T: type, velocity: u7) T {
    const max = std.math.log(T, 10, std.math.maxInt(u7) + 1);
    return std.math.log(T, 10, @intToFloat(T, velocity) + 1) / max;
}

test "noteToFrequency" {
    std.testing.expectEqual(@as(f64, 440), noteToFrequency(69));
}

test "frequencyToNote" {
    std.testing.expectEqual(@as(?f64, 69), frequencyToNote(440));
}

test "velocityToFloat" {
    std.testing.expectEqual(@as(f64, 0), velocityToFloat(f64, 0));
    std.testing.expectEqual(@as(f64, 1), velocityToFloat(f64, 127));
}

test "Message.parse" {}
