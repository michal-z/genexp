const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("genexp", "src/main.zig");
    //exe.addCSourceFile("external/include/stb_perlin_impl.c", &[_][]const u8{"-std=c99"});
    exe.setTarget(.{
        .cpu_arch = .x86_64,
        .os_tag = .windows,
        .abi = .gnu,
    });
    exe.setBuildMode(mode);
    exe.addIncludeDir("external/include");
    //exe.addLibPath("external/lib");
    //exe.linkSystemLibrary("c");
    //exe.linkSystemLibrary("opengl32");
    //exe.linkSystemLibrary("gdi32");
    //exe.linkSystemLibrary("glfw3");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
