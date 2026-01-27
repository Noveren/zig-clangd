const std = @import("std");

const root = @import("./src/root.zig");
pub const Compile = root.Compile;
pub const exportCompileCommands = root.exportCompileCommands;
pub const exportCompileDatabase = root.exportCompileDatabase;

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
}