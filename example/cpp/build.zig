const std = @import("std");
const zmake = @import("zmake");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const dep = b.dependency("lib", .{
    });
    const lib_add = dep.artifact("add");

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    mod.addCSourceFile(.{
        .file = b.path("src/main.cc"),
        .flags = &.{},
    });
    mod.link_libcpp = true;
    mod.linkLibrary(lib_add);

    const exe_c = b.addExecutable(.{
        .name = "exe",
        .root_module = mod,
    });
    // b.installArtifact(exe_c);

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak)  {
            std.log.err("Memeory Leak.\n", .{});
        }
    }
    // const allocator = b.allocator;

    const info = try zmake.Compile.from(allocator, b, exe_c);
    defer info.deinit();
    const info_s = try info.stringify(allocator);
    defer allocator.free(info_s);
    std.debug.print("{s}\n", .{info_s});

    const emit_cc = b.option(bool, "compdb", "") orelse false;
    if (emit_cc) {
        try zmake.exportCompileCommands(allocator, b, exe_c, .{
            .install_prefix = b.install_prefix
        });
    }
}
