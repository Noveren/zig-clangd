# Zig-Clangd

`zig-clangd` is a zig library, which working in the `build.zig` of your C/C++ project built in `zig cc`

## Quick Start

1. Install Clangd and its plugin working in yours Editor (like VS Code)
2. Install Zig and set it into your PATH
3. TODO 待修正

```shell
- project\
  - src\
    - main.c
  - build.zig
  - build.zig.zon
```

TODO `zig fetch`


```c
#include <stdio.h>

int main(int argc, const char* argv[]) {
    printf("Hello, %s!\n", "world");
    return 0;
}
```

```zig
// build.zig
const clangd = @import("clangd");
```

```zig
// zig build -Dclangd
const clangd_emit = b.option(bool, "clangd", "Enable to generate clangd config") orelse false;
if (clangd_emit) {
    try clangd.CompileCommandsJson.generate(b, exe.root_module, .{
        .cstd = .{ .Libc = "any-windows-any" },
    });
}

```