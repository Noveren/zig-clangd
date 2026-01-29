const std = @import("std");
const builtin = @import("builtin");
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
    const content = try json.stringify(allocator);
    defer allocator.free(content);

    if (self.options.debug) {
        std.debug.print("\n{s}\n", .{content});
    }
    const file = try b.build_root.handle.createFile(self.dest_rel_path, .{});
    defer file.close();
    _ = try file.write(content);
}

fn makeExport(
    allocator: Allocator,
    b: *std.Build,
    compile: *const Step.Compile,
    options: Options,
) !CompileCommandsJson {
    const info = try CompileInfo.inspect(allocator, b, compile, options.debug);
    defer info.deinit(allocator);
    if (options.debug) {
        const s_info = try info.stringify(allocator);
        defer allocator.free(s_info);
        std.debug.print("\n{s}\n", .{s_info});
    }

    var set: ?std.BufSet = blk: {
        if (options.exclude_deps) |exclude_deps| {
            var set = std.BufSet.init(allocator);
            for (exclude_deps) |i| {
                try set.insert(i);
            }
            break :blk set;
        }
        if (options.include_deps) |include_deps| {
            var set = std.BufSet.init(allocator);
            for (include_deps) |i| {
                try set.insert(i);
            }
            break :blk set;
        }
        break :blk null;

    };
    defer {
        if (set) |*_set| {
            _set.deinit();
        }
    }
    return convert(allocator, info, set, options);
}

pub const Options = struct {
    cc: []const u8 = "clang",
    // or ZIG_LIB_PATH
    zig_lib_path: ?[]const u8 = null,
    // exclude_deps > include_deps; Include all deps.
    exclude_deps: ?[]const []const u8 = null,
    include_deps: ?[]const []const u8 = null,
    debug: bool = false,
};

fn convert(allocator: Allocator, info: CompileInfo, deps: ?std.BufSet, options: Options) !CompileCommandsJson {
    var json = try CompileCommandsJson.init(allocator);
    var arguments = try std.ArrayList(CompileCommandsJson.Argument).initCapacity(allocator, 16);
    defer arguments.deinit(allocator);

    try arguments.append(allocator, .{ .arg = options.cc });
    try arguments.append(allocator, .{ .c_macro = "__GNUC__" });
    try arguments.append(allocator, .{ .arg = "-target" });
    try arguments.append(allocator, .{ .arg = info.triple });
    try arguments.append(allocator, .{ .c_macro_undef = if (info.native) null else "__STDC_HOSTED__" });

    const zig_lib_path = try getZigLib(allocator, options.zig_lib_path);
    defer allocator.free(zig_lib_path);
    var hosted = try StringHostedArray.init(allocator);
    defer hosted.deinit(allocator);
    switch (info.os) {
        .windows => {
            if (info.link_libcpp) {
                try arguments.append(allocator, .{ .system_include_dirs = &[_][]const u8 {
                    try hosted.join(allocator, &[_][]const u8 { zig_lib_path, "libcxx", "include" }),
                    try hosted.join(allocator, &[_][]const u8 { zig_lib_path, "libcxxabi", "include"}),
                }});
            }
            if (info.link_libc or info.link_libcpp) {
                try arguments.append(allocator, .{ .system_include_dirs = &[_][]const u8 {
                    try hosted.join(allocator, &[_][]const u8 { zig_lib_path, "include" }),
                    try hosted.join(allocator, &[_][]const u8 { zig_lib_path, "libc", "include", "any-windows-any" }),
                }});
            }
            if (info.link_libcpp) {
                try arguments.append(allocator, .{ .system_include_dir = try hosted.join(allocator, &[_][]const u8 {
                    zig_lib_path, "libunwind", "include"
                }) });
                try arguments.append(allocator, .{ .c_macros = &zig_cpp_genernal_c_macros });
            }
        },
        .macos => {
            // FIXME
            if (info.link_libc) {
                try arguments.append(allocator, .{ .system_include_dirs = &[_][]const u8 {
                    try allocator.dupe(u8, "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"),
                    try allocator.dupe(u8, "/opt/homebrew/include"),
                    try allocator.dupe(u8, "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks"),
                }});
            }
        },
        .freestanding => {},
        inline else => |v| {
            std.log.warn("Not adapted os.tag: '{t}'\n", .{v});
        }
    }
    if (!(info.link_libc or info.link_libcpp)) {
        try arguments.append(allocator, .{ .system_include_dir = try hosted.join(allocator, &[_][]const u8 {
            zig_lib_path, "include",
        }) });
    }

    try arguments.append(allocator, .{ .c_macro = if (info.debug) "DEBUG" else null });
    try arguments.append(allocator, .{ .args = info.c_macros });
    try arguments.append(allocator, .{ .include_dirs = info.include.normal });
    try arguments.append(allocator, .{ .system_include_dirs = info.include.system });
    {
        // NOTE: 若为根目录外的源码，需要至少打开一次建立索引后才能跳到源码，否则只能跳到声明
        var include_current_dependency = false;
        for (info.source.dependencies) |dep_info| {
            try arguments.append(allocator, .{ .include_dirs = dep_info.include.installed });
            // TODO 去重，若需添加依赖源码，则构建树同名依赖应该只添加一次
            include_current_dependency = blk: {
                if (options.exclude_deps) |_| {
                    break :blk !deps.?.contains(dep_info.name);
                }
                if (options.include_deps) |_| {
                    break :blk deps.?.contains(dep_info.name);
                }
                break :blk false;
            };
            if (include_current_dependency) {
                var j = try convert(allocator, dep_info, deps, options);
                defer j.deinit(allocator);
                try json.mergeMove(allocator, &j);
            }
        }
        const end_of_common = arguments.items.len;
        for (info.source.c_source_files) |c_source_file| {
            arguments.shrinkRetainingCapacity(end_of_common);
            try arguments.append(allocator, .{ .args = c_source_file.flags });
            try json.appendCloneExt(allocator, c_source_file.file, arguments.items);
        }
    }
    return json;
}

const StringHostedArray = struct {
    hosted: std.ArrayList([]const u8),

    fn init(allocator: Allocator) !@This() {
        return @This() {
            .hosted = try std.ArrayList([]const u8).initCapacity(allocator, 8),
        };
    }

    fn deinit(self: *@This(), allocator: Allocator) void {
        for (self.hosted.items) |item| {
            allocator.free(item);
        }
        self.hosted.deinit(allocator);
    }

    fn join(self: *@This(), allocator: Allocator, paths: []const []const u8) ![]const u8 {
        try self.hosted.append(allocator, try std.fs.path.join(allocator, paths));
        return self.hosted.getLast();
    }

    // fn appendMove(self: *@This(), allocator: Allocator, item: []const u8) ![]const u8 {
    //     try self.hosted.append(allocator, item);
    //     return item;
    // }
};


fn getZigLib(allocator: Allocator, zig_lib_path: ?[]const u8) ![]const u8 {
    const _zig_lib_path = blk: {
        if (zig_lib_path) |v| {
            break :blk try allocator.dupe(u8, v);
        } else {
            var env_map = try std.process.getEnvMap(allocator);
            defer env_map.deinit();
            break :blk try allocator.dupe(u8, env_map.get("ZIG_LIB_DIR").?);
        }
    };
    for (_zig_lib_path) |*byte| {
        switch (byte.*) {
            '/', '\\' => byte.* = std.fs.path.sep,
            else => {},
        }
    }
    // TODO 基于 `zig env` 获得 zig_lib_dir
    return _zig_lib_path;
}

const zig_cpp_genernal_c_macros = [_][]const u8 {
    // windows & macos
    "_LIBCPP_ABI_VERSION=1",
    "_LIBCPP_ABI_NAMESPACE=__1",
    "_LIBCPP_HAS_THREADS=1",
    "_LIBCPP_HAS_MONOTONIC_CLOCK",
    "_LIBCPP_HAS_TERMINAL",
    "_LIBCPP_HAS_MUSL_LIBC=0",
    "_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS",
    "_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS",
    "_LIBCPP_HAS_VENDOR_AVAILABILITY_ANNOTATIONS=0",
    "_LIBCPP_HAS_FILESYSTEM=1",
    "_LIBCPP_HAS_RANDOM_DEVICE",
    "_LIBCPP_HAS_LOCALIZATION",
    "_LIBCPP_HAS_UNICODE",
    "_LIBCPP_HAS_WIDE_CHARACTERS",
    "_LIBCPP_HAS_NO_STD_MODULES",
    "_LIBCPP_PSTL_BACKEND_SERIAL",
    "_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE",
    "_LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS",
};