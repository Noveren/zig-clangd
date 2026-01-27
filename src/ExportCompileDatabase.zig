const std = @import("std");
const Step = std.Build.Step;
const LazyPath = std.Build.LazyPath;
const InstallDir = std.Build.InstallDir;
const ExportCompileDatabase = @This();
const assert = std.debug.assert;

const base_id: Step.Id = .install_artifact;

step: Step,
artifact: *Step.Compile,
sub_path: []const u8,

pub fn create(
    owner: *std.Build,
    artifact: *Step.Compile,
    sub_path: []const u8,
) *ExportCompileDatabase {
    const self = owner.allocator.create(ExportCompileDatabase) catch @panic("OOM");
    self.* = .{
        .step = Step.init(.{
            .id = base_id,
            .name = "export compile database",
            .owner = owner,
            .makeFn = make,
        }),
        .artifact = artifact,
        .sub_path = owner.dupePath(sub_path),
    };
    // 如果不编译，则无法获得 generated_path
    // self.step.dependOn(&artifact.step);
    return self;
}

fn make(step: *Step, options: Step.MakeOptions) !void {
    _ = options;
    const b = step.owner;
    const self: *ExportCompileDatabase = @fieldParentPtr("step", step);
    // TODO 检查 build.zig 是否有修改

    const file = b.pathJoin(&.{ self.sub_path, "compile_commands.json"});
    try Step.handleVerbose(b, null, &.{ "export ", self.artifact.name, " ", file });

    const cwd = try std.fs.cwd().realpathAlloc(b.allocator, "");
    std.debug.print("cwd: {s}\n", .{cwd});
}