const std = @import("std");

// Mirrors BOX3D_SOURCE_FILES in box3d/src/CMakeLists.txt.
const box3d_c_sources = [_][]const u8{
    "aabb.c",
    "arena_allocator.c",
    "bitset.c",
    "block_allocator.c",
    "body.c",
    "broad_phase.c",
    "capsule.c",
    "compound.c",
    "constraint_graph.c",
    "contact.c",
    "contact_solver.c",
    "convex_manifold.c",
    "core.c",
    "distance.c",
    "distance_joint.c",
    "dynamic_tree.c",
    "height_field.c",
    "hull.c",
    "id_pool.c",
    "island.c",
    "joint.c",
    "manifold.c",
    "math_functions.c",
    "mesh.c",
    "mesh_contact.c",
    "motor_joint.c",
    "mover.c",
    "name_cache.c",
    "parallel_for.c",
    "parallel_joint.c",
    "physics_world.c",
    "prismatic_joint.c",
    "recording.c",
    "recording_replay.c",
    "revolute_joint.c",
    "scheduler.c",
    "sensor.c",
    "shape.c",
    "simd.c",
    "solver.c",
    "solver_set.c",
    "sphere.c",
    "spherical_joint.c",
    "table.c",
    "timer.c",
    "triangle_manifold.c",
    "types.c",
    "weld_joint.c",
    "wheel_joint.c",
    "world_snapshot.c",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const box3d_src = b.option(
        []const u8,
        "box3d-src",
        "Path to the Box3D checkout (default: ../box3d relative to this package)",
    ) orelse "../box3d";
    const box3d_root = if (std.fs.path.isAbsolute(box3d_src))
        box3d_src
    else
        b.pathResolve(&.{ b.build_root.path orelse ".", box3d_src });

    const include_dir = std.Build.LazyPath{ .cwd_relative = b.pathJoin(&.{ box3d_root, "include" }) };
    const c_src_dir = std.Build.LazyPath{ .cwd_relative = b.pathJoin(&.{ box3d_root, "src" }) };

    const double_precision = b.option(
        bool,
        "double-precision",
        "Store world positions in double precision for large worlds (affects ABI)",
    ) orelse false;
    const validate = b.option(
        bool,
        "validate",
        "Enable Box3D heavy internal validation (debug builds)",
    ) orelse false;
    const simd = b.option(bool, "simd", "Use the SIMD math path") orelse true;

    // The Box3D C library.
    const lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib_mod.addIncludePath(include_dir);

    var cflags: std.ArrayListUnmanaged([]const u8) = .empty;
    cflags.append(b.allocator, "-std=c17") catch @panic("OOM");
    if (optimize != .Debug) cflags.append(b.allocator, "-DNDEBUG") catch @panic("OOM");
    lib_mod.addCSourceFiles(.{
        .root = c_src_dir,
        .files = &box3d_c_sources,
        .flags = cflags.items,
    });

    if (double_precision) lib_mod.addCMacro("BOX3D_DOUBLE_PRECISION", "1");
    if (validate) lib_mod.addCMacro("BOX3D_VALIDATE", "1");
    if (!simd) lib_mod.addCMacro("BOX3D_DISABLE_SIMD", "1");

    const lib = b.addLibrary(.{
        .name = "box3d",
        .linkage = .static,
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    // The Zig wrapper module consumers import.
    const mod = b.addModule("box3d", .{
        .root_source_file = b.path("src/box3d.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.addIncludePath(include_dir);
    if (double_precision) mod.addCMacro("BOX3D_DOUBLE_PRECISION", "1");
    mod.linkLibrary(lib);

    const tests = b.addTest(.{ .root_module = mod });
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Run the wrapper tests").dependOn(&run_tests.step);

    const example_mod = b.createModule(.{
        .root_source_file = b.path("examples/hello.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "box3d", .module = mod }},
    });
    const example = b.addExecutable(.{ .name = "hello", .root_module = example_mod });
    b.installArtifact(example);
    const run_example = b.addRunArtifact(example);
    b.step("run", "Run the falling-bodies example").dependOn(&run_example.step);
}
