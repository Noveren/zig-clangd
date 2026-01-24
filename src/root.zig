// TODO 支持生成 makefile, ninjia 并选定工具链
// 此时要求必须为纯的 C/C++ 项目

const std = @import("std");
const CompileCommandsJson = @import("CompileCommandsJson.zig");

/// just for `zig build check`
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    const filename = try allocator.dupe(u8, "compile_commands.json");
    defer allocator.free(filename);

    var compile_commands_json = try CompileCommandsJson.init(allocator);
    defer compile_commands_json.deinit();
    try compile_commands_json.appendClone(.{
        .directory = ".",
        .file = filename,
        .arguments = &[_][]const u8 {
            "gcc",
            filename,
        },
    });
    const json = try compile_commands_json.stringify(allocator);
    defer allocator.free(json);

    // var v: u64 = 0;
    // const b: *std.Build = @ptrCast(&v);
    // const c: *std.Build.Step.Compile = @ptrCast(&v);
    // const t = try Compile.from(allocator, c, b);
    // t.deinit();

    // const a = try generateCompileCommandsJson(allocator, c, b, .{});
    // allocator.free(a);
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
        is_link_libc: bool,
        is_link_libcpp: bool,
        debug: bool = true,
        c_macros: [][]u8,
        include_dirs: []IncludeDir,
        installed_include_dirs: [][]u8,
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

            for (self.installed_include_dirs) |i| {
                allocator.free(i);
            }
            allocator.free(self.installed_include_dirs);

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

        // if (root_module.resolved_target) |resolved_target| {
        //     std.log.debug("{any}", .{resolved_target.result.abi});
        // } else {
        //     std.log.debug("Native target", .{});
        // }
        var installed_include_dirs = try std.ArrayList([]u8).initCapacity(allocator, 8);
        for (compile.installed_headers.items) |installed_header| {
            // std.log.info("Installed header: {s}", .{installed_header.getSource().getPath(b)});
            // FIXME getPath() was called on a GeneratedFile that wasn't built yet.
            // Is there a missing Step dependency on step 'configure cmake header include/build_config/SDL_revision.h.cmake to SDL3/SDL_revision.h'?
            // installed_include_dirs[k] = try allocator.dupe(u8, installed_header.getSource().getPath(b));
            // installed header 会被复制到当前 .zig-cache 中，但只在编译后可获得 LazyPath 实际路径
            switch (installed_header) {
                .directory => |v| {
                    // std.log.debug("installed_header directory: {s}", .{v.dest_rel_path});
                    if (getPathNotGenerated(b, v.source)) |not_generated_path| {
                        // std.log.debug("installed_header directory: {s}", .{not_generated_path});
                        var _not_generated_path = not_generated_path;
                        if (std.mem.endsWith(u8, not_generated_path, v.dest_rel_path)) {
                            _not_generated_path = not_generated_path[0..(not_generated_path.len-v.dest_rel_path.len)];
                        }
                        try installed_include_dirs.append(allocator, try allocator.dupe(u8, _not_generated_path));
                    } else {
                        // std.log.warn("'{s}' is generated directory.", .{v.dest_rel_path}); // generated
                        // std.log.warn("'{s}' is generated directory.", .{v.source.getDisplayName()}); // generated
                        std.log.warn("'{s}' is generated installed header directory and it isn't added into compile_commands.json.", .{v.source.basename(b, null)}); // generated
                    }
                },
                .file => |v| {
                    std.log.warn("'{s}' is install header file and it isn't added into compile_commands.json.", .{v.source.getDisplayName()});
                },
            }
        }
        installed_include_dirs.shrinkAndFree(allocator, installed_include_dirs.items.len);

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
                // TODO 考虑如何处理用户提供的系统包含路径
                // 特别是用于嵌入式开发时，用户自行提供的标准库
                try include_dirs.append(allocator, .{
                    .class = try allocator.dupe(u8, "path_system"),
                    .path = try allocator.dupe(u8, v.getPath(b)),
                });
            },
            .path_after => |v| {
                // -idir
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
                // TODO 仅提取用户指定需要源文件的 link_object
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
                .is_link_libc = root_module.link_libc orelse false,
                .is_link_libcpp = root_module.link_libcpp orelse false,
                .debug = if (root_module.optimize) |v| (v == .Debug) else (false),
                .c_macros = c_macros,
                .include_dirs = include_dirs.allocatedSlice(),
                .installed_include_dirs = installed_include_dirs.allocatedSlice(),
                .link_objects = link_objects.allocatedSlice(),
                .other_steps = other_steps.allocatedSlice(),
            },
        };
    }

    const CompileCommandOptions = struct {
        cc: []const u8,
        cxx: []const u8,
        zig_libc_path: []const u8,
        zig_libcxx_path: []const u8,
        arguments: []const []const u8,
    };

    // pub fn intoCompileCommandsJson(self: *const @This(), allocator: std.mem.Allocator, options: CompileCommandOptions) !CompileCommandsJson {
    //     _ = options;
    //     var json = try CompileCommandsJson.init(allocator);
    //     // for (self.data.other_steps) |*other_step| {
    //     //     other_step.include_dirs
    //     // }
    //     for (self.data.link_objects) |link_object| {
    //         if (std.mem.eql(u8, link_object.class, "c_source_file")) {
    //             var arguments = try std.ArrayList([]u8).initCapacity(allocator, 16);
    //             {

    //             }
    //             arguments.shrinkAndFree(allocator, arguments.items.len);
    //             json.appendMove(.{
    //                 .directory = try allocator.dupe(u8, std.fs.path.dirname(link_object.path.?).?),
    //                 .file = try allocator.dupe(u8, std.fs.path.basename(link_object.path.?)),
    //                 .arguments = arguments.allocatedSlice(),
    //             });
    //         }
    //     }
    //     return json;
    // }
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
        arguments: []const []const u8,
        zig_libc_arguments: []const []const u8,
        zig_libcxx_arguments: []const []const u8,
        included_source_libs: []const []const u8 = &.{},
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

        try appendIncludeDirs(allocator, &include_dirs, data.include_dirs);
        for (data.other_steps) |*other_step| {
            for (options.included_source_libs) |included_source_lib| {
                if (std.mem.eql(u8, included_source_lib, other_step.name)) {
                    var sub_compile_commands = try from(allocator, other_step, options);
                    defer sub_compile_commands.deinit(allocator);
                    try compile_comands.appendSlice(allocator, sub_compile_commands.items);
                    break;
                }
            }
            for (other_step.installed_include_dirs) |installed_include_dir| {
                try include_dirs.append(allocator, try allocator.dupe(u8, installed_include_dir));
            }
        }

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
                    for (data.c_macros) |i| {
                        try arguments.append(allocator, try allocator.dupe(u8, i));
                    }
                    for (link_object.flags.?) |flag| {
                        try arguments.append(allocator, try allocator.dupe(u8, flag));
                    }

                    if (data.is_link_libc) {
                        for (options.zig_libc_arguments) |argument| {
                            try arguments.append(allocator, try allocator.dupe(u8, argument));
                        }
                    }
                    if (data.is_link_libcpp) {
                        for (options.zig_libcxx_arguments) |argument| {
                            try arguments.append(allocator, try allocator.dupe(u8, argument));
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
    // TOOD deprecated: clangd 默认检测根路径下的 compile_commands.json
    // 且在 build.zig 中创建路径较为麻烦
    install_prefix: ?[]const u8 = null,
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
    const path_delimiter = if (@import("builtin").target.os.tag == .windows) "\\" else "/";
    const zig_root_path = blk: {
        if (options.zig_root_path) |p| {
            break :blk p;
        } else {
            const zig_exe_path = b.findProgram(&.{"zig"}, &.{}) catch @panic("Couldn't find progarm 'zig'.");
            break :blk std.fs.path.dirname(zig_exe_path).?;
        }
    };
    const zig_lib_include = try std.fs.path.join(allocator, &[_][]const u8 {
        zig_root_path, "lib", "include",
    });
    defer allocator.free(zig_lib_include);
    const zig_libc_include = try std.fs.path.join(allocator, &[_][]const u8 {
        zig_root_path, "lib", "libc", "include",
    });
    defer allocator.free(zig_libc_include);

    var arguments = try std.ArrayList([]u8).initCapacity(allocator, 16);
    defer {
        for (arguments.items) |argument| {
            allocator.free(argument);
        }
        arguments.deinit(allocator);
    }
    try arguments.append(allocator, try allocator.dupe(u8, "_D__GNUC__"));
    try arguments.appendSlice(allocator, &.{
        try allocator.dupe(u8, "-isystem"),
        try allocator.dupe(u8, zig_lib_include),
    });

    var zig_libc_arguments = try std.ArrayList([]u8).initCapacity(allocator, 16);
    // link_cpp = true 编译时，包含了 libc 路径，但如此生成的 compild_commands.json 会导致 clangd 报错
    var zig_libcxx_arguments = try std.ArrayList([]u8).initCapacity(allocator, 16);
    defer {
        for (zig_libc_arguments.items) |argument| {
            allocator.free(argument);
        }
        zig_libc_arguments.deinit(allocator);
        for (zig_libcxx_arguments.items) |argument| {
            allocator.free(argument);
        }
        zig_libcxx_arguments.deinit(allocator);
    }

    try zig_libcxx_arguments.appendSlice(allocator, &.{
        try allocator.dupe(u8, "-isystem"),
        try std.fs.path.join(allocator, &[_][]const u8 { zig_root_path, "lib", "libcxx", "include" }),
        try allocator.dupe(u8, "-isystem"),
        try std.fs.path.join(allocator, &[_][]const u8 { zig_root_path, "lib", "libcxxabi", "include" }),
    });
    for (&[_][]const u8 {
        // windows & macos
        "-D_LIBCPP_ABI_VERSION=1",
        "-D_LIBCPP_ABI_NAMESPACE=__1",
        "-D_LIBCPP_HAS_THREADS=1",
        "-D_LIBCPP_HAS_MONOTONIC_CLOCK",
        "-D_LIBCPP_HAS_TERMINAL",
        "-D_LIBCPP_HAS_MUSL_LIBC=0",
        "-D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS",
        "-D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS",
        "-D_LIBCPP_HAS_VENDOR_AVAILABILITY_ANNOTATIONS=0",
        "-D_LIBCPP_HAS_FILESYSTEM=1",
        "-D_LIBCPP_HAS_RANDOM_DEVICE",
        "-D_LIBCPP_HAS_LOCALIZATION",
        "-D_LIBCPP_HAS_UNICODE",
        "-D_LIBCPP_HAS_WIDE_CHARACTERS",
        "-D_LIBCPP_HAS_NO_STD_MODULES",
        "-D_LIBCPP_PSTL_BACKEND_SERIAL",
        "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE",
        "-D_LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS",
    }) |argument| {
        try zig_libcxx_arguments.append(allocator, try allocator.dupe(u8, argument));
    }

    if (compile.root_module.resolved_target) |resolved_target| {
        // lib/include/<cpu_arch>-<os_tag>-<abi>
        // std.Target.Query {
        //     .cpu_arch = .x86_64,
        //     .os_tag = .windows,
        //     .abi = .musl,
        // };
        switch (resolved_target.result.os.tag) {
            .windows => {
                try zig_libc_arguments.appendSlice(allocator, &.{
                    try allocator.dupe(u8, "-isystem"),
                    try std.fmt.allocPrint(allocator, "{s}{s}any-windows-any", .{zig_libc_include, path_delimiter}),
                    // try allocator.dupe(u8, "-isystem"),
                    // try std.fmt.allocPrint(allocator, "{s}{s}x86_64-windows-gnu", .{zig_libc_include, path_delimiter}),
                    // try allocator.dupe(u8, "-isystem"),
                    // try std.fmt.allocPrint(allocator, "{s}{s}x86_64-windows-any", .{zig_libc_include, path_delimiter}),
                    // try allocator.dupe(u8, "-isystem"),
                    // try std.fmt.allocPrint(allocator, "{s}{s}generic-mingw", .{zig_libc_include, path_delimiter}),
                    // try allocator.dupe(u8, "-D__MSVCRT_VERSION__=0xE00"),
                    // try allocator.dupe(u8, "-D__WIN32_WINNT=0x0a00"),
                });
                try zig_libcxx_arguments.appendSlice(allocator, &.{
                    try allocator.dupe(u8, "-isystem"),
                    try std.fs.path.join(allocator, &[_][]const u8 { zig_root_path, "lib", "libunwind", "include" }),
                });
            },
            .macos => {
                try zig_libc_arguments.appendSlice(allocator, &.{
                    try allocator.dupe(u8, "-isystem"),
                    try allocator.dupe(u8, "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include"),
                    try allocator.dupe(u8, "-isystem"),
                    try allocator.dupe(u8, "/opt/homebrew/include"),
                    try allocator.dupe(u8, "-iframework"),
                    try allocator.dupe(u8, "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks"),
                });
            },
            .linux => |v| {
                std.log.warn("Unsupported os: {any}", .{v});
            },
            inline else => {}
        }
        try arguments.appendSlice(allocator, &.{
            try allocator.dupe(u8, "-target"),
            try std.fmt.allocPrint(allocator, "{t}-{t}-{t}", .{
                resolved_target.result.cpu.arch,
                resolved_target.result.os.tag,
                resolved_target.result.abi,
            }),
        });
    }

    const compile_commands_json = try CompileCommand.stringifyCompileCommands(allocator, b, compile, .{
        .cc = options.cc orelse "clang",
        .cxx = options.cxx orelse "clang",
        .zig_libc_arguments = zig_libc_arguments.items,
        .zig_libcxx_arguments = zig_libcxx_arguments.items,
        .arguments = arguments.items,
    });
    defer allocator.free(compile_commands_json);

    const dir: std.fs.Dir = blk: {
        // default:
        //  - Windows: $CWD\\zig-out
        // -p <path>
        // std.debug.print("{s}", .{b.install_path});
        // std.debug.print("{s}", .{b.install_prefix});
        if (options.install_prefix) |install_prefix| {
            var path = install_prefix;
            if (std.fs.path.isAbsolute(install_prefix)) {
                if (std.mem.eql(u8, install_prefix, b.install_prefix)) {
                    path = "zig-out";
                } else {
                    // Don't support absolute path.
                    std.log.err("Don't support absolute path: '{s}'.", .{install_prefix});
                    path = "";
                }
            }
            break :blk try std.fs.cwd().makeOpenPath(path, .{});
        }
        break :blk std.fs.cwd();
    };
    const file = try dir.createFile("compile_commands.json", .{});
    _ = try file.write(compile_commands_json);
}
