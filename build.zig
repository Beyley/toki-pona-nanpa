const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const module = b.addModule("toki-pona-nanpa", .{ .source_file = .{ .path = "src/root.zig" } });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    const test_app = b.addExecutable(.{
        .name = "ale_nanpa",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
    });
    test_app.addModule("nanpa", module);

    b.installArtifact(test_app);

    const run_test_app_step = b.addRunArtifact(test_app);
    const run_step = b.step("run", "Runs the test app");
    run_step.dependOn(&run_test_app_step.step);
}
