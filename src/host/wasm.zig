const std = @import("std");
const util = @import("../util.zig");
const midi = @import("../midi.zig");
const synth = @import("../synth.zig");

extern "debug" fn js_err(ptr: [*]const u8, len: usize) void;
extern "debug" fn js_warn(ptr: [*]const u8, len: usize) void;

const allocator = std.heap.page_allocator;
var global_synth: synth.Synth = undefined;

pub const Host = struct {
    pub fn warn(comptime fmt: []const u8, args: var) void {
        const buf = std.fmt.allocPrint(allocator, fmt, args) catch unreachable;
        defer allocator.free(buf);
        js_warn(buf.ptr, buf.len);
    }
};

export fn js_alloc(byte_length: usize) [*]u8 {
    const buffer = allocator.alloc(u8, byte_length) catch unreachable;
    return buffer.ptr;
}

export fn js_free(ptr: [*]u8, byte_length: usize) void {
    const buf = ptr[0..byte_length];
    allocator.free(buf);
}

export fn init_synth(sample_rate: f32) void {
    const format = util.Format{
        .sample_rate = sample_rate,
        .channel_count = 1,
    };

    global_synth = synth.Synth.init(allocator, format) catch unreachable;
}

export fn generate(c_buf: [*]f32, frames: u32) void {
    var buf = c_buf[0..frames];
    global_synth.sampleInto(buf);
}

export fn process_midi(ptr: [*]u8, len: usize) void {
    const buf = ptr[0..len];
    const msg = midi.Message.parse(buf);

    global_synth.handleMIDIMessage(msg);
}

pub fn panic(err: []const u8, maybe_trace: ?*std.builtin.StackTrace) noreturn {
    js_err(err.ptr, err.len);

    while (true) {
        @breakpoint();
    }
}
