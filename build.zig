const std = @import("std");

fn addStartPoint(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    description: []const u8,
    path: []const u8,
    module: *std.Build.Module,
) *std.Build.Step {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("zigplotlib", module);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step(name, description);
    run_step.dependOn(&run_cmd.step);

    return run_step;
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "zigplotlib",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_module = &lib.root_module;

    _ = b.addModule("zigplotlib", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const run_step = addStartPoint(b, target, optimize, "run", "Run the App", "src/main.zig", lib_module);
    const step_step = addStartPoint(b, target, optimize, "step-example", "Run the Step example", "example/step.zig", lib_module);
    const stem_step = addStartPoint(b, target, optimize, "stem-example", "Run the Stem example", "example/stem.zig", lib_module);
    const scatter_step = addStartPoint(b, target, optimize, "scatter-example", "Run the Scatter example", "example/scatter.zig", lib_module);
    const line_step = addStartPoint(b, target, optimize, "line-example", "Run the Line example", "example/line.zig", lib_module);
    const area_step = addStartPoint(b, target, optimize, "area-example", "Run the Area example", "example/area.zig", lib_module);
    const log_step = addStartPoint(b, target, optimize, "log-example", "Run the Logarithmic example", "example/logarithmic.zig", lib_module);
    const candlestick_step = addStartPoint(b, target, optimize, "candlestick-example", "Run the Candle stick example", "example/candle_stick.zig", lib_module);

    const all_step = b.step("all", "Run all the examples");
    all_step.dependOn(run_step);
    all_step.dependOn(step_step);
    all_step.dependOn(stem_step);
    all_step.dependOn(scatter_step);
    all_step.dependOn(line_step);
    all_step.dependOn(area_step);
    all_step.dependOn(log_step);
    all_step.dependOn(candlestick_step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
