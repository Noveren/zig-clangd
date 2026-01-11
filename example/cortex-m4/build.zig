const std = @import("std");
const zmake = @import("zmake");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabihf,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
        // Note that "fp_armv8d16sp" is the same instruction set as "fpv5-sp-d16", so LLVM only has the former
        // https://github.com/llvm/llvm-project/issues/95053
        // .cpu_features_add = std.Target.arm.featureSet(&[_] std.Target.arm.Feature {
        //     std.Target.arm.Feature.vfp4d16sp
        // }),
    });

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        // Excludes UBSAN code to prevent from bloating binary
        .sanitize_c = .off,
        .single_threaded = true,
    });
    mod.addCSourceFile(.{
        .file = b.path("src/main.c"),
        .flags = &.{},
    });

    const elf = b.addExecutable(.{
        .name = "firmware" ++ ".elf",
        .root_module = mod,
        .linkage = .static,
    });
    // elf.setLinkerScript()
    elf.entry = .{ .symbol_name = "main" };
    elf.link_gc_sections = true;
    elf.link_data_sections = true;
    elf.link_function_sections = true;
    // b.installArtifact(elf);

    // NOTE: There's currently some bugs with Zig's implementation of objcopy:
    // https://github.com/ziglang/zig/issues/25653
    // For now I'd reccomend gnu's objcopy or llvm-objcopy to accomplish the following:
    // const elf_bin = b.addObjCopy(elf.getEmittedBin(), .{
    //     .format = .bin,
    // });
    // elf_bin.step.dependOn(&elf.step);
    // const elf_bin_step = b.addInstallBinFile(elf_bin.getOutput(), "firmware.bin");

    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak)  {
            std.log.err("Memeory Leak.\n", .{});
        }
    }
    // const allocator = b.allocator;

    const info = try zmake.Compile.from(allocator, b, elf);
    defer info.deinit();
    const info_s = try info.stringify(allocator);
    defer allocator.free(info_s);
    std.debug.print("{s}\n", .{info_s});

    const emit_cc = b.option(bool, "compdb", "") orelse false;
    if (emit_cc) {
        try zmake.exportCompileCommands(allocator, b, elf, .{
            .sub_dir_path = "zig-out"
        });
    }
}
