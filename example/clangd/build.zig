
const std = @import("std");

const clangd = @import("./src/root.zig");
pub const CompileCommandsJson = clangd.CompileCommandsJson;
pub const Config = clangd.Config;

pub fn build(b: *std.Build) void {
    _ = b;
}

// .clangd example
// {
//     "Diagnostics": {
//         "UnusedIncludes": "None",
//         "Suppress": [
//             "pp_including_mainfile_in_preamble",
//             "invalid_token_after_toplevel_declarator"
//         ]
//     }
// }
// .clangd example-cxx
// {
//     "Diagnostics": {
//         "UnusedIncludes": "None",
//         "Suppress": [
//             "pp_including_mainfile_in_preamble",
//             "invalid_token_after_toplevel_declarator",
//             "pp_hash_error",
//             "pp_file_not_found"
//         ]
//     }
// }