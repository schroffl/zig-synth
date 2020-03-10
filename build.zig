const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zig-synth", "src/main.zig");
    exe.setBuildMode(mode);
    exe.install();

    switch (std.builtin.os) {
        .macosx => {
            const sdk_path_raw = try b.exec(&[_][]const u8{
                "xcrun",
                "-show-sdk-path",
            });

            const sdk_path = std.mem.trimRight(u8, sdk_path_raw, "\n");
            const framework_path = try std.mem.concat(b.allocator, u8, &[_][]const u8{
                sdk_path,
                "/System/Library/Frameworks",
            });

            exe.addFrameworkDir(framework_path);

            exe.linkFramework("AppKit");
            exe.linkFramework("CoreFoundation");
            exe.linkFramework("AudioToolbox");
            exe.linkFramework("CoreAudio");
            exe.linkFramework("CoreMIDI");
        },
        else => {},
    }

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
