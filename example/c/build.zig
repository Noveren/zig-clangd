const std = @import("std");
const zmake = @import("zmake");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const dep = b.dependency("lib", .{
        .target = target,
        .optimize = optimize,
    });
    const lib_add = dep.artifact("add");

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    mod.addCMacro("addCMacro", "1");
    mod.addCSourceFile(.{
        .file = b.path("src/main.c"),
        .flags = &.{},
    });
    mod.addCSourceFiles(.{
        .root = b.path("src"),
        .flags = &[_][]const u8 {
            "-DFOO",
        },
        .files = &[_][]const u8 {
            "foo1.c",
            "foo2.c",
        },
    });
    mod.link_libc = true;
    mod.linkLibrary(lib_add);

    const exe = b.addExecutable(.{
        .name = "exe",
        .root_module = mod,
    });
    b.installArtifact(exe);

    const compdb = zmake.exportCompileDatabase(b, exe, null, .{
        .debug = true,
        .include_deps = &[_][]const u8{
            "add",
        },
    });
    const step_compdb = b.step("compdb", "export compile_commands.json");
    step_compdb.dependOn(&compdb.step);
}
