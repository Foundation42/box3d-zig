//! Minimal Box3D example: drop a stack of boxes and a ball onto the ground
//! and print where they end up.

const std = @import("std");
const b3 = @import("box3d");

pub fn main() !void {
    var world_def = b3.defaultWorldDef();
    world_def.gravity = b3.vec3(0, -10, 0);
    const world = try b3.World.create(&world_def);
    defer world.destroy();

    // Static ground: a big flat box whose top surface is at y = 0.
    var ground_def = b3.defaultBodyDef();
    ground_def.position = b3.pos(0, -1, 0);
    const ground = world.createBody(&ground_def);
    const ground_shape = b3.defaultShapeDef();
    _ = ground.createBoxShape(&ground_shape, 50, 1, 50);

    // A little tower of boxes.
    const shape_def = b3.defaultShapeDef();
    var boxes: [5]b3.Body = undefined;
    for (&boxes, 0..) |*body, i| {
        var def = b3.dynamicBodyDef();
        def.position = b3.pos(0, 0.5 + 1.1 * @as(f64, @floatFromInt(i)), 0);
        body.* = world.createBody(&def);
        _ = body.createBoxShape(&shape_def, 0.5, 0.5, 0.5);
    }

    // A ball lobbed at the tower.
    var ball_def = b3.dynamicBodyDef();
    ball_def.position = b3.pos(-8, 3, 0);
    ball_def.linearVelocity = b3.vec3(12, 2, 0);
    const ball = world.createBody(&ball_def);
    _ = ball.createSphereShape(&shape_def, .{ .center = b3.vec3_zero, .radius = 0.5 });

    var i: usize = 0;
    while (i < 300) : (i += 1) {
        world.step(1.0 / 60.0, 4);
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("after 5 simulated seconds:\n", .{});
    for (boxes, 0..) |body, n| {
        const p = body.getPosition();
        try stdout.print("  box {d}: ({d:.2}, {d:.2}, {d:.2})\n", .{ n, p.x, p.y, p.z });
    }
    const bp = ball.getPosition();
    try stdout.print("  ball:  ({d:.2}, {d:.2}, {d:.2})\n", .{ bp.x, bp.y, bp.z });
    try stdout.print("  awake bodies: {d}\n", .{world.getAwakeBodyCount()});
}
