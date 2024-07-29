
const std = @import("std");


fn getZigRootPath(b: *std.Build) ![]const u8 {
    const zig_exe_path = try b.findProgram(&.{"zig"}, &.{});
    const zig_root_path = std.fs.path.dirname(zig_exe_path);
    return zig_root_path orelse error.Failed;
}

pub const CompileCommandsJson = struct {
    const Item = struct {
        arguments: []const []const u8,
        directory: []const u8,
        file: []const u8,
    };

    pub const GenerateOptions = struct {
        cstd: ?CStd,

        const CStd = union(enum) {
            // $zig_root_path$/lib/libc/include/$arch_os_abi$
            Libc: []const u8,
            // $zig_root_path$/lib/libcxx/include
            Libcxx,
        };
    };

    pub fn generate(
        b: *std.Build,
        module: std.Build.Module,
        options: GenerateOptions,
    ) !void {
        const systemIncludeDir: [3]?[]const u8 = blk: {
            var ret: [3]?[]const u8 = .{ null, null, null };
            if (getZigRootPath(b)) |zig_root_path| {
                const zig_cc_builtin_include_path = try std.fs.path.resolve(b.allocator, &[_][]const u8 {
                    zig_root_path,
                    "lib/include"
                });
                ret[0] = zig_cc_builtin_include_path;

                if (options.cstd) |cstd| {
                    switch (cstd) {
                        .Libc => |arch_os_abi| {
                            const libc_include_path = try std.fs.path.resolve(b.allocator, &[_][]const u8 {
                                zig_root_path,
                                "lib/libc/include",
                                arch_os_abi,
                            });
                            ret[1] = libc_include_path;
                        },
                        .Libcxx => {
                            ret[2] = try std.fs.path.resolve(b.allocator, &[_][]const u8 {
                                zig_root_path,
                                "lib/libcxx/include"
                            });
                        }
                    }
                }
            } else |_| {
                std.log.err("Failed to get zig_root_path\n", .{});
            }
            break :blk ret;
        };

        const cwd = try std.fs.cwd().realpathAlloc(b.allocator, ".");
        defer b.allocator.free(cwd);

        const c_macros = module.c_macros.items;
        const include_dirs = blk: {
            var ret = std.ArrayList([]const u8).init(b.allocator);
            for (module.include_dirs.items) |include_dir| {
                switch (include_dir) {
                    .path,
                    .path_system,
                    .path_after,
                    .framework_path,
                    .framework_path_system => |p| {
                        try ret.append(p.getPath(b));
                    },
                    .other_step => {},
                    .config_header_step => {},
                }
            }
            break :blk ret;
        };
        defer include_dirs.deinit();

        var data = std.ArrayList(Item).init(b.allocator);
        defer data.deinit();

        // 未对 Item 内存进行设计和管理（释放）
        for (module.link_objects.items) |link_object| {
            switch (link_object) {
                else => {},
                .c_source_file => |csf| {
                    const file_relative_path = try std.fs.path.relative(b.allocator, cwd, csf.file.getPath(b));

                    var arguments = std.ArrayList([]const u8).init(b.allocator);
                    try arguments.append("zig cc");                 // Compiler
                    try arguments.append(file_relative_path);       // SourceFile

                    for (csf.flags) |flag| {
                        try arguments.append(flag);
                    }

                    for (c_macros) |c_macro| {
                        try arguments.append(c_macro);
                    }

                    for (systemIncludeDir) |sid| {
                        if (sid) |_sid| {
                            try arguments.append(b.fmt("-I{s}", .{_sid}));
                        }
                    }
                    for (include_dirs.items) |include_dir| {
                        const dir_relative = try std.fs.path.relative(b.allocator, cwd, include_dir);
                        try arguments.append(b.fmt("-I{s}", .{dir_relative}));
                    }

                    const item = Item {
                        .arguments = arguments.items,
                        .directory = cwd,
                        .file = file_relative_path,
                    };
                    try data.append(item);
                }
            }
        }

        const json_string = try std.json.stringifyAlloc(b.allocator, data.items, .{
            .whitespace = .indent_4,
        });
        defer b.allocator.free(json_string);

        const json_file = try std.fs.cwd().createFile("compile_commands.json", .{});
        _ = try json_file.write(json_string);
    }
};

pub const Config = struct {
    Diagnostics: Diagnostics,

    const Diagnostics = struct {
        UnusedIncludes: []const u8,

        fn default() Diagnostics {
            return Diagnostics {
                .UnusedIncludes = "Strict"
            };
        }
    };


    pub const GenerateOptions = struct {
        diagnostics: ?DiagnosticsOptions = null,

        const DiagnosticsOptions = struct {
            UnusedIncludes: ?bool = null,
        };
    };

    pub fn generate(allocator: std.mem.Allocator, options: GenerateOptions) !void {
        const config = Config {
            .Diagnostics = blk: {
                var default = Diagnostics.default();
                if (options.diagnostics) |opt| {
                    if (opt.UnusedIncludes) |v| {
                        if (!v) {
                            default.UnusedIncludes = "None";
                        }
                    }
                }
                break :blk default;
            },
        };

        const clangd_string = try std.json.stringifyAlloc(allocator, config, .{
            .whitespace = .indent_4,
        });
        defer allocator.free(clangd_string);

        const clangd_file = try std.fs.cwd().createFile(".clangd", .{});
        _ = try clangd_file.write(clangd_string);
    }
};