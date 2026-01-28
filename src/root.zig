// TODO 支持生成 makefile, ninjia 并选定工具链
// 此时要求必须为纯的 C/C++ 项目

const std = @import("std");
const CompileCommandsJson = @import("CompileCommandsJson.zig");
const ExportCompileDatabase = @import("ExportCompileDatabase.zig");
pub const exportCompileDatabase = ExportCompileDatabase.exportCompileDatabase;