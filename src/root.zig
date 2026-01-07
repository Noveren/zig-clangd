
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    var v: u64 = 0;
    const b: *std.Build = @ptrCast(&v);
    const c: *std.Build.Step.Compile = @ptrCast(&v);
    const t = try Compile.from(allocator, c, b);
    t.deinit();

    const a = try generateCompileCommandsJson(allocator, c, b, .{});
    allocator.free(a);
}

const Compile = struct {
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

    fn stringfy(self: *const @This(), allocator: std.mem.Allocator) ![]const u8 {
        return std.json.Stringify.valueAlloc(allocator, self.data, .{
            .whitespace = .indent_2,
        });
    }

    fn deinit(self: @This()) void {
        self.data.deinit(self.allocator);
    }

    fn from(allocator: std.mem.Allocator, compile: *std.Build.Step.Compile, b: *std.Build) !@This() {
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
                    const sub = try @This().from(allocator, v, b);
                    try other_steps.append(allocator, sub.data);
                }
            },
            .config_header_step => |v| {
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "config_header_step"),
                    .path = try allocator.dupe(u8, v.getOutputDir().getPath(b)),
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
                        const sub = try @This().from(allocator, v, b);
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
                else => {}
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
                .c_macros = c_macros,
                .include_dirs = include_dirs.allocatedSlice(),
                .link_objects = link_objects.allocatedSlice(),
                .other_steps = other_steps.allocatedSlice(),
            },
        };
    }
};

pub fn stringifyCompile(allocator: std.mem.Allocator, compile: *std.Build.Step.Compile, b: *std.Build) ![]const u8 {
    const c = try Compile.from(allocator, compile, b);
    defer c.deinit();
    return c.stringfy(allocator);
}

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
};

const GenerateOptions = struct {
    cc: ?[]const u8 = null,
    cxx: ?[]const u8 = null,
    zig_root_path: ?[]const u8 = null,
};

const ConvertOptions = struct {
    cc: []const u8,
    cxx: []const u8,
    arguments: []const []const u8,
};


fn convert(allocator: std.mem.Allocator, data: *const Compile.Data, options: ConvertOptions) !std.ArrayList(CompileCommand) {
    var compile_comands = try std.ArrayList(CompileCommand).initCapacity(allocator, 8);
    // TODO 共享所有依赖的头文件路径
    // TODO 系统头文件路径
    for (data.link_objects) |link_object| {
        if (std.mem.eql(u8, link_object.class, "c_source_file")) {
            const directory = std.fs.path.dirname(link_object.path.?).?;
            const file = std.fs.path.basename(link_object.path.?);
            var arguments = try std.ArrayList([]const u8).initCapacity(allocator, 16);

            // TODO 暂时全为 CC
            try arguments.append(allocator, try allocator.dupe(u8, options.cc));
            try arguments.append(allocator, try allocator.dupe(u8, file));
            for (options.arguments) |i| {
                try arguments.append(allocator, try allocator.dupe(u8, i));
            }
            for (link_object.flags.?) |flag| {
                try arguments.append(allocator, try allocator.dupe(u8, flag));
            }
            
            arguments.shrinkAndFree(allocator, arguments.items.len);
            try compile_comands.append(allocator, .{
                .arguments = arguments.allocatedSlice(),
                .directory = try allocator.dupe(u8, directory),
                .file = try allocator.dupe(u8, file),
            });
        }
    }
    return compile_comands;
}

pub fn generateCompileCommandsJson(allocator: std.mem.Allocator, compile: *std.Build.Step.Compile, b: *std.Build, options: GenerateOptions) ![]const u8 {
    const c = try Compile.from(allocator, compile, b);
    defer c.deinit();

    // const zig_exe_path = try b.findProgram(&.{"zig"}, &.{});
    // const zig_root_path = std.fs.path.dirname(zig_exe_path).?;

    const _options = ConvertOptions {
        .cc = options.cc orelse "cc",
        .cxx = options.cxx orelse "cxx",
        .arguments = &[_][]const u8{
            "-D__GNUC__",
            "-D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS",
            "-D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS",
            "-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS",
            "-D_LIBCPP_PSTL_CPU_BACKEND_SERIAL",
            "-D_LIBCPP_ABI_VERSION=1",
            "-D_LIBCPP_ABI_NAMESPACE=__1 ",
            "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG",
            "-D__MSVCRT_VERSION__=0xE00",
            "-D_WIN32_WINNT=0x0a00",
            "-D_DEBUG"
        }
    };

    var compile_comands = try convert(allocator, &c.data, _options);
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
