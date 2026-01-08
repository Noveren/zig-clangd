
const std = @import("std");

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();
    // defer {
    //     const deinit_status = gpa.deinit();
    //     if (deinit_status == .leak) @panic("TEST FAIL");
    // }

    // var v: u64 = 0;
    // const b: *std.Build = @ptrCast(&v);
    // const c: *std.Build.Step.Compile = @ptrCast(&v);
    // const t = try Compile.from(allocator, c, b);
    // t.deinit();

    // const a = try generateCompileCommandsJson(allocator, c, b, .{});
    // allocator.free(a);
}

pub const Compile = struct {
    allocator: std.mem.Allocator,
    data: Data,
    
    const IncludeDir = struct {
        class: []u8,
        path: ?[]u8 = null,

        fn deinit(self: @This(), allocator: std.mem.Allocator) void {
            allocator.free(self.class);

            if (self.path) |path| {
                allocator.free(path);
            }
        }
    };

    const LinkObject = struct {
        class: []u8,
        path: ?[]u8 = null,
        flags: ?[][]u8 = null,

        fn deinit(self: @This(), allocator: std.mem.Allocator) void {
            allocator.free(self.class);

            if (self.path) |path| {
                allocator.free(path);
            }

            if (self.flags) |flags| {
                for (flags) |flag| {
                    allocator.free(flag);
                }
                allocator.free(flags);
            }
        }
    };

    const Data = struct {
        name: []u8,
        is_link_libc: ?bool = null,
        is_link_libcpp: ?bool = null,
        debug: bool = true,
        c_macros: [][]u8,
        include_dirs: []IncludeDir,
        link_objects: []LinkObject,
        other_steps: []Data,

        fn deinit(self: @This(), allocator: std.mem.Allocator) void {
            allocator.free(self.name);

            for (self.c_macros) |i| {
                allocator.free(i);
            }
            allocator.free(self.c_macros);

            for (self.include_dirs) |i| {
                i.deinit(allocator);
            }
            allocator.free(self.include_dirs);

            for (self.link_objects) |i| {
                i.deinit(allocator);
            }
            allocator.free(self.link_objects);

            for (self.other_steps) |i| {
                i.deinit(allocator);
            }
            allocator.free(self.other_steps);
        }
    };

    pub fn deinit(self: @This()) void {
        self.data.deinit(self.allocator);
    }

    pub fn stringify(self: *const @This(), allocator: std.mem.Allocator) ![]const u8 {
        return std.json.Stringify.valueAlloc(allocator, self.data, .{
            .whitespace = .indent_2,
        });
    }

    pub fn from(allocator: std.mem.Allocator, b: *std.Build, compile: *const std.Build.Step.Compile) !@This() {
        const name = try allocator.dupe(u8, compile.name);
        const root_module = compile.root_module;

        var other_steps = try std.ArrayList(Data).initCapacity(allocator, 8);
        
        var c_macros = try allocator.alloc([]u8, root_module.c_macros.items.len);
        for (root_module.c_macros.items, 0..) |i, k| {
            c_macros[k] = try allocator.dupe(u8, i);
        }

        var include_dirs = try std.ArrayList(IncludeDir).initCapacity(allocator, 8);
        for (root_module.include_dirs.items) |i| {
        switch (i) {
            .path => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "path"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .path_system => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "path_system"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .path_after => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "path_after"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .framework_path => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "framework_path"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .framework_path_system => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "framework_system_path"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .embed_path => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "embed_path"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .other_step => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "other_step"),
                    .path = try allocator.dupe(u8, v.name),
                });
                for (other_steps.items) |j| {
                    if (std.mem.eql(u8, j.name, v.name)) {
                        break;
                    }
                } else {
                    const sub = try @This().from(allocator, b, v);
                    try other_steps.append(allocator, sub.data);
                }
            },
            .config_header_step => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "config_header_step"),
                    // FIXME getPath() was called on a GeneratedFile that wasn't built yet.
                    // .path = try allocator.dupe(u8, v.getOutputDir().getPath(b)),
                    .path = try allocator.dupe(u8, v.include_path),
                });
            },
        }
        }
        include_dirs.shrinkAndFree(allocator, include_dirs.items.len);

        var link_objects = try std.ArrayList(LinkObject).initCapacity(allocator, 8);
        for (root_module.link_objects.items) |i| {
            switch (i) {
                .static_path => |v| {
                    try link_objects.append(allocator, .{
                        .class = try allocator.dupe(u8, "static_path"),
                        .path = try allocator.dupe(u8, v.getPath(b)),
                    });
                },
                .other_step => |v| {
                    try link_objects.append(allocator, .{
                        .class = try allocator.dupe(u8, "other_step"),
                        .path = try allocator.dupe(u8, v.name),
                    });
                    for (other_steps.items) |j| {
                        if (std.mem.eql(u8, j.name, v.name)) {
                            break;
                        }
                    } else {
                        const sub = try @This().from(allocator, b, v);
                        try other_steps.append(allocator, sub.data);
                    }
                },
                .system_lib => |v| {
                    try link_objects.append(allocator, .{
                        .class = try allocator.dupe(u8, "system_lib"),
                        .path = try allocator.dupe(u8, v.name),
                    });
                },
                .assembly_file => |v| {
                    try link_objects.append(allocator, .{
                        .class = try allocator.dupe(u8, "assembly_file"),
                        .path = try allocator.dupe(u8, v.getPath(b)),
                    });
                },
                .c_source_file => |v| {
                    var flags = try allocator.alloc([]u8, v.flags.len);
                    for (v.flags, 0..) |flag, k| {
                        flags[k] = try allocator.dupe(u8, flag);
                    }
                    try link_objects.append(allocator, .{
                        .class = try allocator.dupe(u8, "c_source_file"),
                        .path = try allocator.dupe(u8, v.file.getPath(b)),
                        .flags = flags,
                    });
                },
                .c_source_files => |v| {
                    const root = v.root.getPath(b);
                    for (v.files) |file| {
                        var flags = try allocator.alloc([]u8, v.flags.len);
                        for (v.flags, 0..) |flag, k| {
                            flags[k] = try allocator.dupe(u8, flag);
                        }
                        try link_objects.append(allocator, .{
                            .class = try allocator.dupe(u8, "c_source_file"),
                            .path = try std.fs.path.join(allocator, &[_][]const u8{root, file}),
                            .flags = flags,
                        });
                    }
                },
                .win32_resource_file => |v| {
                    try link_objects.append(allocator, .{
                        .class = try allocator.dupe(u8, "win32_resource_file"),
                        .path = try allocator.dupe(u8, v.file.getPath(b)),
                    });
                },
            }
        }
        link_objects.shrinkAndFree(allocator, link_objects.items.len);

        other_steps.shrinkAndFree(allocator, other_steps.items.len);
        return @This() {
            .allocator = allocator,
            .data = .{
                .name = name,
                .is_link_libc = root_module.link_libc,
                .is_link_libcpp = root_module.link_libcpp,
                .debug = if (root_module.optimize) |v| (v == .Debug) else (false),
                .c_macros = c_macros,
                .include_dirs = include_dirs.allocatedSlice(),
                .link_objects = link_objects.allocatedSlice(),
                .other_steps = other_steps.allocatedSlice(),
            },
        };
    }
};

const CompileCommand = struct {
    directory: []const u8,
    file: []const u8,
    arguments: [][]const u8,

    fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        allocator.free(self.directory);
        allocator.free(self.file);
        for (self.arguments) |argument| {
            allocator.free(argument);
        }
        allocator.free(self.arguments);
    }

    fn stringify(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
        return std.json.Stringify.valueAlloc(allocator, self, .{
            .whitespace = .indent_2,
        });
    }

    const CompileCommandOptions = struct {
        cc: []const u8,
        cxx: []const u8,
        zig_libc_path: []const u8,
        zig_libcxx_path: []const u8,
        arguments: []const []const u8,
    };

    fn appendIncludeDirs(allocator: std.mem.Allocator, dst: *std.ArrayList([]u8), src: []Compile.IncludeDir) !void {
        for (src) |include_dir| {
            // TODO 处理其他类型的 IncludeDir
            if (std.mem.eql(u8, include_dir.class, "path")) {
                try dst.append(allocator, try allocator.dupe(u8, include_dir.path.?));
            }
        }
    }

    fn from(allocator: std.mem.Allocator, data: *const Compile.Data, options: CompileCommandOptions) !std.ArrayList(CompileCommand) {
        var compile_comands = try std.ArrayList(CompileCommand).initCapacity(allocator, 8);

        var include_dirs = try std.ArrayList([]u8).initCapacity(allocator, 8);
        defer {
            for (include_dirs.items) |i| {
                allocator.free(i);
            }
            defer include_dirs.deinit(allocator);
        }

        // TODO 选择是否将源文件加入到生成列表中，还是仅头文件
        for (data.other_steps) |*other_step| {
            var sub_compile_commands = try from(allocator, other_step, options);
            defer sub_compile_commands.deinit(allocator);
            try compile_comands.appendSlice(allocator, sub_compile_commands.items);

            try appendIncludeDirs(allocator, &include_dirs, other_step.include_dirs);
        }
        try appendIncludeDirs(allocator, &include_dirs, data.include_dirs);

        for (data.link_objects) |link_object| {
            if (std.mem.eql(u8, link_object.class, "c_source_file")) {
                const directory = std.fs.path.dirname(link_object.path.?).?;
                const file = std.fs.path.basename(link_object.path.?);
                var arguments = try std.ArrayList([]const u8).initCapacity(allocator, 16);
                {
                    defer arguments.shrinkAndFree(allocator, arguments.items.len);
                    // TODO 暂时全为 CC
                    try arguments.append(allocator, try allocator.dupe(u8, options.cc));
                    try arguments.append(allocator, try allocator.dupe(u8, file));
                    if (data.debug) {
                        try arguments.append(allocator, try allocator.dupe(u8, "-DDEBUG"));
                    }
                    for (options.arguments) |i| {
                        try arguments.append(allocator, try allocator.dupe(u8, i));
                    }
                    for (link_object.flags.?) |flag| {
                        try arguments.append(allocator, try allocator.dupe(u8, flag));
                    }
                    if (data.is_link_libc) |flag| {
                        if (flag) {
                            try arguments.append(allocator, try allocator.dupe(u8, "-isystem"));
                            try arguments.append(allocator, try allocator.dupe(u8, options.zig_libc_path));
                        }
                    }
                    if (data.is_link_libcpp) |flag| {
                        if (flag) {
                            try arguments.append(allocator, try allocator.dupe(u8, "-isystem"));
                            try arguments.append(allocator, try allocator.dupe(u8, options.zig_libcxx_path));
                        }
                    }
                    for (include_dirs.items) |include_dir| {
                        try arguments.append(allocator, try std.fmt.allocPrint(allocator, "-I{s}", .{include_dir}));
                    }
                }
                try compile_comands.append(allocator, .{
                    .arguments = arguments.allocatedSlice(),
                    .directory = try allocator.dupe(u8, directory),
                    .file = try allocator.dupe(u8, file),
                });
            }
        }
        return compile_comands;
    }

    fn stringifyCompileCommands(
        allocator: std.mem.Allocator,
        b: *std.Build,
        compile: *const std.Build.Step.Compile,
        options: CompileCommandOptions,
    ) ![]const u8 {
        const info = try Compile.from(allocator, b, compile);
        defer info.deinit();

        var compile_comands = try CompileCommand.from(allocator, &info.data, options);
        defer {
            for (compile_comands.items) |i| {
                i.deinit(allocator);
            }
            compile_comands.deinit(allocator);
        }

        return std.json.Stringify.valueAlloc(allocator, compile_comands.items, .{
            .whitespace = .indent_2,
        });

    }
};

const ExportOptions= struct {
    cc: ?[]const u8 = null,
    cxx: ?[]const u8 = null,
    zig_root_path: ?[]const u8 = null,
    sub_dir_path: ?[]const u8 = null,
};


// TODO 在一份 compile_commands.json 中生成多个 target 相关文件的编译指令，需实现共同依赖去重
// pub fn exportCompileCommandsForTargets(
//     allocator: std.mem.Allocator,
//     b: *std.Build,
//     compiles: []const std.Build.Step.Compile,
//     options: ExportOptions,
// ) !void {
// }

pub fn exportCompileCommands(
    allocator: std.mem.Allocator,
    b: *std.Build,
    compile: *const std.Build.Step.Compile,
    options: ExportOptions,
) !void {
    const zig_root_path = blk: {
        if (options.zig_root_path) |p| {
            break :blk p;
        } else {
            const zig_exe_path = try b.findProgram(&.{"zig"}, &.{});
            break :blk std.fs.path.dirname(zig_exe_path).?;
        }
    };
    const zig_libc_path = blk: {
        // TODO 根据编译 target 生成
        const platform = "any-windows-any";
        break :blk try std.fs.path.join(allocator, &[_][]const u8 {
            zig_root_path,
            "lib",
            "libc",
            "include",
            platform,
        });
    };
    defer allocator.free(zig_libc_path);
    const zig_libcxx_path = blk: {
        // TODO libcxxabi, libunwind
        break :blk try std.fs.path.join(allocator, &[_][]const u8 {
            zig_root_path,
            "lib",
            "libcxx",
            "include",
        });
    };
    defer allocator.free(zig_libcxx_path);

    const compile_commands_json = try CompileCommand.stringifyCompileCommands(allocator, b, compile, .{
        .cc = options.cc orelse "gcc",
        .cxx = options.cxx orelse "gcc",
        .zig_libc_path = zig_libc_path,
        .zig_libcxx_path = zig_libcxx_path,
        .arguments = &[_][]const u8{
            "-D__GNUC__",
        }
    });
    defer allocator.free(compile_commands_json);

    const dir: std.fs.Dir = blk: {
        if (options.sub_dir_path) |sub_path| {
            break :blk try std.fs.cwd().makeOpenPath(sub_path, .{});
        }
        break :blk std.fs.cwd();
    };
    const file = try dir.createFile("compile_commands.json", .{});
    _ = try file.write(compile_commands_json);
}

// TODO 支持生成 makefile, ninjia 并选定工具链