# box3d-zig

Zig bindings for [Box3D](https://github.com/erincatto/box3d), Erin Catto's 3D
rigid body physics engine. The package compiles Box3D from source with Zig's C
compiler and exposes two layers:

- `box3d.c` — the complete raw C API via `@cImport`. Everything Box3D exports
  is reachable here (debug draw, recording/replay, standalone collision
  queries, the math library, ...).
- The wrapper — thin idiomatic handles (`World`, `Body`, `Shape`, `Joint` and
  the typed joints) over the Box3D id types. Handles are `extern struct`s that
  are layout-compatible with their C ids, so the two layers mix freely.

Method names map 1:1 onto the C API, so the upstream documentation applies
directly: `b3Body_GetLinearVelocity` is `Body.getLinearVelocity`.

Requires Zig 0.14+ and a Box3D checkout (defaults to `../box3d`).

## Quick start

```zig
const b3 = @import("box3d");

var world_def = b3.defaultWorldDef();
world_def.gravity = b3.vec3(0, -10, 0);
const world = try b3.World.create(&world_def);
defer world.destroy();

var ground_def = b3.defaultBodyDef();
ground_def.position = b3.pos(0, -1, 0);
const ground = world.createBody(&ground_def);
const shape_def = b3.defaultShapeDef();
_ = ground.createBoxShape(&shape_def, 50, 1, 50);

var ball_def = b3.dynamicBodyDef();
ball_def.position = b3.pos(0, 4, 0);
const ball = world.createBody(&ball_def);
_ = ball.createSphereShape(&shape_def, .{ .center = b3.vec3_zero, .radius = 0.5 });

while (running) {
    world.step(1.0 / 60.0, 4);
    const p = ball.getPosition();
    // ...
}
```

Run the bundled demo and tests:

```sh
zig build run    # falling boxes example
zig build test   # wrapper tests (also compile-checks every wrapper method)
```

## Using from another project (e.g. Matryoshka)

Add a path dependency in `build.zig.zon`:

```zig
.dependencies = .{
    .box3d = .{ .path = "../box3d-zig" },
},
```

and wire it up in `build.zig`:

```zig
const box3d_dep = b.dependency("box3d", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("box3d", box3d_dep.module("box3d"));
```

The static library and include paths ride along with the module — no extra
linking steps needed.

## Build options

| Option | Default | Effect |
| --- | --- | --- |
| `-Dbox3d-src=<path>` | `../box3d` | Location of the Box3D checkout (relative paths resolve against this package). |
| `-Ddouble-precision=true` | off | Large-world mode: world positions become `f64` (`b3.Pos` changes ABI). |
| `-Dvalidate=true` | off | Box3D's heavy internal validation. |
| `-Dsimd=false` | on | Fall back to scalar math instead of SSE2/NEON. |

Pass these through `b.dependency("box3d", .{ .@"double-precision" = true, ... })`
when consuming the package. Multithreading needs no build flag — set
`workerCount` in the `WorldDef` (Box3D spins up its own scheduler, or accepts
your task system via the `enqueueTask`/`finishTask` callbacks).

## Layout notes

- `Pos`/`WorldTransform` are distinct from `Vec3`/`Transform` only in
  double-precision builds; write against `Pos` (and the `b3.pos()` helper) and
  your code works in both modes.
- Box hulls from `b3.makeBoxHull` and friends are self-contained value types;
  pass `&box.base` to `Body.createHullShape`, or use the
  `Body.createBoxShape(def, hx, hy, hz)` convenience.
- Heap geometry (`b3.createHull`, `b3.createGridMesh`, ...) must be destroyed
  with the matching `b3.destroy*` function; shapes clone hulls but reference
  meshes and height fields, so keep those alive while shapes use them.
