const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("zig-synth", "src/main.zig");
    exe.setBuildMode(mode);
    exe.install();

    exe.linkFramework("CoreFoundation");
    exe.linkFramework("AudioToolbox");

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
