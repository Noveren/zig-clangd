const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const mod = b.createModule(.{
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
    b.installArtifact(lib);
}
