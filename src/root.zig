const c = @import("./c_api.zig");
pub const enums = @import("./enums.zig");

pub const Value = struct {
    value: f32,
    unit: enums.Unit,
};

pub const Config = struct {
    handle: c.YGConfigRef,

    fn free(self: Config) void {
        c.YGConfigFree(self);
    }
    fn isExperimentalFeatureEnabled(self: Config, feature: enums.ExperimentalFeature) bool {
        return c.YGConfigIsExperimentalFeatureEnabled(self.handle, feature);
    }
    fn setExperimentalFeatureEnabled(self: Config, feature: enums.ExperimentalFeature, enabled: bool) void {
        c.YGConfigSetExperimentalFeatureEnabled(self.handle, feature, enabled);
    }
    fn setPointScaleFactor(self: Config, factor: f32) void {
        c.YGConfigSetPointScaleFactor(self.handle, factor);
    }
    fn getErrata(self: Config) enums.Errata {
        return c.YGConfigGetErrata(self.handle);
    }
    fn setErrata(self: Config, errata: enums.Errata) void {
        c.YGConfigSetErrata(self.handle, errata);
    }
    fn getUseWebDefaults(self: Config) bool {
        return c.YGConfigGetUseWebDefaults(self);
    }
    fn setUseWebDefaults(self: Config, useWebDefaults: bool) void {
        c.YGConfigSetUseWebDefaults(self.handle, useWebDefaults);
    }
};

pub const Node = struct {
    handle: c.YGNodeRef,

    pub fn initDefault() Node {
        return .{
            .handle = c.YGNodeNew(),
        };
    }

    pub fn initWithConfig(config: Config) Node {
        return .{
            .handle = c.YGNodeNewWithConfig(config.handle),
        };
    }

    pub fn free(self: Node) void {
        c.YGNodeFree(self.handle);
    }
    pub fn freeRecursive(self: Node) void {
        c.YGNodeFreeRecursive(self.handle);
    }

    pub fn calculateLayout(self: Node, availableWidth: ?f32, availableHeight: ?f32, ownerDirection: ?enums.Direction) void {
        const ygDir = @as(c_uint, @intFromEnum(ownerDirection orelse enums.Direction.Inherit));
        c.YGNodeCalculateLayout(self.handle, availableWidth orelse 0.0, availableHeight orelse 0.0, ygDir);
    }

    pub fn getChildCount(self: Node) usize {
        return c.YGNodeGetChildCount(self.handle);
    }
    pub fn getChildAt(self: Node, index: usize) Node {
        const ygNode = c.YGNodeGetChild(self.handle, index);
        return .{ .handle = ygNode };
    }

    pub fn getFlexDirection(self: Node) enums.FlexDirection {
        const ygValue = c.YGNodeStyleGetFlexDirection(self.handle);
        return @enumFromInt(@as(i32, ygValue));
    }
    pub fn setFlexDirection(self: Node, dir: enums.FlexDirection) void {
        c.YGNodeStyleSetFlexDirection(self.handle, @intFromEnum(dir));
    }

    pub fn getWidth(self: Node) Value {
        const ygValue = c.YGNodeStyleGetWidth(self.handle);
        return .{
            .value = ygValue.value,
            .unit = @enumFromInt(@as(i32, ygValue.unit)),
        };
    }
    pub fn setWidth(self: Node, size: f32) void {
        c.YGNodeStyleSetWidth(self.handle, size);
    }

    pub fn getHeight(self: Node) Value {
        const ygValue = c.YGNodeStyleGetHeight(self.handle);
        return .{
            .value = ygValue.value,
            .unit = @enumFromInt(@as(i32, ygValue.unit)),
        };
    }
    pub fn setHeight(self: Node, size: f32) void {
        c.YGNodeStyleSetHeight(self.handle, size);
    }

    pub fn setFlexGrow(self: Node, amount: f32) void {
        c.YGNodeStyleSetFlexGrow(self.handle, amount);
    }

    pub fn setMargin(self: Node, edge: enums.Edge, size: f32) void {
        const ygEdge = @as(c_uint, @intFromEnum(edge));
        c.YGNodeStyleSetMargin(self.handle, ygEdge, size);
    }

    pub fn insertChild(self: Node, child: Node, index: usize) void {
        c.YGNodeInsertChild(self.handle, child.handle, index);
    }

    pub fn getComputedWidth(self: Node) f32 {
        return c.YGNodeLayoutGetWidth(self.handle);
    }
    pub fn getComputedHeight(self: Node) f32 {
        return c.YGNodeLayoutGetWidth(self.handle);
    }
    pub fn getComputedLeft(self: Node) f32 {
        return c.YGNodeLayoutGetLeft(self.handle);
    }
    pub fn getComputedTop(self: Node) f32 {
        return c.YGNodeLayoutGetTop(self.handle);
    }
    pub fn getComputedRight(self: Node) f32 {
        return c.YGNodeLayoutGetRight(self.handle);
    }
    pub fn getComputedBottom(self: Node) f32 {
        return c.YGNodeLayoutGetBottom(self.handle);
    }
};

test "basic test" {
    const root = Node.initDefault();
    defer root.free();
    root.setFlexDirection(enums.FlexDirection.Row);
    root.setWidth(100);
    root.setHeight(100);

    const child0 = Node.initDefault();
    defer child0.free();
    child0.setFlexGrow(1);
    child0.setMargin(enums.Edge.Right, 10);
    root.insertChild(child0, 0);

    const child1 = Node.initDefault();
    defer child1.free();
    child1.setFlexGrow(1);
    root.insertChild(child1, 1);

    root.calculateLayout(undefined, undefined, enums.Direction.LTR);
}
