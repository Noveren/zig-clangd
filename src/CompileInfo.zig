
const std = @import("std");
const Allocator = std.mem.Allocator;
const CompileInfo = @This();

name: []const u8,
link_libc: bool,
link_libcpp: bool,
debug: bool,
c_macros: [][]const u8,
include: Include,
source: Source,

const Include = struct {
    normal: [][]const u8,
    system: [][]const u8,
    installed: [][]const u8,

    fn deinit(self: @This(), allocator: Allocator) void {
        for (self.normal) |i| {
            allocator.free(i);
        }
        allocator.free(self.normal);
        for (self.system) |i| {
            allocator.free(i);
        }
        allocator.free(self.system);
        for (self.installed) |i| {
            allocator.free(i);
        }
        allocator.free(self.installed);
    }
};

const Source = struct {
    c_source_files: []CSourceFile,
    dependencies: []CompileInfo,

    fn deinit(self: @This(), allocator: Allocator) void {
        for (self.c_source_files) |i| {
            i.deinit(allocator);
        }
        allocator.free(self.c_source_files);
        for (self.dependencies) |i| {
            i.deinit(allocator);
        }
        allocator.free(self.dependencies);
    }

    const CSourceFile = struct {
        file: []const u8,
        flags: [][]const u8,

        fn deinit(self: @This(), allocator: Allocator) void {
            allocator.free(self.file);
            for (self.flags) |i| {
                allocator.free(i);
            }
            allocator.free(self.flags);
        }
    };
};


pub fn deinit(self: CompileInfo, allocator: Allocator) void {
    allocator.free(self.name);
    for (self.c_macros) |i| {
        allocator.free(i);
    }
    allocator.free(self.c_macros);
    self.include.deinit(allocator);
    self.source.deinit(allocator);
}

pub fn stringify(self: *const CompileInfo, allocator: std.mem.Allocator) ![]const u8 {
    return std.json.Stringify.valueAlloc(allocator, self, .{
        .whitespace = .indent_2,
    });
}

pub fn inspect(
    allocator: Allocator,
    b: *std.Build,
    compile: *const std.Build.Step.Compile,
    enable_warning: bool
) Allocator.Error!CompileInfo {
    return .{
        .name = try allocator.dupe(u8, compile.name),
        .link_libc = compile.root_module.link_libc orelse false,
        .link_libcpp = compile.root_module.link_libcpp orelse false,
        .debug = if (compile.root_module.optimize) |v| (v == .Debug) else (false),
        .c_macros = try filterCMacros(allocator, b, compile, enable_warning),
        .include = try filterInclude(allocator, b, compile, enable_warning),
        .source = try filterSource(allocator, b, compile, enable_warning),
    };
}

fn filterCMacros(
    allocator: Allocator,
    b: *std.Build,
    compile: *const std.Build.Step.Compile,
    enable_warning: bool,
) Allocator.Error![][]const u8 {
    _ = b;
    _ = enable_warning;
    const items = compile.root_module.c_macros.items;
    var c_macros = try allocator.alloc([]const u8, items.len);
    for (items, 0..) |i, k| {
        c_macros[k] = try allocator.dupe(u8, i);
    }
    return c_macros;
}

fn filterSource(
    allocator: Allocator,
    b: *std.Build,
    compile: *const std.Build.Step.Compile,
    enable_warning: bool,
) Allocator.Error!Source {
    var c_source_files = try std.ArrayList(Source.CSourceFile).initCapacity(allocator, 8);
    var denpendecies = try std.ArrayList(CompileInfo).initCapacity(allocator, 8);
    for (compile.root_module.link_objects.items) |i| {
        switch (i) {
            .other_step => |v| {
                const info = try inspect(allocator, b, v, enable_warning);
                try denpendecies.append(allocator, info);
            },
            .c_source_file => |v| {
                var flags = try allocator.alloc([]const u8, v.flags.len);
                for (v.flags, 0..) |flag, k| {
                    flags[k] = try allocator.dupe(u8, flag);
                }
                try c_source_files.append(allocator, .{
                    .file = try allocator.dupe(u8, v.file.getPath(b)),
                    .flags = flags,
                });
            },
            .c_source_files => |v| {
                const root = v.root.getPath(b);
                for (v.files) |file| {
                    var flags = try allocator.alloc([]const u8, v.flags.len);
                    for (v.flags, 0..) |flag, k| {
                        flags[k] = try allocator.dupe(u8, flag);
                    }
                    try c_source_files.append(allocator, .{
                        .file = try std.fs.path.join(allocator, &[_][]const u8{root, file}),
                        .flags = flags,
                    });
                }
            },
            inline else => |_, tag| {
                if (enable_warning) {
                    std.log.warn("Unhandle LinkObject type: '{any}'.", .{tag});
                }
            }
        }
    }
    c_source_files.shrinkAndFree(allocator, c_source_files.items.len);
    denpendecies.shrinkAndFree(allocator, denpendecies.items.len);
    return .{
        .c_source_files = c_source_files.allocatedSlice(),
        .dependencies = denpendecies.allocatedSlice(),
    };
}

fn filterInclude(
    allocator: Allocator,
    b: *std.Build,
    compile: *const std.Build.Step.Compile,
    enable_warning: bool,
) Allocator.Error!Include {
    var normal = try std.ArrayList([]const u8).initCapacity(allocator, 8);
    var system = try std.ArrayList([]const u8).initCapacity(allocator, 8);
    for (compile.root_module.include_dirs.items) |i| {
        switch (i) {
            .path => |v| try normal.append(allocator, try allocator.dupe(u8, v.getPath(b))),
            .path_system => |v| try system.append(allocator, try allocator.dupe(u8, v.getPath(b))),
            .other_step => {},
            inline else => |_, tag| {
                if (enable_warning) {
                    std.log.warn("Unhandle IncludeDir type: '{any}'.", .{tag});
                }
            }
        }
    }
    normal.shrinkAndFree(allocator, normal.items.len);
    system.shrinkAndFree(allocator, system.items.len);

    var installed = try std.ArrayList([]const u8).initCapacity(allocator, 8);
    for (compile.installed_headers.items) |installed_header| {
        // FIXME getPath() was called on a GeneratedFile that wasn't built yet.
        // installed header 会被复制到当前 .zig-cache 中，但只在编译后可获得 LazyPath 实际路径
        switch (installed_header) {
            .directory => |v| {
                if (getPathNotGenerated(b, v.source)) |not_generated_path| {
                    var _not_generated_path = not_generated_path;
                    if (std.mem.endsWith(u8, not_generated_path, v.dest_rel_path)) {
                        _not_generated_path = not_generated_path[0..(not_generated_path.len - v.dest_rel_path.len)];
                    }
                    try installed.append(allocator, try allocator.dupe(u8, _not_generated_path));
                } else {
                    if (enable_warning) {
                        std.log.warn("'{s}' is generated installed header directory and it isn't added into compile_commands.json.", .{v.source.basename(b, null)}); // generated
                    }
                }
            },
            .file => |v| {
                if (enable_warning) {
                    std.log.warn("'{s}' is install header file and it isn't added into compile_commands.json.", .{v.source.getDisplayName()});
                }
            },
        }
    }
    installed.shrinkAndFree(allocator, installed.items.len);

    return .{
        .normal = normal.allocatedSlice(),
        .system = system.allocatedSlice(),
        .installed = installed.allocatedSlice(),
    };
}

fn getPathNotGenerated(b: *std.Build, path: std.Build.LazyPath) ?[]const u8 {
    switch (path) {
        .generated => {
            return null;
        },
        else => |v| {
            return v.getPath(b);
        },
    }
}