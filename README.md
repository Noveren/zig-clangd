# Zig-Clangd

Zig-Clangd is a zig script, which working in the `build.zig` of your C/C++ project built in `zig cc`

## Quick Start

1. Install Clangd and its plugin working in yours Editor (like VS Code)
2. Install Zig and set it into your PATH
3. Git clone the repository into your project, like this.

```shell
- project\
  - clangd\
  - src\
    - main.c
  - build.zig
```

```c
#include <stdio.h>

int main(int argc, const char* argv[]) {
    printf("Hello, %s!\n", "world");
    return 0;
}
```

```zig
// build.zig
const std = @import("std");
const clangd = @import("clangd/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "demo",
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.addCSourceFile(.{ .file = b.path("src/main.c") });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // -Dclangd
    const clangd_emit = b.option(bool, "clangd", "Enable to generate clangd config") orelse false;
    if (clangd_emit) {
        try clangd.CompileCommandsJson.generate(b, exe.root_module, .{
            .cstd = .{ .Libc = "any-windows-any" },
        });
    }
}
```

```shell
$ zig build -Dclangd
```

