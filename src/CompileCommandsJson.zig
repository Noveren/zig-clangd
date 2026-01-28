//! https://clang.llvm.org/docs/JSONCompilationDatabase.html
//! 
//! The convention is to name the file `compile_commands.json` and put it at the top of the build directory.
//! Clang tools are pointed to the top of the build directory to detect the file
//! and use the compilation database to parse C++ code in the source tree.

const std = @import("std");
const Allocator = std.mem.Allocator;

/// A compilation database is a JSON file,
/// which consists of an array of “command objects”,
/// where each command object specifies one way a translation unit is compiled in the project.
objects: std.ArrayList(CommandObject),

pub const Argument = union(enum) {
    arg: ?[]const u8,
    args: [][]const u8,
    c_macro_undef: ?[]const u8,
    c_macro: ?[]const u8,
    c_macros: []const []const u8,
    include_dir: ?[]const u8,
    include_dirs: [][]const u8,
    system_include_dir: ?[]const u8,
    system_include_dirs: []const []const u8,

    fn applyClone(self: Argument, allocator: Allocator, arguments: *std.ArrayList([]const u8)) !void {
        switch (self) {
            .arg => |v| {
                if (v) |_v| { try arguments.append(allocator, try allocator.dupe(u8, _v)); }
            },
            .args => |vs| {
                for (vs) |v| { try arguments.append(allocator, try allocator.dupe(u8, v)); }
            },
            .c_macro_undef => |v| {
                if (v) |_v| { try arguments.append(allocator, try std.fmt.allocPrint(allocator, "-U{s}", .{_v})); }
            },
            .c_macro => |v| {
                if (v) |_v| { try arguments.append(allocator, try std.fmt.allocPrint(allocator, "-D{s}", .{_v})); }
            },
            .c_macros => |vs| {
                for (vs) |v| { try arguments.append(allocator, try std.fmt.allocPrint(allocator, "-D{s}", .{v})); }
            },
            .include_dir => |v| {
                if (v) |_v| { try arguments.append(allocator, try std.fmt.allocPrint(allocator, "-I{s}", .{_v})); }
            },
            .include_dirs => |vs| {
                for (vs) |v| { try arguments.append(allocator, try std.fmt.allocPrint(allocator, "-I{s}", .{v})); }
            },
            .system_include_dir => |v| {
                if (v) |_v| {
                    try arguments.append(allocator, try allocator.dupe(u8, "-isystem"));
                    try arguments.append(allocator, try allocator.dupe(u8, _v));
                }
            },
            .system_include_dirs => |vs| {
                for (vs) |v| {
                    try arguments.append(allocator, try allocator.dupe(u8, "-isystem"));
                    try arguments.append(allocator, try allocator.dupe(u8, v));
                }
            },
        }
    }
};

const CommandObject = struct {
    // The working directory of the compilation.
    // All paths specified in the command or file fields
    // must be either absolute or relative to this directory.
    directory: []const u8,
    // The main translation unit source processed by this compilation step.
    // This is used by tools as the key into the compilation database. 
    // There can be multiple command objects for the same file,
    // for example if the same source file is compiled with different configurations.
    file: []const u8,
    // The compile command argv as list of strings.
    // This should run the compilation step for the translation unit file.
    // arguments[0] should be the executable name, such as clang++.
    // Arguments should not be escaped, but ready to pass to execvp().
    arguments: []const []const u8,
    // The compile command as a single shell-escaped string. 
    // Arguments may be shell quoted and escaped following platform conventions,
    // with ‘"’ and ‘\’ being the only special characters.
    // Shell expansion is not supported.
    command: ?[]u8 = null,
    // The name of the output created by this compilation step.
    // This field is optional.
    // It can be used to distinguish different processing modes of the same input file.
    output: ?[]u8 = null,

    fn deinit(self: @This(), allocator: Allocator) void {
        allocator.free(self.directory);
        allocator.free(self.file);
        for (self.arguments) |argument| {
            allocator.free(argument);
        }
        allocator.free(self.arguments);
        if (self.command) |command| {
            allocator.free(command);
        }
        if (self.output) |output| {
            allocator.free(output);
        }
    }

    fn clone(self: @This(), allocator: Allocator) !@This() {
        const directory = try allocator.dupe(u8, self.directory);
        const file = try allocator.dupe(u8, self.file);
        const arguments = try allocator.alloc([]const u8, self.arguments.len);
        for (self.arguments, 0..) |argument, i| {
            arguments[i] = try allocator.dupe(u8, argument);
        }
        return @This() {
            .directory = directory,
            .file = file,
            .arguments = arguments,
        };
    }

    fn initClone(allocator: Allocator, file: []const u8, arguments: []const Argument) !CommandObject {
        var _arguments = try std.ArrayList([]const u8).initCapacity(allocator, 16);
        for (arguments) |argument| {
            try argument.applyClone(allocator, &_arguments);
        }
        _arguments.shrinkAndFree(allocator, _arguments.items.len);
        return .{
            .file = try allocator.dupe(u8, std.fs.path.basename(file)),
            .directory = try allocator.dupe(u8, std.fs.path.dirname(file) orelse ""),
            .arguments = _arguments.allocatedSlice(),
        };
    }
};

pub fn init(allocator: Allocator) !@This() {
    return @This() {
        .objects = try std.ArrayList(CommandObject).initCapacity(allocator, 16),
    };
}

pub fn deinit(self: *@This(), allocator: Allocator) void {
    for (self.objects.items) |object| {
        object.deinit(allocator);
    }
    self.objects.deinit(allocator);
}

pub fn stringify(self: @This(), allocator: Allocator) ![]const u8 {
    return std.json.Stringify.valueAlloc(allocator, self.objects.items, .{
        .whitespace = .indent_2,
        .emit_null_optional_fields = false,
    });
}

pub fn appendMove(self: *@This(), allocator: Allocator, object: CommandObject) !void {
    try self.objects.append(allocator, object);
}

pub fn appendClone(self: *@This(), allocator: Allocator, object: CommandObject) !void {
    try self.objects.append(allocator, try object.clone(allocator));
}

pub fn appendCloneExt(self: *@This(), allocator: Allocator, file: []const u8, arguments: []const Argument) !void {
    try self.objects.append(allocator, try CommandObject.initClone(allocator, file, arguments));
}

pub fn mergeClone(self: *@This(), allocator: Allocator, other: @This()) !void {
    // TODO 处理重复 (name, directory)
    for (other.objects.items) |object| {
        try self.objects.append(allocator, try object.clone(allocator));
    }
}