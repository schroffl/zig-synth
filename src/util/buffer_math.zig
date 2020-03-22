const std = @import("std");
const testing = std.testing;

pub fn zero(comptime T: type, out: []T) void {
    std.mem.set(T, out, 0);
}

test "zero" {
    var a: [100]f64 = undefined;

    for (a) |_, i| {
        a[i] = @intToFloat(f64, i);
    }

    zero(f64, &a);

    for (a) |v| {
        testing.expectEqual(@as(f64, 0), v);
    }
}

pub fn add(comptime T: type, a: []const T, b: []const T, out: []T) void {
    std.debug.assert(a.len == b.len);
    std.debug.assert(out.len == a.len);

    for (a) |v, i| {
        out[i] = v + b[i];
    }
}

test "add" {
    const a = [3]f32{ 1, 2, 3 };
    const b = [3]f32{ 1, 2, 3 };

    var out: [3]f32 = undefined;

    add(f32, &a, &b, &out);

    testing.expectEqual(@as(f32, 2), out[0]);
    testing.expectEqual(@as(f32, 4), out[1]);
    testing.expectEqual(@as(f32, 6), out[2]);
}

pub fn mix(comptime T: type, a: []const T, b: []const T, balance: T, out: []T) void {
    std.debug.assert(a.len == b.len);
    std.debug.assert(out.len == a.len);

    const b_balance = 1 - balance;

    for (a) |v, i| {
        out[i] = v * balance + b[i] * b_balance;
    }
}

test "mix" {
    const a = [3]f32{ 1, 2, 3 };
    const b = [3]f32{ 0.7, 2, 3 };

    var out: [3]f32 = undefined;

    mix(f32, &a, &b, 0.5, &out);

    testing.expectEqual(@as(f32, 0.85), out[0]);
    testing.expectEqual(@as(f32, 2), out[1]);
    testing.expectEqual(@as(f32, 3), out[2]);
}

pub fn mult(comptime T: type, a: []const T, b: []const T, out: []T) void {
    std.debug.assert(a.len == b.len);
    std.debug.assert(out.len == a.len);

    for (a) |v, i| {
        out[i] = v * b[i];
    }
}

test "mult" {
    const a = [3]f32{ 1, 2, 3 };
    const b = [3]f32{ 0, 2, 0.5 };

    var out: [3]f32 = undefined;

    mult(f32, &a, &b, &out);

    testing.expectEqual(@as(f32, 0), out[0]);
    testing.expectEqual(@as(f32, 4), out[1]);
    testing.expectEqual(@as(f32, 1.5), out[2]);
}

pub fn multScalar(comptime T: type, a: []const T, scalar: T, out: []T) void {
    std.debug.assert(out.len == a.len);

    for (a) |v, i| {
        out[i] = v * scalar;
    }
}

test "multScalar" {
    const a = [3]f32{ 1, 2, 3 };

    var out: [3]f32 = undefined;

    multScalar(f32, &a, 125.5, &out);

    testing.expectEqual(@as(f32, 125.5), out[0]);
    testing.expectEqual(@as(f32, 251), out[1]);
    testing.expectEqual(@as(f32, 376.5), out[2]);
}

pub fn approxEq(comptime T: type, a: []const T, b: []const T, epsilon: T) bool {
    std.debug.assert(a.len == b.len);

    for (a) |v, i| {
        if (!std.math.approxEq(T, v, b[i], epsilon)) {
            return false;
        }
    }

    return true;
}

test "approxEq" {
    const a = [_]f32{ 0.005, 0.003, 5 };
    const b = [_]f32{ 0.004, 0.002, 5.001 };
    const c = [_]f32{ 0.004, 0.001, 5.001 };

    testing.expect(approxEq(f32, &a, &b, 0.001));
    testing.expect(!approxEq(f32, &a, &c, 0.001));
}
