const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    // Standalone build
    {
        const mode = b.standardReleaseOptions();
        const target = b.standardTargetOptions(.{});
        const exe = b.addExecutable("zig-synth", "src/main.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        switch (target.os_tag orelse std.builtin.os.tag) {
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

    // WASM build
    {
        const mode = b.standardReleaseOptions();
        const lib = b.addStaticLibrary("zig-synth", "src/main.zig");

        lib.setTarget(std.zig.CrossTarget{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        });

        lib.setBuildMode(mode);
        lib.install();

        const build_html = b.addExecutable("build-html", "build-html.zig");
        build_html.setBuildMode(mode);

        var run_build_cmd = build_html.run();
        run_build_cmd.step.dependOn(&lib.step);

        const cwd = try std.process.getCwdAlloc(b.allocator);
        defer b.allocator.free(cwd);

        const wasm_path = try std.fs.path.join(b.allocator, &[_][]const u8{
            cwd,
            b.lib_dir,
            lib.out_filename,
        });
        defer b.allocator.free(wasm_path);

        const out_html_path = try std.fs.path.join(b.allocator, &[_][]const u8{
            cwd,
            b.exe_dir,
            "zig-synth.html",
        });

        run_build_cmd.addArg(wasm_path);
        run_build_cmd.addArg(out_html_path);

        b.default_step.dependOn(&run_build_cmd.step);
    }

    // Tests
    {
        const mode = b.standardReleaseOptions();
        var main_tests = b.addTest("src/main.zig");
        main_tests.setBuildMode(mode);

        const test_step = b.step("test", "Run library tests");
        test_step.dependOn(&main_tests.step);
    }
}
