//! Idiomatic Zig wrapper for Box3D (https://github.com/erincatto/box3d).
//!
//! The raw C API is available as `box3d.c`. The wrapper types below are thin
//! handles over the Box3D id types — they add namespacing, slices, and Zig
//! enums, but never hide the underlying API. Anything not wrapped (debug draw,
//! recording/replay, the standalone collision routines) can be reached through
//! `box3d.c` and mixed freely with the wrapper, since handles are layout
//! compatible with their C ids.
//!
//! Method names map 1:1 onto the C API so Erin's documentation applies
//! directly: `b3Body_GetLinearVelocity` becomes `Body.getLinearVelocity`.

const std = @import("std");

pub const c = @cImport({
    @cInclude("box3d/box3d.h");
});

// ---------------------------------------------------------------------------
// Math and geometry types (re-exported from the C API)
// ---------------------------------------------------------------------------

pub const Vec2 = c.b3Vec2;
pub const Vec3 = c.b3Vec3;
pub const Quat = c.b3Quat;
pub const Transform = c.b3Transform;
/// World position. Same as `Vec3` unless built with -Ddouble-precision.
pub const Pos = c.b3Pos;
/// World transform. Same as `Transform` unless built with -Ddouble-precision.
pub const WorldTransform = c.b3WorldTransform;
pub const Matrix3 = c.b3Matrix3;
pub const AABB = c.b3AABB;
pub const Plane = c.b3Plane;

pub const Sphere = c.b3Sphere;
pub const Capsule = c.b3Capsule;
pub const HullData = c.b3HullData;
pub const BoxHull = c.b3BoxHull;
pub const MeshData = c.b3MeshData;
pub const MeshDef = c.b3MeshDef;
pub const Mesh = c.b3Mesh;
pub const HeightFieldData = c.b3HeightFieldData;
pub const HeightFieldDef = c.b3HeightFieldDef;
pub const CompoundData = c.b3CompoundData;
pub const CompoundDef = c.b3CompoundDef;
pub const ShapeProxy = c.b3ShapeProxy;
pub const MassData = c.b3MassData;

pub const WorldDef = c.b3WorldDef;
pub const BodyDef = c.b3BodyDef;
pub const ShapeDef = c.b3ShapeDef;
pub const ExplosionDef = c.b3ExplosionDef;
pub const Filter = c.b3Filter;
pub const QueryFilter = c.b3QueryFilter;
pub const SurfaceMaterial = c.b3SurfaceMaterial;
pub const MotionLocks = c.b3MotionLocks;
pub const Capacity = c.b3Capacity;

pub const RayResult = c.b3RayResult;
pub const WorldCastOutput = c.b3WorldCastOutput;
pub const BodyCastResult = c.b3BodyCastResult;
pub const BodyPlaneResult = c.b3BodyPlaneResult;
pub const ContactData = c.b3ContactData;
pub const TreeStats = c.b3TreeStats;
pub const Profile = c.b3Profile;
pub const Counters = c.b3Counters;

pub const BodyEvents = c.b3BodyEvents;
pub const SensorEvents = c.b3SensorEvents;
pub const ContactEvents = c.b3ContactEvents;
pub const JointEvents = c.b3JointEvents;

pub const DebugDraw = c.b3DebugDraw;

pub const OverlapResultFcn = c.b3OverlapResultFcn;
pub const CastResultFcn = c.b3CastResultFcn;
pub const MoverFilterFcn = c.b3MoverFilterFcn;
pub const PlaneResultFcn = c.b3PlaneResultFcn;
pub const CustomFilterFcn = c.b3CustomFilterFcn;
pub const PreSolveFcn = c.b3PreSolveFcn;
pub const FrictionCallback = c.b3FrictionCallback;
pub const RestitutionCallback = c.b3RestitutionCallback;

pub const DistanceJointDef = c.b3DistanceJointDef;
pub const MotorJointDef = c.b3MotorJointDef;
pub const FilterJointDef = c.b3FilterJointDef;
pub const ParallelJointDef = c.b3ParallelJointDef;
pub const PrismaticJointDef = c.b3PrismaticJointDef;
pub const RevoluteJointDef = c.b3RevoluteJointDef;
pub const SphericalJointDef = c.b3SphericalJointDef;
pub const WeldJointDef = c.b3WeldJointDef;
pub const WheelJointDef = c.b3WheelJointDef;

pub const BodyType = enum(c_uint) {
    static = c.b3_staticBody,
    kinematic = c.b3_kinematicBody,
    dynamic = c.b3_dynamicBody,
};

pub const ShapeType = enum(c_uint) {
    capsule = c.b3_capsuleShape,
    compound = c.b3_compoundShape,
    height_field = c.b3_heightShape,
    hull = c.b3_hullShape,
    mesh = c.b3_meshShape,
    sphere = c.b3_sphereShape,
};

pub const JointType = enum(c_uint) {
    parallel = c.b3_parallelJoint,
    distance = c.b3_distanceJoint,
    filter = c.b3_filterJoint,
    motor = c.b3_motorJoint,
    prismatic = c.b3_prismaticJoint,
    revolute = c.b3_revoluteJoint,
    spherical = c.b3_sphericalJoint,
    weld = c.b3_weldJoint,
    wheel = c.b3_wheelJoint,
};

// ---------------------------------------------------------------------------
// Small constructors and constants
// ---------------------------------------------------------------------------

pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return .{ .x = x, .y = y, .z = z };
}

/// Make a world position. Takes f64 so it works unchanged in double-precision
/// builds; values are narrowed to f32 in the default single-precision build.
pub fn pos(x: f64, y: f64, z: f64) Pos {
    return .{ .x = @floatCast(x), .y = @floatCast(y), .z = @floatCast(z) };
}

pub const vec3_zero = Vec3{ .x = 0, .y = 0, .z = 0 };
pub const vec3_one = Vec3{ .x = 1, .y = 1, .z = 1 };
pub const axis_x = Vec3{ .x = 1, .y = 0, .z = 0 };
pub const axis_y = Vec3{ .x = 0, .y = 1, .z = 0 };
pub const axis_z = Vec3{ .x = 0, .y = 0, .z = 1 };
pub const quat_identity = Quat{ .v = vec3_zero, .s = 1 };
pub const transform_identity = Transform{ .p = vec3_zero, .q = quat_identity };

pub fn defaultWorldDef() WorldDef {
    return c.b3DefaultWorldDef();
}

pub fn defaultBodyDef() BodyDef {
    return c.b3DefaultBodyDef();
}

/// Body definition preset for a dynamic body.
pub fn dynamicBodyDef() BodyDef {
    var def = c.b3DefaultBodyDef();
    def.type = c.b3_dynamicBody;
    return def;
}

/// Body definition preset for a kinematic body.
pub fn kinematicBodyDef() BodyDef {
    var def = c.b3DefaultBodyDef();
    def.type = c.b3_kinematicBody;
    return def;
}

pub fn defaultShapeDef() ShapeDef {
    return c.b3DefaultShapeDef();
}

pub fn defaultFilter() Filter {
    return c.b3DefaultFilter();
}

pub fn defaultQueryFilter() QueryFilter {
    return c.b3DefaultQueryFilter();
}

pub fn defaultSurfaceMaterial() SurfaceMaterial {
    return c.b3DefaultSurfaceMaterial();
}

pub fn defaultExplosionDef() ExplosionDef {
    return c.b3DefaultExplosionDef();
}

pub fn defaultDebugDraw() DebugDraw {
    return c.b3DefaultDebugDraw();
}

// Box hulls are self-contained value types: the embedded offsets are relative,
// so the result can be copied and passed to Body.createHullShape via `.base`.
pub const makeCubeHull = c.b3MakeCubeHull;
pub const makeBoxHull = c.b3MakeBoxHull;
pub const makeOffsetBoxHull = c.b3MakeOffsetBoxHull;
pub const makeTransformedBoxHull = c.b3MakeTransformedBoxHull;
pub const makeScaledBoxHull = c.b3MakeScaledBoxHull;

// Heap-allocated geometry. Destroy with the matching destroy function.
pub const createHull = c.b3CreateHull;
pub const createCylinder = c.b3CreateCylinder;
pub const createCone = c.b3CreateCone;
pub const createRock = c.b3CreateRock;
pub const cloneHull = c.b3CloneHull;
pub const cloneAndTransformHull = c.b3CloneAndTransformHull;
pub const destroyHull = c.b3DestroyHull;

pub const createMesh = c.b3CreateMesh;
pub const createGridMesh = c.b3CreateGridMesh;
pub const createWaveMesh = c.b3CreateWaveMesh;
pub const createTorusMesh = c.b3CreateTorusMesh;
pub const createBoxMesh = c.b3CreateBoxMesh;
pub const createHollowBoxMesh = c.b3CreateHollowBoxMesh;
pub const createPlatformMesh = c.b3CreatePlatformMesh;
pub const destroyMesh = c.b3DestroyMesh;

pub const createHeightField = c.b3CreateHeightField;
pub const createGrid = c.b3CreateGrid;
pub const createWave = c.b3CreateWave;
pub const destroyHeightField = c.b3DestroyHeightField;

pub const createCompound = c.b3CreateCompound;
pub const destroyCompound = c.b3DestroyCompound;

pub fn getWorldCount() i32 {
    return c.b3GetWorldCount();
}

pub fn getMaxWorldCount() i32 {
    return c.b3GetMaxWorldCount();
}

// ---------------------------------------------------------------------------
// World
// ---------------------------------------------------------------------------

pub const World = extern struct {
    id: c.b3WorldId,

    pub const null_world = World{ .id = .{ .index1 = 0, .generation = 0 } };

    /// Create a simulation world. Fails if the world limit (128) is reached.
    pub fn create(def: *const WorldDef) error{CreateWorldFailed}!World {
        const id = c.b3CreateWorld(def);
        if (id.index1 == 0) return error.CreateWorldFailed;
        return .{ .id = id };
    }

    pub fn destroy(self: World) void {
        c.b3DestroyWorld(self.id);
    }

    pub fn isValid(self: World) bool {
        return c.b3World_IsValid(self.id);
    }

    pub fn isNull(self: World) bool {
        return self.id.index1 == 0;
    }

    /// Simulate one time step. `time_step` is usually 1/60, `sub_step_count` usually 4.
    pub fn step(self: World, time_step: f32, sub_step_count: i32) void {
        c.b3World_Step(self.id, time_step, sub_step_count);
    }

    pub fn draw(self: World, debug_draw: *DebugDraw, mask_bits: u64) void {
        c.b3World_Draw(self.id, debug_draw, mask_bits);
    }

    pub fn getBounds(self: World) AABB {
        return c.b3World_GetBounds(self.id);
    }

    // Events (transient — valid until the next step)

    pub fn getBodyEvents(self: World) BodyEvents {
        return c.b3World_GetBodyEvents(self.id);
    }

    pub fn getSensorEvents(self: World) SensorEvents {
        return c.b3World_GetSensorEvents(self.id);
    }

    pub fn getContactEvents(self: World) ContactEvents {
        return c.b3World_GetContactEvents(self.id);
    }

    pub fn getJointEvents(self: World) JointEvents {
        return c.b3World_GetJointEvents(self.id);
    }

    // Queries

    pub fn overlapAABB(self: World, aabb: AABB, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats {
        return c.b3World_OverlapAABB(self.id, aabb, filter, fcn, context);
    }

    pub fn overlapShape(self: World, origin: Pos, proxy: *const ShapeProxy, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats {
        return c.b3World_OverlapShape(self.id, origin, proxy, filter, fcn, context);
    }

    pub fn castRay(self: World, origin: Pos, translation: Vec3, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats {
        return c.b3World_CastRay(self.id, origin, translation, filter, fcn, context);
    }

    pub fn castRayClosest(self: World, origin: Pos, translation: Vec3, filter: QueryFilter) RayResult {
        return c.b3World_CastRayClosest(self.id, origin, translation, filter);
    }

    pub fn castShape(self: World, origin: Pos, proxy: *const ShapeProxy, translation: Vec3, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats {
        return c.b3World_CastShape(self.id, origin, proxy, translation, filter, fcn, context);
    }

    pub fn castMover(self: World, origin: Pos, mover: *const Capsule, translation: Vec3, filter: QueryFilter, fcn: MoverFilterFcn, context: ?*anyopaque) f32 {
        return c.b3World_CastMover(self.id, origin, mover, translation, filter, fcn, context);
    }

    pub fn collideMover(self: World, origin: Pos, mover: *const Capsule, filter: QueryFilter, fcn: PlaneResultFcn, context: ?*anyopaque) void {
        c.b3World_CollideMover(self.id, origin, mover, filter, fcn, context);
    }

    // Configuration

    pub fn enableSleeping(self: World, flag: bool) void {
        c.b3World_EnableSleeping(self.id, flag);
    }

    pub fn isSleepingEnabled(self: World) bool {
        return c.b3World_IsSleepingEnabled(self.id);
    }

    pub fn enableContinuous(self: World, flag: bool) void {
        c.b3World_EnableContinuous(self.id, flag);
    }

    pub fn isContinuousEnabled(self: World) bool {
        return c.b3World_IsContinuousEnabled(self.id);
    }

    pub fn enableSpeculative(self: World, flag: bool) void {
        c.b3World_EnableSpeculative(self.id, flag);
    }

    pub fn setRestitutionThreshold(self: World, value: f32) void {
        c.b3World_SetRestitutionThreshold(self.id, value);
    }

    pub fn getRestitutionThreshold(self: World) f32 {
        return c.b3World_GetRestitutionThreshold(self.id);
    }

    pub fn setHitEventThreshold(self: World, value: f32) void {
        c.b3World_SetHitEventThreshold(self.id, value);
    }

    pub fn getHitEventThreshold(self: World) f32 {
        return c.b3World_GetHitEventThreshold(self.id);
    }

    pub fn setCustomFilterCallback(self: World, fcn: CustomFilterFcn, context: ?*anyopaque) void {
        c.b3World_SetCustomFilterCallback(self.id, fcn, context);
    }

    pub fn setPreSolveCallback(self: World, fcn: PreSolveFcn, context: ?*anyopaque) void {
        c.b3World_SetPreSolveCallback(self.id, fcn, context);
    }

    pub fn setGravity(self: World, gravity: Vec3) void {
        c.b3World_SetGravity(self.id, gravity);
    }

    pub fn getGravity(self: World) Vec3 {
        return c.b3World_GetGravity(self.id);
    }

    pub fn explode(self: World, def: *const ExplosionDef) void {
        c.b3World_Explode(self.id, def);
    }

    pub fn setContactTuning(self: World, hertz: f32, damping_ratio: f32, contact_speed: f32) void {
        c.b3World_SetContactTuning(self.id, hertz, damping_ratio, contact_speed);
    }

    pub fn setContactRecycleDistance(self: World, recycle_distance: f32) void {
        c.b3World_SetContactRecycleDistance(self.id, recycle_distance);
    }

    pub fn getContactRecycleDistance(self: World) f32 {
        return c.b3World_GetContactRecycleDistance(self.id);
    }

    pub fn setMaximumLinearSpeed(self: World, speed: f32) void {
        c.b3World_SetMaximumLinearSpeed(self.id, speed);
    }

    pub fn getMaximumLinearSpeed(self: World) f32 {
        return c.b3World_GetMaximumLinearSpeed(self.id);
    }

    pub fn enableWarmStarting(self: World, flag: bool) void {
        c.b3World_EnableWarmStarting(self.id, flag);
    }

    pub fn isWarmStartingEnabled(self: World) bool {
        return c.b3World_IsWarmStartingEnabled(self.id);
    }

    pub fn setFrictionCallback(self: World, callback: FrictionCallback) void {
        c.b3World_SetFrictionCallback(self.id, callback);
    }

    pub fn setRestitutionCallback(self: World, callback: RestitutionCallback) void {
        c.b3World_SetRestitutionCallback(self.id, callback);
    }

    pub fn setWorkerCount(self: World, count: i32) void {
        c.b3World_SetWorkerCount(self.id, count);
    }

    pub fn getWorkerCount(self: World) i32 {
        return c.b3World_GetWorkerCount(self.id);
    }

    pub fn setUserData(self: World, user_data: ?*anyopaque) void {
        c.b3World_SetUserData(self.id, user_data);
    }

    pub fn getUserData(self: World) ?*anyopaque {
        return c.b3World_GetUserData(self.id);
    }

    // Diagnostics

    pub fn getAwakeBodyCount(self: World) i32 {
        return c.b3World_GetAwakeBodyCount(self.id);
    }

    pub fn getProfile(self: World) Profile {
        return c.b3World_GetProfile(self.id);
    }

    pub fn getCounters(self: World) Counters {
        return c.b3World_GetCounters(self.id);
    }

    pub fn getMaxCapacity(self: World) Capacity {
        return c.b3World_GetMaxCapacity(self.id);
    }

    pub fn dumpMemoryStats(self: World) void {
        c.b3World_DumpMemoryStats(self.id);
    }

    pub fn rebuildStaticTree(self: World) void {
        c.b3World_RebuildStaticTree(self.id);
    }

    // Creation

    pub fn createBody(self: World, def: *const BodyDef) Body {
        return .{ .id = c.b3CreateBody(self.id, def) };
    }

    pub fn createDistanceJoint(self: World, def: *const DistanceJointDef) DistanceJoint {
        return .{ .joint = .{ .id = c.b3CreateDistanceJoint(self.id, def) } };
    }

    pub fn createMotorJoint(self: World, def: *const MotorJointDef) MotorJoint {
        return .{ .joint = .{ .id = c.b3CreateMotorJoint(self.id, def) } };
    }

    pub fn createFilterJoint(self: World, def: *const FilterJointDef) Joint {
        return .{ .id = c.b3CreateFilterJoint(self.id, def) };
    }

    pub fn createParallelJoint(self: World, def: *const ParallelJointDef) ParallelJoint {
        return .{ .joint = .{ .id = c.b3CreateParallelJoint(self.id, def) } };
    }

    pub fn createPrismaticJoint(self: World, def: *const PrismaticJointDef) PrismaticJoint {
        return .{ .joint = .{ .id = c.b3CreatePrismaticJoint(self.id, def) } };
    }

    pub fn createRevoluteJoint(self: World, def: *const RevoluteJointDef) RevoluteJoint {
        return .{ .joint = .{ .id = c.b3CreateRevoluteJoint(self.id, def) } };
    }

    pub fn createSphericalJoint(self: World, def: *const SphericalJointDef) SphericalJoint {
        return .{ .joint = .{ .id = c.b3CreateSphericalJoint(self.id, def) } };
    }

    pub fn createWeldJoint(self: World, def: *const WeldJointDef) WeldJoint {
        return .{ .joint = .{ .id = c.b3CreateWeldJoint(self.id, def) } };
    }

    pub fn createWheelJoint(self: World, def: *const WheelJointDef) WheelJoint {
        return .{ .joint = .{ .id = c.b3CreateWheelJoint(self.id, def) } };
    }
};

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

pub const Body = extern struct {
    id: c.b3BodyId,

    pub const null_body = Body{ .id = .{ .index1 = 0, .world0 = 0, .generation = 0 } };

    /// Destroys the body and all attached shapes and joints.
    pub fn destroy(self: Body) void {
        c.b3DestroyBody(self.id);
    }

    pub fn isValid(self: Body) bool {
        return c.b3Body_IsValid(self.id);
    }

    pub fn isNull(self: Body) bool {
        return self.id.index1 == 0;
    }

    pub fn eql(self: Body, other: Body) bool {
        return self.id.index1 == other.id.index1 and
            self.id.world0 == other.id.world0 and
            self.id.generation == other.id.generation;
    }

    pub fn getType(self: Body) BodyType {
        return @enumFromInt(c.b3Body_GetType(self.id));
    }

    pub fn setType(self: Body, body_type: BodyType) void {
        c.b3Body_SetType(self.id, @intFromEnum(body_type));
    }

    pub fn setName(self: Body, name: [:0]const u8) void {
        c.b3Body_SetName(self.id, name.ptr);
    }

    pub fn getName(self: Body) [:0]const u8 {
        const p = c.b3Body_GetName(self.id);
        return if (p == null) "" else std.mem.span(p);
    }

    pub fn setUserData(self: Body, user_data: ?*anyopaque) void {
        c.b3Body_SetUserData(self.id, user_data);
    }

    pub fn getUserData(self: Body) ?*anyopaque {
        return c.b3Body_GetUserData(self.id);
    }

    // Transform

    pub fn getPosition(self: Body) Pos {
        return c.b3Body_GetPosition(self.id);
    }

    pub fn getRotation(self: Body) Quat {
        return c.b3Body_GetRotation(self.id);
    }

    pub fn getTransform(self: Body) WorldTransform {
        return c.b3Body_GetTransform(self.id);
    }

    pub fn setTransform(self: Body, position: Pos, rotation: Quat) void {
        c.b3Body_SetTransform(self.id, position, rotation);
    }

    pub fn getLocalPoint(self: Body, world_point: Pos) Vec3 {
        return c.b3Body_GetLocalPoint(self.id, world_point);
    }

    pub fn getWorldPoint(self: Body, local_point: Vec3) Pos {
        return c.b3Body_GetWorldPoint(self.id, local_point);
    }

    pub fn getLocalVector(self: Body, world_vector: Vec3) Vec3 {
        return c.b3Body_GetLocalVector(self.id, world_vector);
    }

    pub fn getWorldVector(self: Body, local_vector: Vec3) Vec3 {
        return c.b3Body_GetWorldVector(self.id, local_vector);
    }

    // Velocity

    pub fn getLinearVelocity(self: Body) Vec3 {
        return c.b3Body_GetLinearVelocity(self.id);
    }

    pub fn getAngularVelocity(self: Body) Vec3 {
        return c.b3Body_GetAngularVelocity(self.id);
    }

    pub fn setLinearVelocity(self: Body, velocity: Vec3) void {
        c.b3Body_SetLinearVelocity(self.id, velocity);
    }

    pub fn setAngularVelocity(self: Body, velocity: Vec3) void {
        c.b3Body_SetAngularVelocity(self.id, velocity);
    }

    /// Kinematic bodies: set velocities so the body reaches `target` over `time_step`.
    pub fn setTargetTransform(self: Body, target: WorldTransform, time_step: f32, wake: bool) void {
        c.b3Body_SetTargetTransform(self.id, target, time_step, wake);
    }

    pub fn getLocalPointVelocity(self: Body, local_point: Vec3) Vec3 {
        return c.b3Body_GetLocalPointVelocity(self.id, local_point);
    }

    pub fn getWorldPointVelocity(self: Body, world_point: Pos) Vec3 {
        return c.b3Body_GetWorldPointVelocity(self.id, world_point);
    }

    // Forces and impulses

    pub fn applyForce(self: Body, force: Vec3, point: Pos, wake: bool) void {
        c.b3Body_ApplyForce(self.id, force, point, wake);
    }

    pub fn applyForceToCenter(self: Body, force: Vec3, wake: bool) void {
        c.b3Body_ApplyForceToCenter(self.id, force, wake);
    }

    pub fn applyTorque(self: Body, torque: Vec3, wake: bool) void {
        c.b3Body_ApplyTorque(self.id, torque, wake);
    }

    pub fn applyLinearImpulse(self: Body, impulse: Vec3, point: Pos, wake: bool) void {
        c.b3Body_ApplyLinearImpulse(self.id, impulse, point, wake);
    }

    pub fn applyLinearImpulseToCenter(self: Body, impulse: Vec3, wake: bool) void {
        c.b3Body_ApplyLinearImpulseToCenter(self.id, impulse, wake);
    }

    pub fn applyAngularImpulse(self: Body, impulse: Vec3, wake: bool) void {
        c.b3Body_ApplyAngularImpulse(self.id, impulse, wake);
    }

    // Mass

    pub fn getMass(self: Body) f32 {
        return c.b3Body_GetMass(self.id);
    }

    pub fn getInverseMass(self: Body) f32 {
        return c.b3Body_GetInverseMass(self.id);
    }

    pub fn getLocalRotationalInertia(self: Body) Matrix3 {
        return c.b3Body_GetLocalRotationalInertia(self.id);
    }

    pub fn getWorldInverseRotationalInertia(self: Body) Matrix3 {
        return c.b3Body_GetWorldInverseRotationalInertia(self.id);
    }

    pub fn getLocalCenter(self: Body) Vec3 {
        return c.b3Body_GetLocalCenter(self.id);
    }

    pub fn getWorldCenter(self: Body) Pos {
        return c.b3Body_GetWorldCenter(self.id);
    }

    pub fn setMassData(self: Body, mass_data: MassData) void {
        c.b3Body_SetMassData(self.id, mass_data);
    }

    pub fn getMassData(self: Body) MassData {
        return c.b3Body_GetMassData(self.id);
    }

    pub fn applyMassFromShapes(self: Body) void {
        c.b3Body_ApplyMassFromShapes(self.id);
    }

    // Damping and gravity

    pub fn setLinearDamping(self: Body, damping: f32) void {
        c.b3Body_SetLinearDamping(self.id, damping);
    }

    pub fn getLinearDamping(self: Body) f32 {
        return c.b3Body_GetLinearDamping(self.id);
    }

    pub fn setAngularDamping(self: Body, damping: f32) void {
        c.b3Body_SetAngularDamping(self.id, damping);
    }

    pub fn getAngularDamping(self: Body) f32 {
        return c.b3Body_GetAngularDamping(self.id);
    }

    pub fn setGravityScale(self: Body, scale: f32) void {
        c.b3Body_SetGravityScale(self.id, scale);
    }

    pub fn getGravityScale(self: Body) f32 {
        return c.b3Body_GetGravityScale(self.id);
    }

    // Sleep and enable state

    pub fn isAwake(self: Body) bool {
        return c.b3Body_IsAwake(self.id);
    }

    pub fn setAwake(self: Body, awake: bool) void {
        c.b3Body_SetAwake(self.id, awake);
    }

    pub fn enableSleep(self: Body, flag: bool) void {
        c.b3Body_EnableSleep(self.id, flag);
    }

    pub fn isSleepEnabled(self: Body) bool {
        return c.b3Body_IsSleepEnabled(self.id);
    }

    pub fn setSleepThreshold(self: Body, threshold: f32) void {
        c.b3Body_SetSleepThreshold(self.id, threshold);
    }

    pub fn getSleepThreshold(self: Body) f32 {
        return c.b3Body_GetSleepThreshold(self.id);
    }

    pub fn isEnabled(self: Body) bool {
        return c.b3Body_IsEnabled(self.id);
    }

    pub fn disable(self: Body) void {
        c.b3Body_Disable(self.id);
    }

    pub fn enable(self: Body) void {
        c.b3Body_Enable(self.id);
    }

    // Flags

    pub fn setMotionLocks(self: Body, locks: MotionLocks) void {
        c.b3Body_SetMotionLocks(self.id, locks);
    }

    pub fn getMotionLocks(self: Body) MotionLocks {
        return c.b3Body_GetMotionLocks(self.id);
    }

    pub fn setBullet(self: Body, flag: bool) void {
        c.b3Body_SetBullet(self.id, flag);
    }

    pub fn isBullet(self: Body) bool {
        return c.b3Body_IsBullet(self.id);
    }

    pub fn allowFastRotation(self: Body, flag: bool) void {
        c.b3Body_AllowFastRotation(self.id, flag);
    }

    pub fn isFastRotationAllowed(self: Body) bool {
        return c.b3Body_IsFastRotationAllowed(self.id);
    }

    pub fn enableContactRecycling(self: Body, flag: bool) void {
        c.b3Body_EnableContactRecycling(self.id, flag);
    }

    pub fn isContactRecyclingEnabled(self: Body) bool {
        return c.b3Body_IsContactRecyclingEnabled(self.id);
    }

    pub fn enableHitEvents(self: Body, flag: bool) void {
        c.b3Body_EnableHitEvents(self.id, flag);
    }

    // Associated objects

    pub fn getWorld(self: Body) World {
        return .{ .id = c.b3Body_GetWorld(self.id) };
    }

    pub fn getShapeCount(self: Body) i32 {
        return c.b3Body_GetShapeCount(self.id);
    }

    /// Fills `buffer` with the body's shapes and returns the filled slice.
    pub fn getShapes(self: Body, buffer: []Shape) []Shape {
        const n = c.b3Body_GetShapes(self.id, @ptrCast(buffer.ptr), @intCast(buffer.len));
        return buffer[0..@intCast(n)];
    }

    pub fn getJointCount(self: Body) i32 {
        return c.b3Body_GetJointCount(self.id);
    }

    /// Fills `buffer` with the body's joints and returns the filled slice.
    pub fn getJoints(self: Body, buffer: []Joint) []Joint {
        const n = c.b3Body_GetJoints(self.id, @ptrCast(buffer.ptr), @intCast(buffer.len));
        return buffer[0..@intCast(n)];
    }

    pub fn getContactCapacity(self: Body) i32 {
        return c.b3Body_GetContactCapacity(self.id);
    }

    /// Fills `buffer` with contact data and returns the filled slice.
    pub fn getContactData(self: Body, buffer: []ContactData) []ContactData {
        const n = c.b3Body_GetContactData(self.id, buffer.ptr, @intCast(buffer.len));
        return buffer[0..@intCast(n)];
    }

    // Queries

    pub fn computeAABB(self: Body) AABB {
        return c.b3Body_ComputeAABB(self.id);
    }

    pub const ClosestPoint = struct { point: Vec3, distance: f32 };

    pub fn getClosestPoint(self: Body, target: Vec3) ClosestPoint {
        var result: Vec3 = undefined;
        const distance = c.b3Body_GetClosestPoint(self.id, &result, target);
        return .{ .point = result, .distance = distance };
    }

    pub fn castRay(self: Body, origin: Pos, translation: Vec3, filter: QueryFilter, max_fraction: f32, body_transform: WorldTransform) BodyCastResult {
        return c.b3Body_CastRay(self.id, origin, translation, filter, max_fraction, body_transform);
    }

    pub fn castShape(self: Body, origin: Pos, proxy: *const ShapeProxy, translation: Vec3, filter: QueryFilter, max_fraction: f32, can_encroach: bool, body_transform: WorldTransform) BodyCastResult {
        return c.b3Body_CastShape(self.id, origin, proxy, translation, filter, max_fraction, can_encroach, body_transform);
    }

    pub fn overlapShape(self: Body, origin: Pos, proxy: *const ShapeProxy, filter: QueryFilter, body_transform: WorldTransform) bool {
        return c.b3Body_OverlapShape(self.id, origin, proxy, filter, body_transform);
    }

    pub fn collideMover(self: Body, body_planes: []BodyPlaneResult, origin: Pos, mover: *const Capsule, filter: QueryFilter, body_transform: WorldTransform) []BodyPlaneResult {
        const n = c.b3Body_CollideMover(self.id, body_planes.ptr, @intCast(body_planes.len), origin, mover, filter, body_transform);
        return body_planes[0..@intCast(n)];
    }

    // Shape creation

    pub fn createSphereShape(self: Body, def: *const ShapeDef, sphere: Sphere) Shape {
        return .{ .id = c.b3CreateSphereShape(self.id, def, &sphere) };
    }

    pub fn createCapsuleShape(self: Body, def: *const ShapeDef, capsule: Capsule) Shape {
        return .{ .id = c.b3CreateCapsuleShape(self.id, def, &capsule) };
    }

    pub fn createHullShape(self: Body, def: *const ShapeDef, hull: *const HullData) Shape {
        return .{ .id = c.b3CreateHullShape(self.id, def, hull) };
    }

    /// Convenience: create an axis-aligned box hull shape from half extents.
    pub fn createBoxShape(self: Body, def: *const ShapeDef, hx: f32, hy: f32, hz: f32) Shape {
        const box = c.b3MakeBoxHull(hx, hy, hz);
        return .{ .id = c.b3CreateHullShape(self.id, def, &box.base) };
    }

    pub fn createTransformedHullShape(self: Body, def: *const ShapeDef, hull: *const HullData, transform: Transform, scale: Vec3) Shape {
        return .{ .id = c.b3CreateTransformedHullShape(self.id, def, hull, transform, scale) };
    }

    pub fn createMeshShape(self: Body, def: *const ShapeDef, mesh: *const MeshData, scale: Vec3) Shape {
        return .{ .id = c.b3CreateMeshShape(self.id, def, mesh, scale) };
    }

    pub fn createHeightFieldShape(self: Body, def: *const ShapeDef, height_field: *const HeightFieldData) Shape {
        return .{ .id = c.b3CreateHeightFieldShape(self.id, def, height_field) };
    }

    pub fn createBakedCompoundShape(self: Body, def: *ShapeDef, compound: *const CompoundData) Shape {
        return .{ .id = c.b3CreateBakedCompoundShape(self.id, def, compound) };
    }
};

// ---------------------------------------------------------------------------
// Shape
// ---------------------------------------------------------------------------

pub const Shape = extern struct {
    id: c.b3ShapeId,

    pub const null_shape = Shape{ .id = .{ .index1 = 0, .world0 = 0, .generation = 0 } };

    pub fn destroy(self: Shape, update_body_mass: bool) void {
        c.b3DestroyShape(self.id, update_body_mass);
    }

    pub fn isValid(self: Shape) bool {
        return c.b3Shape_IsValid(self.id);
    }

    pub fn isNull(self: Shape) bool {
        return self.id.index1 == 0;
    }

    pub fn eql(self: Shape, other: Shape) bool {
        return self.id.index1 == other.id.index1 and
            self.id.world0 == other.id.world0 and
            self.id.generation == other.id.generation;
    }

    pub fn getType(self: Shape) ShapeType {
        return @enumFromInt(c.b3Shape_GetType(self.id));
    }

    pub fn getBody(self: Shape) Body {
        return .{ .id = c.b3Shape_GetBody(self.id) };
    }

    pub fn getWorld(self: Shape) World {
        return .{ .id = c.b3Shape_GetWorld(self.id) };
    }

    pub fn isSensor(self: Shape) bool {
        return c.b3Shape_IsSensor(self.id);
    }

    pub fn setName(self: Shape, name: [:0]const u8) void {
        c.b3Shape_SetName(self.id, name.ptr);
    }

    pub fn getName(self: Shape) [:0]const u8 {
        const p = c.b3Shape_GetName(self.id);
        return if (p == null) "" else std.mem.span(p);
    }

    pub fn setUserData(self: Shape, user_data: ?*anyopaque) void {
        c.b3Shape_SetUserData(self.id, user_data);
    }

    pub fn getUserData(self: Shape) ?*anyopaque {
        return c.b3Shape_GetUserData(self.id);
    }

    // Material

    pub fn setDensity(self: Shape, density: f32, update_body_mass: bool) void {
        c.b3Shape_SetDensity(self.id, density, update_body_mass);
    }

    pub fn getDensity(self: Shape) f32 {
        return c.b3Shape_GetDensity(self.id);
    }

    pub fn setFriction(self: Shape, friction: f32) void {
        c.b3Shape_SetFriction(self.id, friction);
    }

    pub fn getFriction(self: Shape) f32 {
        return c.b3Shape_GetFriction(self.id);
    }

    pub fn setRestitution(self: Shape, restitution: f32) void {
        c.b3Shape_SetRestitution(self.id, restitution);
    }

    pub fn getRestitution(self: Shape) f32 {
        return c.b3Shape_GetRestitution(self.id);
    }

    pub fn setSurfaceMaterial(self: Shape, material: SurfaceMaterial) void {
        c.b3Shape_SetSurfaceMaterial(self.id, material);
    }

    pub fn getSurfaceMaterial(self: Shape) SurfaceMaterial {
        return c.b3Shape_GetSurfaceMaterial(self.id);
    }

    pub fn getMeshMaterialCount(self: Shape) i32 {
        return c.b3Shape_GetMeshMaterialCount(self.id);
    }

    pub fn setMeshMaterial(self: Shape, material: SurfaceMaterial, index: i32) void {
        c.b3Shape_SetMeshMaterial(self.id, material, index);
    }

    pub fn getMeshSurfaceMaterial(self: Shape, index: i32) SurfaceMaterial {
        return c.b3Shape_GetMeshSurfaceMaterial(self.id, index);
    }

    // Filtering and events

    pub fn getFilter(self: Shape) Filter {
        return c.b3Shape_GetFilter(self.id);
    }

    pub fn setFilter(self: Shape, filter: Filter, invoke_contacts: bool) void {
        c.b3Shape_SetFilter(self.id, filter, invoke_contacts);
    }

    pub fn enableSensorEvents(self: Shape, flag: bool) void {
        c.b3Shape_EnableSensorEvents(self.id, flag);
    }

    pub fn areSensorEventsEnabled(self: Shape) bool {
        return c.b3Shape_AreSensorEventsEnabled(self.id);
    }

    pub fn enableContactEvents(self: Shape, flag: bool) void {
        c.b3Shape_EnableContactEvents(self.id, flag);
    }

    pub fn areContactEventsEnabled(self: Shape) bool {
        return c.b3Shape_AreContactEventsEnabled(self.id);
    }

    pub fn enablePreSolveEvents(self: Shape, flag: bool) void {
        c.b3Shape_EnablePreSolveEvents(self.id, flag);
    }

    pub fn arePreSolveEventsEnabled(self: Shape) bool {
        return c.b3Shape_ArePreSolveEventsEnabled(self.id);
    }

    pub fn enableHitEvents(self: Shape, flag: bool) void {
        c.b3Shape_EnableHitEvents(self.id, flag);
    }

    pub fn areHitEventsEnabled(self: Shape) bool {
        return c.b3Shape_AreHitEventsEnabled(self.id);
    }

    // Geometry access

    pub fn rayCast(self: Shape, origin: Pos, translation: Vec3) WorldCastOutput {
        return c.b3Shape_RayCast(self.id, origin, translation);
    }

    pub fn getSphere(self: Shape) Sphere {
        return c.b3Shape_GetSphere(self.id);
    }

    pub fn getCapsule(self: Shape) Capsule {
        return c.b3Shape_GetCapsule(self.id);
    }

    pub fn getHull(self: Shape) *const HullData {
        return c.b3Shape_GetHull(self.id);
    }

    pub fn getMesh(self: Shape) Mesh {
        return c.b3Shape_GetMesh(self.id);
    }

    pub fn getHeightField(self: Shape) *const HeightFieldData {
        return c.b3Shape_GetHeightField(self.id);
    }

    pub fn setSphere(self: Shape, sphere: Sphere) void {
        c.b3Shape_SetSphere(self.id, &sphere);
    }

    pub fn setCapsule(self: Shape, capsule: Capsule) void {
        c.b3Shape_SetCapsule(self.id, &capsule);
    }

    pub fn setHull(self: Shape, hull: *const HullData) void {
        c.b3Shape_SetHull(self.id, hull);
    }

    pub fn setMesh(self: Shape, mesh: *const MeshData, scale: Vec3) void {
        c.b3Shape_SetMesh(self.id, mesh, scale);
    }

    // Contact and sensor data

    pub fn getContactCapacity(self: Shape) i32 {
        return c.b3Shape_GetContactCapacity(self.id);
    }

    pub fn getContactData(self: Shape, buffer: []ContactData) []ContactData {
        const n = c.b3Shape_GetContactData(self.id, buffer.ptr, @intCast(buffer.len));
        return buffer[0..@intCast(n)];
    }

    pub fn getSensorCapacity(self: Shape) i32 {
        return c.b3Shape_GetSensorCapacity(self.id);
    }

    /// Fills `buffer` with the shapes overlapping this sensor and returns the filled slice.
    pub fn getSensorData(self: Shape, buffer: []Shape) []Shape {
        const n = c.b3Shape_GetSensorData(self.id, @ptrCast(buffer.ptr), @intCast(buffer.len));
        return buffer[0..@intCast(n)];
    }

    pub fn getAABB(self: Shape) AABB {
        return c.b3Shape_GetAABB(self.id);
    }

    pub fn computeMassData(self: Shape) MassData {
        return c.b3Shape_ComputeMassData(self.id);
    }

    pub fn getClosestPoint(self: Shape, target: Vec3) Vec3 {
        return c.b3Shape_GetClosestPoint(self.id, target);
    }

    pub fn applyWind(self: Shape, wind: Vec3, drag: f32, lift: f32, max_speed: f32, wake: bool) void {
        c.b3Shape_ApplyWind(self.id, wind, drag, lift, max_speed, wake);
    }
};

// ---------------------------------------------------------------------------
// Contact
// ---------------------------------------------------------------------------

pub const Contact = extern struct {
    id: c.b3ContactId,

    pub fn isValid(self: Contact) bool {
        return c.b3Contact_IsValid(self.id);
    }

    pub fn getData(self: Contact) ContactData {
        return c.b3Contact_GetData(self.id);
    }
};

// ---------------------------------------------------------------------------
// Joints
// ---------------------------------------------------------------------------

/// Generic joint handle. Typed wrappers (`RevoluteJoint`, ...) embed this as `.joint`.
pub const Joint = extern struct {
    id: c.b3JointId,

    pub const null_joint = Joint{ .id = .{ .index1 = 0, .world0 = 0, .generation = 0 } };

    pub fn destroy(self: Joint, wake_attached: bool) void {
        c.b3DestroyJoint(self.id, wake_attached);
    }

    pub fn isValid(self: Joint) bool {
        return c.b3Joint_IsValid(self.id);
    }

    pub fn isNull(self: Joint) bool {
        return self.id.index1 == 0;
    }

    pub fn eql(self: Joint, other: Joint) bool {
        return self.id.index1 == other.id.index1 and
            self.id.world0 == other.id.world0 and
            self.id.generation == other.id.generation;
    }

    pub fn getType(self: Joint) JointType {
        return @enumFromInt(c.b3Joint_GetType(self.id));
    }

    pub fn getBodyA(self: Joint) Body {
        return .{ .id = c.b3Joint_GetBodyA(self.id) };
    }

    pub fn getBodyB(self: Joint) Body {
        return .{ .id = c.b3Joint_GetBodyB(self.id) };
    }

    pub fn getWorld(self: Joint) World {
        return .{ .id = c.b3Joint_GetWorld(self.id) };
    }

    pub fn setLocalFrameA(self: Joint, local_frame: Transform) void {
        c.b3Joint_SetLocalFrameA(self.id, local_frame);
    }

    pub fn getLocalFrameA(self: Joint) Transform {
        return c.b3Joint_GetLocalFrameA(self.id);
    }

    pub fn setLocalFrameB(self: Joint, local_frame: Transform) void {
        c.b3Joint_SetLocalFrameB(self.id, local_frame);
    }

    pub fn getLocalFrameB(self: Joint) Transform {
        return c.b3Joint_GetLocalFrameB(self.id);
    }

    pub fn setCollideConnected(self: Joint, should_collide: bool) void {
        c.b3Joint_SetCollideConnected(self.id, should_collide);
    }

    pub fn getCollideConnected(self: Joint) bool {
        return c.b3Joint_GetCollideConnected(self.id);
    }

    pub fn setUserData(self: Joint, user_data: ?*anyopaque) void {
        c.b3Joint_SetUserData(self.id, user_data);
    }

    pub fn getUserData(self: Joint) ?*anyopaque {
        return c.b3Joint_GetUserData(self.id);
    }

    pub fn wakeBodies(self: Joint) void {
        c.b3Joint_WakeBodies(self.id);
    }

    pub fn getConstraintForce(self: Joint) Vec3 {
        return c.b3Joint_GetConstraintForce(self.id);
    }

    pub fn getConstraintTorque(self: Joint) Vec3 {
        return c.b3Joint_GetConstraintTorque(self.id);
    }

    pub fn getLinearSeparation(self: Joint) f32 {
        return c.b3Joint_GetLinearSeparation(self.id);
    }

    pub fn getAngularSeparation(self: Joint) f32 {
        return c.b3Joint_GetAngularSeparation(self.id);
    }

    pub const ConstraintTuning = struct { hertz: f32, damping_ratio: f32 };

    pub fn setConstraintTuning(self: Joint, hertz: f32, damping_ratio: f32) void {
        c.b3Joint_SetConstraintTuning(self.id, hertz, damping_ratio);
    }

    pub fn getConstraintTuning(self: Joint) ConstraintTuning {
        var hertz: f32 = 0;
        var damping_ratio: f32 = 0;
        c.b3Joint_GetConstraintTuning(self.id, &hertz, &damping_ratio);
        return .{ .hertz = hertz, .damping_ratio = damping_ratio };
    }

    pub fn setForceThreshold(self: Joint, threshold: f32) void {
        c.b3Joint_SetForceThreshold(self.id, threshold);
    }

    pub fn getForceThreshold(self: Joint) f32 {
        return c.b3Joint_GetForceThreshold(self.id);
    }

    pub fn setTorqueThreshold(self: Joint, threshold: f32) void {
        c.b3Joint_SetTorqueThreshold(self.id, threshold);
    }

    pub fn getTorqueThreshold(self: Joint) f32 {
        return c.b3Joint_GetTorqueThreshold(self.id);
    }
};

pub fn defaultDistanceJointDef() DistanceJointDef {
    return c.b3DefaultDistanceJointDef();
}

pub const DistanceJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: DistanceJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn setLength(self: DistanceJoint, length: f32) void {
        c.b3DistanceJoint_SetLength(self.joint.id, length);
    }

    pub fn getLength(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetLength(self.joint.id);
    }

    pub fn enableSpring(self: DistanceJoint, flag: bool) void {
        c.b3DistanceJoint_EnableSpring(self.joint.id, flag);
    }

    pub fn isSpringEnabled(self: DistanceJoint) bool {
        return c.b3DistanceJoint_IsSpringEnabled(self.joint.id);
    }

    pub fn setSpringForceRange(self: DistanceJoint, lower_force: f32, upper_force: f32) void {
        c.b3DistanceJoint_SetSpringForceRange(self.joint.id, lower_force, upper_force);
    }

    pub const ForceRange = struct { lower: f32, upper: f32 };

    pub fn getSpringForceRange(self: DistanceJoint) ForceRange {
        var lower: f32 = 0;
        var upper: f32 = 0;
        c.b3DistanceJoint_GetSpringForceRange(self.joint.id, &lower, &upper);
        return .{ .lower = lower, .upper = upper };
    }

    pub fn setSpringHertz(self: DistanceJoint, hertz: f32) void {
        c.b3DistanceJoint_SetSpringHertz(self.joint.id, hertz);
    }

    pub fn getSpringHertz(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetSpringHertz(self.joint.id);
    }

    pub fn setSpringDampingRatio(self: DistanceJoint, damping_ratio: f32) void {
        c.b3DistanceJoint_SetSpringDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSpringDampingRatio(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetSpringDampingRatio(self.joint.id);
    }

    pub fn enableLimit(self: DistanceJoint, flag: bool) void {
        c.b3DistanceJoint_EnableLimit(self.joint.id, flag);
    }

    pub fn isLimitEnabled(self: DistanceJoint) bool {
        return c.b3DistanceJoint_IsLimitEnabled(self.joint.id);
    }

    pub fn setLengthRange(self: DistanceJoint, min_length: f32, max_length: f32) void {
        c.b3DistanceJoint_SetLengthRange(self.joint.id, min_length, max_length);
    }

    pub fn getMinLength(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetMinLength(self.joint.id);
    }

    pub fn getMaxLength(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetMaxLength(self.joint.id);
    }

    pub fn getCurrentLength(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetCurrentLength(self.joint.id);
    }

    pub fn enableMotor(self: DistanceJoint, flag: bool) void {
        c.b3DistanceJoint_EnableMotor(self.joint.id, flag);
    }

    pub fn isMotorEnabled(self: DistanceJoint) bool {
        return c.b3DistanceJoint_IsMotorEnabled(self.joint.id);
    }

    pub fn setMotorSpeed(self: DistanceJoint, speed: f32) void {
        c.b3DistanceJoint_SetMotorSpeed(self.joint.id, speed);
    }

    pub fn getMotorSpeed(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetMotorSpeed(self.joint.id);
    }

    pub fn setMaxMotorForce(self: DistanceJoint, force: f32) void {
        c.b3DistanceJoint_SetMaxMotorForce(self.joint.id, force);
    }

    pub fn getMaxMotorForce(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetMaxMotorForce(self.joint.id);
    }

    pub fn getMotorForce(self: DistanceJoint) f32 {
        return c.b3DistanceJoint_GetMotorForce(self.joint.id);
    }
};

pub fn defaultMotorJointDef() MotorJointDef {
    return c.b3DefaultMotorJointDef();
}

pub const MotorJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: MotorJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn setLinearVelocity(self: MotorJoint, velocity: Vec3) void {
        c.b3MotorJoint_SetLinearVelocity(self.joint.id, velocity);
    }

    pub fn getLinearVelocity(self: MotorJoint) Vec3 {
        return c.b3MotorJoint_GetLinearVelocity(self.joint.id);
    }

    pub fn setAngularVelocity(self: MotorJoint, velocity: Vec3) void {
        c.b3MotorJoint_SetAngularVelocity(self.joint.id, velocity);
    }

    pub fn getAngularVelocity(self: MotorJoint) Vec3 {
        return c.b3MotorJoint_GetAngularVelocity(self.joint.id);
    }

    pub fn setMaxVelocityForce(self: MotorJoint, max_force: f32) void {
        c.b3MotorJoint_SetMaxVelocityForce(self.joint.id, max_force);
    }

    pub fn getMaxVelocityForce(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetMaxVelocityForce(self.joint.id);
    }

    pub fn setMaxVelocityTorque(self: MotorJoint, max_torque: f32) void {
        c.b3MotorJoint_SetMaxVelocityTorque(self.joint.id, max_torque);
    }

    pub fn getMaxVelocityTorque(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetMaxVelocityTorque(self.joint.id);
    }

    pub fn setLinearHertz(self: MotorJoint, hertz: f32) void {
        c.b3MotorJoint_SetLinearHertz(self.joint.id, hertz);
    }

    pub fn getLinearHertz(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetLinearHertz(self.joint.id);
    }

    pub fn setLinearDampingRatio(self: MotorJoint, damping: f32) void {
        c.b3MotorJoint_SetLinearDampingRatio(self.joint.id, damping);
    }

    pub fn getLinearDampingRatio(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetLinearDampingRatio(self.joint.id);
    }

    pub fn setAngularHertz(self: MotorJoint, hertz: f32) void {
        c.b3MotorJoint_SetAngularHertz(self.joint.id, hertz);
    }

    pub fn getAngularHertz(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetAngularHertz(self.joint.id);
    }

    pub fn setAngularDampingRatio(self: MotorJoint, damping: f32) void {
        c.b3MotorJoint_SetAngularDampingRatio(self.joint.id, damping);
    }

    pub fn getAngularDampingRatio(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetAngularDampingRatio(self.joint.id);
    }

    pub fn setMaxSpringForce(self: MotorJoint, max_force: f32) void {
        c.b3MotorJoint_SetMaxSpringForce(self.joint.id, max_force);
    }

    pub fn getMaxSpringForce(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetMaxSpringForce(self.joint.id);
    }

    pub fn setMaxSpringTorque(self: MotorJoint, max_torque: f32) void {
        c.b3MotorJoint_SetMaxSpringTorque(self.joint.id, max_torque);
    }

    pub fn getMaxSpringTorque(self: MotorJoint) f32 {
        return c.b3MotorJoint_GetMaxSpringTorque(self.joint.id);
    }
};

pub fn defaultFilterJointDef() FilterJointDef {
    return c.b3DefaultFilterJointDef();
}

pub fn defaultParallelJointDef() ParallelJointDef {
    return c.b3DefaultParallelJointDef();
}

pub const ParallelJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: ParallelJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn setSpringHertz(self: ParallelJoint, hertz: f32) void {
        c.b3ParallelJoint_SetSpringHertz(self.joint.id, hertz);
    }

    pub fn getSpringHertz(self: ParallelJoint) f32 {
        return c.b3ParallelJoint_GetSpringHertz(self.joint.id);
    }

    pub fn setSpringDampingRatio(self: ParallelJoint, damping_ratio: f32) void {
        c.b3ParallelJoint_SetSpringDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSpringDampingRatio(self: ParallelJoint) f32 {
        return c.b3ParallelJoint_GetSpringDampingRatio(self.joint.id);
    }

    pub fn setMaxTorque(self: ParallelJoint, torque: f32) void {
        c.b3ParallelJoint_SetMaxTorque(self.joint.id, torque);
    }

    pub fn getMaxTorque(self: ParallelJoint) f32 {
        return c.b3ParallelJoint_GetMaxTorque(self.joint.id);
    }
};

pub fn defaultPrismaticJointDef() PrismaticJointDef {
    return c.b3DefaultPrismaticJointDef();
}

pub const PrismaticJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: PrismaticJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn enableSpring(self: PrismaticJoint, flag: bool) void {
        c.b3PrismaticJoint_EnableSpring(self.joint.id, flag);
    }

    pub fn isSpringEnabled(self: PrismaticJoint) bool {
        return c.b3PrismaticJoint_IsSpringEnabled(self.joint.id);
    }

    pub fn setSpringHertz(self: PrismaticJoint, hertz: f32) void {
        c.b3PrismaticJoint_SetSpringHertz(self.joint.id, hertz);
    }

    pub fn getSpringHertz(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetSpringHertz(self.joint.id);
    }

    pub fn setSpringDampingRatio(self: PrismaticJoint, damping_ratio: f32) void {
        c.b3PrismaticJoint_SetSpringDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSpringDampingRatio(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetSpringDampingRatio(self.joint.id);
    }

    pub fn setTargetTranslation(self: PrismaticJoint, translation: f32) void {
        c.b3PrismaticJoint_SetTargetTranslation(self.joint.id, translation);
    }

    pub fn getTargetTranslation(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetTargetTranslation(self.joint.id);
    }

    pub fn enableLimit(self: PrismaticJoint, flag: bool) void {
        c.b3PrismaticJoint_EnableLimit(self.joint.id, flag);
    }

    pub fn isLimitEnabled(self: PrismaticJoint) bool {
        return c.b3PrismaticJoint_IsLimitEnabled(self.joint.id);
    }

    pub fn getLowerLimit(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetLowerLimit(self.joint.id);
    }

    pub fn getUpperLimit(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetUpperLimit(self.joint.id);
    }

    pub fn setLimits(self: PrismaticJoint, lower: f32, upper: f32) void {
        c.b3PrismaticJoint_SetLimits(self.joint.id, lower, upper);
    }

    pub fn enableMotor(self: PrismaticJoint, flag: bool) void {
        c.b3PrismaticJoint_EnableMotor(self.joint.id, flag);
    }

    pub fn isMotorEnabled(self: PrismaticJoint) bool {
        return c.b3PrismaticJoint_IsMotorEnabled(self.joint.id);
    }

    pub fn setMotorSpeed(self: PrismaticJoint, speed: f32) void {
        c.b3PrismaticJoint_SetMotorSpeed(self.joint.id, speed);
    }

    pub fn getMotorSpeed(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetMotorSpeed(self.joint.id);
    }

    pub fn setMaxMotorForce(self: PrismaticJoint, force: f32) void {
        c.b3PrismaticJoint_SetMaxMotorForce(self.joint.id, force);
    }

    pub fn getMaxMotorForce(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetMaxMotorForce(self.joint.id);
    }

    pub fn getMotorForce(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetMotorForce(self.joint.id);
    }

    pub fn getTranslation(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetTranslation(self.joint.id);
    }

    pub fn getSpeed(self: PrismaticJoint) f32 {
        return c.b3PrismaticJoint_GetSpeed(self.joint.id);
    }
};

pub fn defaultRevoluteJointDef() RevoluteJointDef {
    return c.b3DefaultRevoluteJointDef();
}

pub const RevoluteJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: RevoluteJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn enableSpring(self: RevoluteJoint, flag: bool) void {
        c.b3RevoluteJoint_EnableSpring(self.joint.id, flag);
    }

    pub fn isSpringEnabled(self: RevoluteJoint) bool {
        return c.b3RevoluteJoint_IsSpringEnabled(self.joint.id);
    }

    pub fn setSpringHertz(self: RevoluteJoint, hertz: f32) void {
        c.b3RevoluteJoint_SetSpringHertz(self.joint.id, hertz);
    }

    pub fn getSpringHertz(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetSpringHertz(self.joint.id);
    }

    pub fn setSpringDampingRatio(self: RevoluteJoint, damping_ratio: f32) void {
        c.b3RevoluteJoint_SetSpringDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSpringDampingRatio(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetSpringDampingRatio(self.joint.id);
    }

    pub fn setTargetAngle(self: RevoluteJoint, radians: f32) void {
        c.b3RevoluteJoint_SetTargetAngle(self.joint.id, radians);
    }

    pub fn getTargetAngle(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetTargetAngle(self.joint.id);
    }

    pub fn getAngle(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetAngle(self.joint.id);
    }

    pub fn enableLimit(self: RevoluteJoint, flag: bool) void {
        c.b3RevoluteJoint_EnableLimit(self.joint.id, flag);
    }

    pub fn isLimitEnabled(self: RevoluteJoint) bool {
        return c.b3RevoluteJoint_IsLimitEnabled(self.joint.id);
    }

    pub fn getLowerLimit(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetLowerLimit(self.joint.id);
    }

    pub fn getUpperLimit(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetUpperLimit(self.joint.id);
    }

    pub fn setLimits(self: RevoluteJoint, lower_radians: f32, upper_radians: f32) void {
        c.b3RevoluteJoint_SetLimits(self.joint.id, lower_radians, upper_radians);
    }

    pub fn enableMotor(self: RevoluteJoint, flag: bool) void {
        c.b3RevoluteJoint_EnableMotor(self.joint.id, flag);
    }

    pub fn isMotorEnabled(self: RevoluteJoint) bool {
        return c.b3RevoluteJoint_IsMotorEnabled(self.joint.id);
    }

    pub fn setMotorSpeed(self: RevoluteJoint, speed: f32) void {
        c.b3RevoluteJoint_SetMotorSpeed(self.joint.id, speed);
    }

    pub fn getMotorSpeed(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetMotorSpeed(self.joint.id);
    }

    pub fn getMotorTorque(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetMotorTorque(self.joint.id);
    }

    pub fn setMaxMotorTorque(self: RevoluteJoint, torque: f32) void {
        c.b3RevoluteJoint_SetMaxMotorTorque(self.joint.id, torque);
    }

    pub fn getMaxMotorTorque(self: RevoluteJoint) f32 {
        return c.b3RevoluteJoint_GetMaxMotorTorque(self.joint.id);
    }
};

pub fn defaultSphericalJointDef() SphericalJointDef {
    return c.b3DefaultSphericalJointDef();
}

pub const SphericalJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: SphericalJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn enableConeLimit(self: SphericalJoint, flag: bool) void {
        c.b3SphericalJoint_EnableConeLimit(self.joint.id, flag);
    }

    pub fn isConeLimitEnabled(self: SphericalJoint) bool {
        return c.b3SphericalJoint_IsConeLimitEnabled(self.joint.id);
    }

    pub fn getConeLimit(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetConeLimit(self.joint.id);
    }

    pub fn setConeLimit(self: SphericalJoint, radians: f32) void {
        c.b3SphericalJoint_SetConeLimit(self.joint.id, radians);
    }

    pub fn getConeAngle(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetConeAngle(self.joint.id);
    }

    pub fn enableTwistLimit(self: SphericalJoint, flag: bool) void {
        c.b3SphericalJoint_EnableTwistLimit(self.joint.id, flag);
    }

    pub fn isTwistLimitEnabled(self: SphericalJoint) bool {
        return c.b3SphericalJoint_IsTwistLimitEnabled(self.joint.id);
    }

    pub fn getLowerTwistLimit(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetLowerTwistLimit(self.joint.id);
    }

    pub fn getUpperTwistLimit(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetUpperTwistLimit(self.joint.id);
    }

    pub fn setTwistLimits(self: SphericalJoint, lower_radians: f32, upper_radians: f32) void {
        c.b3SphericalJoint_SetTwistLimits(self.joint.id, lower_radians, upper_radians);
    }

    pub fn getTwistAngle(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetTwistAngle(self.joint.id);
    }

    pub fn enableSpring(self: SphericalJoint, flag: bool) void {
        c.b3SphericalJoint_EnableSpring(self.joint.id, flag);
    }

    pub fn isSpringEnabled(self: SphericalJoint) bool {
        return c.b3SphericalJoint_IsSpringEnabled(self.joint.id);
    }

    pub fn setSpringHertz(self: SphericalJoint, hertz: f32) void {
        c.b3SphericalJoint_SetSpringHertz(self.joint.id, hertz);
    }

    pub fn getSpringHertz(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetSpringHertz(self.joint.id);
    }

    pub fn setSpringDampingRatio(self: SphericalJoint, damping_ratio: f32) void {
        c.b3SphericalJoint_SetSpringDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSpringDampingRatio(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetSpringDampingRatio(self.joint.id);
    }

    pub fn setTargetRotation(self: SphericalJoint, target: Quat) void {
        c.b3SphericalJoint_SetTargetRotation(self.joint.id, target);
    }

    pub fn getTargetRotation(self: SphericalJoint) Quat {
        return c.b3SphericalJoint_GetTargetRotation(self.joint.id);
    }

    pub fn enableMotor(self: SphericalJoint, flag: bool) void {
        c.b3SphericalJoint_EnableMotor(self.joint.id, flag);
    }

    pub fn isMotorEnabled(self: SphericalJoint) bool {
        return c.b3SphericalJoint_IsMotorEnabled(self.joint.id);
    }

    pub fn setMotorVelocity(self: SphericalJoint, velocity: Vec3) void {
        c.b3SphericalJoint_SetMotorVelocity(self.joint.id, velocity);
    }

    pub fn getMotorVelocity(self: SphericalJoint) Vec3 {
        return c.b3SphericalJoint_GetMotorVelocity(self.joint.id);
    }

    pub fn getMotorTorque(self: SphericalJoint) Vec3 {
        return c.b3SphericalJoint_GetMotorTorque(self.joint.id);
    }

    pub fn setMaxMotorTorque(self: SphericalJoint, torque: f32) void {
        c.b3SphericalJoint_SetMaxMotorTorque(self.joint.id, torque);
    }

    pub fn getMaxMotorTorque(self: SphericalJoint) f32 {
        return c.b3SphericalJoint_GetMaxMotorTorque(self.joint.id);
    }
};

pub fn defaultWeldJointDef() WeldJointDef {
    return c.b3DefaultWeldJointDef();
}

pub const WeldJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: WeldJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn setLinearHertz(self: WeldJoint, hertz: f32) void {
        c.b3WeldJoint_SetLinearHertz(self.joint.id, hertz);
    }

    pub fn getLinearHertz(self: WeldJoint) f32 {
        return c.b3WeldJoint_GetLinearHertz(self.joint.id);
    }

    pub fn setLinearDampingRatio(self: WeldJoint, damping_ratio: f32) void {
        c.b3WeldJoint_SetLinearDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getLinearDampingRatio(self: WeldJoint) f32 {
        return c.b3WeldJoint_GetLinearDampingRatio(self.joint.id);
    }

    pub fn setAngularHertz(self: WeldJoint, hertz: f32) void {
        c.b3WeldJoint_SetAngularHertz(self.joint.id, hertz);
    }

    pub fn getAngularHertz(self: WeldJoint) f32 {
        return c.b3WeldJoint_GetAngularHertz(self.joint.id);
    }

    pub fn setAngularDampingRatio(self: WeldJoint, damping_ratio: f32) void {
        c.b3WeldJoint_SetAngularDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getAngularDampingRatio(self: WeldJoint) f32 {
        return c.b3WeldJoint_GetAngularDampingRatio(self.joint.id);
    }
};

pub fn defaultWheelJointDef() WheelJointDef {
    return c.b3DefaultWheelJointDef();
}

pub const WheelJoint = extern struct {
    joint: Joint,

    pub fn destroy(self: WheelJoint, wake_attached: bool) void {
        self.joint.destroy(wake_attached);
    }

    pub fn enableSuspension(self: WheelJoint, flag: bool) void {
        c.b3WheelJoint_EnableSuspension(self.joint.id, flag);
    }

    pub fn isSuspensionEnabled(self: WheelJoint) bool {
        return c.b3WheelJoint_IsSuspensionEnabled(self.joint.id);
    }

    pub fn setSuspensionHertz(self: WheelJoint, hertz: f32) void {
        c.b3WheelJoint_SetSuspensionHertz(self.joint.id, hertz);
    }

    pub fn getSuspensionHertz(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSuspensionHertz(self.joint.id);
    }

    pub fn setSuspensionDampingRatio(self: WheelJoint, damping_ratio: f32) void {
        c.b3WheelJoint_SetSuspensionDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSuspensionDampingRatio(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSuspensionDampingRatio(self.joint.id);
    }

    pub fn enableSuspensionLimit(self: WheelJoint, flag: bool) void {
        c.b3WheelJoint_EnableSuspensionLimit(self.joint.id, flag);
    }

    pub fn isSuspensionLimitEnabled(self: WheelJoint) bool {
        return c.b3WheelJoint_IsSuspensionLimitEnabled(self.joint.id);
    }

    pub fn getLowerSuspensionLimit(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetLowerSuspensionLimit(self.joint.id);
    }

    pub fn getUpperSuspensionLimit(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetUpperSuspensionLimit(self.joint.id);
    }

    pub fn setSuspensionLimits(self: WheelJoint, lower: f32, upper: f32) void {
        c.b3WheelJoint_SetSuspensionLimits(self.joint.id, lower, upper);
    }

    pub fn enableSpinMotor(self: WheelJoint, flag: bool) void {
        c.b3WheelJoint_EnableSpinMotor(self.joint.id, flag);
    }

    pub fn isSpinMotorEnabled(self: WheelJoint) bool {
        return c.b3WheelJoint_IsSpinMotorEnabled(self.joint.id);
    }

    pub fn setSpinMotorSpeed(self: WheelJoint, speed: f32) void {
        c.b3WheelJoint_SetSpinMotorSpeed(self.joint.id, speed);
    }

    pub fn getSpinMotorSpeed(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSpinMotorSpeed(self.joint.id);
    }

    pub fn setMaxSpinTorque(self: WheelJoint, torque: f32) void {
        c.b3WheelJoint_SetMaxSpinTorque(self.joint.id, torque);
    }

    pub fn getMaxSpinTorque(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetMaxSpinTorque(self.joint.id);
    }

    pub fn getSpinSpeed(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSpinSpeed(self.joint.id);
    }

    pub fn getSpinTorque(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSpinTorque(self.joint.id);
    }

    pub fn enableSteering(self: WheelJoint, flag: bool) void {
        c.b3WheelJoint_EnableSteering(self.joint.id, flag);
    }

    pub fn isSteeringEnabled(self: WheelJoint) bool {
        return c.b3WheelJoint_IsSteeringEnabled(self.joint.id);
    }

    pub fn setSteeringHertz(self: WheelJoint, hertz: f32) void {
        c.b3WheelJoint_SetSteeringHertz(self.joint.id, hertz);
    }

    pub fn getSteeringHertz(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSteeringHertz(self.joint.id);
    }

    pub fn setSteeringDampingRatio(self: WheelJoint, damping_ratio: f32) void {
        c.b3WheelJoint_SetSteeringDampingRatio(self.joint.id, damping_ratio);
    }

    pub fn getSteeringDampingRatio(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSteeringDampingRatio(self.joint.id);
    }

    pub fn setMaxSteeringTorque(self: WheelJoint, torque: f32) void {
        c.b3WheelJoint_SetMaxSteeringTorque(self.joint.id, torque);
    }

    pub fn getMaxSteeringTorque(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetMaxSteeringTorque(self.joint.id);
    }

    pub fn enableSteeringLimit(self: WheelJoint, flag: bool) void {
        c.b3WheelJoint_EnableSteeringLimit(self.joint.id, flag);
    }

    pub fn isSteeringLimitEnabled(self: WheelJoint) bool {
        return c.b3WheelJoint_IsSteeringLimitEnabled(self.joint.id);
    }

    pub fn getLowerSteeringLimit(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetLowerSteeringLimit(self.joint.id);
    }

    pub fn getUpperSteeringLimit(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetUpperSteeringLimit(self.joint.id);
    }

    pub fn setSteeringLimits(self: WheelJoint, lower_radians: f32, upper_radians: f32) void {
        c.b3WheelJoint_SetSteeringLimits(self.joint.id, lower_radians, upper_radians);
    }

    pub fn setTargetSteeringAngle(self: WheelJoint, radians: f32) void {
        c.b3WheelJoint_SetTargetSteeringAngle(self.joint.id, radians);
    }

    pub fn getTargetSteeringAngle(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetTargetSteeringAngle(self.joint.id);
    }

    pub fn getSteeringAngle(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSteeringAngle(self.joint.id);
    }

    pub fn getSteeringTorque(self: WheelJoint) f32 {
        return c.b3WheelJoint_GetSteeringTorque(self.joint.id);
    }
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

// Forces semantic analysis of every wrapper method, so a signature drift
// against the C API is caught by `zig build test` even for methods no test
// calls directly.
test "all wrapper declarations compile" {
    std.testing.refAllDecls(World);
    std.testing.refAllDecls(Body);
    std.testing.refAllDecls(Shape);
    std.testing.refAllDecls(Contact);
    std.testing.refAllDecls(Joint);
    std.testing.refAllDecls(DistanceJoint);
    std.testing.refAllDecls(MotorJoint);
    std.testing.refAllDecls(ParallelJoint);
    std.testing.refAllDecls(PrismaticJoint);
    std.testing.refAllDecls(RevoluteJoint);
    std.testing.refAllDecls(SphericalJoint);
    std.testing.refAllDecls(WeldJoint);
    std.testing.refAllDecls(WheelJoint);
}

test "sphere falls onto ground box and comes to rest" {
    var world_def = defaultWorldDef();
    world_def.gravity = vec3(0, -10, 0);
    const world = try World.create(&world_def);
    defer world.destroy();

    var ground_def = defaultBodyDef();
    ground_def.position = pos(0, -1, 0);
    const ground = world.createBody(&ground_def);
    const ground_shape_def = defaultShapeDef();
    _ = ground.createBoxShape(&ground_shape_def, 50, 1, 50);

    var ball_def = dynamicBodyDef();
    ball_def.position = pos(0, 4, 0);
    const ball = world.createBody(&ball_def);
    try std.testing.expect(ball.isValid());
    try std.testing.expectEqual(BodyType.dynamic, ball.getType());

    const ball_shape_def = defaultShapeDef();
    const ball_shape = ball.createSphereShape(&ball_shape_def, .{ .center = vec3_zero, .radius = 0.5 });
    try std.testing.expect(ball_shape.isValid());
    try std.testing.expectEqual(ShapeType.sphere, ball_shape.getType());
    try std.testing.expect(ball.getMass() > 0);

    var i: usize = 0;
    while (i < 240) : (i += 1) {
        world.step(1.0 / 60.0, 4);
    }

    // Ground top is at y = 0, so a radius-0.5 sphere rests near y = 0.5.
    const p = ball.getPosition();
    try std.testing.expectApproxEqAbs(@as(f32, 0.5), @as(f32, @floatCast(p.y)), 0.05);

    const speed = ball.getLinearVelocity();
    try std.testing.expect(@abs(speed.y) < 0.1);
}

test "ray cast hits a body" {
    var world_def = defaultWorldDef();
    const world = try World.create(&world_def);
    defer world.destroy();

    var body_def = defaultBodyDef();
    body_def.position = pos(0, 0, 0);
    const body = world.createBody(&body_def);
    const shape_def = defaultShapeDef();
    const shape = body.createBoxShape(&shape_def, 1, 1, 1);

    const result = world.castRayClosest(pos(0, 10, 0), vec3(0, -20, 0), defaultQueryFilter());
    try std.testing.expect(result.hit);
    try std.testing.expectApproxEqAbs(@as(f32, 1.0), @as(f32, @floatCast(result.point.y)), 1e-3);
    const hit_shape = Shape{ .id = result.shapeId };
    try std.testing.expect(hit_shape.eql(shape));
}

test "revolute joint connects two bodies" {
    var world_def = defaultWorldDef();
    const world = try World.create(&world_def);
    defer world.destroy();

    var anchor_def = defaultBodyDef();
    anchor_def.position = pos(0, 5, 0);
    const anchor = world.createBody(&anchor_def);

    var arm_def = dynamicBodyDef();
    arm_def.position = pos(2, 5, 0);
    const arm = world.createBody(&arm_def);
    const shape_def = defaultShapeDef();
    _ = arm.createBoxShape(&shape_def, 1, 0.1, 0.1);

    var joint_def = defaultRevoluteJointDef();
    joint_def.base.bodyIdA = anchor.id;
    joint_def.base.bodyIdB = arm.id;
    joint_def.base.localFrameB = .{ .p = vec3(-2, 0, 0), .q = quat_identity };
    const joint = world.createRevoluteJoint(&joint_def);
    try std.testing.expect(joint.joint.isValid());
    try std.testing.expectEqual(JointType.revolute, joint.joint.getType());

    var i: usize = 0;
    while (i < 60) : (i += 1) {
        world.step(1.0 / 60.0, 4);
    }

    // The arm swings but its anchor end stays pinned at the anchor body.
    const anchor_world = arm.getWorldPoint(vec3(-2, 0, 0));
    try std.testing.expectApproxEqAbs(@as(f32, 0), @as(f32, @floatCast(anchor_world.x)), 0.05);
    try std.testing.expectApproxEqAbs(@as(f32, 5), @as(f32, @floatCast(anchor_world.y)), 0.05);

    joint.destroy(true);
}
