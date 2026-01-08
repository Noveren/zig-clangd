const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/add.zig"),
        .target = target,
        .optimize = optimize,
    });
    mod.addCSourceFile(.{
        .file = b.path("src/add.c"),
        .flags = &.{},
    });
    mod.addIncludePath(b.path("src"));

    const lib = b.addLibrary(.{
        .name = "add",
        .root_module = mod,
    });
    // TODO 用法错误
    // lib.installHeader(b.path("src"), "");
    lib.installHeadersDirectory(b.path("src"), "", .{
        .include_extensions = &.{
            ".h",
        }
    });
    b.installArtifact(lib);
}
