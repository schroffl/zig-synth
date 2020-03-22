const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var allocator = &arena_allocator.allocator;
    defer arena_allocator.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) return error.MissingArguments;

    const cwd = fs.cwd();
    const browser_dir = try cwd.openDir("browser", .{});

    const wasm_path = args[1];
    const wasm_file = try cwd.openFile(wasm_path, .{});
    const wasm_content = try readFileAlloc(allocator, wasm_file);
    defer wasm_file.close();
    defer allocator.free(wasm_content);

    const encoded_wasm = try encodeBase64(allocator, wasm_content);
    defer allocator.free(encoded_wasm);

    var sources = try Sources.init(allocator, browser_dir);
    defer sources.deinit();

    const worklet_base64 = try encodeBase64(allocator, sources.worklet_js);
    defer allocator.free(worklet_base64);

    const with_worklet = try replace(allocator, sources.html, "WORKLET_SOURCE", worklet_base64);
    defer allocator.free(with_worklet);
    const with_wasm = try replace(allocator, with_worklet, "WASM_BINARY", encoded_wasm);
    defer allocator.free(with_wasm);
    const with_main = try replace(allocator, with_wasm, "MAIN_SOURCE", sources.index_js);
    defer allocator.free(with_main);

    const hash = std.hash.Murmur2_64.hash(with_main);
    const hash_hex = try std.fmt.allocPrint(allocator, "{x}", .{hash});
    defer allocator.free(hash_hex);

    const with_hash = try replace(allocator, with_main, "VERSION_HASH", hash_hex);
    defer allocator.free(with_hash);

    const out_path = args[2];
    var out = try cwd.createFile(out_path, .{});
    _ = try out.write(with_hash);
}

const Sources = struct {
    allocator: *std.mem.Allocator,
    html: []const u8,
    index_js: []const u8,
    worklet_js: []const u8,

    fn init(allocator: *std.mem.Allocator, dir: fs.Dir) !Sources {
        var self = Sources{
            .allocator = allocator,
            .html = undefined,
            .index_js = undefined,
            .worklet_js = undefined,
        };

        const html_file = try dir.openFile("index.html", .{});
        defer html_file.close();

        const index_js = try dir.openFile("index.js", .{});
        defer index_js.close();

        const worklet_js = try dir.openFile("worklet.js", .{});
        defer worklet_js.close();

        self.html = try readFileAlloc(allocator, html_file);
        self.index_js = try readFileAlloc(allocator, index_js);
        self.worklet_js = try readFileAlloc(allocator, worklet_js);

        return self;
    }

    fn deinit(self: *Sources) void {
        self.allocator.free(self.html);
        self.allocator.free(self.index_js);
        self.allocator.free(self.worklet_js);
    }
};

fn readFileAlloc(allocator: *std.mem.Allocator, file: fs.File) ![]u8 {
    const size = (try file.stat()).size;
    var buffer = try allocator.alloc(u8, size);

    _ = try file.readAll(buffer);

    return buffer;
}

fn encodeBase64(allocator: *std.mem.Allocator, src: []const u8) ![]u8 {
    const size = std.base64.Base64Encoder.calcSize(src.len);
    var buf = try allocator.alloc(u8, size);

    std.base64.standard_encoder.encode(buf, src);

    return buf;
}

fn replace(
    allocator: *std.mem.Allocator,
    src: []const u8,
    needle: []const u8,
    replacement: []const u8,
) ![]u8 {
    const dest = try allocator.alloc(u8, src.len - needle.len + replacement.len);
    errdefer allocator.free(dest);

    const index = std.mem.indexOf(u8, src, needle) orelse return error.NotFound;

    std.mem.copy(u8, dest[0..index], src[0..index]);
    std.mem.copy(u8, dest[index..], replacement);
    std.mem.copy(u8, dest[index + replacement.len ..], src[index + needle.len ..]);

    return dest;
}
