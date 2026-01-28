# zmake

A Zig build utility for automatically generating `compile_commands.json` for C/C++ projects built with Zig's build system. This plugin integrates seamlessly into your `build.zig`, providing a custom build step to export compilation commands in the JSON Compilation Database format, which is widely supported by tools like clangd, ccls, and other language servers for accurate code intelligence.

## Quick Start

1. **Add zmake as a dependency** to your project using Zig's package manager:

   ```bash
   $ zig fetch --save git+https://Noveren/zmake.git
   ```

2. **Import and use zmake** in your `build.zig`:

   ```zig
   const std = @import("std");
   const zmake = @import("zmake");
   
   pub fn build(b: *std.Build) void {
       // exe with C/C++ Source File
       const compdb = zmake.exportCompileDatabase(b, exe, null, .{
           .debug = true,
       });
       const step_compdb = b.step("compdb", "export compile_commands.json");
       step_compdb.dependOn(&compdb.step);
   }
   ```

3. **Run the compdb step** to generate `compile_commands.json`:

   ```bash
   zig build compdb
   ```

The file will be placed in the project's root directory (or as configured). You can now point your IDE or language server to this file for accurate code analysis, autocompletion, and navigation.

## Limitations & Future Plans

- **Generated Headers**: Currently does not automatically handle generated header files (e.g., from build-time code generation). You may need to manually add include paths or adjust your setup.
- **Platform Support**: Tested primarily on Windows and macOS. Linux and other platforms should work but may require additional validation.
- **Zig Version Compatibility**: Built for Zig 0.15.2. Future updates to Zig's  API may require adaptations. Please check for version compatibility when updating Zig.
- **Future Enhancements**: Planned features include better support for generated headers, extended platform testing, and compatibility with newer Zig releases. Contributions and feedback are welcome!

For issues, suggestions, or contributions, visit the [GitHub repository](https://github.com/Noveren/zmake).