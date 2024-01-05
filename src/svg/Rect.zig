const std = @import("std");

const Kind = @import("kind.zig").Kind;

const length = @import("util/length.zig");
const LengthPercent = length.LengthPercent;
const LengthPercentAuto = length.LengthPercentAuto;

const rgb = @import("util/rgb.zig");
const RGB = rgb.RGB;

const Rect = @This();

/// The options of the Rect
pub const Options = struct {
    /// The x coordinate of the top left corner of the rectangle
    x: LengthPercentAuto = .{ .pixel = 0.0 },
    /// The y coordinate of the top left corner of the rectangle
    y: LengthPercentAuto = .{ .pixel = 0.0 },
    /// The width of the rectangle
    width: LengthPercentAuto = .{ .percent = 1.0 },
    /// The height of the rectangle
    height: LengthPercentAuto = .{ .percent = 1.0 },
    /// The x radius of the corner of the rectangle
    radius_x: LengthPercentAuto = .auto,
    /// The y radius of the corner of the rectangle
    radius_y: LengthPercentAuto = .auto,
    /// The color of the fill of the rectangle
    fill: ?RGB = null,
    /// The opacity of the fill of the rectangle
    fill_opacity: f32 = 1.0,
    /// The color of the stroke of the rectangle
    stroke: ?RGB = null,
    /// The opacity of the stroke of the rectangle
    stroke_opacity: f32 = 1.0,
    /// The width of the stroke of the rectangle
    stroke_width: LengthPercent = .{ .pixel = 1.0 },
    /// The opacity of the rectangle (stroke + fill)
    opacity: f32 = 1.0,
};

/// The options of the rectangle
options: Options,

/// Initialize the rectangle with the given options
pub fn init(options: Options) Rect {
    return Rect {
        .options = options,
    };
}

/// Write the rectangle to the given writer
pub fn writeTo(self: *const Rect, writer: anytype) anyerror!void {
    try writer.writeAll("<rect ");
    try writer.print("x=\"{}\" ", .{self.options.x});
    try writer.print("y=\"{}\" ", .{self.options.y});
    try writer.print("width=\"{}\" ", .{self.options.width});
    try writer.print("height=\"{}\" ", .{self.options.height});
    try writer.print("rx=\"{}\" ", .{self.options.radius_x});
    try writer.print("ry=\"{}\" ", .{self.options.radius_y});
    if (self.options.fill) |fill| try writer.print("fill=\"#{X:0>6}\" ", .{fill})
    else try writer.writeAll("fill=\"none\" ");
    try writer.print("fill-opacity=\"{}\" ", .{self.options.fill_opacity});
    if (self.options.stroke) |stroke| try writer.print("stroke=\"#{X:0>6}\" ", .{stroke})
    else try writer.writeAll("stroke=\"none\" ");
    try writer.print("stroke-opacity=\"{}\" ", .{self.options.stroke_opacity});
    try writer.print("stroke-width=\"{}\" ", .{self.options.stroke_width});
    try writer.print("opacity=\"{}\" ", .{self.options.opacity});
    try writer.writeAll("/>");
}

/// Wrap the rectangle in a kind
pub fn wrap(self: *const Rect) Kind {
    return Kind {
        .rect = self.*,
    };
}