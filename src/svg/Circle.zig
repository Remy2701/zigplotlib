const std = @import("std");

const Kind = @import("kind.zig").Kind;

const length = @import("util/length.zig");
const LengthPercent = length.LengthPercent;
const LenghtPercentAuto = length.LengthPercentAuto;

const rgb = @import("util/rgb.zig");
const RGB = rgb.RGB;

const Circle = @This();

/// The options of the Circle.
pub const Options = struct {
    /// The x coordinate of the center of the circle
    center_x: LengthPercent = .{ .pixel = 0.0 },
    /// The y coordinate of the center of the circle
    center_y: LengthPercent = .{ .pixel = 0.0 },
    /// The radius of the circle
    radius: LengthPercent = .{ .pixel = 0.0 },
    /// The color of the fill of the circle
    fill: ?RGB = null,
    /// The opacity of the fill of the circle
    fill_opacity: f32 = 1.0,
    /// The color of the stroke of the circle
    stroke: ?RGB = null,
    /// The opacity of the stroke of the circle
    stroke_opacity: f32 = 1.0,
    /// The width of the stroke of the circle
    stroke_width: LengthPercent = .{ .pixel = 0.0 },
    /// The opacity of the circle
    opacity: f32 = 1.0,
};

/// The options of the circle
options: Options,

/// Initialize a circle with the given options
pub fn init(options: Options) Circle {
    return Circle {
        .options = options,
    };
}

/// Write the circle to the given writer
pub fn write_to(self: *const Circle, writer: anytype) anyerror!void {
    try writer.writeAll("<circle ");
    try writer.print("cx=\"{}\" ", .{self.options.center_x});
    try writer.print("cy=\"{}\" ", .{self.options.center_y});
    try writer.print("r=\"{}\" ", .{self.options.radius});
    if (self.options.fill) |fill| try writer.print("fill=\"#{X:0>6}\" ", .{fill})
    else try writer.writeAll("fill=\"none\" ");
    try writer.print("fill-opacity=\"{d}\" ", .{self.options.fill_opacity});
    if (self.options.stroke) |stroke| try writer.print("stroke=\"#{X:0>6}\" ", .{stroke})
    else try writer.writeAll("stroke=\"none\" ");
    try writer.print("stroke-opacity=\"{d}\" ", .{self.options.stroke_opacity});
    try writer.print("stroke-width=\"{}\" ", .{self.options.stroke_width});
    try writer.print("opacity=\"{d}\" ", .{self.options.opacity});
    try writer.writeAll("/>");
}

/// Wrap the circle into a kind
pub fn wrap(self: *const Circle) Kind {
    return Kind {
        .circle = self.*
    };
}