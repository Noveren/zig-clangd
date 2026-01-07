const std = @import("std");
const clangd = @import("clangd");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const exe_c = b.addExecutable(.{
        .name = "c",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    exe_c.addCSourceFile(.{
        .file = b.path("src/main.c"),
        .flags = &.{},
    });
    exe_c.linkLibC();
    b.installArtifact(exe_c);

    const exe_cxx = b.addExecutable(.{
        .name = "cxx",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    exe_cxx.addCSourceFile(.{
        .file = b.path("src/main.cc"),
        .flags = &.{},
    });
    exe_cxx.linkLibCpp();
    b.installArtifact(exe_cxx);

    const clangd_emit = b.option(bool, "clangd", "Enable to generate clangd config") orelse false;
    if (clangd_emit) {
        try clangd.CompileCommandsJson.generate(b, exe_c.root_module, .{ .cstd = .{ .arch_os_abi = "any-windows-any", .cxx = false } });
        try clangd.CompileCommandsJson.generate(b, exe_cxx.root_module, .{ .cstd = .{ .arch_os_abi = "any-windows-any", .cxx = true } });
    }
}

// // -Dclangd
// if (clangd_emit) {
//     try clangd.CompileCommandsJson.generate(b, exe.root_module, .{
//         .cstd = .{ .arch_os_abi = "any-windows-any", .cxx = false }
//     });
// }
