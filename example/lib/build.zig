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
    // FIXME 用法错误
    // error: unable to update file from 'C:\Users\no-ve\Noveren\Project\01-Repository\zmake\example\lib\inc\foo.h' to '.zig-cache\o\c600ca2776eec3753b6c5f32f1ca0b47\': IsDir
    // lib.installHeader(b.path("inc/foo.h"), "");
    // error: failed to check cache: '\C:\Users\no-ve\Noveren\Project\01-Repository\zmake\example\lib\inc' file_hash IsDir
    // lib.installHeader(b.path("inc"), "");
    lib.installHeadersDirectory(b.path("src"), "", .{
        .include_extensions = &.{
            ".h",
        }
    });
    lib.installHeadersDirectory(b.path("inc"), "", .{
        .include_extensions = &.{
            ".h",
        }
    });
    b.installArtifact(lib);
}
