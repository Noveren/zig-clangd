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

    const exe_c = b.addExecutable(.{
        .name = "exe",
        .root_module = mod,
    });
    // b.installArtifact(exe_c);

    const emit_cc = b.option(bool, "compdb", "") orelse false;
    if (emit_cc) {
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

        try zmake.exportCompileCommands(allocator, b, exe_c, .{
            .install_prefix = b.install_prefix
        });
    }
    const step_export = b.step("export", "");
    const export_compdb = zmake.exportCompileDatabase(b, exe_c, null, .{
        .enable_warning = true,
    });
    step_export.dependOn(&export_compdb.step);
}
