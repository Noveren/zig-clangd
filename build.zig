const std = @import("std");

// const clangd = @import("./src/root.zig");
// pub const Json = clangd.Json;
// pub const CompileCommandsJson = clangd.CompileCommandsJson;
// pub const Config = clangd.Config;

const root = @import("./src/root.zig");
pub const stringifyCompile = root.stringifyCompile;
pub const generateCompileCommansJson = root.generateCompileCommandsJson;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .root_source_file = b.path("./src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const check = b.addExecutable(.{
        .name = "zmake",
        .root_module = mod,
    });
    const check_step = b.step("check", "");
    check_step.dependOn(&check.step);
    const exe_test = b.addTest(.{
        .root_module = mod,
    });
    const run_exe_test = b.addRunArtifact(exe_test);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_test.step);

    // const write_file = b.addWriteFile("./compile_commands.json", "[]");
}