# zmake

TODO Description

## Quick Start

```shell
$ zig fetch --save git+https://Noveren/zmake.git
```

```zig
const zmake = @import("zmake");

pub fn build(b: *std.Build) void {
  // exe with C Source File

  const emit_json = b.option(bool, "clangd", "") orelse false;
    if (emit_json) {
        zmake.exportCompileCommands(b.allocator, b, exe, .{ .sub_dir_path = "build" }) catch {
            std.log.err("Failed to export compile_commands.json", .{});
        };
    }
}
```