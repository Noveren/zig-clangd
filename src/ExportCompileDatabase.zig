const std = @import("std");
const Step = std.Build.Step;
const LazyPath = std.Build.LazyPath;
const Allocator = std.mem.Allocator;
const InstallDir = std.Build.InstallDir;
const assert = std.debug.assert;
const ExportCompileDatabase = @This();
const CompileInfo = @import("CompileInfo.zig");
const CompileCommandsJson = @import("CompileCommandsJson.zig");

const base_id: Step.Id = .install_artifact;

step: Step,
artifact: *Step.Compile,
dest_rel_path: []const u8,
options: Options,

pub fn exportCompileDatabase(
    b: *std.Build,
    aritifact: *Step.Compile,
    dest_rel_path: ?[]const u8,
    options: Options,
) *ExportCompileDatabase {
    const _dest_rel_path = dest_rel_path orelse "compile_commands.json";
    return .create(b, aritifact, _dest_rel_path, options);
}

fn create(
    owner: *std.Build,
    artifact: *Step.Compile,
    dest_rel_path: []const u8,
    options: Options,
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
        // 根据操作系统替换路径分隔符
        .dest_rel_path = owner.dupePath(dest_rel_path),
        .options = options,
    };
    // 如果不编译，则无法获得 generated_path
    // self.step.dependOn(&artifact.step);
    return self;
}

fn make(step: *Step, _: Step.MakeOptions) !void {
    const b = step.owner;
    const self: *ExportCompileDatabase = @fieldParentPtr("step", step);
    // TODO 检查 build.zig 是否有修改

    try Step.handleVerbose(b, null, &.{ "export", self.artifact.name, self.dest_rel_path });

    var gpa = std.heap.DebugAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        if (status == .leak)  {
            std.log.err("Memeory Leak.\n", .{});
        }
    }
    const allocator = gpa.allocator();
    // const allocator = b.allocator;
    var json = try makeExport(allocator, b, self.artifact, self.options);
    defer json.deinit(allocator);

    // const content = try json.stringify(allocator);
    // defer allocator.free(content);
    // const file = try std.fs.cwd().createFile(self.dest_rel_path, .{});
    // defer file.close();
    // _ = try file.write(content);
}

pub const Options = struct {
    cc: []const u8 = "clang",
    zig_root_path: ?[]const u8 = null,
    enable_warning: bool = false,
};

fn makeExport(
    allocator: Allocator,
    b: *std.Build,
    compile: *const Step.Compile,
    options: Options,
) !CompileCommandsJson {
    const info = try CompileInfo.inspect(allocator, b, compile, options.enable_warning);
    defer info.deinit(allocator);

    const s_info = try info.stringify(allocator);
    defer allocator.free(s_info);
    std.debug.print("\n{s}\n", .{s_info});

    var json = try CompileCommandsJson.init(allocator);
    try json.appendClone(allocator, .{
        .file = "todo.c",
        .directory = "todo",
        .arguments = &.{
            options.cc,
        },
    });
    return json;
}