
const std = @import("std");
const clangd = @import("clangd/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "demo",
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibCpp();
    exe.addCSourceFile(.{ .file = b.path("src/main.cc") });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // -Dclangd
    const clangd_emit = b.option(bool, "clangd", "Enable to generate clangd config") orelse false;
    if (clangd_emit) {
        try clangd.CompileCommandsJson.generate(b, exe.root_module, .{
            .cstd = .{ .arch_os_abi = "any-windows-any", .cxx = true }
         });
    }
}