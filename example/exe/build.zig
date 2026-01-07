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

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak)  {
            std.log.err("Memeory Leak.\n", .{});
        }
    }
    // const allocator = b.allocator;

    const s0 = try zmake.stringifyCompile(allocator, exe_c, b);
    defer allocator.free(s0);
    std.debug.print("{s}\n", .{s0});

    const s1 = try zmake.generateCompileCommansJson(allocator, exe_c, b, .{});
    defer allocator.free(s1);
    std.debug.print("{s}\n", .{s1});

    const filename = "compile_commands.json";
    const write_file = b.addWriteFile(filename, s1);
    const p = try write_file.getDirectory().join(b.allocator, filename);
    const install_file = b.addInstallFile(p, filename);

    const create_json_step =  b.step("clangd", "Generate compile_commands.json");
    create_json_step.dependOn(&install_file.step);

    
    // const clangd_emit = b.option(bool, "clangd", "Enable to generate clangd config") orelse false;
    // if (clangd_emit) {

    // }

    // const exe_cxx = b.addExecutable(.{
    //     .name = "cxx",
    //     .root_module = b.createModule(.{
    //         .target = target,
    //         .optimize = optimize,
    //     }),
    // });
    // exe_cxx.addCSourceFile(.{
    //     .file = b.path("src/main.cc"),
    //     .flags = &.{},
    // });
    // exe_cxx.linkLibCpp();
}
