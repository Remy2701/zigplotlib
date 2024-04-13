const std = @import("std");
const Allocator = std.mem.Allocator;

const Kind = @import("kind.zig").Kind;

const length = @import("util/length.zig");
const LengthPercent = length.LengthPercent;

const rgb = @import("util/rgb.zig");
const RGB = rgb.RGB;

const Polyline = @This();

/// The options of a Polyline
pub const Options = struct {
    /// The points of the polyline
    points: ?[]const f32 = null,
    /// The allocator for the points (null means not-allocated)
    allocator: ?Allocator = null,
    /// The color of the fill
    fill: ?RGB = null,
    /// The opacity of the fill
    fill_opacity: f32 = 1.0,
    /// The color of the stroke
    stroke: ?RGB = null,
    /// The opacity of the stroke
    stroke_opacity: f32 = 1.0,
    /// The width of the stroke
    stroke_width: LengthPercent = .{ .pixel = 1.0 },
    /// The opacity of the Polyline (fill + stroke)
    opacity: f32 = 1.0,
};

/// The options of the polyline
options: Options,

/// Intialize the polyline with the given option
pub fn init(options: Options) Polyline {
    return Polyline{
        .options = options,
    };
}

/// Deinitialize the polyline.
pub fn deinit(self: *const Polyline) void {
    if (self.options.allocator) |allocator| {
        if (self.options.points) |points| {
            allocator.free(points);
        }
    }
}

/// Write the Polyline to the given writer.
pub fn writeTo(self: *const Polyline, writer: anytype) anyerror!void {
    try writer.writeAll("<polyline ");
    if (self.options.points) |points| {
        try writer.writeAll("points=\"");
        for (points) |point| {
            try writer.print("{d} ", .{point});
        }
        try writer.writeAll("\" ");
    } else try writer.writeAll("points=\"\" ");
    if (self.options.fill) |fill| try writer.print("fill=\"#{X:0>6}\" ", .{fill}) else try writer.writeAll("fill=\"none\" ");
    try writer.print("fill-opacity=\"{d}\" ", .{self.options.fill_opacity});
    if (self.options.stroke) |stroke| try writer.print("stroke=\"#{X:0>6}\" ", .{stroke}) else try writer.writeAll("stroke=\"none\" ");
    try writer.print("stroke-opacity=\"{d}\" ", .{self.options.stroke_opacity});
    try writer.print("stroke-width=\"{}\" ", .{self.options.stroke_width});
    try writer.print("opacity=\"{d}\" ", .{self.options.opacity});
    try writer.writeAll("/>");
}

/// Wrap the Polyline in a Kind
pub fn wrap(self: *const Polyline) Kind {
    return Kind{ .polyline = self.* };
}
