const std = @import("std");
const target = std.Target.current;

pub usingnamespace switch (target.os.tag) {
    .freestanding => switch (target.cpu.arch) {
        .wasm32, .wasm64 => @import("host/wasm.zig"),
        else => @compileError("CPU architecture not supported"),
    },
    .macosx => @import("host/macos.zig"),
    else => @compileError("OS not (yet) supported"),
};

test "main" {
    _ = @import("midi.zig");
    _ = @import("util.zig");
    _ = @import("synth.zig");
}
