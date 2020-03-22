pub const Parameters = @import("util/parameters.zig").Parameters;
pub const buffer_math = @import("util/buffer_math.zig");

pub const Format = struct {
    sample_rate: f32 = 44100,
    channel_count: u8 = 1,
};

test "util" {
    _ = @import("util/parameters.zig");
    _ = @import("util/buffer_math.zig");
}
