const testing = @import("std").testing;

pub fn Parameters(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Child = T;

        a: T,
        b: T,
        current: u8 = 0,

        pub fn init(state: T) Self {
            return Self{
                .a = state,
                .b = state,
            };
        }

        pub fn initSeparate(state_a: T, state_b: T) Self {
            return Self{
                .a = state_a,
                .b = state_b,
            };
        }

        pub fn read(self: Self) T {
            const current = @atomicLoad(u8, &self.current, .SeqCst);

            if (current == 0) {
                return self.a;
            } else {
                return self.b;
            }
        }

        pub fn write(self: *Self, new_state: T) void {
            const current = @atomicLoad(u8, &self.current, .SeqCst);

            if (current == 0) {
                self.b = new_state;
                @atomicStore(u8, &self.current, 1, .SeqCst);
            } else {
                self.a = new_state;
                @atomicStore(u8, &self.current, 0, .SeqCst);
            }
        }
    };
}

test "Parameters" {
    const Point = Parameters(struct {
        x: u8 = 0,
        y: u8 = 1,
    });

    var p = Point.init(.{});

    const state = p.read();
    testing.expectEqual(@as(u8, 0), state.x);
    testing.expectEqual(@as(u8, 1), state.y);

    p.write(.{
        .x = 1,
        .y = 0,
    });

    const state2 = p.read();
    testing.expectEqual(@as(u8, 0), state2.y);
    testing.expectEqual(@as(u8, 1), state2.x);
}
