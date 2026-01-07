const std = @import("std");

pub fn main() !void {
    var v: u64 = 0;
    var b: *std.Build = @ptrCast(&v);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "exe",
        .root_module = mod,
    });
    // dep = b.dependency
    // lib = dep.artifact
    // mod.linkLibrary(lib);
    try Json.generate(allocator, exe, .{});
}

test "all" {
    // std.os.environ
    std.debug.print("===========", .{});
}

pub fn getZigRootPath(b: *std.Build) ![]const u8 {
    const zig_exe_path = try b.findProgram(&.{"zig"}, &.{});
    const zig_root_path = std.fs.path.dirname(zig_exe_path);
    return zig_root_path orelse error.Failed;
}

pub const Json = struct {
    pub const Options = struct {
        // 不指定则自动搜索
        system_include_path: ?[]const u8 = null,
        // 裸机环境由用户指定
    };
    const Item = struct {
        arguments: std.ArrayList([]const u8),
        directory: []const u8,
        file: []const u8,

        fn deinit(self: *Item, allocator: std.mem.Allocator) void {
            for (self.arguments.items) |argument| {
                allocator.free(argument);
            }
            self.arguments.deinit(allocator);
            allocator.free(self.directory);
            allocator.free(self.file);
        }
    };
    // TODO ArenaAlloctor
    allocator: std.mem.Allocator,
    data: std.ArrayList(Item),

    fn init(allocator: std.mem.Allocator, size: usize) !@This() {
        return Json{
            .allocator = allocator,
            .data = try std.ArrayList(Item).initCapacity(allocator, size),
        };
    }

    fn deinit(self: *@This()) void {
        for (self.data.items) |*item| {
            item.deinit(self.allocator);
        }
        self.data.deinit(self.allocator);
    }

    fn stringify(self: *const @This(), allocator: std.mem.Allocator) ![]const u8 {
        return std.json.Stringify.valueAlloc(allocator, self.data.items, .{
            .whitespace = .indent_2,
        });
    }

    pub fn generate(allocator: std.mem.Allocator, compile: *std.Build.Step.Compile, options: Options) !void {
        // TODO *std.Build 用来获得 zig 的根目录
        var self = try @This().from(allocator, compile, options);
        defer self.deinit();
        const string = try self.stringify(allocator);
        defer allocator.free(string);
        // const json_file = try std.fs.cwd().createFile("compile_commands.json", .{});
        // _ = try json_file.write(string);
    }

    fn from(allocator: std.mem.Allocator, compile: *std.Build.Step.Compile, options: Options) !@This() {
        const self = try @This().init(allocator, 1024);

        _ = options;

        const root_module = compile.root_module;
        printModule(root_module);

        // var system_include_paths = try std.ArrayList([]const u8).initCapacity(allocator, 8);
        // defer {
        //     for (system_include_paths.items) |i| {
        //         allocator.free(i);
        //     }
        // }
        // if (options.system_include_path) |system_include_path| {
        //     try system_include_paths.append(allocator, system_include_path);
        // } else {
        //     // TODO 搜索 Zig 自带头文件
        //     if (root_module.link_libc) |flag| {
        //         if (flag) {}
        //     }
        //     if (root_module.link_libcpp) |flag| {
        //         if (flag) {}
        //     }
        // }

        // root_module.link_objects.items[0].c_source_file
        // root_module.link_objects.items[0].static_path

        // _ = module;
        // module.c_macros.items
        // module.include_dirs.items
        // module.link_objects
        return self;
    }
};

fn printModule(mod: *std.Build.Module) void {
    std.debug.print("Module Info: \n", .{});

    std.debug.print("MACRO: ", .{});
    for (mod.c_macros.items) |i| {
        std.debug.print("{s} ", .{i});
    }
    std.debug.print("\n", .{});

    std.debug.print("Include: \n", .{});
    for (mod.include_dirs.items) |include_dir| {
        switch (include_dir) {
            .path => |v| {
                std.debug.print("path: {s}\n", .{v.getDisplayName()});
            },
            .path_system, .path_after, .framework_path, .framework_path_system => |p| {
                std.debug.print("other: {s}\n", .{p.getDisplayName()});
            },
            .other_step => {},
            .config_header_step => {},
            .embed_path => {},
        }
    }
    std.debug.print("\n", .{});

    std.debug.print("Link Object: \n", .{});
    for (mod.link_objects.items) |link_object| {
        switch (link_object) {
            .c_source_file => |v| {
                std.debug.print("c source file: {s}\n", .{v.file.getDisplayName()});
            },
            .static_path => |v| {
                std.debug.print("static path: {s}\n", .{v.getDisplayName()});
            },
            else => {},
        }
    }
    std.debug.print("\n", .{});
}

pub const CompileCommandsJson = struct {
    const Item = struct {
        arguments: []const []const u8,
        directory: []const u8,
        file: []const u8,
    };

    pub const GenerateOptions = struct {
        cstd: ?CStd = null,

        const CStd = struct {
            // $zig_root_path$/lib/libc/include/$arch_os_abi$
            arch_os_abi: []const u8,
            cxx: bool = false,
        };
    };

    pub fn generate(
        b: *std.Build,
        module: *std.Build.Module,
        options: GenerateOptions,
    ) !void {
        var systemIncludeDir: [5]?[]const u8 = .{ null, null, null, null, null };
        if (getZigRootPath(b)) |zig_root_path| {
            systemIncludeDir[0] = try std.fs.path.resolve(b.allocator, &[_][]const u8{ zig_root_path, "lib/include" });
            if (options.cstd) |cstd| {
                const libc_include_path = try std.fs.path.resolve(b.allocator, &[_][]const u8{
                    zig_root_path,
                    "lib/libc/include",
                    cstd.arch_os_abi,
                });
                systemIncludeDir[1] = libc_include_path;
                if (cstd.cxx) {
                    systemIncludeDir[2] = try std.fs.path.resolve(b.allocator, &[_][]const u8{ zig_root_path, "lib/libcxx/include" });
                    systemIncludeDir[3] = try std.fs.path.resolve(b.allocator, &[_][]const u8{ zig_root_path, "lib/libcxxabi/include" });
                    systemIncludeDir[4] = try std.fs.path.resolve(b.allocator, &[_][]const u8{ zig_root_path, "lib/libunwind/include" });
                }
            }
        } else |_| {
            std.log.err("Failed to get zig_root_path\n", .{});
        }

        const cwd = try std.fs.cwd().realpathAlloc(b.allocator, ".");
        defer b.allocator.free(cwd);

        const c_macros = module.c_macros.items;
        var include_dirs = blk: {
            var ret = try std.ArrayList([]const u8).initCapacity(b.allocator, 1024);
            for (module.include_dirs.items) |include_dir| {
                switch (include_dir) {
                    .path, .path_system, .path_after, .framework_path, .framework_path_system => |p| {
                        try ret.append(b.allocator, p.getPath(b));
                    },
                    .other_step => {},
                    .config_header_step => {},
                    .embed_path => {},
                }
            }
            break :blk ret;
        };
        defer include_dirs.deinit(b.allocator);

        var data = try std.ArrayList(Item).initCapacity(b.allocator, 1024);
        defer data.deinit(b.allocator);

        // 未对 Item 内存进行设计和管理（释放）
        for (module.link_objects.items) |link_object| {
            switch (link_object) {
                else => {},
                .c_source_file => |csf| {
                    const file_relative_path = try std.fs.path.relative(b.allocator, cwd, csf.file.getPath(b));

                    var arguments = try std.ArrayList([]const u8).initCapacity(b.allocator, 1024);
                    try arguments.append(b.allocator, "zig cc"); // Compiler
                    try arguments.append(b.allocator, file_relative_path); // SourceFile

                    for (csf.flags) |flag| {
                        try arguments.append(b.allocator, flag);
                    }

                    try arguments.append(b.allocator, "-D__GNUC__");
                    for (c_macros) |c_macro| {
                        try arguments.append(b.allocator, c_macro);
                    }

                    for (systemIncludeDir) |sid| {
                        if (sid) |_sid| {
                            try arguments.append(b.allocator, b.fmt("-isystem{s}", .{_sid}));
                        }
                    }
                    if (options.cstd) |cstd| {
                        if (cstd.cxx) {
                            try arguments.append(b.allocator, "-D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS");
                            try arguments.append(b.allocator, "-D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS");
                            try arguments.append(b.allocator, "-D_LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS");
                            try arguments.append(b.allocator, "-D_LIBCPP_PSTL_CPU_BACKEND_SERIAL");
                            try arguments.append(b.allocator, "-D_LIBCPP_ABI_VERSION=1");
                            try arguments.append(b.allocator, "-D_LIBCPP_ABI_NAMESPACE=__1 ");
                            try arguments.append(b.allocator, "-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_DEBUG");
                            try arguments.append(b.allocator, "-D__MSVCRT_VERSION__=0xE00");
                            try arguments.append(b.allocator, "-D_WIN32_WINNT=0x0a00");
                            try arguments.append(b.allocator, "-D_DEBUG");
                        }
                    }
                    for (include_dirs.items) |include_dir| {
                        const dir_relative = try std.fs.path.relative(b.allocator, cwd, include_dir);
                        try arguments.append(b.allocator, b.fmt("-I{s}", .{dir_relative}));
                    }

                    const item = Item{
                        .arguments = arguments.items,
                        .directory = cwd,
                        .file = file_relative_path,
                    };
                    try data.append(b.allocator, item);
                },
            }
        }

        const json_string = try std.json.Stringify.valueAlloc(b.allocator, data.items, .{
            .whitespace = .indent_4,
        });
        defer b.allocator.free(json_string);

        const json_file = try std.fs.cwd().createFile("compile_commands.json", .{});
        _ = try json_file.write(json_string);
    }
};

// pub const Config = struct {
//     // Diagnostics: Diagnostics,
//     const Diagnostics = struct {
//         UnusedIncludes: []const u8,

//         fn default() Diagnostics {
//             return Diagnostics{ .UnusedIncludes = "Strict" };
//         }
//     };

//     pub const GenerateOptions = struct {
//         diagnostics: ?DiagnosticsOptions = null,

//         const DiagnosticsOptions = struct {
//             UnusedIncludes: ?bool = null,
//         };
//     };

//     pub fn generate(allocator: std.mem.Allocator, options: GenerateOptions) !void {
//         const config = Config{
//             .Diagnostics = blk: {
//                 var default = Diagnostics.default();
//                 if (options.diagnostics) |opt| {
//                     if (opt.UnusedIncludes) |v| {
//                         if (!v) {
//                             default.UnusedIncludes = "None";
//                         }
//                     }
//                 }
//                 break :blk default;
//             },
//         };

//         const clangd_string = try std.json.stringifyAlloc(allocator, config, .{
//             .whitespace = .indent_4,
//         });
//         defer allocator.free(clangd_string);

//         const clangd_file = try std.fs.cwd().createFile(".clangd", .{});
//         _ = try clangd_file.write(clangd_string);
//     }
// };
