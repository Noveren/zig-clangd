
const std = @import("std");

const clangd = @import("./src/root.zig");
pub const CompileCommandsJson = clangd.CompileCommandsJson;
pub const Config = clangd.Config;

pub fn build(b: *std.Build) void {
    _ = b;
}